From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/4] cls_tcindex: Use generic routines for class binding and police config/dump
Date: Fri, 29 Oct 2004 16:08:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029140856.GR12289@postel.suug.ch>
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

--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_tcindex.c	2004-10-28 22:03:29.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_tcindex.c	2004-10-29 11:43:29.000000000 +0200
@@ -165,7 +165,6 @@
 	struct tcindex_data *p = PRIV(tp);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) arg;
 	struct tcindex_filter *f = NULL;
-	unsigned long cl;
 
 	DPRINTK("tcindex_delete(tp %p,arg 0x%lx),p %p,f %p\n",tp,arg,p,f);
 	if (p->perfect) {
@@ -187,9 +186,7 @@
 		*walk = f->next;
 		tcf_tree_unlock(tp);
 	}
-	cl = __cls_set_class(&r->res.class,0);
-	if (cl)
-		tp->q->ops->cl_ops->unbind_tcf(tp->q,cl);
+	tcf_unbind_filter(tp, &r->res);
 #ifdef CONFIG_NET_CLS_POLICE
 	tcf_police_release(r->police, TCA_ACT_UNBIND);
 #endif
@@ -313,28 +310,19 @@
 	}
 	DPRINTK("r=%p\n",r);
 	if (tb[TCA_TCINDEX_CLASSID-1]) {
-		unsigned long cl = cls_set_class(tp,&r->res.class,0);
-
-		if (cl)
-			tp->q->ops->cl_ops->unbind_tcf(tp->q,cl);
 		r->res.classid = *(__u32 *) RTA_DATA(tb[TCA_TCINDEX_CLASSID-1]);
-		r->res.class = tp->q->ops->cl_ops->bind_tcf(tp->q,base,
-							    r->res.classid);
+		tcf_bind_filter(tp, &r->res, base);
+
 		if (!r->res.class) {
 			r->res.classid = 0;
 			return -ENOENT;
 		}
-        }
+	}
 #ifdef CONFIG_NET_CLS_POLICE
-	{
-		struct tcf_police *police;
-
-		police = tb[TCA_TCINDEX_POLICE-1] ?
-		    tcf_police_locate(tb[TCA_TCINDEX_POLICE-1],NULL) : NULL;
-		tcf_tree_lock(tp);
-		police = xchg(&r->police,police);
-		tcf_tree_unlock(tp);
-		tcf_police_release(police,TCA_ACT_UNBIND);
+	if (tb[TCA_TCINDEX_POLICE-1]) {
+		int err = tcf_change_police(tp, &r->police, tb[TCA_TCINDEX_POLICE-1], NULL);
+		if (err < 0)
+			return err;
 	}
 #endif
 	if (r != &new_filter_result)
@@ -459,14 +447,8 @@
 		if (r->res.class)
 			RTA_PUT(skb, TCA_TCINDEX_CLASSID, 4, &r->res.classid);
 #ifdef CONFIG_NET_CLS_POLICE
-		if (r->police) {
-			struct rtattr *p_rta = (struct rtattr *) skb->tail;
-
-			RTA_PUT(skb,TCA_TCINDEX_POLICE,0,NULL);
-			if (tcf_police_dump(skb,r->police) < 0)
-				goto rtattr_failure;
-			p_rta->rta_len = skb->tail-(u8 *) p_rta;
-		}
+		if (tcf_dump_police(skb, r->police, TCA_TCINDEX_POLICE) < 0)
+			goto rtattr_failure;
 #endif
 	}
 	rta->rta_len = skb->tail-b;
