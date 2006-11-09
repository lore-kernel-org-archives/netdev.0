From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/6] [NET] rules: Protocol independant mark selector
Date: Thu, 09 Nov 2006 12:27:39 +0100
Message-ID: <20061109113245.899802813@lsx.localdomain>
References: <20061109112735.577771022@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:7888 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965257AbWKILdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 06:33:52 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=rules_mark
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move mark selector currently implemented per protocol into
the protocol independant part.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/net/fib_rules.h
===================================================================
--- net-2.6.20.orig/include/net/fib_rules.h	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/include/net/fib_rules.h	2006-11-08 23:32:35.000000000 +0100
@@ -13,6 +13,8 @@
 	atomic_t		refcnt;
 	int			ifindex;
 	char			ifname[IFNAMSIZ];
+	u32			mark;
+	u32			mark_mask;
 	u32			pref;
 	u32			flags;
 	u32			table;
Index: net-2.6.20/net/core/fib_rules.c
===================================================================
--- net-2.6.20.orig/net/core/fib_rules.c	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/net/core/fib_rules.c	2006-11-08 23:32:35.000000000 +0100
@@ -119,6 +119,9 @@
 		if (rule->ifindex && (rule->ifindex != fl->iif))
 			continue;
 
+		if ((rule->mark ^ fl->mark) & rule->mark_mask)
+			continue;
+
 		if (!ops->match(rule, fl, flags))
 			continue;
 
@@ -179,6 +182,18 @@
 			rule->ifindex = dev->ifindex;
 	}
 
+	if (tb[FRA_FWMARK]) {
+		rule->mark = nla_get_u32(tb[FRA_FWMARK]);
+		if (rule->mark)
+			/* compatibility: if the mark value is non-zero all bits
+			 * are compared unless a mask is explicitly specified.
+			 */
+			rule->mark_mask = 0xFFFFFFFF;
+	}
+
+	if (tb[FRA_FWMASK])
+		rule->mark_mask = nla_get_u32(tb[FRA_FWMASK]);
+
 	rule->action = frh->action;
 	rule->flags = frh->flags;
 	rule->table = frh_get_table(frh, tb);
@@ -250,6 +265,14 @@
 		    nla_strcmp(tb[FRA_IFNAME], rule->ifname))
 			continue;
 
+		if (tb[FRA_FWMARK] &&
+		    (rule->mark != nla_get_u32(tb[FRA_FWMARK])))
+			continue;
+
+		if (tb[FRA_FWMASK] &&
+		    (rule->mark_mask != nla_get_u32(tb[FRA_FWMASK])))
+			continue;
+
 		if (!ops->compare(rule, frh, tb))
 			continue;
 
@@ -298,6 +321,12 @@
 	if (rule->pref)
 		NLA_PUT_U32(skb, FRA_PRIORITY, rule->pref);
 
+	if (rule->mark)
+		NLA_PUT_U32(skb, FRA_FWMARK, rule->mark);
+
+	if (rule->mark_mask || rule->mark)
+		NLA_PUT_U32(skb, FRA_FWMASK, rule->mark_mask);
+
 	if (ops->fill(rule, skb, nlh, frh) < 0)
 		goto nla_put_failure;
 
Index: net-2.6.20/net/decnet/dn_rules.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_rules.c	2006-11-08 16:12:32.000000000 +0100
+++ net-2.6.20/net/decnet/dn_rules.c	2006-11-08 23:32:35.000000000 +0100
@@ -45,8 +45,6 @@
 	__le16			dstmask;
 	__le16			srcmap;
 	u8			flags;
-	u32			fwmark;
-	u32			fwmask;
 };
 
 static struct dn_fib_rule default_rule = {
@@ -129,9 +127,6 @@
 	    ((daddr ^ r->dst) & r->dstmask))
 		return 0;
 
-	if ((r->fwmark ^ fl->mark) & r->fwmask)
-		return 0;
-
 	return 1;
 }
 
@@ -165,18 +160,6 @@
 	if (tb[FRA_DST])
 		r->dst = nla_get_u16(tb[FRA_DST]);
 
-	if (tb[FRA_FWMARK]) {
-		r->fwmark = nla_get_u32(tb[FRA_FWMARK]);
-		if (r->fwmark)
-			/* compatibility: if the mark value is non-zero all bits
-			 * are compared unless a mask is explicitly specified.
-			 */
-			r->fwmask = 0xFFFFFFFF;
-	}
-
-	if (tb[FRA_FWMASK])
-		r->fwmask = nla_get_u32(tb[FRA_FWMASK]);
-
 	r->src_len = frh->src_len;
 	r->srcmask = dnet_make_mask(r->src_len);
 	r->dst_len = frh->dst_len;
@@ -197,12 +180,6 @@
 	if (frh->dst_len && (r->dst_len != frh->dst_len))
 		return 0;
 
-	if (tb[FRA_FWMARK] && (r->fwmark != nla_get_u32(tb[FRA_FWMARK])))
-		return 0;
-
-	if (tb[FRA_FWMASK] && (r->fwmask != nla_get_u32(tb[FRA_FWMASK])))
-		return 0;
-
 	if (tb[FRA_SRC] && (r->src != nla_get_u16(tb[FRA_SRC])))
 		return 0;
 
@@ -240,10 +217,6 @@
 	frh->src_len = r->src_len;
 	frh->tos = 0;
 
-	if (r->fwmark)
-		NLA_PUT_U32(skb, FRA_FWMARK, r->fwmark);
-	if (r->fwmask || r->fwmark)
-		NLA_PUT_U32(skb, FRA_FWMASK, r->fwmask);
 	if (r->dst_len)
 		NLA_PUT_U16(skb, FRA_DST, r->dst);
 	if (r->src_len)
Index: net-2.6.20/net/ipv4/fib_rules.c
===================================================================
--- net-2.6.20.orig/net/ipv4/fib_rules.c	2006-11-08 16:12:32.000000000 +0100
+++ net-2.6.20/net/ipv4/fib_rules.c	2006-11-08 23:32:35.000000000 +0100
@@ -44,8 +44,6 @@
 	__be32			srcmask;
 	__be32			dst;
 	__be32			dstmask;
-	u32			fwmark;
-	u32			fwmask;
 #ifdef CONFIG_NET_CLS_ROUTE
 	u32			tclassid;
 #endif
@@ -158,9 +156,6 @@
 	if (r->tos && (r->tos != fl->fl4_tos))
 		return 0;
 
-	if ((r->fwmark ^ fl->mark) & r->fwmask)
-		return 0;
-
 	return 1;
 }
 
@@ -216,18 +211,6 @@
 	if (tb[FRA_DST])
 		rule4->dst = nla_get_be32(tb[FRA_DST]);
 
-	if (tb[FRA_FWMARK]) {
-		rule4->fwmark = nla_get_u32(tb[FRA_FWMARK]);
-		if (rule4->fwmark)
-			/* compatibility: if the mark value is non-zero all bits
-			 * are compared unless a mask is explicitly specified.
-			 */
-			rule4->fwmask = 0xFFFFFFFF;
-	}
-
-	if (tb[FRA_FWMASK])
-		rule4->fwmask = nla_get_u32(tb[FRA_FWMASK]);
-
 #ifdef CONFIG_NET_CLS_ROUTE
 	if (tb[FRA_FLOW])
 		rule4->tclassid = nla_get_u32(tb[FRA_FLOW]);
@@ -258,12 +241,6 @@
 	if (frh->tos && (rule4->tos != frh->tos))
 		return 0;
 
-	if (tb[FRA_FWMARK] && (rule4->fwmark != nla_get_u32(tb[FRA_FWMARK])))
-		return 0;
-
-	if (tb[FRA_FWMASK] && (rule4->fwmask != nla_get_u32(tb[FRA_FWMASK])))
-		return 0;
-
 #ifdef CONFIG_NET_CLS_ROUTE
 	if (tb[FRA_FLOW] && (rule4->tclassid != nla_get_u32(tb[FRA_FLOW])))
 		return 0;
@@ -288,12 +265,6 @@
 	frh->src_len = rule4->src_len;
 	frh->tos = rule4->tos;
 
-	if (rule4->fwmark)
-		NLA_PUT_U32(skb, FRA_FWMARK, rule4->fwmark);
-
-	if (rule4->fwmask || rule4->fwmark)
-		NLA_PUT_U32(skb, FRA_FWMASK, rule4->fwmask);
-
 	if (rule4->dst_len)
 		NLA_PUT_BE32(skb, FRA_DST, rule4->dst);
 
Index: net-2.6.20/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.20.orig/net/ipv6/fib6_rules.c	2006-11-08 16:12:32.000000000 +0100
+++ net-2.6.20/net/ipv6/fib6_rules.c	2006-11-08 23:32:35.000000000 +0100
@@ -25,8 +25,6 @@
 	struct fib_rule		common;
 	struct rt6key		src;
 	struct rt6key		dst;
-	u32			fwmark;
-	u32			fwmask;
 	u8			tclass;
 };
 
@@ -128,9 +126,6 @@
 	if (r->tclass && r->tclass != ((ntohl(fl->fl6_flowlabel) >> 20) & 0xff))
 		return 0;
 
-	if ((r->fwmark ^ fl->mark) & r->fwmask)
-		return 0;
-
 	return 1;
 }
 
@@ -173,21 +168,6 @@
 		nla_memcpy(&rule6->dst.addr, tb[FRA_DST],
 			   sizeof(struct in6_addr));
 
-	if (tb[FRA_FWMARK]) {
-		rule6->fwmark = nla_get_u32(tb[FRA_FWMARK]);
-		if (rule6->fwmark) {
-			/*
-			 * if the mark value is non-zero,
-			 * all bits are compared by default
-			 * unless a mask is explicitly specified.
-			 */
-			rule6->fwmask = 0xFFFFFFFF;
-		}
-	}
-
-	if (tb[FRA_FWMASK])
-		rule6->fwmask = nla_get_u32(tb[FRA_FWMASK]);
-
 	rule6->src.plen = frh->src_len;
 	rule6->dst.plen = frh->dst_len;
 	rule6->tclass = frh->tos;
@@ -219,12 +199,6 @@
 	    nla_memcmp(tb[FRA_DST], &rule6->dst.addr, sizeof(struct in6_addr)))
 		return 0;
 
-	if (tb[FRA_FWMARK] && (rule6->fwmark != nla_get_u32(tb[FRA_FWMARK])))
-		return 0;
-
-	if (tb[FRA_FWMASK] && (rule6->fwmask != nla_get_u32(tb[FRA_FWMASK])))
-		return 0;
-
 	return 1;
 }
 
@@ -246,12 +220,6 @@
 		NLA_PUT(skb, FRA_SRC, sizeof(struct in6_addr),
 			&rule6->src.addr);
 
-	if (rule6->fwmark)
-		NLA_PUT_U32(skb, FRA_FWMARK, rule6->fwmark);
-
-	if (rule6->fwmask || rule6->fwmark)
-		NLA_PUT_U32(skb, FRA_FWMASK, rule6->fwmask);
-
 	return 0;
 
 nla_put_failure:
Index: net-2.6.20/include/linux/fib_rules.h
===================================================================
--- net-2.6.20.orig/include/linux/fib_rules.h	2006-11-08 15:29:26.000000000 +0100
+++ net-2.6.20/include/linux/fib_rules.h	2006-11-08 23:32:35.000000000 +0100
@@ -34,7 +34,7 @@
 	FRA_UNUSED3,
 	FRA_UNUSED4,
 	FRA_UNUSED5,
-	FRA_FWMARK,	/* netfilter mark */
+	FRA_FWMARK,	/* mark */
 	FRA_FLOW,	/* flow/class id */
 	FRA_UNUSED6,
 	FRA_UNUSED7,

--

