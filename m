From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v3 net-next 7/9] bonding: convert IS_UP(slave->dev) to inline function
Date: Thu, 15 May 2014 21:39:57 +0200
Message-ID: <1400182799-22737-8-git-send-email-vfalico@gmail.com>
References: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754949AbaEOToo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 15:44:44 -0400
In-Reply-To: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, remove the IFF_UP verification cause we can't be netif_running() with
being also IFF_UP.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_3ad.c     |  2 +-
 drivers/net/bonding/bond_main.c    | 16 ++++++++--------
 drivers/net/bonding/bond_options.c |  2 +-
 drivers/net/bonding/bonding.h      | 12 ++++++------
 4 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 24faddd..7997a1e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -192,7 +192,7 @@ static inline void __enable_port(struct port *port)
 {
 	struct slave *slave = port->slave;
 
-	if ((slave->link == BOND_LINK_UP) && IS_UP(slave->dev))
+	if ((slave->link == BOND_LINK_UP) && bond_slave_is_up(slave))
 		bond_set_slave_active_flags(slave, BOND_SLAVE_NOTIFY_LATER);
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1af2be5..db323e6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -747,7 +747,7 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
 	bond_for_each_slave(bond, slave, iter) {
 		if (slave->link == BOND_LINK_UP)
 			return slave;
-		if (slave->link == BOND_LINK_BACK && IS_UP(slave->dev) &&
+		if (slave->link == BOND_LINK_BACK && bond_slave_is_up(slave) &&
 		    slave->delay < mintime) {
 			mintime = slave->delay;
 			bestslave = slave;
@@ -958,7 +958,7 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
 	struct slave *slave;
 
 	bond_for_each_slave(bond, slave, iter)
-		if (IS_UP(slave->dev))
+		if (bond_slave_is_up(slave))
 			slave_disable_netpoll(slave);
 }
 
@@ -2490,7 +2490,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 		 * do - all replies will be rx'ed on same link causing slaves
 		 * to be unstable during low/no traffic periods
 		 */
-		if (IS_UP(slave->dev))
+		if (bond_slave_is_up(slave))
 			bond_arp_send_all(bond, slave);
 	}
 
@@ -2712,10 +2712,10 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 	bond_set_slave_inactive_flags(curr_arp_slave, BOND_SLAVE_NOTIFY_LATER);
 
 	bond_for_each_slave_rcu(bond, slave, iter) {
-		if (!found && !before && IS_UP(slave->dev))
+		if (!found && !before && bond_slave_is_up(slave))
 			before = slave;
 
-		if (found && !new_slave && IS_UP(slave->dev))
+		if (found && !new_slave && bond_slave_is_up(slave))
 			new_slave = slave;
 		/* if the link state is up at this point, we
 		 * mark it down - this can happen if we have
@@ -2724,7 +2724,7 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 		 * one the current slave so it is still marked
 		 * up when it is actually down
 		 */
-		if (!IS_UP(slave->dev) && slave->link == BOND_LINK_UP) {
+		if (!bond_slave_is_up(slave) && slave->link == BOND_LINK_UP) {
 			slave->link = BOND_LINK_DOWN;
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
@@ -3710,7 +3710,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (bond_is_last_slave(bond, slave))
 			break;
-		if (IS_UP(slave->dev) && slave->link == BOND_LINK_UP) {
+		if (bond_slave_is_up(slave) && slave->link == BOND_LINK_UP) {
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
 			if (!skb2) {
@@ -3722,7 +3722,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 			bond_dev_queue_xmit(bond, skb2, slave->dev);
 		}
 	}
-	if (slave && IS_UP(slave->dev) && slave->link == BOND_LINK_UP)
+	if (slave && bond_slave_is_up(slave) && slave->link == BOND_LINK_UP)
 		bond_dev_queue_xmit(bond, skb, slave->dev);
 	else
 		dev_kfree_skb_any(skb);
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 0cf4c1a..94094b3 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -758,7 +758,7 @@ static int bond_option_active_slave_set(struct bonding *bond,
 				bond->dev->name, new_active->dev->name);
 		} else {
 			if (old_active && (new_active->link == BOND_LINK_UP) &&
-			    IS_UP(new_active->dev)) {
+			    bond_slave_is_up(new_active)) {
 				pr_info("%s: Setting %s as active slave\n",
 					bond->dev->name, new_active->dev->name);
 				bond_change_active_slave(bond, new_active);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ac75b0f..6a5393b 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -40,11 +40,6 @@
 
 #define BOND_DEFAULT_MIIMON	100
 
-#define IS_UP(dev)					   \
-	      ((((dev)->flags & IFF_UP) == IFF_UP)	&& \
-	       netif_running(dev)			&& \
-	       netif_carrier_ok(dev))
-
 /*
  * Checks whether slave is ready for transmit.
  */
@@ -297,6 +292,11 @@ static inline bool bond_uses_primary(struct bonding *bond)
 	return bond_mode_uses_primary(BOND_MODE(bond));
 }
 
+static inline bool bond_slave_is_up(struct slave *slave)
+{
+	return netif_running(slave->dev) && netif_carrier_ok(slave->dev);
+}
+
 static inline void bond_set_active_slave(struct slave *slave)
 {
 	if (slave->backup) {
@@ -487,7 +487,7 @@ static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be3
 
 static inline bool slave_can_tx(struct slave *slave)
 {
-	if (IS_UP(slave->dev) && slave->link == BOND_LINK_UP &&
+	if (bond_slave_is_up(slave) && slave->link == BOND_LINK_UP &&
 	    bond_is_active_slave(slave))
 		return true;
 	else
-- 
1.8.4
