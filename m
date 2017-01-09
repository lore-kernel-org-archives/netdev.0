From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 6/7] net: ipv4: return route match in GETROUTE request
Date: Mon,  9 Jan 2017 13:32:50 -0800
Message-ID: <1483997571-3964-7-git-send-email-dsa@cumulusnetworks.com>
References: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35401 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932800AbdAIVdB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:33:01 -0500
Received: by mail-pf0-f171.google.com with SMTP id f144so24368551pfa.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 13:33:01 -0800 (PST)
In-Reply-To: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the matching route returned in fib_result as a new, nested attribute,
RTA_ROUTE_GET, to the GETROUTE response. The rtmsg struct is added use a
new attribute, RTA_ROUTE_GET_RTM. These attributes allow userspace to show
which route was matched for a GETROUTE request.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/uapi/linux/rtnetlink.h |  2 ++
 net/ipv4/route.c               | 36 ++++++++++++++++++++++++++++++++++--
 2 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 8c93ad1ef9ab..471384b72cea 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -319,6 +319,8 @@ enum rtattr_type_t {
 	RTA_EXPIRES,
 	RTA_PAD,
 	RTA_UID,
+	RTA_ROUTE_GET,  /* nested attribute; route spec for RTM_GETROUTE */
+	RTA_ROUTE_GET_RTM, /* struct rtmsg for nested spec */
 	__RTA_MAX
 };
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 03ddc03c185a..9f44b869b8a6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -113,6 +113,7 @@
 #include <net/secure_seq.h>
 #include <net/ip_tunnels.h>
 #include <net/l3mdev.h>
+#include "fib_lookup.h"
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -2470,7 +2471,8 @@ EXPORT_SYMBOL_GPL(ip_route_output_flow);
 /* called with rcu_read_lock held */
 static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 			struct flowi4 *fl4, struct sk_buff *skb, u32 portid,
-			u32 seq, int event, struct rtable *rt)
+			u32 seq, int event, struct rtable *rt,
+			struct fib_result *res)
 {
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
@@ -2572,6 +2574,36 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, error) < 0)
 		goto nla_put_failure;
 
+	if (res->fi) {
+		struct nlattr *get_rt;
+		struct rtmsg r_match;
+
+		/* Add data for matching route */
+		get_rt = nla_nest_start(skb, RTA_ROUTE_GET);
+		if (!get_rt)
+			goto nla_put_failure;
+
+		r_match.rtm_family = AF_INET;
+		r_match.rtm_dst_len = res->prefixlen;
+		r_match.rtm_src_len = 0;
+		r_match.rtm_tos  = fl4->flowi4_tos;
+		r_match.rtm_type = rt->rt_type;
+		r_match.rtm_flags = res->fi->fib_flags;
+		r_match.rtm_scope = res->fi->fib_scope;
+		r_match.rtm_protocol = res->fi->fib_protocol;
+		r_match.rtm_table = table_id;
+		if (nla_put_u32(skb, RTA_TABLE, table_id))
+			goto nla_put_failure;
+
+		if (fib_dump_add_attrs_rcu(skb, res->prefix, &r_match, res->fi))
+			goto nla_put_failure;
+
+		if (nla_put(skb, RTA_ROUTE_GET_RTM, sizeof(r_match), &r_match))
+			goto nla_put_failure;
+
+		nla_nest_end(skb, get_rt);
+	}
+
 	nlmsg_end(skb, nlh);
 	return 0;
 
@@ -2680,7 +2712,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 
 	err = rt_fill_info(net, dst, src, table_id, &fl4, skb,
 			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
-			   RTM_NEWROUTE, rt);
+			   RTM_NEWROUTE, rt, &res);
 	if (err < 0)
 		goto errout_free;
 
-- 
2.1.4
