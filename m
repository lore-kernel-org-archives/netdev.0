From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v3 net-next] rtnetlink: RTEXT_FILTER_SKIP_STATS support to
 avoid dumping inet/inet6 stats
Date: Fri, 11 Sep 2015 16:48:48 -0400
Message-ID: <20150911204848.GC9687@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, raghavendra.kt@linux.vnet.ibm.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com,
	jose.marchesi@oracle.com
To: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30643 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbbIKUtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 16:49:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Many commonly used functions like getifaddrs() invoke RTM_GETLINK
to dump the interface information, and do not need the
the AF_INET6 statististics that are always returned by default
from rtnl_fill_ifinfo().

Computing the statistics can be an expensive operation that impacts
scaling, so it is desirable to avoid this if the information is
not needed.

This patch adds a the RTEXT_FILTER_SKIP_STATS extended info flag that
can be passed with netlink_request() to avoid statistics computation
for the ifinfo path.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: David Miller comments: pass u32 ext_filter_mask down.
v3: non-RFC version of v2.

 include/net/rtnetlink.h        |    3 ++-
 include/uapi/linux/rtnetlink.h |    1 +
 net/core/rtnetlink.c           |    2 +-
 net/ipv4/devinet.c             |    3 ++-
 net/ipv6/addrconf.c            |   13 +++++++++----
 5 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 18fdb98..aff6ceb 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -122,7 +122,8 @@ struct rtnl_af_ops {
 	int			family;
 
 	int			(*fill_link_af)(struct sk_buff *skb,
-						const struct net_device *dev);
+						const struct net_device *dev,
+						u32 ext_filter_mask);
 	size_t			(*get_link_af_size)(const struct net_device *dev);
 
 	int			(*validate_link_af)(const struct net_device *dev,
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 7020247..434227f 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -666,6 +666,7 @@ struct tcamsg {
 #define RTEXT_FILTER_VF		(1 << 0)
 #define RTEXT_FILTER_BRVLAN	(1 << 1)
 #define RTEXT_FILTER_BRVLAN_COMPRESSED	(1 << 2)
+#define	RTEXT_FILTER_SKIP_STATS	(1 << 3)
 
 /* End of information exported to user level */
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a466821..e545229 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1272,7 +1272,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			if (!(af = nla_nest_start(skb, af_ops->family)))
 				goto nla_put_failure;
 
-			err = af_ops->fill_link_af(skb, dev);
+			err = af_ops->fill_link_af(skb, dev, ext_filter_mask);
 
 			/*
 			 * Caller may return ENODATA to indicate that there
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 2d9cb17..7350084 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1654,7 +1654,8 @@ static size_t inet_get_link_af_size(const struct net_device *dev)
 	return nla_total_size(IPV4_DEVCONF_MAX * 4); /* IFLA_INET_CONF */
 }
 
-static int inet_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
+static int inet_fill_link_af(struct sk_buff *skb, const struct net_device *dev,
+			     u32 ext_filter_mask)
 {
 	struct in_device *in_dev = rcu_dereference_rtnl(dev->ip_ptr);
 	struct nlattr *nla;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 99c0f2b..9acbb09 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4760,7 +4760,8 @@ static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
 	}
 }
 
-static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev)
+static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev,
+				  u32 ext_filter_mask)
 {
 	struct nlattr *nla;
 	struct ifla_cacheinfo ci;
@@ -4780,6 +4781,9 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev)
 
 	/* XXX - MC not implemented */
 
+	if (!!(ext_filter_mask & RTEXT_FILTER_SKIP_STATS))
+		return 0;
+
 	nla = nla_reserve(skb, IFLA_INET6_STATS, IPSTATS_MIB_MAX * sizeof(u64));
 	if (!nla)
 		goto nla_put_failure;
@@ -4815,14 +4819,15 @@ static size_t inet6_get_link_af_size(const struct net_device *dev)
 	return inet6_ifla6_size();
 }
 
-static int inet6_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
+static int inet6_fill_link_af(struct sk_buff *skb, const struct net_device *dev,
+			      u32 ext_filter_mask)
 {
 	struct inet6_dev *idev = __in6_dev_get(dev);
 
 	if (!idev)
 		return -ENODATA;
 
-	if (inet6_fill_ifla6_attrs(skb, idev) < 0)
+	if (inet6_fill_ifla6_attrs(skb, idev, ext_filter_mask) < 0)
 		return -EMSGSIZE;
 
 	return 0;
@@ -4977,7 +4982,7 @@ static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 	if (!protoinfo)
 		goto nla_put_failure;
 
-	if (inet6_fill_ifla6_attrs(skb, idev) < 0)
+	if (inet6_fill_ifla6_attrs(skb, idev, 0) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, protoinfo);
-- 
1.7.1
