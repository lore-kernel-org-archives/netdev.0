From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH] ipv6: expose RFC4191 route preference via rtnetlink
Date: Tue,  3 Mar 2015 11:01:52 +0100
Message-ID: <1425376912-31983-1-git-send-email-lkundrak@v3.sk>
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Lubomir Rintel <lkundrak@v3.sk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes it possible to retain the route preference when RAs are handled in
userspace.

Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
---
 include/uapi/linux/rtnetlink.h |  1 +
 net/ipv6/route.c               | 16 +++++++++++++++-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 5cc5d66..0671524 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -303,6 +303,7 @@ enum rtattr_type_t {
 	RTA_TABLE,
 	RTA_MARK,
 	RTA_MFC_STATS,
+	RTA_PREF,
 	__RTA_MAX
 };
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 47b5109..08f689e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2401,6 +2401,7 @@ static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 	[RTA_PRIORITY]          = { .type = NLA_U32 },
 	[RTA_METRICS]           = { .type = NLA_NESTED },
 	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
+	[RTA_PREF]              = { .type = NLA_U8 },
 };
 
 static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -2408,6 +2409,7 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 {
 	struct rtmsg *rtm;
 	struct nlattr *tb[RTA_MAX+1];
+	unsigned int pref;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy);
@@ -2483,6 +2485,14 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 		cfg->fc_mp_len = nla_len(tb[RTA_MULTIPATH]);
 	}
 
+	if (tb[RTA_PREF]) {
+		pref = nla_get_u8(tb[RTA_PREF]);
+		if (pref == ICMPV6_ROUTER_PREF_LOW ||
+		    pref == ICMPV6_ROUTER_PREF_MEDIUM ||
+		    pref == ICMPV6_ROUTER_PREF_HIGH)
+			cfg->fc_flags |= RTF_PREF(pref);
+	}
+
 	err = 0;
 errout:
 	return err;
@@ -2586,7 +2596,8 @@ static inline size_t rt6_nlmsg_size(void)
 	       + nla_total_size(4) /* RTA_PRIORITY */
 	       + RTAX_MAX * nla_total_size(4) /* RTA_METRICS */
 	       + nla_total_size(sizeof(struct rta_cacheinfo))
-	       + nla_total_size(TCP_CA_NAME_MAX); /* RTAX_CC_ALGO */
+	       + nla_total_size(TCP_CA_NAME_MAX) /* RTAX_CC_ALGO */
+	       + nla_total_size(1); /* RTA_PREF */
 }
 
 static int rt6_fill_node(struct net *net,
@@ -2727,6 +2738,9 @@ static int rt6_fill_node(struct net *net,
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, rt->dst.error) < 0)
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, RTA_PREF, IPV6_EXTRACT_PREF(rt->rt6i_flags)))
+		goto nla_put_failure;
+
 	nlmsg_end(skb, nlh);
 	return 0;
 
-- 
2.1.0
