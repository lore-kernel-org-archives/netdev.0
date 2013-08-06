From: Veaceslav Falico <vfalico@redhat.com>
Subject: [RFC PATCH net-next 3/6] bonding: make bond_alb use 8021q's dev->vlan_info instead of vlan_list
Date: Tue,  6 Aug 2013 19:59:01 +0200
Message-ID: <1375811944-31942-4-git-send-email-vfalico@redhat.com>
References: <1375811944-31942-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30061 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756429Ab3HFR6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 13:58:43 -0400
In-Reply-To: <1375811944-31942-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In alb mode, we only need each vlan's id (that is on top of bond) to tag
learning packets, so get them via __vlan_find_dev_next_id(bond->dev,
last_id).

We must also find *any* vlan (including last id stored in current_alb_vlan)
if we can't find anything >= current_alb_vlan id.

For that, we verify if bond has any vlans at all, and if yes - find the
next vlan id after current_alb_vlan id. So, if vlan id is not 0, we tag the
skb.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c |   28 ++++++++++++++++++----------
 drivers/net/bonding/bond_alb.h |    2 +-
 2 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 2684329..5731540 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -976,6 +976,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 	struct learning_pkt pkt;
 	int size = sizeof(struct learning_pkt);
 	int i;
+	u16 vlan_id = 0;
 
 	memset(&pkt, 0, size);
 	memcpy(pkt.mac_dst, mac_addr, ETH_ALEN);
@@ -1000,22 +1001,29 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 		skb->priority = TC_PRIO_CONTROL;
 		skb->dev = slave->dev;
 
+		rcu_read_lock();
 		if (bond_vlan_used(bond)) {
-			struct vlan_entry *vlan;
+			vlan_id = bond->alb_info.current_alb_vlan+1;
 
-			vlan = bond_next_vlan(bond,
-					      bond->alb_info.current_alb_vlan);
+			vlan_id = __vlan_find_dev_next_id(bond->dev, vlan_id);
+			if (!vlan_id)
+				vlan_id = __vlan_find_dev_next_id(bond->dev, 1);
 
-			bond->alb_info.current_alb_vlan = vlan;
-			if (!vlan) {
+			bond->alb_info.current_alb_vlan = vlan_id;
+
+			if (!vlan_id) {
+				rcu_read_unlock();
 				kfree_skb(skb);
 				continue;
 			}
+		}
+		rcu_read_unlock();
 
-			skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vlan->vlan_id);
+		if (vlan_id) {
+			skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
 			if (!skb) {
-				pr_err("%s: Error: failed to insert VLAN tag\n",
-				       bond->dev->name);
+				pr_err("%s: Error: failed to insert VLAN tag %d\n",
+				       bond->dev->name, vlan_id);
 				continue;
 			}
 		}
@@ -1759,8 +1767,8 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 {
 	if (bond->alb_info.current_alb_vlan &&
-	    (bond->alb_info.current_alb_vlan->vlan_id == vlan_id)) {
-		bond->alb_info.current_alb_vlan = NULL;
+	    (bond->alb_info.current_alb_vlan == vlan_id)) {
+		bond->alb_info.current_alb_vlan = 0;
 	}
 
 	if (bond->alb_info.rlb_enabled) {
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index e7a5b8b..b2452aa 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -170,7 +170,7 @@ struct alb_bond_info {
 						 * rx traffic should be
 						 * rebalanced
 						 */
-	struct vlan_entry	*current_alb_vlan;
+	u16			current_alb_vlan;
 };
 
 int bond_alb_initialize(struct bonding *bond, int rlb_enabled);
-- 
1.7.1
