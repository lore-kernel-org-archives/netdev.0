From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/9] PKT_SCHED: tcindex: allow changing parameters for existing filters and use tcf_exts API
Date: Thu, 30 Dec 2004 13:34:11 +0100
Message-ID: <20041230123411.GS32419@postel.suug.ch>
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
actions. Replaces the existing change implementation with a new one
supporting changes for existing filters which allows to change a
classifier without letting a single packet pass by unclassified.

Fixes various cases where a error is returned but the filter was
changed already.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-bk1.orig/include/linux/pkt_cls.h	2004-12-27 22:28:09.000000000 +0100
+++ linux-2.6.10-bk1/include/linux/pkt_cls.h	2004-12-27 22:28:30.000000000 +0100
@@ -312,6 +312,7 @@
 	TCA_TCINDEX_FALL_THROUGH,
 	TCA_TCINDEX_CLASSID,
 	TCA_TCINDEX_POLICE,
+	TCA_TCINDEX_ACT,
 	__TCA_TCINDEX_MAX
 };
 
--- linux-2.6.10-bk2.orig/net/sched/cls_tcindex.c	2004-12-29 20:41:32.000000000 +0100
+++ linux-2.6.10-bk2/net/sched/cls_tcindex.c	2004-12-29 22:52:46.000000000 +0100
@@ -49,12 +49,12 @@
 
 
 struct tcindex_filter_result {
-	struct tcf_police *police;
-	struct tcf_result res;
+	struct tcf_exts		exts;
+	struct tcf_result	res;
 };
 
 struct tcindex_filter {
-	__u16 key;
+	u16 key;
 	struct tcindex_filter_result result;
 	struct tcindex_filter *next;
 };
@@ -64,60 +64,64 @@
 	struct tcindex_filter_result *perfect; /* perfect hash; NULL if none */
 	struct tcindex_filter **h; /* imperfect hash; only used if !perfect;
 				      NULL if unused */
-	__u16 mask;		/* AND key with mask */
+	u16 mask;		/* AND key with mask */
 	int shift;		/* shift ANDed key to the right */
 	int hash;		/* hash table size; 0 if undefined */
 	int alloc_hash;		/* allocated size */
 	int fall_through;	/* 0: only classify if explicit match */
 };
 
+static struct tcf_ext_map tcindex_ext_map = {
+	.police = TCA_TCINDEX_POLICE,
+	.action = TCA_TCINDEX_ACT
+};
+
+static inline int
+tcindex_filter_is_set(struct tcindex_filter_result *r)
+{
+	return tcf_exts_is_predicative(&r->exts) || r->res.classid;
+}
 
-static struct tcindex_filter_result *lookup(struct tcindex_data *p,__u16 key)
+static struct tcindex_filter_result *
+tcindex_lookup(struct tcindex_data *p, u16 key)
 {
 	struct tcindex_filter *f;
 
 	if (p->perfect)
-		return p->perfect[key].res.class ? p->perfect+key : NULL;
-	if (!p->h)
-		return NULL;
-	for (f = p->h[key % p->hash]; f; f = f->next) {
-		if (f->key == key)
-			return &f->result;
+		return tcindex_filter_is_set(p->perfect + key) ?
+			p->perfect + key : NULL;
+	else if (p->h) {
+		for (f = p->h[key % p->hash]; f; f = f->next)
+			if (f->key == key)
+				return &f->result;
 	}
+
 	return NULL;
 }
 
 
 static int tcindex_classify(struct sk_buff *skb, struct tcf_proto *tp,
-			  struct tcf_result *res)
+			    struct tcf_result *res)
 {
 	struct tcindex_data *p = PRIV(tp);
 	struct tcindex_filter_result *f;
+	int key = (skb->tc_index & p->mask) >> p->shift;
 
 	D2PRINTK("tcindex_classify(skb %p,tp %p,res %p),p %p\n",skb,tp,res,p);
 
-	f = lookup(p,(skb->tc_index & p->mask) >> p->shift);
+	f = tcindex_lookup(p, key);
 	if (!f) {
 		if (!p->fall_through)
 			return -1;
-		res->classid = TC_H_MAKE(TC_H_MAJ(tp->q->handle),
-		    (skb->tc_index& p->mask) >> p->shift);
+		res->classid = TC_H_MAKE(TC_H_MAJ(tp->q->handle), key);
 		res->class = 0;
 		D2PRINTK("alg 0x%x\n",res->classid);
 		return 0;
 	}
 	*res = f->res;
 	D2PRINTK("map 0x%x\n",res->classid);
-#ifdef CONFIG_NET_CLS_POLICE
-	if (f->police) {
-		int result;
-
-		result = tcf_police(skb,f->police);
-		D2PRINTK("police %d\n",res);
-		return result;
-	}
-#endif
-	return 0;
+
+	return tcf_exts_exec(skb, &f->exts, res);
 }
 
 
@@ -129,8 +133,8 @@
 	DPRINTK("tcindex_get(tp %p,handle 0x%08x)\n",tp,handle);
 	if (p->perfect && handle >= p->alloc_hash)
 		return 0;
-	r = lookup(PRIV(tp),handle);
-	return r && r->res.class ? (unsigned long) r : 0;
+	r = tcindex_lookup(p, handle);
+	return r && tcindex_filter_is_set(r) ? (unsigned long) r : 0UL;
 }
 
 
@@ -149,13 +153,12 @@
 	if (!p)
 		return -ENOMEM;
 
-	tp->root = p;
-	p->perfect = NULL;
-	p->h = NULL;
-	p->hash = 0;
+	memset(p, 0, sizeof(*p));
 	p->mask = 0xffff;
-	p->shift = 0;
+	p->hash = DEFAULT_HASH_SIZE;
 	p->fall_through = 1;
+
+	tp->root = p;
 	return 0;
 }
 
@@ -190,9 +193,7 @@
 			tcf_tree_unlock(tp);
 	}
 	tcf_unbind_filter(tp, &r->res);
-#ifdef CONFIG_NET_CLS_POLICE
-	tcf_police_release(r->police, TCA_ACT_UNBIND);
-#endif
+	tcf_exts_destroy(tp, &r->exts);
 	if (f)
 		kfree(f);
 	return 0;
@@ -203,148 +204,184 @@
 	return __tcindex_delete(tp, arg, 1);
 }
 
-/*
- * There are no parameters for tcindex_init, so we overload tcindex_change
- */
+static inline int
+valid_perfect_hash(struct tcindex_data *p)
+{
+	return  p->hash > (p->mask >> p->shift);
+}
+
+static int
+tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
+		  struct tcindex_data *p, struct tcindex_filter_result *r,
+		  struct rtattr **tb, struct rtattr *est)
+{
+	int err, balloc = 0;
+	struct tcindex_filter_result new_filter_result, *old_r = r;
+	struct tcindex_filter_result cr;
+	struct tcindex_data cp;
+	struct tcindex_filter *f = NULL; /* make gcc behave */
+	struct tcf_exts e;
+
+	err = tcf_exts_validate(tp, tb, est, &e, &tcindex_ext_map);
+	if (err < 0)
+		return err;
+	
+	memcpy(&cp, p, sizeof(cp));
+	memset(&new_filter_result, 0, sizeof(new_filter_result));
+
+	if (old_r)
+		memcpy(&cr, r, sizeof(cr));
+	else
+		memset(&cr, 0, sizeof(cr));
+
+	err = -EINVAL;
+	if (tb[TCA_TCINDEX_HASH-1]) {
+		if (RTA_PAYLOAD(tb[TCA_TCINDEX_HASH-1]) < sizeof(u32))
+			goto errout;
+		cp.hash = *(u32 *) RTA_DATA(tb[TCA_TCINDEX_HASH-1]);
+	}
+
+	if (tb[TCA_TCINDEX_MASK-1]) {
+		if (RTA_PAYLOAD(tb[TCA_TCINDEX_MASK-1]) < sizeof(u16))
+			goto errout;
+		cp.mask = *(u16 *) RTA_DATA(tb[TCA_TCINDEX_MASK-1]);
+	}
+
+	if (tb[TCA_TCINDEX_SHIFT-1]) {
+		if (RTA_PAYLOAD(tb[TCA_TCINDEX_SHIFT-1]) < sizeof(u16))
+			goto errout;
+		cp.shift = *(u16 *) RTA_DATA(tb[TCA_TCINDEX_SHIFT-1]);
+	}
+
+	err = -EBUSY;
+	/* Hash already allocated, make sure that we still meet the
+	 * requirements for the allocated hash.
+	 */
+	if (cp.perfect) {
+		if (!valid_perfect_hash(&cp) ||
+		    cp.hash > cp.alloc_hash)
+			goto errout;
+	} else if (cp.h && cp.hash != cp.alloc_hash)
+		goto errout;
+
+	err = -EINVAL;
+	if (tb[TCA_TCINDEX_FALL_THROUGH-1]) {
+		if (RTA_PAYLOAD(tb[TCA_TCINDEX_FALL_THROUGH-1]) < sizeof(u32))
+			goto errout;
+		cp.fall_through =
+			*(u32 *) RTA_DATA(tb[TCA_TCINDEX_FALL_THROUGH-1]);
+	}
+
+	if (!cp.hash) {
+		/* Hash not specified, use perfect hash if the upper limit
+		 * of the hashing index is below the threshold.
+		 */
+		if ((cp.mask >> cp.shift) < PERFECT_HASH_THRESHOLD)
+			cp.hash = (cp.mask >> cp.shift)+1;
+		else
+			cp.hash = DEFAULT_HASH_SIZE;
+	}
+
+	if (!cp.perfect && !cp.h)
+		cp.alloc_hash = cp.hash;
+
+	/* Note: this could be as restrictive as if (handle & ~(mask >> shift))
+	 * but then, we'd fail handles that may become valid after some future
+	 * mask change. While this is extremely unlikely to ever matter,
+	 * the check below is safer (and also more backwards-compatible).
+	 */
+	if (cp.perfect || valid_perfect_hash(&cp))
+		if (handle >= cp.alloc_hash)
+			goto errout;
+
+
+	err = -ENOMEM;
+	if (!cp.perfect && !cp.h) {
+		if (valid_perfect_hash(&cp)) {
+			cp.perfect = kmalloc(cp.hash * sizeof(*r), GFP_KERNEL);
+			if (!cp.perfect)
+				goto errout;
+			memset(cp.perfect, 0, cp.hash * sizeof(*r));
+			balloc = 1;
+		} else {
+			cp.h = kmalloc(cp.hash * sizeof(f), GFP_KERNEL);
+			if (!cp.h)
+				goto errout;
+			memset(cp.h, 0, cp.hash * sizeof(f));
+			balloc = 2;
+		}
+	}
+
+	if (cp.perfect)
+		r = cp.perfect + handle;
+	else
+		r = tcindex_lookup(&cp, handle) ? : &new_filter_result;
+
+	if (r == &new_filter_result) {
+		f = kmalloc(sizeof(*f), GFP_KERNEL);
+		if (!f)
+			goto errout_alloc;
+		memset(f, 0, sizeof(*f));
+ 	}
+
+	if (tb[TCA_TCINDEX_CLASSID-1]) {
+		cr.res.classid = *(u32 *) RTA_DATA(tb[TCA_TCINDEX_CLASSID-1]);
+		tcf_bind_filter(tp, &cr.res, base);
+ 	}
+
+	tcf_exts_change(tp, &cr.exts, &e);
+
+	tcf_tree_lock(tp);
+	if (old_r && old_r != r)
+		memset(old_r, 0, sizeof(*old_r));
+
+	memcpy(p, &cp, sizeof(cp));
+	memcpy(r, &cr, sizeof(cr));
+
+	if (r == &new_filter_result) {
+		struct tcindex_filter **fp;
+
+		f->key = handle;
+		f->result = new_filter_result;
+		f->next = NULL;
+		for (fp = p->h+(handle % p->hash); *fp; fp = &(*fp)->next)
+			/* nothing */;
+		*fp = f;
+ 	}
+	tcf_tree_unlock(tp);
+
+	return 0;
 
+errout_alloc:
+	if (balloc == 1)
+		kfree(cp.perfect);
+	else if (balloc == 2)
+		kfree(cp.h);
+errout:
+	tcf_exts_destroy(tp, &e);
+	return err;
+}
 
-static int tcindex_change(struct tcf_proto *tp,unsigned long base,u32 handle,
-    struct rtattr **tca,unsigned long *arg)
-{
-	struct tcindex_filter_result new_filter_result = {
-		NULL,		/* no policing */
-		{ 0,0 },	/* no classification */
-	};
+static int
+tcindex_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+	       struct rtattr **tca, unsigned long *arg)
+{
 	struct rtattr *opt = tca[TCA_OPTIONS-1];
 	struct rtattr *tb[TCA_TCINDEX_MAX];
 	struct tcindex_data *p = PRIV(tp);
-	struct tcindex_filter *f;
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) *arg;
-	struct tcindex_filter **walk;
-	int hash,shift;
-	__u16 mask;
 
 	DPRINTK("tcindex_change(tp %p,handle 0x%08x,tca %p,arg %p),opt %p,"
-	    "p %p,r %p\n",tp,handle,tca,arg,opt,p,r);
-	if (arg)
-		DPRINTK("*arg = 0x%lx\n",*arg);
+	    "p %p,r %p,*arg 0x%lx\n",
+	    tp, handle, tca, arg, opt, p, r, arg ? *arg : 0L);
+
 	if (!opt)
 		return 0;
-	if (rtattr_parse(tb,TCA_TCINDEX_MAX,RTA_DATA(opt),RTA_PAYLOAD(opt)) < 0)
-		return -EINVAL;
-	if (!tb[TCA_TCINDEX_HASH-1]) {
-		hash = p->hash;
-	} else {
-		if (RTA_PAYLOAD(tb[TCA_TCINDEX_HASH-1]) < sizeof(int))
-			return -EINVAL;
-		hash = *(int *) RTA_DATA(tb[TCA_TCINDEX_HASH-1]);
-	}
-	if (!tb[TCA_TCINDEX_MASK-1]) {
-		mask = p->mask;
-	} else {
-		if (RTA_PAYLOAD(tb[TCA_TCINDEX_MASK-1]) < sizeof(__u16))
-			return -EINVAL;
-		mask = *(__u16 *) RTA_DATA(tb[TCA_TCINDEX_MASK-1]);
-	}
-	if (!tb[TCA_TCINDEX_SHIFT-1])
-		shift = p->shift;
-	else {
-		if (RTA_PAYLOAD(tb[TCA_TCINDEX_SHIFT-1]) < sizeof(__u16))
-			return -EINVAL;
-		shift = *(int *) RTA_DATA(tb[TCA_TCINDEX_SHIFT-1]);
-	}
-	if (p->perfect && hash <= (mask >> shift))
-		return -EBUSY;
-	if (p->perfect && hash > p->alloc_hash)
-		return -EBUSY;
-	if (p->h && hash != p->alloc_hash)
-		return -EBUSY;
-	p->hash = hash;
-	p->mask = mask;
-	p->shift = shift;
-	if (tb[TCA_TCINDEX_FALL_THROUGH-1]) {
-		if (RTA_PAYLOAD(tb[TCA_TCINDEX_FALL_THROUGH-1]) < sizeof(int))
-			return -EINVAL;
-		p->fall_through =
-		    *(int *) RTA_DATA(tb[TCA_TCINDEX_FALL_THROUGH-1]);
-	}
-	DPRINTK("classid/police %p/%p\n",tb[TCA_TCINDEX_CLASSID-1],
-	    tb[TCA_TCINDEX_POLICE-1]);
-	if (!tb[TCA_TCINDEX_CLASSID-1] && !tb[TCA_TCINDEX_POLICE-1])
-		return 0;
-	if (!hash) {
-		if ((mask >> shift) < PERFECT_HASH_THRESHOLD) {
-			p->hash = (mask >> shift)+1;
-		} else {
-			p->hash = DEFAULT_HASH_SIZE;
-		}
-	}
-	if (!p->perfect && !p->h) {
-		p->alloc_hash = p->hash;
-		DPRINTK("hash %d mask %d\n",p->hash,p->mask);
-		if (p->hash > (mask >> shift)) {
-			p->perfect = kmalloc(p->hash*
-			    sizeof(struct tcindex_filter_result),GFP_KERNEL);
-			if (!p->perfect)
-				return -ENOMEM;
-			memset(p->perfect, 0,
-			       p->hash * sizeof(struct tcindex_filter_result));
-		} else {
-			p->h = kmalloc(p->hash*sizeof(struct tcindex_filter *),
-			    GFP_KERNEL);
-			if (!p->h)
-				return -ENOMEM;
-			memset(p->h, 0, p->hash*sizeof(struct tcindex_filter *));
-		}
-	}
-	/*
-	 * Note: this could be as restrictive as
-	 * if (handle & ~(mask >> shift))
-	 * but then, we'd fail handles that may become valid after some
-	 * future mask change. While this is extremely unlikely to ever
-	 * matter, the check below is safer (and also more
-	 * backwards-compatible).
-	 */
-	if (p->perfect && handle >= p->alloc_hash)
+
+	if (rtattr_parse_nested(tb, TCA_TCINDEX_MAX, opt) < 0)
 		return -EINVAL;
-	if (p->perfect) {
-		r = p->perfect+handle;
-	} else {
-		r = lookup(p,handle);
-		DPRINTK("r=%p\n",r);
-		if (!r)
-			r = &new_filter_result;
-	}
-	DPRINTK("r=%p\n",r);
-	if (tb[TCA_TCINDEX_CLASSID-1]) {
-		r->res.classid = *(__u32 *) RTA_DATA(tb[TCA_TCINDEX_CLASSID-1]);
-		tcf_bind_filter(tp, &r->res, base);
 
-		if (!r->res.class) {
-			r->res.classid = 0;
-			return -ENOENT;
-		}
-	}
-#ifdef CONFIG_NET_CLS_POLICE
-	if (tb[TCA_TCINDEX_POLICE-1]) {
-		int err = tcf_change_police(tp, &r->police, tb[TCA_TCINDEX_POLICE-1], NULL);
-		if (err < 0)
-			return err;
-	}
-#endif
-	if (r != &new_filter_result)
-		return 0;
-	f = kmalloc(sizeof(struct tcindex_filter),GFP_KERNEL);
-	if (!f)
-		return -ENOMEM;
-	f->key = handle;
-	f->result = new_filter_result;
-	f->next = NULL;
-	for (walk = p->h+(handle % p->hash); *walk; walk = &(*walk)->next)
-		/* nothing */;
-	wmb();
-	*walk = f;
-	return 0;
+	return tcindex_set_parms(tp, base, handle, p, r, tb, tca[TCA_RATE-1]);
 }
 
 
@@ -434,6 +471,7 @@
 		RTA_PUT(skb,TCA_TCINDEX_SHIFT,sizeof(p->shift),&p->shift);
 		RTA_PUT(skb,TCA_TCINDEX_FALL_THROUGH,sizeof(p->fall_through),
 		    &p->fall_through);
+		rta->rta_len = skb->tail-b;
 	} else {
 		if (p->perfect) {
 			t->tcm_handle = r-p->perfect;
@@ -453,12 +491,15 @@
 		DPRINTK("handle = %d\n",t->tcm_handle);
 		if (r->res.class)
 			RTA_PUT(skb, TCA_TCINDEX_CLASSID, 4, &r->res.classid);
-#ifdef CONFIG_NET_CLS_POLICE
-		if (tcf_dump_police(skb, r->police, TCA_TCINDEX_POLICE) < 0)
+
+		if (tcf_exts_dump(skb, &r->exts, &tcindex_ext_map) < 0)
+			goto rtattr_failure;
+		rta->rta_len = skb->tail-b;
+
+		if (tcf_exts_dump_stats(skb, &r->exts, &tcindex_ext_map) < 0)
 			goto rtattr_failure;
-#endif
 	}
-	rta->rta_len = skb->tail-b;
+	
 	return skb->len;
 
 rtattr_failure:
