From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Wed, 25 Mar 2015 11:27:41 +0200
Message-ID: <55127F8D.3070309@cloudius-systems.com>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com> <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com> <55113B9B.3090308@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com> <5511B5AE.1090905@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274DD2@FMSMSX105.amr.corp.intel.com>
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
Received: from mail-wg0-f42.google.com ([74.125.82.42]:33604 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbbCYJ1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 05:27:45 -0400
Received: by wgbcc7 with SMTP id cc7so20146206wgb.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 02:27:43 -0700 (PDT)
In-Reply-To: <87618083B2453E4A8714035B62D6799250274DD2@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/24/15 23:04, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com]
>> Sent: Tuesday, March 24, 2015 12:06 PM
>> Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
>> I'm not sure where you see this, on my setup ixgbevf_get_queues() gets 4 in msg[IXGBE_VF_R/TX_QUEUES] which is used to set hw->mac.max_t/rx_queues.
>>
>> Right. I misread the __ALIGN_MASK() macro.
>> But then I can't see where max_rx_queues is used.
> It is used when stopping the Tx/Rx queues in ixgbevf_stop_hw_vf().

Of course, I meant it's not used during the adapter->num_rx_queues value 
calculation. Let's move this discussion to the appropriate patch thread.

>
>> ixgbevf_set_num_queues() sets adapter->num_rx_queues ignoring the above
>> value if num_tcs less or equal to 1:
>>
>> /* fetch queue configuration from the PF */
>> 	err = ixgbevf_get_queues(hw, &num_tcs, &def_q);
>>
>> 	spin_unlock_bh(&adapter->mbx_lock);
>>
>> 	if (err)
>> 		return;
>>
>> 	/* we need as many queues as traffic classes */
>> 	if (num_tcs > 1) {
>> 		adapter->num_rx_queues = num_tcs;
>> 	} else {
>> 		u16 rss = min_t(u16, num_online_cpus(), IXGBEVF_MAX_RSS_QUEUES);

>>
>> 		switch (hw->api_version) {
>> 		case ixgbe_mbox_api_11:
>> 		case ixgbe_mbox_api_12:
>> 			adapter->num_rx_queues = rss;
>> 			adapter->num_tx_queues = rss;
>> 		default:
>> 			break;
>> 		}
>> 	}
>>
>> This means that if PF returned in IXGBE_VF_RX_QUEUES 1 and if u have
>> more than 1 CPU u will still go and configure 2 Rx queues for a VF. This
>> unless I miss something again... ;)
>  From what I can see vmdq->mask can be only for 4 or 8 queues, so the PF will not return 1, unless you meant something else.
This is only if PF is driven by a Linux ixgbe PF driver as it is in the 
upstream tree right now. AFAIK VF driver should be completely decoupled 
from the PF driver and all the configuration decisions should be made 
based on the VF-PF communication via VF-PF channel (mailbox).
Pls., see my comments on the thread of your patches that have added 
these lines.

>
> The comment about the 1 queue is outdated though - I think it's leftover from the time the VF only allowed single queue.

Looks like it. ;)

>
>>> BTW - there are other issues with your patches. The indirection table seems to come out as all 0s and the VF driver reports link >> down/up when querying it.
>> Worked just fine to me on x540.
>> What is your setup? How did u check it? Did u remember to patch "ip"
>> tool and enable the querying?
> I have x540 as well and used the modified ip, otherwise the operation won't be allowed. I will do some more debugging when I get a chance and will get back to you.

Pls., make sure u use v7 patches.

One problem that there may still be is that I may have protected the 
mbox access by adapter->mbx_lock spinlock similarly to 
ixgbevf_set_num_queues() since I don't think ethtool ensures the atomicy 
of its requests in a context of a specific device and thus mbox could be 
trashed by ethtool operations running in parallel on different CPUs.


>
>>> Where is this information useful anyway - what is the use case? There is no description in your patches for why all this is >>needed.
>> I'm not sure it's required to explain why would I want to add a standard
>> ethtool functionality to a driver.
>> However, since u've asked - we are developing a software infrastructure
>> that needs the ability to query the VF's indirection table and RSS hash
>> key from inside the Guest OS (particularly on AWS) in order to be able
>> to open the socket the way that its traffic would arrive to a specific CPU.
> Understanding the use case can help with the implementation. Because you need to get the RSS info from the PF for macs < x550 this opens up the possibility to abuse (even if inadvertently) the mailbox if someone decided to query that info in a loop - like we have seen this happen with net-snmp.
>
> Have you tested what happens if you run:
>
> while true
> do
> 	ethtool --show-rxfh-indir ethX
> done
>
> in the background while passing traffic through the VF?
I understand your concerns but let's start with clarifying a few things. 
First, VF driver is by definition not trusted. If it (or its user) 
decides to do anything malicious (like u proposed above) that would 
eventually hurt (only this) VF's performance - nobody should care. 
However the right question here would be: "How the above use case may 
hurt the corresponding PF or other VFs' performance?" And since the 
mailbox operation involves quite a few MMIO writes and reads this may 
slow the PF quite a bit and this may be a problem that should be taken 
care of. However it wasn't my patch series that have introduced it. The 
same problem would arise if Guest would change VF's MAC address in a 
tight loop like above. Namely any VF slow path operation that would 
eventually cause the VF-PF channel transaction may be used to create an 
attack on a PF.

This problem naturally may not be resolved on a VF level but only on a 
PF level since VF is not a trusted component. One option could be to 
allow only a specific number of mbox operations from a specific VF in a 
specific time period: e.g. at most 1 operation every jiffy.

I don't see any code handling any protection of this sort in a PF driver 
at the moment. However I maybe missing some HW configuration that limits 
the slow path interrupts rate thus limiting the number of mbox requests 
rate...

>
> Perhaps storing the RSS key and the table is better option than having to invoke the mailbox on every read.

I don't think this could work if I understand your proposal correctly. 
The only way to cache the result that would decrease the number of mbox 
transactions would be to cache it in the VF. But how could i invalidate 
this cache if the table content has been changed by a PF? I think the 
main source of a confusion here is that u assume that PF driver is a 
Linux ixgbe driver that doesn't support an indirection table change at 
the moment. As I have explained above - this should not be assumed.

thanks,
vlad

>
> Thanks,
> Emil
>
>
