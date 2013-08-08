From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v1 net-next 3/6] bonding: make bond_alb use 8021q's dev->vlan_info instead of vlan_list
Date: Thu,  8 Aug 2013 12:21:06 +0200
Message-ID: <1375957269-13100-4-git-send-email-vfalico@redhat.com>
References: <1375957269-13100-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964873Ab3HHKUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 06:20:48 -0400
In-Reply-To: <1375957269-13100-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC -> v1: use the changed __vlan_find_dev_next, which now works with
	   vlan's net_device instead of vlan's id. Also, fix a subtle race
	   condition if we remove the only vlan while looping through
	   MAX_LP_BURST - we end up with using the old vlan_id, so set it
	   to 0 if we don't have vlans.

In alb mode, we only need each vlan's id (that is on top of bond) to tag
learning packets, so get them via __vlan_find_dev_next(bond->dev, last_dev).

We must also find *any* vlan (including last id stored in current_alb_vlan)
if we can't find anything >= current_alb_vlan id.

For that, we verify if bond has any vlans at all, and if yes - find the
next vlan id after current_alb_vlan id. So, if vlan id is not 0, we tag the
skb.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c |   47 ++++++++++++++++++++++++++++-----------
 drivers/net/bonding/bond_alb.h |    2 +-
 2 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 2684329..ced5753 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -974,8 +974,9 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 {
 	struct bonding *bond = bond_get_bond_by_slave(slave);
 	struct learning_pkt pkt;
+	struct net_device *vlan_dev;
 	int size = sizeof(struct learning_pkt);
-	int i;
+	int i, vlan_id;
 
 	memset(&pkt, 0, size);
 	memcpy(pkt.mac_dst, mac_addr, ETH_ALEN);
@@ -1000,22 +1001,42 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 		skb->priority = TC_PRIO_CONTROL;
 		skb->dev = slave->dev;
 
+		rcu_read_lock();
 		if (bond_vlan_used(bond)) {
-			struct vlan_entry *vlan;
-
-			vlan = bond_next_vlan(bond,
-					      bond->alb_info.current_alb_vlan);
-
-			bond->alb_info.current_alb_vlan = vlan;
-			if (!vlan) {
+			/* first try to find the previously used vlan by
+			 * id, which might have gone away already
+			 */
+			vlan_id = bond->alb_info.current_alb_vlan;
+			vlan_dev = __vlan_find_dev_deep(bond->dev,
+							htons(ETH_P_8021Q),
+							vlan_id);
+
+			/* search for the next one, if not found - for any */
+			if (vlan_dev)
+				vlan_dev = __vlan_find_dev_next(bond->dev,
+								vlan_dev);
+			if (!vlan_dev)
+				vlan_dev = __vlan_find_dev_next(bond->dev,
+								NULL);
+
+			if (vlan_dev) {
+				vlan_id = vlan_dev_vlan_id(vlan_dev);
+				bond->alb_info.current_alb_vlan = vlan_id;
+			} else {
+				bond->alb_info.current_alb_vlan = 0;
+				rcu_read_unlock();
 				kfree_skb(skb);
 				continue;
 			}
+		} else
+			vlan_id = 0;
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
@@ -1759,8 +1780,8 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
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
