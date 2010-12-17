From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH RFC v3 1/2] bonding: generic netlink infrastructure
Date: Thu, 16 Dec 2010 17:35:25 -0800
Message-ID: <1292549726-15957-2-git-send-email-fubar@us.ibm.com>
References: <1292549726-15957-1-git-send-email-fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:39592 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab0LQBfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 20:35:38 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBH1MxmX021199
	for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 18:22:59 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBH1ZXdW147858
	for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 18:35:33 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBH1ZWkr028947
	for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 18:35:32 -0700
In-Reply-To: <1292549726-15957-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generic netlink infrastructure for bonding.  Includes two
netlink operations: notification for slave link state change, and a
"get mode" netlink command.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/Makefile       |    3 +-
 drivers/net/bonding/bond_main.c    |   41 +++----
 drivers/net/bonding/bond_netlink.c |  212 ++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_netlink.h |    6 +
 drivers/net/bonding/bonding.h      |    1 +
 include/linux/if_bonding.h         |   23 ++++
 6 files changed, 262 insertions(+), 24 deletions(-)
 create mode 100644 drivers/net/bonding/bond_netlink.c
 create mode 100644 drivers/net/bonding/bond_netlink.h

diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 0e2737e..b5fba40 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -4,7 +4,8 @@
 
 obj-$(CONFIG_BONDING) += bonding.o
 
-bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o
+bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o \
+	bond_netlink.o
 
 ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
 bonding-objs += $(ipv6-y)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 07011e4..ac1c2f0 100644
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
@@ -2892,6 +2898,9 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 
 				if (slave == oldcurrent)
 					do_failover = 1;
+
+				bond_nl_link_change(bond, slave,
+						    BOND_LINK_DOWN);
 			}
 		}
 
@@ -3038,6 +3047,8 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 				pr_info("%s: link status definitely up for interface %s.\n",
 					bond->dev->name, slave->dev->name);
 
+				bond_nl_link_change(bond, slave, BOND_LINK_UP);
+
 				if (!bond->curr_active_slave ||
 				    (slave == bond->primary_slave))
 					goto do_failover;
@@ -3056,6 +3067,8 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 			pr_info("%s: link status definitely down for interface %s, disabling it\n",
 				bond->dev->name, slave->dev->name);
 
+			bond_nl_link_change(bond, slave, BOND_LINK_DOWN);
+
 			if (slave == bond->curr_active_slave) {
 				bond->current_arp_slave = NULL;
 				goto do_failover;
@@ -4685,7 +4698,7 @@ static void bond_destructor(struct net_device *bond_dev)
 	free_netdev(bond_dev);
 }
 
-static void bond_setup(struct net_device *bond_dev)
+void bond_setup(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
@@ -5197,24 +5210,6 @@ static int bond_init(struct net_device *bond_dev)
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
@@ -5236,7 +5231,7 @@ int bond_create(struct net *net, const char *name)
 	}
 
 	dev_net_set(bond_dev, net);
-	bond_dev->rtnl_link_ops = &bond_link_ops;
+	bond_set_rtnl_link_ops(bond_dev);
 
 	if (!name) {
 		res = dev_alloc_name(bond_dev, "bond%d");
@@ -5310,7 +5305,7 @@ static int __init bonding_init(void)
 	if (res)
 		goto out;
 
-	res = rtnl_link_register(&bond_link_ops);
+	res = bond_netlink_init();
 	if (res)
 		goto err_link;
 
@@ -5332,7 +5327,7 @@ static int __init bonding_init(void)
 out:
 	return res;
 err:
-	rtnl_link_unregister(&bond_link_ops);
+	bond_netlink_fini();
 err_link:
 	unregister_pernet_subsys(&bond_net_ops);
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -5351,7 +5346,7 @@ static void __exit bonding_exit(void)
 	bond_destroy_sysfs();
 	bond_destroy_debugfs();
 
-	rtnl_link_unregister(&bond_link_ops);
+	bond_netlink_fini();
 	unregister_pernet_subsys(&bond_net_ops);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
new file mode 100644
index 0000000..b77c772
--- /dev/null
+++ b/drivers/net/bonding/bond_netlink.c
@@ -0,0 +1,212 @@
+/*
+ * Generic Netlink support for bonding
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
+ * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright IBM Corporation, 2010
+ *
+ * Author: Jay Vosburgh <fubar@us.ibm.com>
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <net/ip.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/if_bonding.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/genetlink.h>
+
+#include "bonding.h"
+
+int bond_nl_seq;
+
+struct genl_family bond_genl_family = {
+	.id = GENL_ID_GENERATE,
+	.name = "bond",
+	.version = BOND_GENL_VERSION,
+	.maxattr = BOND_GENL_ATTR_MAX,
+};
+
+struct genl_multicast_group bond_genl_mcgrp = {
+	.name = BOND_GENL_MC_GROUP,
+};
+
+static int bond_genl_validate(struct genl_info *info)
+{
+	switch (info->genlhdr->cmd) {
+	case BOND_GENL_CMD_GET_MODE:
+		if (!info->attrs[BOND_GENL_ATTR_MASTER_INDEX])
+			return -EINVAL;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/*
+ * Send netlink notification of slave link state change.
+ */
+int bond_nl_link_change(struct bonding *bond, struct slave *slave, int state)
+{
+	struct sk_buff *skb;
+	void *msg;
+	int rv;
+
+	skb = genlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+
+	msg = genlmsg_put(skb, 0, bond_nl_seq++, &bond_genl_family, 0,
+			  BOND_GENL_SLAVE_LINK);
+	if (!msg)
+		goto nla_put_failure;
+
+	NLA_PUT_U32(skb, BOND_GENL_ATTR_SLAVE_INDEX, slave->dev->ifindex);
+	NLA_PUT_U32(skb, BOND_GENL_ATTR_MASTER_INDEX, bond->dev->ifindex);
+	NLA_PUT_U32(skb, BOND_GENL_ATTR_SLAVE_LINK, state);
+
+	rv = genlmsg_end(skb, msg);
+	if (rv < 0)
+		goto nla_put_failure;
+
+	return genlmsg_multicast(skb, 0, bond_genl_mcgrp.id, GFP_ATOMIC);
+
+nla_put_failure:
+	nlmsg_free(skb);
+	return -EMSGSIZE;
+}
+
+static int bond_genl_get_mode(struct sk_buff *skb, struct genl_info *info)
+{
+	struct bonding *bond;
+	struct net_device *bond_dev;
+	struct sk_buff *rep_skb;
+	void *reply;
+	u32 m_idx, mode;
+	int rv;
+
+	rv = bond_genl_validate(info);
+	if (rv)
+		return rv;
+
+	m_idx = nla_get_u32(info->attrs[BOND_GENL_ATTR_MASTER_INDEX]);
+	bond_dev = dev_get_by_index(&init_net, m_idx);
+	if (!bond_dev || !(bond_dev->flags & IFF_MASTER) ||
+	    !(bond_dev->priv_flags & IFF_BONDING))
+		return -EINVAL;
+
+	bond = netdev_priv(bond_dev);
+	mode = bond->params.mode;
+
+	rep_skb = genlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!rep_skb)
+		return -ENOMEM;
+
+	reply = genlmsg_put_reply(rep_skb, info, &bond_genl_family, 0,
+				  info->genlhdr->cmd);
+	if (!reply)
+		goto nla_put_failure;
+
+	NLA_PUT_U32(rep_skb, BOND_GENL_ATTR_MODE, mode);
+
+	genlmsg_end(rep_skb, reply);
+
+	return genlmsg_reply(rep_skb, info);
+
+nla_put_failure:
+	nlmsg_free(rep_skb);
+	return -EMSGSIZE;
+}
+
+static struct nla_policy bond_genl_policy[BOND_GENL_ATTR_MAX + 1] = {
+	[BOND_GENL_ATTR_MASTER_INDEX] = { .type = NLA_U32 },
+	[BOND_GENL_ATTR_SLAVE_INDEX] = { .type = NLA_U32 },
+	[BOND_GENL_ATTR_MODE] = { .type = NLA_U32 },
+	[BOND_GENL_ATTR_SLAVE_LINK] = { .type = NLA_U32 },
+};
+
+static struct genl_ops bond_genl_ops[] = {
+	{
+		.cmd = BOND_GENL_CMD_GET_MODE,
+		.doit = bond_genl_get_mode,
+		.policy = bond_genl_policy,
+	},
+};
+
+static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+	return 0;
+}
+
+struct rtnl_link_ops bond_link_ops __read_mostly = {
+	.kind		= "bond",
+	.priv_size	= sizeof(struct bonding),
+	.setup		= bond_setup,
+	.validate	= bond_validate,
+};
+
+void bond_set_rtnl_link_ops(struct net_device *bond_dev)
+{
+	bond_dev->rtnl_link_ops = &bond_link_ops;
+}
+
+int __init bond_netlink_init(void)
+{
+	int rv;
+
+	rv = rtnl_link_register(&bond_link_ops);
+	if (rv)
+		goto out1;
+
+	rv = genl_register_family_with_ops(&bond_genl_family,
+					     bond_genl_ops,
+					     ARRAY_SIZE(bond_genl_ops));
+	if (rv)
+		goto out2;
+
+	rv = genl_register_mc_group(&bond_genl_family, &bond_genl_mcgrp);
+	if (rv)
+		goto out3;
+
+	return 0;
+
+out3:
+	genl_unregister_family(&bond_genl_family);
+out2:
+	rtnl_link_unregister(&bond_link_ops);
+out1:
+	return rv;
+}
+
+void __exit bond_netlink_fini(void)
+{
+	rtnl_link_unregister(&bond_link_ops);
+	genl_unregister_family(&bond_genl_family);
+}
diff --git a/drivers/net/bonding/bond_netlink.h b/drivers/net/bonding/bond_netlink.h
new file mode 100644
index 0000000..030c2af
--- /dev/null
+++ b/drivers/net/bonding/bond_netlink.h
@@ -0,0 +1,6 @@
+
+extern int bond_nl_link_change(struct bonding *bond, struct slave *slave,
+			       int state);
+extern void bond_set_rtnl_link_ops(struct net_device *bond_dev);
+extern int bond_netlink_init(void);
+extern void bond_netlink_fini(void);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 03710f8..ed09a79 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -389,6 +389,7 @@ void bond_destroy_debugfs(void);
 void bond_debug_register(struct bonding *bond);
 void bond_debug_unregister(struct bonding *bond);
 void bond_debug_reregister(struct bonding *bond);
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

