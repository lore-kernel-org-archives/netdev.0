From: Thomas Graf <tgraf@suug.ch>
Subject: [RESEND 2/4] cls_rsvp*: Use generic routines for class binding and police config/dump
Date: Sat, 30 Oct 2004 02:01:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030000105.GY12289@postel.suug.ch>
References: <20041029140612.GO12289@postel.suug.ch> <20041029140756.GQ12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041029140756.GQ12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Resend of original patch with a typo fix included.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_rsvp.h	2004-10-29 11:18:17.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_rsvp.h	2004-10-29 11:24:07.000000000 +0200
@@ -272,11 +272,8 @@
 				struct rsvp_filter *f;
 
 				while ((f = s->ht[h2]) != NULL) {
-					unsigned long cl;
-
 					s->ht[h2] = f->next;
-					if ((cl = __cls_set_class(&f->res.class, 0)) != 0)
-						tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+					tcf_unbind_filter(tp, &f->res);
 #ifdef CONFIG_NET_CLS_POLICE
 					tcf_police_release(f->police,TCA_ACT_UNBIND);
 #endif
@@ -299,16 +296,10 @@
 
 	for (fp = &s->ht[(h>>8)&0xFF]; *fp; fp = &(*fp)->next) {
 		if (*fp == f) {
-			unsigned long cl;
-
-
 			tcf_tree_lock(tp);
 			*fp = f->next;
 			tcf_tree_unlock(tp);
-
-			if ((cl = cls_set_class(tp, &f->res.class, 0)) != 0)
-				tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
-
+			tcf_unbind_filter(tp, &f->res);
 #ifdef CONFIG_NET_CLS_POLICE
 			tcf_police_release(f->police,TCA_ACT_UNBIND);
 #endif
@@ -437,22 +428,15 @@
 		if (f->handle != handle && handle)
 			return -EINVAL;
 		if (tb[TCA_RSVP_CLASSID-1]) {
-			unsigned long cl;
-
 			f->res.classid = *(u32*)RTA_DATA(tb[TCA_RSVP_CLASSID-1]);
-			cl = cls_set_class(tp, &f->res.class, tp->q->ops->cl_ops->bind_tcf(tp->q, base, f->res.classid));
-			if (cl)
-				tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
+			tcf_bind_filter(tp, &f->res, base);
 		}
 #ifdef CONFIG_NET_CLS_POLICE
 		if (tb[TCA_RSVP_POLICE-1]) {
-			struct tcf_police *police = tcf_police_locate(tb[TCA_RSVP_POLICE-1], tca[TCA_RATE-1]);
-
-			tcf_tree_lock(tp);
-			police = xchg(&f->police, police);
-			tcf_tree_unlock(tp);
-
-			tcf_police_release(police,TCA_ACT_UNBIND);
+			err = tcf_change_police(tp, &f->police,
+				tb[TCA_RSVP_POLICE-1], tca[TCA_RATE-1]);
+			if (err < 0)
+				return err;
 		}
 #endif
 		return 0;
@@ -531,10 +515,10 @@
 
 			f->sess = s;
 			if (f->tunnelhdr == 0)
-				cls_set_class(tp, &f->res.class, tp->q->ops->cl_ops->bind_tcf(tp->q, base, f->res.classid));
+				tcf_bind_filter(tp, &f->res, base);
 #ifdef CONFIG_NET_CLS_POLICE
 			if (tb[TCA_RSVP_POLICE-1])
-				f->police = tcf_police_locate(tb[TCA_RSVP_POLICE-1], tca[TCA_RATE-1]);
+				tcf_change_police(tp, &f->police, tb[TCA_RSVP_POLICE-1], tca[TCA_RATE-1]);
 #endif
 
 			for (fp = &s->ht[h2]; *fp; fp = &(*fp)->next)
@@ -641,16 +625,8 @@
 	if (((f->handle>>8)&0xFF) != 16)
 		RTA_PUT(skb, TCA_RSVP_SRC, sizeof(f->src), f->src);
 #ifdef CONFIG_NET_CLS_POLICE
-	if (f->police) {
-		struct rtattr * p_rta = (struct rtattr*)skb->tail;
-
-		RTA_PUT(skb, TCA_RSVP_POLICE, 0, NULL);
-
-		if (tcf_police_dump(skb, f->police) < 0)
-			goto rtattr_failure;
-
-		p_rta->rta_len = skb->tail - (u8*)p_rta;
-	}
+	if (tcf_dump_police(skb, f->police, TCA_RSVP_POLICE) < 0)
+		goto rtattr_failure;
 #endif
 
 	rta->rta_len = skb->tail - b;
