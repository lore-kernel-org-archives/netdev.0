From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/9] PKT_SCHED: fw: make use of tcf_exts API
Date: Thu, 30 Dec 2004 13:32:16 +0100
Message-ID: <20041230123216.GQ32419@postel.suug.ch>
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

Transforms fw to use tcf_exts API. Makes the fw changing
procedure consistent upon failures except for indev failures but
indev will be removed very soon.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-bk2.orig/net/sched/cls_fw.c	2004-12-29 20:16:24.000000000 +0100
+++ linux-2.6.10-bk2/net/sched/cls_fw.c	2004-12-29 20:20:26.000000000 +0100
@@ -59,13 +59,12 @@
 #ifdef CONFIG_NET_CLS_IND
 	char			indev[IFNAMSIZ];
 #endif /* CONFIG_NET_CLS_IND */
-#ifdef CONFIG_NET_CLS_ACT
-	struct tc_action        *action;
-#else /* CONFIG_NET_CLS_ACT */
-#ifdef CONFIG_NET_CLS_POLICE
-	struct tcf_police	*police;
-#endif /* CONFIG_NET_CLS_POLICE */
-#endif /* CONFIG_NET_CLS_ACT */
+	struct tcf_exts		exts;
+};
+
+static struct tcf_ext_map fw_ext_map = {
+	.action = TCA_FW_ACT,
+	.police = TCA_FW_POLICE
 };
 
 static __inline__ int fw_hash(u32 handle)
@@ -78,6 +77,7 @@
 {
 	struct fw_head *head = (struct fw_head*)tp->root;
 	struct fw_filter *f;
+	int r;
 #ifdef CONFIG_NETFILTER
 	u32 id = skb->nfmark;
 #else
@@ -92,20 +92,11 @@
 				if (!tcf_match_indev(skb, f->indev))
 					continue;
 #endif /* CONFIG_NET_CLS_IND */
-#ifdef CONFIG_NET_CLS_ACT
-				if (f->action) {
-					int act_res = tcf_action_exec(skb, f->action, res);
-					if (act_res >= 0)
-						return act_res;
+				r = tcf_exts_exec(skb, &f->exts, res);
+				if (r < 0)
 					continue;
-				}
-#else /* CONFIG_NET_CLS_ACT */
-#ifdef CONFIG_NET_CLS_POLICE
-				if (f->police)
-					return tcf_police(skb, f->police);
-#endif /* CONFIG_NET_CLS_POLICE */
-#endif /* CONFIG_NET_CLS_ACT */
-				return 0;
+
+				return r;
 			}
 		}
 	} else {
@@ -144,6 +135,14 @@
 	return 0;
 }
 
+static inline void
+fw_delete_filter(struct tcf_proto *tp, struct fw_filter *f)
+{
+	tcf_unbind_filter(tp, &f->res);
+	tcf_exts_destroy(tp, &f->exts);
+	kfree(f);
+}
+
 static void fw_destroy(struct tcf_proto *tp)
 {
 	struct fw_head *head = (struct fw_head*)xchg(&tp->root, NULL);
@@ -156,18 +155,7 @@
 	for (h=0; h<256; h++) {
 		while ((f=head->ht[h]) != NULL) {
 			head->ht[h] = f->next;
-			tcf_unbind_filter(tp, &f->res);
-#ifdef CONFIG_NET_CLS_ACT
-			if (f->action)
-				tcf_action_destroy(f->action, TCA_ACT_UNBIND);
-#else /* CONFIG_NET_CLS_ACT */
-#ifdef CONFIG_NET_CLS_POLICE
-			if (f->police)
-				tcf_police_release(f->police, TCA_ACT_UNBIND);
-#endif /* CONFIG_NET_CLS_POLICE */
-#endif /* CONFIG_NET_CLS_ACT */
-
-			kfree(f);
+			fw_delete_filter(tp, f);
 		}
 	}
 	kfree(head);
@@ -187,16 +175,7 @@
 			tcf_tree_lock(tp);
 			*fp = f->next;
 			tcf_tree_unlock(tp);
-			tcf_unbind_filter(tp, &f->res);
-#ifdef CONFIG_NET_CLS_ACT
-			if (f->action)
-				tcf_action_destroy(f->action,TCA_ACT_UNBIND);
-#else /* CONFIG_NET_CLS_ACT */
-#ifdef CONFIG_NET_CLS_POLICE
-			tcf_police_release(f->police,TCA_ACT_UNBIND);
-#endif /* CONFIG_NET_CLS_POLICE */
-#endif /* CONFIG_NET_CLS_ACT */
-			kfree(f);
+			fw_delete_filter(tp, f);
 			return 0;
 		}
 	}
@@ -208,8 +187,14 @@
 fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
 	struct rtattr **tb, struct rtattr **tca, unsigned long base)
 {
-	int err = -EINVAL;
+	struct tcf_exts e;
+	int err;
 
+	err = tcf_exts_validate(tp, tb, tca[TCA_RATE-1], &e, &fw_ext_map);
+	if (err < 0)
+		return err;
+
+	err = -EINVAL;
 	if (tb[TCA_FW_CLASSID-1]) {
 		if (RTA_PAYLOAD(tb[TCA_FW_CLASSID-1]) != sizeof(u32))
 			goto errout;
@@ -225,33 +210,11 @@
 	}
 #endif /* CONFIG_NET_CLS_IND */
 
-#ifdef CONFIG_NET_CLS_ACT
-	if (tb[TCA_FW_POLICE-1]) {
-		err = tcf_change_act_police(tp, &f->action, tb[TCA_FW_POLICE-1],
-			tca[TCA_RATE-1]);
-		if (err < 0)
-			goto errout;
-	}
-
-	if (tb[TCA_FW_ACT-1]) {
-		err = tcf_change_act(tp, &f->action, tb[TCA_FW_ACT-1],
-			tca[TCA_RATE-1]);
-		if (err < 0)
-			goto errout;
-	}
-#else /* CONFIG_NET_CLS_ACT */
-#ifdef CONFIG_NET_CLS_POLICE
-	if (tb[TCA_FW_POLICE-1]) {
-		err = tcf_change_police(tp, &f->police, tb[TCA_FW_POLICE-1],
-			tca[TCA_RATE-1]);
-		if (err < 0)
-			goto errout;
-	}
-#endif /* CONFIG_NET_CLS_POLICE */
-#endif /* CONFIG_NET_CLS_ACT */
+	tcf_exts_change(tp, &f->exts, &e);
 
-	err = 0;
+	return 0;
 errout:
+	tcf_exts_destroy(tp, &e);
 	return err;
 }
 
@@ -269,7 +232,7 @@
 	if (!opt)
 		return handle ? -EINVAL : 0;
 
-	if (rtattr_parse(tb, TCA_FW_MAX, RTA_DATA(opt), RTA_PAYLOAD(opt)) < 0)
+	if (rtattr_parse_nested(tb, TCA_FW_MAX, opt) < 0)
 		return -EINVAL;
 
 	if (f != NULL) {
@@ -357,15 +320,7 @@
 
 	t->tcm_handle = f->id;
 
-	if (!f->res.classid
-#ifdef CONFIG_NET_CLS_ACT
-		&& !f->action
-#else
-#ifdef CONFIG_NET_CLS_POLICE
-		&& !f->police
-#endif
-#endif
-		)
+	if (!f->res.classid && !tcf_exts_is_available(&f->exts))
 		return skb->len;
 
 	rta = (struct rtattr*)b;
@@ -377,29 +332,15 @@
 	if (strlen(f->indev))
 		RTA_PUT(skb, TCA_FW_INDEV, IFNAMSIZ, f->indev);
 #endif /* CONFIG_NET_CLS_IND */
-#ifdef CONFIG_NET_CLS_ACT
-	if (tcf_dump_act(skb, f->action, TCA_FW_ACT, TCA_FW_POLICE) < 0)
-		goto rtattr_failure;
-#else /* CONFIG_NET_CLS_ACT */
-#ifdef CONFIG_NET_CLS_POLICE
-	if (tcf_dump_police(skb, f->police, TCA_FW_POLICE) < 0)
+
+	if (tcf_exts_dump(skb, &f->exts, &fw_ext_map) < 0)
 		goto rtattr_failure;
-#endif /* CONFIG_NET_CLS_POLICE */
-#endif /* CONFIG_NET_CLS_ACT */
 
 	rta->rta_len = skb->tail - b;
-#ifdef CONFIG_NET_CLS_ACT
-	if (f->action && f->action->type == TCA_OLD_COMPAT) {
-		if (tcf_action_copy_stats(skb,f->action))
-			goto rtattr_failure;
-	}
-#else /* CONFIG_NET_CLS_ACT */
-#ifdef CONFIG_NET_CLS_POLICE
-	if (f->police)
-		if (tcf_police_dump_stats(skb, f->police) < 0)
-			goto rtattr_failure;
-#endif /* CONFIG_NET_CLS_POLICE */
-#endif /* CONFIG_NET_CLS_ACT */
+
+	if (tcf_exts_dump_stats(skb, &f->exts, &fw_ext_map) < 0)
+		goto rtattr_failure;
+
 	return skb->len;
 
 rtattr_failure:
