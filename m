From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 02/12] net: flow_table: add flow, delete flow
Date: Tue, 13 Jan 2015 13:35:57 -0800
Message-ID: <20150113213556.13874.41211.stgit@nitbit.x32>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net, davem@davemloft.net
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:58266 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbbAMVgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:36:15 -0500
Received: by mail-ob0-f174.google.com with SMTP id uz6so4886007obc.5
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 13:36:15 -0800 (PST)
In-Reply-To: <20150113212941.13874.48692.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the device capabilities are exposed we can add support to
add and delete flows from the tables.

The two operations are

table_set_flows :

  The set flow operations is used to program a set of flows into a
  hardware device table. The message is consumed via netlink encoded
  message which is then decoded into a null terminated  array of
  flow entry structures. A flow entry structure is defined as

     struct net_flow_flow {
			  int table_id;
			  int uid;
			  int priority;
			  struct net_flow_field_ref *matches;
			  struct net_flow_action *actions;
     }

  The table id is the _uid_ returned from 'get_tables' operatoins.
  Matches is a set of match criteria for packets with a logical AND
  operation done on the set so packets match the entire criteria.
  Actions provide a set of actions to perform when the flow rule is
  hit. Both matches and actions are null terminated arrays.

  The flows are configured in hardware using an ndo op. We do not
  provide a commit operation at the moment and expect hardware
  commits the flows one at a time. Future work may require a commit
  operation to tell the hardware we are done loading flow rules. On
  some hardware this will help bulk updates.

  Its possible for hardware to return an error from a flow set
  operation. This can occur for many reasons both transient and
  resource constraints. We have different error handling strategies
  built in and listed here,

    *_ERROR_ABORT      abort on first error with errmsg

    *_ERROR_CONTINUE   continue programming flows no errmsg

    *_ERROR_ABORT_LOG  abort on first error and return flow that
 		       failed to user space in reply msg

    *_ERROR_CONT_LOG   continue programming flows and return a list
		       of flows that failed to user space in a reply
		       msg.

  notably missing is a rollback error strategy. I don't have a
  use for this in software yet but the strategy can be added with
  *_ERROR_ROLLBACK for example.

table_del_flows

  The delete flow operation uses the same structures and error
  handling strategies as the table_set_flows operations. Although on
  delete messges ommit the matches/actions arrays because they are
  not needed to lookup the flow.

Also thanks to Simon Horman for fixes and other help.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/if_flow.h      |   21 +
 include/linux/netdevice.h    |   10 +
 include/uapi/linux/if_flow.h |   51 +++
 net/core/flow_table.c        |  760 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 841 insertions(+), 1 deletion(-)

diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
index 3e1829e..23dec9b 100644
--- a/include/linux/if_flow.h
+++ b/include/linux/if_flow.h
@@ -185,4 +185,23 @@ struct net_flow_tbl_node {
 	__u32 flags;
 	struct net_flow_jump_table *jump;
 };
-#endif
+
+/**
+ * @struct net_flow_rule
+ * @brief describes the match/action entry
+ *
+ * @uid unique identifier for flow
+ * @priority priority to execute flow match/action in table
+ * @match null terminated set of match uids match criteria
+ * @actoin null terminated set of action uids to apply to match
+ *
+ * Flows must match all entries in match set.
+ */
+struct net_flow_rule {
+	int table_id;
+	int uid;
+	int priority;
+	struct net_flow_field_ref *matches;
+	struct net_flow_action *actions;
+};
+#endif /* _IF_FLOW_H_ */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 74481b9..9d57f8b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1061,6 +1061,12 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Report a null terminated list of nodes defining the header graph. This
  *	provides the necessary graph to learn the ordering of headers supported
  *	by the device.
+ *
+ * int (*ndo_flow_set_rule)(struct net_device *dev, struct net_flow_rule *f)
+ *	This is used to program a rule into a device table.
+ *
+ * int (*ndo_flow_del_rule)(struct net_device *dev, struct net_flow_rule *f)
+ *	This is used to remove a rule from a device table.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1227,6 +1233,10 @@ struct net_device_ops {
 	struct net_flow_tbl_node **(*ndo_flow_get_tbl_graph)(struct net_device *dev);
 	struct net_flow_hdr	 **(*ndo_flow_get_hdrs)(struct net_device *dev);
 	struct net_flow_hdr_node **(*ndo_flow_get_hdr_graph)(struct net_device *dev);
+	int		        (*ndo_flow_set_rule)(struct net_device *dev,
+						     struct net_flow_rule *f);
+	int		        (*ndo_flow_del_rule)(struct net_device *dev,
+						     struct net_flow_rule *f);
 #endif
 };
 
diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index 4ab2fa0..23ae3e7 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -149,6 +149,12 @@ enum {
 
 #define NFL_FIELD_MAX (__NFL_FIELD_MAX - 1)
 
+/* Max length supported by kernel name strings only the first n characters
+ * will be used by the kernel API. This is to prevent arbitrarily long
+ * strings being passed from user space.
+ */
+#define NFL_MAX_NAME 80
+
 enum {
 	NFL_FIELD_ATTR_UNSPEC,
 	NFL_FIELD_ATTR_NAME,
@@ -354,6 +360,44 @@ enum {
 #define NFL_NFL_MAX (__NFL_NFL_MAX - 1)
 
 enum {
+	NFL_TABLE_FLOWS_UNSPEC,
+	NFL_TABLE_FLOWS_TABLE,
+	NFL_TABLE_FLOWS_MINPRIO,
+	NFL_TABLE_FLOWS_MAXPRIO,
+	NFL_TABLE_FLOWS_FLOWS,
+	__NFL_TABLE_FLOWS_MAX,
+};
+
+#define NFL_TABLE_FLOWS_MAX (__NFL_TABLE_FLOWS_MAX - 1)
+
+enum {
+	/* Abort with normal errmsg */
+	NFL_FLOWS_ERROR_ABORT,
+	/* Ignore errors and continue without logging */
+	NFL_FLOWS_ERROR_CONTINUE,
+	/* Abort and reply with invalid flow fields */
+	NFL_FLOWS_ERROR_ABORT_LOG,
+	/* Continue and reply with list of invalid flows */
+	NFL_FLOWS_ERROR_CONT_LOG,
+	__NFLS_FLOWS_ERROR_MAX,
+};
+
+#define NFLS_FLOWS_ERROR_MAX (__NFLS_FLOWS_ERROR_MAX - 1)
+
+enum {
+	NFL_ATTR_UNSPEC,
+	NFL_ATTR_ERROR,
+	NFL_ATTR_TABLE,
+	NFL_ATTR_UID,
+	NFL_ATTR_PRIORITY,
+	NFL_ATTR_MATCHES,
+	NFL_ATTR_ACTIONS,
+	__NFL_ATTR_MAX,
+};
+
+#define NFL_ATTR_MAX (__NFL_ATTR_MAX - 1)
+
+enum {
 	NFL_IDENTIFIER_UNSPEC,
 	NFL_IDENTIFIER_IFINDEX, /* net_device ifindex */
 };
@@ -369,6 +413,9 @@ enum {
 	NFL_HEADER_GRAPH,
 	NFL_TABLE_GRAPH,
 
+	NFL_FLOWS,
+	NFL_FLOWS_ERROR,
+
 	__NFL_MAX,
 	NFL_MAX = (__NFL_MAX - 1),
 };
@@ -380,6 +427,10 @@ enum {
 	NFL_TABLE_CMD_GET_HDR_GRAPH,
 	NFL_TABLE_CMD_GET_TABLE_GRAPH,
 
+	NFL_TABLE_CMD_GET_FLOWS,
+	NFL_TABLE_CMD_SET_FLOWS,
+	NFL_TABLE_CMD_DEL_FLOWS,
+
 	__NFL_CMD_MAX,
 	NFL_CMD_MAX = (__NFL_CMD_MAX - 1),
 };
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index ce673df..b6b1729 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -27,6 +27,18 @@
 #include <net/rtnetlink.h>
 #include <linux/module.h>
 
+static DEFINE_MUTEX(net_flow_mutex);
+
+void net_flow_lock(void)
+{
+	mutex_lock(&net_flow_mutex);
+}
+
+void net_flow_unlock(void)
+{
+	mutex_unlock(&net_flow_mutex);
+}
+
 static struct genl_family net_flow_nl_family = {
 	.id		= GENL_ID_GENERATE,
 	.name		= NFL_GENL_NAME,
@@ -78,6 +90,34 @@ static int net_flow_put_act_types(struct sk_buff *skb,
 		if (err)
 			goto out;
 
+		switch (args[i].type) {
+		case NFL_ACTION_ARG_TYPE_NULL:
+			err = 0;
+			break;
+		case NFL_ACTION_ARG_TYPE_U8:
+			err = nla_put_u8(skb, NFL_ACTION_ARG_VALUE,
+					 args[i].value_u8);
+			break;
+		case NFL_ACTION_ARG_TYPE_U16:
+			err = nla_put_u16(skb, NFL_ACTION_ARG_VALUE,
+					  args[i].value_u16);
+			break;
+		case NFL_ACTION_ARG_TYPE_U32:
+			err = nla_put_u32(skb, NFL_ACTION_ARG_VALUE,
+					  args[i].value_u32);
+			break;
+		case NFL_ACTION_ARG_TYPE_U64:
+			err = nla_put_u64(skb, NFL_ACTION_ARG_VALUE,
+					  args[i].value_u64);
+			break;
+		default:
+			err = -EINVAL;
+			break;
+		}
+
+		if (err)
+			goto out;
+
 		nla_nest_end(skb, arg);
 	}
 	return 0;
@@ -879,6 +919,708 @@ static int net_flow_cmd_get_table_graph(struct sk_buff *skb,
 	return genlmsg_reply(msg, info);
 }
 
+static int net_flow_put_flow_action(struct sk_buff *skb,
+				    struct net_flow_action *a)
+{
+	struct nlattr *action, *sigs;
+	int err = 0;
+
+	action = nla_nest_start(skb, NFL_ACTION);
+	if (!action)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, NFL_ACTION_ATTR_UID, a->uid))
+		return -EMSGSIZE;
+
+	if (!a->args)
+		goto done;
+
+	sigs = nla_nest_start(skb, NFL_ACTION_ATTR_SIGNATURE);
+	if (!sigs) {
+		nla_nest_cancel(skb, action);
+		return -EMSGSIZE;
+	}
+
+	err = net_flow_put_act_types(skb, a->args);
+	if (err) {
+		nla_nest_cancel(skb, action);
+		return err;
+	}
+	nla_nest_end(skb, sigs);
+done:
+	nla_nest_end(skb, action);
+	return 0;
+}
+
+static int net_flow_put_rule(struct sk_buff *skb, struct net_flow_rule *rule)
+{
+	struct nlattr *flows, *actions, *matches;
+	int j, i = 0;
+	int err = -EMSGSIZE;
+
+	flows = nla_nest_start(skb, NFL_FLOW);
+	if (!flows)
+		goto put_failure;
+
+	if (nla_put_u32(skb, NFL_ATTR_TABLE, rule->table_id) ||
+	    nla_put_u32(skb, NFL_ATTR_UID, rule->uid) ||
+	    nla_put_u32(skb, NFL_ATTR_PRIORITY, rule->priority))
+		goto flows_put_failure;
+
+	if (rule->matches) {
+		matches = nla_nest_start(skb, NFL_ATTR_MATCHES);
+		if (!matches)
+			goto flows_put_failure;
+
+		for (j = 0; rule->matches && rule->matches[j].header; j++) {
+			struct net_flow_field_ref *f = &rule->matches[j];
+			struct nlattr *field;
+
+			field = nla_nest_start(skb, NFL_FIELD_REF);
+			if (!field) {
+				err = -EMSGSIZE;
+				goto flows_put_failure;
+			}
+
+			err = net_flow_put_field_ref(skb, f);
+			if (err)
+				goto flows_put_failure;
+
+			err = net_flow_put_field_value(skb, f);
+			if (err)
+				goto flows_put_failure;
+
+			nla_nest_end(skb, field);
+		}
+		nla_nest_end(skb, matches);
+	}
+
+	if (rule->actions) {
+		actions = nla_nest_start(skb, NFL_ATTR_ACTIONS);
+		if (!actions)
+			goto flows_put_failure;
+
+		for (i = 0; rule->actions && rule->actions[i].uid; i++) {
+			err = net_flow_put_flow_action(skb, &rule->actions[i]);
+			if (err)
+				goto flows_put_failure;
+		}
+		nla_nest_end(skb, actions);
+	}
+
+	nla_nest_end(skb, flows);
+	return 0;
+
+flows_put_failure:
+	nla_nest_cancel(skb, flows);
+put_failure:
+	return err;
+}
+
+static struct sk_buff *net_flow_build_flows_msg(struct net_device *dev,
+						u32 portid, int seq, u8 cmd,
+						int min, int max, int table)
+{
+	struct genlmsghdr *hdr;
+	struct nlattr *flows;
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-ENOBUFS);
+
+	hdr = genlmsg_put(skb, portid, seq, &net_flow_nl_family, 0, cmd);
+	if (!hdr)
+		goto out;
+
+	if (nla_put_u32(skb,
+			NFL_IDENTIFIER_TYPE,
+			NFL_IDENTIFIER_IFINDEX) ||
+	    nla_put_u32(skb, NFL_IDENTIFIER, dev->ifindex)) {
+		err = -ENOBUFS;
+		goto out;
+	}
+
+	flows = nla_nest_start(skb, NFL_FLOWS);
+	if (!flows) {
+		err = -EMSGSIZE;
+		goto out;
+	}
+
+	err = -EOPNOTSUPP;
+	if (err < 0)
+		goto out_cancel;
+
+	nla_nest_end(skb, flows);
+
+	err = genlmsg_end(skb, hdr);
+	if (err < 0)
+		goto out;
+
+	return skb;
+out_cancel:
+	nla_nest_cancel(skb, flows);
+out:
+	nlmsg_free(skb);
+	return ERR_PTR(err);
+}
+
+static const
+struct nla_policy net_flow_table_flows_policy[NFL_TABLE_FLOWS_MAX + 1] = {
+	[NFL_TABLE_FLOWS_TABLE]   = { .type = NLA_U32,},
+	[NFL_TABLE_FLOWS_MINPRIO] = { .type = NLA_U32,},
+	[NFL_TABLE_FLOWS_MAXPRIO] = { .type = NLA_U32,},
+	[NFL_TABLE_FLOWS_FLOWS]   = { .type = NLA_NESTED,},
+};
+
+static int net_flow_table_cmd_get_flows(struct sk_buff *skb,
+					struct genl_info *info)
+{
+	struct nlattr *tb[NFL_TABLE_FLOWS_MAX+1];
+	int table, min = -1, max = -1;
+	struct net_device *dev;
+	struct sk_buff *msg;
+	int err = -EINVAL;
+
+	dev = net_flow_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	if (!info->attrs[NFL_IDENTIFIER_TYPE] ||
+	    !info->attrs[NFL_IDENTIFIER] ||
+	    !info->attrs[NFL_FLOWS])
+		goto out;
+
+	err = nla_parse_nested(tb, NFL_TABLE_FLOWS_MAX,
+			       info->attrs[NFL_FLOWS],
+			       net_flow_table_flows_policy);
+	if (err)
+		goto out;
+
+	if (!tb[NFL_TABLE_FLOWS_TABLE])
+		goto out;
+
+	table = nla_get_u32(tb[NFL_TABLE_FLOWS_TABLE]);
+
+	if (tb[NFL_TABLE_FLOWS_MINPRIO])
+		min = nla_get_u32(tb[NFL_TABLE_FLOWS_MINPRIO]);
+	if (tb[NFL_TABLE_FLOWS_MAXPRIO])
+		max = nla_get_u32(tb[NFL_TABLE_FLOWS_MAXPRIO]);
+
+	msg = net_flow_build_flows_msg(dev,
+				       info->snd_portid,
+				       info->snd_seq,
+				       NFL_TABLE_CMD_GET_FLOWS,
+				       min, max, table);
+	dev_put(dev);
+
+	if (IS_ERR(msg))
+		return PTR_ERR(msg);
+
+	return genlmsg_reply(msg, info);
+out:
+	dev_put(dev);
+	return err;
+}
+
+static struct sk_buff *net_flow_start_errmsg(struct net_device *dev,
+					     struct genlmsghdr **hdr,
+					     u32 portid, int seq, u8 cmd)
+{
+	struct genlmsghdr *h;
+	struct sk_buff *skb;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-EMSGSIZE);
+
+	h = genlmsg_put(skb, portid, seq, &net_flow_nl_family, 0, cmd);
+	if (!h)
+		return ERR_PTR(-EMSGSIZE);
+
+	if (nla_put_u32(skb,
+			NFL_IDENTIFIER_TYPE,
+			NFL_IDENTIFIER_IFINDEX) ||
+	    nla_put_u32(skb, NFL_IDENTIFIER, dev->ifindex))
+		return ERR_PTR(-EMSGSIZE);
+
+	*hdr = h;
+	return skb;
+}
+
+static struct sk_buff *net_flow_end_flow_errmsg(struct sk_buff *skb,
+						struct genlmsghdr *hdr)
+{
+	int err;
+
+	err = genlmsg_end(skb, hdr);
+	if (err < 0) {
+		nlmsg_free(skb);
+		return ERR_PTR(err);
+	}
+
+	return skb;
+}
+
+const struct nla_policy net_flow_field_policy[NFL_FIELD_REF_MAX + 1] = {
+	[NFL_FIELD_REF_NEXT_NODE] = { .type = NLA_U32,},
+	[NFL_FIELD_REF_INSTANCE]  = { .type = NLA_U32,},
+	[NFL_FIELD_REF_HEADER]	  = { .type = NLA_U32,},
+	[NFL_FIELD_REF_FIELD]	  = { .type = NLA_U32,},
+	[NFL_FIELD_REF_MASK_TYPE] = { .type = NLA_U32,},
+	[NFL_FIELD_REF_TYPE]	  = { .type = NLA_U32,},
+	[NFL_FIELD_REF_VALUE]	  = { .type = NLA_BINARY,
+				      .len = sizeof(u64)},
+	[NFL_FIELD_REF_MASK]	  = { .type = NLA_BINARY,
+				      .len = sizeof(u64)},
+};
+
+static int net_flow_get_field(struct net_flow_field_ref *field,
+			      struct nlattr *nla)
+{
+	struct nlattr *ref[NFL_FIELD_REF_MAX+1];
+	int err;
+
+	err = nla_parse_nested(ref, NFL_FIELD_REF_MAX,
+			       nla, net_flow_field_policy);
+	if (err)
+		return err;
+
+	if (!ref[NFL_FIELD_REF_INSTANCE] ||
+	    !ref[NFL_FIELD_REF_HEADER] ||
+	    !ref[NFL_FIELD_REF_FIELD] ||
+	    !ref[NFL_FIELD_REF_MASK_TYPE] ||
+	    !ref[NFL_FIELD_REF_TYPE])
+		return -EINVAL;
+
+	field->instance = nla_get_u32(ref[NFL_FIELD_REF_INSTANCE]);
+	field->header = nla_get_u32(ref[NFL_FIELD_REF_HEADER]);
+	field->field = nla_get_u32(ref[NFL_FIELD_REF_FIELD]);
+	field->mask_type = nla_get_u32(ref[NFL_FIELD_REF_MASK_TYPE]);
+	field->type = nla_get_u32(ref[NFL_FIELD_REF_TYPE]);
+
+	if (!ref[NFL_FIELD_REF_VALUE])
+		return 0;
+
+	switch (field->type) {
+	case NFL_FIELD_REF_ATTR_TYPE_U8:
+		if (nla_len(ref[NFL_FIELD_REF_VALUE]) < sizeof(u8)) {
+			err = -EINVAL;
+			break;
+		}
+		field->value_u8 = nla_get_u8(ref[NFL_FIELD_REF_VALUE]);
+
+		if (!ref[NFL_FIELD_REF_MASK])
+			break;
+
+		if (nla_len(ref[NFL_FIELD_REF_MASK]) < sizeof(u8)) {
+			err = -EINVAL;
+			break;
+		}
+		field->mask_u8 = nla_get_u8(ref[NFL_FIELD_REF_MASK]);
+		break;
+	case NFL_FIELD_REF_ATTR_TYPE_U16:
+		if (nla_len(ref[NFL_FIELD_REF_VALUE]) < sizeof(u16)) {
+			err = -EINVAL;
+			break;
+		}
+		field->value_u16 = nla_get_u16(ref[NFL_FIELD_REF_VALUE]);
+
+		if (!ref[NFL_FIELD_REF_MASK])
+			break;
+
+		if (nla_len(ref[NFL_FIELD_REF_MASK]) < sizeof(u16)) {
+			err = -EINVAL;
+			break;
+		}
+		field->mask_u16 = nla_get_u16(ref[NFL_FIELD_REF_MASK]);
+		break;
+	case NFL_FIELD_REF_ATTR_TYPE_U32:
+		if (nla_len(ref[NFL_FIELD_REF_VALUE]) < sizeof(u32)) {
+			err = -EINVAL;
+			break;
+		}
+		field->value_u32 = nla_get_u32(ref[NFL_FIELD_REF_VALUE]);
+
+		if (!ref[NFL_FIELD_REF_MASK])
+			break;
+
+		if (nla_len(ref[NFL_FIELD_REF_MASK]) < sizeof(u32)) {
+			err = -EINVAL;
+			break;
+		}
+		field->mask_u32 = nla_get_u32(ref[NFL_FIELD_REF_MASK]);
+		break;
+	case NFL_FIELD_REF_ATTR_TYPE_U64:
+		if (nla_len(ref[NFL_FIELD_REF_VALUE]) < sizeof(u64)) {
+			err = -EINVAL;
+			break;
+		}
+		field->value_u64 = nla_get_u64(ref[NFL_FIELD_REF_VALUE]);
+
+		if (!ref[NFL_FIELD_REF_MASK])
+			break;
+
+		if (nla_len(ref[NFL_FIELD_REF_MASK]) < sizeof(u64)) {
+			err = -EINVAL;
+			break;
+		}
+		field->mask_u64 = nla_get_u64(ref[NFL_FIELD_REF_MASK]);
+		break;
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+	return err;
+}
+
+static void net_flow_free_actions(struct net_flow_action *actions)
+{
+	int i;
+
+	if (!actions)
+		return;
+
+	for (i = 0; actions[i].args; i++) {
+		kfree(actions[i].args->name);
+		kfree(actions[i].args);
+	}
+	kfree(actions);
+}
+
+static void net_flow_rule_free(struct net_flow_rule *rule)
+{
+	if (!rule)
+		return;
+
+	kfree(rule->matches);
+	net_flow_free_actions(rule->actions);
+	kfree(rule);
+}
+
+static const
+struct nla_policy net_flow_actarg_policy[NFL_ACTION_ARG_MAX + 1] = {
+	[NFL_ACTION_ARG_NAME]  = { .type = NLA_STRING },
+	[NFL_ACTION_ARG_TYPE]  = { .type = NLA_U32 },
+	[NFL_ACTION_ARG_VALUE] = { .type = NLA_BINARY, .len = sizeof(u64)},
+};
+
+static int net_flow_get_actarg(struct net_flow_action_arg *arg,
+			       struct nlattr *attr)
+{
+	struct nlattr *r[NFL_ACTION_ARG_MAX+1];
+	int err;
+
+	err = nla_parse_nested(r, NFL_ACTION_ARG_MAX,
+			       attr, net_flow_actarg_policy);
+	if (err)
+		return err;
+
+	if (!r[NFL_ACTION_ARG_TYPE] ||
+	    !r[NFL_ACTION_ARG_VALUE])
+		return -EINVAL;
+
+	arg->type = nla_get_u32(r[NFL_ACTION_ARG_TYPE]);
+	switch (arg->type) {
+	case NFL_ACTION_ARG_TYPE_U8:
+		if (nla_len(r[NFL_ACTION_ARG_VALUE]) < sizeof(u8))
+			return -EINVAL;
+		arg->value_u8 = nla_get_u8(r[NFL_ACTION_ARG_VALUE]);
+		break;
+	case NFL_ACTION_ARG_TYPE_U16:
+		if (nla_len(r[NFL_ACTION_ARG_VALUE]) < sizeof(u16))
+			return -EINVAL;
+		arg->value_u16 = nla_get_u16(r[NFL_ACTION_ARG_VALUE]);
+		break;
+	case NFL_ACTION_ARG_TYPE_U32:
+		if (nla_len(r[NFL_ACTION_ARG_VALUE]) < sizeof(u32))
+			return -EINVAL;
+		arg->value_u32 = nla_get_u32(r[NFL_ACTION_ARG_VALUE]);
+		break;
+	case NFL_ACTION_ARG_TYPE_U64:
+		if (nla_len(r[NFL_ACTION_ARG_VALUE]) < sizeof(u64))
+			return -EINVAL;
+		arg->value_u64 = nla_get_u64(r[NFL_ACTION_ARG_VALUE]);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (r[NFL_ACTION_ARG_NAME]) {
+		int max = nla_len(r[NFL_ACTION_ARG_NAME]);
+
+		if (max > NFL_MAX_NAME)
+			max = NFL_MAX_NAME;
+
+		arg->name = kzalloc(max, GFP_KERNEL);
+		if (!arg->name)
+			return -ENOMEM;
+		nla_strlcpy(arg->name, r[NFL_ACTION_ARG_NAME], max);
+	}
+
+	return 0;
+}
+
+static int net_flow_get_action(struct net_flow_action *a, struct nlattr *attr)
+{
+	struct nlattr *act[NFL_ACTION_ATTR_MAX+1];
+	struct nlattr *args;
+	int rem;
+	int err, count = 0;
+
+	if (nla_type(attr) != NFL_ACTION) {
+		pr_warn("%s: expected NFL_ACTION\n", __func__);
+		return 0;
+	}
+
+	err = nla_parse_nested(act, NFL_ACTION_ATTR_MAX,
+			       attr, net_flow_action_policy);
+	if (err < 0)
+		return err;
+
+	if (!act[NFL_ACTION_ATTR_UID])
+		return -EINVAL;
+
+	a->uid = nla_get_u32(act[NFL_ACTION_ATTR_UID]);
+
+	/* Only need to parse signature if it is provided otherwise assume
+	 * action does not need any arguments
+	 */
+	if (!act[NFL_ACTION_ATTR_SIGNATURE])
+		return 0;
+
+	nla_for_each_nested(args, act[NFL_ACTION_ATTR_SIGNATURE], rem)
+		count++;
+
+	a->args = kcalloc(count + 1,
+			  sizeof(struct net_flow_action_arg),
+			  GFP_KERNEL);
+	count = 0;
+
+	nla_for_each_nested(args, act[NFL_ACTION_ATTR_SIGNATURE], rem) {
+		if (nla_type(args) != NFL_ACTION_ARG)
+			continue;
+
+		err = net_flow_get_actarg(&a->args[count], args);
+		if (err) {
+			kfree(a->args);
+			a->args = NULL;
+			return err;
+		}
+		count++;
+	}
+	return 0;
+}
+
+static const
+struct nla_policy net_flow_rule_policy[NFL_ATTR_MAX + 1] = {
+	[NFL_ATTR_TABLE]	= { .type = NLA_U32 },
+	[NFL_ATTR_UID]		= { .type = NLA_U32 },
+	[NFL_ATTR_PRIORITY]	= { .type = NLA_U32 },
+	[NFL_ATTR_MATCHES]	= { .type = NLA_NESTED },
+	[NFL_ATTR_ACTIONS]	= { .type = NLA_NESTED },
+};
+
+static int net_flow_get_rule(struct net_flow_rule *rule, struct nlattr *attr)
+{
+	struct nlattr *f[NFL_ATTR_MAX+1];
+	struct nlattr *match, *act;
+	int rem, err;
+	int count = 0;
+
+	err = nla_parse_nested(f, NFL_ATTR_MAX,
+			       attr, net_flow_rule_policy);
+	if (err < 0)
+		return -EINVAL;
+
+	if (!f[NFL_ATTR_TABLE] || !f[NFL_ATTR_UID] ||
+	    !f[NFL_ATTR_PRIORITY])
+		return -EINVAL;
+
+	rule->table_id = nla_get_u32(f[NFL_ATTR_TABLE]);
+	rule->uid = nla_get_u32(f[NFL_ATTR_UID]);
+	rule->priority = nla_get_u32(f[NFL_ATTR_PRIORITY]);
+
+	rule->matches = NULL;
+	rule->actions = NULL;
+
+	if (f[NFL_ATTR_MATCHES]) {
+		nla_for_each_nested(match, f[NFL_ATTR_MATCHES], rem) {
+			if (nla_type(match) == NFL_FIELD_REF)
+				count++;
+		}
+
+		/* Null terminated list of matches */
+		rule->matches = kcalloc(count + 1,
+					sizeof(struct net_flow_field_ref),
+					GFP_KERNEL);
+		if (!rule->matches)
+			return -ENOMEM;
+
+		count = 0;
+		nla_for_each_nested(match, f[NFL_ATTR_MATCHES], rem) {
+			err = net_flow_get_field(&rule->matches[count], match);
+			if (err) {
+				kfree(rule->matches);
+				rule->matches = NULL;
+				return err;
+			}
+			count++;
+		}
+	}
+
+	if (f[NFL_ATTR_ACTIONS]) {
+		count = 0;
+		nla_for_each_nested(act, f[NFL_ATTR_ACTIONS], rem) {
+			if (nla_type(act) == NFL_ACTION)
+				count++;
+		}
+
+		/* Null terminated list of actions */
+		rule->actions = kcalloc(count + 1,
+					sizeof(struct net_flow_action),
+					GFP_KERNEL);
+		if (!rule->actions) {
+			kfree(rule->matches);
+			rule->matches = NULL;
+			return -ENOMEM;
+		}
+
+		count = 0;
+		nla_for_each_nested(act, f[NFL_ATTR_ACTIONS], rem) {
+			err = net_flow_get_action(&rule->actions[count], act);
+			if (err) {
+				kfree(rule->matches);
+				rule->matches = NULL;
+				net_flow_free_actions(rule->actions);
+				rule->actions = NULL;
+				return err;
+			}
+			count++;
+		}
+	}
+
+	return 0;
+}
+
+static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
+				    struct genl_info *info)
+{
+	int rem, err_handle = NFL_FLOWS_ERROR_ABORT;
+	struct net_flow_rule *this = NULL;
+	struct sk_buff *skb = NULL;
+	struct genlmsghdr *hdr;
+	struct net_device *dev;
+	struct nlattr *flow, *flows;
+	int cmd = info->genlhdr->cmd;
+	int err = -EOPNOTSUPP;
+
+	dev = net_flow_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	switch (cmd) {
+	case NFL_TABLE_CMD_SET_FLOWS:
+		if (!dev->netdev_ops->ndo_flow_set_rule)
+			goto out;
+		break;
+	case NFL_TABLE_CMD_DEL_FLOWS:
+		if (!dev->netdev_ops->ndo_flow_del_rule)
+			goto out;
+		break;
+	default:
+		goto out;
+	}
+
+	if (!info->attrs[NFL_IDENTIFIER_TYPE] ||
+	    !info->attrs[NFL_IDENTIFIER] ||
+	    !info->attrs[NFL_FLOWS]) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	if (info->attrs[NFL_FLOWS_ERROR])
+		err_handle = nla_get_u32(info->attrs[NFL_FLOWS_ERROR]);
+
+	net_flow_lock();
+	nla_for_each_nested(flow, info->attrs[NFL_FLOWS], rem) {
+		if (nla_type(flow) != NFL_FLOW)
+			continue;
+
+		this = kzalloc(sizeof(*this), GFP_KERNEL);
+		if (!this) {
+			err = -ENOMEM;
+			goto skip;
+		}
+
+		/* If userspace is passing invalid messages so that we can not
+		 * even build correct flow structures abort with an error. And
+		 * do not try to proceed regardless of error structure.
+		 */
+		err = net_flow_get_rule(this, flow);
+		if (err)
+			goto out_locked;
+
+		switch (cmd) {
+		case NFL_TABLE_CMD_SET_FLOWS:
+			err = dev->netdev_ops->ndo_flow_set_rule(dev, this);
+			break;
+		case NFL_TABLE_CMD_DEL_FLOWS:
+			err = dev->netdev_ops->ndo_flow_del_rule(dev, this);
+			break;
+		default:
+			err = -EOPNOTSUPP;
+			break;
+		}
+
+skip:
+		if (err && err_handle != NFL_FLOWS_ERROR_CONTINUE) {
+			if (!skb) {
+				skb = net_flow_start_errmsg(dev, &hdr,
+							    info->snd_portid,
+							    info->snd_seq,
+							    cmd);
+				if (IS_ERR(skb)) {
+					err = PTR_ERR(skb);
+					goto out_locked;
+				}
+
+				flows = nla_nest_start(skb, NFL_FLOWS);
+				if (!flows) {
+					err = -EMSGSIZE;
+					goto out_locked;
+				}
+			}
+
+			net_flow_put_rule(skb, this);
+		}
+
+		net_flow_rule_free(this);
+
+		if (err && err_handle == NFL_FLOWS_ERROR_ABORT)
+			goto out_locked;
+	}
+	net_flow_unlock();
+	dev_put(dev);
+
+	if (skb) {
+		nla_nest_end(skb, flows);
+		net_flow_end_flow_errmsg(skb, hdr);
+		return genlmsg_reply(skb, info);
+	}
+	return 0;
+
+out_locked:
+	net_flow_unlock();
+out:
+	net_flow_rule_free(this);
+	nlmsg_free(skb);
+	dev_put(dev);
+	return err;
+}
+
 static const struct nla_policy net_flow_cmd_policy[NFL_MAX + 1] = {
 	[NFL_IDENTIFIER_TYPE]	= {.type = NLA_U32, },
 	[NFL_IDENTIFIER]	= {.type = NLA_U32, },
@@ -920,6 +1662,24 @@ static const struct genl_ops net_flow_table_nl_ops[] = {
 		.policy = net_flow_cmd_policy,
 		.flags = GENL_ADMIN_PERM,
 	},
+	{
+		.cmd = NFL_TABLE_CMD_GET_FLOWS,
+		.doit = net_flow_table_cmd_get_flows,
+		.policy = net_flow_cmd_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NFL_TABLE_CMD_SET_FLOWS,
+		.doit = net_flow_table_cmd_flows,
+		.policy = net_flow_cmd_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NFL_TABLE_CMD_DEL_FLOWS,
+		.doit = net_flow_table_cmd_flows,
+		.policy = net_flow_cmd_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
 };
 
 static int __init net_flow_nl_module_init(void)
