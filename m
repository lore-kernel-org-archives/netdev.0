From: Thomas Graf <tgraf@suug.ch>
Subject: [NETLINK]: Improve returned error codes
Date: Mon, 26 May 2008 13:32:40 +0200
Message-ID: <20080526113240.GY20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:57072 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134AbYEZLcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 07:32:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make nlmsg_trim(), nlmsg_cancel(), genlmsg_cancel(), and nla_nest_cancel()
void functions.

Return -EMSGSIZE instead of -1 if the provided message buffer
is not big enough.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/include/net/netlink.h
===================================================================
--- net-2.6.orig/include/net/netlink.h	2008-05-26 13:26:42.000000000 +0200
+++ net-2.6/include/net/netlink.h	2008-05-26 13:30:06.000000000 +0200
@@ -556,14 +556,12 @@
  * @skb: socket buffer the message is stored in
  * @mark: mark to trim to
  *
- * Trims the message to the provided mark. Returns -1.
+ * Trims the message to the provided mark.
  */
-static inline int nlmsg_trim(struct sk_buff *skb, const void *mark)
+static inline void nlmsg_trim(struct sk_buff *skb, const void *mark)
 {
 	if (mark)
 		skb_trim(skb, (unsigned char *) mark - skb->data);
-
-	return -1;
 }
 
 /**
@@ -572,11 +570,11 @@
  * @nlh: netlink message header
  *
  * Removes the complete netlink message including all
- * attributes from the socket buffer again. Returns -1.
+ * attributes from the socket buffer again.
  */
-static inline int nlmsg_cancel(struct sk_buff *skb, struct nlmsghdr *nlh)
+static inline void nlmsg_cancel(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	return nlmsg_trim(skb, nlh);
+	nlmsg_trim(skb, nlh);
 }
 
 /**
@@ -775,7 +773,7 @@
 	int nested_len = nla_len(nla) - NLA_ALIGN(len);
 
 	if (nested_len < 0)
-		return -1;
+		return -EINVAL;
 	if (nested_len >= nla_attr_size(0))
 		return nla_parse(tb, maxtype, nla_data(nla) + NLA_ALIGN(len),
 				 nested_len, policy);
@@ -1080,11 +1078,11 @@
  * @start: container attribute
  *
  * Removes the container attribute and including all nested
- * attributes. Returns -1.
+ * attributes. Returns -EMSGSIZE
  */
-static inline int nla_nest_cancel(struct sk_buff *skb, struct nlattr *start)
+static inline void nla_nest_cancel(struct sk_buff *skb, struct nlattr *start)
 {
-	return nlmsg_trim(skb, start);
+	nlmsg_trim(skb, start);
 }
 
 /**
Index: net-2.6/net/netlink/attr.c
===================================================================
--- net-2.6.orig/net/netlink/attr.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/netlink/attr.c	2008-05-26 13:30:06.000000000 +0200
@@ -400,13 +400,13 @@
  * @attrlen: length of attribute payload
  * @data: head of attribute payload
  *
- * Returns -1 if the tailroom of the skb is insufficient to store
+ * Returns -EMSGSIZE if the tailroom of the skb is insufficient to store
  * the attribute header and payload.
  */
 int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
 {
 	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
-		return -1;
+		return -EMSGSIZE;
 
 	__nla_put(skb, attrtype, attrlen, data);
 	return 0;
@@ -418,13 +418,13 @@
  * @attrlen: length of attribute payload
  * @data: head of attribute payload
  *
- * Returns -1 if the tailroom of the skb is insufficient to store
+ * Returns -EMSGSIZE if the tailroom of the skb is insufficient to store
  * the attribute payload.
  */
 int nla_put_nohdr(struct sk_buff *skb, int attrlen, const void *data)
 {
 	if (unlikely(skb_tailroom(skb) < NLA_ALIGN(attrlen)))
-		return -1;
+		return -EMSGSIZE;
 
 	__nla_put_nohdr(skb, attrlen, data);
 	return 0;
@@ -436,13 +436,13 @@
  * @attrlen: length of attribute payload
  * @data: head of attribute payload
  *
- * Returns -1 if the tailroom of the skb is insufficient to store
+ * Returns -EMSGSIZE if the tailroom of the skb is insufficient to store
  * the attribute payload.
  */
 int nla_append(struct sk_buff *skb, int attrlen, const void *data)
 {
 	if (unlikely(skb_tailroom(skb) < NLA_ALIGN(attrlen)))
-		return -1;
+		return -EMSGSIZE;
 
 	memcpy(skb_put(skb, attrlen), data, attrlen);
 	return 0;
Index: net-2.6/include/net/genetlink.h
===================================================================
--- net-2.6.orig/include/net/genetlink.h	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/include/net/genetlink.h	2008-05-26 13:30:06.000000000 +0200
@@ -162,9 +162,9 @@
  * @skb: socket buffer the message is stored in
  * @hdr: generic netlink message header
  */
-static inline int genlmsg_cancel(struct sk_buff *skb, void *hdr)
+static inline void genlmsg_cancel(struct sk_buff *skb, void *hdr)
 {
-	return nlmsg_cancel(skb, hdr - GENL_HDRLEN - NLMSG_HDRLEN);
+	nlmsg_cancel(skb, hdr - GENL_HDRLEN - NLMSG_HDRLEN);
 }
 
 /**
Index: net-2.6/net/netlink/genetlink.c
===================================================================
--- net-2.6.orig/net/netlink/genetlink.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/netlink/genetlink.c	2008-05-26 13:30:06.000000000 +0200
@@ -554,7 +554,8 @@
 	return genlmsg_end(skb, hdr);
 
 nla_put_failure:
-	return genlmsg_cancel(skb, hdr);
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
 }
 
 static int ctrl_fill_mcgrp_info(struct genl_multicast_group *grp, u32 pid,
@@ -590,7 +591,8 @@
 	return genlmsg_end(skb, hdr);
 
 nla_put_failure:
-	return genlmsg_cancel(skb, hdr);
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
 }
 
 static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
Index: net-2.6/net/wireless/nl80211.c
===================================================================
--- net-2.6.orig/net/wireless/nl80211.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/wireless/nl80211.c	2008-05-26 13:30:06.000000000 +0200
@@ -187,7 +187,8 @@
 	return genlmsg_end(msg, hdr);
 
  nla_put_failure:
-	return genlmsg_cancel(msg, hdr);
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
 }
 
 static int nl80211_dump_wiphy(struct sk_buff *skb, struct netlink_callback *cb)
@@ -273,7 +274,8 @@
 	return genlmsg_end(msg, hdr);
 
  nla_put_failure:
-	return genlmsg_cancel(msg, hdr);
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
 }
 
 static int nl80211_dump_interface(struct sk_buff *skb, struct netlink_callback *cb)
@@ -928,7 +930,8 @@
 	return genlmsg_end(msg, hdr);
 
  nla_put_failure:
-	return genlmsg_cancel(msg, hdr);
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
 }
 
 static int nl80211_dump_station(struct sk_buff *skb,
@@ -1267,7 +1270,8 @@
 	return genlmsg_end(msg, hdr);
 
  nla_put_failure:
-	return genlmsg_cancel(msg, hdr);
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
 }
 
 static int nl80211_dump_mpath(struct sk_buff *skb,
Index: net-2.6/net/core/neighbour.c
===================================================================
--- net-2.6.orig/net/core/neighbour.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/core/neighbour.c	2008-05-26 13:30:06.000000000 +0200
@@ -1714,7 +1714,8 @@
 	return nla_nest_end(skb, nest);
 
 nla_put_failure:
-	return nla_nest_cancel(skb, nest);
+	nla_nest_cancel(skb, nest);
+	return -EMSGSIZE;
 }
 
 static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
Index: net-2.6/net/core/rtnetlink.c
===================================================================
--- net-2.6.orig/net/core/rtnetlink.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/core/rtnetlink.c	2008-05-26 13:30:06.000000000 +0200
@@ -498,7 +498,8 @@
 	return nla_nest_end(skb, mx);
 
 nla_put_failure:
-	return nla_nest_cancel(skb, mx);
+	nla_nest_cancel(skb, mx);
+	return -EMSGSIZE;
 }
 
 int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
Index: net-2.6/net/sched/sch_dsmark.c
===================================================================
--- net-2.6.orig/net/sched/sch_dsmark.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/sched/sch_dsmark.c	2008-05-26 13:30:06.000000000 +0200
@@ -444,7 +444,8 @@
 	return nla_nest_end(skb, opts);
 
 nla_put_failure:
-	return nla_nest_cancel(skb, opts);
+	nla_nest_cancel(skb, opts);
+	return -EMSGSIZE;
 }
 
 static int dsmark_dump(struct Qdisc *sch, struct sk_buff *skb)
@@ -466,7 +467,8 @@
 	return nla_nest_end(skb, opts);
 
 nla_put_failure:
-	return nla_nest_cancel(skb, opts);
+	nla_nest_cancel(skb, opts);
+	return -EMSGSIZE;
 }
 
 static const struct Qdisc_class_ops dsmark_class_ops = {
Index: net-2.6/net/sched/sch_gred.c
===================================================================
--- net-2.6.orig/net/sched/sch_gred.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/sched/sch_gred.c	2008-05-26 13:30:06.000000000 +0200
@@ -582,7 +582,8 @@
 	return nla_nest_end(skb, opts);
 
 nla_put_failure:
-	return nla_nest_cancel(skb, opts);
+	nla_nest_cancel(skb, opts);
+	return -EMSGSIZE;
 }
 
 static void gred_destroy(struct Qdisc *sch)
Index: net-2.6/net/sched/sch_hfsc.c
===================================================================
--- net-2.6.orig/net/sched/sch_hfsc.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/sched/sch_hfsc.c	2008-05-26 13:30:06.000000000 +0200
@@ -1360,7 +1360,7 @@
 
  nla_put_failure:
 	nla_nest_cancel(skb, nest);
-	return -1;
+	return -EMSGSIZE;
 }
 
 static int
Index: net-2.6/net/sched/sch_red.c
===================================================================
--- net-2.6.orig/net/sched/sch_red.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/sched/sch_red.c	2008-05-26 13:30:06.000000000 +0200
@@ -281,7 +281,8 @@
 	return nla_nest_end(skb, opts);
 
 nla_put_failure:
-	return nla_nest_cancel(skb, opts);
+	nla_nest_cancel(skb, opts);
+	return -EMSGSIZE;
 }
 
 static int red_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
