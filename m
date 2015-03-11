From: Lubomir Rintel <lkundrak-NGH9Lh4a5iE@public.gmane.org>
Subject: [PATCH v2] ipv6: expose RFC4191 route preference via rtnetlink
Date: Wed, 11 Mar 2015 15:39:21 +0100
Message-ID: <1426084761-3303-1-git-send-email-lkundrak@v3.sk>
References: <20150310160423.GC2016@nanopsycho.orion>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Lubomir Rintel <lkundrak-NGH9Lh4a5iE@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150310160423.GC2016-6KJVSR23iU488b5SBfVpbw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This makes it possible to retain the route preference when RAs are handled in
userspace.

Signed-off-by: Lubomir Rintel <lkundrak-NGH9Lh4a5iE@public.gmane.org>
---
Changes since v1:
  - In case an invalid value is specified treat it as ICMPV6_ROUTER_PREF_MEDIUM

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
index 47b5109..8b01d16 100644
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
+		if (pref != ICMPV6_ROUTER_PREF_LOW &&
+		    pref != ICMPV6_ROUTER_PREF_HIGH)
+			pref = ICMPV6_ROUTER_PREF_MEDIUM;
+		cfg->fc_flags |= RTF_PREF(pref);
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
