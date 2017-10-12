From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/34] net: sched: teach tcf_bind/unbind_filter to use block->q
Date: Thu, 12 Oct 2017 19:17:53 +0200
Message-ID: <20171012171823.1431-5-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35309 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752797AbdJLRS3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:29 -0400
Received: by mail-wm0-f66.google.com with SMTP id b189so4344612wmd.2
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:28 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
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
index 0cf520b..05bc999 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -108,36 +108,43 @@ __cls_set_class(unsigned long *clp, unsigned long cl)
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
