From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 05/20] net: sched: remove redundant helpers tcf_exts_is_predicative and tcf_exts_is_available
Date: Fri,  4 Aug 2017 14:29:00 +0200
Message-ID: <20170804122915.15177-6-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37625 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752491AbdHDM33 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:29 -0400
Received: by mail-wm0-f67.google.com with SMTP id t138so5520492wmt.4
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:29 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

These two helpers are doing the same as tcf_exts_has_actions, so remove
them and use tcf_exts_has_actions instead.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h   | 30 ------------------------------
 net/sched/cls_fw.c      |  2 +-
 net/sched/cls_route.c   |  2 +-
 net/sched/cls_tcindex.c |  2 +-
 4 files changed, 3 insertions(+), 33 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 322a282..817badf 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -113,36 +113,6 @@ static inline int tcf_exts_init(struct tcf_exts *exts, int action, int police)
 	return 0;
 }
 
-/**
- * tcf_exts_is_predicative - check if a predicative extension is present
- * @exts: tc filter extensions handle
- *
- * Returns 1 if a predicative extension is present, i.e. an extension which
- * might cause further actions and thus overrule the regular tcf_result.
- */
-static inline int
-tcf_exts_is_predicative(struct tcf_exts *exts)
-{
-#ifdef CONFIG_NET_CLS_ACT
-	return exts->nr_actions;
-#else
-	return 0;
-#endif
-}
-
-/**
- * tcf_exts_is_available - check if at least one extension is present
- * @exts: tc filter extensions handle
- *
- * Returns 1 if at least one extension is present.
- */
-static inline int
-tcf_exts_is_available(struct tcf_exts *exts)
-{
-	/* All non-predicative extensions must be added here. */
-	return tcf_exts_is_predicative(exts);
-}
-
 static inline void tcf_exts_to_list(const struct tcf_exts *exts,
 				    struct list_head *actions)
 {
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index d388536..a53fa75 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -387,7 +387,7 @@ static int fw_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	t->tcm_handle = f->id;
 
-	if (!f->res.classid && !tcf_exts_is_available(&f->exts))
+	if (!f->res.classid && !tcf_exts_has_actions(&f->exts))
 		return skb->len;
 
 	nest = nla_nest_start(skb, TCA_OPTIONS);
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index d63d550..26f8636 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -113,7 +113,7 @@ static inline int route4_hash_wild(void)
 #define ROUTE4_APPLY_RESULT()					\
 {								\
 	*res = f->res;						\
-	if (tcf_exts_is_available(&f->exts)) {			\
+	if (tcf_exts_has_actions(&f->exts)) {			\
 		int r = tcf_exts_exec(skb, &f->exts, res);	\
 		if (r < 0) {					\
 			dont_cache = 1;				\
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 8a8a583..66924d1 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -52,7 +52,7 @@ struct tcindex_data {
 
 static inline int tcindex_filter_is_set(struct tcindex_filter_result *r)
 {
-	return tcf_exts_is_predicative(&r->exts) || r->res.classid;
+	return tcf_exts_has_actions(&r->exts) || r->res.classid;
 }
 
 static struct tcindex_filter_result *tcindex_lookup(struct tcindex_data *p,
-- 
2.9.3
