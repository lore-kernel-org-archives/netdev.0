From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: check if clients MAC addr has changed
Date: Tue, 29 Jun 2010 08:03:20 -0700
Message-ID: <13473.1277823800@death.nxdomain.ibm.com>
References: <1277822481-25175-1-git-send-email-fleitner@redhat.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andy Gospodarek <gospo@redhat.com>
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:58296 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755958Ab0F2QDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 12:03:48 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5TEpYPc005358
	for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 10:51:34 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5TF3RCh094516
	for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 11:03:29 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5TF3OTp006160
	for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 12:03:26 -0300
In-reply-to: <1277822481-25175-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flavio Leitner <fleitner@redhat.com> wrote:

>When two systems using bonding devices in adaptive load
>balancing (ALB) communicates with each other, an endless
>ping-pong of ARP replies starts between these two systems.
>
>What happens? In the ALB mode, bonding driver keeps track
>of each client connected in a hash table, so it can do the
>receive load balancing (RLB). This hash table is updated
>when an ARP reply is received, then it scans for the client
>entry, updates its MAC address and flag it to be announced
>later. Therefore, two seconds later, the alb monitor runs
>and send for each updated client entry two ARP replies
>updating this specific client. The same process happens on
>the receiving system, causing the endless ping-pong of arp
>replies.
>
>See more information including the relevant functions below:
>
>   System 1                          System 2
>    bond0                             bond0
>
>   ping <system2>
>    ARP request  --------->
>                           <--------- ARP reply
>
>+->rlb_arp_recv  <---------------------+   <--- loop begins
>|  rlb_update_entry_from_arp           |
>|  client_info->ntt = 1;               |
>|  bond_info->rx_ntt = 1;              |
>|                                      |
>|         <communication succeed>      |
>|                                      |
>|  bond_alb_monitor                    |
>|  rlb_update_rx_clients               |
>|  rlb_update_client                   |
>|  arp_create(ARPOP_REPLY)             |
>|   send ARP reply -------------->     V
>|   send ARP reply -------------->
>|                               rlb_arp_recv
>|                               rlb_update_entry_from_arp
>|                               client_info->ntt = 1;
>|                               bond_info->rx_ntt = 1;
>|                           < snipped, same as in system 1>
>+-------           <-------------- send ARP reply
>                   <-------------- send ARP reply
>
>Besides the unneeded networking traffic, this loop breaks
>a cluster because a backup system can't take over the IP
>address. There is always one system sending an ARP reply
>poisoning the network.
>
>This patch fixes the problem adding a check for the MAC
>address before updating it. Thus, if the MAC address didn't
>change, there is no need to update neither to announce it later.
>
>Signed-off-by: Flavio Leitner <fleitner@redhat.com>
>---
> drivers/net/bonding/bond_alb.c |    3 ++-
> 1 files changed, 2 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index 40fdc41..67154bb 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -340,7 +340,8 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
>
> 	if ((client_info->assigned) &&
> 	    (client_info->ip_src == arp->ip_dst) &&
>-	    (client_info->ip_dst == arp->ip_src)) {
>+	    (client_info->ip_dst == arp->ip_src) &&
>+	    (memcmp(client_info->mac_dst, arp->mac_src, ETH_ALEN))) {

	This should use compare_ether_addr instead of memcmp.

	Other than that, this looks good, so add me to the updated patch:

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

> 		/* update the clients MAC address */
> 		memcpy(client_info->mac_dst, arp->mac_src, ETH_ALEN);
> 		client_info->ntt = 1;
>-- 
>1.7.0.1

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
