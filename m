From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 3/3] net: unft: Add Userspace hairpin network flow table device
Date: Wed, 18 Feb 2015 14:25:59 -0500
Message-ID: <1424287559-25700-4-git-send-email-simon.horman@netronome.com>
References: <1424287559-25700-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:38254 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754907AbbBRT01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 14:26:27 -0500
Received: by yhzz6 with SMTP id z6so2228230yhz.5
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 11:26:26 -0800 (PST)
In-Reply-To: <1424287559-25700-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

*** Not for Upstream Merge
*** For informational purposes only

Allows the implementation of the NDO's proposed by John Fastabend's API
to be implemented in user-space. This is done using netlink messages.

Limitations:
* Both the design and the implementation are slow

I have also written user-space code. There are two portions:

1. flow-table

   This may be used to send and receive messages from the Flow API.
   It a command-line utility which may be used to exercise the flow API.
   And a library to help achieve this. An interesting portion
   of the library is a small framework for converting between
   netlink and JSON.

   It is available here: https://github.com/horms/flow-table
   The licence is GPLv2

   It overlaps to some extent with user-space code by John Fastabend.
   I was not aware of that work which he was doing concurrently.

2. flow-table-hairpin

   This is a daemon that listens for messages hairpined back
   to user-space and responds accordingly. That is, the user-space
   backing of the NDOs of the Flow API.

   It includes a simple flow table backend (ftbe) abstraction
   and a dummy implementation that stores flows in a local list
   ** and does nothing else with them ***

   It is available here: https://github.com/horms/flow-table-hairpin
   The licence is GPLv2

Simple usage example:

ip link add type unft

flow-table-hairpind \
        --tables tables.json \
        --headers headers.json \
        --actions actions.json \
        --header-graph header-graph.json \
        --table-graph table-graph.json &

flow-table-ctl get-tables unft0

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/Kconfig  |    9 +
 drivers/net/Makefile |    1 +
 drivers/net/unft.c   | 1520 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 1530 insertions(+)
 create mode 100644 drivers/net/unft.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d6607ee..9a4ddb1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -268,6 +268,15 @@ config NLMON
 	  diagnostics, etc. This is mostly intended for developers or support
 	  to debug netlink issues. If unsure, say N.
 
+config UNFT
+	tristate "User-Space hairpin network flow table device"
+	depends on NET_FLOW_TABLES
+	---help---
+	  This option enables a hairpin network flow table device. The
+	  purpose of this is to reflect network flow table API calls,
+	  made via netlink messages, to user-space to allow prototyping
+	  of implementations there. If unsure, say N.
+
 endif # NET_CORE
 
 config SUNGEM_PHY
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index e25fdd7..88ca294 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -24,6 +24,7 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_VXLAN) += vxlan.o
 obj-$(CONFIG_NLMON) += nlmon.o
+obj-$(CONFIG_UNFT) += unft.o
 
 #
 # Networking Drivers
diff --git a/drivers/net/unft.c b/drivers/net/unft.c
new file mode 100644
index 0000000..483dc8d
--- /dev/null
+++ b/drivers/net/unft.c
@@ -0,0 +1,1520 @@
+/* Based on nlmon.c by Daniel Borkmann, Mathieu Geli et al. */
+/* Based on flow_table.c by John Fastabend */
+/*
+ * include/uapi/linux/if_flow_hairpin.h -
+ * Hairpin to allow the messages of the Flow table interface for
+ * Swtich devices to be forwarded to user-space
+ * Copyright (c) 2014 Simon Horman <simon.horman@netronome.com>
+ *
+ * Based on: flow_table.c
+ * Copyright (c) 2014 John Fastabend <john.r.fastabend@intel.com>
+ *
+ * Based on nlmon.c by Daniel Borkmann, Mathieu Geli et al.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Author: Simon Horman <simon.horman@netronome.com>
+ */
+
+#include <linux/if_arp.h>
+#include <linux/if_flow_common.h>
+#include <linux/if_flow_hairpin.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/netlink.h>
+#include <net/genetlink.h>
+#include <net/sock.h>
+#include <net/rtnetlink.h>
+
+static struct genl_family net_flow_hairpin_nl_family = {
+	.id = GENL_ID_GENERATE,
+	.name = NFLH_GENL_NAME,
+	.version = NFLH_GENL_VERSION,
+	.maxattr = NFLH_MAX,
+	.netnsok = true,
+};
+
+/* Protected by genl_lock */
+static u32 net_flow_hairpin_listener_pid;
+static bool net_flow_hairpin_listener_set;
+static struct net_flow_tbl **unft_table_list;
+static struct net_flow_hdr **unft_header_list;
+static struct net_flow_action **unft_action_list;
+static struct net_flow_hdr_node **unft_header_nodes;
+static struct net_flow_tbl_node **unft_table_nodes;
+
+#ifdef CONFIG_NET_NS
+/* Protected by genl_lock */
+static struct net *net_flow_hairpin_listener_net;
+#endif
+
+/* In flight encap request details.
+ * Protected by genl_lock.
+ */
+static DECLARE_WAIT_QUEUE_HEAD(unft_msg_wq);
+static int unft_msg_state;
+static int unft_msg_status;
+
+enum {
+	UNFT_MSG_S_NONE,
+	UNFT_MSG_S_REQUEST,
+	UNFT_MSG_S_REPLY,
+};
+
+/* This is 64-bits to allow plenty of space
+ * for example to partition the sequence number space on a per-CPU basis.
+ */
+static u64 unft_msg_seq;
+
+static int unft_flow_encap_request(struct net_device *dev, u32 cmd,
+				   int (*cb)(struct sk_buff *msg, void *priv),
+				   void *priv)
+{
+	int err = -ENOBUFS;
+	struct genl_info info = {
+		.dst_sk = read_pnet(&net_flow_hairpin_listener_net)->genl_sock,
+		.snd_portid = net_flow_hairpin_listener_pid,
+	};
+	struct genlmsghdr *hdr;
+	struct nlattr *encap, *encap_attr;
+	struct sk_buff *msg;
+
+	/* At this time only one message is allowed at a time */
+	if (unft_msg_state != UNFT_MSG_S_NONE)
+		return -EBUSY;
+
+	msg = genlmsg_new_unicast(NLMSG_DEFAULT_SIZE, &info, GFP_KERNEL);
+	if (!msg)
+		return -ENOBUFS;
+
+	hdr = genlmsg_put(msg, 0, 0, &net_flow_hairpin_nl_family, 0,
+			  NFLH_CMD_ENCAP);
+	if (!hdr)
+		goto err_msg;
+
+	encap = nla_nest_start(msg, NFLH_ENCAP);
+	if (!encap) {
+		err = -EMSGSIZE;
+		goto err_msg;
+	}
+
+	unft_msg_state = UNFT_MSG_S_REQUEST;
+	unft_msg_seq++;
+
+	if (nla_put_u32(msg, NFLH_ENCAP_CMD_TYPE,
+			NFLH_ENCAP_CMD_NFL_CMD) ||
+	    nla_put_u32(msg, NFLH_ENCAP_CMD, cmd) ||
+	    nla_put_u64(msg, NFLH_ENCAP_SEQ, unft_msg_seq)) {
+		err = -ENOBUFS;
+		goto err_encap;
+	}
+
+	encap_attr = nla_nest_start(msg, NFLH_ENCAP_ATTR);
+	if (!encap) {
+		err = -EMSGSIZE;
+		goto err_encap;
+	}
+
+	if (nla_put_u32(msg, NFL_IDENTIFIER_TYPE,
+			NFL_IDENTIFIER_IFINDEX) ||
+	    nla_put_u32(msg, NFL_IDENTIFIER, dev->ifindex)) {
+		err = -ENOBUFS;
+		goto err_encap_attr;
+	}
+
+	if (cb) {
+		err = cb(msg, priv);
+		if (err)
+			goto err_encap_attr;
+	}
+
+	nla_nest_end(msg, encap_attr);
+	nla_nest_end(msg, encap);
+
+	err = genlmsg_end(msg, hdr);
+	if (err < 0)
+		goto err_msg;
+
+	err = genlmsg_unicast(read_pnet(&net_flow_hairpin_listener_net),
+			      msg, net_flow_hairpin_listener_pid);
+	if (err)
+		return err;
+
+	genl_unlock();
+	err = wait_event_interruptible_timeout(unft_msg_wq,
+					       unft_msg_state == UNFT_MSG_S_REPLY,
+					       msecs_to_jiffies(5000));
+	genl_lock();
+	if (err < 0)
+		goto out;
+	if (unft_msg_state != UNFT_MSG_S_REPLY) {
+		err = -ETIMEDOUT;
+		goto out;
+	}
+
+	err = unft_msg_status;
+	goto out;
+
+err_encap_attr:
+	nla_nest_cancel(msg, encap_attr);
+err_encap:
+	nla_nest_cancel(msg, encap);
+err_msg:
+	nlmsg_free(msg);
+out:
+	unft_msg_state = UNFT_MSG_S_NONE;
+
+	return err;
+}
+
+static int unft_set_del_rule_cb(struct sk_buff *msg, void *priv)
+{
+	int err;
+	struct net_flow_rule *rule = priv;
+	struct nlattr *start;
+
+	start = nla_nest_start(msg, NFL_FLOWS);
+	if (!start)
+		return -EMSGSIZE;
+
+	err = net_flow_put_rule(msg, rule);
+	if (err) {
+		nla_nest_cancel(msg, start);
+		return -ENOBUFS;
+	}
+
+	nla_nest_end(msg, start);
+
+	return 0;
+}
+
+static int unft_flow_table_set_rule(struct net_device *dev,
+				    struct net_flow_rule *rule)
+{
+	return unft_flow_encap_request(dev, NFL_TABLE_CMD_SET_FLOWS,
+				       unft_set_del_rule_cb, rule);
+}
+
+static int unft_flow_table_del_rule(struct net_device *dev,
+				     struct net_flow_rule *rule)
+{
+	return unft_flow_encap_request(dev, NFL_TABLE_CMD_DEL_FLOWS,
+				       unft_set_del_rule_cb, rule);
+}
+
+static const
+struct nla_policy net_flow_hairpin_listener_policy[NFLH_LISTENER_ATTR_MAX + 1] = {
+	[NFLH_LISTENER_ATTR_TYPE] = { .type = NLA_U32,},
+	[NFLH_LISTENER_ATTR_PIDS] = { .type = NLA_U32,},
+};
+
+static int net_flow_table_hairpin_cmd_set_listener(struct sk_buff *skb,
+						   struct genl_info *info)
+{
+	int err;
+	struct nlattr *tb[NFLH_LISTENER_ATTR_MAX + 1];
+	u32 pid, type;
+
+	if (!info->attrs[NFLH_LISTENER])
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, NFLH_LISTENER_ATTR_MAX,
+			       info->attrs[NFLH_LISTENER],
+			       net_flow_hairpin_listener_policy);
+	if (err)
+		return err;
+
+	if (!tb[NFLH_LISTENER_ATTR_TYPE] ||
+	    !tb[NFLH_LISTENER_ATTR_PIDS])
+		return -EINVAL;
+	type = nla_get_u32(tb[NFLH_LISTENER_ATTR_TYPE]);
+	if (type != NFLH_LISTENER_ATTR_TYPE_ENCAP)
+		return -EOPNOTSUPP;
+
+	if (tb[NFLH_LISTENER_ATTR_PIDS]) {
+		/* Only the first pid is used at this time */
+		pid = nla_get_u32(tb[NFLH_LISTENER_ATTR_PIDS]);
+		net_flow_hairpin_listener_pid = pid;
+		write_pnet(&net_flow_hairpin_listener_net,
+			   hold_net(sock_net(skb->sk)));
+		net_flow_hairpin_listener_set = true;
+	} else {
+		net_flow_hairpin_listener_set = false;
+	}
+
+	return 0;
+}
+
+static int net_flow_table_hairpin_cmd_get_listener(struct sk_buff *skb,
+						   struct genl_info *info)
+{
+	int err;
+	struct genlmsghdr *hdr;
+	struct nlattr *start;
+	struct nlattr *tb[NFLH_LISTENER_ATTR_MAX + 1];
+	struct sk_buff *msg = NULL;
+	u32 type;
+
+	if (!info->attrs[NFLH_LISTENER]) {
+		err = -EINVAL;
+		goto err;
+	}
+
+	err = nla_parse_nested(tb, NFLH_LISTENER_ATTR_MAX,
+			       info->attrs[NFLH_LISTENER],
+			       net_flow_hairpin_listener_policy);
+	if (err)
+		goto err;
+
+	if (!tb[NFLH_LISTENER_ATTR_TYPE]) {
+		err = -EINVAL;
+		goto err;
+	}
+	type = nla_get_u32(tb[NFLH_LISTENER_ATTR_TYPE]);
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg) {
+		err = -ENOBUFS;
+		goto err;
+	}
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			  &net_flow_hairpin_nl_family, 0,
+			  NFLH_CMD_GET_LISTENER);
+	if (!hdr) {
+		err = -ENOBUFS;
+		goto err;
+	}
+
+	start = nla_nest_start(msg, NFLH_LISTENER);
+	if (!start)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(msg, NFLH_LISTENER_ATTR_TYPE,
+			NFLH_LISTENER_ATTR_TYPE_ENCAP))
+		return -ENOBUFS;
+
+	if (net_flow_hairpin_listener_set &&
+	    nla_put_u32(msg, NFLH_LISTENER_ATTR_PIDS,
+			net_flow_hairpin_listener_pid))
+		return -ENOBUFS;
+
+	nla_nest_end(msg, start);
+
+	err = genlmsg_end(msg, hdr);
+	if (err < 0)
+		goto err;
+
+	return genlmsg_reply(msg, info);
+
+err:
+	nlmsg_free(msg);
+	return err;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static struct net_flow_field_ref *
+unft_encap_get_field_refs(struct nlattr *attr)
+{
+	int count, err, rem;
+	struct net_flow_field_ref *refs;
+	struct nlattr *a;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem)
+		if (nla_type(a) == NFL_FIELD_REF)
+			count++;
+
+	refs = kcalloc(count + 1, sizeof *refs, GFP_KERNEL);
+	if (!refs)
+		return ERR_PTR(-ENOMEM);
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem) {
+		if (nla_type(a) != NFL_FIELD_REF)
+			continue;
+		err = net_flow_get_field(&refs[count++], a);
+		if (err) {
+			kfree(refs);
+			return ERR_PTR(err);
+		}
+	}
+
+	return refs;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static int *
+unft_encap_get_action_descs(struct nlattr *attr)
+{
+	int count, rem;
+	struct nlattr *a;
+	int *actions;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem)
+		if (nla_type(a) == NFL_ACTION_ATTR_UID)
+			count++;
+
+	actions = kcalloc(count + 1, sizeof *actions, GFP_KERNEL);
+	if (!actions)
+		return ERR_PTR(-ENOMEM);
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem) {
+		u32 x;
+
+		if (nla_type(a) != NFL_ACTION_ATTR_UID)
+			continue;
+		x = nla_get_u32(a);
+		if (!x || x > INT_MAX) {
+			kfree(actions);
+			return ERR_PTR(-EINVAL);
+		}
+		actions[count] = x;
+	}
+
+	return actions;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static char *unft_encap_get_name(struct nlattr *attr)
+{
+	int max;
+	char *name;
+
+	max = nla_len(attr);
+	if (max > NFL_MAX_NAME)
+		max = NFL_MAX_NAME;
+	name = kzalloc(max, GFP_KERNEL);
+	if (!name)
+		return NULL;
+	nla_strlcpy(name, attr, max);
+
+	return name;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static const
+struct nla_policy flow_table_table_attr_policy[NFL_TABLE_ATTR_MAX + 1] =
+{
+	[NFL_TABLE_ATTR_NAME]		= { .type = NLA_STRING },
+	[NFL_TABLE_ATTR_UID]		= { .type = NLA_U32 },
+	[NFL_TABLE_ATTR_SOURCE]		= { .type = NLA_U32 },
+	[NFL_TABLE_ATTR_APPLY]		= { .type = NLA_U32 },
+	[NFL_TABLE_ATTR_SIZE]		= { .type = NLA_U32 },
+	[NFL_TABLE_ATTR_MATCHES]	= { .type = NLA_NESTED },
+	[NFL_TABLE_ATTR_ACTIONS]	= { .type = NLA_NESTED },
+};
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static void unft_encap_free_table(struct net_flow_tbl *table)
+{
+	kfree(table->name);
+	kfree(table->matches);
+	kfree(table->actions);
+	kfree(table);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure */
+struct net_flow_tbl *unft_encap_get_table(struct nlattr *attr)
+{
+	int err = -EINVAL;
+	struct net_flow_tbl *table;
+	struct nlattr *attrs[NFL_TABLE_ATTR_MAX + 1];
+
+	table = kzalloc(sizeof *table, GFP_KERNEL);
+	if (!table)
+		return ERR_PTR(-ENOMEM);
+
+	err = nla_parse_nested(attrs, NFL_TABLE_ATTR_MAX,
+			       attr, flow_table_table_attr_policy);
+	if (err)
+		goto err;
+
+	if (!attrs[NFL_TABLE_ATTR_NAME] || !attrs[NFL_TABLE_ATTR_UID] ||
+	    !attrs[NFL_TABLE_ATTR_SOURCE] || !attrs[NFL_TABLE_ATTR_APPLY] ||
+	    !attrs[NFL_TABLE_ATTR_SIZE] || !attrs[NFL_TABLE_ATTR_UID] ||
+	    !attrs[NFL_TABLE_ATTR_MATCHES] || !attrs[NFL_TABLE_ATTR_ACTIONS])
+		goto err;
+
+	table->name = unft_encap_get_name(attrs[NFL_TABLE_ATTR_NAME]);
+	if (!table->name) {
+		err = -ENOMEM;
+		goto err;
+	}
+
+	table->uid = nla_get_u32(attrs[NFL_TABLE_ATTR_UID]);
+	table->source = nla_get_u32(attrs[NFL_TABLE_ATTR_SOURCE]);
+	table->apply_action = nla_get_u32(attrs[NFL_TABLE_ATTR_APPLY]);
+	table->size = nla_get_u32(attrs[NFL_TABLE_ATTR_SIZE]);
+
+	table->matches = unft_encap_get_field_refs(attrs[NFL_TABLE_ATTR_MATCHES]);
+	if (IS_ERR(table->matches)) {
+		err = PTR_ERR(table->matches);
+		goto err;
+	}
+
+	table->actions = unft_encap_get_action_descs(attrs[NFL_TABLE_ATTR_ACTIONS]);
+	if (IS_ERR(table->actions)) {
+		err = PTR_ERR(table->actions);
+		goto err;
+	}
+
+	return table;
+err:
+	unft_encap_free_table(table);
+	return ERR_PTR(err);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static void unft_encap_free_tables(struct net_flow_tbl **tables)
+{
+	int i;
+
+	if (!tables)
+		return;
+
+	for (i = 0; !IS_ERR_OR_NULL(tables[i]); i++)
+		unft_encap_free_table(tables[i]);
+
+	kfree(tables);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static int unft_encap_get_tables(struct nlattr *attr)
+{
+	int count, rem;
+	struct nlattr *a;
+
+	if (!attr || unft_table_list)
+		return -EINVAL;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem)
+		if (nla_type(a) == NFL_TABLE)
+			count++;
+
+	unft_table_list = kcalloc(count + 1, sizeof *unft_table_list,
+				  GFP_KERNEL);
+	if (!unft_table_list)
+		return -ENOMEM;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem) {
+		if (nla_type(a) != NFL_TABLE)
+			continue;
+
+		unft_table_list[count] = unft_encap_get_table(a);
+		if (IS_ERR(unft_table_list[count])) {
+			int err = PTR_ERR(unft_table_list[count]);
+
+			unft_encap_free_tables(unft_table_list);
+			unft_table_list = NULL;
+			return err;
+		}
+
+		count++;
+	}
+
+	return 0;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static const
+struct nla_policy flow_table_field_attr_policy[NFL_FIELD_ATTR_MAX + 1] =
+{
+	[NFL_FIELD_ATTR_NAME]		= { .type = NLA_STRING },
+	[NFL_FIELD_ATTR_UID]		= { .type = NLA_U32 },
+	[NFL_FIELD_ATTR_BITWIDTH]	= { .type = NLA_U32 },
+};
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure */
+int unft_encap_get_field(struct nlattr *attr, struct net_flow_field *field)
+{
+	int err;
+	struct nlattr *attrs[NFL_FIELD_ATTR_MAX + 1];
+
+	err = nla_parse_nested(attrs, NFL_FIELD_ATTR_MAX, attr,
+			       flow_table_field_attr_policy);
+	if (err)
+		return err;
+
+	if (!attrs[NFL_FIELD_ATTR_NAME] || !attrs[NFL_FIELD_ATTR_UID] ||
+	    !attrs[NFL_FIELD_ATTR_BITWIDTH])
+		return -EINVAL;
+
+	field->name = unft_encap_get_name(attrs[NFL_FIELD_ATTR_NAME]);
+	if (!field->name)
+		return -ENOMEM;
+
+	field->uid = nla_get_u32(attrs[NFL_FIELD_ATTR_UID]);
+	field->bitwidth = nla_get_u32(attrs[NFL_FIELD_ATTR_BITWIDTH]);
+
+	return 0;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static void unft_encap_free_fields(struct net_flow_field *fields, int count)
+{
+	int i;
+
+	if (!fields)
+		return;
+
+	for (i = 0; i < count; i++)
+		kfree(fields[i].name);
+
+	kfree(fields);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static int unft_encap_get_header_fields(struct nlattr *attr,
+					struct net_flow_hdr *header)
+{
+	int count, rem;
+	struct nlattr *a;
+
+	if (!attr)
+		return -EINVAL;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem)
+		if (nla_type(a) == NFL_FIELD)
+			count++;
+
+	header->field_sz = count;
+	header->fields = kcalloc(count, sizeof *header->fields, GFP_KERNEL);
+	if (!header->fields)
+		return -ENOMEM;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem) {
+		int err;
+
+		if (nla_type(a) != NFL_FIELD)
+			continue;
+
+		err = unft_encap_get_field(a, &header->fields[count]);
+		if (err) {
+			unft_encap_free_fields(header->fields, count);
+			return err;
+		}
+
+		count++;
+	}
+
+	return 0;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static void unft_encap_free_header(struct net_flow_hdr *header)
+{
+	unft_encap_free_fields(header->fields, header->field_sz);
+	kfree(header->name);
+	kfree(header);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static const
+struct nla_policy flow_table_header_attr_policy[NFL_HEADER_ATTR_MAX + 1] =
+{
+	[NFL_HEADER_ATTR_NAME]		= { .type = NLA_STRING },
+	[NFL_HEADER_ATTR_UID]		= { .type = NLA_U32 },
+	[NFL_HEADER_ATTR_FIELDS]	= { .type = NLA_NESTED },
+};
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure */
+struct net_flow_hdr *unft_encap_get_header(struct nlattr *attr)
+{
+	int err = -EINVAL;
+	struct net_flow_hdr *header;
+	struct nlattr *attrs[NFL_HEADER_ATTR_MAX + 1];
+
+	header = kzalloc(sizeof *header, GFP_KERNEL);
+	if (!header)
+		return ERR_PTR(-ENOMEM);
+
+	err = nla_parse_nested(attrs, NFL_HEADER_ATTR_MAX, attr,
+			       flow_table_header_attr_policy);
+	if (err)
+		goto err;
+
+	if (!attrs[NFL_HEADER_ATTR_NAME] || !attrs[NFL_HEADER_ATTR_UID] ||
+	    !attrs[NFL_HEADER_ATTR_FIELDS])
+		goto err;
+
+	header->name = unft_encap_get_name(attrs[NFL_HEADER_ATTR_NAME]);
+	if (!header->name) {
+		err = -ENOMEM;
+		goto err;
+	}
+
+	header->uid = nla_get_u32(attrs[NFL_HEADER_ATTR_UID]);
+
+	err = unft_encap_get_header_fields(attrs[NFL_HEADER_ATTR_FIELDS],
+					   header);
+	if (err)
+		goto err;
+
+	return header;
+err:
+	unft_encap_free_header(header);
+	return ERR_PTR(err);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static void unft_encap_free_headers(struct net_flow_hdr **headers)
+{
+	int i;
+
+	if (!headers)
+		return;
+
+	for (i = 0; !IS_ERR_OR_NULL(headers[i]); i++)
+		unft_encap_free_header(headers[i]);
+
+	kfree(headers);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static int unft_encap_get_headers(struct nlattr *attr)
+{
+	int count, rem;
+	struct nlattr *a;
+
+	if (!attr || unft_header_list)
+		return -EINVAL;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem)
+		if (nla_type(a) == NFL_HEADER)
+			count++;
+
+	unft_header_list = kcalloc(count + 1, sizeof *unft_header_list,
+				  GFP_KERNEL);
+	if (!unft_header_list)
+		return -ENOMEM;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem) {
+		if (nla_type(a) != NFL_HEADER)
+			continue;
+
+		unft_header_list[count] = unft_encap_get_header(a);
+		if (IS_ERR(unft_header_list[count])) {
+			int err = PTR_ERR(unft_header_list[count]);
+
+			unft_encap_free_headers(unft_header_list);
+			unft_header_list = NULL;
+			return err;
+		}
+
+		count++;
+	}
+
+	return 0;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static void unft_encap_free_actions(struct net_flow_action **actions)
+{
+	int i;
+
+	if (!actions)
+		return;
+
+	for (i = 0; actions[i]; i++) {
+		if (actions[i]->args) {
+			kfree(actions[i]->args->name);
+			kfree(actions[i]->args);
+		}
+		kfree(actions[i]);
+	}
+
+	kfree(actions);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static int unft_encap_get_actions(struct nlattr *attr)
+{
+	int count, rem;
+	int err = 0;
+	struct nlattr *a;
+
+	if (!attr || unft_action_list)
+		return -EINVAL;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem)
+		if (nla_type(a) == NFL_HEADER)
+			count++;
+
+	unft_action_list = kcalloc(count + 1, sizeof *unft_action_list,
+				  GFP_KERNEL);
+	if (!unft_action_list)
+		return -ENOMEM;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem) {
+		int err;
+
+		if (nla_type(a) != NFL_HEADER)
+			continue;
+
+		unft_action_list[count] = kzalloc(sizeof *unft_action_list[count],
+						  GFP_KERNEL);
+		if (!unft_action_list[count]) {
+			err = -ENOMEM;
+			goto err;
+		}
+
+		err = net_flow_get_action(unft_action_list[count], a);
+		if (err)
+			goto err;
+
+		count++;
+	}
+
+	return 0;
+
+err:
+	unft_encap_free_actions(unft_action_list);
+	unft_action_list = NULL;
+	return err;
+}
+
+/* Copied from flow_table.c */
+static const
+struct nla_policy net_flow_field_policy[NFL_FIELD_REF_MAX + 1] = {
+        [NFL_FIELD_REF_NEXT_NODE] = { .type = NLA_U32,},
+        [NFL_FIELD_REF_INSTANCE]  = { .type = NLA_U32,},
+        [NFL_FIELD_REF_HEADER]    = { .type = NLA_U32,},
+        [NFL_FIELD_REF_FIELD]     = { .type = NLA_U32,},
+        [NFL_FIELD_REF_MASK_TYPE] = { .type = NLA_U32,},
+        [NFL_FIELD_REF_TYPE]      = { .type = NLA_U32,},
+        [NFL_FIELD_REF_VALUE]     = { .type = NLA_BINARY,
+                                      .len = sizeof(u64)},
+        [NFL_FIELD_REF_MASK]      = { .type = NLA_BINARY,
+                                      .len = sizeof(u64)},
+};
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure */
+int unft_encap_get_jump_table(struct net_flow_jump_table *table,
+			      struct nlattr *attr)
+{
+	int err;
+	struct nlattr *attrs[NFL_FIELD_REF_MAX + 1];
+
+	err = net_flow_get_field(&table->field, attr);
+	if (err)
+		return err;
+
+	/* net_flow_get_field() does not parse NFL_FIELD_REF_NEXT_NODE
+	 * which has no corresponding field in struct net_flow_field_ref
+	 */
+
+	err = nla_parse_nested(attrs, NFL_FIELD_REF_MAX,
+			       attr, net_flow_field_policy);
+	if (err)
+		return err;
+
+	if (!attrs[NFL_FIELD_REF_NEXT_NODE])
+		return -EINVAL;
+
+	table->node =  nla_get_u32(attrs[NFL_FIELD_REF_NEXT_NODE]);
+
+	return 0;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static struct net_flow_jump_table *unft_encap_get_jump_tables(struct nlattr *attr)
+{
+	int count, rem;
+	struct nlattr *a;
+	struct net_flow_jump_table *tables;
+
+	count = 0;
+	if (attr)
+		nla_for_each_nested(a, attr, rem)
+			if (nla_type(a) == NFL_HEADER_NODE_HDRS_VALUE)
+				count++;
+
+	tables = kcalloc(count + 1, sizeof *tables, GFP_KERNEL);
+	if (!tables)
+		return ERR_PTR(-ENOMEM);
+
+	if (!attr)
+		return tables;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem) {
+		int err;
+
+		if (nla_type(a) != NFL_HEADER_NODE_HDRS_VALUE)
+			continue;
+
+		err = unft_encap_get_jump_table(&tables[count], a);
+		if (err) {
+			kfree(tables);
+			return ERR_PTR(err);
+		}
+
+		count++;
+	}
+
+	return tables;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static int *unft_encap_get_header_node_hdrs(struct nlattr *attr)
+{
+	int count, rem;
+	struct nlattr *a;
+	int *hdrs;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem)
+		if (nla_type(a) == NFL_HEADER_NODE_HDRS_VALUE)
+			count++;
+
+	hdrs = kcalloc(count + 1, sizeof *hdrs, GFP_KERNEL);
+	if (!hdrs)
+		return ERR_PTR(-ENOMEM);
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem) {
+		u32 value;
+
+		if (nla_type(a) != NFL_HEADER_NODE_HDRS_VALUE)
+			continue;
+
+		value = nla_get_u32(a);
+		if (value > INT_MAX)
+			return ERR_PTR(-EINVAL);
+		hdrs[count++] = value;
+	}
+
+	return hdrs;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static void unft_encap_free_header_node(struct net_flow_hdr_node *node)
+{
+	kfree(node->name);
+	kfree(node->hdrs);
+	kfree(node->jump);
+	kfree(node);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static const
+struct nla_policy flow_table_header_node_policy[NFL_HEADER_NODE_MAX + 1] =
+{
+        [NFL_HEADER_NODE_NAME]          = { .type = NLA_STRING },
+        [NFL_HEADER_NODE_UID]           = { .type = NLA_U32 },
+        [NFL_HEADER_NODE_HDRS]          = { .type = NLA_NESTED },
+        [NFL_HEADER_NODE_JUMP]          = { .type = NLA_NESTED },
+};
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure */
+struct net_flow_hdr_node *unft_encap_get_header_node(struct nlattr *attr)
+{
+	int err;
+	struct net_flow_hdr_node *node;
+	struct nlattr *attrs[NFL_HEADER_NODE_MAX + 1];
+
+	node = kzalloc(sizeof *node, GFP_KERNEL);
+	if (!node)
+		return ERR_PTR(-ENOMEM);
+
+	err = nla_parse_nested(attrs, NFL_HEADER_NODE_MAX,
+			       attr, flow_table_header_node_policy);
+	if (err)
+		goto err;
+
+	if (!attrs[NFL_HEADER_NODE_NAME] || !attrs[NFL_HEADER_NODE_UID] ||
+	    !attrs[NFL_HEADER_NODE_HDRS]) {
+		err = -EINVAL;
+		goto err;
+	}
+
+	node->name = unft_encap_get_name(attrs[NFL_HEADER_NODE_NAME]);
+	if (!node->name) {
+		err = -ENOMEM;
+		goto err;
+	}
+
+	node->uid = nla_get_u32(attrs[NFL_HEADER_NODE_UID]);
+
+	node->hdrs = unft_encap_get_header_node_hdrs(attrs[NFL_HEADER_NODE_HDRS]);
+	if (IS_ERR(node->hdrs)) {
+		err = PTR_ERR(node->hdrs);
+		node->hdrs = NULL;
+		goto err;
+	}
+
+	node->jump = unft_encap_get_jump_tables(attrs[NFL_HEADER_NODE_JUMP]);
+	if (IS_ERR(node->jump)) {
+		err = PTR_ERR(node->jump);
+		node->jump = NULL;
+		goto err;
+	}
+
+	return node;
+err:
+	unft_encap_free_header_node(node);
+	return ERR_PTR(err);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static void unft_encap_free_header_nodes(struct net_flow_hdr_node **nodes)
+{
+	int i;
+
+	if (!nodes)
+		return;
+
+	for (i = 0; !IS_ERR_OR_NULL(nodes[i]); i++)
+		unft_encap_free_header_node(nodes[i]);
+
+	kfree(nodes);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static int unft_encap_get_header_graph(struct nlattr *attr)
+{
+	int count, rem;
+	struct nlattr *a;
+
+	if (!attr || unft_header_nodes)
+		return -EINVAL;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem)
+		if (nla_type(a) == NFL_HEADER_GRAPH_NODE)
+			count++;
+
+	unft_header_nodes = kcalloc(count + 1, sizeof *unft_header_nodes,
+				  GFP_KERNEL);
+	if (!unft_header_nodes)
+		return -ENOMEM;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem) {
+		if (nla_type(a) != NFL_HEADER_GRAPH_NODE)
+			continue;
+
+		unft_header_nodes[count] = unft_encap_get_header_node(a);
+		if (IS_ERR(unft_header_nodes[count])) {
+			int err = PTR_ERR(unft_header_nodes[count]);
+
+			unft_encap_free_header_nodes(unft_header_nodes);
+			unft_header_nodes = NULL;
+			return err;
+		}
+
+		count++;
+	}
+
+	return 0;
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static void unft_encap_free_table_node(struct net_flow_tbl_node *node)
+{
+	kfree(node->jump);
+	kfree(node);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static const
+struct nla_policy flow_table_table_node_policy[NFL_TABLE_GRAPH_NODE_MAX + 1] =
+{
+        [NFL_TABLE_GRAPH_NODE_UID]	= { .type = NLA_U32 },
+        [NFL_TABLE_GRAPH_NODE_FLAGS]	= { .type = NLA_U32 },
+        [NFL_TABLE_GRAPH_NODE_JUMP]	= { .type = NLA_NESTED },
+};
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure */
+struct net_flow_tbl_node *unft_encap_get_table_node(struct nlattr *attr)
+{
+	int err;
+	struct net_flow_tbl_node *node;
+	struct nlattr *attrs[NFL_TABLE_GRAPH_NODE_MAX + 1];
+
+	node = kzalloc(sizeof *node, GFP_KERNEL);
+	if (!node)
+		return ERR_PTR(-ENOMEM);
+
+	err = nla_parse_nested(attrs, NFL_TABLE_GRAPH_NODE_MAX,
+			       attr, flow_table_table_node_policy);
+	if (err)
+		goto err;
+
+	if (!attrs[NFL_TABLE_GRAPH_NODE_UID] ||
+	    !attrs[NFL_TABLE_GRAPH_NODE_FLAGS]) {
+		err = -EINVAL;
+		goto err;
+	}
+
+	node->uid = nla_get_u32(attrs[NFL_TABLE_GRAPH_NODE_UID]);
+	node->flags = nla_get_u32(attrs[NFL_TABLE_GRAPH_NODE_FLAGS]);
+
+	node->jump = unft_encap_get_jump_tables(attrs[NFL_TABLE_GRAPH_NODE_JUMP]);
+	if (IS_ERR(node->jump)) {
+		err = PTR_ERR(node->jump);
+		node->jump = NULL;
+		goto err;
+	}
+
+	return node;
+err:
+	unft_encap_free_table_node(node);
+	return ERR_PTR(err);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static void unft_encap_free_table_nodes(struct net_flow_tbl_node **nodes)
+{
+	int i;
+
+	if (!nodes)
+		return;
+
+	for (i = 0; !IS_ERR_OR_NULL(nodes[i]); i++)
+		unft_encap_free_table_node(nodes[i]);
+
+	kfree(nodes);
+}
+
+/* This only deals with encoding NFT attibutes and could
+ * be part of flow table infrastructure.
+ */
+static int unft_encap_get_table_graph(struct nlattr *attr)
+{
+	int count, rem;
+	struct nlattr *a;
+
+	if (!attr || unft_table_nodes)
+		return -EINVAL;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem)
+		if (nla_type(a) == NFL_TABLE_GRAPH_NODE)
+			count++;
+
+	unft_table_nodes = kcalloc(count + 1, sizeof *unft_table_nodes,
+				   GFP_KERNEL);
+	if (!unft_table_nodes)
+		return -ENOMEM;
+
+	count = 0;
+	nla_for_each_nested(a, attr, rem) {
+		if (nla_type(a) != NFL_TABLE_GRAPH_NODE)
+			continue;
+
+		unft_table_nodes[count] = unft_encap_get_table_node(a);
+		if (IS_ERR(unft_table_nodes[count])) {
+			int err = PTR_ERR(unft_table_nodes[count]);
+
+			unft_encap_free_table_nodes(unft_table_nodes);
+			unft_table_nodes = NULL;
+			return err;
+		}
+
+		count++;
+	}
+
+	return 0;
+}
+
+static const
+struct nla_policy unft_net_flow_policy[NFL_MAX + 1] = {
+	[NFL_IDENTIFIER_TYPE]	= { .type = NLA_U32,},
+	[NFL_IDENTIFIER]	= { .type = NLA_U32,},
+	[NFL_TABLES]		= { .type = NLA_NESTED,},
+	[NFL_HEADERS]		= { .type = NLA_NESTED,},
+	[NFL_ACTIONS]		= { .type = NLA_NESTED,},
+	[NFL_HEADER_GRAPH]	= { .type = NLA_NESTED,},
+	[NFL_TABLE_GRAPH]	= { .type = NLA_NESTED,},
+	[NFL_FLOWS]		= { .type = NLA_NESTED,},
+	[NFL_FLOWS_ERROR]	= { .type = NLA_NESTED,},
+};
+
+static int unft_encap_net_flow_cmd(u32 cmd, struct nlattr *attr)
+{
+	int err;
+	struct nlattr *tb[NFL_MAX + 1];
+	u32 ifindex, type;
+
+	if (!attr)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, NFL_MAX, attr, unft_net_flow_policy);
+	if (err)
+		return err;
+
+	if (!tb[NFL_IDENTIFIER_TYPE] || !tb[NFL_IDENTIFIER])
+		return -EINVAL;
+	type = nla_get_u32(tb[NFL_IDENTIFIER_TYPE]);
+	if (type != NFL_IDENTIFIER_IFINDEX)
+		return -EOPNOTSUPP;
+	ifindex = nla_get_u32(tb[NFL_IDENTIFIER]);
+
+	pr_debug("%s type: %u ifindex: %u cmd: %u\n", __func__, type,
+		 ifindex, cmd);
+
+	switch (cmd) {
+	case NFL_TABLE_CMD_GET_TABLES:
+		return unft_encap_get_tables(tb[NFL_TABLES]);
+
+	case NFL_TABLE_CMD_GET_HEADERS:
+		return unft_encap_get_headers(tb[NFL_HEADERS]);
+
+	case NFL_TABLE_CMD_GET_ACTIONS:
+		return unft_encap_get_actions(tb[NFL_ACTIONS]);
+
+	case NFL_TABLE_CMD_GET_HDR_GRAPH:
+		return unft_encap_get_header_graph(tb[NFL_HEADER_GRAPH]);
+
+	case NFL_TABLE_CMD_GET_TABLE_GRAPH:
+		return unft_encap_get_table_graph(tb[NFL_TABLE_GRAPH]);
+
+	case NFL_TABLE_CMD_SET_FLOWS:
+	case NFL_TABLE_CMD_DEL_FLOWS:
+		/* Noting more to decode for these commands */
+		return 0;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static const
+struct nla_policy net_flow_hairpin_encap_policy[NFLH_ENCAP_MAX + 1] = {
+	[NFLH_ENCAP_CMD_TYPE]	= { .type = NLA_U32,},
+	[NFLH_ENCAP_CMD]	= { .type = NLA_U32,},
+	[NFLH_ENCAP_SEQ]	= { .type = NLA_U64,},
+	[NFLH_ENCAP_STATUS]	= { .type = NLA_U32,},
+	[NFLH_ENCAP_ATTR]	= { .type = NLA_NESTED,},
+};
+
+static int net_flow_table_hairpin_cmd_encap(struct sk_buff *skb,
+					    struct genl_info *info)
+{
+	int err = -EINVAL;
+	struct nlattr *tb[NFLH_ENCAP_MAX + 1];
+	u32 cmd, status, type;
+	u64 seq;
+
+	if (unft_msg_state != UNFT_MSG_S_REQUEST)
+		goto out;
+
+	if (!info->attrs[NFLH_ENCAP])
+		goto out;
+
+	err = nla_parse_nested(tb, NFLH_ENCAP_MAX,
+			       info->attrs[NFLH_ENCAP],
+			       net_flow_hairpin_encap_policy);
+	if (err)
+		goto out;
+
+	if (!tb[NFLH_ENCAP_CMD_TYPE] ||
+	    !tb[NFLH_ENCAP_CMD] ||
+	    !tb[NFLH_ENCAP_SEQ] ||
+	    !tb[NFLH_ENCAP_STATUS]) {
+		err = -EINVAL;
+		goto out;
+	}
+	type = nla_get_u32(tb[NFLH_ENCAP_CMD_TYPE]);
+	if (type != NFLH_ENCAP_CMD_NFL_CMD) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+	cmd = nla_get_u32(tb[NFLH_ENCAP_CMD]);
+	seq = nla_get_u64(tb[NFLH_ENCAP_SEQ]);
+	status = nla_get_u32(tb[NFLH_ENCAP_STATUS]);
+
+	if (unft_msg_seq != seq) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	pr_debug("%s cmd: %u seq: %llu status: %u\n", __func__,
+		 cmd, seq, status);
+
+	switch (status) {
+	case NFLH_ENCAP_STATUS_OK:
+		err = unft_encap_net_flow_cmd(cmd, tb[NFLH_ENCAP_ATTR]);
+		if (err)
+			goto out;
+		unft_msg_status = 0;
+		break;
+
+	case NFLH_ENCAP_STATUS_EINVAL:
+		unft_msg_status = -EINVAL;
+		break;
+
+	case NFLH_ENCAP_STATUS_EOPNOTSUPP:
+		unft_msg_status = -EOPNOTSUPP;
+		break;
+
+	default:
+		err = -EINVAL;
+		goto out;
+	}
+
+out:
+	unft_msg_state = UNFT_MSG_S_REPLY;
+	wake_up_interruptible(&unft_msg_wq);
+	return err;
+}
+
+static const struct genl_ops net_flow_table_hairpin_nl_ops[] = {
+	{
+		.cmd = NFLH_CMD_SET_LISTENER,
+		.doit = net_flow_table_hairpin_cmd_set_listener,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NFLH_CMD_GET_LISTENER,
+		.doit = net_flow_table_hairpin_cmd_get_listener,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NFLH_CMD_ENCAP,
+		.doit = net_flow_table_hairpin_cmd_encap,
+		.flags = GENL_ADMIN_PERM,
+	},
+};
+
+static netdev_tx_t unft_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	dev_kfree_skb(skb);
+
+	return NETDEV_TX_OK;
+}
+
+static int
+unft_flow_table_get_tables__(struct net_device *dev)
+{
+	int err, i;
+
+	err = unft_flow_encap_request(dev, NFL_TABLE_CMD_GET_TABLES,
+				      NULL, NULL);
+	if (err)
+		return err;
+
+	for (i = 0; unft_table_list[i]; i++) {
+		err = net_flow_init_cache(unft_table_list[i]);
+		if (err)
+			goto err;
+	}
+
+	return 0;
+
+err:
+	while (i-- > 1)
+		net_flow_destroy_cache(unft_table_list[i - 1]);
+	return err;
+}
+
+static struct net_flow_tbl **unft_flow_table_get_tables(struct net_device *dev)
+{
+	if (!unft_table_list && unft_flow_table_get_tables__(dev))
+		return NULL;
+
+	return unft_table_list;
+}
+
+static struct net_flow_hdr **unft_flow_table_get_headers(struct net_device *dev)
+{
+	if (!unft_header_list &&
+	    unft_flow_encap_request(dev, NFL_TABLE_CMD_GET_HEADERS, NULL, NULL))
+		return NULL;
+
+	return unft_header_list;
+}
+
+static struct net_flow_action **unft_flow_table_get_actions(struct net_device *dev)
+{
+	if (!unft_action_list &&
+	    unft_flow_encap_request(dev, NFL_TABLE_CMD_GET_ACTIONS, NULL, NULL))
+		return NULL;
+
+	return unft_action_list;
+}
+
+static struct net_flow_hdr_node **unft_flow_table_get_hgraph(struct net_device *dev)
+{
+	if (!unft_header_nodes &&
+	    unft_flow_encap_request(dev, NFL_TABLE_CMD_GET_HDR_GRAPH,
+				    NULL, NULL))
+		return NULL;
+
+	return unft_header_nodes;
+}
+
+static struct net_flow_tbl_node **unft_flow_table_get_tgraph(struct net_device *dev)
+{
+	if (!unft_table_nodes &&
+	    unft_flow_encap_request(dev, NFL_TABLE_CMD_GET_TABLE_GRAPH,
+				    NULL, NULL))
+		return NULL;
+
+	return unft_table_nodes;
+}
+
+static const struct net_device_ops unft_ops = {
+	.ndo_start_xmit = unft_xmit, /* Required */
+	.ndo_flow_set_rule = unft_flow_table_set_rule,
+	.ndo_flow_del_rule = unft_flow_table_del_rule,
+	.ndo_flow_get_tbls = unft_flow_table_get_tables,
+	.ndo_flow_get_hdrs = unft_flow_table_get_headers,
+	.ndo_flow_get_actions = unft_flow_table_get_actions,
+	.ndo_flow_get_hdr_graph = unft_flow_table_get_hgraph,
+	.ndo_flow_get_tbl_graph = unft_flow_table_get_tgraph,
+};
+
+static void unft_setup(struct net_device *dev)
+{
+	dev->type = ARPHRD_NETLINK;
+	dev->tx_queue_len = 0;
+
+	dev->netdev_ops	= &unft_ops;
+	dev->destructor	= free_netdev;
+
+	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST |
+			NETIF_F_HIGHDMA | NETIF_F_LLTX;
+	dev->flags = IFF_NOARP;
+
+	/* That's rather a softlimit here, which, of course,
+	 * can be altered. Not a real MTU, but what is to be
+	 * expected in most cases.
+	 */
+	dev->mtu = NLMSG_GOODSIZE;
+}
+
+static int unft_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS])
+		return -EINVAL;
+	return 0;
+}
+
+static struct rtnl_link_ops unft_link_ops __read_mostly = {
+	.kind			= "unft",
+	.setup			= unft_setup,
+	.validate		= unft_validate,
+};
+static __init int unft_register(void)
+{
+	int err;
+
+	err = genl_register_family_with_ops(&net_flow_hairpin_nl_family,
+					    net_flow_table_hairpin_nl_ops);
+	if (err)
+		return err;
+
+	err = rtnl_link_register(&unft_link_ops);
+	if (err)
+		goto err;
+
+	return 0;
+
+err:
+	genl_unregister_family(&net_flow_hairpin_nl_family);
+	return err;
+}
+
+static __exit void unft_unregister(void)
+{
+	int i;
+
+	genl_unregister_family(&net_flow_hairpin_nl_family);
+	rtnl_link_unregister(&unft_link_ops);
+
+	for (i = 0; unft_table_list[i]; i++)
+		net_flow_destroy_cache(unft_table_list[i]);
+	unft_encap_free_tables(unft_table_list);
+	unft_encap_free_headers(unft_header_list);
+	unft_encap_free_actions(unft_action_list);
+	unft_encap_free_header_nodes(unft_header_nodes);
+	unft_encap_free_table_nodes(unft_table_nodes);
+}
+
+module_init(unft_register);
+module_exit(unft_unregister);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Simon Horman <simon.horman@netronome.com>");
+MODULE_DESCRIPTION("User-Space Hairpin Network Flow Table Device");
+MODULE_ALIAS_RTNL_LINK("unft");
+MODULE_ALIAS_GENL_FAMILY(NFLH_GENL_NAME);
-- 
2.1.4
