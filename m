From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 3/5] bonding: simplify broadcast_xmit function
Date: Thu,  1 Aug 2013 14:10:27 +0200
Message-ID: <1375359029-25889-4-git-send-email-nikolay@redhat.com>
References: <1375359029-25889-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, davem@davemloft.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26857 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753884Ab3HAMOy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 08:14:54 -0400
In-Reply-To: <1375359029-25889-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@BlackWall.org>

We don't need to start from the curr_active_slave as the frame will be
sent to all eligible slaves anyway, so we remove the unnecessary local
variables, checks and comments, and make it use the standard list API.
This has the nice side-effect that later when it's converted to RCU
a race condition will be avoided which could lead to double packet tx.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 52 +++++++++++++----------------------------
 1 file changed, 16 insertions(+), 36 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9bdc701..5f9d2fa 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3910,52 +3910,32 @@ static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
 	return NETDEV_TX_OK;
 }
 
-/*
- * in broadcast mode, we send everything to all usable interfaces.
- */
+/* in broadcast mode, we send everything to all usable interfaces. */
 static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave, *start_at;
-	struct net_device *tx_dev = NULL;
-	int i;
-	int res = 1;
-
-	start_at = bond->curr_active_slave;
-	if (!start_at)
-		goto out;
+	struct slave *slave = NULL;
 
-	bond_for_each_slave_from(bond, slave, i, start_at) {
-		if (IS_UP(slave->dev) &&
-		    (slave->link == BOND_LINK_UP) &&
-		    bond_is_active_slave(slave)) {
-			if (tx_dev) {
-				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
-				if (!skb2) {
-					pr_err("%s: Error: bond_xmit_broadcast(): skb_clone() failed\n",
-					       bond_dev->name);
-					continue;
-				}
+	bond_for_each_slave(bond, slave) {
+		if (bond_is_last_slave(bond, slave))
+			break;
+		if (IS_UP(slave->dev) && slave->link == BOND_LINK_UP) {
+			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
-				res = bond_dev_queue_xmit(bond, skb2, tx_dev);
-				if (res) {
-					kfree_skb(skb2);
-					continue;
-				}
+			if (!skb2) {
+				pr_err("%s: Error: bond_xmit_broadcast(): skb_clone() failed\n",
+				       bond_dev->name);
+				continue;
 			}
-			tx_dev = slave->dev;
+			/* bond_dev_queue_xmit always returns 0 */
+			bond_dev_queue_xmit(bond, skb2, slave->dev);
 		}
 	}
-
-	if (tx_dev)
-		res = bond_dev_queue_xmit(bond, skb, tx_dev);
-
-out:
-	if (res)
-		/* no suitable interface, frame not sent */
+	if (slave && IS_UP(slave->dev) && slave->link == BOND_LINK_UP)
+		bond_dev_queue_xmit(bond, skb, slave->dev);
+	else
 		kfree_skb(skb);
 
-	/* frame sent to all suitable interfaces */
 	return NETDEV_TX_OK;
 }
 
-- 
1.8.1.4
