From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Thu, 26 Mar 2015 20:10:45 +0200
Message-ID: <55144BA5.5040507@cloudius-systems.com>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com> <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com> <55113B9B.3090308@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com> <5511B5AE.1090905@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274DD2@FMSMSX105.amr.corp.intel.com> <55127F8D.3070309@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250275B81@FMSMSX105.amr.corp.intel.com> <551317DE.90500@cloudius-systems.com> <551322F2.5020101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37636 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbbCZSKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 14:10:49 -0400
Received: by wiaa2 with SMTP id a2so34270344wia.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 11:10:48 -0700 (PDT)
In-Reply-To: <551322F2.5020101@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/25/15 23:04, Alexander Duyck wrote:
>
> On 03/25/2015 01:17 PM, Vlad Zolotarov wrote:
>>
>>
>> On 03/25/15 20:35, Tantilov, Emil S wrote:
>>>> -----Original Message-----
>>>> From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com]
>>>> Sent: Wednesday, March 25, 2015 2:28 AM
>>>> Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
>>> <snip>
>>>
>>>>> Have you tested what happens if you run:
>>>>>
>>>>> while true
>>>>> do
>>>>>     ethtool --show-rxfh-indir ethX
>>>>> done
>>>>>
>>>>> in the background while passing traffic through the VF?
>>>> I understand your concerns but let's start with clarifying a few 
>>>> things.
>>>> First, VF driver is by definition not trusted. If it (or its user)
>>>> decides to do anything malicious (like u proposed above) that would
>>>> eventually hurt (only this) VF's performance - nobody should care.
>>>> However the right question here would be: "How the above use case may
>>>> hurt the corresponding PF or other VFs' performance?" And since the
>>>> mailbox operation involves quite a few MMIO writes and reads this may
>>>> slow the PF quite a bit and this may be a problem that should be taken
>>>> care of. However it wasn't my patch series that have introduced it. 
>>>> The
>>>> same problem would arise if Guest would change VF's MAC address in a
>>>> tight loop like above. Namely any VF slow path operation that would
>>>> eventually cause the VF-PF channel transaction may be used to 
>>>> create an
>>>> attack on a PF.
>>> There are operations that can be disruptive to the VF I am not 
>>> arguing that,
>>> the issue introduced by these patches has mostly to do with the fact 
>>> that now
>>> we can hit the mailbox more often for what is mostly static 
>>> information.
>>>
>>> Especially with ethtool we already had to deal with an issue caused 
>>> by net-snmp:
>>> https://sourceforge.net/p/e1000/mailman/message/32188362/
>>>
>>> Where net-snmp was being too aggressive when collecting information, 
>>> even if most of it was static.
>>
>> Emil, I don't really understand what are u trying to protect here 
>> against. If a user would want to shoot him/herself in the leg - 
>> he/she would still be able to do it with the other mailbox involving 
>> operations like MAC change. So, what's the sense to add useless lines?
>>
>>>
>>>> Perhaps storing the RSS key and the table is better option than 
>>>> having to invoke the mailbox on every read.
>>>> I don't think this could work if I understand your proposal correctly.
>>>> The only way to cache the result that would decrease the number of 
>>>> mbox
>>>> transactions would be to cache it in the VF. But how could i 
>>>> invalidate
>>>> this cache if the table content has been changed by a PF? I think the
>>>> main source of a confusion here is that u assume that PF driver is a
>>>> Linux ixgbe driver that doesn't support an indirection table change at
>>>> the moment. As I have explained above - this should not be assumed.
>>> You keep mentioning other drivers - what other driver do you mean?
>>> All the PF drivers that enable SRIOV are maintained and supported by 
>>> Intel.
>>>
>>> For HW older than X550 we can simply not allow the RSS hash to be 
>>> modified if the driver is loaded in SRIOV mode.
>>> This way the RSS info can be read once the driver is loaded. For 
>>> X550 this can all be done in the VF, so you can avoid calling the 
>>> mailbox altogether.
>>> I understand this is a bit limiting, but this is due to HW 
>>> limitation anyway (VFs do not have their own RSS config).
>>
>> Let me remind u that Linux, FreeBSD, XEN  and DPDK PF drivers are all 
>> open source so u can't actually go and "not allow" things. ;) And 
>> although Intel developers contribute most of the code there are and 
>> will be other contributors too so I doubt the proposed above approach 
>> fits the open source spirit well. ;)
>
> Actually these drivers already support multiple OSes just fine. The 
> part where I think you are confused is that you assume they all use 
> the same Mailbox API which they likely wouldn't.  I would suggest 
> taking a look at ixgbe_pfvf_api_rev in mbx.h of the VF driver. 
> Different OSes have different things that can be supported, so for 
> example the ixgbe_mbox_api_20 is reserved for a Solaris based PF/VF 
> combination.  I would suspect that FreeBSD will likely have to conform 
> to the existing APIs, or report that it only supports a different 
> version of the mailbox API.
>
>>
>> The user should actually not query the indirection table and a hash 
>> key too often. And if he/she does - it should be his/her problem.
>> However, if like with the ixgbevf_set_num_queues() u insist on your 
>> way of doing this (on caching the indirection table and hash key) - 
>> then please let me know and I will add it. Because, frankly, I care 
>> about the PF part of this series much more than for the VF part... ;)
>
> I would say you don't need to cache it, but for 82599 and x540 there 
> isn't any need to store more than 3 bits per entry, 384b, or 12 DWORDs 
> for the entire RETA of the VF since the hardware can support at most 8 
> queues w/ SR-IOV.

Isn't it 2 bits? VF may have up to 8 queues in total but it supports up 
to 4 RSS queues (according to MRQC.MRQE and PSRTYPE[n].RQPL description...

> Then you only need one message instead of 3 which will reduce quite a 
> bit of the complication with all of this.
>
> Also it might make more sense to start working on displaying this on 
> the PF before you start trying to do this on the VF.  As far as I know 
> ixgbe still doesn't have this functionality and it would make much 
> more sense to enable that first on ixgbe before you start trying to 
> find a way to feed the data to the VF.
>
> - Alex
