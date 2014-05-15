From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v3 net-next 9/9] bonding: replace SLAVE_IS_OK() with bond_slave_can_tx()
Date: Thu, 15 May 2014 21:39:59 +0200
Message-ID: <1400182799-22737-10-git-send-email-vfalico@gmail.com>
References: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54595 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755869AbaEOTos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 15:44:48 -0400
In-Reply-To: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They're verifying the same thing (except of IFF_UP, which is implied for
netif_running(), which is also a prerequisite).

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_3ad.c  |  4 ++--
 drivers/net/bonding/bond_alb.c  | 14 +++++++-------
 drivers/net/bonding/bond_main.c |  4 ++--
 drivers/net/bonding/bonding.h   |  9 ---------
 4 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 7997a1e..0dfeaf5 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2449,13 +2449,13 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 			continue;
 
 		if (slave_agg_no >= 0) {
-			if (!first_ok_slave && SLAVE_IS_OK(slave))
+			if (!first_ok_slave && bond_slave_can_tx(slave))
 				first_ok_slave = slave;
 			slave_agg_no--;
 			continue;
 		}
 
-		if (SLAVE_IS_OK(slave)) {
+		if (bond_slave_can_tx(slave)) {
 			bond_dev_queue_xmit(bond, skb, slave->dev);
 			goto out;
 		}
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index efacb0e..03e0bca 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -228,7 +228,7 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
 
 	/* Find the slave with the largest gap */
 	bond_for_each_slave_rcu(bond, slave, iter) {
-		if (SLAVE_IS_OK(slave)) {
+		if (bond_slave_can_tx(slave)) {
 			long long gap = compute_gap(slave);
 
 			if (max_gap < gap) {
@@ -383,7 +383,7 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
 	bool found = false;
 
 	bond_for_each_slave(bond, slave, iter) {
-		if (!SLAVE_IS_OK(slave))
+		if (!bond_slave_can_tx(slave))
 			continue;
 		if (!found) {
 			if (!before || before->speed < slave->speed)
@@ -416,7 +416,7 @@ static struct slave *__rlb_next_rx_slave(struct bonding *bond)
 	bool found = false;
 
 	bond_for_each_slave_rcu(bond, slave, iter) {
-		if (!SLAVE_IS_OK(slave))
+		if (!bond_slave_can_tx(slave))
 			continue;
 		if (!found) {
 			if (!before || before->speed < slave->speed)
@@ -1100,13 +1100,13 @@ static void alb_swap_mac_addr(struct slave *slave1, struct slave *slave2)
 static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
 				struct slave *slave2)
 {
-	int slaves_state_differ = (SLAVE_IS_OK(slave1) != SLAVE_IS_OK(slave2));
+	int slaves_state_differ = (bond_slave_can_tx(slave1) != bond_slave_can_tx(slave2));
 	struct slave *disabled_slave = NULL;
 
 	ASSERT_RTNL();
 
 	/* fasten the change in the switch */
-	if (SLAVE_IS_OK(slave1)) {
+	if (bond_slave_can_tx(slave1)) {
 		alb_send_learning_packets(slave1, slave1->dev->dev_addr);
 		if (bond->alb_info.rlb_enabled) {
 			/* inform the clients that the mac address
@@ -1118,7 +1118,7 @@ static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
 		disabled_slave = slave1;
 	}
 
-	if (SLAVE_IS_OK(slave2)) {
+	if (bond_slave_can_tx(slave2)) {
 		alb_send_learning_packets(slave2, slave2->dev->dev_addr);
 		if (bond->alb_info.rlb_enabled) {
 			/* inform the clients that the mac address
@@ -1360,7 +1360,7 @@ static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
 			bond_info->unbalanced_load += skb->len;
 	}
 
-	if (tx_slave && SLAVE_IS_OK(tx_slave)) {
+	if (tx_slave && bond_slave_can_tx(tx_slave)) {
 		if (tx_slave != rcu_dereference(bond->curr_active_slave)) {
 			ether_addr_copy(eth_data->h_source,
 					tx_slave->dev->dev_addr);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5a1e7b7..7123205 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3850,14 +3850,14 @@ static int bond_ethtool_get_settings(struct net_device *bond_dev,
 	ecmd->duplex = DUPLEX_UNKNOWN;
 	ecmd->port = PORT_OTHER;
 
-	/* Since SLAVE_IS_OK returns false for all inactive or down slaves, we
+	/* Since bond_slave_can_tx returns false for all inactive or down slaves, we
 	 * do not need to check mode.  Though link speed might not represent
 	 * the true receive or transmit bandwidth (not all modes are symmetric)
 	 * this is an accurate maximum.
 	 */
 	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, iter) {
-		if (SLAVE_IS_OK(slave)) {
+		if (bond_slave_can_tx(slave)) {
 			if (slave->speed != SPEED_UNKNOWN)
 				speed += slave->speed;
 			if (ecmd->duplex == DUPLEX_UNKNOWN &&
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 60ffd57..44334b3d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -41,15 +41,6 @@
 #define BOND_DEFAULT_MIIMON	100
 
 /*
- * Checks whether slave is ready for transmit.
- */
-#define SLAVE_IS_OK(slave)			        \
-		    (((slave)->dev->flags & IFF_UP)  && \
-		     netif_running((slave)->dev)     && \
-		     ((slave)->link == BOND_LINK_UP) && \
-		     bond_is_active_slave(slave))
-
-/*
  * Less bad way to call ioctl from within the kernel; this needs to be
  * done some other way to get the call out of interrupt context.
  * Needs "ioctl" variable to be supplied by calling context.
-- 
1.8.4
