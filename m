From: Patrick McHardy <kaber@trash.net>
Subject: [NET 02/06]: Introduce RTA_TABLE/FRA_TABLE attributes
Date: Thu, 10 Aug 2006 21:30:00 +0200 (MEST)
Message-ID: <20060810193000.14867.49807.sendpatchset@localhost.localdomain>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41690 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751243AbWHJTaB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 15:30:01 -0400
To: davem@davemloft.net
In-Reply-To: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Introduce RTA_TABLE/FRA_TABLE attributes

Introduce RTA_TABLE route attribute and FRA_TABLE routing rule attribute
to hold 32 bit routing table IDs. Usespace compatibility is provided by
continuing to accept and send the rtm_table field, but because of its
limited size it can only carry the low 8 bits of the table ID. This
implies that if larger IDs are used, _all_ userspace programs using them
need to use RTA_TABLE.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a9fe50e925cdc0471b88bcf6f3cc18278b63c984
tree 08d8bfa20011b5afa940126a8bb0c153729584c3
parent 29a0f4a779543907ddf8fbca55b6f1d0e0017f64
author Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 20:50:19 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 20:50:19 +0200

 include/linux/fib_rules.h |    4 ++++
 include/linux/rtnetlink.h |    8 ++++++++
 include/net/fib_rules.h   |    7 +++++++
 net/core/fib_rules.c      |    5 +++--
 net/decnet/dn_fib.c       |    7 ++++---
 net/decnet/dn_route.c     |    1 +
 net/decnet/dn_table.c     |    1 +
 net/ipv4/fib_frontend.c   |    7 ++++---
 net/ipv4/fib_rules.c      |    1 +
 net/ipv4/fib_semantics.c  |    1 +
 net/ipv4/route.c          |    1 +
 net/ipv6/fib6_rules.c     |    1 +
 net/ipv6/route.c          |   13 +++++++++----
 13 files changed, 45 insertions(+), 12 deletions(-)

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 5e503f0..19a82b6 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -36,6 +36,10 @@ enum
 	FRA_UNUSED5,
 	FRA_FWMARK,	/* netfilter mark (IPv4) */
 	FRA_FLOW,	/* flow/class id */
+	FRA_UNUSED6,
+	FRA_UNUSED7,
+	FRA_UNUSED8,
+	FRA_TABLE,	/* Extended table id */
 	__FRA_MAX
 };
 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 5deca87..b01bc8b 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -264,6 +264,7 @@ enum rtattr_type_t
 	RTA_CACHEINFO,
 	RTA_SESSION,
 	RTA_MP_ALGO,
+	RTA_TABLE,
 	__RTA_MAX
 };
 
@@ -716,6 +717,13 @@ #define BUG_TRAP(x) do { \
 	} \
 } while(0)
 
+static inline u32 rtm_get_table(struct rtattr **rta, u8 table)
+{
+	return RTA_GET_U32(rta[RTA_TABLE-1]);
+rtattr_failure:
+	return table;
+}
+
 #endif /* __KERNEL__ */
 
 
diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 61375d9..8e2f473 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -74,6 +74,13 @@ static inline void fib_rule_put(struct f
 		call_rcu(&rule->rcu, fib_rule_put_rcu);
 }
 
+static inline u32 frh_get_table(struct fib_rule_hdr *frh, struct nlattr **nla)
+{
+	if (nla[FRA_TABLE])
+		return nla_get_u32(nla[FRA_TABLE]);
+	return frh->table;
+}
+
 extern int			fib_rules_register(struct fib_rules_ops *);
 extern int			fib_rules_unregister(struct fib_rules_ops *);
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 2e7ed5d..97b196f 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -187,7 +187,7 @@ int fib_nl_newrule(struct sk_buff *skb, 
 
 	rule->action = frh->action;
 	rule->flags = frh->flags;
-	rule->table = frh->table;
+	rule->table = frh_get_table(frh, tb);
 
 	if (!rule->pref && ops->default_pref)
 		rule->pref = ops->default_pref();
@@ -245,7 +245,7 @@ int fib_nl_delrule(struct sk_buff *skb, 
 		if (frh->action && (frh->action != rule->action))
 			continue;
 
-		if (frh->table && (frh->table != rule->table))
+		if (frh->table && (frh_get_table(frh, tb) != rule->table))
 			continue;
 
 		if (tb[FRA_PRIORITY] &&
@@ -291,6 +291,7 @@ static int fib_nl_fill_rule(struct sk_bu
 
 	frh = nlmsg_data(nlh);
 	frh->table = rule->table;
+	NLA_PUT_U32(skb, FRA_TABLE, rule->table);
 	frh->res1 = 0;
 	frh->res2 = 0;
 	frh->action = rule->action;
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 7b3bf5c..fb59637 100644
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
+	tb = dn_fib_get_table(rtm_get_table(rta, r->rtm_table), 0);
 	if (tb)
 		return tb->delete(tb, r, (struct dn_kern_rta *)rta, nlh, &NETLINK_CB(skb));
 
@@ -524,7 +525,7 @@ int dn_fib_rtm_newroute(struct sk_buff *
 	if (dn_fib_check_attr(r, rta))
 		return -EINVAL;
 
-	tb = dn_fib_get_table(r->rtm_table, 1);
+	tb = dn_fib_get_table(rtm_get_table(rta, r->rtm_table), 1);
 	if (tb) 
 		return tb->insert(tb, r, (struct dn_kern_rta *)rta, nlh, &NETLINK_CB(skb));
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index d5c1758..c5daf35 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1486,6 +1486,7 @@ static int dn_rt_fill_info(struct sk_buf
 	r->rtm_src_len = 0;
 	r->rtm_tos = 0;
 	r->rtm_table = RT_TABLE_MAIN;
+	RTA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type = rt->rt_type;
 	r->rtm_flags = (rt->rt_flags & ~0xFFFF) | RTM_F_CLONED;
 	r->rtm_scope = RT_SCOPE_UNIVERSE;
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index b7c6c06..d2ad791 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -278,6 +278,7 @@ static int dn_fib_dump_info(struct sk_bu
         rtm->rtm_src_len = 0;
         rtm->rtm_tos = 0;
         rtm->rtm_table = tb_id;
+	RTA_PUT_U32(skb, RTA_TABLE, tb_id);
         rtm->rtm_flags = fi->fib_flags;
         rtm->rtm_scope = scope;
 	rtm->rtm_type  = type;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 06f4b23..2696ede 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -294,7 +294,8 @@ static int inet_check_attr(struct rtmsg 
 		if (attr) {
 			if (RTA_PAYLOAD(attr) < 4)
 				return -EINVAL;
-			if (i != RTA_MULTIPATH && i != RTA_METRICS)
+			if (i != RTA_MULTIPATH && i != RTA_METRICS &&
+			    i != RTA_TABLE)
 				*rta = (struct rtattr*)RTA_DATA(attr);
 		}
 	}
@@ -310,7 +311,7 @@ int inet_rtm_delroute(struct sk_buff *sk
 	if (inet_check_attr(r, rta))
 		return -EINVAL;
 
-	tb = fib_get_table(r->rtm_table);
+	tb = fib_get_table(rtm_get_table(rta, r->rtm_table));
 	if (tb)
 		return tb->tb_delete(tb, r, (struct kern_rta*)rta, nlh, &NETLINK_CB(skb));
 	return -ESRCH;
@@ -325,7 +326,7 @@ int inet_rtm_newroute(struct sk_buff *sk
 	if (inet_check_attr(r, rta))
 		return -EINVAL;
 
-	tb = fib_new_table(r->rtm_table);
+	tb = fib_new_table(rtm_get_table(rta, r->rtm_table));
 	if (tb)
 		return tb->tb_insert(tb, r, (struct kern_rta*)rta, nlh, &NETLINK_CB(skb));
 	return -ENOBUFS;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 58fb91b..0330b9c 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -184,6 +184,7 @@ static struct nla_policy fib4_rule_polic
 	[FRA_DST]	= { .type = NLA_U32 },
 	[FRA_FWMARK]	= { .type = NLA_U32 },
 	[FRA_FLOW]	= { .type = NLA_U32 },
+	[FRA_TABLE]	= { .type = NLA_U32 },
 };
 
 static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 17c7974..ffb5966 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -949,6 +949,7 @@ fib_dump_info(struct sk_buff *skb, u32 p
 	rtm->rtm_src_len = 0;
 	rtm->rtm_tos = tos;
 	rtm->rtm_table = tb_id;
+	RTA_PUT_U32(skb, RTA_TABLE, tb_id);
 	rtm->rtm_type = type;
 	rtm->rtm_flags = fi->fib_flags;
 	rtm->rtm_scope = scope;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 77852da..956e4da 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2652,6 +2652,7 @@ #endif
 	r->rtm_src_len	= 0;
 	r->rtm_tos	= rt->fl.fl4_tos;
 	r->rtm_table	= RT_TABLE_MAIN;
+	RTA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type	= rt->rt_type;
 	r->rtm_scope	= RT_SCOPE_UNIVERSE;
 	r->rtm_protocol = RTPROT_UNSPEC;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 22a2fdb..2c4fbc8 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -129,6 +129,7 @@ static struct nla_policy fib6_rule_polic
 	[FRA_PRIORITY]	= { .type = NLA_U32 },
 	[FRA_SRC]	= { .minlen = sizeof(struct in6_addr) },
 	[FRA_DST]	= { .minlen = sizeof(struct in6_addr) },
+	[FRA_TABLE]	= { .type = NLA_U32 },
 };
 
 static int fib6_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c30da9a..b8b5132 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1855,7 +1855,8 @@ int inet6_rtm_delroute(struct sk_buff *s
 
 	if (inet6_rtm_to_rtmsg(r, arg, &rtmsg))
 		return -EINVAL;
-	return ip6_route_del(&rtmsg, nlh, arg, &NETLINK_CB(skb), r->rtm_table);
+	return ip6_route_del(&rtmsg, nlh, arg, &NETLINK_CB(skb),
+			     rtm_get_table(arg, r->rtm_table));
 }
 
 int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
@@ -1865,7 +1866,8 @@ int inet6_rtm_newroute(struct sk_buff *s
 
 	if (inet6_rtm_to_rtmsg(r, arg, &rtmsg))
 		return -EINVAL;
-	return ip6_route_add(&rtmsg, nlh, arg, &NETLINK_CB(skb), r->rtm_table);
+	return ip6_route_add(&rtmsg, nlh, arg, &NETLINK_CB(skb),
+			     rtm_get_table(arg, r->rtm_table));
 }
 
 struct rt6_rtnl_dump_arg
@@ -1883,6 +1885,7 @@ static int rt6_fill_node(struct sk_buff 
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
 	struct rta_cacheinfo ci;
+	u32 table;
 
 	if (prefix) {	/* user wants prefix routes only */
 		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
@@ -1898,9 +1901,11 @@ static int rt6_fill_node(struct sk_buff 
 	rtm->rtm_src_len = rt->rt6i_src.plen;
 	rtm->rtm_tos = 0;
 	if (rt->rt6i_table)
-		rtm->rtm_table = rt->rt6i_table->tb6_id;
+		table = rt->rt6i_table->tb6_id;
 	else
-		rtm->rtm_table = RT6_TABLE_UNSPEC;
+		table = RT6_TABLE_UNSPEC;
+	rtm->rtm_table = table;
+	RTA_PUT_U32(skb, RTA_TABLE, table);
 	if (rt->rt6i_flags&RTF_REJECT)
 		rtm->rtm_type = RTN_UNREACHABLE;
 	else if (rt->rt6i_dev && (rt->rt6i_dev->flags&IFF_LOOPBACK))
