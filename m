From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/9] PKT_SCHED: u32: make use of tcf_exts API
Date: Thu, 30 Dec 2004 13:31:08 +0100
Message-ID: <20041230123108.GP32419@postel.suug.ch>
References: <20041230122652.GM32419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041230122652.GM32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Transforms u32 to use tcf_exts API. Makes the u32 changing
procedure consistent upon failures except for indev failures but
indev will be removed very soon.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-bk2.orig/net/sched/cls_u32.c	2004-12-29 20:16:24.000000000 +0100
+++ linux-2.6.10-bk2/net/sched/cls_u32.c	2004-12-29 20:19:49.000000000 +0100
@@ -61,9 +61,9 @@
 
 struct tc_u32_mark
 {
-	__u32		val;
-	__u32		mask;
-	__u32		success;
+	u32		val;
+	u32		mask;
+	u32		success;
 };
 
 struct tc_u_knode
@@ -71,13 +71,7 @@
 	struct tc_u_knode	*next;
 	u32			handle;
 	struct tc_u_hnode	*ht_up;
-#ifdef CONFIG_NET_CLS_ACT
-	struct tc_action	*action;
-#else
-#ifdef CONFIG_NET_CLS_POLICE
-	struct tcf_police	*police;
-#endif
-#endif
+	struct tcf_exts		exts;
 #ifdef CONFIG_NET_CLS_IND
 	char                     indev[IFNAMSIZ];
 #endif
@@ -112,6 +106,11 @@
 	u32			hgenerator;
 };
 
+static struct tcf_ext_map u32_ext_map = {
+	.action = TCA_U32_ACT,
+	.police = TCA_U32_POLICE
+};
+
 static struct tc_u_common *u32_list;
 
 static __inline__ unsigned u32_hash_fold(u32 key, struct tc_u32_sel *sel, u8 fshift)
@@ -137,7 +136,7 @@
 #ifdef CONFIG_CLS_U32_PERF
 	int j;
 #endif
-	int i;
+	int i, r;
 
 next_ht:
 	n = ht->ht[sel];
@@ -185,22 +184,13 @@
 #ifdef CONFIG_CLS_U32_PERF
 				n->pf->rhit +=1;
 #endif
-#ifdef CONFIG_NET_CLS_ACT
-				if (n->action) {
-					int pol_res = tcf_action_exec(skb, n->action, res);
-					if (pol_res >= 0)
-						return pol_res;
-				} else
-#else
-#ifdef CONFIG_NET_CLS_POLICE
-				if (n->police) {
-					int pol_res = tcf_police(skb, n->police);
-					if (pol_res >= 0)
-						return pol_res;
-				} else
-#endif
-#endif
-					return 0;
+				r = tcf_exts_exec(skb, &n->exts, res);
+				if (r < 0) {
+					n = n->next;
+					goto next_knode;
+				}
+
+				return r;
 			}
 			n = n->next;
 			goto next_knode;
@@ -359,15 +349,7 @@
 static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
 {
 	tcf_unbind_filter(tp, &n->res);
-#ifdef CONFIG_NET_CLS_ACT
-	if (n->action) {
-		tcf_action_destroy(n->action, TCA_ACT_UNBIND);
-	}
-#else
-#ifdef CONFIG_NET_CLS_POLICE
-	tcf_police_release(n->police, TCA_ACT_UNBIND);
-#endif
-#endif
+	tcf_exts_destroy(tp, &n->exts);
 	if (n->ht_down)
 		n->ht_down->refcnt--;
 #ifdef CONFIG_CLS_U32_PERF
@@ -509,18 +491,26 @@
 			 struct tc_u_knode *n, struct rtattr **tb,
 			 struct rtattr *est)
 {
+	int err;
+	struct tcf_exts e;
+
+	err = tcf_exts_validate(tp, tb, est, &e, &u32_ext_map);
+	if (err < 0)
+		return err;
+
+	err = -EINVAL;
 	if (tb[TCA_U32_LINK-1]) {
 		u32 handle = *(u32*)RTA_DATA(tb[TCA_U32_LINK-1]);
 		struct tc_u_hnode *ht_down = NULL;
 
 		if (TC_U32_KEY(handle))
-			return -EINVAL;
+			goto errout;
 
 		if (handle) {
 			ht_down = u32_lookup_ht(ht->tp_c, handle);
 
 			if (ht_down == NULL)
-				return -EINVAL;
+				goto errout;
 			ht_down->refcnt++;
 		}
 
@@ -535,36 +525,20 @@
 		n->res.classid = *(u32*)RTA_DATA(tb[TCA_U32_CLASSID-1]);
 		tcf_bind_filter(tp, &n->res, base);
 	}
-#ifdef CONFIG_NET_CLS_ACT
-	if (tb[TCA_U32_POLICE-1]) {
-		int err = tcf_change_act_police(tp, &n->action, tb[TCA_U32_POLICE-1], est);
-		if (err < 0)
-			return err;
-	}
 
-	if (tb[TCA_U32_ACT-1]) {
-		int err = tcf_change_act(tp, &n->action, tb[TCA_U32_ACT-1], est);
-		if (err < 0)
-			return err;
-	}
-#else
-#ifdef CONFIG_NET_CLS_POLICE
-	if (tb[TCA_U32_POLICE-1]) {
-		int err = tcf_change_police(tp, &n->police, tb[TCA_U32_POLICE-1], est);
-		if (err < 0)
-			return err;
-	}
-#endif
-#endif
 #ifdef CONFIG_NET_CLS_IND
 	if (tb[TCA_U32_INDEV-1]) {
 		int err = tcf_change_indev(tp, n->indev, tb[TCA_U32_INDEV-1]);
 		if (err < 0)
-			return err;
+			goto errout;
 	}
 #endif
+	tcf_exts_change(tp, &n->exts, &e);
 
 	return 0;
+errout:
+	tcf_exts_destroy(tp, &e);
+	return err;
 }
 
 static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
@@ -584,7 +558,7 @@
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	if (rtattr_parse(tb, TCA_U32_MAX, RTA_DATA(opt), RTA_PAYLOAD(opt)) < 0)
+	if (rtattr_parse_nested(tb, TCA_U32_MAX, opt) < 0)
 		return -EINVAL;
 
 	if ((n = (struct tc_u_knode*)*arg) != NULL) {
@@ -657,12 +631,12 @@
 
 	memset(n, 0, sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key));
 #ifdef CONFIG_CLS_U32_PERF
-	n->pf = kmalloc(sizeof(struct tc_u32_pcnt) + s->nkeys*sizeof(__u64), GFP_KERNEL);
+	n->pf = kmalloc(sizeof(struct tc_u32_pcnt) + s->nkeys*sizeof(u64), GFP_KERNEL);
 	if (n->pf == NULL) {
 		kfree(n);
 		return -ENOBUFS;
 	}
-	memset(n->pf, 0, sizeof(struct tc_u32_pcnt) + s->nkeys*sizeof(__u64));
+	memset(n->pf, 0, sizeof(struct tc_u32_pcnt) + s->nkeys*sizeof(u64));
 #endif
 
 	memcpy(&n->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
@@ -783,15 +757,8 @@
 			RTA_PUT(skb, TCA_U32_MARK, sizeof(n->mark), &n->mark);
 #endif
 
-#ifdef CONFIG_NET_CLS_ACT
-		if (tcf_dump_act(skb, n->action, TCA_U32_ACT, TCA_U32_POLICE) < 0)
-			goto rtattr_failure;
-#else
-#ifdef CONFIG_NET_CLS_POLICE
-		if (tcf_dump_police(skb, n->police, TCA_U32_POLICE) < 0)
+		if (tcf_exts_dump(skb, &n->exts, &u32_ext_map) < 0)
 			goto rtattr_failure;
-#endif
-#endif
 
 #ifdef CONFIG_NET_CLS_IND
 		if(strlen(n->indev))
@@ -799,26 +766,15 @@
 #endif
 #ifdef CONFIG_CLS_U32_PERF
 		RTA_PUT(skb, TCA_U32_PCNT, 
-		sizeof(struct tc_u32_pcnt) + n->sel.nkeys*sizeof(__u64),
+		sizeof(struct tc_u32_pcnt) + n->sel.nkeys*sizeof(u64),
 			n->pf);
 #endif
 	}
 
 	rta->rta_len = skb->tail - b;
-#ifdef CONFIG_NET_CLS_ACT
-	if (TC_U32_KEY(n->handle) != 0) {
-		if (TC_U32_KEY(n->handle) && n->action && n->action->type == TCA_OLD_COMPAT) {
-			if (tcf_action_copy_stats(skb,n->action))
-				goto rtattr_failure;
-		}
-	}
-#else
-#ifdef CONFIG_NET_CLS_POLICE
-	if (TC_U32_KEY(n->handle) && n->police)
-		if (tcf_police_dump_stats(skb, n->police) < 0)
+	if (TC_U32_KEY(n->handle))
+		if (tcf_exts_dump_stats(skb, &n->exts, &u32_ext_map) < 0)
 			goto rtattr_failure;
-#endif
-#endif
 	return skb->len;
 
 rtattr_failure:
