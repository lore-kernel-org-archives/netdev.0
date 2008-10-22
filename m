From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Possible bug in bonding driver (with VLAN in ALB mode)
Date: Wed, 22 Oct 2008 12:13:19 -0700
Message-ID: <23022.1224702799@death.nxdomain.ibm.com>
References: <48FE0EEB.7050503@anduras.de> <1830.1224612755@death.nxdomain.ibm.com> <48FE51C5.2010800@anduras.de> <4231.1224629540@death.nxdomain.ibm.com> <48FF3A05.1010408@anduras.de>
Cc: netdev@vger.kernel.org
To: Sven Anders <anders@anduras.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:49153 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752031AbYJVTNa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 15:13:30 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9MJDN4W030922
	for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 15:13:23 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9MJDNiH124006
	for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 15:13:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9MJDNEx000921
	for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 15:13:23 -0400
In-reply-to: <48FF3A05.1010408@anduras.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sven Anders <anders@anduras.de> wrote:
[...]
>Certainly, this is only a test bugfix only, because it does not
>work with more than one active bond. Any ideas how to implement
>this correctly? Do we have to use an "dev_add_pack()" for each
>VLAN we are adding?

	Can you give this a try?  This patch just checks for VLAN-ness
and extracts the real device if so, then does the usual "is it bonding"
stuff to the real device.

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 3d39278..ec1c115 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -341,14 +341,18 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 
 static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct packet_type *ptype, struct net_device *orig_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond;
 	struct arp_pkt *arp = (struct arp_pkt *)skb->data;
 	int res = NET_RX_DROP;
 
 	if (dev_net(bond_dev) != &init_net)
 		goto out;
 
-	if (!(bond_dev->flags & IFF_MASTER))
+	if (bond_dev->priv_flags & IFF_802_1Q_VLAN)
+		bond_dev = vlan_dev_real_dev(bond_dev);
+
+	if (!(bond_dev->priv_flags & IFF_BONDING) ||
+	    !(bond_dev->flags & IFF_MASTER))
 		goto out;
 
 	if (!arp) {
@@ -363,6 +367,7 @@ static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct
 
 	if (arp->op_code == htons(ARPOP_REPLY)) {
 		/* update rx hash table for this ARP */
+		bond = bond_dev->priv;
 		rlb_update_entry_from_arp(bond, arp);
 		dprintk("Server received an ARP Reply from client\n");
 	}
@@ -813,7 +818,7 @@ static int rlb_initialize(struct bonding *bond)
 
 	/*initialize packet type*/
 	pk_type->type = __constant_htons(ETH_P_ARP);
-	pk_type->dev = bond->dev;
+	pk_type->dev = NULL;
 	pk_type->func = rlb_arp_recv;
 
 	/* register to receive ARPs */


>What troubles me is, that nobody since the addition of VLAN support
>to bonding in 2004 had this problem before. Did this (ever) work in
>one older version of the bonding driver?

	I suspect not; I don't recall checking the load balancing
performance of this kind of configuration (all VLANs over balance-alb).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
