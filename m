From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET 02/04]: Introduce RTA_TABLE routing attribute
Date: Mon,  3 Jul 2006 09:53:02 +0200 (MEST)
Message-ID: <20060703075302.6286.78273.sendpatchset@localhost.localdomain>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:24016 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750741AbWGCHxD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 03:53:03 -0400
To: davem@davemloft.net
In-Reply-To: <20060703075259.6286.67397.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Introduce RTA_TABLE routing attribute

Introduce RTA_TABLE routing attribute to hold 32 bit routing table IDs.
Usespace compatibility is provided by continuing to accept and send the
rtm_table field, but because of its limited size it can only carry the
low 8 bits of the table ID. This implies that if larger IDs are used,
_all_ userspace programs using them need to use RTA_TABLE.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8cf1ae7345f935350dede855381dfbb620cabc1c
tree d674b6bb251dda0fcb915db0dbca98cda7779348
parent 7e3ac412e095b5a4d29a7244d5cee795267a7c6a
author Patrick McHardy <kaber@trash.net> Mon, 03 Jul 2006 08:13:14 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 03 Jul 2006 08:13:14 +0200

 include/linux/rtnetlink.h |    8 ++++++++
 net/decnet/dn_fib.c       |    7 ++++---
 net/decnet/dn_route.c     |    1 +
 net/decnet/dn_rules.c     |    6 ++++--
 net/decnet/dn_table.c     |    1 +
 net/ipv4/fib_frontend.c   |    7 ++++---
 net/ipv4/fib_rules.c      |    6 ++++--
 net/ipv4/fib_semantics.c  |    1 +
 net/ipv4/route.c          |    1 +
 net/ipv6/route.c          |    1 +
 10 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index facd9ee..8f6efff 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -263,6 +263,7 @@ enum rtattr_type_t
 	RTA_CACHEINFO,
 	RTA_SESSION,
 	RTA_MP_ALGO,
+	RTA_TABLE,
 	__RTA_MAX
 };
 
@@ -1065,6 +1066,13 @@ #define BUG_TRAP(x) do { \
 	} \
 } while(0)
 
+static inline u32 rtm_get_table(struct rtmsg *rtm, struct rtattr **rta)
+{
+	return RTA_GET_U32(rta[RTA_TABLE-1]);
+rtattr_failure:
+	return rtm->rtm_table;
+}
+
 #endif /* __KERNEL__ */
 
 
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index f4c1c1e..a43e59b 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -491,7 +491,8 @@ static int dn_fib_check_attr(struct rtms
 		if (attr) {
 			if (RTA_PAYLOAD(attr) < 4 && RTA_PAYLOAD(attr) != 2)
 				return -EINVAL;
-			if (i != RTA_MULTIPATH && i != RTA_METRICS)
+			if (i != RTA_MULTIPATH && i != RTA_METRICS &&
+			    i != RTA_TABLE)
 				rta[i-1] = (struct rtattr *)RTA_DATA(attr);
 		}
 	}
@@ -508,7 +509,7 @@ int dn_fib_rtm_delroute(struct sk_buff *
 	if (dn_fib_check_attr(r, rta))
 		return -EINVAL;
 
-	tb = dn_fib_get_table(r->rtm_table, 0);
+	tb = dn_fib_get_table(rtm_get_table(r, rta), 0);
 	if (tb)
 		return tb->delete(tb, r, (struct dn_kern_rta *)rta, nlh, &NETLINK_CB(skb));
 
@@ -524,7 +525,7 @@ int dn_fib_rtm_newroute(struct sk_buff *
 	if (dn_fib_check_attr(r, rta))
 		return -EINVAL;
 
-	tb = dn_fib_get_table(r->rtm_table, 1);
+	tb = dn_fib_get_table(rtm_get_table(r, rta), 1);
 	if (tb) 
 		return tb->insert(tb, r, (struct dn_kern_rta *)rta, nlh, &NETLINK_CB(skb));
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 1355614..2c5bc4e 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1480,6 +1480,7 @@ static int dn_rt_fill_info(struct sk_buf
 	r->rtm_src_len = 0;
 	r->rtm_tos = 0;
 	r->rtm_table = RT_TABLE_MAIN;
+	RTA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type = rt->rt_type;
 	r->rtm_flags = (rt->rt_flags & ~0xFFFF) | RTM_F_CLONED;
 	r->rtm_scope = RT_SCOPE_UNIVERSE;
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 16ca66b..d274d59 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -77,6 +77,7 @@ int dn_fib_rtm_delrule(struct sk_buff *s
 	struct rtmsg *rtm = NLMSG_DATA(nlh);
 	struct dn_fib_rule *r;
 	struct hlist_node *node;
+	u32 table = rtm_get_table(rtm, rta);
 	int err = -ESRCH;
 
 	hlist_for_each_entry(r, node, &dn_fib_rules, r_hlist) {
@@ -90,7 +91,7 @@ #endif
 			(!rtm->rtm_type || rtm->rtm_type == r->r_action) &&
 			(!rta[RTA_PRIORITY-1] || memcmp(RTA_DATA(rta[RTA_PRIORITY-1]), &r->r_preference, 4) == 0) &&
 			(!rta[RTA_IIF-1] || rtattr_strcmp(rta[RTA_IIF-1], r->r_ifname) == 0) &&
-			(!rtm->rtm_table || (r && rtm->rtm_table == r->r_table))) {
+			(!table || (r && table == r->r_table))) {
 
 			err = -EPERM;
 			if (r == &default_rule)
@@ -141,7 +142,7 @@ int dn_fib_rtm_newrule(struct sk_buff *s
 	if (rtm->rtm_type == RTN_NAT)
 		return -EINVAL;
 
-	table_id = rtm->rtm_table;
+	table_id = rtm_get_table(rtm, rta);
 	if (table_id == RT_TABLE_UNSPEC) {
 		struct dn_fib_table *tb;
 		if (rtm->rtm_type == RTN_UNICAST) {
@@ -365,6 +366,7 @@ #ifdef CONFIG_DECNET_ROUTE_FWMARK
 		RTA_PUT(skb, RTA_PROTOINFO, 4, &r->r_fwmark);
 #endif
 	rtm->rtm_table = r->r_table;
+	RTA_PUT_U32(skb, RTA_TABLE, r->r_table);
 	rtm->rtm_protocol = 0;
 	rtm->rtm_scope = 0;
 	rtm->rtm_type = r->r_action;
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 7de6a88..b165282 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -282,6 +282,7 @@ static int dn_fib_dump_info(struct sk_bu
         rtm->rtm_src_len = 0;
         rtm->rtm_tos = 0;
         rtm->rtm_table = tb_id;
+	RTA_PUT_U32(skb, RTA_TABLE, tb_id);
         rtm->rtm_flags = fi->fib_flags;
         rtm->rtm_scope = scope;
 	rtm->rtm_type  = type;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4d5429a..2f54f22 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -293,7 +293,8 @@ static int inet_check_attr(struct rtmsg 
 		if (attr) {
 			if (RTA_PAYLOAD(attr) < 4)
 				return -EINVAL;
-			if (i != RTA_MULTIPATH && i != RTA_METRICS)
+			if (i != RTA_MULTIPATH && i != RTA_METRICS &&
+			    i != RTA_TABLE)
 				*rta = (struct rtattr*)RTA_DATA(attr);
 		}
 	}
@@ -309,7 +310,7 @@ int inet_rtm_delroute(struct sk_buff *sk
 	if (inet_check_attr(r, rta))
 		return -EINVAL;
 
-	tb = fib_get_table(r->rtm_table);
+	tb = fib_get_table(rtm_get_table(r, rta));
 	if (tb)
 		return tb->tb_delete(tb, r, (struct kern_rta*)rta, nlh, &NETLINK_CB(skb));
 	return -ESRCH;
@@ -324,7 +325,7 @@ int inet_rtm_newroute(struct sk_buff *sk
 	if (inet_check_attr(r, rta))
 		return -EINVAL;
 
-	tb = fib_new_table(r->rtm_table);
+	tb = fib_new_table(rtm_get_table(r, rta));
 	if (tb)
 		return tb->tb_insert(tb, r, (struct kern_rta*)rta, nlh, &NETLINK_CB(skb));
 	return -ENOBUFS;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 71ede02..e6d1f5a 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -111,6 +111,7 @@ int inet_rtm_delrule(struct sk_buff *skb
 	struct rtmsg *rtm = NLMSG_DATA(nlh);
 	struct fib_rule *r;
 	struct hlist_node *node;
+	u32 table = rtm_get_table(rtm, rta);
 	int err = -ESRCH;
 
 	hlist_for_each_entry(r, node, &fib_rules, hlist) {
@@ -125,7 +126,7 @@ #endif
 		    (!rtm->rtm_type || rtm->rtm_type == r->r_action) &&
 		    (!rta[RTA_PRIORITY-1] || memcmp(RTA_DATA(rta[RTA_PRIORITY-1]), &r->r_preference, 4) == 0) &&
 		    (!rta[RTA_IIF-1] || rtattr_strcmp(rta[RTA_IIF-1], r->r_ifname) == 0) &&
-		    (!rtm->rtm_table || (r && rtm->rtm_table == r->r_table))) {
+		    (!table || (r && table == r->r_table))) {
 			err = -EPERM;
 			if (r == &local_rule)
 				break;
@@ -186,7 +187,7 @@ int inet_rtm_newrule(struct sk_buff *skb
 	if (rta[RTA_IIF-1] && RTA_PAYLOAD(rta[RTA_IIF-1]) > IFNAMSIZ)
 		return -EINVAL;
 
-	table_id = rtm->rtm_table;
+	table_id = rtm_get_table(rtm, rta);
 	if (table_id == RT_TABLE_UNSPEC) {
 		struct fib_table *table;
 		if (rtm->rtm_type == RTN_UNICAST) {
@@ -403,6 +404,7 @@ #ifdef CONFIG_IP_ROUTE_FWMARK
 		RTA_PUT(skb, RTA_PROTOINFO, 4, &r->r_fwmark);
 #endif
 	rtm->rtm_table = r->r_table;
+	RTA_PUT_U32(skb, RTA_TABLE, r->r_table);
 	rtm->rtm_protocol = 0;
 	rtm->rtm_scope = 0;
 	rtm->rtm_type = r->r_action;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 84537df..3c45256 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -954,6 +954,7 @@ fib_dump_info(struct sk_buff *skb, u32 p
 	rtm->rtm_src_len = 0;
 	rtm->rtm_tos = tos;
 	rtm->rtm_table = tb_id;
+	RTA_PUT_U32(skb, RTA_TABLE, tb_id);
 	rtm->rtm_type = type;
 	rtm->rtm_flags = fi->fib_flags;
 	rtm->rtm_scope = scope;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index da44fab..7ef78f3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2638,6 +2638,7 @@ #endif
 	r->rtm_src_len	= 0;
 	r->rtm_tos	= rt->fl.fl4_tos;
 	r->rtm_table	= RT_TABLE_MAIN;
+	RTA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type	= rt->rt_type;
 	r->rtm_scope	= RT_SCOPE_UNIVERSE;
 	r->rtm_protocol = RTPROT_UNSPEC;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 87c39c9..4410282 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1745,6 +1745,7 @@ static int rt6_fill_node(struct sk_buff 
 	rtm->rtm_src_len = rt->rt6i_src.plen;
 	rtm->rtm_tos = 0;
 	rtm->rtm_table = RT_TABLE_MAIN;
+	RTA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	if (rt->rt6i_flags&RTF_REJECT)
 		rtm->rtm_type = RTN_UNREACHABLE;
 	else if (rt->rt6i_dev && (rt->rt6i_dev->flags&IFF_LOOPBACK))
