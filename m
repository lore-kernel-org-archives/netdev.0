From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/9] PKT_SCHED: rsvp: use tcf_exts API
Date: Thu, 30 Dec 2004 13:34:58 +0100
Message-ID: <20041230123458.GT32419@postel.suug.ch>
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

Transforms tcindex to use tcf_exts API and thus adds support for
actions. Needs more work to allow changing parameters for
existing filters.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-bk1.orig/include/linux/pkt_cls.h	2004-12-27 22:38:14.000000000 +0100
+++ linux-2.6.10-bk1/include/linux/pkt_cls.h	2004-12-27 22:39:29.000000000 +0100
@@ -249,6 +249,7 @@
 	TCA_RSVP_SRC,
 	TCA_RSVP_PINFO,
 	TCA_RSVP_POLICE,
+	TCA_RSVP_ACT,
 	__TCA_RSVP_MAX
 };
 
--- linux-2.6.10-bk2.orig/net/sched/cls_rsvp.h	2004-12-29 20:16:24.000000000 +0100
+++ linux-2.6.10-bk2/net/sched/cls_rsvp.h	2004-12-29 20:24:09.000000000 +0100
@@ -95,9 +95,7 @@
 	u8			tunnelhdr;
 
 	struct tcf_result	res;
-#ifdef CONFIG_NET_CLS_POLICE
-	struct tcf_police	*police;
-#endif
+	struct tcf_exts		exts;
 
 	u32			handle;
 	struct rsvp_session	*sess;
@@ -120,18 +118,20 @@
 	return h & 0xF;
 }
 
-#ifdef CONFIG_NET_CLS_POLICE
-#define RSVP_POLICE() \
-if (f->police) { \
-	int pol_res = tcf_police(skb, f->police); \
-	if (pol_res < 0) continue; \
-	if (pol_res) return pol_res; \
-}
-#else
-#define RSVP_POLICE()
-#endif
-
+static struct tcf_ext_map rsvp_ext_map = {
+	.police = TCA_RSVP_POLICE,
+	.action = TCA_RSVP_ACT
+};
 
+#define RSVP_APPLY_RESULT()					\
+	do {							\
+		int r = tcf_exts_exec(skb, &f->exts, res);	\
+		if (r < 0)					\
+			continue;				\
+		else if (r > 0)					\
+			return r;				\
+	} while(0)
+	
 static int rsvp_classify(struct sk_buff *skb, struct tcf_proto *tp,
 			 struct tcf_result *res)
 {
@@ -189,8 +189,7 @@
 #endif
 				    ) {
 					*res = f->res;
-
-					RSVP_POLICE();
+					RSVP_APPLY_RESULT();
 
 matched:
 					if (f->tunnelhdr == 0)
@@ -205,7 +204,7 @@
 			/* And wildcard bucket... */
 			for (f = s->ht[16]; f; f = f->next) {
 				*res = f->res;
-				RSVP_POLICE();
+				RSVP_APPLY_RESULT();
 				goto matched;
 			}
 			return -1;
@@ -251,6 +250,14 @@
 	return -ENOBUFS;
 }
 
+static inline void
+rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
+{
+	tcf_unbind_filter(tp, &f->res);
+	tcf_exts_destroy(tp, &f->exts);
+	kfree(f);
+}
+
 static void rsvp_destroy(struct tcf_proto *tp)
 {
 	struct rsvp_head *data = xchg(&tp->root, NULL);
@@ -273,11 +280,7 @@
 
 				while ((f = s->ht[h2]) != NULL) {
 					s->ht[h2] = f->next;
-					tcf_unbind_filter(tp, &f->res);
-#ifdef CONFIG_NET_CLS_POLICE
-					tcf_police_release(f->police,TCA_ACT_UNBIND);
-#endif
-					kfree(f);
+					rsvp_delete_filter(tp, f);
 				}
 			}
 			kfree(s);
@@ -299,12 +302,7 @@
 			tcf_tree_lock(tp);
 			*fp = f->next;
 			tcf_tree_unlock(tp);
-			tcf_unbind_filter(tp, &f->res);
-#ifdef CONFIG_NET_CLS_POLICE
-			tcf_police_release(f->police,TCA_ACT_UNBIND);
-#endif
-
-			kfree(f);
+			rsvp_delete_filter(tp, f);
 
 			/* Strip tree */
 
@@ -412,6 +410,7 @@
 	struct tc_rsvp_pinfo *pinfo = NULL;
 	struct rtattr *opt = tca[TCA_OPTIONS-1];
 	struct rtattr *tb[TCA_RSVP_MAX];
+	struct tcf_exts e;
 	unsigned h1, h2;
 	u32 *dst;
 	int err;
@@ -419,38 +418,38 @@
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	if (rtattr_parse(tb, TCA_RSVP_MAX, RTA_DATA(opt), RTA_PAYLOAD(opt)) < 0)
+	if (rtattr_parse_nested(tb, TCA_RSVP_MAX, opt) < 0)
 		return -EINVAL;
 
+	err = tcf_exts_validate(tp, tb, tca[TCA_RATE-1], &e, &rsvp_ext_map);
+	if (err < 0)
+		return err;
+
 	if ((f = (struct rsvp_filter*)*arg) != NULL) {
 		/* Node exists: adjust only classid */
 
 		if (f->handle != handle && handle)
-			return -EINVAL;
+			goto errout2;
 		if (tb[TCA_RSVP_CLASSID-1]) {
 			f->res.classid = *(u32*)RTA_DATA(tb[TCA_RSVP_CLASSID-1]);
 			tcf_bind_filter(tp, &f->res, base);
 		}
-#ifdef CONFIG_NET_CLS_POLICE
-		if (tb[TCA_RSVP_POLICE-1]) {
-			err = tcf_change_police(tp, &f->police,
-				tb[TCA_RSVP_POLICE-1], tca[TCA_RATE-1]);
-			if (err < 0)
-				return err;
-		}
-#endif
+
+		tcf_exts_change(tp, &f->exts, &e);
 		return 0;
 	}
 
 	/* Now more serious part... */
+	err = -EINVAL;
 	if (handle)
-		return -EINVAL;
+		goto errout2;
 	if (tb[TCA_RSVP_DST-1] == NULL)
-		return -EINVAL;
+		goto errout2;
 
+	err = -ENOBUFS;
 	f = kmalloc(sizeof(struct rsvp_filter), GFP_KERNEL);
 	if (f == NULL)
-		return -ENOBUFS;
+		goto errout2;
 
 	memset(f, 0, sizeof(*f));
 	h2 = 16;
@@ -516,10 +515,8 @@
 			f->sess = s;
 			if (f->tunnelhdr == 0)
 				tcf_bind_filter(tp, &f->res, base);
-#ifdef CONFIG_NET_CLS_POLICE
-			if (tb[TCA_RSVP_POLICE-1])
-				tcf_change_police(tp, &f->police, tb[TCA_RSVP_POLICE-1], tca[TCA_RATE-1]);
-#endif
+
+			tcf_exts_change(tp, &f->exts, &e);
 
 			for (fp = &s->ht[h2]; *fp; fp = &(*fp)->next)
 				if (((*fp)->spi.mask&f->spi.mask) != f->spi.mask)
@@ -560,6 +557,8 @@
 errout:
 	if (f)
 		kfree(f);
+errout2:
+	tcf_exts_destroy(tp, &e);
 	return err;
 }
 
@@ -624,17 +623,14 @@
 		RTA_PUT(skb, TCA_RSVP_CLASSID, 4, &f->res.classid);
 	if (((f->handle>>8)&0xFF) != 16)
 		RTA_PUT(skb, TCA_RSVP_SRC, sizeof(f->src), f->src);
-#ifdef CONFIG_NET_CLS_POLICE
-	if (tcf_dump_police(skb, f->police, TCA_RSVP_POLICE) < 0)
+
+	if (tcf_exts_dump(skb, &f->exts, &rsvp_ext_map) < 0)
 		goto rtattr_failure;
-#endif
 
 	rta->rta_len = skb->tail - b;
-#ifdef CONFIG_NET_CLS_POLICE
-	if (f->police)
-		if (tcf_police_dump_stats(skb, f->police) < 0)
-			goto rtattr_failure;
-#endif
+
+	if (tcf_exts_dump_stats(skb, &f->exts, &rsvp_ext_map) < 0)
+		goto rtattr_failure;
 	return skb->len;
 
 rtattr_failure:
