From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 20/20] net: sched: avoid atomic swap in tcf_exts_change
Date: Fri,  4 Aug 2017 14:29:15 +0200
Message-ID: <20170804122915.15177-21-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36768 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752330AbdHDMaI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:30:08 -0400
Received: by mail-wm0-f66.google.com with SMTP id d40so5520927wma.3
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:30:08 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

tcf_exts_change is always called on newly created exts, which are not used
on fastpath. Therefore, simple struct copy is enough.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h   |  3 +--
 net/sched/cls_api.c     | 10 ++--------
 net/sched/cls_rsvp.h    |  4 ++--
 net/sched/cls_tcindex.c |  6 +++---
 4 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index b8959c9..e0c54f1 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -201,8 +201,7 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
 		      struct nlattr **tb, struct nlattr *rate_tlv,
 		      struct tcf_exts *exts, bool ovr);
 void tcf_exts_destroy(struct tcf_exts *exts);
-void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
-		     struct tcf_exts *src);
+void tcf_exts_change(struct tcf_exts *dst, struct tcf_exts *src);
 int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts);
 int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts);
 int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 735d556..e655221 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -883,18 +883,12 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 }
 EXPORT_SYMBOL(tcf_exts_validate);
 
-void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
-		     struct tcf_exts *src)
+void tcf_exts_change(struct tcf_exts *dst, struct tcf_exts *src)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	struct tcf_exts old = *dst;
 
-	tcf_tree_lock(tp);
-	dst->nr_actions = src->nr_actions;
-	dst->actions = src->actions;
-	dst->type = src->type;
-	tcf_tree_unlock(tp);
-
+	*dst = *src;
 	tcf_exts_destroy(&old);
 #endif
 }
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 0d9d077..4adb67a 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -518,7 +518,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 			tcf_bind_filter(tp, &n->res, base);
 		}
 
-		tcf_exts_change(tp, &n->exts, &e);
+		tcf_exts_change(&n->exts, &e);
 		rsvp_replace(tp, n, handle);
 		return 0;
 	}
@@ -591,7 +591,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 			if (f->tunnelhdr == 0)
 				tcf_bind_filter(tp, &f->res, base);
 
-			tcf_exts_change(tp, &f->exts, &e);
+			tcf_exts_change(&f->exts, &e);
 
 			fp = &s->ht[h2];
 			for (nfp = rtnl_dereference(*fp); nfp;
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 66924d1..d69f828 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -419,9 +419,9 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	}
 
 	if (old_r)
-		tcf_exts_change(tp, &r->exts, &e);
+		tcf_exts_change(&r->exts, &e);
 	else
-		tcf_exts_change(tp, &cr.exts, &e);
+		tcf_exts_change(&cr.exts, &e);
 
 	if (old_r && old_r != r) {
 		err = tcindex_filter_result_init(old_r);
@@ -439,7 +439,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		struct tcindex_filter *nfp;
 		struct tcindex_filter __rcu **fp;
 
-		tcf_exts_change(tp, &f->result.exts, &r->exts);
+		tcf_exts_change(&f->result.exts, &r->exts);
 
 		fp = cp->h + (handle % cp->hash);
 		for (nfp = rtnl_dereference(*fp);
-- 
2.9.3
