From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/4] cls_u32: Use generic routines for class binding and police/action config/dump
Date: Fri, 29 Oct 2004 16:09:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029140931.GS12289@postel.suug.ch>
References: <20041029140612.GO12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041029140612.GO12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_u32.c	2004-10-28 22:03:29.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_u32.c	2004-10-29 12:04:11.000000000 +0200
@@ -156,18 +156,9 @@
 
 				*res = n->res;
 #ifdef CONFIG_NET_CLS_IND
-				/* yes, i know it sucks but the feature is 
-				** optional dammit! - JHS */
-				if (0 != n->indev[0]) {
-					if  (NULL == skb->input_dev) {
-						n = n->next;
-						goto next_knode;
-					} else {
-						if (0 != strcmp(n->indev, skb->input_dev->name)) {
-							n = n->next;
-							goto next_knode;
-						}
-					}
+				if (!tcf_match_indev(skb, n->indev)) {
+					n = n->next;
+					goto next_knode;
 				}
 #endif
 #ifdef CONFIG_CLS_U32_PERF
@@ -346,10 +337,7 @@
 
 static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
 {
-	unsigned long cl;
-
-	if ((cl = __cls_set_class(&n->res.class, 0)) != 0)
-		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+	tcf_unbind_filter(tp, &n->res);
 #ifdef CONFIG_NET_CLS_ACT
 	if (n->action) {
 		tcf_action_destroy(n->action, TCA_ACT_UNBIND);
@@ -495,15 +483,11 @@
 	return handle|(i>0xFFF ? 0xFFF : i);
 }
 
-static int u32_set_parms(struct Qdisc *q, unsigned long base,
+static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
 			 struct tc_u_hnode *ht,
 			 struct tc_u_knode *n, struct rtattr **tb,
 			 struct rtattr *est)
 {
-#ifdef CONFIG_NET_CLS_ACT
-	struct tc_action *act = NULL;
-	int ret;
-#endif
 	if (tb[TCA_U32_LINK-1]) {
 		u32 handle = *(u32*)RTA_DATA(tb[TCA_U32_LINK-1]);
 		struct tc_u_hnode *ht_down = NULL;
@@ -519,88 +503,43 @@
 			ht_down->refcnt++;
 		}
 
-		sch_tree_lock(q);
+		tcf_tree_lock(tp);
 		ht_down = xchg(&n->ht_down, ht_down);
-		sch_tree_unlock(q);
+		tcf_tree_unlock(tp);
 
 		if (ht_down)
 			ht_down->refcnt--;
 	}
 	if (tb[TCA_U32_CLASSID-1]) {
-		unsigned long cl;
-
 		n->res.classid = *(u32*)RTA_DATA(tb[TCA_U32_CLASSID-1]);
-		sch_tree_lock(q);
-		cl = __cls_set_class(&n->res.class, q->ops->cl_ops->bind_tcf(q, base, n->res.classid));
-		sch_tree_unlock(q);
-		if (cl)
-			q->ops->cl_ops->unbind_tcf(q, cl);
+		tcf_bind_filter(tp, &n->res, base);
 	}
 #ifdef CONFIG_NET_CLS_ACT
-	/*backward compatibility */
-	if (tb[TCA_U32_POLICE-1])
-	{
-		act = kmalloc(sizeof(*act),GFP_KERNEL);
-		if (NULL == act)
-			return -ENOMEM;
-
-		memset(act,0,sizeof(*act));
-		ret = tcf_action_init_1(tb[TCA_U32_POLICE-1], est,act,"police", TCA_ACT_NOREPLACE, TCA_ACT_BIND);
-		if (0 > ret){
-			tcf_action_destroy(act, TCA_ACT_UNBIND);
-			return ret;
-		}
-		act->type = TCA_OLD_COMPAT;
-
-		sch_tree_lock(q);
-		act = xchg(&n->action, act);
-		sch_tree_unlock(q);
-
-		tcf_action_destroy(act, TCA_ACT_UNBIND);
-
+	if (tb[TCA_U32_POLICE-1]) {
+		int err = tcf_change_act_police(tp, &n->action, tb[TCA_U32_POLICE-1], est);
+		if (err < 0)
+			return err;
 	}
 
-	if(tb[TCA_U32_ACT-1]) {
-		act = kmalloc(sizeof(*act),GFP_KERNEL);
-		if (NULL == act)
-			return -ENOMEM;
-		memset(act,0,sizeof(*act));
-		ret = tcf_action_init(tb[TCA_U32_ACT-1], est,act,NULL,TCA_ACT_NOREPLACE, TCA_ACT_BIND);
-		if (0 > ret) {
-			tcf_action_destroy(act, TCA_ACT_UNBIND);
-			return ret;
-		}
-
-		sch_tree_lock(q);
-		act = xchg(&n->action, act);
-		sch_tree_unlock(q);
-
-		tcf_action_destroy(act, TCA_ACT_UNBIND);
+	if (tb[TCA_U32_ACT-1]) {
+		int err = tcf_change_act(tp, &n->action, tb[TCA_U32_ACT-1], est);
+		if (err < 0)
+			return err;
 	}
-
-
 #else
 #ifdef CONFIG_NET_CLS_POLICE
 	if (tb[TCA_U32_POLICE-1]) {
-		struct tcf_police *police = tcf_police_locate(tb[TCA_U32_POLICE-1], est);
-		sch_tree_lock(q);
-		police = xchg(&n->police, police);
-		sch_tree_unlock(q);
-		tcf_police_release(police, TCA_ACT_UNBIND);
+		int err = tcf_change_police(tp, &n->police, tb[TCA_U32_POLICE-1], est);
+		if (err < 0)
+			return err;
 	}
 #endif
 #endif
 #ifdef CONFIG_NET_CLS_IND
-	n->indev[0] = 0;
-	if(tb[TCA_U32_INDEV-1]) {
-		struct rtattr *input_dev = tb[TCA_U32_INDEV-1];
-		if (RTA_PAYLOAD(input_dev) >= IFNAMSIZ) {
-			printk("cls_u32: bad indev name %s\n",(char*)RTA_DATA(input_dev));
-			/* should we clear state first? */
-			return  -EINVAL;
-		}
-		sprintf(n->indev, "%s", (char*)RTA_DATA(input_dev));
-		printk("got IND %s\n",n->indev);
+	if (tb[TCA_U32_INDEV-1]) {
+		int err = tcf_change_indev(tp, n->indev, tb[TCA_U32_INDEV-1]);
+		if (err < 0)
+			return err;
 	}
 #endif
 
@@ -630,7 +569,7 @@
 		if (TC_U32_KEY(n->handle) == 0)
 			return -EINVAL;
 
-		return u32_set_parms(tp->q, base, n->ht_up, n, tb, tca[TCA_RATE-1]);
+		return u32_set_parms(tp, base, n->ht_up, n, tb, tca[TCA_RATE-1]);
 	}
 
 	if (tb[TCA_U32_DIVISOR-1]) {
@@ -718,7 +657,7 @@
 	}
 	n->fshift = i;
 }
-	err = u32_set_parms(tp->q, base, ht, n, tb, tca[TCA_RATE-1]);
+	err = u32_set_parms(tp, base, ht, n, tb, tca[TCA_RATE-1]);
 	if (err == 0) {
 		struct tc_u_knode **ins;
 		for (ins = &ht->ht[TC_U32_HASH(handle)]; *ins; ins = &(*ins)->next)
@@ -806,49 +745,18 @@
 		if (n->ht_down)
 			RTA_PUT(skb, TCA_U32_LINK, 4, &n->ht_down->handle);
 #ifdef CONFIG_NET_CLS_ACT
-		/* again for backward compatible mode - we want
-		*  to work with both old and new modes of entering
-		*  tc data even if iproute2  was newer - jhs 
-		*/
-		if (n->action) {
-			struct rtattr * p_rta = (struct rtattr*)skb->tail;
-
-			if (n->action->type != TCA_OLD_COMPAT) {
-				RTA_PUT(skb, TCA_U32_ACT, 0, NULL);
-				if (tcf_action_dump(skb,n->action, 0, 0) < 0) {
-					goto rtattr_failure;
-				}
-			} else {
-				RTA_PUT(skb, TCA_U32_POLICE, 0, NULL);
-				if (tcf_action_dump_old(skb,n->action,0,0) < 0) {
-					goto rtattr_failure;
-				}
-			}
-
-			p_rta->rta_len = skb->tail - (u8*)p_rta;
-		}
-
+		if (tcf_dump_act(skb, n->action, TCA_U32_ACT, TCA_U32_POLICE) < 0)
+			goto rtattr_failure;
 #else
 #ifdef CONFIG_NET_CLS_POLICE
-		if (n->police) {
-			struct rtattr * p_rta = (struct rtattr*)skb->tail;
-			RTA_PUT(skb, TCA_U32_POLICE, 0, NULL);
-	 
-			if (tcf_police_dump(skb, n->police) < 0)
-				goto rtattr_failure;
-
-			p_rta->rta_len = skb->tail - (u8*)p_rta;
-
-		}
+		if (tcf_dump_police(skb, n->police, TCA_U32_POLICE) < 0)
+			goto rtattr_failure;
 #endif
 #endif
 
 #ifdef CONFIG_NET_CLS_IND
-		if(strlen(n->indev)) {
-			struct rtattr * p_rta = (struct rtattr*)skb->tail;
+		if(strlen(n->indev))
 			RTA_PUT(skb, TCA_U32_INDEV, IFNAMSIZ, n->indev);
-			p_rta->rta_len = skb->tail - (u8*)p_rta;
-		}
 #endif
 #ifdef CONFIG_CLS_U32_PERF
 		RTA_PUT(skb, TCA_U32_PCNT, 
