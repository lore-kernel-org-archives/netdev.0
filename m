From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v2 10/13] bonding: split alb_send_learning_packets()
Date: Wed, 28 Aug 2013 14:02:29 +0200
Message-ID: <1377691352-4146-11-git-send-email-vfalico@redhat.com>
References: <1377691352-4146-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21470 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752979Ab3H1MDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 08:03:32 -0400
In-Reply-To: <1377691352-4146-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create alb_send_lp_vid(), which will handle the skb/lp creation, vlan
tagging and sending, and use it in alb_send_learning_packets().

This way all the logic remains in alb_send_learning_packets(), which
becomes a lot more cleaner and easier to understand.

v1: no change
v2: no change

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c |   59 +++++++++++++++++++++++----------------
 1 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 3a5db7b..3ca3c85 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -971,35 +971,53 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 
 /*********************** tlb/rlb shared functions *********************/
 
-static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
+static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
+			    u16 vid)
 {
-	struct bonding *bond = bond_get_bond_by_slave(slave);
 	struct learning_pkt pkt;
+	struct sk_buff *skb;
 	int size = sizeof(struct learning_pkt);
-	int i;
+	char *data;
 
 	memset(&pkt, 0, size);
 	memcpy(pkt.mac_dst, mac_addr, ETH_ALEN);
 	memcpy(pkt.mac_src, mac_addr, ETH_ALEN);
 	pkt.type = cpu_to_be16(ETH_P_LOOP);
 
-	for (i = 0; i < MAX_LP_BURST; i++) {
-		struct sk_buff *skb;
-		char *data;
+	skb = dev_alloc_skb(size);
+	if (!skb)
+		return;
 
-		skb = dev_alloc_skb(size);
+	data = skb_put(skb, size);
+	memcpy(data, &pkt, size);
+
+	skb_reset_mac_header(skb);
+	skb->network_header = skb->mac_header + ETH_HLEN;
+	skb->protocol = pkt.type;
+	skb->priority = TC_PRIO_CONTROL;
+	skb->dev = slave->dev;
+
+	if (vid) {
+		skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vid);
 		if (!skb) {
+			pr_err("%s: Error: failed to insert VLAN tag\n",
+			       slave->bond->dev->name);
 			return;
 		}
+	}
 
-		data = skb_put(skb, size);
-		memcpy(data, &pkt, size);
+	dev_queue_xmit(skb);
+}
 
-		skb_reset_mac_header(skb);
-		skb->network_header = skb->mac_header + ETH_HLEN;
-		skb->protocol = pkt.type;
-		skb->priority = TC_PRIO_CONTROL;
-		skb->dev = slave->dev;
+
+static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
+{
+	struct bonding *bond = bond_get_bond_by_slave(slave);
+	u16 vlan_id;
+	int i;
+
+	for (i = 0; i < MAX_LP_BURST; i++) {
+		vlan_id = 0;
 
 		if (bond_vlan_used(bond)) {
 			struct vlan_entry *vlan;
@@ -1008,20 +1026,13 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 					      bond->alb_info.current_alb_vlan);
 
 			bond->alb_info.current_alb_vlan = vlan;
-			if (!vlan) {
-				kfree_skb(skb);
+			if (!vlan)
 				continue;
-			}
 
-			skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vlan->vlan_id);
-			if (!skb) {
-				pr_err("%s: Error: failed to insert VLAN tag\n",
-				       bond->dev->name);
-				continue;
-			}
+			vlan_id = vlan->vlan_id;
 		}
 
-		dev_queue_xmit(skb);
+		alb_send_lp_vid(slave, mac_addr, vlan_id);
 	}
 }
 
-- 
1.7.1
