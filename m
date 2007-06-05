From: Patrick McHardy <kaber@trash.net>
Subject: [RFC RTNETLINK 04/09]: Link creation API
Date: Tue,  5 Jun 2007 16:12:57 +0200 (MEST)
Message-ID: <20070605141256.15650.37514.sendpatchset@localhost.localdomain>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Cc: socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru,
	Patrick McHardy <kaber@trash.net>, ebiederm@xmission.com,
	tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63914 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763215AbXFEOM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:12:59 -0400
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[RTNETLINK]: Link creation API

Add rtnetlink API for creating, changing and deleting software devices.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0323e7d1e7d5042492684264cfcba6d7ff55c473
tree 161530836d43b39ddef42a2c2b48b82187580e3c
parent 40b0b8787c1057d055baa6e3d11ff6db7783c982
author Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 15:40:12 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 15:40:12 +0200

 include/linux/if_link.h   |   13 ++
 include/linux/netdevice.h |    3 
 include/net/rtnetlink.h   |   57 ++++++++
 net/core/rtnetlink.c      |  338 ++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 404 insertions(+), 7 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 604c243..e46ed94 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -76,6 +76,8 @@ enum
 #define IFLA_WEIGHT IFLA_WEIGHT
 	IFLA_OPERSTATE,
 	IFLA_LINKMODE,
+	IFLA_LINKINFO,
+#define IFLA_LINKINFO IFLA_LINKINFO
 	__IFLA_MAX
 };
 
@@ -140,4 +142,15 @@ struct ifla_cacheinfo
 	__u32	retrans_time;
 };
 
+enum
+{
+	IFLA_INFO_UNSPEC,
+	IFLA_INFO_NAME,
+	IFLA_INFO_DATA,
+	IFLA_INFO_XSTATS,
+	__IFLA_INFO_MAX,
+};
+
+#define IFLA_INFO_MAX	(__IFLA_INFO_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3a70f55..e327ccc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -540,6 +540,9 @@ struct net_device
 	struct device		dev;
 	/* space for optional statistics and wireless sysfs groups */
 	struct attribute_group  *sysfs_groups[3];
+
+	/* rtnetlink link ops */
+	struct rtnl_link_ops	*rtnl_link_ops;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 3b3d474..d744198 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -22,4 +22,61 @@ static inline int rtnl_msg_family(struct nlmsghdr *nlh)
 		return AF_UNSPEC;
 }
 
+/**
+ *	struct rtnl_link_ops - rtnetlink link operations
+ *
+ *	@list: Used internally
+ *	@name: Identifier
+ *	@maxtype: Highest device specific netlink attribute number
+ *	@policy: Netlink policy for device specific attribute validation
+ *	@validate: Optional validation function for netlink/changelink parameters
+ *	@priv_size: sizeof net_device private space
+ *	@setup: net_device setup function
+ *	@newlink: Function for configuring and registering a new device
+ *	@changelink: Function for changing parameters of an existing device
+ *	@dellink: Function to remove a device
+ *	@get_size: Function to calculate required room for dumping device
+ *		   specific netlink attributes
+ *	@fill_info: Function to dump device specific netlink attributes
+ *	@xstats_size: Size of device specific statistics
+ *	@fill_xstats: Function to dump device specific statistics
+ */
+struct rtnl_link_ops {
+	struct list_head	list;
+
+	const char		*name;
+
+	size_t			priv_size;
+	void			(*setup)(struct net_device *dev);
+
+	int			maxtype;
+	const struct nla_policy	*policy;
+	int			(*validate)(struct nlattr *tb[],
+					    struct nlattr *data[]);
+
+	int			(*newlink)(struct net_device *dev,
+					   struct nlattr *tb[],
+					   struct nlattr *data[]);
+	int			(*changelink)(struct net_device *dev,
+					      struct nlattr *tb[],
+					      struct nlattr *data[]);
+	void			(*dellink)(struct net_device *dev);
+
+	size_t			(*get_size)(struct net_device *dev);
+	int			(*fill_info)(struct sk_buff *skb,
+					     struct net_device *dev);
+
+	size_t			xstats_size;
+	int			(*fill_xstats)(struct sk_buff *skb,
+					       struct net_device *dev);
+};
+
+extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
+extern void	__rtnl_link_unregister(struct rtnl_link_ops *ops);
+
+extern int	rtnl_link_register(struct rtnl_link_ops *ops);
+extern void	rtnl_link_unregister(struct rtnl_link_ops *ops);
+
+#define MODULE_ALIAS_RTNL_LINK(name) MODULE_ALIAS("rtnl-link-" #name)
+
 #endif
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 25ca219..ed17288 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -243,6 +243,141 @@ void rtnl_unregister_all(int protocol)
 
 EXPORT_SYMBOL_GPL(rtnl_unregister_all);
 
+static LIST_HEAD(link_ops);
+
+/**
+ * __rtnl_link_register - Register rtnl_link_ops with rtnetlink.
+ * @ops: struct rtnl_link_ops * to register
+ *
+ * The caller must hold the rtnl_mutex. This function should be used
+ * by drivers that create devices during module initialization. It
+ * must be called before registering the devices.
+ *
+ * Returns 0 on success or a negative error code.
+ */
+int __rtnl_link_register(struct rtnl_link_ops *ops)
+{
+	list_add_tail(&ops->list, &link_ops);
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(__rtnl_link_register);
+
+/**
+ * rtnl_link_register - Register rtnl_link_ops with rtnetlink.
+ * @ops: struct rtnl_link_ops * to register
+ *
+ * Returns 0 on success or a negative error code.
+ */
+int rtnl_link_register(struct rtnl_link_ops *ops)
+{
+	int err;
+
+	rtnl_lock();
+	err = __rtnl_link_register(ops);
+	rtnl_unlock();
+	return err;
+}
+
+EXPORT_SYMBOL_GPL(rtnl_link_register);
+
+/**
+ * __rtnl_link_unregister - Unregister rtnl_link_ops from rtnetlink.
+ * @ops: struct rtnl_link_ops * to unregister
+ *
+ * The caller must hold the rtnl_mutex. This function should be used
+ * by drivers that unregister devices during module unloading. It must
+ * be called after unregistering the devices.
+ */
+void __rtnl_link_unregister(struct rtnl_link_ops *ops)
+{
+	list_del(&ops->list);
+}
+
+EXPORT_SYMBOL_GPL(__rtnl_link_unregister);
+
+/**
+ * rtnl_link_unregister - Unregister rtnl_link_ops from rtnetlink.
+ * @ops: struct rtnl_link_ops * to unregister
+ */
+void rtnl_link_unregister(struct rtnl_link_ops *ops)
+{
+	rtnl_lock();
+	__rtnl_link_unregister(ops);
+	rtnl_unlock();
+}
+
+EXPORT_SYMBOL_GPL(rtnl_link_unregister);
+
+static struct rtnl_link_ops *rtnl_link_ops_get(char *name)
+{
+	struct rtnl_link_ops *ops;
+
+	list_for_each_entry(ops, &link_ops, list) {
+		if (!strcmp(ops->name, name))
+			return ops;
+	}
+	return NULL;
+}
+
+static size_t rtnl_link_get_size(struct net_device *dev)
+{
+	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+	size_t size;
+
+	if (!ops)
+		return 0;
+
+	size = nlmsg_total_size(sizeof(struct nlattr)) + /* IFLA_LINKINFO */
+	       nlmsg_total_size(strlen(ops->name) + 1) + /* IFLA_INFO_NAME */
+	       nlmsg_total_size(ops->xstats_size);	 /* IFLA_INFO_XSTATS */
+
+	if (ops->get_size)
+		/* IFLA_INFO_DATA + nested data */
+		size += nlmsg_total_size(sizeof(struct nlattr)) +
+			ops->get_size(dev);
+
+	return size;
+}
+
+static int rtnl_link_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+	struct nlattr *linkinfo, *data;
+	int err = -EMSGSIZE;
+
+	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
+	if (linkinfo == NULL)
+		goto out;
+
+	if (nla_put_string(skb, IFLA_INFO_NAME, ops->name) < 0)
+		goto err_cancel_link;
+	if (ops->fill_xstats) {
+		err = ops->fill_xstats(skb, dev);
+		if (err < 0)
+			goto err_cancel_link;
+	}
+	if (ops->fill_info) {
+		data = nla_nest_start(skb, IFLA_INFO_DATA);
+		if (data == NULL)
+			goto err_cancel_link;
+		err = ops->fill_info(skb, dev);
+		if (err < 0)
+			goto err_cancel_data;
+		nla_nest_end(skb, data);
+	}
+
+	nla_nest_end(skb, linkinfo);
+	return 0;
+
+err_cancel_data:
+	nla_nest_cancel(skb, data);
+err_cancel_link:
+	nla_nest_cancel(skb, linkinfo);
+out:
+	return err;
+}
+
 static const int rtm_min[RTM_NR_FAMILIES] =
 {
 	[RTM_FAM(RTM_NEWLINK)]      = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
@@ -437,7 +572,7 @@ static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
 	a->tx_compressed = b->tx_compressed;
 };
 
-static inline size_t if_nlmsg_size(void)
+static inline size_t if_nlmsg_size(struct net_device *dev)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
 	       + nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
@@ -452,7 +587,8 @@ static inline size_t if_nlmsg_size(void)
 	       + nla_total_size(4) /* IFLA_LINK */
 	       + nla_total_size(4) /* IFLA_MASTER */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
-	       + nla_total_size(1); /* IFLA_LINKMODE */
+	       + nla_total_size(1) /* IFLA_LINKMODE */
+	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
 }
 
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
@@ -522,6 +658,11 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
+	if (dev->rtnl_link_ops) {
+		if (rtnl_link_fill(skb, dev) < 0)
+			goto nla_put_failure;
+	}
+
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -553,6 +694,8 @@ cont:
 
 static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_IFNAME]		= { .type = NLA_STRING, .len = IFNAMSIZ-1 },
+	[IFLA_ADDRESS]		= { .type = NLA_BINARY, .len = MAX_ADDR_LEN },
+	[IFLA_BROADCAST]	= { .type = NLA_BINARY, .len = MAX_ADDR_LEN },
 	[IFLA_MAP]		= { .len = sizeof(struct rtnl_link_ifmap) },
 	[IFLA_MTU]		= { .type = NLA_U32 },
 	[IFLA_TXQLEN]		= { .type = NLA_U32 },
@@ -561,10 +704,15 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINKMODE]		= { .type = NLA_U8 },
 };
 
+static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
+	[IFLA_INFO_NAME]	= { .type = NLA_STRING },
+	[IFLA_INFO_DATA]	= { .type = NLA_NESTED },
+};
+
 static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
-		      struct nlattr **tb, char *ifname)
+		      struct nlattr **tb, char *ifname, int modified)
 {
-	int modified = 0, send_addr_notify = 0;
+	int send_addr_notify = 0;
 	int err;
 
 	if (tb[IFLA_MAP]) {
@@ -729,13 +877,187 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	    nla_len(tb[IFLA_BROADCAST]) < dev->addr_len)
 		goto errout_dev;
 
-	err = do_setlink(dev, ifm, tb, ifname);
+	err = do_setlink(dev, ifm, tb, ifname, 0);
 errout_dev:
 	dev_put(dev);
 errout:
 	return err;
 }
 
+static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	const struct rtnl_link_ops *ops;
+	struct net_device *dev;
+	struct ifinfomsg *ifm;
+	char ifname[IFNAMSIZ];
+	struct nlattr *tb[IFLA_MAX+1];
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[IFLA_IFNAME])
+		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
+
+	ifm = nlmsg_data(nlh);
+	if (ifm->ifi_index > 0)
+		dev = __dev_get_by_index(ifm->ifi_index);
+	else if (tb[IFLA_IFNAME])
+		dev = __dev_get_by_name(ifname);
+	else
+		return -EINVAL;
+
+	if (!dev)
+		return -ENODEV;
+
+	ops = dev->rtnl_link_ops;
+	if (!ops)
+		return -EOPNOTSUPP;
+
+	ops->dellink(dev);
+	return 0;
+}
+
+static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct rtnl_link_ops *ops;
+	struct net_device *dev;
+	struct ifinfomsg *ifm;
+	char name[MODULE_NAME_LEN];
+	char ifname[IFNAMSIZ];
+	struct nlattr *tb[IFLA_MAX+1];
+	struct nlattr *linkinfo[IFLA_INFO_MAX+1];
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[IFLA_IFNAME])
+		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
+	else
+		ifname[0] = '\0';
+
+	ifm = nlmsg_data(nlh);
+	if (ifm->ifi_index > 0)
+		dev = __dev_get_by_index(ifm->ifi_index);
+	else if (ifname[0])
+		dev = __dev_get_by_name(ifname);
+	else
+		dev = NULL;
+
+	if (tb[IFLA_LINKINFO]) {
+		err = nla_parse_nested(linkinfo, IFLA_INFO_MAX,
+				       tb[IFLA_LINKINFO], ifla_info_policy);
+		if (err < 0)
+			return err;
+	} else
+		memset(linkinfo, 0, sizeof(linkinfo));
+
+	if (linkinfo[IFLA_INFO_NAME]) {
+		nla_strlcpy(name, linkinfo[IFLA_INFO_NAME], sizeof(name));
+		ops = rtnl_link_ops_get(name);
+	} else {
+		name[0] = '\0';
+		ops = NULL;
+	}
+
+	if (1) {
+		struct nlattr *attr[ops ? ops->maxtype + 1 : 0], **data = NULL;
+
+		if (ops) {
+			if (ops->maxtype && linkinfo[IFLA_INFO_DATA]) {
+				err = nla_parse_nested(attr, ops->maxtype,
+						       linkinfo[IFLA_INFO_DATA],
+						       ops->policy);
+				if (err < 0)
+					return err;
+				data = attr;
+			}
+			if (ops->validate) {
+				err = ops->validate(tb, data);
+				if (err < 0)
+					return err;
+			}
+		}
+
+		if (dev) {
+			int modified = 0;
+
+			if (nlh->nlmsg_flags & NLM_F_EXCL)
+				return -EEXIST;
+			if (nlh->nlmsg_flags & NLM_F_REPLACE)
+				return -EOPNOTSUPP;
+
+			if (linkinfo[IFLA_INFO_DATA]) {
+				if (!ops || ops != dev->rtnl_link_ops ||
+				    !ops->changelink)
+					return -EOPNOTSUPP;
+
+				err = ops->changelink(dev, tb, data);
+				if (err < 0)
+					return err;
+				modified = 1;
+			}
+
+			return do_setlink(dev, ifm, tb, ifname, modified);
+		}
+
+		if (!(nlh->nlmsg_flags & NLM_F_CREATE))
+			return -ENODEV;
+
+		if (ifm->ifi_index)
+			return -EINVAL;
+		if (tb[IFLA_ADDRESS] || tb[IFLA_BROADCAST] || tb[IFLA_MAP])
+			return -EOPNOTSUPP;
+
+#ifdef CONFIG_KMOD
+		if (!ops && name[0]) {
+			/* race condition: device may be created while rtnl is
+			 * unlocked, final register_netdevice will catch it.
+			 */
+			__rtnl_unlock();
+			request_module("rtnl-link-%s", name);
+			rtnl_lock();
+			ops = rtnl_link_ops_get(name);
+		}
+#endif
+		if (!ops)
+			return -EOPNOTSUPP;
+
+		if (!ifname[0])
+			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->name);
+		dev = alloc_netdev(ops->priv_size, ifname, ops->setup);
+		if (!dev)
+			return -ENOMEM;
+
+		if (strchr(dev->name, '%')) {
+			err = dev_alloc_name(dev, dev->name);
+			if (err < 0)
+				goto err_free;
+		}
+		dev->rtnl_link_ops = ops;
+
+		if (tb[IFLA_MTU])
+			dev->mtu = nla_get_u32(tb[IFLA_MTU]);
+		if (tb[IFLA_TXQLEN])
+			dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
+		if (tb[IFLA_WEIGHT])
+			dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
+		if (tb[IFLA_OPERSTATE])
+			set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
+		if (tb[IFLA_LINKMODE])
+			dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
+
+		err = ops->newlink(dev, tb, data);
+err_free:
+		if (err < 0)
+			free_netdev(dev);
+		return err;
+	}
+}
+
 static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct ifinfomsg *ifm;
@@ -756,7 +1078,7 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	} else
 		return -EINVAL;
 
-	nskb = nlmsg_new(if_nlmsg_size(), GFP_KERNEL);
+	nskb = nlmsg_new(if_nlmsg_size(dev), GFP_KERNEL);
 	if (nskb == NULL) {
 		err = -ENOBUFS;
 		goto errout;
@@ -806,7 +1128,7 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(if_nlmsg_size(), GFP_KERNEL);
+	skb = nlmsg_new(if_nlmsg_size(dev), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
 
@@ -961,6 +1283,8 @@ void __init rtnetlink_init(void)
 
 	rtnl_register(PF_UNSPEC, RTM_GETLINK, rtnl_getlink, rtnl_dump_ifinfo);
 	rtnl_register(PF_UNSPEC, RTM_SETLINK, rtnl_setlink, NULL);
+	rtnl_register(PF_UNSPEC, RTM_NEWLINK, rtnl_newlink, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELLINK, rtnl_dellink, NULL);
 
 	rtnl_register(PF_UNSPEC, RTM_GETADDR, NULL, rtnl_dump_all);
 	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all);
