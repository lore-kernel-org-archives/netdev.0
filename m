From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [RFC PATCH 1/2] bonding: generic netlink infrastructure
Date: Mon, 13 Dec 2010 14:07:34 -0800
Message-ID: <1292278055-2842-2-git-send-email-fubar@us.ibm.com>
References: <1292278055-2842-1-git-send-email-fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:48528 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757850Ab0LMWHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 17:07:46 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBDLs0bL030626
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:54:00 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBDM7hIU175750
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:07:43 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBDM7geG022688
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:07:42 -0700
In-Reply-To: <1292278055-2842-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Generic netlink infrastructure for bonding.  Includes two
netlink operations: notification for slave link state change, and a
"get mode" netlink command.
---
 drivers/net/bonding/Makefile    |    2 +-
 drivers/net/bonding/bond_main.c |   39 +++++++++++++++++----------------------
 drivers/net/bonding/bonding.h   |    1 +
 include/linux/if_bonding.h      |   23 +++++++++++++++++++++++
 4 files changed, 42 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 6f9c6fa..26848a2 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_BONDING) += bonding.o
 
-bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o
+bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_netlink.o
 
 ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
 bonding-objs += $(ipv6-y)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index bb33b3b..4d3a2c8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -83,6 +83,7 @@
 #include "bonding.h"
 #include "bond_3ad.h"
 #include "bond_alb.h"
+#include "bond_netlink.h"
 
 /*---------------------------- Module parameters ----------------------------*/
 
@@ -2417,6 +2418,8 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_UP);
 
+			bond_nl_link_change(bond, slave, BOND_LINK_UP);
+
 			if (!bond->curr_active_slave ||
 			    (slave == bond->primary_slave))
 				goto do_failover;
@@ -2444,6 +2447,8 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_DOWN);
 
+			bond_nl_link_change(bond, slave, BOND_LINK_DOWN);
+
 			if (slave == bond->curr_active_slave)
 				goto do_failover;
 
@@ -2865,6 +2870,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 						bond->dev->name,
 						slave->dev->name);
 				}
+				bond_nl_link_change(bond, slave, BOND_LINK_UP);
 			}
 		} else {
 			/* slave->link == BOND_LINK_UP */
@@ -2892,6 +2898,8 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 
 				if (slave == oldcurrent)
 					do_failover = 1;
+
+				bond_nl_link_change(bond, slave, BOND_LINK_DOWN);
 			}
 		}
 
@@ -3038,6 +3046,8 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 				pr_info("%s: link status definitely up for interface %s.\n",
 					bond->dev->name, slave->dev->name);
 
+				bond_nl_link_change(bond, slave, BOND_LINK_UP);
+
 				if (!bond->curr_active_slave ||
 				    (slave == bond->primary_slave))
 					goto do_failover;
@@ -3056,6 +3066,8 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 			pr_info("%s: link status definitely down for interface %s, disabling it\n",
 				bond->dev->name, slave->dev->name);
 
+			bond_nl_link_change(bond, slave, BOND_LINK_DOWN);
+
 			if (slave == bond->curr_active_slave) {
 				bond->current_arp_slave = NULL;
 				goto do_failover;
@@ -4683,7 +4695,7 @@ static void bond_destructor(struct net_device *bond_dev)
 	free_netdev(bond_dev);
 }
 
-static void bond_setup(struct net_device *bond_dev)
+void bond_setup(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
@@ -5191,24 +5203,6 @@ static int bond_init(struct net_device *bond_dev)
 	return 0;
 }
 
-static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
-{
-	if (tb[IFLA_ADDRESS]) {
-		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
-			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
-			return -EADDRNOTAVAIL;
-	}
-	return 0;
-}
-
-static struct rtnl_link_ops bond_link_ops __read_mostly = {
-	.kind		= "bond",
-	.priv_size	= sizeof(struct bonding),
-	.setup		= bond_setup,
-	.validate	= bond_validate,
-};
-
 /* Create a new bond based on the specified name and bonding parameters.
  * If name is NULL, obtain a suitable "bond%d" name for us.
  * Caller must NOT hold rtnl_lock; we need to release it here before we
@@ -5216,6 +5210,7 @@ static struct rtnl_link_ops bond_link_ops __read_mostly = {
  */
 int bond_create(struct net *net, const char *name)
 {
+	extern struct rtnl_link_ops bond_link_ops;
 	struct net_device *bond_dev;
 	int res;
 
@@ -5304,7 +5299,7 @@ static int __init bonding_init(void)
 	if (res)
 		goto out;
 
-	res = rtnl_link_register(&bond_link_ops);
+	res = bond_netlink_init();
 	if (res)
 		goto err_link;
 
@@ -5325,7 +5320,7 @@ static int __init bonding_init(void)
 out:
 	return res;
 err:
-	rtnl_link_unregister(&bond_link_ops);
+	bond_netlink_fini();
 err_link:
 	unregister_pernet_subsys(&bond_net_ops);
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -5343,7 +5338,7 @@ static void __exit bonding_exit(void)
 
 	bond_destroy_sysfs();
 
-	rtnl_link_unregister(&bond_link_ops);
+	bond_netlink_fini();
 	unregister_pernet_subsys(&bond_net_ops);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ad3ae46..db7bb06 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -380,6 +380,7 @@ void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
 void bond_unregister_arp(struct bonding *);
+extern void bond_setup(struct net_device *bond_dev);
 
 struct bond_net {
 	struct net *		net;	/* Associated network namespace */
diff --git a/include/linux/if_bonding.h b/include/linux/if_bonding.h
index a17edda..b03d832 100644
--- a/include/linux/if_bonding.h
+++ b/include/linux/if_bonding.h
@@ -114,6 +114,29 @@ struct ad_info {
 	__u8 partner_system[ETH_ALEN];
 };
 
+enum {
+	BOND_GENL_ATTR_UNSPEC = 0,
+	BOND_GENL_ATTR_MASTER_INDEX,
+	BOND_GENL_ATTR_SLAVE_INDEX,
+	BOND_GENL_ATTR_MODE,
+	BOND_GENL_ATTR_SLAVE_LINK,
+	__BOND_GENL_ATTR_MAX,
+};
+
+#define BOND_GENL_ATTR_MAX (__BOND_GENL_ATTR_MAX - 1)
+
+enum {
+	BOND_GENL_CMD_UNSPEC = 0,
+	BOND_GENL_CMD_GET_MODE,
+	BOND_GENL_SLAVE_LINK,
+	__BOND_GENL_MAX,
+};
+
+#define BOND_GENL_MAX (__BOND_GENL_MAX - 1)
+
+#define BOND_GENL_VERSION	1
+#define BOND_GENL_MC_GROUP	"bond_mc_group"
+
 #endif /* _LINUX_IF_BONDING_H */
 
 /*
-- 
1.6.0.2

