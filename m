From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 09/39] wimax: provides user space with information needed when opening a WiMAX device
Date: Mon, 24 Nov 2008 13:50:32 -0800
Message-ID: <fd6ab6bba983c6a3214eb423c86385f82528cd78.1227562829.git.inaky@linux.intel.com>
References: <cover.1227562829.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:47824 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753223AbYKXVvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 16:51:18 -0500
In-Reply-To: <cover.1227562829.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When user space wants to open a handle to a WiMAX device, it needs
information that is provided as a response to an "open" generic
netlink message.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/op-open.c |  157 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 157 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wimax/op-open.c

diff --git a/drivers/net/wimax/op-open.c b/drivers/net/wimax/op-open.c
new file mode 100644
index 0000000..06c9cce
--- /dev/null
+++ b/drivers/net/wimax/op-open.c
@@ -0,0 +1,157 @@
+/*
+ * Linux WiMAX
+ * Netlink layer, open operation
+ *
+ *
+ * Copyright (C) 2005-2006 Intel Corporation <linux-wimax@intel.com>
+ * Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA.
+ *
+ *
+ * Parse the open-handle command from user space.
+ *
+ * Accepts an "open" request from user space through generic netlink
+ * and replies to it with the information about internals that user
+ * space will need.
+ *
+ * This will only work if the device is in a state ready to accept
+ * user space intervention.
+ */
+#include <net/genetlink.h>
+#include <linux/wimax.h>
+#include <linux/security.h>
+#include "wimax-internal.h"
+
+#define D_SUBMODULE op_open
+#include "debug-levels.h"
+
+
+/*
+ * Authoritative source for the IFINFO attribute policy
+ *
+ * These attributes represent a struct that looks:
+ *
+ * MC_GROUPS: (nested) array of zero or more MC_GROUP
+ *   MC_GROUP: nested MC_NAME and MC_ID
+ *
+ * We don't really use it here, but /me likes to keep the definition
+ * close to where the data is generated.
+ */
+/*
+static
+struct nla_policy wimax_gnl_ifinfo_policy[WIMAX_GNL_ATTR_MAX + 1] = {
+	[WIMAX_GNL_IFINFO_MC_GROUPS] = { .type = NLA_NESTED },
+	[WIMAX_GNL_IFINFO_MC_GROUP] = { .type = NLA_NESTED },
+	[WIMAX_GNL_IFINFO_MC_NAME] = {
+		.type = NLA_STRING,
+		.len = GENL_NAMSIZ
+	},
+	[WIMAX_GNL_IFINFO_MC_ID] = { .type = NLA_U16 },
+};
+*/
+
+
+static
+int __wimax_gnl_open_reply(struct wimax_dev *wimax_dev,
+			   struct genl_info *genl_info)
+{
+	int result;
+	void *data;
+	struct sk_buff *reply_skb;
+	struct nlattr *nla_groups, *nla_group;
+	struct wimax_pipe *pipe_itr;
+
+	result = -ENOMEM;
+	reply_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (reply_skb == NULL)
+		goto error_new;
+	data = genlmsg_put_reply(reply_skb, genl_info,
+				 &wimax_dev->gnl_family,
+				 0, WIMAX_GNL_RP_IFINFO);
+	if (data == NULL)
+		goto error_put_reply;
+
+	nla_groups = nla_nest_start(reply_skb, WIMAX_GNL_IFINFO_MC_GROUPS);
+	if (nla_groups == NULL)
+		goto error_groups_start;
+
+	list_for_each_entry(pipe_itr, &wimax_dev->pipe_list,
+			    list_node) {
+		nla_group = nla_nest_start(reply_skb,
+					   WIMAX_GNL_IFINFO_MC_GROUP);
+		if (nla_group == NULL)
+			goto error_group_start;
+
+		nla_put_u16(reply_skb, WIMAX_GNL_IFINFO_MC_ID,
+			    pipe_itr->mcg.id);
+		nla_put_string(reply_skb, WIMAX_GNL_IFINFO_MC_NAME,
+			       pipe_itr->mcg.name);
+		nla_nest_end(reply_skb, nla_group);
+	}
+	nla_nest_end(reply_skb, nla_groups);
+	genlmsg_end(reply_skb, data);
+
+	result = genlmsg_reply(reply_skb, genl_info);
+	if (result < 0)
+		goto error_reply;
+	return 0;
+
+error_group_start:
+error_groups_start:
+error_reply:
+error_put_reply:
+	nlmsg_free(reply_skb);
+error_new:
+	return result;
+}
+
+
+static
+int wimax_gnl_doit_open(struct sk_buff *skb, struct genl_info *info)
+{
+	int result;
+	struct wimax_dev *wimax_dev;
+
+	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
+	result = -EPERM;
+	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+		goto error_perm;
+	result = -ENODEV;
+	wimax_dev = wimax_dev_get_by_genl_info(info);
+	if (wimax_dev == NULL)
+		goto error_no_wimax_dev;
+	mutex_lock(&wimax_dev->mutex);
+	result = wimax_dev_is_ready(wimax_dev);
+	if (result < 0)
+		goto error_not_ready;
+	result = __wimax_gnl_open_reply(wimax_dev, info);
+error_not_ready:
+	mutex_unlock(&wimax_dev->mutex);
+	dev_put(wimax_dev->net_dev);
+error_no_wimax_dev:
+error_perm:
+	d_fnend(3, NULL, "(skb %p info %p) = %d\n", skb, info, result);
+	return result;
+}
+
+
+struct genl_ops wimax_gnl_open = {
+	.cmd = WIMAX_GNL_OP_OPEN,
+	.flags = 0,
+	.policy = NULL,
+	.doit = wimax_gnl_doit_open,
+	.dumpit = NULL,
+};
-- 
1.5.6.5

