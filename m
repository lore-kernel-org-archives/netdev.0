From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/9] net: sched: teach tcf_bind/unbind_filter to use block->q
Date: Fri, 13 Oct 2017 14:01:00 +0200
Message-ID: <20171013120105.23358-5-jiri@resnulli.us>
References: <20171013120105.23358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:55365 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758070AbdJMMBM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 08:01:12 -0400
Received: by mail-wm0-f65.google.com with SMTP id u138so21285023wmu.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 05:01:11 -0700 (PDT)
In-Reply-To: <20171013120105.23358-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Whenever the block->q is set, it can be used instead of tp->q as it
contains the same value. When it is not set, which can't happen now but
it might happen with the follow-up shared blocks introduction, the class
is not set in the result. That would lead to a class lookup instead
of direct class pointer use for classful qdiscs. However, it is not
planned to support classful qdisqs sharing filter blocks, so that may
never happen.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 01ffda5..bf6c853 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -74,36 +74,43 @@ __cls_set_class(unsigned long *clp, unsigned long cl)
 }
 
 static inline unsigned long
-cls_set_class(struct tcf_proto *tp, unsigned long *clp, 
-	unsigned long cl)
+cls_set_class(struct Qdisc *q, unsigned long *clp, unsigned long cl)
 {
 	unsigned long old_cl;
-	
-	tcf_tree_lock(tp);
+
+	sch_tree_lock(q);
 	old_cl = __cls_set_class(clp, cl);
-	tcf_tree_unlock(tp);
- 
+	sch_tree_unlock(q);
 	return old_cl;
 }
 
 static inline void
 tcf_bind_filter(struct tcf_proto *tp, struct tcf_result *r, unsigned long base)
 {
+	struct Qdisc *q = tp->chain->block->q;
 	unsigned long cl;
 
-	cl = tp->q->ops->cl_ops->bind_tcf(tp->q, base, r->classid);
-	cl = cls_set_class(tp, &r->class, cl);
+	/* Check q as it is not set for shared blocks. In that case,
+	 * setting class is not supported.
+	 */
+	if (!q)
+		return;
+	cl = q->ops->cl_ops->bind_tcf(q, base, r->classid);
+	cl = cls_set_class(q, &r->class, cl);
 	if (cl)
-		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+		q->ops->cl_ops->unbind_tcf(q, cl);
 }
 
 static inline void
 tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
 {
+	struct Qdisc *q = tp->chain->block->q;
 	unsigned long cl;
 
+	if (!q)
+		return;
 	if ((cl = __cls_set_class(&r->class, 0)) != 0)
-		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+		q->ops->cl_ops->unbind_tcf(q, cl);
 }
 
 struct tcf_exts {
-- 
2.9.5
