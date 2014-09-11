From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 6/7] bonding: 3ad: convert to bond->mode_lock
Date: Thu, 11 Sep 2014 13:38:42 +0200
Message-ID: <1410435523-7520-7-git-send-email-nikolay@redhat.com>
References: <1410435523-7520-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44553 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754484AbaIKLjF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 07:39:05 -0400
In-Reply-To: <1410435523-7520-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have bond->mode_lock, we can remove the state_machine_lock
and use it in its place. There're no fast paths requiring the per-port
spinlocks so it should be okay to consolidate them into mode_lock.
Also move it inside the unbinding function as we don't want to expose
mode_lock outside of the specific modes.

Suggested-by: Jay Vosburgh <jay.vosburgh@canonical.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_3ad.c  | 62 +++++++++++++----------------------------
 drivers/net/bonding/bond_3ad.h  |  1 -
 drivers/net/bonding/bond_main.c |  8 +-----
 3 files changed, 20 insertions(+), 51 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 1b19f35689a4..38fa749bf83b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -234,24 +234,6 @@ static inline int __check_agg_selection_timer(struct port *port)
 }
 
 /**
- * __get_state_machine_lock - lock the port's state machines
- * @port: the port we're looking at
- */
-static inline void __get_state_machine_lock(struct port *port)
-{
-	spin_lock_bh(&(SLAVE_AD_INFO(port->slave)->state_machine_lock));
-}
-
-/**
- * __release_state_machine_lock - unlock the port's state machines
- * @port: the port we're looking at
- */
-static inline void __release_state_machine_lock(struct port *port)
-{
-	spin_unlock_bh(&(SLAVE_AD_INFO(port->slave)->state_machine_lock));
-}
-
-/**
  * __get_link_speed - get a port's speed
  * @port: the port we're looking at
  *
@@ -341,16 +323,6 @@ static u8 __get_duplex(struct port *port)
 	return retval;
 }
 
-/**
- * __initialize_port_locks - initialize a port's STATE machine spinlock
- * @port: the slave of the port we're looking at
- */
-static inline void __initialize_port_locks(struct slave *slave)
-{
-	/* make sure it isn't called twice */
-	spin_lock_init(&(SLAVE_AD_INFO(slave)->state_machine_lock));
-}
-
 /* Conversions */
 
 /**
@@ -1843,7 +1815,6 @@ void bond_3ad_bind_slave(struct slave *slave)
 
 		ad_initialize_port(port, bond->params.lacp_fast);
 
-		__initialize_port_locks(slave);
 		port->slave = slave;
 		port->actor_port_number = SLAVE_AD_INFO(slave)->id;
 		/* key is determined according to the link speed, duplex and user key(which
@@ -1899,6 +1870,8 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	struct slave *slave_iter;
 	struct list_head *iter;
 
+	/* Sync against bond_3ad_state_machine_handler() */
+	spin_lock_bh(&bond->mode_lock);
 	aggregator = &(SLAVE_AD_INFO(slave)->aggregator);
 	port = &(SLAVE_AD_INFO(slave)->port);
 
@@ -1906,7 +1879,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	if (!port->slave) {
 		netdev_warn(bond->dev, "Trying to unbind an uninitialized port on %s\n",
 			    slave->dev->name);
-		return;
+		goto out;
 	}
 
 	netdev_dbg(bond->dev, "Unbinding Link Aggregation Group %d\n",
@@ -2032,6 +2005,9 @@ void bond_3ad_unbind_slave(struct slave *slave)
 		}
 	}
 	port->slave = NULL;
+
+out:
+	spin_unlock_bh(&bond->mode_lock);
 }
 
 /**
@@ -2098,7 +2074,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		 * by all (e.g., port->sm_vars).  ad_rx_machine may run
 		 * concurrently due to incoming LACPDU.
 		 */
-		__get_state_machine_lock(port);
+		spin_lock_bh(&bond->mode_lock);
 
 		ad_rx_machine(NULL, port);
 		ad_periodic_machine(port);
@@ -2110,7 +2086,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		if (port->sm_vars & AD_PORT_BEGIN)
 			port->sm_vars &= ~AD_PORT_BEGIN;
 
-		__release_state_machine_lock(port);
+		spin_unlock_bh(&bond->mode_lock);
 	}
 
 re_arm:
@@ -2161,9 +2137,9 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
 			netdev_dbg(slave->bond->dev, "Received LACPDU on port %d\n",
 				   port->actor_port_number);
 			/* Protect against concurrent state machines */
-			__get_state_machine_lock(port);
+			spin_lock(&slave->bond->mode_lock);
 			ad_rx_machine(lacpdu, port);
-			__release_state_machine_lock(port);
+			spin_unlock(&slave->bond->mode_lock);
 			break;
 
 		case AD_TYPE_MARKER:
@@ -2213,7 +2189,7 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 		return;
 	}
 
-	__get_state_machine_lock(port);
+	spin_lock_bh(&slave->bond->mode_lock);
 
 	port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS;
 	port->actor_oper_port_key = port->actor_admin_port_key |=
@@ -2224,7 +2200,7 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 	 */
 	port->sm_vars |= AD_PORT_BEGIN;
 
-	__release_state_machine_lock(port);
+	spin_unlock_bh(&slave->bond->mode_lock);
 }
 
 /**
@@ -2246,7 +2222,7 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 		return;
 	}
 
-	__get_state_machine_lock(port);
+	spin_lock_bh(&slave->bond->mode_lock);
 
 	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
 	port->actor_oper_port_key = port->actor_admin_port_key |=
@@ -2257,7 +2233,7 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 	 */
 	port->sm_vars |= AD_PORT_BEGIN;
 
-	__release_state_machine_lock(port);
+	spin_unlock_bh(&slave->bond->mode_lock);
 }
 
 /**
@@ -2280,7 +2256,7 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 		return;
 	}
 
-	__get_state_machine_lock(port);
+	spin_lock_bh(&slave->bond->mode_lock);
 	/* on link down we are zeroing duplex and speed since
 	 * some of the adaptors(ce1000.lan) report full duplex/speed
 	 * instead of N/A(duplex) / 0(speed).
@@ -2311,7 +2287,7 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 	 */
 	port->sm_vars |= AD_PORT_BEGIN;
 
-	__release_state_machine_lock(port);
+	spin_unlock_bh(&slave->bond->mode_lock);
 }
 
 /**
@@ -2495,7 +2471,7 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
  * When modify lacp_rate parameter via sysfs,
  * update actor_oper_port_state of each port.
  *
- * Hold slave->state_machine_lock,
+ * Hold bond->mode_lock,
  * so we can modify port->actor_oper_port_state,
  * no matter bond is up or down.
  */
@@ -2509,11 +2485,11 @@ void bond_3ad_update_lacp_rate(struct bonding *bond)
 	lacp_fast = bond->params.lacp_fast;
 	bond_for_each_slave(bond, slave, iter) {
 		port = &(SLAVE_AD_INFO(slave)->port);
-		__get_state_machine_lock(port);
+		spin_lock_bh(&bond->mode_lock);
 		if (lacp_fast)
 			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
 		else
 			port->actor_oper_port_state &= ~AD_STATE_LACP_TIMEOUT;
-		__release_state_machine_lock(port);
+		spin_unlock_bh(&bond->mode_lock);
 	}
 }
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index bb03b1df2f3e..c5f14ac63f3e 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -259,7 +259,6 @@ struct ad_bond_info {
 struct ad_slave_info {
 	struct aggregator aggregator;	/* 802.3ad aggregator structure */
 	struct port port;		/* 802.3ad port structure */
-	spinlock_t state_machine_lock;	/* mutex state machines vs. incoming LACPDU */
 	u16 id;
 };
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e06251417a7d..116cf6965bc5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1675,14 +1675,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 	 */
 	netdev_rx_handler_unregister(slave_dev);
 
-	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
-		/* Sync against bond_3ad_rx_indication and
-		 * bond_3ad_state_machine_handler
-		 */
-		spin_lock_bh(&bond->mode_lock);
+	if (BOND_MODE(bond) == BOND_MODE_8023AD)
 		bond_3ad_unbind_slave(slave);
-		spin_unlock_bh(&bond->mode_lock);
-	}
 
 	netdev_info(bond_dev, "Releasing %s interface %s\n",
 		    bond_is_active_slave(slave) ? "active" : "backup",
-- 
1.9.3
