From: <Narendra_K@Dell.com>
Subject: RE: bonding device in balance-alb mode shows packet loss in kernel
 3.2-rc6
Date: Fri, 30 Dec 2011 17:52:09 +0530
Message-ID: <E31FB011129F30488D5861F38390491520C5327012@BLRX7MCDC201.AMER.DELL.COM>
References: <E31FB011129F30488D5861F38390491520C52BCC8B@BLRX7MCDC201.AMER.DELL.COM>
 <27384.1325102910@death>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <Surya_Prabhakar@Dell.com>,
	<Shyam_Iyer@Dell.com>
To: <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:6823 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143Ab1L3MWO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 07:22:14 -0500
In-Reply-To: <27384.1325102910@death>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Jay Vosburgh [mailto:fubar@us.ibm.com]
> Sent: Thursday, December 29, 2011 1:39 AM
> To: K, Narendra
> Cc: netdev@vger.kernel.org
> Subject: Re: bonding device in balance-alb mode shows packet loss in kernel
> 3.2-rc6
> 
> <Narendra_K@Dell.com> wrote:
> 
> >By observing the packets on remote HOST2, the sequence is
> >
> >1. 'bond0' broadcasts an ARP request with source MAC equal to 'bond0'
> >MAC address and receives a ARP response to the same.
> >Next few packets are received.
> 
> 	In this case, it means the peer has been assigned to the "em2"
> slave.
> 
> >2. After some, there are 2 ARP replies from 'bond0' to HOST2 with
> >source MAC equal to 'inactive slave' MAC id. Now HOST2 sends ICMP
> >response with destnation MAC equal to inactive slave MAC id and these
> >packets are dropped.
> 
> 	This part is not unusual for the balance-alb mode; the traffic is
> periodically rebalanced, and in this case the peer HOST2 was likely assigned
> to a different slave that it was previously.  I'm not sure why the packets don't
> reach their destination, but they shouldn't be dropped due to the slave being
> "inactive," as I explained above.
> 
> >The wireshark protocol trace is attached to this note.
> >
> >3. The behavior was independent of the Network adapters models.
> >
> >4. Also, I had few prints in 'eth_type_trans' and it seemed like the 'inactive
> slave'
> >was not receiving any frames destined to it (00:21:9b:9d:a5:74) except ARP
> broadcasts.
> >Setting the 'inactive slave' in 'promisc' mode made bond0 see the responses.
> 
> 	This seems very strange, since the MAC information shown later
> suggests that the slaves all are using their original MAC addresses, so the
> packets ought to be delivered.
> 
> 	I'm out of the office until next week, so I won't have an opportunity
> to try and reproduce this myself until then.  I wonder if something in the
> rx_handler changes over the last few months has broken this, although a
> look at the code suggests that it should be doing the right things.

Hi Jay, thanks for looking into this. I am out of office next week.
I am copying Surya if additional information is required.
(Please keep Surya in CC).

It was strange that 'eth_type_trans' showed only ARP broadcasts for
em3 and em4. Interestingly when i set the perm HW address of em3 manually
by

ifconfig em3 hw ether 00:21:9b:9d:a5:74

packet drops stopped and 'eth_type_trans' showed unicast frames
destined to 00:21:9b:9d:a5:74.

I put few debug prints in 'bnx2_set_mac_addr' to see what MAC ids are
getting set in the hardware. When i stopped and started the bond0,
all the slaves seemed to have the same MAC id 
(of em2 and bond0 00:21:9b:9d:a5:72). 

Also, the following change made the packet drops stop and prints in
'bnx2_set_mac_addr' seemed to indicate that all slaves got unique
mac id set in hardware.

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7f87568..e717267 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1620,7 +1620,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
         */
        memcpy(new_slave->perm_hwaddr, slave_dev->dev_addr, ETH_ALEN);

-       if (!bond->params.fail_over_mac) {
+       if (!bond->params.fail_over_mac && !bond_is_lb(bond)) {
                /*
                 * Set slave to master's mac address.  The application already
                 * set the master's mac address to that of the first slave


With regards,
Narendra K
 
