From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v3 net-next 8/9] bonding: rename {,bond_}slave_can_tx and clean it up
Date: Thu, 15 May 2014 21:39:58 +0200
Message-ID: <1400182799-22737-9-git-send-email-vfalico@gmail.com>
References: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15170 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755869AbaEOToq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 15:44:46 -0400
In-Reply-To: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_main.c |  8 ++++----
 drivers/net/bonding/bonding.h   | 15 ++++++---------
 2 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index db323e6..5a1e7b7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3588,7 +3588,7 @@ static void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int sl
 	/* Here we start from the slave with slave_id */
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (--i < 0) {
-			if (slave_can_tx(slave)) {
+			if (bond_slave_can_tx(slave)) {
 				bond_dev_queue_xmit(bond, skb, slave->dev);
 				return;
 			}
@@ -3600,7 +3600,7 @@ static void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int sl
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (--i < 0)
 			break;
-		if (slave_can_tx(slave)) {
+		if (bond_slave_can_tx(slave)) {
 			bond_dev_queue_xmit(bond, skb, slave->dev);
 			return;
 		}
@@ -3657,7 +3657,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 	 */
 	if (iph->protocol == IPPROTO_IGMP && skb->protocol == htons(ETH_P_IP)) {
 		slave = rcu_dereference(bond->curr_active_slave);
-		if (slave && slave_can_tx(slave))
+		if (slave && bond_slave_can_tx(slave))
 			bond_dev_queue_xmit(bond, skb, slave->dev);
 		else
 			bond_xmit_slave_id(bond, skb, 0);
@@ -3747,7 +3747,7 @@ static inline int bond_slave_override(struct bonding *bond,
 	/* Find out if any slaves have the same mapping as this skb. */
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (slave->queue_id == skb->queue_mapping) {
-			if (slave_can_tx(slave)) {
+			if (bond_slave_can_tx(slave)) {
 				bond_dev_queue_xmit(bond, skb, slave->dev);
 				return 0;
 			}
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6a5393b..60ffd57 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -367,6 +367,12 @@ static inline bool bond_is_active_slave(struct slave *slave)
 	return !bond_slave_state(slave);
 }
 
+static inline bool bond_slave_can_tx(struct slave *slave)
+{
+	return bond_slave_is_up(slave) && slave->link == BOND_LINK_UP &&
+	       bond_is_active_slave(slave);
+}
+
 #define BOND_PRI_RESELECT_ALWAYS	0
 #define BOND_PRI_RESELECT_BETTER	1
 #define BOND_PRI_RESELECT_FAILURE	2
@@ -485,15 +491,6 @@ static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be3
 	return addr;
 }
 
-static inline bool slave_can_tx(struct slave *slave)
-{
-	if (bond_slave_is_up(slave) && slave->link == BOND_LINK_UP &&
-	    bond_is_active_slave(slave))
-		return true;
-	else
-		return false;
-}
-
 struct bond_net {
 	struct net		*net;	/* Associated network namespace */
 	struct list_head	dev_list;
-- 
1.8.4
