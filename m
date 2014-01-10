From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 08/12] net: sched: RCU cls_tcindex
Date: Fri, 10 Jan 2014 01:42:13 -0800
Message-ID: <20140110094211.7193.16540.stgit@nitbit.x32>
References: <20140110092041.7193.5952.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:55150 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbaAJJmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:42:35 -0500
Received: by mail-ob0-f182.google.com with SMTP id wn1so2582658obc.27
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 01:42:35 -0800 (PST)
In-Reply-To: <20140110092041.7193.5952.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make cls_tcindex RCU safe.

This patch addds a new RCU routine rcu_dereference_bh_rtnl() to check
caller either holds the rcu read lock or RTNL. This is needed to
handle the case where tcindex_lookup() is being called in both cases.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/rtnetlink.h |   10 +
 net/sched/cls_tcindex.c   |  327 ++++++++++++++++++++++++++-------------------
 2 files changed, 202 insertions(+), 135 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 939428a..6008b22 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -37,6 +37,16 @@ extern int lockdep_rtnl_is_held(void);
 	rcu_dereference_check(p, lockdep_rtnl_is_held())
 
 /**
+ * rcu_dereference_bh_rtnl - rcu_dereference_bh with debug checking
+ * @p: The pointer to read, prior to dereference
+ *
+ * Do an rcu_dereference_bh(p), but check caller either holds rcu_read_lock_bh()
+ * or RTNL. Note : Please prefer rtnl_dereference() or rcu_dereference_bh()
+ */
+#define rcu_dereference_bh_rtnl(p)				\
+	rcu_dereference_bh_check(p, lockdep_rtnl_is_held())
+
+/**
  * rtnl_dereference - fetch RCU pointer when updates are prevented by RTNL
  * @p: The pointer to read, prior to dereferencing
  *
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index ffad187..19eb24e 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -24,7 +24,7 @@
 #define DEFAULT_HASH_SIZE	64	/* optimized for diffserv */
 
 
-#define	PRIV(tp)	((struct tcindex_data *) (tp)->root)
+#define	PRIV(tp)	((struct tcindex_data *) rtnl_dereference((tp)->root))
 
 
 struct tcindex_filter_result {
@@ -35,19 +35,22 @@ struct tcindex_filter_result {
 struct tcindex_filter {
 	u16 key;
 	struct tcindex_filter_result result;
-	struct tcindex_filter *next;
+	struct tcindex_filter __rcu *next;
+	struct rcu_head rcu;
 };
 
 
 struct tcindex_data {
 	struct tcindex_filter_result *perfect; /* perfect hash; NULL if none */
-	struct tcindex_filter **h; /* imperfect hash; only used if !perfect;
-				      NULL if unused */
+	struct tcindex_filter __rcu **h; /* imperfect hash; only used if
+					    !perfect NULL if unused */
+	struct rcu_head rcu;
+	struct tcf_proto *tp;
 	u16 mask;		/* AND key with mask */
-	int shift;		/* shift ANDed key to the right */
-	int hash;		/* hash table size; 0 if undefined */
-	int alloc_hash;		/* allocated size */
-	int fall_through;	/* 0: only classify if explicit match */
+	u32 shift;		/* shift ANDed key to the right */
+	u32 hash;		/* hash table size; 0 if undefined */
+	u32 alloc_hash;		/* allocated size */
+	u32 fall_through;	/* 0: only classify if explicit match */
 };
 
 static inline int
@@ -59,13 +62,18 @@ tcindex_filter_is_set(struct tcindex_filter_result *r)
 static struct tcindex_filter_result *
 tcindex_lookup(struct tcindex_data *p, u16 key)
 {
-	struct tcindex_filter *f;
+	if (p->perfect) {
+		struct tcindex_filter_result *f = p->perfect + key;
+
+		return tcindex_filter_is_set(f) ? f : NULL;
+	} else if (p->h) {
+		struct tcindex_filter __rcu **fp;
+		struct tcindex_filter *f;
 
-	if (p->perfect)
-		return tcindex_filter_is_set(p->perfect + key) ?
-			p->perfect + key : NULL;
-	else if (p->h) {
-		for (f = p->h[key % p->hash]; f; f = f->next)
+		fp = &p->h[key % p->hash];
+		for (f = rcu_dereference_bh_rtnl(*fp);
+		     f;
+		     fp = &f->next, f = rcu_dereference_bh_rtnl(*fp))
 			if (f->key == key)
 				return &f->result;
 	}
@@ -77,7 +85,7 @@ tcindex_lookup(struct tcindex_data *p, u16 key)
 static int tcindex_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			    struct tcf_result *res)
 {
-	struct tcindex_data *p = PRIV(tp);
+	struct tcindex_data *p = rcu_dereference(tp->root);
 	struct tcindex_filter_result *f;
 	int key = (skb->tc_index & p->mask) >> p->shift;
 
@@ -132,49 +140,113 @@ static int tcindex_init(struct tcf_proto *tp)
 	p->hash = DEFAULT_HASH_SIZE;
 	p->fall_through = 1;
 
-	tp->root = p;
+	rcu_assign_pointer(tp->root, p);
 	return 0;
 }
 
+static void tcindex_walk(struct tcf_proto *tp, struct tcf_walker *walker)
+{
+	struct tcindex_data *p = PRIV(tp);
+	struct tcindex_filter *f, *next;
+	int i;
+
+	pr_debug("tcindex_walk(tp %p,walker %p),p %p\n", tp, walker, p);
+	if (p->perfect) {
+		for (i = 0; i < p->hash; i++) {
+			if (!p->perfect[i].res.class)
+				continue;
+			if (walker->count >= walker->skip) {
+				if (walker->fn(tp,
+				    (unsigned long) (p->perfect+i), walker)
+				     < 0) {
+					walker->stop = 1;
+					return;
+				}
+			}
+			walker->count++;
+		}
+	}
+	if (!p->h)
+		return;
+	for (i = 0; i < p->hash; i++) {
+		for (f = rtnl_dereference(p->h[i]); f; f = next) {
+			next = rtnl_dereference(f->next);
+			if (walker->count >= walker->skip) {
+				if (walker->fn(tp, (unsigned long) &f->result,
+				    walker) < 0) {
+					walker->stop = 1;
+					return;
+				}
+			}
+			walker->count++;
+		}
+	}
+}
 
 static int
-__tcindex_delete(struct tcf_proto *tp, unsigned long arg, int lock)
+tcindex_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct tcindex_data *p = PRIV(tp);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) arg;
+	struct tcindex_filter __rcu **walk;
 	struct tcindex_filter *f = NULL;
 
-	pr_debug("tcindex_delete(tp %p,arg 0x%lx),p %p,f %p\n", tp, arg, p, f);
+	pr_debug("tcindex_delete(tp %p,arg 0x%lx),p %p\n", tp, arg, p);
 	if (p->perfect) {
 		if (!r->res.class)
 			return -ENOENT;
 	} else {
 		int i;
-		struct tcindex_filter **walk = NULL;
 
-		for (i = 0; i < p->hash; i++)
-			for (walk = p->h+i; *walk; walk = &(*walk)->next)
-				if (&(*walk)->result == r)
+		for (i = 0; i < p->hash; i++) {
+			walk = p->h + i;
+			for (f = rtnl_dereference(*walk); f;
+			     walk = &f->next, f = rtnl_dereference(*walk)) {
+				if (&f->result == r)
 					goto found;
+			}
+		}
 		return -ENOENT;
 
 found:
-		f = *walk;
-		if (lock)
-			tcf_tree_lock(tp);
-		*walk = f->next;
-		if (lock)
-			tcf_tree_unlock(tp);
+		rcu_assign_pointer(*walk, rtnl_dereference(f->next));
 	}
 	tcf_unbind_filter(tp, &r->res);
 	tcf_exts_destroy(tp, &r->exts);
-	kfree(f);
+	if (f)
+		kfree_rcu(f, rcu);
 	return 0;
 }
 
-static int tcindex_delete(struct tcf_proto *tp, unsigned long arg)
+static int tcindex_destroy_element(struct tcf_proto *tp,
+				   unsigned long arg,
+				   struct tcf_walker *walker)
+{
+	return tcindex_delete(tp, arg);
+}
+
+static void __tcindex_destroy(struct rcu_head *head)
 {
-	return __tcindex_delete(tp, arg, 1);
+	struct tcindex_data *p = container_of(head, struct tcindex_data, rcu);
+
+	kfree(p->perfect);
+	kfree(p->h);
+	kfree(p);
+}
+
+static void tcindex_destroy(struct tcf_proto *tp)
+{
+	struct tcindex_data *p = PRIV(tp);
+	struct tcf_walker walker;
+
+	pr_debug("%s(tp %p),p %p\n", __func__, tp, p);
+	walker.count = 0;
+	walker.skip = 0;
+	walker.fn = &tcindex_destroy_element;
+	tcindex_walk(tp, &walker);
+
+	rcu_assign_pointer(tp->root, NULL);
+	call_rcu(&p->rcu, __tcindex_destroy);
 }
 
 static inline int
@@ -191,6 +263,14 @@ static const struct nla_policy tcindex_policy[TCA_TCINDEX_MAX + 1] = {
 	[TCA_TCINDEX_CLASSID]		= { .type = NLA_U32 },
 };
 
+static void __tcindex_partial_destroy(struct rcu_head *head)
+{
+	struct tcindex_data *p = container_of(head, struct tcindex_data, rcu);
+
+	kfree(p->perfect);
+	kfree(p);
+}
+
 static int
 tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		  u32 handle, struct tcindex_data *p,
@@ -200,7 +280,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	int err, balloc = 0;
 	struct tcindex_filter_result new_filter_result, *old_r = r;
 	struct tcindex_filter_result cr;
-	struct tcindex_data cp;
+	struct tcindex_data *cp, *oldp;
 	struct tcindex_filter *f = NULL; /* make gcc behave */
 	struct tcf_exts e;
 
@@ -209,7 +289,27 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	if (err < 0)
 		return err;
 
-	memcpy(&cp, p, sizeof(cp));
+	/* tcindex_data attributes must look atomic to classifier/lookup so
+	 * allocate new tcindex data and RCU assign it onto root. Keeping
+	 * perfect hash and hash pointers from old data.
+	 */
+	cp = kzalloc(sizeof(cp), GFP_KERNEL);
+	if (!cp)
+		return -ENOMEM;
+
+	cp->mask = p->mask;
+	cp->shift = p->shift;
+	cp->hash = p->hash;
+	cp->alloc_hash = p->alloc_hash;
+	cp->fall_through = p->fall_through;
+	cp->tp = tp;
+
+	if (p->perfect) {
+		cp->perfect = kcalloc(cp->hash, sizeof(*r), GFP_KERNEL);
+		memcpy(cp->perfect, p->perfect, sizeof(*r) * cp->hash);
+	}
+	cp->h = p->h;
+
 	memset(&new_filter_result, 0, sizeof(new_filter_result));
 	tcf_exts_init(&new_filter_result.exts, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
 
@@ -221,71 +321,82 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	}
 
 	if (tb[TCA_TCINDEX_HASH])
-		cp.hash = nla_get_u32(tb[TCA_TCINDEX_HASH]);
+		cp->hash = nla_get_u32(tb[TCA_TCINDEX_HASH]);
 
 	if (tb[TCA_TCINDEX_MASK])
-		cp.mask = nla_get_u16(tb[TCA_TCINDEX_MASK]);
+		cp->mask = nla_get_u16(tb[TCA_TCINDEX_MASK]);
 
 	if (tb[TCA_TCINDEX_SHIFT])
-		cp.shift = nla_get_u32(tb[TCA_TCINDEX_SHIFT]);
+		cp->shift = nla_get_u32(tb[TCA_TCINDEX_SHIFT]);
 
 	err = -EBUSY;
+
 	/* Hash already allocated, make sure that we still meet the
 	 * requirements for the allocated hash.
 	 */
-	if (cp.perfect) {
-		if (!valid_perfect_hash(&cp) ||
-		    cp.hash > cp.alloc_hash)
+	if (cp->perfect) {
+		if (!valid_perfect_hash(cp) ||
+		    cp->hash > cp->alloc_hash)
 			goto errout;
-	} else if (cp.h && cp.hash != cp.alloc_hash)
+	} else if (cp->h && cp->hash != cp->alloc_hash)
 		goto errout;
 
 	err = -EINVAL;
 	if (tb[TCA_TCINDEX_FALL_THROUGH])
-		cp.fall_through = nla_get_u32(tb[TCA_TCINDEX_FALL_THROUGH]);
+		cp->fall_through = nla_get_u32(tb[TCA_TCINDEX_FALL_THROUGH]);
 
-	if (!cp.hash) {
+	if (!cp->hash) {
 		/* Hash not specified, use perfect hash if the upper limit
 		 * of the hashing index is below the threshold.
 		 */
-		if ((cp.mask >> cp.shift) < PERFECT_HASH_THRESHOLD)
-			cp.hash = (cp.mask >> cp.shift) + 1;
+		if ((cp->mask >> cp->shift) < PERFECT_HASH_THRESHOLD)
+			cp->hash = (cp->mask >> cp->shift) + 1;
 		else
-			cp.hash = DEFAULT_HASH_SIZE;
+			cp->hash = DEFAULT_HASH_SIZE;
 	}
 
-	if (!cp.perfect && !cp.h)
-		cp.alloc_hash = cp.hash;
+	if (!cp->perfect && cp->h)
+		cp->alloc_hash = cp->hash;
 
 	/* Note: this could be as restrictive as if (handle & ~(mask >> shift))
 	 * but then, we'd fail handles that may become valid after some future
 	 * mask change. While this is extremely unlikely to ever matter,
 	 * the check below is safer (and also more backwards-compatible).
 	 */
-	if (cp.perfect || valid_perfect_hash(&cp))
-		if (handle >= cp.alloc_hash)
+	if (cp->perfect || valid_perfect_hash(cp))
+		if (handle >= cp->alloc_hash)
 			goto errout;
 
 
 	err = -ENOMEM;
-	if (!cp.perfect && !cp.h) {
-		if (valid_perfect_hash(&cp)) {
-			cp.perfect = kcalloc(cp.hash, sizeof(*r), GFP_KERNEL);
-			if (!cp.perfect)
+	if (!cp->perfect && !cp->h) {
+		if (valid_perfect_hash(cp)) {
+			struct tcindex_filter_result *perfect;
+
+			perfect = kcalloc(cp->hash, sizeof(*r), GFP_KERNEL);
+			if (!perfect)
 				goto errout;
+			cp->perfect = perfect;
 			balloc = 1;
 		} else {
-			cp.h = kcalloc(cp.hash, sizeof(f), GFP_KERNEL);
-			if (!cp.h)
+			struct tcindex_filter __rcu **hash;
+
+			hash = kcalloc(cp->hash,
+				       sizeof(struct tcindex_filter *),
+				       GFP_KERNEL);
+
+			if (!hash)
 				goto errout;
+
+			cp->h = hash;
 			balloc = 2;
 		}
 	}
 
-	if (cp.perfect)
-		r = cp.perfect + handle;
+	if (cp->perfect)
+		r = cp->perfect + handle;
 	else
-		r = tcindex_lookup(&cp, handle) ? : &new_filter_result;
+		r = tcindex_lookup(cp, handle) ? : &new_filter_result;
 
 	if (r == &new_filter_result) {
 		f = kzalloc(sizeof(*f), GFP_KERNEL);
@@ -300,33 +411,41 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 
 	tcf_exts_change(tp, &cr.exts, &e);
 
-	tcf_tree_lock(tp);
 	if (old_r && old_r != r)
 		memset(old_r, 0, sizeof(*old_r));
 
-	memcpy(p, &cp, sizeof(cp));
+	oldp = p;
 	memcpy(r, &cr, sizeof(cr));
+	rcu_assign_pointer(tp->root, cp);
 
 	if (r == &new_filter_result) {
-		struct tcindex_filter **fp;
+		struct tcindex_filter *nfp;
+		struct tcindex_filter __rcu **fp;
 
 		f->key = handle;
 		f->result = new_filter_result;
 		f->next = NULL;
-		for (fp = p->h+(handle % p->hash); *fp; fp = &(*fp)->next)
-			/* nothing */;
-		*fp = f;
+
+		fp = p->h + (handle % p->hash);
+		for (nfp = rtnl_dereference(*fp);
+		     nfp;
+		     fp = &nfp->next, nfp = rtnl_dereference(*fp))
+				/* nothing */;
+
+		rcu_assign_pointer(*fp, f);
 	}
-	tcf_tree_unlock(tp);
 
+	if (oldp)
+		call_rcu(&oldp->rcu, __tcindex_partial_destroy);
 	return 0;
 
 errout_alloc:
 	if (balloc == 1)
-		kfree(cp.perfect);
+		kfree(cp->perfect);
 	else if (balloc == 2)
-		kfree(cp.h);
+		kfree(cp->h);
 errout:
+	kfree(cp);
 	tcf_exts_destroy(tp, &e);
 	return err;
 }
@@ -357,71 +476,6 @@ tcindex_change(struct net *net, struct sk_buff *in_skb,
 				 tca[TCA_RATE]);
 }
 
-
-static void tcindex_walk(struct tcf_proto *tp, struct tcf_walker *walker)
-{
-	struct tcindex_data *p = PRIV(tp);
-	struct tcindex_filter *f, *next;
-	int i;
-
-	pr_debug("tcindex_walk(tp %p,walker %p),p %p\n", tp, walker, p);
-	if (p->perfect) {
-		for (i = 0; i < p->hash; i++) {
-			if (!p->perfect[i].res.class)
-				continue;
-			if (walker->count >= walker->skip) {
-				if (walker->fn(tp,
-				    (unsigned long) (p->perfect+i), walker)
-				     < 0) {
-					walker->stop = 1;
-					return;
-				}
-			}
-			walker->count++;
-		}
-	}
-	if (!p->h)
-		return;
-	for (i = 0; i < p->hash; i++) {
-		for (f = p->h[i]; f; f = next) {
-			next = f->next;
-			if (walker->count >= walker->skip) {
-				if (walker->fn(tp, (unsigned long) &f->result,
-				    walker) < 0) {
-					walker->stop = 1;
-					return;
-				}
-			}
-			walker->count++;
-		}
-	}
-}
-
-
-static int tcindex_destroy_element(struct tcf_proto *tp,
-    unsigned long arg, struct tcf_walker *walker)
-{
-	return __tcindex_delete(tp, arg, 0);
-}
-
-
-static void tcindex_destroy(struct tcf_proto *tp)
-{
-	struct tcindex_data *p = PRIV(tp);
-	struct tcf_walker walker;
-
-	pr_debug("tcindex_destroy(tp %p),p %p\n", tp, p);
-	walker.count = 0;
-	walker.skip = 0;
-	walker.fn = &tcindex_destroy_element;
-	tcindex_walk(tp, &walker);
-	kfree(p->perfect);
-	kfree(p->h);
-	kfree(p);
-	tp->root = NULL;
-}
-
-
 static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
     struct sk_buff *skb, struct tcmsg *t)
 {
@@ -448,15 +502,18 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 		nla_nest_end(skb, nest);
 	} else {
 		if (p->perfect) {
-			t->tcm_handle = r-p->perfect;
+			t->tcm_handle = r - p->perfect;
 		} else {
 			struct tcindex_filter *f;
+			struct tcindex_filter __rcu **fp;
 			int i;
 
 			t->tcm_handle = 0;
 			for (i = 0; !t->tcm_handle && i < p->hash; i++) {
-				for (f = p->h[i]; !t->tcm_handle && f;
-				     f = f->next) {
+				fp = &p->h[i];
+				for (f = rtnl_dereference(*fp);
+				     !t->tcm_handle && f;
+				     fp = &f->next, f = rtnl_dereference(*fp)) {
 					if (&f->result == r)
 						t->tcm_handle = f->key;
 				}
