From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] ipv6: add support for stats via RTM_GETSTATS
Date: Sat, 12 Mar 2016 17:56:26 -0800
Message-ID: <1457834186-45727-3-git-send-email-roopa@cumulusnetworks.com>
Cc: jhs@mojatatu.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35357 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090AbcCMB4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 20:56:33 -0500
Received: by mail-pf0-f181.google.com with SMTP id n5so71995318pfn.2
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 17:56:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch is an example of adding af stats in
RTM_GETSTATS. It adds a new nested IFLA_STATS_INET6
attribute for ipv6 af stats. stats attributes inside
IFLA_STATS_INET6 nested attribute use the existing ipv6 stats
attributes from ipv6 IFLA_PROTINFO (I can certainly declare
new attributes if required)

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
I have added this patch only to show an example of af stats.
I have tested it to work. My real intent is to have
IFLA_STATS_MPLS implemented in the same way for mpls.
We could rethink ipv6 stats in a new way instead of carrying
over the older ipv6 stats which i am doing here.
I am not sure how popular the current ipv6 stats are.
I have not used them. Adding this note here if people prefer
dropping this and revisiting ipv6 stats at a later point.

 net/core/rtnetlink.c |  1 +
 net/ipv6/addrconf.c  | 77 ++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 70 insertions(+), 8 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d1e3d17..00a04e5 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3464,6 +3464,7 @@ nla_put_failure:
 
 static const struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
 	[IFLA_STATS_LINK64]	= { .len = sizeof(struct rtnl_link_stats64) },
+	[IFLA_STATS_INET6]      = {. type = NLA_NESTED },
 };
 
 static size_t rtnl_link_get_af_stats_size(const struct net_device *dev,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8c0dab2..d700647 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4911,6 +4911,29 @@ static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
 	}
 }
 
+static int inet6_fill_ifla6_stats(struct sk_buff *skb,
+				  struct inet6_dev *idev)
+{
+	struct nlattr *nla;
+
+	nla = nla_reserve(skb, IFLA_INET6_STATS, IPSTATS_MIB_MAX * sizeof(u64));
+	if (!nla)
+		goto nla_put_failure;
+	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_STATS, nla_len(nla));
+
+	nla = nla_reserve(skb, IFLA_INET6_ICMP6STATS,
+			  ICMP6_MIB_MAX * sizeof(u64));
+	if (!nla)
+		goto nla_put_failure;
+	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_ICMP6STATS,
+			 nla_len(nla));
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
 static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev,
 				  u32 ext_filter_mask)
 {
@@ -4935,15 +4958,8 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev,
 	if (ext_filter_mask & RTEXT_FILTER_SKIP_STATS)
 		return 0;
 
-	nla = nla_reserve(skb, IFLA_INET6_STATS, IPSTATS_MIB_MAX * sizeof(u64));
-	if (!nla)
-		goto nla_put_failure;
-	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_STATS, nla_len(nla));
-
-	nla = nla_reserve(skb, IFLA_INET6_ICMP6STATS, ICMP6_MIB_MAX * sizeof(u64));
-	if (!nla)
+	if (inet6_fill_ifla6_stats(skb, idev))
 		goto nla_put_failure;
-	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_ICMP6STATS, nla_len(nla));
 
 	nla = nla_reserve(skb, IFLA_INET6_TOKEN, sizeof(struct in6_addr));
 	if (!nla)
@@ -4985,6 +5001,49 @@ static int inet6_fill_link_af(struct sk_buff *skb, const struct net_device *dev,
 	return 0;
 }
 
+static size_t inet6_get_link_af_stats_size(const struct net_device *dev,
+					   u32 filter_mask)
+{
+	if (!(filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_INET6)))
+		return 0;
+
+	if (!__in6_dev_get(dev))
+		return 0;
+
+	return nla_total_size(sizeof(struct nlattr)) /* IFLA_STATS_INET6 */
+		+ nla_total_size(IPSTATS_MIB_MAX * 8) /* IFLA_INET6_STATS */
+		+ nla_total_size(ICMP6_MIB_MAX * sizeof(u64));/* IFLA_INET6_ICMP6STATS */
+}
+
+static int inet6_fill_link_af_stats(struct sk_buff *skb,
+				    const struct net_device *dev,
+				    u32 filter_mask)
+{
+	struct inet6_dev *idev = __in6_dev_get(dev);
+	struct nlattr *inet6_stats;
+
+	if (!(filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_INET6)))
+		return 0;
+
+	if (!idev)
+		return -ENODATA;
+
+	inet6_stats = nla_nest_start(skb, IFLA_STATS_INET6);
+	if (!inet6_stats)
+		return -EMSGSIZE;
+
+	if (inet6_fill_ifla6_stats(skb, idev) < 0)
+		goto errout;
+
+	nla_nest_end(skb, inet6_stats);
+
+	return 0;
+errout:
+	nla_nest_cancel(skb, inet6_stats);
+
+	return -EMSGSIZE;
+}
+
 static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 {
 	struct inet6_ifaddr *ifp;
@@ -6079,6 +6138,8 @@ static struct rtnl_af_ops inet6_ops __read_mostly = {
 	.get_link_af_size = inet6_get_link_af_size,
 	.validate_link_af = inet6_validate_link_af,
 	.set_link_af	  = inet6_set_link_af,
+	.get_link_af_stats_size = inet6_get_link_af_stats_size,
+	.fill_link_af_stats = inet6_fill_link_af_stats,
 };
 
 /*
-- 
1.9.1
