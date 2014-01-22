From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] rtnetlink: provide api for getting and setting slave info
Date: Wed, 22 Jan 2014 09:05:55 +0100
Message-ID: <1390377957-31466-4-git-send-email-jiri@resnulli.us>
References: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:63061 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbaAVIGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 03:06:09 -0500
Received: by mail-ee0-f51.google.com with SMTP id b57so4622579eek.38
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 00:06:07 -0800 (PST)
In-Reply-To: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent patch
bonding: add netlink attributes to slave link dev (1d3ee88ae0d6)

Introduced yet another device specific way to access slave information
over rtnetlink. There is one already there for bridge.

This patch introduces generic way to do this, for getting and setting
info as well by extending link_ops. Later on, this new interface will
be used for bridge ports as well.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/rtnetlink.h      |  14 ++++
 include/uapi/linux/if_link.h |   2 +
 net/core/rtnetlink.c         | 158 +++++++++++++++++++++++++++++++++++++------
 3 files changed, 154 insertions(+), 20 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 8fb4207..661e45d 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -79,6 +79,20 @@ struct rtnl_link_ops {
 					       const struct net_device *dev);
 	unsigned int		(*get_num_tx_queues)(void);
 	unsigned int		(*get_num_rx_queues)(void);
+
+	int			slave_maxtype;
+	const struct nla_policy	*slave_policy;
+	int			(*slave_validate)(struct nlattr *tb[],
+						  struct nlattr *data[]);
+	int			(*slave_changelink)(struct net_device *dev,
+						    struct net_device *slave_dev,
+						    struct nlattr *tb[],
+						    struct nlattr *data[]);
+	size_t			(*get_slave_size)(const struct net_device *dev,
+						  const struct net_device *slave_dev);
+	int			(*fill_slave_info)(struct sk_buff *skb,
+						   const struct net_device *dev,
+						   const struct net_device *slave_dev);
 };
 
 int __rtnl_link_register(struct rtnl_link_ops *ops);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 1f30b85..b8fb352 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -241,6 +241,8 @@ enum {
 	IFLA_INFO_KIND,
 	IFLA_INFO_DATA,
 	IFLA_INFO_XSTATS,
+	IFLA_INFO_SLAVE_KIND,
+	IFLA_INFO_SLAVE_DATA,
 	__IFLA_INFO_MAX,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index cace149..a56bccf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -365,6 +365,22 @@ void rtnl_link_unregister(struct rtnl_link_ops *ops)
 }
 EXPORT_SYMBOL_GPL(rtnl_link_unregister);
 
+static size_t rtnl_link_get_slave_info_data_size(const struct net_device *dev)
+{
+	struct net_device *master_dev;
+	const struct rtnl_link_ops *ops;
+
+	master_dev = netdev_master_upper_dev_get((struct net_device *) dev);
+	if (!master_dev)
+		return 0;
+	ops = master_dev->rtnl_link_ops;
+	if (!ops->get_slave_size)
+		return 0;
+	/* IFLA_INFO_SLAVE_DATA + nested data */
+	return nla_total_size(sizeof(struct nlattr)) +
+	       ops->get_slave_size(master_dev, dev);
+}
+
 static size_t rtnl_link_get_size(const struct net_device *dev)
 {
 	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
@@ -385,6 +401,8 @@ static size_t rtnl_link_get_size(const struct net_device *dev)
 		/* IFLA_INFO_XSTATS */
 		size += nla_total_size(ops->get_xstats_size(dev));
 
+	size += rtnl_link_get_slave_info_data_size(dev);
+
 	return size;
 }
 
@@ -459,40 +477,101 @@ static size_t rtnl_link_get_af_size(const struct net_device *dev)
 	return size;
 }
 
-static int rtnl_link_fill(struct sk_buff *skb, const struct net_device *dev)
+static bool rtnl_have_link_slave_info(const struct net_device *dev)
 {
-	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
-	struct nlattr *linkinfo, *data;
-	int err = -EMSGSIZE;
+	struct net_device *master_dev;
 
-	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
-	if (linkinfo == NULL)
-		goto out;
+	master_dev = netdev_master_upper_dev_get((struct net_device *) dev);
+	if (master_dev && master_dev->rtnl_link_ops &&
+	    master_dev->rtnl_link_ops->fill_slave_info)
+		return true;
+	return false;
+}
+
+static int rtnl_link_slave_info_fill(struct sk_buff *skb,
+				     const struct net_device *dev)
+{
+	struct net_device *master_dev;
+	const struct rtnl_link_ops *ops;
+	struct nlattr *slave_data;
+	int err;
 
+	master_dev = netdev_master_upper_dev_get((struct net_device *) dev);
+	if (!master_dev)
+		return 0;
+	ops = master_dev->rtnl_link_ops;
+	if (!ops)
+		return 0;
+	if (nla_put_string(skb, IFLA_INFO_SLAVE_KIND, ops->kind) < 0)
+		return -EMSGSIZE;
+	if (ops->fill_slave_info) {
+		slave_data = nla_nest_start(skb, IFLA_INFO_SLAVE_DATA);
+		if (!slave_data)
+			return -EMSGSIZE;
+		err = ops->fill_slave_info(skb, master_dev, dev);
+		if (err < 0)
+			goto err_cancel_slave_data;
+		nla_nest_end(skb, slave_data);
+	}
+	return 0;
+
+err_cancel_slave_data:
+	nla_nest_cancel(skb, slave_data);
+	return err;
+}
+
+static int rtnl_link_info_fill(struct sk_buff *skb,
+			       const struct net_device *dev)
+{
+	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+	struct nlattr *data;
+	int err;
+
+	if (!ops)
+		return 0;
 	if (nla_put_string(skb, IFLA_INFO_KIND, ops->kind) < 0)
-		goto err_cancel_link;
+		return -EMSGSIZE;
 	if (ops->fill_xstats) {
 		err = ops->fill_xstats(skb, dev);
 		if (err < 0)
-			goto err_cancel_link;
+			return err;
 	}
 	if (ops->fill_info) {
 		data = nla_nest_start(skb, IFLA_INFO_DATA);
-		if (data == NULL) {
-			err = -EMSGSIZE;
-			goto err_cancel_link;
-		}
+		if (data == NULL)
+			return -EMSGSIZE;
 		err = ops->fill_info(skb, dev);
 		if (err < 0)
 			goto err_cancel_data;
 		nla_nest_end(skb, data);
 	}
-
-	nla_nest_end(skb, linkinfo);
 	return 0;
 
 err_cancel_data:
 	nla_nest_cancel(skb, data);
+	return err;
+}
+
+static int rtnl_link_fill(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct nlattr *linkinfo;
+	int err = -EMSGSIZE;
+
+	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
+	if (linkinfo == NULL)
+		goto out;
+
+	err = rtnl_link_info_fill(skb, dev);
+	if (err < 0)
+		goto err_cancel_link;
+
+	err = rtnl_link_slave_info_fill(skb, dev);
+	if (err < 0)
+		goto err_cancel_link;
+
+	nla_nest_end(skb, linkinfo);
+	return 0;
+
 err_cancel_link:
 	nla_nest_cancel(skb, linkinfo);
 out:
@@ -1052,10 +1131,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_port_fill(skb, dev))
 		goto nla_put_failure;
 
-	if (rtnl_bond_slave_fill(skb, dev))
-		goto nla_put_failure;
-
-	if (dev->rtnl_link_ops) {
+	if (dev->rtnl_link_ops || rtnl_have_link_slave_info(dev)) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
 	}
@@ -1178,6 +1254,8 @@ EXPORT_SYMBOL(ifla_policy);
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
 	[IFLA_INFO_KIND]	= { .type = NLA_STRING },
 	[IFLA_INFO_DATA]	= { .type = NLA_NESTED },
+	[IFLA_INFO_SLAVE_KIND]	= { .type = NLA_STRING },
+	[IFLA_INFO_SLAVE_DATA]	= { .type = NLA_NESTED },
 };
 
 static const struct nla_policy ifla_vfinfo_policy[IFLA_VF_INFO_MAX+1] = {
@@ -1765,7 +1843,9 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	const struct rtnl_link_ops *ops;
+	const struct rtnl_link_ops *m_ops = NULL;
 	struct net_device *dev;
+	struct net_device *master_dev = NULL;
 	struct ifinfomsg *ifm;
 	char kind[MODULE_NAME_LEN];
 	char ifname[IFNAMSIZ];
@@ -1795,6 +1875,12 @@ replay:
 			dev = NULL;
 	}
 
+	if (dev) {
+		master_dev = netdev_master_upper_dev_get(dev);
+		if (master_dev)
+			m_ops = master_dev->rtnl_link_ops;
+	}
+
 	err = validate_linkmsg(dev, tb);
 	if (err < 0)
 		return err;
@@ -1816,7 +1902,10 @@ replay:
 	}
 
 	if (1) {
-		struct nlattr *attr[ops ? ops->maxtype + 1 : 0], **data = NULL;
+		struct nlattr *attr[ops ? ops->maxtype + 1 : 0];
+		struct nlattr *slave_attr[m_ops ? m_ops->slave_maxtype + 1 : 0];
+		struct nlattr **data = NULL;
+		struct nlattr **slave_data = NULL;
 		struct net *dest_net;
 
 		if (ops) {
@@ -1835,6 +1924,24 @@ replay:
 			}
 		}
 
+		if (m_ops) {
+			if (m_ops->slave_maxtype &&
+			    linkinfo[IFLA_INFO_SLAVE_DATA]) {
+				err = nla_parse_nested(slave_attr,
+						       m_ops->slave_maxtype,
+						       linkinfo[IFLA_INFO_SLAVE_DATA],
+						       m_ops->slave_policy);
+				if (err < 0)
+					return err;
+				slave_data = slave_attr;
+			}
+			if (m_ops->slave_validate) {
+				err = m_ops->slave_validate(tb, slave_data);
+				if (err < 0)
+					return err;
+			}
+		}
+
 		if (dev) {
 			int modified = 0;
 
@@ -1854,6 +1961,17 @@ replay:
 				modified = 1;
 			}
 
+			if (linkinfo[IFLA_INFO_SLAVE_DATA]) {
+				if (!m_ops || !m_ops->slave_changelink)
+					return -EOPNOTSUPP;
+
+				err = m_ops->slave_changelink(master_dev, dev,
+							      tb, slave_data);
+				if (err < 0)
+					return err;
+				modified = 1;
+			}
+
 			return do_setlink(dev, ifm, tb, ifname, modified);
 		}
 
-- 
1.8.3.1
