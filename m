From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_gred: prefer GFP_KERNEL allocations
Date: Fri, 16 Dec 2011 09:09:45 +0100
Message-ID: <1324022985.2562.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33802 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174Ab1LPIJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 03:09:49 -0500
Received: by wgbdr13 with SMTP id dr13so5741073wgb.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 00:09:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In control path, its better to use GFP_KERNEL allocations where
possible.

Before taking qdisc spinlock, we preallocate memory just in case we'll
need it in gred_change_vq()

This is a followup to commit 3f1e6d3fd37b (sch_gred: should not use
GFP_KERNEL while holding a spinlock)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_gred.c |   18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 1b5e631..c9391ab 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -380,18 +380,19 @@ static inline int gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
 
 static inline int gred_change_vq(struct Qdisc *sch, int dp,
 				 struct tc_gred_qopt *ctl, int prio,
-				 u8 *stab, u32 max_P)
+				 u8 *stab, u32 max_P,
+				 struct gred_sched_data **prealloc)
 {
 	struct gred_sched *table = qdisc_priv(sch);
-	struct gred_sched_data *q;
+	struct gred_sched_data *q = table->tab[dp];
 
-	if (table->tab[dp] == NULL) {
-		table->tab[dp] = kzalloc(sizeof(*q), GFP_ATOMIC);
-		if (table->tab[dp] == NULL)
+	if (!q) {
+		table->tab[dp] = q = *prealloc;
+		*prealloc = NULL;
+		if (!q)
 			return -ENOMEM;
 	}
 
-	q = table->tab[dp];
 	q->DP = dp;
 	q->prio = prio;
 	q->limit = ctl->limit;
@@ -421,6 +422,7 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 	int err, prio = GRED_DEF_PRIO;
 	u8 *stab;
 	u32 max_P;
+	struct gred_sched_data *prealloc;
 
 	if (opt == NULL)
 		return -EINVAL;
@@ -460,9 +462,10 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 			prio = ctl->prio;
 	}
 
+	prealloc = kzalloc(sizeof(*prealloc), GFP_KERNEL);
 	sch_tree_lock(sch);
 
-	err = gred_change_vq(sch, ctl->DP, ctl, prio, stab, max_P);
+	err = gred_change_vq(sch, ctl->DP, ctl, prio, stab, max_P, &prealloc);
 	if (err < 0)
 		goto errout_locked;
 
@@ -476,6 +479,7 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 
 errout_locked:
 	sch_tree_unlock(sch);
+	kfree(prealloc);
 errout:
 	return err;
 }
