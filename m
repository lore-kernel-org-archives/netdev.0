From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/6] cls_fw: Use generic routines to configure action/policer
Date: Fri, 29 Oct 2004 02:24:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029002404.GB12289@postel.suug.ch>
References: <20041029002113.GY12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041029002113.GY12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adds a new function fw_change_attr using the new generic routines which
can be used to change attribute but also to initially set them to avoid
duplicated code.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_fw.c	2004-10-29 00:27:10.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_fw.c	2004-10-29 00:27:19.000000000 +0200
@@ -155,11 +155,8 @@
 
 	for (h=0; h<256; h++) {
 		while ((f=head->ht[h]) != NULL) {
-			unsigned long cl;
 			head->ht[h] = f->next;
-
-			if ((cl = __cls_set_class(&f->res.class, 0)) != 0)
-				tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+			tcf_unbind_filter(tp, &f->res);
 #ifdef CONFIG_NET_CLS_ACT
        if (f->action) {
                tcf_action_destroy(f->action,TCA_ACT_UNBIND);
@@ -187,14 +184,10 @@
 
 	for (fp=&head->ht[fw_hash(f->id)]; *fp; fp = &(*fp)->next) {
 		if (*fp == f) {
-			unsigned long cl;
-
 			tcf_tree_lock(tp);
 			*fp = f->next;
 			tcf_tree_unlock(tp);
-
-			if ((cl = cls_set_class(tp, &f->res.class, 0)) != 0)
-				tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+			tcf_unbind_filter(tp, &f->res);
 #ifdef CONFIG_NET_CLS_ACT
        if (f->action) {
                tcf_action_destroy(f->action,TCA_ACT_UNBIND);
@@ -212,21 +205,67 @@
 	return -EINVAL;
 }
 
+static int
+fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
+	struct rtattr **tb, struct rtattr **tca, unsigned long base)
+{
+	int err = -EINVAL;
+
+	if (tb[TCA_FW_CLASSID-1]) {
+		if (RTA_PAYLOAD(tb[TCA_FW_CLASSID-1]) != sizeof(u32))
+			goto errout;
+		f->res.classid = *(u32*)RTA_DATA(tb[TCA_FW_CLASSID-1]);
+		tcf_bind_filter(tp, &f->res, base);
+	}
+
+#ifdef CONFIG_NET_CLS_ACT
+	if (tb[TCA_FW_POLICE-1]) {
+		err = tcf_change_act_police(tp, &f->action, tb[TCA_FW_POLICE-1],
+			tca[TCA_RATE-1]);
+		if (err < 0)
+			goto errout;
+	}
+
+	if (tb[TCA_FW_ACT-1]) {
+		err = tcf_change_act(tp, &f->action, tb[TCA_FW_ACT-1],
+			tca[TCA_RATE-1]);
+		if (err < 0)
+			goto errout;
+	}
+
+#ifdef CONFIG_NET_CLS_IND
+	if (tb[TCA_FW_INDEV-1]) {
+		err = tcf_change_indev(tp, f->indev, tb[TCA_FW_INDEV-1]);
+		if (err < 0)
+			goto errout;
+	}
+#endif /* CONFIG_NET_CLS_IND */
+#else /* CONFIG_NET_CLS_ACT */
+#ifdef CONFIG_NET_CLS_POLICE
+	if (tb[TCA_FW_POLICE-1]) {
+		err = tcf_change_police(tp, &f->police, tb[TCA_FW_POLICE-1],
+			tca[TCA_RATE-1]);
+		if (err < 0)
+			goto errout;
+	}
+#endif /* CONFIG_NET_CLS_POLICE */
+#endif /* CONFIG_NET_CLS_ACT */
+
+	err = 0;
+errout:
+	return err;
+}
+
 static int fw_change(struct tcf_proto *tp, unsigned long base,
 		     u32 handle,
 		     struct rtattr **tca,
 		     unsigned long *arg)
 {
 	struct fw_head *head = (struct fw_head*)tp->root;
-	struct fw_filter *f;
+	struct fw_filter *f = (struct fw_filter *) *arg;
 	struct rtattr *opt = tca[TCA_OPTIONS-1];
 	struct rtattr *tb[TCA_FW_MAX];
 	int err;
-#ifdef CONFIG_NET_CLS_ACT
-       struct tc_action *act = NULL;
-       int ret;
-#endif
-
 
 	if (!opt)
 		return handle ? -EINVAL : 0;
@@ -234,85 +273,10 @@
 	if (rtattr_parse(tb, TCA_FW_MAX, RTA_DATA(opt), RTA_PAYLOAD(opt)) < 0)
 		return -EINVAL;
 
-	if ((f = (struct fw_filter*)*arg) != NULL) {
-		/* Node exists: adjust only classid */
-
+	if (f != NULL) {
 		if (f->id != handle && handle)
 			return -EINVAL;
-		if (tb[TCA_FW_CLASSID-1]) {
-			unsigned long cl;
-
-			f->res.classid = *(u32*)RTA_DATA(tb[TCA_FW_CLASSID-1]);
-			cl = tp->q->ops->cl_ops->bind_tcf(tp->q, base, f->res.classid);
-			cl = cls_set_class(tp, &f->res.class, cl);
-			if (cl)
-				tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
-		}
-#ifdef CONFIG_NET_CLS_ACT
-		if (tb[TCA_FW_POLICE-1]) {
-			act = kmalloc(sizeof(*act),GFP_KERNEL);
-			if (NULL == act)
-				return -ENOMEM;
-
-			memset(act,0,sizeof(*act));
-			ret = tcf_action_init_1(tb[TCA_FW_POLICE-1], tca[TCA_RATE-1] ,act,"police",TCA_ACT_NOREPLACE,TCA_ACT_BIND);
-			if (0 > ret){
-				tcf_action_destroy(act,TCA_ACT_UNBIND);
-				return ret;
-			}
-			act->type = TCA_OLD_COMPAT;
-
-			sch_tree_lock(tp->q);
-			act = xchg(&f->action, act);
-			sch_tree_unlock(tp->q);
-
-			tcf_action_destroy(act,TCA_ACT_UNBIND);
-
-		}
-
-		if(tb[TCA_FW_ACT-1]) {
-			act = kmalloc(sizeof(*act),GFP_KERNEL);
-			if (NULL == act)
-				return -ENOMEM;
-			memset(act,0,sizeof(*act));
-			ret = tcf_action_init(tb[TCA_FW_ACT-1], tca[TCA_RATE-1],act,NULL, TCA_ACT_NOREPLACE,TCA_ACT_BIND);
-			if (0 > ret) {
-				tcf_action_destroy(act,TCA_ACT_UNBIND);
-				return ret;
-			}
-
-			sch_tree_lock(tp->q);
-			act = xchg(&f->action, act);
-			sch_tree_unlock(tp->q);
-
-			tcf_action_destroy(act,TCA_ACT_UNBIND);
-		}
-#ifdef CONFIG_NET_CLS_IND
-		if(tb[TCA_FW_INDEV-1]) {
-			struct rtattr *idev = tb[TCA_FW_INDEV-1];
-			if (RTA_PAYLOAD(idev) >= IFNAMSIZ) {
-				printk("cls_fw: bad indev name %s\n",(char*)RTA_DATA(idev));
-				err = -EINVAL;
-				goto errout;
-			}
-			memset(f->indev,0,IFNAMSIZ);
-			sprintf(f->indev, "%s", (char*)RTA_DATA(idev));
-		}
-#endif
-#else /* only POLICE defined */
-#ifdef CONFIG_NET_CLS_POLICE
-		if (tb[TCA_FW_POLICE-1]) {
-			struct tcf_police *police = tcf_police_locate(tb[TCA_FW_POLICE-1], tca[TCA_RATE-1]);
-
-			tcf_tree_lock(tp);
-			police = xchg(&f->police, police);
-			tcf_tree_unlock(tp);
-
-			tcf_police_release(police,TCA_ACT_UNBIND);
-		}
-#endif
-#endif
-		return 0;
+		return fw_change_attrs(tp, f, tb, tca, base);
 	}
 
 	if (!handle)
@@ -336,45 +300,9 @@
 
 	f->id = handle;
 
-	if (tb[TCA_FW_CLASSID-1]) {
-		err = -EINVAL;
-		if (RTA_PAYLOAD(tb[TCA_FW_CLASSID-1]) != 4)
-			goto errout;
-		f->res.classid = *(u32*)RTA_DATA(tb[TCA_FW_CLASSID-1]);
-		cls_set_class(tp, &f->res.class, tp->q->ops->cl_ops->bind_tcf(tp->q, base, f->res.classid));
-	}
-
-#ifdef CONFIG_NET_CLS_ACT
-	if(tb[TCA_FW_ACT-1]) {
-		act = kmalloc(sizeof(*act),GFP_KERNEL);
-		if (NULL == act)
-			return -ENOMEM;
-		memset(act,0,sizeof(*act));
-		ret = tcf_action_init(tb[TCA_FW_ACT-1], tca[TCA_RATE-1],act,NULL,TCA_ACT_NOREPLACE,TCA_ACT_BIND);
-		if (0 > ret) {
-			tcf_action_destroy(act,TCA_ACT_UNBIND);
-			return ret;
-		}
-		f->action= act;
-	}
-#ifdef CONFIG_NET_CLS_IND
-		if(tb[TCA_FW_INDEV-1]) {
-			struct rtattr *idev = tb[TCA_FW_INDEV-1];
-			if (RTA_PAYLOAD(idev) >= IFNAMSIZ) {
-				printk("cls_fw: bad indev name %s\n",(char*)RTA_DATA(idev));
-				err = -EINVAL;
-				goto errout;
-			}
-			memset(f->indev,0,IFNAMSIZ);
-			sprintf(f->indev, "%s", (char*)RTA_DATA(idev));
-		}
-#endif
-#else
-#ifdef CONFIG_NET_CLS_POLICE
-	if (tb[TCA_FW_POLICE-1])
-		f->police = tcf_police_locate(tb[TCA_FW_POLICE-1], tca[TCA_RATE-1]);
-#endif
-#endif
+	err = fw_change_attrs(tp, f, tb, tca, base);
+	if (err < 0)
+		goto errout;
 
 	f->next = head->ht[fw_hash(handle)];
 	tcf_tree_lock(tp);
