From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v3 4/5] bonding: factor out slave id tx code and simplify xmit paths
Date: Thu,  1 Aug 2013 16:54:50 +0200
Message-ID: <1375368891-9979-5-git-send-email-nikolay@redhat.com>
References: <1375368891-9979-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44550 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755847Ab3HAO6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 10:58:34 -0400
In-Reply-To: <1375368891-9979-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@BlackWall.org>

I factored out the tx xmit code which relies on slave id in
bond_xmit_slave_id. It is global because later it can be used also in
3ad mode xmit. Unnecessary obvious comments are removed. Active-backup
mode is simplified because bond_dev_queue_xmit always consumes the skb.
bond_xmit_xor becomes one line because of bond_xmit_slave_id.
bond_for_each_slave_from is not used in bond_xmit_slave_id because later
when RCU is used we can avoid important race condition by using standard
rculist routines.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v3: no change
v2: no need to NULL slave in xmit_roundrobin

 drivers/net/bonding/bond_main.c | 118 +++++++++++++++++-----------------------
 drivers/net/bonding/bonding.h   |  10 ++++
 2 files changed, 61 insertions(+), 67 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5f9d2fa..196febb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3795,12 +3795,50 @@ unwind:
 	return res;
 }
 
+/**
+ * bond_xmit_slave_id - transmit skb through slave with slave_id
+ * @bond: bonding device that is transmitting
+ * @skb: buffer to transmit
+ * @slave_id: slave id up to slave_cnt-1 through which to transmit
+ *
+ * This function tries to transmit through slave with slave_id but in case
+ * it fails, it tries to find the first available slave for transmission.
+ * The skb is consumed in all cases, thus the function is void.
+ */
+void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
+{
+	struct slave *slave;
+	int i = slave_id;
+
+	/* Here we start from the slave with slave_id */
+	bond_for_each_slave(bond, slave) {
+		if (--i < 0) {
+			if (slave_can_tx(slave)) {
+				bond_dev_queue_xmit(bond, skb, slave->dev);
+				return;
+			}
+		}
+	}
+
+	/* Here we start from the first slave up to slave_id */
+	i = slave_id;
+	bond_for_each_slave(bond, slave) {
+		if (--i < 0)
+			break;
+		if (slave_can_tx(slave)) {
+			bond_dev_queue_xmit(bond, skb, slave->dev);
+			return;
+		}
+	}
+	/* no slave that can tx has been found */
+	kfree_skb(skb);
+}
+
 static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave, *start_at;
-	int i, slave_no, res = 1;
 	struct iphdr *iph = ip_hdr(skb);
+	struct slave *slave;
 
 	/*
 	 * Start with the curr_active_slave that joined the bond as the
@@ -3809,46 +3847,20 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 	 * send the join/membership reports.  The curr_active_slave found
 	 * will send all of this type of traffic.
 	 */
-	if ((iph->protocol == IPPROTO_IGMP) &&
-	    (skb->protocol == htons(ETH_P_IP))) {
+	if (iph->protocol == IPPROTO_IGMP && skb->protocol == htons(ETH_P_IP)) {
 		slave = bond->curr_active_slave;
-		if (!slave)
-			goto out;
+		if (slave && slave_can_tx(slave))
+			bond_dev_queue_xmit(bond, skb, slave->dev);
+		else
+			bond_xmit_slave_id(bond, skb, 0);
 	} else {
-		/*
-		 * Concurrent TX may collide on rr_tx_counter; we accept
-		 * that as being rare enough not to justify using an
-		 * atomic op here.
-		 */
-		slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
-
-		bond_for_each_slave(bond, slave) {
-			slave_no--;
-			if (slave_no < 0)
-				break;
-		}
-	}
-
-	start_at = slave;
-	bond_for_each_slave_from(bond, slave, i, start_at) {
-		if (IS_UP(slave->dev) &&
-		    (slave->link == BOND_LINK_UP) &&
-		    bond_is_active_slave(slave)) {
-			res = bond_dev_queue_xmit(bond, skb, slave->dev);
-			break;
-		}
-	}
-
-out:
-	if (res) {
-		/* no suitable interface, frame not sent */
-		kfree_skb(skb);
+		bond_xmit_slave_id(bond, skb,
+				   bond->rr_tx_counter++ % bond->slave_cnt);
 	}
 
 	return NETDEV_TX_OK;
 }
 
-
 /*
  * in active-backup mode, we know that bond->curr_active_slave is always valid if
  * the bond has a usable interface.
@@ -3857,14 +3869,11 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
-	int res = 1;
 
 	slave = bond->curr_active_slave;
 	if (slave)
-		res = bond_dev_queue_xmit(bond, skb, slave->dev);
-
-	if (res)
-		/* no suitable interface, frame not sent */
+		bond_dev_queue_xmit(bond, skb, slave->dev);
+	else
 		kfree_skb(skb);
 
 	return NETDEV_TX_OK;
@@ -3878,34 +3887,9 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave, *start_at;
-	int slave_no;
-	int i;
-	int res = 1;
-
-	slave_no = bond->xmit_hash_policy(skb, bond->slave_cnt);
-
-	bond_for_each_slave(bond, slave) {
-		slave_no--;
-		if (slave_no < 0)
-			break;
-	}
-
-	start_at = slave;
 
-	bond_for_each_slave_from(bond, slave, i, start_at) {
-		if (IS_UP(slave->dev) &&
-		    (slave->link == BOND_LINK_UP) &&
-		    bond_is_active_slave(slave)) {
-			res = bond_dev_queue_xmit(bond, skb, slave->dev);
-			break;
-		}
-	}
-
-	if (res) {
-		/* no suitable interface, frame not sent */
-		kfree_skb(skb);
-	}
+	bond_xmit_slave_id(bond, skb,
+			   bond->xmit_hash_policy(skb, bond->slave_cnt));
 
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index cfd9b49..0995974 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -426,10 +426,20 @@ static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be3
 	return addr;
 }
 
+static inline bool slave_can_tx(struct slave *slave)
+{
+	if (IS_UP(slave->dev) && slave->link == BOND_LINK_UP &&
+	    bond_is_active_slave(slave))
+		return true;
+	else
+		return false;
+}
+
 struct bond_net;
 
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
+void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id);
 int bond_create(struct net *net, const char *name);
 int bond_create_sysfs(struct bond_net *net);
 void bond_destroy_sysfs(struct bond_net *net);
-- 
1.8.1.4
