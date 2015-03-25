From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Wed, 25 Mar 2015 22:17:34 +0200
Message-ID: <551317DE.90500@cloudius-systems.com>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com> <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com> <55113B9B.3090308@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com> <5511B5AE.1090905@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274DD2@FMSMSX105.amr.corp.intel.com> <55127F8D.3070309@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250275B81@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:36489 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbbCYURh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 16:17:37 -0400
Received: by wgra20 with SMTP id a20so40668514wgr.3
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 13:17:36 -0700 (PDT)
In-Reply-To: <87618083B2453E4A8714035B62D6799250275B81@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/25/15 20:35, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com]
>> Sent: Wednesday, March 25, 2015 2:28 AM
>> Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
> <snip>
>
>>> Have you tested what happens if you run:
>>>
>>> while true
>>> do
>>> 	ethtool --show-rxfh-indir ethX
>>> done
>>>
>>> in the background while passing traffic through the VF?
>> I understand your concerns but let's start with clarifying a few things.
>> First, VF driver is by definition not trusted. If it (or its user)
>> decides to do anything malicious (like u proposed above) that would
>> eventually hurt (only this) VF's performance - nobody should care.
>> However the right question here would be: "How the above use case may
>> hurt the corresponding PF or other VFs' performance?" And since the
>> mailbox operation involves quite a few MMIO writes and reads this may
>> slow the PF quite a bit and this may be a problem that should be taken
>> care of. However it wasn't my patch series that have introduced it. The
>> same problem would arise if Guest would change VF's MAC address in a
>> tight loop like above. Namely any VF slow path operation that would
>> eventually cause the VF-PF channel transaction may be used to create an
>> attack on a PF.
> There are operations that can be disruptive to the VF I am not arguing that,
> the issue introduced by these patches has mostly to do with the fact that now
> we can hit the mailbox more often for what is mostly static information.
>
> Especially with ethtool we already had to deal with an issue caused by net-snmp:
> https://sourceforge.net/p/e1000/mailman/message/32188362/
>
> Where net-snmp was being too aggressive when collecting information, even if most of it was static.

Emil, I don't really understand what are u trying to protect here 
against. If a user would want to shoot him/herself in the leg - he/she 
would still be able to do it with the other mailbox involving operations 
like MAC change. So, what's the sense to add useless lines?

>
>> Perhaps storing the RSS key and the table is better option than having to invoke the mailbox on every read.
>> I don't think this could work if I understand your proposal correctly.
>> The only way to cache the result that would decrease the number of mbox
>> transactions would be to cache it in the VF. But how could i invalidate
>> this cache if the table content has been changed by a PF? I think the
>> main source of a confusion here is that u assume that PF driver is a
>> Linux ixgbe driver that doesn't support an indirection table change at
>> the moment. As I have explained above - this should not be assumed.
> You keep mentioning other drivers - what other driver do you mean?
> All the PF drivers that enable SRIOV are maintained and supported by Intel.
>
> For HW older than X550 we can simply not allow the RSS hash to be modified if the driver is loaded in SRIOV mode.
> This way the RSS info can be read once the driver is loaded. For X550 this can all be done in the VF, so you can avoid calling the mailbox altogether.
> I understand this is a bit limiting, but this is due to HW limitation anyway (VFs do not have their own RSS config).

Let me remind u that Linux, FreeBSD, XEN  and DPDK PF drivers are all 
open source so u can't actually go and "not allow" things. ;) And 
although Intel developers contribute most of the code there are and will 
be other contributors too so I doubt the proposed above approach fits 
the open source spirit well. ;)

The user should actually not query the indirection table and a hash key 
too often. And if he/she does - it should be his/her problem.
However, if like with the ixgbevf_set_num_queues() u insist on your way 
of doing this (on caching the indirection table and hash key) - then 
please let me know and I will add it. Because, frankly, I care about the 
PF part of this series much more than for the VF part... ;)

>
> Thanks,
> Emil
>
>
