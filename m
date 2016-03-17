From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 02/13] devlink: add shared buffer configuration
Date: Thu, 17 Mar 2016 18:13:42 +0100
Message-ID: <1458234833-25836-3-git-send-email-jiri@resnulli.us>
References: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36283 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031746AbcCQRN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 13:13:59 -0400
Received: by mail-wm0-f68.google.com with SMTP id l68so432248wml.3
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 10:13:58 -0700 (PDT)
In-Reply-To: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Define userspace API and drivers API for configuration of shared
buffers. Four basic objects are defined:
shared buffer - attributes are size, number of pools and TCs
pool - chunk of sharedbuffer definition, it has some size and either
       static or dynamic threshold
port pool threshold - to set per-port threshold for each pool
port tc threshold bind - to bind port and TC to specified pool with threshold.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/devlink.h        |  46 +++
 include/uapi/linux/devlink.h |  41 ++
 net/core/devlink.c           | 911 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 998 insertions(+)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index c37d257..343d8cf 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -24,6 +24,7 @@ struct devlink_ops;
 struct devlink {
 	struct list_head list;
 	struct list_head port_list;
+	struct list_head sb_list;
 	const struct devlink_ops *ops;
 	struct device *dev;
 	possible_net_t _net;
@@ -42,6 +43,12 @@ struct devlink_port {
 	u32 split_group;
 };
 
+struct devlink_sb_pool_info {
+	enum devlink_sb_pool_type pool_type;
+	u32 size;
+	enum devlink_sb_threshold_type threshold_type;
+};
+
 struct devlink_ops {
 	size_t priv_size;
 	int (*port_type_set)(struct devlink_port *devlink_port,
@@ -49,6 +56,28 @@ struct devlink_ops {
 	int (*port_split)(struct devlink *devlink, unsigned int port_index,
 			  unsigned int count);
 	int (*port_unsplit)(struct devlink *devlink, unsigned int port_index);
+	int (*sb_pool_get)(struct devlink *devlink, unsigned int sb_index,
+			   u16 pool_index,
+			   struct devlink_sb_pool_info *pool_info);
+	int (*sb_pool_set)(struct devlink *devlink, unsigned int sb_index,
+			   u16 pool_index, u32 size,
+			   enum devlink_sb_threshold_type threshold_type);
+	int (*sb_port_pool_get)(struct devlink_port *devlink_port,
+				unsigned int sb_index, u16 pool_index,
+				u32 *p_threshold);
+	int (*sb_port_pool_set)(struct devlink_port *devlink_port,
+				unsigned int sb_index, u16 pool_index,
+				u32 threshold);
+	int (*sb_tc_pool_bind_get)(struct devlink_port *devlink_port,
+				   unsigned int sb_index,
+				   u16 tc_index,
+				   enum devlink_sb_pool_type pool_type,
+				   u16 *p_pool_index, u32 *p_threshold);
+	int (*sb_tc_pool_bind_set)(struct devlink_port *devlink_port,
+				   unsigned int sb_index,
+				   u16 tc_index,
+				   enum devlink_sb_pool_type pool_type,
+				   u16 pool_index, u32 threshold);
 };
 
 static inline void *devlink_priv(struct devlink *devlink)
@@ -82,6 +111,10 @@ void devlink_port_type_ib_set(struct devlink_port *devlink_port,
 void devlink_port_type_clear(struct devlink_port *devlink_port);
 void devlink_port_split_set(struct devlink_port *devlink_port,
 			    u32 split_group);
+int devlink_sb_register(struct devlink *devlink, unsigned int sb_index,
+			u32 size, u16 ingress_pools_count,
+			u16 egress_pools_count, u16 tc_count);
+void devlink_sb_unregister(struct devlink *devlink, unsigned int sb_index);
 
 #else
 
@@ -135,6 +168,19 @@ static inline void devlink_port_split_set(struct devlink_port *devlink_port,
 {
 }
 
+static inline int devlink_sb_register(struct devlink *devlink,
+				      unsigned int sb_index, u32 size,
+				      u16 ingress_pools_count,
+				      u16 egress_pools_count, u16 tc_count)
+{
+	return 0;
+}
+
+static inline void devlink_sb_unregister(struct devlink *devlink,
+					 unsigned int sb_index)
+{
+}
+
 #endif
 
 #endif /* _NET_DEVLINK_H_ */
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index c9fee57..9bf34c7 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -33,6 +33,26 @@ enum devlink_command {
 	DEVLINK_CMD_PORT_SPLIT,
 	DEVLINK_CMD_PORT_UNSPLIT,
 
+	DEVLINK_CMD_SB_GET,		/* can dump */
+	DEVLINK_CMD_SB_SET,
+	DEVLINK_CMD_SB_NEW,
+	DEVLINK_CMD_SB_DEL,
+
+	DEVLINK_CMD_SB_POOL_GET,	/* can dump */
+	DEVLINK_CMD_SB_POOL_SET,
+	DEVLINK_CMD_SB_POOL_NEW,
+	DEVLINK_CMD_SB_POOL_DEL,
+
+	DEVLINK_CMD_SB_PORT_POOL_GET,	/* can dump */
+	DEVLINK_CMD_SB_PORT_POOL_SET,
+	DEVLINK_CMD_SB_PORT_POOL_NEW,
+	DEVLINK_CMD_SB_PORT_POOL_DEL,
+
+	DEVLINK_CMD_SB_TC_POOL_BIND_GET,	/* can dump */
+	DEVLINK_CMD_SB_TC_POOL_BIND_SET,
+	DEVLINK_CMD_SB_TC_POOL_BIND_NEW,
+	DEVLINK_CMD_SB_TC_POOL_BIND_DEL,
+
 	/* add new commands above here */
 
 	__DEVLINK_CMD_MAX,
@@ -46,6 +66,16 @@ enum devlink_port_type {
 	DEVLINK_PORT_TYPE_IB,
 };
 
+enum devlink_sb_pool_type {
+	DEVLINK_SB_POOL_TYPE_INGRESS,
+	DEVLINK_SB_POOL_TYPE_EGRESS,
+};
+
+enum devlink_sb_threshold_type {
+	DEVLINK_SB_THRESHOLD_TYPE_STATIC,
+	DEVLINK_SB_THRESHOLD_TYPE_DYNAMIC,
+};
+
 enum devlink_attr {
 	/* don't change the order or add anything between, this is ABI! */
 	DEVLINK_ATTR_UNSPEC,
@@ -62,6 +92,17 @@ enum devlink_attr {
 	DEVLINK_ATTR_PORT_IBDEV_NAME,		/* string */
 	DEVLINK_ATTR_PORT_SPLIT_COUNT,		/* u32 */
 	DEVLINK_ATTR_PORT_SPLIT_GROUP,		/* u32 */
+	DEVLINK_ATTR_SB_INDEX,			/* u32 */
+	DEVLINK_ATTR_SB_SIZE,			/* u32 */
+	DEVLINK_ATTR_SB_INGRESS_POOLS_COUNT,	/* u16 */
+	DEVLINK_ATTR_SB_EGRESS_POOLS_COUNT,	/* u16 */
+	DEVLINK_ATTR_SB_TC_COUNT,		/* u16 */
+	DEVLINK_ATTR_SB_POOL_INDEX,		/* u16 */
+	DEVLINK_ATTR_SB_POOL_TYPE,		/* u8 */
+	DEVLINK_ATTR_SB_POOL_SIZE,		/* u32 */
+	DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE,	/* u8 */
+	DEVLINK_ATTR_SB_THRESHOLD,		/* u32 */
+	DEVLINK_ATTR_SB_TC_INDEX,		/* u16 */
 
 	/* add new attributes above here, update the policy in devlink.c */
 
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 5f1cdf9..3cf01e5 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -119,8 +119,158 @@ static struct devlink_port *devlink_port_get_from_info(struct devlink *devlink,
 	return devlink_port_get_from_attrs(devlink, info->attrs);
 }
 
+struct devlink_sb {
+	struct list_head list;
+	unsigned int index;
+	u32 size;
+	u16 ingress_pools_count;
+	u16 egress_pools_count;
+	u16 tc_count;
+};
+
+static u16 devlink_sb_pool_count(struct devlink_sb *devlink_sb)
+{
+	return devlink_sb->ingress_pools_count + devlink_sb->egress_pools_count;
+}
+
+static struct devlink_sb *devlink_sb_get_by_index(struct devlink *devlink,
+						  unsigned sb_index)
+{
+	struct devlink_sb *devlink_sb;
+
+	list_for_each_entry(devlink_sb, &devlink->sb_list, list) {
+		if (devlink_sb->index == sb_index)
+			return devlink_sb;
+	}
+	return NULL;
+}
+
+static bool devlink_sb_index_exists(struct devlink *devlink,
+				    unsigned int sb_index)
+{
+	return devlink_sb_get_by_index(devlink, sb_index);
+}
+
+static struct devlink_sb *devlink_sb_get_from_attrs(struct devlink *devlink,
+						    struct nlattr **attrs)
+{
+	if (attrs[DEVLINK_ATTR_SB_INDEX]) {
+		u32 sb_index = nla_get_u32(attrs[DEVLINK_ATTR_SB_INDEX]);
+		struct devlink_sb *devlink_sb;
+
+		devlink_sb = devlink_sb_get_by_index(devlink, sb_index);
+		if (!devlink_sb)
+			return ERR_PTR(-ENODEV);
+		return devlink_sb;
+	}
+	return ERR_PTR(-EINVAL);
+}
+
+static struct devlink_sb *devlink_sb_get_from_info(struct devlink *devlink,
+						   struct genl_info *info)
+{
+	return devlink_sb_get_from_attrs(devlink, info->attrs);
+}
+
+static int devlink_sb_pool_index_get_from_attrs(struct devlink_sb *devlink_sb,
+						struct nlattr **attrs,
+						u16 *p_pool_index)
+{
+	u16 val;
+
+	if (!attrs[DEVLINK_ATTR_SB_POOL_INDEX])
+		return -EINVAL;
+
+	val = nla_get_u16(attrs[DEVLINK_ATTR_SB_POOL_INDEX]);
+	if (val >= devlink_sb_pool_count(devlink_sb))
+		return -EINVAL;
+	*p_pool_index = val;
+	return 0;
+}
+
+static int devlink_sb_pool_index_get_from_info(struct devlink_sb *devlink_sb,
+					       struct genl_info *info,
+					       u16 *p_pool_index)
+{
+	return devlink_sb_pool_index_get_from_attrs(devlink_sb, info->attrs,
+						    p_pool_index);
+}
+
+static int
+devlink_sb_pool_type_get_from_attrs(struct nlattr **attrs,
+				    enum devlink_sb_pool_type *p_pool_type)
+{
+	u8 val;
+
+	if (!attrs[DEVLINK_ATTR_SB_POOL_TYPE])
+		return -EINVAL;
+
+	val = nla_get_u8(attrs[DEVLINK_ATTR_SB_POOL_TYPE]);
+	if (val != DEVLINK_SB_POOL_TYPE_INGRESS &&
+	    val != DEVLINK_SB_POOL_TYPE_EGRESS)
+		return -EINVAL;
+	*p_pool_type = val;
+	return 0;
+}
+
+static int
+devlink_sb_pool_type_get_from_info(struct genl_info *info,
+				   enum devlink_sb_pool_type *p_pool_type)
+{
+	return devlink_sb_pool_type_get_from_attrs(info->attrs, p_pool_type);
+}
+
+static int
+devlink_sb_th_type_get_from_attrs(struct nlattr **attrs,
+				  enum devlink_sb_threshold_type *p_th_type)
+{
+	u8 val;
+
+	if (!attrs[DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE])
+		return -EINVAL;
+
+	val = nla_get_u8(attrs[DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE]);
+	if (val != DEVLINK_SB_THRESHOLD_TYPE_STATIC &&
+	    val != DEVLINK_SB_THRESHOLD_TYPE_DYNAMIC)
+		return -EINVAL;
+	*p_th_type = val;
+	return 0;
+}
+
+static int
+devlink_sb_th_type_get_from_info(struct genl_info *info,
+				 enum devlink_sb_threshold_type *p_th_type)
+{
+	return devlink_sb_th_type_get_from_attrs(info->attrs, p_th_type);
+}
+
+static int devlink_sb_tc_index_get_from_attrs(struct devlink_sb *devlink_sb,
+					      struct nlattr **attrs,
+					      u16 *p_tc_index)
+{
+	u16 val;
+
+	if (!attrs[DEVLINK_ATTR_SB_TC_INDEX])
+		return -EINVAL;
+
+	val = nla_get_u16(attrs[DEVLINK_ATTR_SB_TC_INDEX]);
+	if (val >= devlink_sb->tc_count)
+		return -EINVAL;
+	*p_tc_index = val;
+	return 0;
+}
+
+static int devlink_sb_tc_index_get_from_info(struct devlink_sb *devlink_sb,
+					     struct genl_info *info,
+					     u16 *p_tc_index)
+{
+	return devlink_sb_tc_index_get_from_attrs(devlink_sb, info->attrs,
+						  p_tc_index);
+}
+
 #define DEVLINK_NL_FLAG_NEED_DEVLINK	BIT(0)
 #define DEVLINK_NL_FLAG_NEED_PORT	BIT(1)
+#define DEVLINK_NL_FLAG_NEED_SB		BIT(2)
 
 static int devlink_nl_pre_doit(const struct genl_ops *ops,
 			       struct sk_buff *skb, struct genl_info *info)
@@ -147,6 +297,18 @@ static int devlink_nl_pre_doit(const struct genl_ops *ops,
 		}
 		info->user_ptr[0] = devlink_port;
 	}
+	if (ops->internal_flags & DEVLINK_NL_FLAG_NEED_SB) {
+		struct devlink_sb *devlink_sb;
+
+		devlink_sb = devlink_sb_get_from_info(devlink, info);
+		if (IS_ERR(devlink_sb)) {
+			if (ops->internal_flags & DEVLINK_NL_FLAG_NEED_PORT)
+				mutex_unlock(&devlink_port_mutex);
+			mutex_unlock(&devlink_mutex);
+			return PTR_ERR(devlink_sb);
+		}
+		info->user_ptr[1] = devlink_sb;
+	}
 	return 0;
 }
 
@@ -499,12 +661,657 @@ static int devlink_nl_cmd_port_unsplit_doit(struct sk_buff *skb,
 	return devlink_port_unsplit(devlink, port_index);
 }
 
+static int devlink_nl_sb_fill(struct sk_buff *msg, struct devlink *devlink,
+			      struct devlink_sb *devlink_sb,
+			      enum devlink_command cmd, u32 portid,
+			      u32 seq, int flags)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(msg, portid, seq, &devlink_nl_family, flags, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (devlink_nl_put_handle(msg, devlink))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_SB_INDEX, devlink_sb->index))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_SB_SIZE, devlink_sb->size))
+		goto nla_put_failure;
+	if (nla_put_u16(msg, DEVLINK_ATTR_SB_INGRESS_POOLS_COUNT,
+			devlink_sb->ingress_pools_count))
+		goto nla_put_failure;
+	if (nla_put_u16(msg, DEVLINK_ATTR_SB_EGRESS_POOLS_COUNT,
+			devlink_sb->egress_pools_count))
+		goto nla_put_failure;
+	if (nla_put_u16(msg, DEVLINK_ATTR_SB_TC_COUNT,
+			devlink_sb->tc_count))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static int devlink_nl_cmd_sb_get_doit(struct sk_buff *skb,
+				      struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct devlink_sb *devlink_sb = info->user_ptr[1];
+	struct sk_buff *msg;
+	int err;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	err = devlink_nl_sb_fill(msg, devlink, devlink_sb,
+				 DEVLINK_CMD_SB_NEW,
+				 info->snd_portid, info->snd_seq, 0);
+	if (err) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	return genlmsg_reply(msg, info);
+}
+
+static int devlink_nl_cmd_sb_get_dumpit(struct sk_buff *msg,
+					struct netlink_callback *cb)
+{
+	struct devlink *devlink;
+	struct devlink_sb *devlink_sb;
+	int start = cb->args[0];
+	int idx = 0;
+	int err;
+
+	mutex_lock(&devlink_mutex);
+	list_for_each_entry(devlink, &devlink_list, list) {
+		if (!net_eq(devlink_net(devlink), sock_net(msg->sk)))
+			continue;
+		list_for_each_entry(devlink_sb, &devlink->sb_list, list) {
+			if (idx < start) {
+				idx++;
+				continue;
+			}
+			err = devlink_nl_sb_fill(msg, devlink, devlink_sb,
+						 DEVLINK_CMD_SB_NEW,
+						 NETLINK_CB(cb->skb).portid,
+						 cb->nlh->nlmsg_seq,
+						 NLM_F_MULTI);
+			if (err)
+				goto out;
+			idx++;
+		}
+	}
+out:
+	mutex_unlock(&devlink_mutex);
+
+	cb->args[0] = idx;
+	return msg->len;
+}
+
+static int devlink_nl_sb_pool_fill(struct sk_buff *msg, struct devlink *devlink,
+				   struct devlink_sb *devlink_sb,
+				   u16 pool_index, enum devlink_command cmd,
+				   u32 portid, u32 seq, int flags)
+{
+	struct devlink_sb_pool_info pool_info;
+	void *hdr;
+	int err;
+
+	err = devlink->ops->sb_pool_get(devlink, devlink_sb->index,
+					pool_index, &pool_info);
+
+	hdr = genlmsg_put(msg, portid, seq, &devlink_nl_family, flags, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (devlink_nl_put_handle(msg, devlink))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_SB_INDEX, devlink_sb->index))
+		goto nla_put_failure;
+	if (nla_put_u16(msg, DEVLINK_ATTR_SB_POOL_INDEX, pool_index))
+		goto nla_put_failure;
+	if (nla_put_u8(msg, DEVLINK_ATTR_SB_POOL_TYPE, pool_info.pool_type))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_SB_POOL_SIZE, pool_info.size))
+		goto nla_put_failure;
+	if (nla_put_u8(msg, DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE,
+		       pool_info.threshold_type))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static int devlink_nl_cmd_sb_pool_get_doit(struct sk_buff *skb,
+					   struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct devlink_sb *devlink_sb = info->user_ptr[1];
+	struct sk_buff *msg;
+	u16 pool_index;
+	int err;
+
+	err = devlink_sb_pool_index_get_from_info(devlink_sb, info,
+						  &pool_index);
+	if (err)
+		return err;
+
+	if (!devlink->ops || !devlink->ops->sb_pool_get)
+		return -EOPNOTSUPP;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	err = devlink_nl_sb_pool_fill(msg, devlink, devlink_sb, pool_index,
+				      DEVLINK_CMD_SB_POOL_NEW,
+				      info->snd_portid, info->snd_seq, 0);
+	if (err) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	return genlmsg_reply(msg, info);
+}
+
+static int __sb_pool_get_dumpit(struct sk_buff *msg, int start, int *p_idx,
+				struct devlink *devlink,
+				struct devlink_sb *devlink_sb,
+				u32 portid, u32 seq)
+{
+	u16 pool_count = devlink_sb_pool_count(devlink_sb);
+	u16 pool_index;
+	int err;
+
+	for (pool_index = 0; pool_index < pool_count; pool_index++) {
+		if (*p_idx < start) {
+			(*p_idx)++;
+			continue;
+		}
+		err = devlink_nl_sb_pool_fill(msg, devlink,
+					      devlink_sb,
+					      pool_index,
+					      DEVLINK_CMD_SB_POOL_NEW,
+					      portid, seq, NLM_F_MULTI);
+		if (err)
+			return err;
+		(*p_idx)++;
+	}
+	return 0;
+}
+
+static int devlink_nl_cmd_sb_pool_get_dumpit(struct sk_buff *msg,
+					     struct netlink_callback *cb)
+{
+	struct devlink *devlink;
+	struct devlink_sb *devlink_sb;
+	int start = cb->args[0];
+	int idx = 0;
+	int err;
+
+	mutex_lock(&devlink_mutex);
+	list_for_each_entry(devlink, &devlink_list, list) {
+		if (!net_eq(devlink_net(devlink), sock_net(msg->sk)) ||
+		    !devlink->ops || !devlink->ops->sb_pool_get)
+			continue;
+		list_for_each_entry(devlink_sb, &devlink->sb_list, list) {
+			err = __sb_pool_get_dumpit(msg, start, &idx, devlink,
+						   devlink_sb,
+						   NETLINK_CB(cb->skb).portid,
+						   cb->nlh->nlmsg_seq);
+			if (err && err != -EOPNOTSUPP)
+				goto out;
+		}
+	}
+out:
+	mutex_unlock(&devlink_mutex);
+
+	cb->args[0] = idx;
+	return msg->len;
+}
+
+static int devlink_sb_pool_set(struct devlink *devlink, unsigned int sb_index,
+			       u16 pool_index, u32 size,
+			       enum devlink_sb_threshold_type threshold_type)
+
+{
+	const struct devlink_ops *ops = devlink->ops;
+
+	if (ops && ops->sb_pool_set)
+		return ops->sb_pool_set(devlink, sb_index, pool_index,
+					size, threshold_type);
+	return -EOPNOTSUPP;
+}
+
+static int devlink_nl_cmd_sb_pool_set_doit(struct sk_buff *skb,
+					   struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct devlink_sb *devlink_sb = info->user_ptr[1];
+	enum devlink_sb_threshold_type threshold_type;
+	u16 pool_index;
+	u32 size;
+	int err;
+
+	err = devlink_sb_pool_index_get_from_info(devlink_sb, info,
+						  &pool_index);
+	if (err)
+		return err;
+
+	err = devlink_sb_th_type_get_from_info(info, &threshold_type);
+	if (err)
+		return err;
+
+	if (!info->attrs[DEVLINK_ATTR_SB_POOL_SIZE])
+		return -EINVAL;
+
+	size = nla_get_u32(info->attrs[DEVLINK_ATTR_SB_POOL_SIZE]);
+	return devlink_sb_pool_set(devlink, devlink_sb->index,
+				   pool_index, size, threshold_type);
+}
+
+static int devlink_nl_sb_port_pool_fill(struct sk_buff *msg,
+					struct devlink *devlink,
+					struct devlink_port *devlink_port,
+					struct devlink_sb *devlink_sb,
+					u16 pool_index,
+					enum devlink_command cmd,
+					u32 portid, u32 seq, int flags)
+{
+	u32 threshold;
+	void *hdr;
+	int err;
+
+	err = devlink->ops->sb_port_pool_get(devlink_port, devlink_sb->index,
+					     pool_index, &threshold);
+
+	hdr = genlmsg_put(msg, portid, seq, &devlink_nl_family, flags, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (devlink_nl_put_handle(msg, devlink))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_PORT_INDEX, devlink_port->index))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_SB_INDEX, devlink_sb->index))
+		goto nla_put_failure;
+	if (nla_put_u16(msg, DEVLINK_ATTR_SB_POOL_INDEX, pool_index))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_SB_THRESHOLD, threshold))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static int devlink_nl_cmd_sb_port_pool_get_doit(struct sk_buff *skb,
+						struct genl_info *info)
+{
+	struct devlink_port *devlink_port = info->user_ptr[0];
+	struct devlink *devlink = devlink_port->devlink;
+	struct devlink_sb *devlink_sb = info->user_ptr[1];
+	struct sk_buff *msg;
+	u16 pool_index;
+	int err;
+
+	err = devlink_sb_pool_index_get_from_info(devlink_sb, info,
+						  &pool_index);
+	if (err)
+		return err;
+
+	if (!devlink->ops || !devlink->ops->sb_port_pool_get)
+		return -EOPNOTSUPP;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	err = devlink_nl_sb_port_pool_fill(msg, devlink, devlink_port,
+					   devlink_sb, pool_index,
+					   DEVLINK_CMD_SB_PORT_POOL_NEW,
+					   info->snd_portid, info->snd_seq, 0);
+	if (err) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	return genlmsg_reply(msg, info);
+}
+
+static int __sb_port_pool_get_dumpit(struct sk_buff *msg, int start, int *p_idx,
+				     struct devlink *devlink,
+				     struct devlink_sb *devlink_sb,
+				     u32 portid, u32 seq)
+{
+	struct devlink_port *devlink_port;
+	u16 pool_count = devlink_sb_pool_count(devlink_sb);
+	u16 pool_index;
+	int err;
+
+	list_for_each_entry(devlink_port, &devlink->port_list, list) {
+		for (pool_index = 0; pool_index < pool_count; pool_index++) {
+			if (*p_idx < start) {
+				(*p_idx)++;
+				continue;
+			}
+			err = devlink_nl_sb_port_pool_fill(msg, devlink,
+							   devlink_port,
+							   devlink_sb,
+							   pool_index,
+							   DEVLINK_CMD_SB_PORT_POOL_NEW,
+							   portid, seq,
+							   NLM_F_MULTI);
+			if (err)
+				return err;
+			(*p_idx)++;
+		}
+	}
+	return 0;
+}
+
+static int devlink_nl_cmd_sb_port_pool_get_dumpit(struct sk_buff *msg,
+						  struct netlink_callback *cb)
+{
+	struct devlink *devlink;
+	struct devlink_sb *devlink_sb;
+	int start = cb->args[0];
+	int idx = 0;
+	int err;
+
+	mutex_lock(&devlink_mutex);
+	mutex_lock(&devlink_port_mutex);
+	list_for_each_entry(devlink, &devlink_list, list) {
+		if (!net_eq(devlink_net(devlink), sock_net(msg->sk)) ||
+		    !devlink->ops || !devlink->ops->sb_port_pool_get)
+			continue;
+		list_for_each_entry(devlink_sb, &devlink->sb_list, list) {
+			err = __sb_port_pool_get_dumpit(msg, start, &idx,
+							devlink, devlink_sb,
+							NETLINK_CB(cb->skb).portid,
+							cb->nlh->nlmsg_seq);
+			if (err && err != -EOPNOTSUPP)
+				goto out;
+		}
+	}
+out:
+	mutex_unlock(&devlink_port_mutex);
+	mutex_unlock(&devlink_mutex);
+
+	cb->args[0] = idx;
+	return msg->len;
+}
+
+static int devlink_sb_port_pool_set(struct devlink_port *devlink_port,
+				    unsigned int sb_index, u16 pool_index,
+				    u32 threshold)
+
+{
+	const struct devlink_ops *ops = devlink_port->devlink->ops;
+
+	if (ops && ops->sb_port_pool_set)
+		return ops->sb_port_pool_set(devlink_port, sb_index,
+					     pool_index, threshold);
+	return -EOPNOTSUPP;
+}
+
+static int devlink_nl_cmd_sb_port_pool_set_doit(struct sk_buff *skb,
+						struct genl_info *info)
+{
+	struct devlink_port *devlink_port = info->user_ptr[0];
+	struct devlink_sb *devlink_sb = info->user_ptr[1];
+	u16 pool_index;
+	u32 threshold;
+	int err;
+
+	err = devlink_sb_pool_index_get_from_info(devlink_sb, info,
+						  &pool_index);
+	if (err)
+		return err;
+
+	if (!info->attrs[DEVLINK_ATTR_SB_THRESHOLD])
+		return -EINVAL;
+
+	threshold = nla_get_u32(info->attrs[DEVLINK_ATTR_SB_THRESHOLD]);
+	return devlink_sb_port_pool_set(devlink_port, devlink_sb->index,
+					pool_index, threshold);
+}
+
+static int
+devlink_nl_sb_tc_pool_bind_fill(struct sk_buff *msg, struct devlink *devlink,
+				struct devlink_port *devlink_port,
+				struct devlink_sb *devlink_sb, u16 tc_index,
+				enum devlink_sb_pool_type pool_type,
+				enum devlink_command cmd,
+				u32 portid, u32 seq, int flags)
+{
+	u16 pool_index;
+	u32 threshold;
+	void *hdr;
+	int err;
+
+	err = devlink->ops->sb_tc_pool_bind_get(devlink_port, devlink_sb->index,
+						tc_index, pool_type,
+						&pool_index, &threshold);
+
+	hdr = genlmsg_put(msg, portid, seq, &devlink_nl_family, flags, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (devlink_nl_put_handle(msg, devlink))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_PORT_INDEX, devlink_port->index))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_SB_INDEX, devlink_sb->index))
+		goto nla_put_failure;
+	if (nla_put_u16(msg, DEVLINK_ATTR_SB_TC_INDEX, tc_index))
+		goto nla_put_failure;
+	if (nla_put_u8(msg, DEVLINK_ATTR_SB_POOL_TYPE, pool_type))
+		goto nla_put_failure;
+	if (nla_put_u16(msg, DEVLINK_ATTR_SB_POOL_INDEX, pool_index))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_SB_THRESHOLD, threshold))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static int devlink_nl_cmd_sb_tc_pool_bind_get_doit(struct sk_buff *skb,
+						   struct genl_info *info)
+{
+	struct devlink_port *devlink_port = info->user_ptr[0];
+	struct devlink *devlink = devlink_port->devlink;
+	struct devlink_sb *devlink_sb = info->user_ptr[1];
+	struct sk_buff *msg;
+	enum devlink_sb_pool_type pool_type;
+	u16 tc_index;
+	int err;
+
+	err = devlink_sb_pool_type_get_from_info(info, &pool_type);
+	if (err)
+		return err;
+
+	err = devlink_sb_tc_index_get_from_info(devlink_sb, info, &tc_index);
+	if (err)
+		return err;
+
+	if (!devlink->ops || !devlink->ops->sb_tc_pool_bind_get)
+		return -EOPNOTSUPP;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	err = devlink_nl_sb_tc_pool_bind_fill(msg, devlink, devlink_port,
+					      devlink_sb, tc_index, pool_type,
+					      DEVLINK_CMD_SB_TC_POOL_BIND_NEW,
+					      info->snd_portid,
+					      info->snd_seq, 0);
+	if (err) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	return genlmsg_reply(msg, info);
+}
+
+static int __sb_tc_pool_bind_get_dumpit(struct sk_buff *msg,
+					int start, int *p_idx,
+					struct devlink *devlink,
+					struct devlink_sb *devlink_sb,
+					u32 portid, u32 seq)
+{
+	struct devlink_port *devlink_port;
+	u16 tc_index;
+	int err;
+
+	list_for_each_entry(devlink_port, &devlink->port_list, list) {
+		for (tc_index = 0;
+		     tc_index < devlink_sb->tc_count; tc_index++) {
+			if (*p_idx < start) {
+				(*p_idx)++;
+				continue;
+			}
+			err = devlink_nl_sb_tc_pool_bind_fill(msg, devlink,
+							      devlink_port,
+							      devlink_sb,
+							      tc_index,
+							      DEVLINK_SB_POOL_TYPE_INGRESS,
+							      DEVLINK_CMD_SB_TC_POOL_BIND_NEW,
+							      portid, seq,
+							      NLM_F_MULTI);
+			if (err)
+				return err;
+			err = devlink_nl_sb_tc_pool_bind_fill(msg, devlink,
+							      devlink_port,
+							      devlink_sb,
+							      tc_index,
+							      DEVLINK_SB_POOL_TYPE_EGRESS,
+							      DEVLINK_CMD_SB_TC_POOL_BIND_NEW,
+							      portid, seq,
+							      NLM_F_MULTI);
+			if (err)
+				return err;
+			(*p_idx)++;
+		}
+	}
+	return 0;
+}
+
+static int
+devlink_nl_cmd_sb_tc_pool_bind_get_dumpit(struct sk_buff *msg,
+					  struct netlink_callback *cb)
+{
+	struct devlink *devlink;
+	struct devlink_sb *devlink_sb;
+	int start = cb->args[0];
+	int idx = 0;
+	int err;
+
+	mutex_lock(&devlink_mutex);
+	mutex_lock(&devlink_port_mutex);
+	list_for_each_entry(devlink, &devlink_list, list) {
+		if (!net_eq(devlink_net(devlink), sock_net(msg->sk)) ||
+		    !devlink->ops || !devlink->ops->sb_tc_pool_bind_get)
+			continue;
+		list_for_each_entry(devlink_sb, &devlink->sb_list, list) {
+			err = __sb_tc_pool_bind_get_dumpit(msg, start, &idx,
+							   devlink,
+							   devlink_sb,
+							   NETLINK_CB(cb->skb).portid,
+							   cb->nlh->nlmsg_seq);
+			if (err && err != -EOPNOTSUPP)
+				goto out;
+		}
+	}
+out:
+	mutex_unlock(&devlink_port_mutex);
+	mutex_unlock(&devlink_mutex);
+
+	cb->args[0] = idx;
+	return msg->len;
+}
+
+static int devlink_sb_tc_pool_bind_set(struct devlink_port *devlink_port,
+				       unsigned int sb_index, u16 tc_index,
+				       enum devlink_sb_pool_type pool_type,
+				       u16 pool_index, u32 threshold)
+
+{
+	const struct devlink_ops *ops = devlink_port->devlink->ops;
+
+	if (ops && ops->sb_tc_pool_bind_set)
+		return ops->sb_tc_pool_bind_set(devlink_port, sb_index,
+						tc_index, pool_type,
+						pool_index, threshold);
+	return -EOPNOTSUPP;
+}
+
+static int devlink_nl_cmd_sb_tc_pool_bind_set_doit(struct sk_buff *skb,
+						   struct genl_info *info)
+{
+	struct devlink_port *devlink_port = info->user_ptr[0];
+	struct devlink_sb *devlink_sb = info->user_ptr[1];
+	enum devlink_sb_pool_type pool_type;
+	u16 tc_index;
+	u16 pool_index;
+	u32 threshold;
+	int err;
+
+	err = devlink_sb_tc_index_get_from_info(devlink_sb, info,
+						&tc_index);
+	if (err)
+		return err;
+
+	err = devlink_sb_pool_type_get_from_info(info, &pool_type);
+	if (err)
+		return err;
+
+	err = devlink_sb_pool_index_get_from_info(devlink_sb, info,
+						  &pool_index);
+	if (err)
+		return err;
+
+	if (!info->attrs[DEVLINK_ATTR_SB_THRESHOLD])
+		return -EINVAL;
+
+	threshold = nla_get_u32(info->attrs[DEVLINK_ATTR_SB_THRESHOLD]);
+	return devlink_sb_tc_pool_bind_set(devlink_port, devlink_sb->index,
+					   tc_index, pool_type,
+					   pool_index, threshold);
+}
+
 static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_BUS_NAME] = { .type = NLA_NUL_STRING },
 	[DEVLINK_ATTR_DEV_NAME] = { .type = NLA_NUL_STRING },
 	[DEVLINK_ATTR_PORT_INDEX] = { .type = NLA_U32 },
 	[DEVLINK_ATTR_PORT_TYPE] = { .type = NLA_U16 },
 	[DEVLINK_ATTR_PORT_SPLIT_COUNT] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_SB_INDEX] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_SB_POOL_INDEX] = { .type = NLA_U16 },
+	[DEVLINK_ATTR_SB_POOL_TYPE] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_SB_POOL_SIZE] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_SB_THRESHOLD] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_SB_TC_INDEX] = { .type = NLA_U16 },
 };
 
 static const struct genl_ops devlink_nl_ops[] = {
@@ -545,6 +1352,66 @@ static const struct genl_ops devlink_nl_ops[] = {
 		.flags = GENL_ADMIN_PERM,
 		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
 	},
+	{
+		.cmd = DEVLINK_CMD_SB_GET,
+		.doit = devlink_nl_cmd_sb_get_doit,
+		.dumpit = devlink_nl_cmd_sb_get_dumpit,
+		.policy = devlink_nl_policy,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK |
+				  DEVLINK_NL_FLAG_NEED_SB,
+		/* can be retrieved by unprivileged users */
+	},
+	{
+		.cmd = DEVLINK_CMD_SB_POOL_GET,
+		.doit = devlink_nl_cmd_sb_pool_get_doit,
+		.dumpit = devlink_nl_cmd_sb_pool_get_dumpit,
+		.policy = devlink_nl_policy,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK |
+				  DEVLINK_NL_FLAG_NEED_SB,
+		/* can be retrieved by unprivileged users */
+	},
+	{
+		.cmd = DEVLINK_CMD_SB_POOL_SET,
+		.doit = devlink_nl_cmd_sb_pool_set_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK |
+				  DEVLINK_NL_FLAG_NEED_SB,
+	},
+	{
+		.cmd = DEVLINK_CMD_SB_PORT_POOL_GET,
+		.doit = devlink_nl_cmd_sb_port_pool_get_doit,
+		.dumpit = devlink_nl_cmd_sb_port_pool_get_dumpit,
+		.policy = devlink_nl_policy,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_PORT |
+				  DEVLINK_NL_FLAG_NEED_SB,
+		/* can be retrieved by unprivileged users */
+	},
+	{
+		.cmd = DEVLINK_CMD_SB_PORT_POOL_SET,
+		.doit = devlink_nl_cmd_sb_port_pool_set_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_PORT |
+				  DEVLINK_NL_FLAG_NEED_SB,
+	},
+	{
+		.cmd = DEVLINK_CMD_SB_TC_POOL_BIND_GET,
+		.doit = devlink_nl_cmd_sb_tc_pool_bind_get_doit,
+		.dumpit = devlink_nl_cmd_sb_tc_pool_bind_get_dumpit,
+		.policy = devlink_nl_policy,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_PORT |
+				  DEVLINK_NL_FLAG_NEED_SB,
+		/* can be retrieved by unprivileged users */
+	},
+	{
+		.cmd = DEVLINK_CMD_SB_TC_POOL_BIND_SET,
+		.doit = devlink_nl_cmd_sb_tc_pool_bind_set_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_PORT |
+				  DEVLINK_NL_FLAG_NEED_SB,
+	},
 };
 
 /**
@@ -566,6 +1433,7 @@ struct devlink *devlink_alloc(const struct devlink_ops *ops, size_t priv_size)
 	devlink->ops = ops;
 	devlink_net_set(devlink, &init_net);
 	INIT_LIST_HEAD(&devlink->port_list);
+	INIT_LIST_HEAD(&devlink->sb_list);
 	return devlink;
 }
 EXPORT_SYMBOL_GPL(devlink_alloc);
@@ -722,6 +1590,49 @@ void devlink_port_split_set(struct devlink_port *devlink_port,
 }
 EXPORT_SYMBOL_GPL(devlink_port_split_set);
 
+int devlink_sb_register(struct devlink *devlink, unsigned int sb_index,
+			u32 size, u16 ingress_pools_count,
+			u16 egress_pools_count, u16 tc_count)
+{
+	struct devlink_sb *devlink_sb;
+	int err = 0;
+
+	mutex_lock(&devlink_mutex);
+	if (devlink_sb_index_exists(devlink, sb_index)) {
+		err = -EEXIST;
+		goto unlock;
+	}
+
+	devlink_sb = kzalloc(sizeof(*devlink_sb), GFP_KERNEL);
+	if (!devlink_sb) {
+		err = -ENOMEM;
+		goto unlock;
+	}
+	devlink_sb->index = sb_index;
+	devlink_sb->size = size;
+	devlink_sb->ingress_pools_count = ingress_pools_count;
+	devlink_sb->egress_pools_count = egress_pools_count;
+	devlink_sb->tc_count = tc_count;
+	list_add_tail(&devlink_sb->list, &devlink->sb_list);
+unlock:
+	mutex_unlock(&devlink_mutex);
+	return err;
+}
+EXPORT_SYMBOL_GPL(devlink_sb_register);
+
+void devlink_sb_unregister(struct devlink *devlink, unsigned int sb_index)
+{
+	struct devlink_sb *devlink_sb;
+
+	mutex_lock(&devlink_mutex);
+	devlink_sb = devlink_sb_get_by_index(devlink, sb_index);
+	WARN_ON(!devlink_sb);
+	list_del(&devlink_sb->list);
+	mutex_unlock(&devlink_mutex);
+	kfree(devlink_sb);
+}
+EXPORT_SYMBOL_GPL(devlink_sb_unregister);
+
 static int __init devlink_module_init(void)
 {
 	return genl_register_family_with_ops_groups(&devlink_nl_family,
-- 
2.5.0
