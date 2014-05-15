From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v2 net-next 2/9] bonding: make TX_QUEUE_OVERRIDE() macro an inline function
Date: Thu, 15 May 2014 14:29:20 +0200
Message-ID: <1400156967-8231-3-git-send-email-vfalico@gmail.com>
References: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26481 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754218AbaEOMeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 08:34:13 -0400
In-Reply-To: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, make it accept bonding as a parameter and change the name a bit to
better reflect its scope.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_main.c |  7 +++----
 drivers/net/bonding/bonding.h   | 10 ++++++----
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 90ebed6..5c88c11 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3788,10 +3788,9 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 {
 	struct bonding *bond = netdev_priv(dev);
 
-	if (TX_QUEUE_OVERRIDE(bond->params.mode)) {
-		if (!bond_slave_override(bond, skb))
-			return NETDEV_TX_OK;
-	}
+	if (bond_should_override_tx_queue(bond) &&
+	    !bond_slave_override(bond, skb))
+		return NETDEV_TX_OK;
 
 	switch (bond->params.mode) {
 	case BOND_MODE_ROUNDROBIN:
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 16e57a1..dca3dfd 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -65,10 +65,6 @@
 		 ((mode) == BOND_MODE_TLB)	||	\
 		 ((mode) == BOND_MODE_ALB))
 
-#define TX_QUEUE_OVERRIDE(mode)				\
-			(((mode) == BOND_MODE_ACTIVEBACKUP) ||	\
-			 ((mode) == BOND_MODE_ROUNDROBIN))
-
 #define IS_IP_TARGET_UNUSABLE_ADDRESS(a)	\
 	((htonl(INADDR_BROADCAST) == a) ||	\
 	 ipv4_is_zeronet(a))
@@ -284,6 +280,12 @@ static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 	return slave->bond;
 }
 
+static inline bool bond_should_override_tx_queue(struct bonding *bond)
+{
+	return bond->params.mode == BOND_MODE_ACTIVEBACKUP ||
+	       bond->params.mode == BOND_MODE_ROUNDROBIN;
+}
+
 static inline bool bond_is_lb(const struct bonding *bond)
 {
 	return bond->params.mode == BOND_MODE_TLB ||
-- 
1.8.4
