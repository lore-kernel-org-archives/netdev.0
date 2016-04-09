From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next RFC v2 2/2] ipv6: add support for stats via RTM_GETSTATS
Date: Fri,  8 Apr 2016 23:38:12 -0700
Message-ID: <1460183892-57286-3-git-send-email-roopa@cumulusnetworks.com>
Cc: jhs@mojatatu.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35103 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbcDIGiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 02:38:18 -0400
Received: by mail-pa0-f50.google.com with SMTP id td3so87423317pab.2
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 23:38:18 -0700 (PDT)
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
This patch is an example of af stats hooked into the new stats
infrastructure. I have tested it to work. My real intent is to have
IFLA_STATS_MPLS implemented in the same way for mpls.
I am not sure how popular the current ipv6 stats are.
Instead of carrying over the old ipv6 stats, we 
We could rethink ipv6 stats in a new way when people see the need
for it.

 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         |  1 +
 net/ipv6/addrconf.c          | 77 +++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 71 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 4cfd029..e0b51c8 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -791,6 +791,7 @@ struct if_stats_msg {
 enum {
 	IFLA_STATS_UNSPEC,
 	IFLA_STATS_LINK64,
+	IFLA_STATS_INET6,
 	__IFLA_STATS_MAX,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d1fba58..9c6cff1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3505,6 +3505,7 @@ nla_put_failure:
 
 static const struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
 	[IFLA_STATS_LINK64]	= { .len = sizeof(struct rtnl_link_stats64) },
+	[IFLA_STATS_INET6]      = {. type = NLA_NESTED },
 };
 
 static size_t rtnl_link_get_af_stats_size(const struct net_device *dev,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 27aed1a..445f21a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4917,6 +4917,29 @@ static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
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
@@ -4941,15 +4964,8 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev,
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
@@ -4991,6 +5007,49 @@ static int inet6_fill_link_af(struct sk_buff *skb, const struct net_device *dev,
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
@@ -6085,6 +6144,8 @@ static struct rtnl_af_ops inet6_ops __read_mostly = {
 	.get_link_af_size = inet6_get_link_af_size,
 	.validate_link_af = inet6_validate_link_af,
 	.set_link_af	  = inet6_set_link_af,
+	.get_link_af_stats_size = inet6_get_link_af_stats_size,
+	.fill_link_af_stats = inet6_fill_link_af_stats,
 };
 
 /*
-- 
1.9.1
