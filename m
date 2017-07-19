From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/17] ipv6: fib: Add offload indication to routes
Date: Wed, 19 Jul 2017 09:02:25 +0200
Message-ID: <20170719070232.28457-11-jiri@resnulli.us>
References: <20170719070232.28457-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36580 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753034AbdGSHCu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 03:02:50 -0400
Received: by mail-wr0-f194.google.com with SMTP id y67so6822900wrb.3
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 00:02:49 -0700 (PDT)
In-Reply-To: <20170719070232.28457-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Allow user space applications to see which routes are offloaded and
which aren't by setting the RTNH_F_OFFLOAD flag when dumping them.

To be consistent with IPv4, a multipath route is marked as offloaded if
one of its nexthops is offloaded. Individual nexthops aren't marked with
the 'offload' flag.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/ipv6_route.h |  1 +
 net/ipv6/route.c                | 19 ++++++++++++++++---
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/ipv6_route.h b/include/uapi/linux/ipv6_route.h
index d496c02..33e2a57 100644
--- a/include/uapi/linux/ipv6_route.h
+++ b/include/uapi/linux/ipv6_route.h
@@ -35,6 +35,7 @@
 #define RTF_PREF(pref)	((pref) << 27)
 #define RTF_PREF_MASK	0x18000000
 
+#define RTF_OFFLOAD	0x20000000	/* offloaded route		*/
 #define RTF_PCPU	0x40000000	/* read-only: can not be set by user */
 #define RTF_LOCAL	0x80000000
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d30c96..924e02d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1820,6 +1820,11 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 		goto out;
 	}
 
+	if (cfg->fc_flags & RTF_OFFLOAD) {
+		NL_SET_ERR_MSG(extack, "Userspace can not set RTF_OFFLOAD");
+		goto out;
+	}
+
 	if (cfg->fc_dst_len > 128) {
 		NL_SET_ERR_MSG(extack, "Invalid prefix length");
 		goto out;
@@ -3327,6 +3332,9 @@ static int rt6_nexthop_info(struct sk_buff *skb, struct rt6_info *rt,
 			goto nla_put_failure;
 	}
 
+	if (rt->rt6i_flags & RTF_OFFLOAD)
+		*flags |= RTNH_F_OFFLOAD;
+
 	/* not needed for multipath encoding b/c it has a rtnexthop struct */
 	if (!skip_oif && rt->dst.dev &&
 	    nla_put_u32(skb, RTA_OIF, rt->dst.dev->ifindex))
@@ -3343,7 +3351,8 @@ static int rt6_nexthop_info(struct sk_buff *skb, struct rt6_info *rt,
 }
 
 /* add multipath next hop */
-static int rt6_add_nexthop(struct sk_buff *skb, struct rt6_info *rt)
+static int rt6_add_nexthop(struct sk_buff *skb, struct rt6_info *rt,
+			   unsigned int *rtm_flags)
 {
 	struct rtnexthop *rtnh;
 	unsigned int flags = 0;
@@ -3359,6 +3368,10 @@ static int rt6_add_nexthop(struct sk_buff *skb, struct rt6_info *rt)
 		goto nla_put_failure;
 
 	rtnh->rtnh_flags = flags;
+	if (rtnh->rtnh_flags & RTNH_F_OFFLOAD) {
+		rtnh->rtnh_flags &= ~RTNH_F_OFFLOAD;
+		*rtm_flags |= RTNH_F_OFFLOAD;
+	}
 
 	/* length of rtnetlink header + attributes */
 	rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *)rtnh;
@@ -3499,12 +3512,12 @@ static int rt6_fill_node(struct net *net,
 		if (!mp)
 			goto nla_put_failure;
 
-		if (rt6_add_nexthop(skb, rt) < 0)
+		if (rt6_add_nexthop(skb, rt, &rtm->rtm_flags) < 0)
 			goto nla_put_failure;
 
 		list_for_each_entry_safe(sibling, next_sibling,
 					 &rt->rt6i_siblings, rt6i_siblings) {
-			if (rt6_add_nexthop(skb, sibling) < 0)
+			if (rt6_add_nexthop(skb, sibling, &rtm->rtm_flags) < 0)
 				goto nla_put_failure;
 		}
 
-- 
2.9.3
