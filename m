From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH net-next-2.6]: rtnl: make link af-specific updates atomic
Date: Mon, 22 Nov 2010 06:31:54 -0500
Message-ID: <20101122113154.GA16382@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:33491 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696Ab0KVLbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 06:31:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As David pointed out correctly, updates to af-specific attributes
are currently not atomic. If multiple changes are requested and
one of them fails, previous updates may have been applied already
leaving the link behind in a undefined state.

This patch splits the function parse_link_af() into two functions
validate_link_af() and set_link_at(). validate_link_af() is placed
to validate_linkmsg() check for errors as early as possible before
any changes to the link have been made. set_link_af() is called to
commit the changes later.

This method is not fail proof, while it is currently sufficient
to make set_link_af() inerrable and thus 100% atomic, the
validation function method will not be able to detect all error
scenarios in the future, there will likely always be errors
depending on states which are f.e. not protected by rtnl_mutex
and thus may change between validation and setting.

Also, instead of silently ignoring unknown address families and
config blocks for address families which did not register a set
function the errors EAFNOSUPPORT respectively EOPNOSUPPORT are
returned to avoid comitting 4 out of 5 update requests without
notifying the user.

Signed-off-by: Thomas Graf <tgraf@infradead.org>

Index: net-next-2.6/include/net/rtnetlink.h
===================================================================
--- net-next-2.6.orig/include/net/rtnetlink.h
+++ net-next-2.6/include/net/rtnetlink.h
@@ -92,8 +92,10 @@ extern void	rtnl_link_unregister(struct 
  * 		       specific netlink attributes.
  * 	@get_link_af_size: Function to calculate size of address family specific
  * 			   netlink attributes exlusive the container attribute.
- * 	@parse_link_af: Function to parse a IFLA_AF_SPEC attribute and modify
- *			net_device accordingly.
+ *	@validate_link_af: Validate a IFLA_AF_SPEC attribute, must check attr
+ *			   for invalid configuration settings.
+ * 	@set_link_af: Function to parse a IFLA_AF_SPEC attribute and modify
+ *		      net_device accordingly.
  */
 struct rtnl_af_ops {
 	struct list_head	list;
@@ -103,8 +105,10 @@ struct rtnl_af_ops {
 						const struct net_device *dev);
 	size_t			(*get_link_af_size)(const struct net_device *dev);
 
-	int			(*parse_link_af)(struct net_device *dev,
-						 const struct nlattr *attr);
+	int			(*validate_link_af)(const struct net_device *dev,
+						    const struct nlattr *attr);
+	int			(*set_link_af)(struct net_device *dev,
+					       const struct nlattr *attr);
 };
 
 extern int	__rtnl_af_register(struct rtnl_af_ops *ops);
Index: net-next-2.6/net/core/rtnetlink.c
===================================================================
--- net-next-2.6.orig/net/core/rtnetlink.c
+++ net-next-2.6/net/core/rtnetlink.c
@@ -1107,6 +1107,28 @@ static int validate_linkmsg(struct net_d
 			return -EINVAL;
 	}
 
+	if (tb[IFLA_AF_SPEC]) {
+		struct nlattr *af;
+		int rem, err;
+
+		nla_for_each_nested(af, tb[IFLA_AF_SPEC], rem) {
+			const struct rtnl_af_ops *af_ops;
+
+			if (!(af_ops = rtnl_af_lookup(nla_type(af))))
+				return -EAFNOSUPPORT;
+
+			if (!af_ops->set_link_af)
+				return -EOPNOTSUPP;
+
+			if (af_ops->validate_link_af) {
+				err = af_ops->validate_link_af(dev,
+			    				tb[IFLA_AF_SPEC]);
+				if (err < 0)
+					return err;
+			}
+		}
+	}
+
 	return 0;
 }
 
@@ -1356,12 +1378,9 @@ static int do_setlink(struct net_device 
 			const struct rtnl_af_ops *af_ops;
 
 			if (!(af_ops = rtnl_af_lookup(nla_type(af))))
-				continue;
-
-			if (!af_ops->parse_link_af)
-				continue;
+				BUG();
 
-			err = af_ops->parse_link_af(dev, af);
+			err = af_ops->set_link_af(dev, af);
 			if (err < 0)
 				goto errout;
 
Index: net-next-2.6/net/ipv4/devinet.c
===================================================================
--- net-next-2.6.orig/net/ipv4/devinet.c
+++ net-next-2.6/net/ipv4/devinet.c
@@ -1289,14 +1289,14 @@ static const struct nla_policy inet_af_p
 	[IFLA_INET_CONF]	= { .type = NLA_NESTED },
 };
 
-static int inet_parse_link_af(struct net_device *dev, const struct nlattr *nla)
+static int inet_validate_link_af(const struct net_device *dev,
+				 const struct nlattr *nla)
 {
-	struct in_device *in_dev = __in_dev_get_rcu(dev);
 	struct nlattr *a, *tb[IFLA_INET_MAX+1];
 	int err, rem;
 
-	if (!in_dev)
-		return -EOPNOTSUPP;
+	if (dev && !__in_dev_get_rcu(dev))
+		return -EAFNOSUPPORT;
 
 	err = nla_parse_nested(tb, IFLA_INET_MAX, nla, inet_af_policy);
 	if (err < 0)
@@ -1314,6 +1314,21 @@ static int inet_parse_link_af(struct net
 		}
 	}
 
+	return 0;
+}
+
+static int inet_set_link_af(struct net_device *dev, const struct nlattr *nla)
+{
+	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	struct nlattr *a, *tb[IFLA_INET_MAX+1];
+	int rem;
+
+	if (!in_dev)
+		return -EAFNOSUPPORT;
+
+	if (nla_parse_nested(tb, IFLA_INET_MAX, nla, NULL) < 0)
+		BUG();
+
 	if (tb[IFLA_INET_CONF]) {
 		nla_for_each_nested(a, tb[IFLA_INET_CONF], rem)
 			ipv4_devconf_set(in_dev, nla_type(a), nla_get_u32(a));
@@ -1689,7 +1704,8 @@ static struct rtnl_af_ops inet_af_ops = 
 	.family		  = AF_INET,
 	.fill_link_af	  = inet_fill_link_af,
 	.get_link_af_size = inet_get_link_af_size,
-	.parse_link_af	  = inet_parse_link_af,
+	.validate_link_af = inet_validate_link_af,
+	.set_link_af	  = inet_set_link_af,
 };
 
 void __init devinet_init(void)
Index: net-next-2.6/net/ipv6/addrconf.c
===================================================================
--- net-next-2.6.orig/net/ipv6/addrconf.c
+++ net-next-2.6/net/ipv6/addrconf.c
@@ -3956,11 +3956,6 @@ static int inet6_fill_link_af(struct sk_
 	return 0;
 }
 
-static int inet6_parse_link_af(struct net_device *dev, const struct nlattr *nla)
-{
-	return -EOPNOTSUPP;
-}
-
 static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 			     u32 pid, u32 seq, int event, unsigned int flags)
 {
@@ -4670,7 +4665,6 @@ static struct rtnl_af_ops inet6_ops = {
 	.family		  = AF_INET6,
 	.fill_link_af	  = inet6_fill_link_af,
 	.get_link_af_size = inet6_get_link_af_size,
-	.parse_link_af	  = inet6_parse_link_af,
 };
 
 /*
