From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 1/7] devlink: Add support for resource abstraction
Date: Tue, 24 Oct 2017 11:22:39 +0200
Message-ID: <20171024092245.1386-2-jiri@resnulli.us>
References: <20171024092245.1386-1-jiri@resnulli.us>
Cc: davem@davemloft.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com, ast@kernel.org,
        daniel@iogearbox.net, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com, linville@tuxdriver.com,
        gospo@broadcom.com, steven.lin1@broadcom.com, yuvalm@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:44955 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932279AbdJXJWs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:22:48 -0400
Received: by mail-wm0-f65.google.com with SMTP id 196so11473454wma.1
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:22:48 -0700 (PDT)
In-Reply-To: <20171024092245.1386-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for hardware resource abstraction over devlink. Each resource
is identified via unique name, furthermore it contains information
regarding its size and its related sub resources. Each resource can also
provide its current occupancy.

In some cases the sizes of some resources can be changed, yet for those
changes to take place a hot driver reload may be needed. The reload
capability will be introduced in the next patch.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/devlink.h        |  74 ++++++++++
 include/uapi/linux/devlink.h |   8 ++
 net/core/devlink.c           | 317 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 399 insertions(+)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index b9654e1..fe57534 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -26,6 +26,7 @@ struct devlink {
 	struct list_head port_list;
 	struct list_head sb_list;
 	struct list_head dpipe_table_list;
+	struct list_head resource_list;
 	struct devlink_dpipe_headers *dpipe_headers;
 	const struct devlink_ops *ops;
 	struct device *dev;
@@ -223,6 +224,43 @@ struct devlink_dpipe_headers {
 	unsigned int headers_count;
 };
 
+/**
+ * struct devlink_resource_ops - resource ops
+ * @occ_get - get the occupied size
+ * @size_validate - validate the size of the resource before update, reload
+ *                  is needed for changes to take place
+ */
+struct devlink_resource_ops {
+	u64 (*occ_get)(void *priv);
+	int (*size_validate)(void *priv, u64 size);
+};
+
+/**
+ * struct devlink_resource - devlink resource
+ * @priv - private
+ * @name - name of the resource
+ * @size - size of the resource
+ * @size_new - updated size of the resource, reload is needed
+ * @id - id, per devlink instance
+ * @parent - parent resource
+ * @list - parent list
+ * @sub_resource_list - list of sub-resources
+ * @resource_ops - resource ops
+ */
+struct devlink_resource {
+	void *priv;
+	const char *name;
+	u64 size;
+	u64 size_new;
+	u64 id;
+	struct devlink_resource *parent;
+	struct list_head list;
+	struct list_head sub_resource_list;
+	struct devlink_resource_ops *resource_ops;
+};
+
+#define DEVLINK_RESOURCE_ID_PARENT_TOP 0
+
 struct devlink_ops {
 	int (*port_type_set)(struct devlink_port *devlink_port,
 			     enum devlink_port_type port_type);
@@ -331,6 +369,18 @@ int devlink_dpipe_match_put(struct sk_buff *skb,
 extern struct devlink_dpipe_header devlink_dpipe_header_ethernet;
 extern struct devlink_dpipe_header devlink_dpipe_header_ipv4;
 extern struct devlink_dpipe_header devlink_dpipe_header_ipv6;
+int devlink_resource_register(struct devlink *devlink,
+			      const char *resource_name,
+			      bool top_hirarchy,
+			      u64 resource_size,
+			      u64 resource_id,
+			      u64 parent_resource_id,
+			      struct devlink_resource_ops *resource_ops,
+			      void *priv);
+int devlink_resource_size_get(struct devlink *devlink,
+			      u64 resource_id,
+			      u64 *p_resource_size);
+void devlink_resources_clear(struct devlink *devlink);
 
 #else
 
@@ -468,6 +518,30 @@ devlink_dpipe_match_put(struct sk_buff *skb,
 	return 0;
 }
 
+static inline int
+devlink_resource_register(struct devlink *devlink,
+			  const char *resource_name,
+			  bool top_hirarchy,
+			  u64 resource_size,
+			  u64 resource_id,
+			  u64 parent_resource_id,
+			  struct devlink_resource_ops *resource_ops,
+			  void *priv)
+{
+	return 0;
+}
+
+static inline int
+devlink_resource_size_get(struct devlink *devlink, u64 resource_id,
+			  u64 *p_resource_size)
+{
+	return -EINVAL;
+}
+
+static inline void devlink_resources_clear(struct devlink *devlink)
+{
+}
+
 #endif
 
 #endif /* _NET_DEVLINK_H_ */
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 0cbca96..9db1d70 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -69,6 +69,8 @@ enum devlink_command {
 	DEVLINK_CMD_DPIPE_ENTRIES_GET,
 	DEVLINK_CMD_DPIPE_HEADERS_GET,
 	DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
+	DEVLINK_CMD_RESOURCE_SET,
+	DEVLINK_CMD_RESOURCE_DUMP,
 
 	/* add new commands above here */
 	__DEVLINK_CMD_MAX,
@@ -201,6 +203,12 @@ enum devlink_attr {
 	DEVLINK_ATTR_PAD,
 
 	DEVLINK_ATTR_ESWITCH_ENCAP_MODE,	/* u8 */
+	DEVLINK_ATTR_RESOURCES,			/* nested */
+	DEVLINK_ATTR_RESOURCE,			/* nested */
+	DEVLINK_ATTR_RESOURCE_NAME,		/* string */
+	DEVLINK_ATTR_RESOURCE_SIZE,		/* u64 */
+	DEVLINK_ATTR_RESOURCE_SIZE_NEW,		/* u64 */
+	DEVLINK_ATTR_RESOURCE_ID,		/* u64 */
 
 	/* add new attributes above here, update the policy in devlink.c */
 
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 7d430c1..a48dcd6 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -2273,6 +2273,198 @@ static int devlink_nl_cmd_dpipe_table_counters_set(struct sk_buff *skb,
 						counters_enable);
 }
 
+struct devlink_resource *
+devlink_subresource_find(struct devlink_resource *resource, u64 resource_id)
+{
+	struct devlink_resource *sub_resource;
+
+	list_for_each_entry(sub_resource, &resource->sub_resource_list, list) {
+		struct devlink_resource *__sub_resource;
+
+		if (sub_resource->id == resource_id)
+			return sub_resource;
+
+		__sub_resource = devlink_subresource_find(sub_resource,
+							  resource_id);
+		if (__sub_resource)
+			return __sub_resource;
+	}
+	return NULL;
+}
+
+struct devlink_resource *
+devlink_resource_find(struct devlink *devlink, u64 resource_id)
+{
+	struct devlink_resource *resource;
+
+	list_for_each_entry(resource, &devlink->resource_list, list) {
+		struct devlink_resource *sub_resource;
+
+		if (resource->id == resource_id)
+			return resource;
+
+		sub_resource = devlink_subresource_find(resource, resource_id);
+		if (sub_resource)
+			return sub_resource;
+	}
+	return NULL;
+}
+
+static int devlink_nl_cmd_resource_set(struct sk_buff *skb,
+				       struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct devlink_resource *resource;
+	u64 resource_id;
+	u64 size;
+	int err;
+
+	if (!info->attrs[DEVLINK_ATTR_RESOURCE_ID] ||
+	    !info->attrs[DEVLINK_ATTR_RESOURCE_SIZE])
+		return -EINVAL;
+	resource_id = nla_get_u64(info->attrs[DEVLINK_ATTR_RESOURCE_ID]);
+
+	resource = devlink_resource_find(devlink, resource_id);
+	if (!resource)
+		return -EINVAL;
+
+	if (!resource->resource_ops->size_validate)
+		return -EINVAL;
+
+	size = nla_get_u64(info->attrs[DEVLINK_ATTR_RESOURCE_SIZE]);
+	err = resource->resource_ops->size_validate(resource->priv, size);
+	if (err)
+		return err;
+
+	resource->size_new = size;
+	return 0;
+}
+
+static int devlink_resource_put(struct sk_buff *skb,
+				struct devlink_resource *resource)
+{
+	struct devlink_resource *sub_resource;
+	struct nlattr *sub_resource_attr;
+	struct nlattr *resource_attr;
+
+	resource_attr = nla_nest_start(skb, DEVLINK_ATTR_RESOURCE);
+	if (!resource_attr)
+		return -EMSGSIZE;
+
+	if (nla_put_string(skb, DEVLINK_ATTR_RESOURCE_NAME, resource->name) ||
+	    nla_put_u64_64bit(skb, DEVLINK_ATTR_RESOURCE_SIZE, resource->size,
+			      DEVLINK_ATTR_PAD) ||
+	    nla_put_u64_64bit(skb, DEVLINK_ATTR_RESOURCE_ID, resource->id,
+			      DEVLINK_ATTR_PAD))
+		goto nla_put_failure;
+	if (resource->size != resource->size_new)
+		nla_put_u64_64bit(skb, DEVLINK_ATTR_RESOURCE_SIZE_NEW,
+				  resource->size_new, DEVLINK_ATTR_PAD);
+	if (list_empty(&resource->sub_resource_list))
+		goto out;
+
+	sub_resource_attr = nla_nest_start(skb, DEVLINK_ATTR_RESOURCES);
+	if (!sub_resource_attr)
+		goto nla_put_failure;
+
+	list_for_each_entry(sub_resource, &resource->sub_resource_list, list) {
+		if (devlink_resource_put(skb, sub_resource))
+			goto resource_put_failure;
+	}
+
+	nla_nest_end(skb, sub_resource_attr);
+out:
+	nla_nest_end(skb, resource_attr);
+	return 0;
+
+resource_put_failure:
+	nla_nest_cancel(skb, sub_resource_attr);
+nla_put_failure:
+	nla_nest_cancel(skb, resource_attr);
+	return -EMSGSIZE;
+}
+
+static int devlink_resource_fill(struct genl_info *info,
+				 enum devlink_command cmd, int flags)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct devlink_resource *resource;
+	struct nlattr *resources_attr;
+	struct sk_buff *skb = NULL;
+	struct nlmsghdr *nlh;
+	bool incomplete;
+	void *hdr;
+	int i;
+	int err;
+
+	resource = list_first_entry(&devlink->resource_list,
+				    struct devlink_resource, list);
+start_again:
+	err = devlink_dpipe_send_and_alloc_skb(&skb, info);
+	if (err)
+		return err;
+
+	hdr = genlmsg_put(skb, info->snd_portid, info->snd_seq,
+			  &devlink_nl_family, NLM_F_MULTI, cmd);
+	if (!hdr) {
+		nlmsg_free(skb);
+		return -EMSGSIZE;
+	}
+
+	if (devlink_nl_put_handle(skb, devlink))
+		goto nla_put_failure;
+
+	resources_attr = nla_nest_start(skb, DEVLINK_ATTR_RESOURCES);
+	if (!resources_attr)
+		goto nla_put_failure;
+
+	incomplete = false;
+	i = 0;
+	list_for_each_entry_from(resource, &devlink->resource_list, list) {
+		err = devlink_resource_put(skb, resource);
+		if (err) {
+			if (!i)
+				goto err_resource_put;
+			incomplete = true;
+			break;
+		}
+		i++;
+	}
+	nla_nest_end(skb, resources_attr);
+	genlmsg_end(skb, hdr);
+	if (incomplete)
+		goto start_again;
+send_done:
+	nlh = nlmsg_put(skb, info->snd_portid, info->snd_seq,
+			NLMSG_DONE, 0, flags | NLM_F_MULTI);
+	if (!nlh) {
+		err = devlink_dpipe_send_and_alloc_skb(&skb, info);
+		if (err)
+			goto err_skb_send_alloc;
+		goto send_done;
+	}
+	return genlmsg_reply(skb, info);
+
+nla_put_failure:
+	err = -EMSGSIZE;
+err_resource_put:
+err_skb_send_alloc:
+	genlmsg_cancel(skb, hdr);
+	nlmsg_free(skb);
+	return err;
+}
+
+static int devlink_nl_cmd_resource_dump(struct sk_buff *skb,
+					struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+
+	if (list_empty(&devlink->resource_list))
+		return -EOPNOTSUPP;
+
+	return devlink_resource_fill(info, DEVLINK_CMD_RESOURCE_DUMP, 0);
+}
+
 static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_BUS_NAME] = { .type = NLA_NUL_STRING },
 	[DEVLINK_ATTR_DEV_NAME] = { .type = NLA_NUL_STRING },
@@ -2451,6 +2643,20 @@ static const struct genl_ops devlink_nl_ops[] = {
 		.flags = GENL_ADMIN_PERM,
 		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
 	},
+	{
+		.cmd = DEVLINK_CMD_RESOURCE_SET,
+		.doit = devlink_nl_cmd_resource_set,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
+	{
+		.cmd = DEVLINK_CMD_RESOURCE_DUMP,
+		.doit = devlink_nl_cmd_resource_dump,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
 };
 
 static struct genl_family devlink_nl_family __ro_after_init = {
@@ -2488,6 +2694,7 @@ struct devlink *devlink_alloc(const struct devlink_ops *ops, size_t priv_size)
 	INIT_LIST_HEAD(&devlink->port_list);
 	INIT_LIST_HEAD(&devlink->sb_list);
 	INIT_LIST_HEAD_RCU(&devlink->dpipe_table_list);
+	INIT_LIST_HEAD(&devlink->resource_list);
 	return devlink;
 }
 EXPORT_SYMBOL_GPL(devlink_alloc);
@@ -2815,6 +3022,116 @@ void devlink_dpipe_table_unregister(struct devlink *devlink,
 }
 EXPORT_SYMBOL_GPL(devlink_dpipe_table_unregister);
 
+/**
+ *	devlink_resource_register - devlink resource register
+ *
+ *	@devlink: devlink
+ *	@resource_name: resource's name
+ *	@top_hirarchy: top hirarchy
+ *	@resource_size: resource's size
+ *	@resource_id: resource's id
+ *	@parent_reosurce_id: resource's parent id
+ *	@resource_ops: resource ops
+ *	@priv: priv
+ */
+int devlink_resource_register(struct devlink *devlink,
+			      const char *resource_name,
+			      bool top_hirarchy,
+			      u64 resource_size,
+			      u64 resource_id,
+			      u64 parent_resource_id,
+			      struct devlink_resource_ops *resource_ops,
+			      void *priv)
+{
+	struct devlink_resource *resource;
+	struct list_head *resource_list;
+
+	resource = devlink_resource_find(devlink, resource_id);
+	if (resource)
+		return -EINVAL;
+
+	if (top_hirarchy) {
+		resource_list = &devlink->resource_list;
+	} else {
+		struct devlink_resource *parent_resource;
+
+		parent_resource = devlink_resource_find(devlink,
+							parent_resource_id);
+		if (parent_resource)
+			resource_list = &parent_resource->sub_resource_list;
+		else
+			return -EINVAL;
+	}
+
+	resource = kzalloc(sizeof(*resource), GFP_KERNEL);
+	if (!resource)
+		return -ENOMEM;
+
+	resource->name = resource_name;
+	resource->size = resource_size;
+	resource->size_new = resource_size;
+	resource->id = resource_id;
+	resource->resource_ops = resource_ops;
+	resource->priv = priv;
+	INIT_LIST_HEAD(&resource->sub_resource_list);
+
+	list_add_tail(&resource->list, resource_list);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(devlink_resource_register);
+
+static void devlink_subresources_clear(struct devlink_resource *resource)
+{
+	struct devlink_resource *sub_resource, *tmp;
+
+	list_for_each_entry_safe(sub_resource, tmp,
+				 &resource->sub_resource_list, list) {
+		devlink_subresources_clear(sub_resource);
+		list_del(&sub_resource->list);
+		kfree(sub_resource);
+	}
+}
+
+/**
+ *	devlink_resource_clear - frees all resources
+ *
+ *	@devlink: devlink
+ */
+void devlink_resources_clear(struct devlink *devlink)
+{
+	struct devlink_resource *resource, *tmp;
+
+	list_for_each_entry_safe(resource, tmp,
+				 &devlink->resource_list, list) {
+		devlink_subresources_clear(resource);
+		list_del(&resource->list);
+		kfree(resource);
+	}
+}
+EXPORT_SYMBOL_GPL(devlink_resources_clear);
+
+/**
+ *	devlink_resource_size_get - get and update size
+ *
+ *	@devlink: devlink
+ *	@resource_id: the requested resource id
+ *	@p_resource_size: ptr to update
+ */
+int devlink_resource_size_get(struct devlink *devlink,
+			      u64 resource_id,
+			      u64 *p_resource_size)
+{
+	struct devlink_resource *resource;
+
+	resource = devlink_resource_find(devlink, resource_id);
+	if (!resource)
+		return -EINVAL;
+	*p_resource_size = resource->size_new;
+	resource->size = resource->size_new;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(devlink_resource_size_get);
+
 static int __init devlink_module_init(void)
 {
 	return genl_register_family(&devlink_nl_family);
-- 
2.9.5
