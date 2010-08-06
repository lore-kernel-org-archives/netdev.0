From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/9] net classifier: deinline bind/unbind functions
Date: Fri, 06 Aug 2010 12:35:50 -0700
Message-ID: <20100806193558.667488554@vyatta.com>
References: <20100806193548.007978639@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35719 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940Ab0HFTiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 15:38:04 -0400
Content-Disposition: inline; filename=cls-deinline.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The filter bind/unbind functions are not worth inlining.
Not performance critical in the least.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/pkt_cls.h |   52 ++------------------------------------------------
 net/sched/cls_api.c   |   50 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 53 insertions(+), 49 deletions(-)

--- a/include/net/pkt_cls.h	2010-08-06 12:21:18.000000000 -0700
+++ b/include/net/pkt_cls.h	2010-08-06 12:21:59.736709482 -0700
@@ -16,55 +16,9 @@ struct tcf_walker {
 
 extern int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 extern int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
-
-static inline unsigned long
-__cls_set_class(unsigned long *clp, unsigned long cl)
-{
-	unsigned long old_cl;
- 
-	old_cl = *clp;
-	*clp = cl;
-	return old_cl;
-}
-
-static inline unsigned long
-cls_set_class(struct tcf_proto *tp, unsigned long *clp, 
-	unsigned long cl)
-{
-	unsigned long old_cl;
-	
-	tcf_tree_lock(tp);
-	old_cl = __cls_set_class(clp, cl);
-	tcf_tree_unlock(tp);
- 
-	return old_cl;
-}
-
-static inline int
-tcf_bind_filter(struct tcf_proto *tp, struct tcf_result *r, unsigned long base)
-{
-	const struct Qdisc_class_ops *cops = tp->q->ops->cl_ops;
-	unsigned long cl;
-
-	if (!cops->bind_tcf)
-		return -EINVAL;
-
-	cl = cops->bind_tcf(tp->q, base, r->classid);
-	cl = cls_set_class(tp, &r->class, cl);
-	if (cl)
-		cops->unbind_tcf(tp->q, cl);
-
-	return 0;
-}
-
-static inline void
-tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
-{
-	unsigned long cl;
-
-	if ((cl = __cls_set_class(&r->class, 0)) != 0)
-		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
-}
+extern int tcf_bind_filter(struct tcf_proto *tp, struct tcf_result *r,
+			   unsigned long base);
+extern void tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r);
 
 struct tcf_exts {
 #ifdef CONFIG_NET_CLS_ACT
--- a/net/sched/cls_api.c	2010-08-06 12:20:02.000000000 -0700
+++ b/net/sched/cls_api.c	2010-08-06 12:21:21.623261373 -0700
@@ -99,6 +99,56 @@ out:
 }
 EXPORT_SYMBOL(unregister_tcf_proto_ops);
 
+static unsigned long __cls_set_class(unsigned long *clp, unsigned long cl)
+{
+	unsigned long old_cl;
+
+	old_cl = *clp;
+	*clp = cl;
+	return old_cl;
+}
+
+static unsigned long cls_set_class(struct tcf_proto *tp, unsigned long *clp,
+				   unsigned long cl)
+{
+	unsigned long old_cl;
+
+	tcf_tree_lock(tp);
+	old_cl = __cls_set_class(clp, cl);
+	tcf_tree_unlock(tp);
+
+	return old_cl;
+}
+
+int tcf_bind_filter(struct tcf_proto *tp, struct tcf_result *r,
+		    unsigned long base)
+{
+	const struct Qdisc_class_ops *cops = tp->q->ops->cl_ops;
+	unsigned long cl;
+
+	if (!cops->bind_tcf)
+		return -ENOENT;
+
+	cl = cops->bind_tcf(tp->q, base, r->classid);
+	cl = cls_set_class(tp, &r->class, cl);
+	if (cl)
+		cops->unbind_tcf(tp->q, cl);
+
+	return 0;
+}
+EXPORT_SYMBOL(tcf_bind_filter);
+
+void tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
+{
+	unsigned long cl;
+
+	cl = __cls_set_class(&r->class, 0);
+	if (cl)
+		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+}
+EXPORT_SYMBOL(tcf_unbind_filter);
+
+
 static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 			  struct nlmsghdr *n, struct tcf_proto *tp,
 			  unsigned long fh, int event);


