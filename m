From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/3] bonding: Fix ALB mode to balance traffic on VLANs
Date: Tue,  4 Nov 2008 17:51:15 -0800
Message-ID: <1225849876-8930-3-git-send-email-fubar@us.ibm.com>
References: <1225849876-8930-1-git-send-email-fubar@us.ibm.com>
 <1225849876-8930-2-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41661 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754228AbYKEBvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 20:51:22 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA51lgeW028078
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:47:42 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA51pLqV118826
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:51:21 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA51pKTW019890
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:51:21 -0500
In-Reply-To: <1225849876-8930-2-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	The current ALB function that processes incoming ARPs
does not handle traffic for VLANs configured above bonding.  This causes
traffic on those VLANs to all be assigned the same slave.  This patch
corrects that misbehavior by locating the bonding interface nested below
the VLAN interface.

	Bug reported by Sven Anders <anders@anduras.de>, who also
tested an earlier version of this patch and confirmed that it resolved
the problem.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_alb.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 87437c7..e170fa2 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -346,14 +346,18 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 
 static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct packet_type *ptype, struct net_device *orig_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond;
 	struct arp_pkt *arp = (struct arp_pkt *)skb->data;
 	int res = NET_RX_DROP;
 
 	if (dev_net(bond_dev) != &init_net)
 		goto out;
 
-	if (!(bond_dev->flags & IFF_MASTER))
+	while (bond_dev->priv_flags & IFF_802_1Q_VLAN)
+		bond_dev = vlan_dev_real_dev(bond_dev);
+
+	if (!(bond_dev->priv_flags & IFF_BONDING) ||
+	    !(bond_dev->flags & IFF_MASTER))
 		goto out;
 
 	if (!arp) {
@@ -368,6 +372,9 @@ static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct
 
 	if (arp->op_code == htons(ARPOP_REPLY)) {
 		/* update rx hash table for this ARP */
+		printk("rar: update orig %s bond_dev %s\n", orig_dev->name,
+		       bond_dev->name);
+		bond = bond_dev->priv;
 		rlb_update_entry_from_arp(bond, arp);
 		dprintk("Server received an ARP Reply from client\n");
 	}
@@ -818,7 +825,7 @@ static int rlb_initialize(struct bonding *bond)
 
 	/*initialize packet type*/
 	pk_type->type = __constant_htons(ETH_P_ARP);
-	pk_type->dev = bond->dev;
+	pk_type->dev = NULL;
 	pk_type->func = rlb_arp_recv;
 
 	/* register to receive ARPs */
-- 
1.6.0.2

