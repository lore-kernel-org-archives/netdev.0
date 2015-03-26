From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Thu, 26 Mar 2015 08:59:03 -0700
Message-ID: <55142CC7.70302@redhat.com>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com> <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com> <55113B9B.3090308@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com> <5511B5AE.1090905@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274DD2@FMSMSX105.amr.corp.intel.com> <55127F8D.3070309@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250275B81@FMSMSX105.amr.corp.intel.com> <551317DE.90500@cloudius-systems.com> <551322F2.5020101@redhat.com> <5513D2C9.7010907@cloudius-systems.com> <55141A4B.1040903@redhat.com> <55142177.9080705@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59728 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752207AbbCZP7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 11:59:09 -0400
In-Reply-To: <55142177.9080705@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/26/2015 08:10 AM, Vlad Zolotarov wrote:
>
>
> On 03/26/15 16:40, Alexander Duyck wrote:
>>
>> On 03/26/2015 02:35 AM, Vlad Zolotarov wrote:
>>>
>>>
>>> On 03/25/15 23:04, Alexander Duyck wrote:
>>>>
>>>> On 03/25/2015 01:17 PM, Vlad Zolotarov wrote:
>>>>>
>>>>>
>>>>> On 03/25/15 20:35, Tantilov, Emil S wrote:
>>>>>>> -----Original Message-----
>>>>>>> From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com]
>>>>>>> Sent: Wednesday, March 25, 2015 2:28 AM
>>>>>>> Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
>>>>>>
>>>>>
>>

<snip>

>>
>>>
>>>>
>>>>>
>>>>> The user should actually not query the indirection table and a 
>>>>> hash key too often. And if he/she does - it should be his/her 
>>>>> problem.
>>>>> However, if like with the ixgbevf_set_num_queues() u insist on 
>>>>> your way of doing this (on caching the indirection table and hash 
>>>>> key) - then please let me know and I will add it. Because, 
>>>>> frankly, I care about the PF part of this series much more than 
>>>>> for the VF part... ;)
>>>>
>>>> I would say you don't need to cache it, but for 82599 and x540 
>>>> there isn't any need to store more than 3 bits per entry, 384b, or 
>>>> 12 DWORDs for the entire RETA of the VF since the hardware can 
>>>> support at most 8 queues w/ SR-IOV. Then you only need one message 
>>>> instead of 3 which will reduce quite a bit of the complication with 
>>>> all of this.
>>>>
>>>> Also it might make more sense to start working on displaying this 
>>>> on the PF before you start trying to do this on the VF. As far as I 
>>>> know ixgbe still doesn't have this functionality and it would make 
>>>> much more sense to enable that first on ixgbe before you start 
>>>> trying to find a way to feed the data to the VF.
>>>
>>> Let's agree on the next steps:
>>>
>>> 1. I'll reduce the series scope to 82599 and x540 devices.
>>
>> For mailbox implementation that is okay, my advice for the x550 would 
>> be to just read the registers.  They should already be defined in the 
>> driver so it is just a matter of reversing the process for writing 
>> the RETA.  You should have a solid grasp of that once you implement 
>> the solution for the PF.
>
> The problem is that I have no means to validate the solution - I have 
> only x540 devices (nor specs). I'd prefer not to work in darkness and 
> let u, guys, do it...

If it helps the specs for the x540 can be found at 
http://www.intel.com/content/www/us/en/network-adapters/10-gigabit-network-adapters/ethernet-x540-datasheet.html. 
Section 8 has a full list of the register definitions.

All the code you need should already be stored in ixgbe_setup_reta and 
ixgbe_setup_vfreta.  If you do it right you shouldn't even need to read 
the hardware.  Odds are you could generate it in software and that is 
what you would be accessing on the PF.  After all, if at some point you 
reset the hardware you would need to restore it from software wouldn't 
you, and since the table is static for now you should be able to 
calculate the value without need of reading a register.  If at some 
point in the future you can change the table then it means a copy has to 
be maintained in kernel memory and at that point you could use that for 
the data you would be sending to the VF.

>>
>>> 4. I won't implement the caching of the indirection and RSS hash key
>>>    query results in the VF level.
>>
>> The idea with caching is to keep the number of messages across the 
>> mailbox to a minimum.  Compressing it down to 3 bits per entry will 
>> help some, but I am not sure if that is enough to completely mitigate 
>> the need for caching.  For now though the caching isn't a must-have, 
>> and it won't be needed for x550 since it can access the table 
>> directly.  The main thing I would recommend keeping an eye on would 
>> be how long it will take to complete the messages necessary to get 
>> the ethtool info.  If there are any scenarios where things take more 
>> than 1 second then I would say we are taking too long and we would 
>> have to look into caching because we want to avoid holding the rtnl 
>> lock for any extended period of time.
>
> I've described the limitations the caching approach imposes above. I 
> suggest we follow your approach here - solve the problems when they 
> arrive. ;) I haven't succeeded to make it take as long as even near 
> one second.
>
>>
>> My advice is get the PF patches in first, then we can look at trying 
>> to get feature parity on the VF.
>
> "feature parity on the VF"?

Get "ethtool -x/X" working on the PF, and then get it working on the 
VF.  That way it makes for very simple verification as you can inspect 
that the PF and VF tables are consistent.  As I said if nothing else you 
can probably take a look at the igb driver to see how this was done on 
the 1Gbps Intel hardware.

>
> I'll send the patches later today. I'll incorporate the new PF code 
> into the existing series.

You might want to break things out into a couple series of patches. Do 
the PF driver first just to make sure you have an understanding of what 
you expect, think of it as a proof of concept if nothing else for how 
you want the VF to function, then submit the VF series as a separate 
patch set and include the mailbox API changes.

- Alex
