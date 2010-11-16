From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH net-next 1/4] rtnetlink: Link address family API
Date: Tue, 16 Nov 2010 09:30:14 -0500
Message-ID: <20101116143014.GA26669@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:32991 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933907Ab0KPOaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 09:30:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each net_device contains address family specific data such as
per device settings and statistics. We already expose this data
via procfs/sysfs and partially netlink.

The netlink method requires the requester to send one RTM_GETLINK
request for each address family it wishes to receive data of
and then merge this data itself.

This patch implements a new API which combines all address family
specific link data in a new netlink attribute IFLA_AF_SPEC.
IFLA_AF_SPEC contains a sequence of nested attributes, one for each
address family which in turn defines the structure of its own
attribute. Example:

   [IFLA_AF_SPEC] = {
       [AF_INET] = {
           [IFLA_INET_CONF] = ...,
       },
       [AF_INET6] = {
           [IFLA_INET6_FLAGS] = ...,
           [IFLA_INET6_CONF] = ...,
       }
   }

The API also allows for address families to implement a function
which parses the IFLA_AF_SPEC attribute sent by userspace to
implement address family specific link options.

Signed-off-by: Thomas Graf <tgraf@infradead.org>

Index: net-2.6/include/linux/if_link.h
===================================================================
--- net-2.6.orig/include/linux/if_link.h
+++ net-2.6/include/linux/if_link.h
@@ -80,6 +80,24 @@ struct rtnl_link_ifmap {
 	__u8	port;
 };
 
+/*
+ * IFLA_AF_SPEC
+ *   Contains nested attributes for address family specific attributes.
+ *   Each address family may create a attribute with the address family
+ *   number as type and create its own attribute structure in it.
+ *
+ *   Example:
+ *   [IFLA_AF_SPEC] = {
+ *       [AF_INET] = {
+ *           [IFLA_INET_CONF] = ...,
+ *       },
+ *       [AF_INET6] = {
+ *           [IFLA_INET6_FLAGS] = ...,
+ *           [IFLA_INET6_CONF] = ...,
+ *       }
+ *   }
+ */
+
 enum {
 	IFLA_UNSPEC,
 	IFLA_ADDRESS,
@@ -116,6 +134,7 @@ enum {
 	IFLA_STATS64,
 	IFLA_VF_PORTS,
 	IFLA_PORT_SELF,
+	IFLA_AF_SPEC,
 	__IFLA_MAX
 };
 
Index: net-2.6/include/net/rtnetlink.h
===================================================================
--- net-2.6.orig/include/net/rtnetlink.h
+++ net-2.6/include/net/rtnetlink.h
@@ -83,6 +83,37 @@ extern void	__rtnl_link_unregister(struc
 extern int	rtnl_link_register(struct rtnl_link_ops *ops);
 extern void	rtnl_link_unregister(struct rtnl_link_ops *ops);
 
+/**
+ * 	struct rtnl_af_ops - rtnetlink address family operations
+ *
+ *	@list: Used internally
+ * 	@family: Address family
+ * 	@fill_link_af: Function to fill IFLA_AF_SPEC with address family
+ * 		       specific netlink attributes.
+ * 	@get_link_af_size: Function to calculate size of address family specific
+ * 			   netlink attributes exlusive the container attribute.
+ * 	@parse_link_af: Function to parse a IFLA_AF_SPEC attribute and modify
+ *			net_device accordingly.
+ */
+struct rtnl_af_ops {
+	struct list_head	list;
+	int			family;
+
+	int			(*fill_link_af)(struct sk_buff *skb,
+						const struct net_device *dev);
+	size_t			(*get_link_af_size)(const struct net_device *dev);
+
+	int			(*parse_link_af)(struct net_device *dev,
+						 const struct nlattr *attr);
+};
+
+extern int	__rtnl_af_register(struct rtnl_af_ops *ops);
+extern void	__rtnl_af_unregister(struct rtnl_af_ops *ops);
+
+extern int	rtnl_af_register(struct rtnl_af_ops *ops);
+extern void	rtnl_af_unregister(struct rtnl_af_ops *ops);
+
+
 extern struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[]);
 extern struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
 	char *ifname, const struct rtnl_link_ops *ops, struct nlattr *tb[]);
Index: net-2.6/net/core/rtnetlink.c
===================================================================
--- net-2.6.orig/net/core/rtnetlink.c
+++ net-2.6/net/core/rtnetlink.c
@@ -362,6 +362,95 @@ static size_t rtnl_link_get_size(const s
 	return size;
 }
 
+static LIST_HEAD(rtnl_af_ops);
+
+static const struct rtnl_af_ops *rtnl_af_lookup(const int family)
+{
+	const struct rtnl_af_ops *ops;
+
+	list_for_each_entry(ops, &rtnl_af_ops, list) {
+		if (ops->family == family)
+			return ops;
+	}
+
+	return NULL;
+}
+
+/**
+ * __rtnl_af_register - Register rtnl_af_ops with rtnetlink.
+ * @ops: struct rtnl_af_ops * to register
+ *
+ * The caller must hold the rtnl_mutex.
+ *
+ * Returns 0 on success or a negative error code.
+ */
+int __rtnl_af_register(struct rtnl_af_ops *ops)
+{
+	list_add_tail(&ops->list, &rtnl_af_ops);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__rtnl_af_register);
+
+/**
+ * rtnl_af_register - Register rtnl_af_ops with rtnetlink.
+ * @ops: struct rtnl_af_ops * to register
+ *
+ * Returns 0 on success or a negative error code.
+ */
+int rtnl_af_register(struct rtnl_af_ops *ops)
+{
+	int err;
+
+	rtnl_lock();
+	err = __rtnl_af_register(ops);
+	rtnl_unlock();
+	return err;
+}
+EXPORT_SYMBOL_GPL(rtnl_af_register);
+
+/**
+ * __rtnl_af_unregister - Unregister rtnl_af_ops from rtnetlink.
+ * @ops: struct rtnl_af_ops * to unregister
+ *
+ * The caller must hold the rtnl_mutex.
+ */
+void __rtnl_af_unregister(struct rtnl_af_ops *ops)
+{
+	list_del(&ops->list);
+}
+EXPORT_SYMBOL_GPL(__rtnl_af_unregister);
+
+/**
+ * rtnl_af_unregister - Unregister rtnl_af_ops from rtnetlink.
+ * @ops: struct rtnl_af_ops * to unregister
+ */
+void rtnl_af_unregister(struct rtnl_af_ops *ops)
+{
+	rtnl_lock();
+	__rtnl_af_unregister(ops);
+	rtnl_unlock();
+}
+EXPORT_SYMBOL_GPL(rtnl_af_unregister);
+
+static size_t rtnl_link_get_af_size(const struct net_device *dev)
+{
+	struct rtnl_af_ops *af_ops;
+	size_t size;
+
+	/* IFLA_AF_SPEC */
+	size = nla_total_size(sizeof(struct nlattr));
+
+	list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+		if (af_ops->get_link_af_size) {
+			/* AF_* + nested data */
+			size += nla_total_size(sizeof(struct nlattr)) +
+				af_ops->get_link_af_size(dev);
+		}
+	}
+
+	return size;
+}
+
 static int rtnl_link_fill(struct sk_buff *skb, const struct net_device *dev)
 {
 	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
@@ -671,7 +760,8 @@ static noinline size_t if_nlmsg_size(con
 	       + nla_total_size(4) /* IFLA_NUM_VF */
 	       + rtnl_vfinfo_size(dev) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
-	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
+	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
+	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
 }
 
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
@@ -757,7 +847,8 @@ static int rtnl_fill_ifinfo(struct sk_bu
 	struct nlmsghdr *nlh;
 	struct rtnl_link_stats64 temp;
 	const struct rtnl_link_stats64 *stats;
-	struct nlattr *attr;
+	struct nlattr *attr, *af_spec;
+	struct rtnl_af_ops *af_ops;
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
 	if (nlh == NULL)
@@ -866,6 +957,36 @@ static int rtnl_fill_ifinfo(struct sk_bu
 			goto nla_put_failure;
 	}
 
+	if (!(af_spec = nla_nest_start(skb, IFLA_AF_SPEC)))
+		goto nla_put_failure;
+
+	list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+		if (af_ops->fill_link_af) {
+			struct nlattr *af;
+			int err;
+
+			if (!(af = nla_nest_start(skb, af_ops->family)))
+				goto nla_put_failure;
+
+			err = af_ops->fill_link_af(skb, dev);
+
+			/*
+			 * Caller may return ENODATA to indicate that there
+			 * was no data to be dumped. This is not an error, it
+			 * means we should trim the attribute header and
+			 * continue.
+			 */
+			if (err == -ENODATA)
+				nla_nest_cancel(skb, af);
+			else if (err < 0)
+				goto nla_put_failure;
+
+			nla_nest_end(skb, af);
+		}
+	}
+
+	nla_nest_end(skb, af_spec);
+
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -924,6 +1045,7 @@ const struct nla_policy ifla_policy[IFLA
 	[IFLA_VFINFO_LIST]	= {. type = NLA_NESTED },
 	[IFLA_VF_PORTS]		= { .type = NLA_NESTED },
 	[IFLA_PORT_SELF]	= { .type = NLA_NESTED },
+	[IFLA_AF_SPEC]		= { .type = NLA_NESTED },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1225,6 +1347,27 @@ static int do_setlink(struct net_device 
 			goto errout;
 		modified = 1;
 	}
+
+	if (tb[IFLA_AF_SPEC]) {
+		struct nlattr *af;
+		int rem;
+
+		nla_for_each_nested(af, tb[IFLA_AF_SPEC], rem) {
+			const struct rtnl_af_ops *af_ops;
+
+			if (!(af_ops = rtnl_af_lookup(nla_type(af))))
+				continue;
+
+			if (!af_ops->parse_link_af)
+				continue;
+
+			err = af_ops->parse_link_af(dev, af);
+			if (err < 0)
+				goto errout;
+
+			modified = 1;
+		}
+	}
 	err = 0;
 
 errout:
