From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH, RFC] bonding: prevent outgoing packets on inactive slaves
Date: Wed, 5 Aug 2009 18:24:29 +0200
Message-ID: <20090805162429.GD16093@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54423 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934321AbZHEQYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 12:24:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applications exist that broadcast/multicast packets on all
devices in the system (e.g. avahi-mdns).

When a device is an inactive slave of a bond in active-backup
mode, its MAC address may be set identical to other divecies in
the bond. The broadcast/multicast packets may then confuse
switches to direct packets to the inactive slave, rather than the
active one.

This patch makes sure the TX queues on inactive slaves are
deactivated.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -20,6 +20,7 @@
 #include <linux/if_bonding.h>
 #include <linux/kobject.h>
 #include <linux/in6.h>
+#include <net/sch_generic.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
@@ -291,12 +292,21 @@ static inline void bond_set_slave_inactive_flags(struct slave *slave)
 	slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
 	if (slave_do_arp_validate(bond, slave))
 		slave->dev->priv_flags |= IFF_SLAVE_NEEDARP;
+
+	/* prevent outgoing frames on inactive slaves from confusing switches */
+	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+		dev_deactivate_tx(slave->dev);
 }
 
 static inline void bond_set_slave_active_flags(struct slave *slave)
 {
+	struct bonding *bond = netdev_priv(slave->dev->master);
+
 	slave->state = BOND_STATE_ACTIVE;
 	slave->dev->priv_flags &= ~(IFF_SLAVE_INACTIVE | IFF_SLAVE_NEEDARP);
+
+	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+		dev_activate_tx(slave->dev);
 }
 
 static inline void bond_set_master_3ad_flags(struct bonding *bond)
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 964ffa0..eee006a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -296,6 +296,8 @@ extern void dev_init_scheduler(struct net_device *dev);
 extern void dev_shutdown(struct net_device *dev);
 extern void dev_activate(struct net_device *dev);
 extern void dev_deactivate(struct net_device *dev);
+extern void dev_activate_tx(struct net_device *dev);
+extern void dev_deactivate_tx(struct net_device *dev);
 extern void qdisc_reset(struct Qdisc *qdisc);
 extern void qdisc_destroy(struct Qdisc *qdisc);
 extern void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 27d0381..514c73d 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -628,7 +628,7 @@ static void transition_one_qdisc(struct net_device *dev,
 	}
 }
 
-void dev_activate(struct net_device *dev)
+void dev_activate_tx(struct net_device *dev)
 {
 	int need_watchdog;
 
@@ -647,13 +647,19 @@ void dev_activate(struct net_device *dev)
 
 	need_watchdog = 0;
 	netdev_for_each_tx_queue(dev, transition_one_qdisc, &need_watchdog);
-	transition_one_qdisc(dev, &dev->rx_queue, NULL);
 
 	if (need_watchdog) {
 		dev->trans_start = jiffies;
 		dev_watchdog_up(dev);
 	}
 }
+EXPORT_SYMBOL(dev_activate_tx);
+
+void dev_activate(struct net_device *dev)
+{
+	dev_activate_tx(dev);
+	transition_one_qdisc(dev, &dev->rx_queue, NULL);
+}
 
 static void dev_deactivate_queue(struct net_device *dev,
 				 struct netdev_queue *dev_queue,
@@ -703,12 +709,18 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 	return false;
 }
 
-void dev_deactivate(struct net_device *dev)
+void dev_deactivate_tx(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, dev_deactivate_queue, &noop_qdisc);
-	dev_deactivate_queue(dev, &dev->rx_queue, &noop_qdisc);
 
 	dev_watchdog_down(dev);
+}
+EXPORT_SYMBOL(dev_deactivate_tx);
+
+void dev_deactivate(struct net_device *dev)
+{
+	dev_deactivate_tx(dev);
+	dev_deactivate_queue(dev, &dev->rx_queue, &noop_qdisc);
 
 	/* Wait for outstanding qdisc-less dev_queue_xmit calls. */
 	synchronize_rcu();



-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

