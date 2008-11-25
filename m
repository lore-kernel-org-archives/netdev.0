From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1a/2] tc: propogate errors from tcf_hash_create
Date: Tue, 25 Nov 2008 10:57:27 -0800
Message-ID: <20081125105727.56b7efef@extreme>
References: <20081125101656.52348bdd@extreme>
	<492C43DF.1040703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49057 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751976AbYKYS67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 13:58:59 -0500
In-Reply-To: <492C43DF.1040703@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow tcf_hash_create to return different errors on estimator failure.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/sched/act_api.c     |   18 +++++++++++++-----
 net/sched/act_gact.c    |    4 ++--
 net/sched/act_ipt.c     |    4 ++--
 net/sched/act_mirred.c  |    4 ++--
 net/sched/act_nat.c     |    4 ++--
 net/sched/act_pedit.c   |    4 ++--
 net/sched/act_simple.c  |    4 ++--
 net/sched/act_skbedit.c |    4 ++--
 8 files changed, 27 insertions(+), 19 deletions(-)

--- a/net/sched/act_api.c	2008-11-25 10:47:48.000000000 -0800
+++ b/net/sched/act_api.c	2008-11-25 10:50:56.000000000 -0800
@@ -214,12 +214,14 @@ struct tcf_common *tcf_hash_check(u32 in
 }
 EXPORT_SYMBOL(tcf_hash_check);
 
-struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a, int size, int bind, u32 *idx_gen, struct tcf_hashinfo *hinfo)
+struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
+				   struct tc_action *a, int size, int bind,
+				   u32 *idx_gen, struct tcf_hashinfo *hinfo)
 {
 	struct tcf_common *p = kzalloc(size, GFP_KERNEL);
 
 	if (unlikely(!p))
-		return p;
+		return ERR_PTR(-ENOMEM);
 	p->tcfc_refcnt = 1;
 	if (bind)
 		p->tcfc_bindcnt = 1;
@@ -228,9 +230,15 @@ struct tcf_common *tcf_hash_create(u32 i
 	p->tcfc_index = index ? index : tcf_hash_new_index(idx_gen, hinfo);
 	p->tcfc_tm.install = jiffies;
 	p->tcfc_tm.lastuse = jiffies;
-	if (est)
-		gen_new_estimator(&p->tcfc_bstats, &p->tcfc_rate_est,
-				  &p->tcfc_lock, est);
+	if (est) {
+		int err = gen_new_estimator(&p->tcfc_bstats, &p->tcfc_rate_est,
+					    &p->tcfc_lock, est);
+		if (err) {
+			kfree(p);
+			return ERR_PTR(err);
+		}
+	}
+
 	a->priv = (void *) p;
 	return p;
 }
--- a/net/sched/act_gact.c	2008-11-25 10:47:48.000000000 -0800
+++ b/net/sched/act_gact.c	2008-11-25 10:52:19.000000000 -0800
@@ -88,8 +88,8 @@ static int tcf_gact_init(struct nlattr *
 	if (!pc) {
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*gact),
 				     bind, &gact_idx_gen, &gact_hash_info);
-		if (unlikely(!pc))
-			return -ENOMEM;
+		if (IS_ERR(pc))
+		    return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
--- a/net/sched/act_ipt.c	2008-11-25 10:47:48.000000000 -0800
+++ b/net/sched/act_ipt.c	2008-11-25 10:52:31.000000000 -0800
@@ -136,8 +136,8 @@ static int tcf_ipt_init(struct nlattr *n
 	if (!pc) {
 		pc = tcf_hash_create(index, est, a, sizeof(*ipt), bind,
 				     &ipt_idx_gen, &ipt_hash_info);
-		if (unlikely(!pc))
-			return -ENOMEM;
+		if (IS_ERR(pc))
+		    return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
--- a/net/sched/act_mirred.c	2008-11-25 10:47:48.000000000 -0800
+++ b/net/sched/act_mirred.c	2008-11-25 10:52:25.000000000 -0800
@@ -105,8 +105,8 @@ static int tcf_mirred_init(struct nlattr
 			return -EINVAL;
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*m), bind,
 				     &mirred_idx_gen, &mirred_hash_info);
-		if (unlikely(!pc))
-			return -ENOMEM;
+		if (IS_ERR(pc))
+		    return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
--- a/net/sched/act_nat.c	2008-11-25 10:47:48.000000000 -0800
+++ b/net/sched/act_nat.c	2008-11-25 10:52:37.000000000 -0800
@@ -68,8 +68,8 @@ static int tcf_nat_init(struct nlattr *n
 	if (!pc) {
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
 				     &nat_idx_gen, &nat_hash_info);
-		if (unlikely(!pc))
-			return -ENOMEM;
+		if (IS_ERR(pc))
+		    return PTR_ERR(pc);
 		p = to_tcf_nat(pc);
 		ret = ACT_P_CREATED;
 	} else {
--- a/net/sched/act_pedit.c	2008-11-25 10:47:48.000000000 -0800
+++ b/net/sched/act_pedit.c	2008-11-25 10:52:44.000000000 -0800
@@ -68,8 +68,8 @@ static int tcf_pedit_init(struct nlattr 
 			return -EINVAL;
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
 				     &pedit_idx_gen, &pedit_hash_info);
-		if (unlikely(!pc))
-			return -ENOMEM;
+		if (IS_ERR(pc))
+		    return PTR_ERR(pc);
 		p = to_pedit(pc);
 		keys = kmalloc(ksize, GFP_KERNEL);
 		if (keys == NULL) {
--- a/net/sched/act_simple.c	2008-11-25 10:47:48.000000000 -0800
+++ b/net/sched/act_simple.c	2008-11-25 10:52:51.000000000 -0800
@@ -124,8 +124,8 @@ static int tcf_simp_init(struct nlattr *
 	if (!pc) {
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
 				     &simp_idx_gen, &simp_hash_info);
-		if (unlikely(!pc))
-			return -ENOMEM;
+		if (IS_ERR(pc))
+		    return PTR_ERR(pc);
 
 		d = to_defact(pc);
 		ret = alloc_defdata(d, defdata);
--- a/net/sched/act_skbedit.c	2008-11-25 10:47:48.000000000 -0800
+++ b/net/sched/act_skbedit.c	2008-11-25 10:53:11.000000000 -0800
@@ -104,8 +104,8 @@ static int tcf_skbedit_init(struct nlatt
 	if (!pc) {
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
 				     &skbedit_idx_gen, &skbedit_hash_info);
-		if (unlikely(!pc))
-			return -ENOMEM;
+		if (IS_ERR(pc))
+		    return PTR_ERR(pc);
 
 		d = to_skbedit(pc);
 		ret = ACT_P_CREATED;
