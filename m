From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] net: sched: constify tcf_proto and tc_action
Date: Wed, 06 Jul 2011 06:32:45 +0200
Message-ID: <1309926765.2545.53.camel@edumazet-laptop>
References: <1309883807.2271.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49352 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907Ab1GFEcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 00:32:51 -0400
Received: by wwe5 with SMTP id 5so6549646wwe.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 21:32:49 -0700 (PDT)
In-Reply-To: <1309883807.2271.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/act_api.h     |    6 +++---
 include/net/pkt_sched.h   |    4 ++--
 include/net/sch_generic.h |   12 +++++++-----
 net/sched/act_api.c       |    4 ++--
 net/sched/act_csum.c      |    2 +-
 net/sched/act_gact.c      |    3 ++-
 net/sched/act_ipt.c       |    2 +-
 net/sched/act_mirred.c    |    2 +-
 net/sched/act_nat.c       |    2 +-
 net/sched/act_pedit.c     |    2 +-
 net/sched/act_police.c    |    2 +-
 net/sched/act_simple.c    |    3 ++-
 net/sched/act_skbedit.c   |    2 +-
 net/sched/cls_api.c       |    6 +++---
 net/sched/cls_basic.c     |    2 +-
 net/sched/cls_flow.c      |    2 +-
 net/sched/cls_fw.c        |    2 +-
 net/sched/cls_route.c     |    2 +-
 net/sched/cls_rsvp.h      |    2 +-
 net/sched/cls_tcindex.c   |    2 +-
 net/sched/cls_u32.c       |    2 +-
 net/sched/sch_api.c       |    6 +++---
 22 files changed, 38 insertions(+), 34 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index bab385f..c739531 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -72,7 +72,7 @@ struct tcf_act_hdr {
 
 struct tc_action {
 	void			*priv;
-	struct tc_action_ops	*ops;
+	const struct tc_action_ops	*ops;
 	__u32			type; /* for backward compat(TCA_OLD_COMPAT) */
 	__u32			order;
 	struct tc_action	*next;
@@ -86,7 +86,7 @@ struct tc_action_ops {
 	__u32   type; /* TBD to match kind */
 	__u32 	capab;  /* capabilities includes 4 bit version */
 	struct module		*owner;
-	int     (*act)(struct sk_buff *, struct tc_action *, struct tcf_result *);
+	int     (*act)(struct sk_buff *, const struct tc_action *, struct tcf_result *);
 	int     (*get_stats)(struct sk_buff *, struct tc_action *);
 	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
 	int     (*cleanup)(struct tc_action *, int bind);
@@ -115,7 +115,7 @@ extern void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo);
 extern int tcf_register_action(struct tc_action_ops *a);
 extern int tcf_unregister_action(struct tc_action_ops *a);
 extern void tcf_action_destroy(struct tc_action *a, int bind);
-extern int tcf_action_exec(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res);
+extern int tcf_action_exec(struct sk_buff *skb, const struct tc_action *a, struct tcf_result *res);
 extern struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est, char *n, int ovr, int bind);
 extern struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est, char *n, int ovr, int bind);
 extern int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 65afc49..fffdc60 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -99,9 +99,9 @@ static inline void qdisc_run(struct Qdisc *q)
 		__qdisc_run(q);
 }
 
-extern int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
+extern int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
 			      struct tcf_result *res);
-extern int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
+extern int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		       struct tcf_result *res);
 
 /* Calculate maximal size of packet seen by hard_start_xmit
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b931f02..626177b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -181,8 +181,9 @@ struct tcf_proto_ops {
 	struct tcf_proto_ops	*next;
 	char			kind[IFNAMSIZ];
 
-	int			(*classify)(struct sk_buff*, struct tcf_proto*,
-					struct tcf_result *);
+	int			(*classify)(struct sk_buff *,
+					    const struct tcf_proto*,
+					    struct tcf_result *);
 	int			(*init)(struct tcf_proto*);
 	void			(*destroy)(struct tcf_proto*);
 
@@ -205,8 +206,9 @@ struct tcf_proto {
 	/* Fast access part */
 	struct tcf_proto	*next;
 	void			*root;
-	int			(*classify)(struct sk_buff*, struct tcf_proto*,
-					struct tcf_result *);
+	int			(*classify)(struct sk_buff *,
+					    const struct tcf_proto *,
+					    struct tcf_result *);
 	__be16			protocol;
 
 	/* All the rest */
@@ -214,7 +216,7 @@ struct tcf_proto {
 	u32			classid;
 	struct Qdisc		*q;
 	void			*data;
-	struct tcf_proto_ops	*ops;
+	const struct tcf_proto_ops	*ops;
 };
 
 struct qdisc_skb_cb {
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 2f64262..f2fb67e 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -365,10 +365,10 @@ static struct tc_action_ops *tc_lookup_action_id(u32 type)
 }
 #endif
 
-int tcf_action_exec(struct sk_buff *skb, struct tc_action *act,
+int tcf_action_exec(struct sk_buff *skb, const struct tc_action *act,
 		    struct tcf_result *res)
 {
-	struct tc_action *a;
+	const struct tc_action *a;
 	int ret = -1;
 
 	if (skb->tc_verd & TC_NCLS) {
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 6cdf9ab..453a734 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -500,7 +500,7 @@ fail:
 }
 
 static int tcf_csum(struct sk_buff *skb,
-		    struct tc_action *a, struct tcf_result *res)
+		    const struct tc_action *a, struct tcf_result *res)
 {
 	struct tcf_csum *p = a->priv;
 	int action;
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 2b4ab4b..b77f5a0 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -125,7 +125,8 @@ static int tcf_gact_cleanup(struct tc_action *a, int bind)
 	return 0;
 }
 
-static int tcf_gact(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res)
+static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
+		    struct tcf_result *res)
 {
 	struct tcf_gact *gact = a->priv;
 	int action = TC_ACT_SHOT;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 9fc211a..60f8f61 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -195,7 +195,7 @@ static int tcf_ipt_cleanup(struct tc_action *a, int bind)
 	return tcf_ipt_release(ipt, bind);
 }
 
-static int tcf_ipt(struct sk_buff *skb, struct tc_action *a,
+static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 		   struct tcf_result *res)
 {
 	int ret = 0, result = 0;
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 961386e..102fc21 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -154,7 +154,7 @@ static int tcf_mirred_cleanup(struct tc_action *a, int bind)
 	return 0;
 }
 
-static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
+static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 		      struct tcf_result *res)
 {
 	struct tcf_mirred *m = a->priv;
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 762b027..001d1b3 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -102,7 +102,7 @@ static int tcf_nat_cleanup(struct tc_action *a, int bind)
 	return tcf_hash_release(&p->common, bind, &nat_hash_info);
 }
 
-static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
+static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 		   struct tcf_result *res)
 {
 	struct tcf_nat *p = a->priv;
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 7affe9a..10d3aed 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -120,7 +120,7 @@ static int tcf_pedit_cleanup(struct tc_action *a, int bind)
 	return 0;
 }
 
-static int tcf_pedit(struct sk_buff *skb, struct tc_action *a,
+static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 		     struct tcf_result *res)
 {
 	struct tcf_pedit *p = a->priv;
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index b3b9b32..6fb3f5a 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -282,7 +282,7 @@ static int tcf_act_police_cleanup(struct tc_action *a, int bind)
 	return ret;
 }
 
-static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
+static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 			  struct tcf_result *res)
 {
 	struct tcf_police *police = a->priv;
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index a34a22d..73e0a3a 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -36,7 +36,8 @@ static struct tcf_hashinfo simp_hash_info = {
 };
 
 #define SIMP_MAX_DATA	32
-static int tcf_simp(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res)
+static int tcf_simp(struct sk_buff *skb, const struct tc_action *a,
+		    struct tcf_result *res)
 {
 	struct tcf_defact *d = a->priv;
 
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 5f6f0c7..35dbbe9 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -39,7 +39,7 @@ static struct tcf_hashinfo skbedit_hash_info = {
 	.lock	=	&skbedit_lock,
 };
 
-static int tcf_skbedit(struct sk_buff *skb, struct tc_action *a,
+static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
 		       struct tcf_result *res)
 {
 	struct tcf_skbedit *d = a->priv;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 9563887..a69d44f 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -40,9 +40,9 @@ static DEFINE_RWLOCK(cls_mod_lock);
 
 /* Find classifier type by string name */
 
-static struct tcf_proto_ops *tcf_proto_lookup_ops(struct nlattr *kind)
+static const struct tcf_proto_ops *tcf_proto_lookup_ops(struct nlattr *kind)
 {
-	struct tcf_proto_ops *t = NULL;
+	const struct tcf_proto_ops *t = NULL;
 
 	if (kind) {
 		read_lock(&cls_mod_lock);
@@ -132,7 +132,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	struct Qdisc  *q;
 	struct tcf_proto **back, **chain;
 	struct tcf_proto *tp;
-	struct tcf_proto_ops *tp_ops;
+	const struct tcf_proto_ops *tp_ops;
 	const struct Qdisc_class_ops *cops;
 	unsigned long cl;
 	unsigned long fh;
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 8be8872..ea1f70b 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -39,7 +39,7 @@ static const struct tcf_ext_map basic_ext_map = {
 	.police = TCA_BASIC_POLICE
 };
 
-static int basic_classify(struct sk_buff *skb, struct tcf_proto *tp,
+static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			  struct tcf_result *res)
 {
 	int r;
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 34533a5..6994214 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -356,7 +356,7 @@ static u32 flow_key_get(struct sk_buff *skb, int key)
 	}
 }
 
-static int flow_classify(struct sk_buff *skb, struct tcf_proto *tp,
+static int flow_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			 struct tcf_result *res)
 {
 	struct flow_head *head = tp->root;
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 26e7bc4..389af15 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -77,7 +77,7 @@ static inline int fw_hash(u32 handle)
 		return handle & (HTSIZE - 1);
 }
 
-static int fw_classify(struct sk_buff *skb, struct tcf_proto *tp,
+static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			  struct tcf_result *res)
 {
 	struct fw_head *head = (struct fw_head *)tp->root;
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index a9079053..13ab66e 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -125,7 +125,7 @@ static inline int route4_hash_wild(void)
 	return 0;						\
 }
 
-static int route4_classify(struct sk_buff *skb, struct tcf_proto *tp,
+static int route4_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			   struct tcf_result *res)
 {
 	struct route4_head *head = (struct route4_head *)tp->root;
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index ed691b1..be4505e 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -130,7 +130,7 @@ static struct tcf_ext_map rsvp_ext_map = {
 		return r;				\
 }
 
-static int rsvp_classify(struct sk_buff *skb, struct tcf_proto *tp,
+static int rsvp_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			 struct tcf_result *res)
 {
 	struct rsvp_session **sht = ((struct rsvp_head *)tp->root)->ht;
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 36667fa..dbe1992 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -79,7 +79,7 @@ tcindex_lookup(struct tcindex_data *p, u16 key)
 }
 
 
-static int tcindex_classify(struct sk_buff *skb, struct tcf_proto *tp,
+static int tcindex_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			    struct tcf_result *res)
 {
 	struct tcindex_data *p = PRIV(tp);
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 3b93fc0..939b627 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -93,7 +93,7 @@ static inline unsigned int u32_hash_fold(__be32 key,
 	return h;
 }
 
-static int u32_classify(struct sk_buff *skb, struct tcf_proto *tp, struct tcf_result *res)
+static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct tcf_result *res)
 {
 	struct {
 		struct tc_u_knode *knode;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 8182aef..dca6c1a 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1644,7 +1644,7 @@ done:
  * to this qdisc, (optionally) tests for protocol and asks
  * specific classifiers.
  */
-int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
+int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
 		       struct tcf_result *res)
 {
 	__be16 protocol = skb->protocol;
@@ -1668,12 +1668,12 @@ int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
 }
 EXPORT_SYMBOL(tc_classify_compat);
 
-int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
+int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		struct tcf_result *res)
 {
 	int err = 0;
 #ifdef CONFIG_NET_CLS_ACT
-	struct tcf_proto *otp = tp;
+	const struct tcf_proto *otp = tp;
 reclassify:
 #endif
 


