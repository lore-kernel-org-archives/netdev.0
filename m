From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bonding: drop_monitor aware
Date: Wed, 13 Jun 2012 17:30:07 +0200
Message-ID: <1339601407.22704.380.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53976 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453Ab2FMPaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 11:30:10 -0400
Received: by eeit10 with SMTP id t10so256084eei.19
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 08:30:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When packets are dropped in TX path, its better to use kfree_skb()
instead of dev_kfree_skb() to give proper drop_monitor events.

Also move the kfree_skb() call after read_unlock() in bond_alb_xmit()
and bond_xmit_activebackup()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_3ad.c  |    2 +-
 drivers/net/bonding/bond_alb.c  |    6 +++---
 drivers/net/bonding/bond_main.c |   18 +++++++++---------
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 3031e04..a030e63 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2454,7 +2454,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 out:
 	if (res) {
 		/* no suitable interface, frame not sent */
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 	}
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index ef3791a..e15cc11 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1346,12 +1346,12 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		}
 	}
 
+	read_unlock(&bond->curr_slave_lock);
+
 	if (res) {
 		/* no suitable interface, frame not sent */
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 	}
-	read_unlock(&bond->curr_slave_lock);
-
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index af50632..f5a40b9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3990,7 +3990,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 out:
 	if (res) {
 		/* no suitable interface, frame not sent */
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 	}
 
 	return NETDEV_TX_OK;
@@ -4012,11 +4012,11 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 		res = bond_dev_queue_xmit(bond, skb,
 			bond->curr_active_slave->dev);
 
+	read_unlock(&bond->curr_slave_lock);
+
 	if (res)
 		/* no suitable interface, frame not sent */
-		dev_kfree_skb(skb);
-
-	read_unlock(&bond->curr_slave_lock);
+		kfree_skb(skb);
 
 	return NETDEV_TX_OK;
 }
@@ -4055,7 +4055,7 @@ static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
 
 	if (res) {
 		/* no suitable interface, frame not sent */
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 	}
 
 	return NETDEV_TX_OK;
@@ -4093,7 +4093,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 
 				res = bond_dev_queue_xmit(bond, skb2, tx_dev);
 				if (res) {
-					dev_kfree_skb(skb2);
+					kfree_skb(skb2);
 					continue;
 				}
 			}
@@ -4107,7 +4107,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 out:
 	if (res)
 		/* no suitable interface, frame not sent */
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 
 	/* frame sent to all suitable interfaces */
 	return NETDEV_TX_OK;
@@ -4213,7 +4213,7 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 		pr_err("%s: Error: Unknown bonding mode %d\n",
 		       dev->name, bond->params.mode);
 		WARN_ON_ONCE(1);
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 }
@@ -4235,7 +4235,7 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (bond->slave_cnt)
 		ret = __bond_start_xmit(skb, dev);
 	else
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 
 	read_unlock(&bond->lock);
 
