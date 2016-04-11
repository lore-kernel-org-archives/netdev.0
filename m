From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next WIP] ethtool: generic netlink policy
Date: Sun, 10 Apr 2016 20:15:45 -0700
Message-ID: <1460344545-45501-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, jiri@resnulli.us, eladr@mellanox.com,
	idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34994 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbcDKDPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 23:15:50 -0400
Received: by mail-pa0-f45.google.com with SMTP id td3so112682121pab.2
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 20:15:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

netlink for ethtool came up at netconf/netdev and we had promised to
send some of the ethtool netlink code we have.
We use a generic netlink channel for ethtool between our kernel and
user space driver. This ethtool channel nicely wraps most ethtool
commands into genl messages. And is capable of handling delayed
remote ops to userspace in some cases (dropping rtnl etc). We use
this channel to also cache some of this ethtool data in the kernel.
In this patch I have included just the genl policy for ethtool which
will apply to the generic usecase. We can certainly share the rest of
it if we see a usecase. Especially the remote handling of ethtool ops
for delayed hw operations maybe useful in other cases (today they are
tied to our remote driver in userspace). The ethtool handlers for
genl use the existing ethtool structs and call into the
respective driver handlers.

This came up again at the switchdev discussion recently and I had
promised to get this out this weekend :). This patch does not include
changes to compile the code.

We should move ethtool to netlink at some point: And I think we
should also explore the possibility of including it into the existing
new devlink generic netlink infrastructure. And ethtool stats should
move to the new stats infrastructure.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
---
 net/core/ethtool_netlink.c | 200 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 200 insertions(+)
 create mode 100644 net/core/ethtool_netlink.c

diff --git a/net/core/ethtool_netlink.c b/net/core/ethtool_netlink.c
new file mode 100644
index 0000000..f5445f3
--- /dev/null
+++ b/net/core/ethtool_netlink.c
@@ -0,0 +1,200 @@
+/*
+ *  net/core/ethtool_netlink.c - generic ethtool netlink handler
+ *  Copyright (C) 2015 Cumulus Networks
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ *  GNU General Public License for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/capability.h>
+#include <linux/errno.h>
+#include <linux/ethtool.h>
+#include <linux/port.h>
+#include <linux/netdevice.h>
+#include <linux/list.h>
+#include <linux/rtnetlink.h>
+#include <linux/hashtable.h>
+#include <linux/rcupdate.h>
+#include <linux/nsproxy.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/genetlink.h>
+
+static const struct nla_policy ethtool_policy[ETHTOOL_ATTR_MAX + 1] = {
+	[ETHTOOL_ATTR_IFINDEX]		= { .type = NLA_U32 },
+	[ETHTOOL_ATTR_FLAGS]		= { .type = NLA_U32 },
+	[ETHTOOL_ATTR_PHYS_ID_STATE]	= { .type = NLA_U8 },
+	[ETHTOOL_ATTR_SETTINGS]		= { .type = NLA_BINARY,
+		.len = sizeof(struct ethtool_cmd) },
+	[ETHTOOL_ATTR_PAUSE]		= { .type = NLA_BINARY,
+		.len = sizeof(struct ethtool_pauseparam) },
+	[ETHTOOL_ATTR_MODINFO]		= { .type = NLA_BINARY,
+		.len = sizeof(struct ethtool_modinfo) },
+	[ETHTOOL_ATTR_EEPROM]		= { .type = NLA_BINARY,
+		.len = sizeof(struct ethtool_eeprom) },
+	[ETHTOOL_ATTR_EEPROM_DATA]		= { .type = NLA_BINARY },
+	[ETHTOOL_ATTR_STATS]		= { .type = NLA_NESTED },
+	[ETHTOOL_ATTR_STAT]		= { .type = NLA_U32 },
+	[ETHTOOL_ATTR_STRINGS]		= { .type = NLA_NESTED },
+	[ETHTOOL_ATTR_STRING]		= { .type = NLA_STRING,
+		.len = ETH_GSTRING_LEN },
+	[ETHTOOL_ATTR_SSET]		= { .type = NLA_U32 },
+	[ETHTOOL_ATTR_SSET_COUNT]		= { .type = NLA_U32 },
+};
+
+static struct genl_family ethtool_family = {
+	.id = GENL_ID_GENERATE,
+	.name = "ethtool_family",
+	.version = 1,
+	.maxattr = ETHTOOL_ATTR_MAX,
+};
+
+static struct genl_multicast_group ethtool_mcgrp[] = {
+	{ .name = "port_mc", },
+};
+
+static LIST_HEAD(wq_list);
+
+static struct genl_ops ethtool_ops[] = {
+	{
+		.cmd = ETHTOOL_CMD_GET_SETTINGS,
+		.policy = ethtool_policy,
+		.doit = ethtool_get_settings,
+	},
+	{
+		.cmd = ETHTOOL_CMD_SET_SETTINGS,
+		.policy = ethtool_policy,
+		.doit = ethtool_set_settings,
+	},
+	{
+		.cmd = ETHTOOL_CMD_GET_PAUSE,
+		.policy = ethtool_policy,
+		.doit = ethtool_get_pause,
+	},
+	{
+		.cmd = ETHTOOL_CMD_SET_PAUSE,
+		.policy = ethtool_policy,
+		.doit = ethtool_set_pause,
+	},
+	{
+		.cmd = ETHTOOL_CMD_GET_MODULE_INFO,
+		.policy = ethtool_policy,
+		.doit = ethtool_get_module_info,
+	},
+	{
+		.cmd = ETHTOOL_CMD_SET_MODULE_INFO,
+		.policy = ethtool_policy,
+		.doit = ethtool_set_module_info,
+	},
+};
+
+int ethtool_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ethtool_get_settings);
+
+int ethtool_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ethtool_set_settings);
+
+void ethtool_get_pauseparam(struct net_device *dev,
+			    struct ethtool_pauseparam *pause)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ethtool_get_pauseparam);
+
+int ethtool_set_pauseparam(struct net_device *dev,
+			   struct ethtool_pauseparam *pause)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ethtool_set_pauseparam);
+
+void ethtool_get_ethtool_stats(struct net_device *dev,
+			       struct ethtool_stats *stats,
+			       u64 *data)
+{
+
+	/* example the driver handler would do the below
+	 *
+	err = nla_put_u32(msg, PORT_ATTR_IFINDEX, ifindex);
+	if (err < 0)
+		goto err_out;
+
+	err = nla_put_u32(msg, PORT_ATTR_FLAGS, flags);
+	if (err < 0)
+		goto err_out;
+
+	err = nla_put_u32(msg, PORT_ATTR_SSET_COUNT,
+			  count);
+	if (err < 0)
+		goto err_out;
+
+	nest = nla_nest_start(msg, PORT_ATTR_STATS);
+	for (i = 0; i < count; i++)
+		nla_put_u64(msg, PORT_ATTR_STAT, data[i]);
+			    nla_nest_end(msg, nest);
+
+	 */
+}
+EXPORT_SYMBOL_GPL(ethtool_get_ethtool_stats);
+
+void ethtool_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+	return;
+}
+EXPORT_SYMBOL_GPL(ethtool_get_strings);
+
+int ethtool_get_sset_count(struct net_device *dev, int sset)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ethtool_get_sset_count);
+
+int ethtool_set_phys_id(struct net_device *dev, enum ethtool_phys_id_state state)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ethtool_set_phys_id);
+
+int ethtool_get_module_info(struct net_device *dev, struct ethtool_modinfo *info)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ethtool_get_module_info);
+
+int ethtool_get_module_eeprom(struct net_device *dev,
+			      struct ethtool_eeprom *eeprom, u8 *data)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ethtool_get_module_eeprom);
+
+static int __init ethtool_init(void)
+{
+	int err;
+
+	err = genl_register_family_with_ops_groups(&ethtool_family, ethtool_ops,
+						   ethtool_mcgrp);
+	if (err) {
+		genl_unregister_family(&port_family);
+		return err;
+	}
+	pr_debug("ethtool netlink family register OK\n");
+
+	return 0;
+}
+late_initcall(ethtool_init);
-- 
1.9.1
