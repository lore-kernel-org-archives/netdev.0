From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 11/22]: gact action: fix multiple bugs in init path
Date: Mon, 10 Jan 2005 20:38:01 +0100
Message-ID: <41E2D999.2080107@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010700010109080507030301"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010700010109080507030301
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------010700010109080507030301
Content-Type: text/x-patch;
 name="11.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="11.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 02:06:29+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: gact action: fix multiple bugs in init path
#   
#   - rta can be NULL
#   - Attribute sizes are not checked
#   - No locking when replacing an action
#   - The action is inserted into the hash before its parameters are set
#   
#   Also return proper error codes.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
#    
# 
# net/sched/gact.c
#   2005/01/10 02:06:22+01:00 kaber@coreworks.de +34 -32
#   [PKT_SCHED]: gact action: fix multiple bugs in init path
#   
#   - rta can be NULL
#   - Attribute sizes are not checked
#   - No locking when replacing an action
#   - The action is inserted into the hash before its parameters are set
#   
#   Also return proper error codes.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
#    
# 
# include/net/pkt_act.h
#   2005/01/10 02:06:22+01:00 kaber@coreworks.de +10 -17
#   [PKT_SCHED]: gact action: fix multiple bugs in init path
#   
#   - rta can be NULL
#   - Attribute sizes are not checked
#   - No locking when replacing an action
#   - The action is inserted into the hash before its parameters are set
#   
#   Also return proper error codes.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
#    
# 
diff -Nru a/include/net/pkt_act.h b/include/net/pkt_act.h
--- a/include/net/pkt_act.h	2005-01-10 06:22:29 +01:00
+++ b/include/net/pkt_act.h	2005-01-10 06:22:29 +01:00
@@ -218,10 +218,10 @@
 
 #ifdef CONFIG_NET_ACT_INIT
 static inline struct tcf_st *
-tcf_hash_check(struct tc_st *parm, struct tc_action *a, int ovr, int bind)
+tcf_hash_check(u32 index, struct tc_action *a, int ovr, int bind)
 {
 	struct tcf_st *p = NULL;
-	if (parm->index && (p = tcf_hash_lookup(parm->index)) != NULL) {
+	if (index && (p = tcf_hash_lookup(index)) != NULL) {
 		spin_lock(&p->lock);
 		if (bind) {
 			p->bindcnt++;
@@ -234,9 +234,8 @@
 }
 
 static inline struct tcf_st *
-tcf_hash_create(struct tc_st *parm, struct rtattr *est, struct tc_action *a, int size, int ovr, int bind)
+tcf_hash_create(u32 index, struct rtattr *est, struct tc_action *a, int size, int ovr, int bind)
 {
-	unsigned h;
 	struct tcf_st *p = NULL;
 
 	p = kmalloc(size, GFP_KERNEL);
@@ -252,31 +251,25 @@
 
 	spin_lock_init(&p->lock);
 	p->stats_lock = &p->lock;
-	p->index = parm->index ? : tcf_hash_new_index();
+	p->index = index ? : tcf_hash_new_index();
 	p->tm.install = jiffies;
 	p->tm.lastuse = jiffies;
 #ifdef CONFIG_NET_ESTIMATOR
 	if (est)
 		gen_new_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
 #endif
-	h = tcf_hash(p->index);
-	write_lock_bh(&tcf_t_lock);
-	p->next = tcf_ht[h];
-	tcf_ht[h] = p;
-	write_unlock_bh(&tcf_t_lock);
-
 	a->priv = (void *) p;
 	return p;
 }
 
-static inline struct tcf_st *
-tcf_hash_init(struct tc_st *parm, struct rtattr *est, struct tc_action *a, int size, int ovr, int bind)
+static inline void tcf_hash_insert(struct tcf_st *p)
 {
-	struct tcf_st *p = tcf_hash_check (parm,a,ovr,bind);
+	unsigned h = tcf_hash(p->index);
 
-	if (!p)
-		p = tcf_hash_create(parm, est, a, size, ovr, bind);
-	return p;
+	write_lock_bh(&tcf_t_lock);
+	p->next = tcf_ht[h];
+	tcf_ht[h] = p;
+	write_unlock_bh(&tcf_t_lock);
 }
 
 #endif
diff -Nru a/net/sched/gact.c b/net/sched/gact.c
--- a/net/sched/gact.c	2005-01-10 06:22:29 +01:00
+++ b/net/sched/gact.c	2005-01-10 06:22:29 +01:00
@@ -75,51 +75,53 @@
                          struct tc_action *a, int ovr, int bind)
 {
 	struct rtattr *tb[TCA_GACT_MAX];
-	struct tc_gact *parm = NULL;
-#ifdef CONFIG_GACT_PROB
-	struct tc_gact_p *p_parm = NULL;
-#endif
-	struct tcf_gact *p = NULL;
+	struct tc_gact *parm;
+	struct tcf_gact *p;
 	int ret = 0;
 
-	if (rtattr_parse(tb, TCA_GACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
-		return -1;
-
-	if (tb[TCA_GACT_PARMS - 1] == NULL) {
-		printk("BUG: tcf_gact_init called with NULL params\n");
-		return -1;
-	}
+	if (rta == NULL ||
+	    rtattr_parse(tb, TCA_GACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
+		return -EINVAL;
 
+	if (tb[TCA_GACT_PARMS - 1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_GACT_PARMS - 1]) < sizeof(*parm))
+		return -EINVAL;
 	parm = RTA_DATA(tb[TCA_GACT_PARMS - 1]);
+
+	if (tb[TCA_GACT_PROB-1] != NULL)
 #ifdef CONFIG_GACT_PROB
-	if (tb[TCA_GACT_PROB - 1] != NULL)
-		p_parm = RTA_DATA(tb[TCA_GACT_PROB - 1]);
+		if (RTA_PAYLOAD(tb[TCA_GACT_PROB-1]) < sizeof(struct tc_gact_p))
+			return -EINVAL;
+#else
+		return -EOPNOTSUPP;
 #endif
-	p = tcf_hash_check(parm, a, ovr, bind);
+
+	p = tcf_hash_check(parm->index, a, ovr, bind);
 	if (p == NULL) {
-		p = tcf_hash_create(parm, est, a, sizeof(*p), ovr, bind);
+		p = tcf_hash_create(parm->index, est, a, sizeof(*p), ovr, bind);
 		if (p == NULL)
-			return -1;
-		else {
-			p->refcnt = 1;
-			ret = 1;
-			goto override;
+			return -ENOMEM;
+		ret = ACT_P_CREATED;
+	} else {
+		if (!ovr) {
+			tcf_hash_release(p, bind);
+			return -EEXIST;
 		}
 	}
 
-	if (ovr) {
-override:
-		p->action = parm->action;
+	spin_lock_bh(&p->lock);
+	p->action = parm->action;
 #ifdef CONFIG_GACT_PROB
-		if (p_parm != NULL) {
-			p->paction = p_parm->paction;
-			p->pval = p_parm->pval;
-			p->ptype = p_parm->ptype;
-		} else {
-			p->paction = p->pval = p->ptype = 0;
-		}
-#endif
+	if (tb[TCA_GACT_PROB-1] != NULL) {
+		struct tc_gact_p *p_parm = RTA_DATA(tb[TCA_GACT_PROB-1]);
+		p->paction = p_parm->paction;
+		p->pval    = p_parm->pval;
+		p->ptype   = p_parm->ptype;
 	}
+#endif
+	spin_unlock_bh(&p->lock);
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(p);
 	return ret;
 }
 

--------------010700010109080507030301--
