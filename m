From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 15/22]: police action: fix multiple bugs in init
 path
Date: Mon, 10 Jan 2005 20:38:08 +0100
Message-ID: <41E2D9A0.3060903@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000505020205030308060704"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000505020205030308060704
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------000505020205030308060704
Content-Type: text/x-patch;
 name="15.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="15.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 02:43:13+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: police action: fix multiple bugs in init path
#   
#   - Return proper error codes
#   - Some attribute sizes are not checked
#   - rta may by NULL
#   - multiple leaks
#   - possible unbalanced unlock
#   - used action is freed after if an error happens while trying to replace
#   - estimator can't be replaced
#   
#   This patch makes replacement atomic, so the old action is either
#   replaced entirely or not touched at all.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/police.c
#   2005/01/10 02:43:06+01:00 kaber@coreworks.de +49 -37
#   [PKT_SCHED]: police action: fix multiple bugs in init path
#   
#   - Return proper error codes
#   - Some attribute sizes are not checked
#   - rta may by NULL
#   - multiple leaks
#   - possible unbalanced unlock
#   - used action is freed after if an error happens while trying to replace
#   - estimator can't be replaced
#   
#   This patch makes replacement atomic, so the old action is either
#   replaced entirely or not touched at all.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/police.c b/net/sched/police.c
--- a/net/sched/police.c	2005-01-10 06:22:48 +01:00
+++ b/net/sched/police.c	2005-01-10 06:22:48 +01:00
@@ -165,20 +165,28 @@
                                  struct tc_action *a, int ovr, int bind)
 {
 	unsigned h;
-	int ret = 0;
+	int ret = 0, err;
 	struct rtattr *tb[TCA_POLICE_MAX];
 	struct tc_police *parm;
 	struct tcf_police *p;
+	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
 
-	if (rtattr_parse(tb, TCA_POLICE_MAX, RTA_DATA(rta),
-	                 RTA_PAYLOAD(rta)) < 0)
-		return -1;
+	if (rta == NULL || rtattr_parse(tb, TCA_POLICE_MAX, RTA_DATA(rta),
+	                                RTA_PAYLOAD(rta)) < 0)
+		return -EINVAL;
 
 	if (tb[TCA_POLICE_TBF-1] == NULL ||
 	    RTA_PAYLOAD(tb[TCA_POLICE_TBF-1]) != sizeof(*parm))
-		return -1;
-
+		return -EINVAL;
 	parm = RTA_DATA(tb[TCA_POLICE_TBF-1]);
+
+	if (tb[TCA_POLICE_RESULT-1] != NULL &&
+	    RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))
+		return -EINVAL;
+	if (tb[TCA_POLICE_RESULT-1] != NULL &&
+	    RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))
+		return -EINVAL;
+
 	if (parm->index && (p = tcf_police_lookup(parm->index)) != NULL) {
 		a->priv = p;
 		spin_lock(&p->lock);
@@ -186,18 +194,18 @@
 			p->bindcnt += 1;
 			p->refcnt += 1;
 		}
+		spin_unlock(&p->lock);
 		if (ovr)
 			goto override;
-		spin_unlock(&p->lock);
 		return ret;
 	}
 
 	p = kmalloc(sizeof(*p), GFP_KERNEL);
 	if (p == NULL)
-		return -1;
+		return -ENOMEM;
 	memset(p, 0, sizeof(*p));
 
-	ret = 1;
+	ret = ACT_P_CREATED;
 	p->refcnt = 1;
 	spin_lock_init(&p->lock);
 	p->stats_lock = &p->lock;
@@ -205,28 +213,32 @@
 		p->bindcnt = 1;
 override:
 	if (parm->rate.rate) {
-		p->R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE-1]);
-		if (p->R_tab == NULL)
+		err = -ENOMEM;
+		R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE-1]);
+		if (R_tab == NULL)
 			goto failure;
 		if (parm->peakrate.rate) {
-			p->P_tab = qdisc_get_rtab(&parm->peakrate,
-					          tb[TCA_POLICE_PEAKRATE-1]);
-			if (p->P_tab == NULL)
+			P_tab = qdisc_get_rtab(&parm->peakrate,
+					       tb[TCA_POLICE_PEAKRATE-1]);
+			if (p->P_tab == NULL) {
+				qdisc_put_rtab(R_tab);
 				goto failure;
+			}
 		}
 	}
-	if (tb[TCA_POLICE_RESULT-1]) {
-		if (RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))
-			goto failure;
-		p->result = *(u32*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
+	/* No failure allowed after this point */
+	spin_lock(&p->lock);
+	if (R_tab != NULL) {
+		qdisc_put_rtab(p->R_tab);
+		p->R_tab = R_tab;
 	}
-#ifdef CONFIG_NET_ESTIMATOR
-	if (tb[TCA_POLICE_AVRATE-1]) {
-		if (RTA_PAYLOAD(tb[TCA_POLICE_AVRATE-1]) != sizeof(u32))
-			goto failure;
-		p->ewma_rate = *(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
+	if (P_tab != NULL) {
+		qdisc_put_rtab(p->P_tab);
+		p->P_tab = P_tab;
 	}
-#endif
+
+	if (tb[TCA_POLICE_RESULT-1])
+		p->result = *(u32*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
 	p->toks = p->burst = parm->burst;
 	p->mtu = parm->mtu;
 	if (p->mtu == 0) {
@@ -238,16 +250,19 @@
 		p->ptoks = L2T_P(p, p->mtu);
 	p->action = parm->action;
 
-	if (ovr) {
-		spin_unlock(&p->lock);
-		return ret;
-	}
-	PSCHED_GET_TIME(p->t_c);
-	p->index = parm->index ? : tcf_police_new_index();
 #ifdef CONFIG_NET_ESTIMATOR
+	if (tb[TCA_POLICE_AVRATE-1])
+		p->ewma_rate = *(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
 	if (est)
-		gen_new_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
+		gen_replace_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
 #endif
+
+	spin_unlock(&p->lock);
+	if (ret != ACT_P_CREATED)
+		return ret;
+
+	PSCHED_GET_TIME(p->t_c);
+	p->index = parm->index ? : tcf_police_new_index();
 	h = tcf_police_hash(p->index);
 	write_lock_bh(&police_lock);
 	p->next = tcf_police_ht[h];
@@ -258,12 +273,9 @@
 	return ret;
 
 failure:
-	if (p->R_tab)
-		qdisc_put_rtab(p->R_tab);
-	if (ovr)
-		spin_unlock(&p->lock);
-	kfree(p);
-	return -1;
+	if (ret == ACT_P_CREATED)
+		kfree(p);
+	return err;
 }
 
 static int tcf_act_police_cleanup(struct tc_action *a, int bind)

--------------000505020205030308060704--
