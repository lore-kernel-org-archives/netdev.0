From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/9] PKT_SCHED: route: allow changing parameters for existing filters and use tcf_exts API
Date: Thu, 30 Dec 2004 13:33:11 +0100
Message-ID: <20041230123311.GR32419@postel.suug.ch>
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

Transforms route to use tcf_exts API and thus adds support for
actions. Replaces the existing change implementation with a new one
supporting changes for existing filters which allows to change a
classifier without letting a single packet pass by unclassified.

Fixes various cases where a error is returned but the filter was
changed already.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-bk1.orig/include/linux/pkt_cls.h	2004-12-27 21:34:52.000000000 +0100
+++ linux-2.6.10-bk1/include/linux/pkt_cls.h	2004-12-27 21:46:40.000000000 +0100
@@ -280,6 +280,7 @@
 	TCA_ROUTE4_FROM,
 	TCA_ROUTE4_IIF,
 	TCA_ROUTE4_POLICE,
+	TCA_ROUTE4_ACT,
 	__TCA_ROUTE4_MAX
 };
 
--- linux-2.6.10-bk2.orig/net/sched/cls_route.c	2004-12-29 20:16:24.000000000 +0100
+++ linux-2.6.10-bk2/net/sched/cls_route.c	2004-12-29 20:21:15.000000000 +0100
@@ -59,6 +59,7 @@
 
 struct route4_bucket
 {
+	/* 16 FROM buckets + 16 IIF buckets + 1 wildcard bucket */
 	struct route4_filter	*ht[16+16+1];
 };
 
@@ -69,22 +70,25 @@
 	int			iif;
 
 	struct tcf_result	res;
-#ifdef CONFIG_NET_CLS_POLICE
-	struct tcf_police	*police;
-#endif
-
+	struct tcf_exts		exts;
 	u32			handle;
 	struct route4_bucket	*bkt;
 };
 
 #define ROUTE4_FAILURE ((struct route4_filter*)(-1L))
 
+static struct tcf_ext_map route_ext_map = {
+	.police = TCA_ROUTE4_POLICE,
+	.action = TCA_ROUTE4_ACT
+};
+
 static __inline__ int route4_fastmap_hash(u32 id, int iif)
 {
 	return id&0xF;
 }
 
-static void route4_reset_fastmap(struct net_device *dev, struct route4_head *head, u32 id)
+static inline
+void route4_reset_fastmap(struct net_device *dev, struct route4_head *head, u32 id)
 {
 	spin_lock_bh(&dev->queue_lock);
 	memset(head->fastmap, 0, sizeof(head->fastmap));
@@ -121,19 +125,20 @@
 	return 32;
 }
 
-#ifdef CONFIG_NET_CLS_POLICE
-#define IF_ROUTE_POLICE \
-if (f->police) { \
-	int pol_res = tcf_police(skb, f->police); \
-	if (pol_res >= 0) return pol_res; \
-	dont_cache = 1; \
-	continue; \
-} \
-if (!dont_cache)
-#else
-#define IF_ROUTE_POLICE
-#endif
-
+#define ROUTE4_APPLY_RESULT()						\
+	do {								\
+		*res = f->res;						\
+		if (tcf_exts_is_available(&f->exts)) {			\
+			int r = tcf_exts_exec(skb, &f->exts, res);	\
+			if (r < 0) {					\
+				dont_cache = 1;				\
+				continue;				\
+			}						\
+			return r;					\
+		} else if (!dont_cache)					\
+			route4_set_fastmap(head, id, iif, f);		\
+		return 0;						\
+	} while(0)
 
 static int route4_classify(struct sk_buff *skb, struct tcf_proto *tp,
 			   struct tcf_result *res)
@@ -142,11 +147,8 @@
 	struct dst_entry *dst;
 	struct route4_bucket *b;
 	struct route4_filter *f;
-#ifdef CONFIG_NET_CLS_POLICE
-	int dont_cache = 0;
-#endif
 	u32 id, h;
-	int iif;
+	int iif, dont_cache = 0;
 
 	if ((dst = skb->dst) == NULL)
 		goto failure;
@@ -172,29 +174,16 @@
 
 restart:
 	if ((b = head->table[h]) != NULL) {
-		f = b->ht[route4_hash_from(id)];
-
-		for ( ; f; f = f->next) {
-			if (f->id == id) {
-				*res = f->res;
-				IF_ROUTE_POLICE route4_set_fastmap(head, id, iif, f);
-				return 0;
-			}
-		}
-
-		for (f = b->ht[route4_hash_iif(iif)]; f; f = f->next) {
-			if (f->iif == iif) {
-				*res = f->res;
-				IF_ROUTE_POLICE route4_set_fastmap(head, id, iif, f);
-				return 0;
-			}
-		}
+		for (f = b->ht[route4_hash_from(id)]; f; f = f->next)
+			if (f->id == id)
+				ROUTE4_APPLY_RESULT();
+
+		for (f = b->ht[route4_hash_iif(iif)]; f; f = f->next)
+			if (f->iif == iif)
+				ROUTE4_APPLY_RESULT();
 
-		for (f = b->ht[route4_hash_wild()]; f; f = f->next) {
-			*res = f->res;
-			IF_ROUTE_POLICE route4_set_fastmap(head, id, iif, f);
-			return 0;
-		}
+		for (f = b->ht[route4_hash_wild()]; f; f = f->next)
+			ROUTE4_APPLY_RESULT();
 
 	}
 	if (h < 256) {
@@ -203,9 +192,7 @@
 		goto restart;
 	}
 
-#ifdef CONFIG_NET_CLS_POLICE
 	if (!dont_cache)
-#endif
 		route4_set_fastmap(head, id, iif, ROUTE4_FAILURE);
 failure:
 	return -1;
@@ -220,7 +207,7 @@
 	return -1;
 }
 
-static u32 to_hash(u32 id)
+static inline u32 to_hash(u32 id)
 {
 	u32 h = id&0xFF;
 	if (id&0x8000)
@@ -228,7 +215,7 @@
 	return h;
 }
 
-static u32 from_hash(u32 id)
+static inline u32 from_hash(u32 id)
 {
 	id &= 0xFFFF;
 	if (id == 0xFFFF)
@@ -276,6 +263,14 @@
 	return 0;
 }
 
+static inline void
+route4_delete_filter(struct tcf_proto *tp, struct route4_filter *f)
+{
+	tcf_unbind_filter(tp, &f->res);
+	tcf_exts_destroy(tp, &f->exts);
+	kfree(f);
+}
+
 static void route4_destroy(struct tcf_proto *tp)
 {
 	struct route4_head *head = xchg(&tp->root, NULL);
@@ -293,11 +288,7 @@
 
 				while ((f = b->ht[h2]) != NULL) {
 					b->ht[h2] = f->next;
-					tcf_unbind_filter(tp, &f->res);
-#ifdef CONFIG_NET_CLS_POLICE
-					tcf_police_release(f->police,TCA_ACT_UNBIND);
-#endif
-					kfree(f);
+					route4_delete_filter(tp, f);
 				}
 			}
 			kfree(b);
@@ -327,11 +318,7 @@
 			tcf_tree_unlock(tp);
 
 			route4_reset_fastmap(tp->q->dev, head, f->id);
-			tcf_unbind_filter(tp, &f->res);
-#ifdef CONFIG_NET_CLS_POLICE
-			tcf_police_release(f->police,TCA_ACT_UNBIND);
-#endif
-			kfree(f);
+			route4_delete_filter(tp, f);
 
 			/* Strip tree */
 
@@ -351,108 +338,63 @@
 	return 0;
 }
 
-static int route4_change(struct tcf_proto *tp, unsigned long base,
-		       u32 handle,
-		       struct rtattr **tca,
-		       unsigned long *arg)
+static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
+	struct route4_filter *f, u32 handle, struct route4_head *head,
+	struct rtattr **tb, struct rtattr *est, int new)
 {
-	struct route4_head *head = tp->root;
-	struct route4_filter *f, *f1, **ins_f;
-	struct route4_bucket *b;
-	struct rtattr *opt = tca[TCA_OPTIONS-1];
-	struct rtattr *tb[TCA_ROUTE4_MAX];
-	unsigned h1, h2;
 	int err;
+	u32 id = 0, to = 0, nhandle = 0x8000;
+	struct route4_filter *fp;
+	unsigned int h1;
+	struct route4_bucket *b;
+	struct tcf_exts e;
 
-	if (opt == NULL)
-		return handle ? -EINVAL : 0;
-
-	if (rtattr_parse(tb, TCA_ROUTE4_MAX, RTA_DATA(opt), RTA_PAYLOAD(opt)) < 0)
-		return -EINVAL;
-
-	if ((f = (struct route4_filter*)*arg) != NULL) {
-		if (f->handle != handle && handle)
-			return -EINVAL;
-		if (tb[TCA_ROUTE4_CLASSID-1]) {
-			f->res.classid = *(u32*)RTA_DATA(tb[TCA_ROUTE4_CLASSID-1]);
-			tcf_bind_filter(tp, &f->res, base);
-		}
-#ifdef CONFIG_NET_CLS_POLICE
-		if (tb[TCA_ROUTE4_POLICE-1]) {
-			err = tcf_change_police(tp, &f->police,
-				tb[TCA_ROUTE4_POLICE-1], tca[TCA_RATE-1]);
-			if (err < 0)
-				return err;
-		}
-#endif
-		return 0;
-	}
-
-	/* Now more serious part... */
-
-	if (head == NULL) {
-		head = kmalloc(sizeof(struct route4_head), GFP_KERNEL);
-		if (head == NULL)
-			return -ENOBUFS;
-		memset(head, 0, sizeof(struct route4_head));
-
-		tcf_tree_lock(tp);
-		tp->root = head;
-		tcf_tree_unlock(tp);
-	}
-
-	f = kmalloc(sizeof(struct route4_filter), GFP_KERNEL);
-	if (f == NULL)
-		return -ENOBUFS;
-
-	memset(f, 0, sizeof(*f));
+	err = tcf_exts_validate(tp, tb, est, &e, &route_ext_map);
+	if (err < 0)
+		return err;
 
 	err = -EINVAL;
-	f->handle = 0x8000;
+	if (tb[TCA_ROUTE4_CLASSID-1])
+		if (RTA_PAYLOAD(tb[TCA_ROUTE4_CLASSID-1]) < sizeof(u32))
+			goto errout;
+
 	if (tb[TCA_ROUTE4_TO-1]) {
-		if (handle&0x8000)
+		if (new && handle & 0x8000)
 			goto errout;
-		if (RTA_PAYLOAD(tb[TCA_ROUTE4_TO-1]) < 4)
+		if (RTA_PAYLOAD(tb[TCA_ROUTE4_TO-1]) < sizeof(u32))
 			goto errout;
-		f->id = *(u32*)RTA_DATA(tb[TCA_ROUTE4_TO-1]);
-		if (f->id > 0xFF)
+		to = *(u32*)RTA_DATA(tb[TCA_ROUTE4_TO-1]);
+		if (to > 0xFF)
 			goto errout;
-		f->handle = f->id;
+		nhandle = to;
 	}
+
 	if (tb[TCA_ROUTE4_FROM-1]) {
-		u32 sid;
 		if (tb[TCA_ROUTE4_IIF-1])
 			goto errout;
-		if (RTA_PAYLOAD(tb[TCA_ROUTE4_FROM-1]) < 4)
+		if (RTA_PAYLOAD(tb[TCA_ROUTE4_FROM-1]) < sizeof(u32))
 			goto errout;
-		sid = (*(u32*)RTA_DATA(tb[TCA_ROUTE4_FROM-1]));
-		if (sid > 0xFF)
+		id = *(u32*)RTA_DATA(tb[TCA_ROUTE4_FROM-1]);
+		if (id > 0xFF)
 			goto errout;
-		f->handle |= sid<<16;
-		f->id |= sid<<16;
+		nhandle |= id << 16;
 	} else if (tb[TCA_ROUTE4_IIF-1]) {
-		if (RTA_PAYLOAD(tb[TCA_ROUTE4_IIF-1]) < 4)
+		if (RTA_PAYLOAD(tb[TCA_ROUTE4_IIF-1]) < sizeof(u32))
 			goto errout;
-		f->iif = *(u32*)RTA_DATA(tb[TCA_ROUTE4_IIF-1]);
-		if (f->iif > 0x7FFF)
+		id = *(u32*)RTA_DATA(tb[TCA_ROUTE4_IIF-1]);
+		if (id > 0x7FFF)
 			goto errout;
-		f->handle |= (f->iif|0x8000)<<16;
+		nhandle = (id | 0x8000) << 16;
 	} else
-		f->handle |= 0xFFFF<<16;
+		nhandle = 0xFFFF << 16;
 
-	if (handle) {
-		f->handle |= handle&0x7F00;
-		if (f->handle != handle)
+	if (handle && new) {
+		nhandle |= handle & 0x7F00;
+		if (nhandle != handle)
 			goto errout;
 	}
 
-	if (tb[TCA_ROUTE4_CLASSID-1]) {
-		if (RTA_PAYLOAD(tb[TCA_ROUTE4_CLASSID-1]) < 4)
-			goto errout;
-		f->res.classid = *(u32*)RTA_DATA(tb[TCA_ROUTE4_CLASSID-1]);
-	}
-
-	h1 = to_hash(f->handle);
+	h1 = to_hash(nhandle);
 	if ((b = head->table[h1]) == NULL) {
 		err = -ENOBUFS;
 		b = kmalloc(sizeof(struct route4_bucket), GFP_KERNEL);
@@ -463,27 +405,119 @@
 		tcf_tree_lock(tp);
 		head->table[h1] = b;
 		tcf_tree_unlock(tp);
+	} else {
+		unsigned int h2 = from_hash(nhandle >> 16);
+		err = -EEXIST;
+		for (fp = b->ht[h2]; fp; fp = fp->next)
+			if (fp->handle == f->handle)
+				goto errout;
 	}
+
+	tcf_tree_lock(tp);
+	if (tb[TCA_ROUTE4_TO-1])
+		f->id = to;
+
+	if (tb[TCA_ROUTE4_FROM-1])
+		f->id = to | id<<16;
+	else if (tb[TCA_ROUTE4_IIF-1])
+		f->iif = id;
+
+	f->handle = nhandle;
 	f->bkt = b;
+	tcf_tree_unlock(tp);
 
-	err = -EEXIST;
-	h2 = from_hash(f->handle>>16);
-	for (ins_f = &b->ht[h2]; (f1=*ins_f) != NULL; ins_f = &f1->next) {
-		if (f->handle < f1->handle)
-			break;
-		if (f1->handle == f->handle)
+	if (tb[TCA_ROUTE4_CLASSID-1]) {
+		f->res.classid = *(u32*)RTA_DATA(tb[TCA_ROUTE4_CLASSID-1]);
+		tcf_bind_filter(tp, &f->res, base);
+	}
+
+	tcf_exts_change(tp, &f->exts, &e);
+
+	return 0;
+errout:
+	tcf_exts_destroy(tp, &e);
+	return err;
+}
+
+static int route4_change(struct tcf_proto *tp, unsigned long base,
+		       u32 handle,
+		       struct rtattr **tca,
+		       unsigned long *arg)
+{
+	struct route4_head *head = tp->root;
+	struct route4_filter *f, *f1, **fp;
+	struct route4_bucket *b;
+	struct rtattr *opt = tca[TCA_OPTIONS-1];
+	struct rtattr *tb[TCA_ROUTE4_MAX];
+	unsigned int h, th;
+	u32 old_handle = 0;
+	int err;
+
+	if (opt == NULL)
+		return handle ? -EINVAL : 0;
+
+	if (rtattr_parse_nested(tb, TCA_ROUTE4_MAX, opt) < 0)
+		return -EINVAL;
+
+	if ((f = (struct route4_filter*)*arg) != NULL) {
+		if (f->handle != handle && handle)
+			return -EINVAL;
+
+		if (f->bkt)
+			old_handle = f->handle;
+
+		err = route4_set_parms(tp, base, f, handle, head, tb,
+			tca[TCA_RATE-1], 0);
+		if (err < 0)
+			return err;
+
+		goto reinsert;
+	}
+
+	err = -ENOBUFS;
+	if (head == NULL) {
+		head = kmalloc(sizeof(struct route4_head), GFP_KERNEL);
+		if (head == NULL)
 			goto errout;
+		memset(head, 0, sizeof(struct route4_head));
+
+		tcf_tree_lock(tp);
+		tp->root = head;
+		tcf_tree_unlock(tp);
 	}
 
-	tcf_bind_filter(tp, &f->res, base);
-#ifdef CONFIG_NET_CLS_POLICE
-	if (tb[TCA_ROUTE4_POLICE-1])
-		tcf_change_police(tp, &f->police, tb[TCA_ROUTE4_POLICE-1], tca[TCA_RATE-1]);
-#endif
+	f = kmalloc(sizeof(struct route4_filter), GFP_KERNEL);
+	if (f == NULL)
+		goto errout;
+	memset(f, 0, sizeof(*f));
+
+	err = route4_set_parms(tp, base, f, handle, head, tb,
+		tca[TCA_RATE-1], 1);
+	if (err < 0)
+		goto errout;
+
+reinsert:
+	h = from_hash(f->handle >> 16);
+	for (fp = &f->bkt->ht[h]; (f1=*fp) != NULL; fp = &f1->next)
+		if (f->handle < f1->handle)
+			break;
 
 	f->next = f1;
 	tcf_tree_lock(tp);
-	*ins_f = f;
+	*fp = f;
+
+	if (old_handle && f->handle != old_handle) {
+		th = to_hash(old_handle);
+		h = from_hash(old_handle >> 16);
+		if ((b = head->table[th]) != NULL) {
+			for (fp = &b->ht[h]; *fp; fp = &(*fp)->next) {
+				if (*fp == f) {
+					*fp = f->next;
+					break;
+				}
+			}
+		}
+	}
 	tcf_tree_unlock(tp);
 
 	route4_reset_fastmap(tp->q->dev, head, f->id);
@@ -559,17 +593,15 @@
 	}
 	if (f->res.classid)
 		RTA_PUT(skb, TCA_ROUTE4_CLASSID, 4, &f->res.classid);
-#ifdef CONFIG_NET_CLS_POLICE
-	if (tcf_dump_police(skb, f->police, TCA_ROUTE4_POLICE) < 0)
+
+	if (tcf_exts_dump(skb, &f->exts, &route_ext_map) < 0)
 		goto rtattr_failure;
-#endif
 
 	rta->rta_len = skb->tail - b;
-#ifdef CONFIG_NET_CLS_POLICE
-	if (f->police)
-		if (tcf_police_dump_stats(skb, f->police) < 0)
-			goto rtattr_failure;
-#endif
+
+	if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
+		goto rtattr_failure;
+
 	return skb->len;
 
 rtattr_failure:
