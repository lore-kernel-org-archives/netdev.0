From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.6.27] netlink: Remove compat API for nested attributes
Date: Thu, 28 Aug 2008 16:00:50 +0200
Message-ID: <20080828140050.GB20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:34863 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753352AbYH1OAa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 10:00:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes all _nested_compat() functions from the API. The prio qdisc
no longer requires them and netem has its own format anyway. Their
existance is only confusing.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/include/net/netlink.h
===================================================================
--- net-2.6.orig/include/net/netlink.h	2008-08-28 12:52:00.000000000 +0200
+++ net-2.6/include/net/netlink.h	2008-08-28 12:55:28.000000000 +0200
@@ -119,9 +119,6 @@
  * Nested Attributes Construction:
  *   nla_nest_start(skb, type)		start a nested attribute
  *   nla_nest_end(skb, nla)		finalize a nested attribute
- *   nla_nest_compat_start(skb, type,	start a nested compat attribute
- *			   len, data)
- *   nla_nest_compat_end(skb, type)	finalize a nested compat attribute
  *   nla_nest_cancel(skb, nla)		cancel nested attribute construction
  *
  * Attribute Length Calculations:
@@ -156,7 +153,6 @@
  *   nla_find_nested()			find attribute in nested attributes
  *   nla_parse()			parse and validate stream of attrs
  *   nla_parse_nested()			parse nested attribuets
- *   nla_parse_nested_compat()		parse nested compat attributes
  *   nla_for_each_attr()		loop over all attributes
  *   nla_for_each_nested()		loop over the nested attributes
  *=========================================================================
@@ -751,35 +747,6 @@
 	return nla_parse(tb, maxtype, nla_data(nla), nla_len(nla), policy);
 }
 
-/**
- * nla_parse_nested_compat - parse nested compat attributes
- * @tb: destination array with maxtype+1 elements
- * @maxtype: maximum attribute type to be expected
- * @nla: attribute containing the nested attributes
- * @data: pointer to point to contained structure
- * @len: length of contained structure
- * @policy: validation policy
- *
- * Parse a nested compat attribute. The compat attribute contains a structure
- * and optionally a set of nested attributes. On success the data pointer
- * points to the nested data and tb contains the parsed attributes
- * (see nla_parse).
- */
-static inline int __nla_parse_nested_compat(struct nlattr *tb[], int maxtype,
-					    struct nlattr *nla,
-					    const struct nla_policy *policy,
-					    int len)
-{
-	int nested_len = nla_len(nla) - NLA_ALIGN(len);
-
-	if (nested_len < 0)
-		return -EINVAL;
-	if (nested_len >= nla_attr_size(0))
-		return nla_parse(tb, maxtype, nla_data(nla) + NLA_ALIGN(len),
-				 nested_len, policy);
-	memset(tb, 0, sizeof(struct nlattr *) * (maxtype + 1));
-	return 0;
-}
 
 #define nla_parse_nested_compat(tb, maxtype, nla, policy, data, len) \
 ({	data = nla_len(nla) >= len ? nla_data(nla) : NULL; \
@@ -1031,51 +998,6 @@
 }
 
 /**
- * nla_nest_compat_start - Start a new level of nested compat attributes
- * @skb: socket buffer to add attributes to
- * @attrtype: attribute type of container
- * @attrlen: length of structure
- * @data: pointer to structure
- *
- * Start a nested compat attribute that contains both a structure and
- * a set of nested attributes.
- *
- * Returns the container attribute
- */
-static inline struct nlattr *nla_nest_compat_start(struct sk_buff *skb,
-						   int attrtype, int attrlen,
-						   const void *data)
-{
-	struct nlattr *start = (struct nlattr *)skb_tail_pointer(skb);
-
-	if (nla_put(skb, attrtype, attrlen, data) < 0)
-		return NULL;
-	if (nla_nest_start(skb, attrtype) == NULL) {
-		nlmsg_trim(skb, start);
-		return NULL;
-	}
-	return start;
-}
-
-/**
- * nla_nest_compat_end - Finalize nesting of compat attributes
- * @skb: socket buffer the attributes are stored in
- * @start: container attribute
- *
- * Corrects the container attribute header to include the all
- * appeneded attributes.
- *
- * Returns the total data length of the skb.
- */
-static inline int nla_nest_compat_end(struct sk_buff *skb, struct nlattr *start)
-{
-	struct nlattr *nest = (void *)start + NLMSG_ALIGN(start->nla_len);
-
-	start->nla_len = skb_tail_pointer(skb) - (unsigned char *)start;
-	return nla_nest_end(skb, nest);
-}
-
-/**
  * nla_nest_cancel - Cancel nesting of attributes
  * @skb: socket buffer the message is stored in
  * @start: container attribute
Index: net-2.6/net/sched/sch_netem.c
===================================================================
--- net-2.6.orig/net/sched/sch_netem.c	2008-08-28 12:55:32.000000000 +0200
+++ net-2.6/net/sched/sch_netem.c	2008-08-28 15:35:25.000000000 +0200
@@ -388,6 +388,20 @@
 	[TCA_NETEM_CORRUPT]	= { .len = sizeof(struct tc_netem_corrupt) },
 };
 
+static int parse_attr(struct nlattr *tb[], int maxtype, struct nlattr *nla,
+		      const struct nla_policy *policy, int len)
+{
+	int nested_len = nla_len(nla) - NLA_ALIGN(len);
+
+	if (nested_len < 0)
+		return -EINVAL;
+	if (nested_len >= nla_attr_size(0))
+		return nla_parse(tb, maxtype, nla_data(nla) + NLA_ALIGN(len),
+				 nested_len, policy);
+	memset(tb, 0, sizeof(struct nlattr *) * (maxtype + 1));
+	return 0;
+}
+
 /* Parse netlink message to set options */
 static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 {
@@ -399,8 +413,8 @@
 	if (opt == NULL)
 		return -EINVAL;
 
-	ret = nla_parse_nested_compat(tb, TCA_NETEM_MAX, opt, netem_policy,
-				      qopt, sizeof(*qopt));
+	qopt = nla_data(opt);
+	ret = parse_attr(tb, TCA_NETEM_MAX, opt, netem_policy, sizeof(*qopt));
 	if (ret < 0)
 		return ret;
 
Index: net-2.6/net/sched/sch_prio.c
===================================================================
--- net-2.6.orig/net/sched/sch_prio.c	2008-08-28 12:52:07.000000000 +0200
+++ net-2.6/net/sched/sch_prio.c	2008-08-28 15:33:14.000000000 +0200
@@ -254,16 +254,12 @@
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nest;
 	struct tc_prio_qopt opt;
 
 	opt.bands = q->bands;
 	memcpy(&opt.priomap, q->prio2band, TC_PRIO_MAX+1);
 
-	nest = nla_nest_compat_start(skb, TCA_OPTIONS, sizeof(opt), &opt);
-	if (nest == NULL)
-		goto nla_put_failure;
-	nla_nest_compat_end(skb, nest);
+	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 
 	return skb->len;
 
