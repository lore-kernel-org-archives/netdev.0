From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Tue, 24 Mar 2015 21:04:29 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250274DD2@FMSMSX105.amr.corp.intel.com>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
 <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com>
 <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com>
 <55113B9B.3090308@cloudius-systems.com>
 <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com>
 <5511B5AE.1090905@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34293 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284AbbCXVEb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 17:04:31 -0400
In-Reply-To: <5511B5AE.1090905@cloudius-systems.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com] 
>Sent: Tuesday, March 24, 2015 12:06 PM
> Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
> I'm not sure where you see this, on my setup ixgbevf_get_queues() gets 4 in msg[IXGBE_VF_R/TX_QUEUES] which is used to set hw->mac.max_t/rx_queues.
>
>Right. I misread the __ALIGN_MASK() macro.
>But then I can't see where max_rx_queues is used. 

It is used when stopping the Tx/Rx queues in ixgbevf_stop_hw_vf().

>ixgbevf_set_num_queues() sets adapter->num_rx_queues ignoring the above 
>value if num_tcs less or equal to 1:
>
>/* fetch queue configuration from the PF */
>	err = ixgbevf_get_queues(hw, &num_tcs, &def_q);
>
>	spin_unlock_bh(&adapter->mbx_lock);
>
>	if (err)
>		return;
>
>	/* we need as many queues as traffic classes */
>	if (num_tcs > 1) {
>		adapter->num_rx_queues = num_tcs;
>	} else {
>		u16 rss = min_t(u16, num_online_cpus(), IXGBEVF_MAX_RSS_QUEUES);
>
>		switch (hw->api_version) {
>		case ixgbe_mbox_api_11:
>		case ixgbe_mbox_api_12:
>			adapter->num_rx_queues = rss;
>			adapter->num_tx_queues = rss;
>		default:
>			break;
>		}
>	}
>
>This means that if PF returned in IXGBE_VF_RX_QUEUES 1 and if u have 
>more than 1 CPU u will still go and configure 2 Rx queues for a VF. This 
>unless I miss something again... ;)

>From what I can see vmdq->mask can be only for 4 or 8 queues, so the PF will not return 1, unless you meant something else.

The comment about the 1 queue is outdated though - I think it's leftover from the time the VF only allowed single queue.

>> BTW - there are other issues with your patches. The indirection table seems to come out as all 0s and the VF driver reports link >> down/up when querying it.

>Worked just fine to me on x540.
>What is your setup? How did u check it? Did u remember to patch "ip" 
>tool and enable the querying?

I have x540 as well and used the modified ip, otherwise the operation won't be allowed. I will do some more debugging when I get a chance and will get back to you.

>>
>> Where is this information useful anyway - what is the use case? There is no description in your patches for why all this is >>needed.
>
>I'm not sure it's required to explain why would I want to add a standard 
>ethtool functionality to a driver.
>However, since u've asked - we are developing a software infrastructure 
>that needs the ability to query the VF's indirection table and RSS hash 
>key from inside the Guest OS (particularly on AWS) in order to be able 
>to open the socket the way that its traffic would arrive to a specific CPU.

Understanding the use case can help with the implementation. Because you need to get the RSS info from the PF for macs < x550 this opens up the possibility to abuse (even if inadvertently) the mailbox if someone decided to query that info in a loop - like we have seen this happen with net-snmp.

Have you tested what happens if you run:

while true
do
	ethtool --show-rxfh-indir ethX
done

in the background while passing traffic through the VF?

Perhaps storing the RSS key and the table is better option than having to invoke the mailbox on every read.

Thanks,
Emil
