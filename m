From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/4] cls_route: Use generic routines for class binding and police config/dump
Date: Fri, 29 Oct 2004 16:06:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029140659.GP12289@postel.suug.ch>
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

--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_route.c	2004-10-29 11:18:17.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_route.c	2004-10-29 10:57:07.000000000 +0200
@@ -292,11 +292,8 @@
 				struct route4_filter *f;
 
 				while ((f = b->ht[h2]) != NULL) {
-					unsigned long cl;
-
 					b->ht[h2] = f->next;
-					if ((cl = __cls_set_class(&f->res.class, 0)) != 0)
-						tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+					tcf_unbind_filter(tp, &f->res);
 #ifdef CONFIG_NET_CLS_POLICE
 					tcf_police_release(f->police,TCA_ACT_UNBIND);
 #endif
@@ -325,17 +322,12 @@
 
 	for (fp = &b->ht[from_hash(h>>16)]; *fp; fp = &(*fp)->next) {
 		if (*fp == f) {
-			unsigned long cl;
-
 			tcf_tree_lock(tp);
 			*fp = f->next;
 			tcf_tree_unlock(tp);
 
 			route4_reset_fastmap(tp->q->dev, head, f->id);
-
-			if ((cl = cls_set_class(tp, &f->res.class, 0)) != 0)
-				tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
-
+			tcf_unbind_filter(tp, &f->res);
 #ifdef CONFIG_NET_CLS_POLICE
 			tcf_police_release(f->police,TCA_ACT_UNBIND);
 #endif
@@ -379,27 +371,18 @@
 		return -EINVAL;
 
 	if ((f = (struct route4_filter*)*arg) != NULL) {
-		/* Node exists: adjust only classid */
-
 		if (f->handle != handle && handle)
 			return -EINVAL;
 		if (tb[TCA_ROUTE4_CLASSID-1]) {
-			unsigned long cl;
-
 			f->res.classid = *(u32*)RTA_DATA(tb[TCA_ROUTE4_CLASSID-1]);
-			cl = cls_set_class(tp, &f->res.class, tp->q->ops->cl_ops->bind_tcf(tp->q, base, f->res.classid));
-			if (cl)
-				tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+			tcf_bind_filter(tp, &f->res, base);
 		}
 #ifdef CONFIG_NET_CLS_POLICE
 		if (tb[TCA_ROUTE4_POLICE-1]) {
-			struct tcf_police *police = tcf_police_locate(tb[TCA_ROUTE4_POLICE-1], tca[TCA_RATE-1]);
-
-			tcf_tree_lock(tp);
-			police = xchg(&f->police, police);
-			tcf_tree_unlock(tp);
-
-			tcf_police_release(police,TCA_ACT_UNBIND);
+			err = tcf_change_police(tp, &f->police,
+				tb[TCA_ROUTE4_POLICE-1], tca[TCA_RATE-1]);
+			if (err < 0)
+				return err;
 		}
 #endif
 		return 0;
@@ -492,10 +475,10 @@
 			goto errout;
 	}
 
-	cls_set_class(tp, &f->res.class, tp->q->ops->cl_ops->bind_tcf(tp->q, base, f->res.classid));
+	tcf_bind_filter(tp, &f->res, base);
 #ifdef CONFIG_NET_CLS_POLICE
 	if (tb[TCA_ROUTE4_POLICE-1])
-		f->police = tcf_police_locate(tb[TCA_ROUTE4_POLICE-1], tca[TCA_RATE-1]);
+		tcf_change_police(tp, &f->police, tb[TCA_ROUTE4_POLICE-1], tca[TCA_RATE-1]);
 #endif
 
 	f->next = f1;
@@ -577,16 +560,8 @@
 	if (f->res.classid)
 		RTA_PUT(skb, TCA_ROUTE4_CLASSID, 4, &f->res.classid);
 #ifdef CONFIG_NET_CLS_POLICE
-	if (f->police) {
-		struct rtattr * p_rta = (struct rtattr*)skb->tail;
-
-		RTA_PUT(skb, TCA_ROUTE4_POLICE, 0, NULL);
-
-		if (tcf_police_dump(skb, f->police) < 0)
-			goto rtattr_failure;
-
-		p_rta->rta_len = skb->tail - (u8*)p_rta;
-	}
+	if (tcf_dump_police(skb, f->police, TCA_ROUTE4_POLICE) < 0)
+		goto rtattr_failure;
 #endif
 
 	rta->rta_len = skb->tail - b;
