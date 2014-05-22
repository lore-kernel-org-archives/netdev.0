From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 1/2] bonding: remove rlb_enabled and use mode == ALB instead
Date: Thu, 22 May 2014 15:12:03 +0200
Message-ID: <1400764324-23221-2-git-send-email-vfalico@gmail.com>
References: <1400764324-23221-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753895AbaEVNQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 09:16:35 -0400
In-Reply-To: <1400764324-23221-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently rlb_enabled is set only when bonding mode is ALB, and 0
otherwise, so just use the mode == ALB verification instead of maintaining
additional variable.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_alb.c  | 36 +++++++++++++++---------------------
 drivers/net/bonding/bond_alb.h  |  3 +--
 drivers/net/bonding/bond_main.c |  2 +-
 3 files changed, 17 insertions(+), 24 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 03e0bca..965518b 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1108,7 +1108,7 @@ static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
 	/* fasten the change in the switch */
 	if (bond_slave_can_tx(slave1)) {
 		alb_send_learning_packets(slave1, slave1->dev->dev_addr);
-		if (bond->alb_info.rlb_enabled) {
+		if (BOND_MODE(bond) == BOND_MODE_ALB) {
 			/* inform the clients that the mac address
 			 * has changed
 			 */
@@ -1120,7 +1120,7 @@ static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
 
 	if (bond_slave_can_tx(slave2)) {
 		alb_send_learning_packets(slave2, slave2->dev->dev_addr);
-		if (bond->alb_info.rlb_enabled) {
+		if (BOND_MODE(bond) == BOND_MODE_ALB) {
 			/* inform the clients that the mac address
 			 * has changed
 			 */
@@ -1130,7 +1130,7 @@ static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
 		disabled_slave = slave2;
 	}
 
-	if (bond->alb_info.rlb_enabled && slaves_state_differ) {
+	if (BOND_MODE(bond) == BOND_MODE_ALB && slaves_state_differ) {
 		/* A disabled slave was assigned an active mac addr */
 		rlb_teach_disabled_mac_on_primary(bond,
 						  disabled_slave->dev->dev_addr);
@@ -1278,7 +1278,7 @@ static int alb_set_mac_address(struct bonding *bond, void *addr)
 	char tmp_addr[ETH_ALEN];
 	int res;
 
-	if (bond->alb_info.rlb_enabled)
+	if (BOND_MODE(bond) == BOND_MODE_ALB)
 		return 0;
 
 	bond_for_each_slave(bond, slave, iter) {
@@ -1314,7 +1314,7 @@ unwind:
 
 /************************ exported alb funcions ************************/
 
-int bond_alb_initialize(struct bonding *bond, int rlb_enabled)
+int bond_alb_initialize(struct bonding *bond)
 {
 	int res;
 
@@ -1322,16 +1322,13 @@ int bond_alb_initialize(struct bonding *bond, int rlb_enabled)
 	if (res)
 		return res;
 
-	if (rlb_enabled) {
-		bond->alb_info.rlb_enabled = 1;
+	if (BOND_MODE(bond) == BOND_MODE_ALB) {
 		/* initialize rlb */
 		res = rlb_initialize(bond);
 		if (res) {
 			tlb_deinitialize(bond);
 			return res;
 		}
-	} else {
-		bond->alb_info.rlb_enabled = 0;
 	}
 
 	return 0;
@@ -1339,11 +1336,9 @@ int bond_alb_initialize(struct bonding *bond, int rlb_enabled)
 
 void bond_alb_deinitialize(struct bonding *bond)
 {
-	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-
 	tlb_deinitialize(bond);
 
-	if (bond_info->rlb_enabled)
+	if (BOND_MODE(bond) == BOND_MODE_ALB)
 		rlb_deinitialize(bond);
 }
 
@@ -1422,7 +1417,6 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct ethhdr *eth_data;
-	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct slave *tx_slave = NULL;
 	static const __be32 ip_bcast = htonl(0xffffffff);
 	int hash_size = 0;
@@ -1499,7 +1493,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		break;
 	case ETH_P_ARP:
 		do_tx_balance = false;
-		if (bond_info->rlb_enabled)
+		if (BOND_MODE(bond) == BOND_MODE_ALB)
 			tx_slave = rlb_arp_xmit(skb, bond);
 		break;
 	default:
@@ -1572,7 +1566,7 @@ void bond_alb_monitor(struct work_struct *work)
 	}
 
 	/* handle rlb stuff */
-	if (bond_info->rlb_enabled) {
+	if (BOND_MODE(bond) == BOND_MODE_ALB) {
 		if (bond_info->primary_is_promisc &&
 		    (++bond_info->rlb_promisc_timeout_counter >= RLB_PROMISC_TIMEOUT)) {
 
@@ -1640,7 +1634,7 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 	/* order a rebalance ASAP */
 	bond->alb_info.tx_rebalance_counter = BOND_TLB_REBALANCE_TICKS;
 
-	if (bond->alb_info.rlb_enabled)
+	if (BOND_MODE(bond) == BOND_MODE_ALB)
 		bond->alb_info.rlb_rebalance = 1;
 
 	return 0;
@@ -1659,7 +1653,7 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
 
 	tlb_clear_slave(bond, slave, 0);
 
-	if (bond->alb_info.rlb_enabled) {
+	if (BOND_MODE(bond) == BOND_MODE_ALB) {
 		bond->alb_info.rx_slave = NULL;
 		rlb_clear_slave(bond, slave);
 	}
@@ -1672,12 +1666,12 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
 
 	if (link == BOND_LINK_DOWN) {
 		tlb_clear_slave(bond, slave, 0);
-		if (bond->alb_info.rlb_enabled)
+		if (BOND_MODE(bond) == BOND_MODE_ALB)
 			rlb_clear_slave(bond, slave);
 	} else if (link == BOND_LINK_UP) {
 		/* order a rebalance ASAP */
 		bond_info->tx_rebalance_counter = BOND_TLB_REBALANCE_TICKS;
-		if (bond->alb_info.rlb_enabled) {
+		if (BOND_MODE(bond) == BOND_MODE_ALB) {
 			bond->alb_info.rlb_rebalance = 1;
 			/* If the updelay module parameter is smaller than the
 			 * forwarding delay of the switch the rebalance will
@@ -1811,7 +1805,7 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 
 		read_lock(&bond->lock);
 		alb_send_learning_packets(bond->curr_active_slave, bond_dev->dev_addr);
-		if (bond->alb_info.rlb_enabled) {
+		if (BOND_MODE(bond) == BOND_MODE_ALB) {
 			/* inform clients mac address has changed */
 			rlb_req_update_slave_clients(bond, bond->curr_active_slave);
 		}
@@ -1823,7 +1817,7 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 {
-	if (bond->alb_info.rlb_enabled)
+	if (BOND_MODE(bond) == BOND_MODE_ALB)
 		rlb_clear_vlan(bond, vlan_id);
 }
 
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 5fc76c0..fee7a26 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -146,7 +146,6 @@ struct alb_bond_info {
 	int			tx_rebalance_counter;
 	int			lp_counter;
 	/* -------- rlb parameters -------- */
-	int rlb_enabled;
 	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
 	spinlock_t		rx_hashtbl_lock;
 	u32			rx_hashtbl_used_head;
@@ -168,7 +167,7 @@ struct alb_bond_info {
 						 */
 };
 
-int bond_alb_initialize(struct bonding *bond, int rlb_enabled);
+int bond_alb_initialize(struct bonding *bond);
 void bond_alb_deinitialize(struct bonding *bond);
 int bond_alb_init_slave(struct bonding *bond, struct slave *slave);
 void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7123205..1c7ae78 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3124,7 +3124,7 @@ static int bond_open(struct net_device *bond_dev)
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
 		 */
-		if (bond_alb_initialize(bond, (BOND_MODE(bond) == BOND_MODE_ALB)))
+		if (bond_alb_initialize(bond))
 			return -ENOMEM;
 		if (bond->params.tlb_dynamic_lb)
 			queue_delayed_work(bond->wq, &bond->alb_work, 0);
-- 
1.8.4
