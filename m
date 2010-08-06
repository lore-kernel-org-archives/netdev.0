From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/9] net classifier: dont allow filters on semi-classful qdisc
Date: Fri, 06 Aug 2010 12:35:49 -0700
Message-ID: <20100806193558.580890552@vyatta.com>
References: <20100806193548.007978639@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35710 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761960Ab0HFTiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 15:38:05 -0400
Content-Disposition: inline; filename=cls-bind-tcf.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several qdisc which only support a single class (sfq, mq, tbf)
and the kernel would dereference a null pointer (bind_tcf), if a user
attempted to apply a filter one of these classes.

This patch changes the tcf_bind_filter to return an error in
these cases.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
This needs to go in net-2.6 and stable.

 include/net/pkt_cls.h   |   12 +++++++++---
 net/sched/cls_basic.c   |    4 +++-
 net/sched/cls_fw.c      |    6 ++++--
 net/sched/cls_route.c   |    4 +++-
 net/sched/cls_tcindex.c |    4 +++-
 net/sched/cls_u32.c     |    4 +++-
 6 files changed, 25 insertions(+), 9 deletions(-)

--- a/include/net/pkt_cls.h	2010-08-06 11:51:18.903581556 -0700
+++ b/include/net/pkt_cls.h	2010-08-06 12:20:02.072241508 -0700
@@ -40,15 +40,21 @@ cls_set_class(struct tcf_proto *tp, unsi
 	return old_cl;
 }
 
-static inline void
+static inline int
 tcf_bind_filter(struct tcf_proto *tp, struct tcf_result *r, unsigned long base)
 {
+	const struct Qdisc_class_ops *cops = tp->q->ops->cl_ops;
 	unsigned long cl;
 
-	cl = tp->q->ops->cl_ops->bind_tcf(tp->q, base, r->classid);
+	if (!cops->bind_tcf)
+		return -EINVAL;
+
+	cl = cops->bind_tcf(tp->q, base, r->classid);
 	cl = cls_set_class(tp, &r->class, cl);
 	if (cl)
-		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+		cops->unbind_tcf(tp->q, cl);
+
+	return 0;
 }
 
 static inline void
--- a/net/sched/cls_basic.c	2010-08-06 11:51:18.923582342 -0700
+++ b/net/sched/cls_basic.c	2010-08-06 11:55:13.292553190 -0700
@@ -153,7 +153,9 @@ static inline int basic_set_parms(struct
 
 	if (tb[TCA_BASIC_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_BASIC_CLASSID]);
-		tcf_bind_filter(tp, &f->res, base);
+		err = tcf_bind_filter(tp, &f->res, base);
+		if (err)
+			goto errout;
 	}
 
 	tcf_exts_change(tp, &f->exts, &e);
--- a/net/sched/cls_fw.c	2010-08-06 11:51:18.943583126 -0700
+++ b/net/sched/cls_fw.c	2010-08-06 11:55:39.085476144 -0700
@@ -206,10 +206,11 @@ fw_change_attrs(struct tcf_proto *tp, st
 	if (err < 0)
 		return err;
 
-	err = -EINVAL;
 	if (tb[TCA_FW_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_FW_CLASSID]);
-		tcf_bind_filter(tp, &f->res, base);
+		err = tcf_bind_filter(tp, &f->res, base);
+		if (err)
+			goto errout;
 	}
 
 #ifdef CONFIG_NET_CLS_IND
@@ -220,6 +221,7 @@ fw_change_attrs(struct tcf_proto *tp, st
 	}
 #endif /* CONFIG_NET_CLS_IND */
 
+	err = -EINVAL;
 	if (tb[TCA_FW_MASK]) {
 		mask = nla_get_u32(tb[TCA_FW_MASK]);
 		if (mask != head->mask)
--- a/net/sched/cls_route.c	2010-08-06 11:51:18.959583757 -0700
+++ b/net/sched/cls_route.c	2010-08-06 11:55:50.077870498 -0700
@@ -412,7 +412,9 @@ static int route4_set_parms(struct tcf_p
 
 	if (tb[TCA_ROUTE4_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_ROUTE4_CLASSID]);
-		tcf_bind_filter(tp, &f->res, base);
+		err = tcf_bind_filter(tp, &f->res, base);
+		if (err)
+			goto errout;
 	}
 
 	tcf_exts_change(tp, &f->exts, &e);
--- a/net/sched/cls_tcindex.c	2010-08-06 11:51:18.999585326 -0700
+++ b/net/sched/cls_tcindex.c	2010-08-06 11:56:01.486283847 -0700
@@ -295,7 +295,9 @@ tcindex_set_parms(struct tcf_proto *tp, 
 
 	if (tb[TCA_TCINDEX_CLASSID]) {
 		cr.res.classid = nla_get_u32(tb[TCA_TCINDEX_CLASSID]);
-		tcf_bind_filter(tp, &cr.res, base);
+		err = tcf_bind_filter(tp, &cr.res, base);
+		if (err)
+			goto errout;
 	}
 
 	tcf_exts_change(tp, &cr.exts, &e);
--- a/net/sched/cls_u32.c	2010-08-06 11:51:19.019586112 -0700
+++ b/net/sched/cls_u32.c	2010-08-06 11:56:12.390678703 -0700
@@ -528,7 +528,9 @@ static int u32_set_parms(struct tcf_prot
 	}
 	if (tb[TCA_U32_CLASSID]) {
 		n->res.classid = nla_get_u32(tb[TCA_U32_CLASSID]);
-		tcf_bind_filter(tp, &n->res, base);
+		err = tcf_bind_filter(tp, &n->res, base);
+		if (err)
+			goto errout;
 	}
 
 #ifdef CONFIG_NET_CLS_IND


