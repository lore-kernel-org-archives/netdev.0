From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Mon, 3 Jan 2005 13:56:35 +0100
Message-ID: <20050103125635.GB26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Jamal et al,

I attached 4 patches of a first ematch implementation. Comments
and suggestions very much appreciated. Compiles but untested.

Patch 1: ematch API

API visible to classifier:

tcf_em_tree_validate(tp, tlv, tree)
  tlv: ematches TLV
  tree: temporary struct tcf_ematch_tree

  Validates the data in the TLV and builds the ematch tree
  upon the temporary variable.

tcf_em_tree_change(tp, dst, src)
  dst: destination ematch tree (from classifier private data)
  src: source ematch tree (temporary tree from _validate)

  Replaces the ematch tree in the classifier with the temporary
  tree.
 
tcf_em_tree_destroy(tp, tree)
  Destroys an ematch tree

tcf_em_tree_dump(skb, tree, tlv_type)
  tlv_type: T of ematches TLV (classifier specific)

  Dumps the ematch tree to the skb with given tlv_type.

tcf_em_tree_match(skb, tree, res)
  res: struct tcf_result *

  Macro returning 1 if no ematches are configured, otherwise
  the tree is evaulated and 1 is returned if the tree matches.

The complete API is also visible if ematch is not configured but
will result in empty macros/structures. Those need to be
improved though.

API visible to ematches:

  tcf_em_register(ops)
  tcf_em_unregister(ops)

  ematches must at least provide the following callbacks:

  change, match
 
  Optional callbacks are: destroy, dump  

  kind must be set to a unique ID, i thought about declaring
  1..2^16 to ematches within the mainline tree and have the
  rest declared as to be used for private use to avoid collisions.

Patch 2: u32 ematch

  Is an ematch based on the existing u32 match but allows to
  specify the layer and is able to read u32 values if alignment
  does not allow direct access. Additionally it supports
  the operands, eq, lt, gt. It is a few ticks slower than the
  existing match but worth it. However, it does not support
  the neat nexthdr via hashing as u32 does which is the main
  problem before u32 can make proper use of it.

Patch 3: nbyte ematch

  Compares n bytes at specified offset. To be used for IPv6
  address matches to avoid 4 ANDed u32 matches.

Patch 4: Basic Classifier

  This is the most basic classifier possible doing nothing more
  than executing extensions and ematches. It follows the
  architecture of u32 and fw by storing a filter list in tp->root.
  This eventually makes fw obsolete once meta ematch is available.
  I didn't copy the u32/fw code but rather made use of the list.h.

pskbs are completely unhandled so far as I'm still not sure
how to do it properly.

Cheers

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="01_ematch.diff"

diff -Nru linux-2.6.10-bk4.orig/include/linux/pkt_cls.h linux-2.6.10-bk4/include/linux/pkt_cls.h
--- linux-2.6.10-bk4.orig/include/linux/pkt_cls.h	2005-01-02 21:39:16.000000000 +0100
+++ linux-2.6.10-bk4/include/linux/pkt_cls.h	2005-01-02 21:31:48.000000000 +0100
@@ -319,4 +319,47 @@
 
 #define TCA_TCINDEX_MAX     (__TCA_TCINDEX_MAX - 1)
 
+struct tcf_ematch_tree_hdr
+{
+	__u16		nmatches;
+	__u16		progid;
+};
+
+enum
+{
+	TCA_EMATCH_TREE_UNSPEC,
+	TCA_EMATCH_TREE_HDR,
+	TCA_EMATCH_TREE_LIST,
+	__TCA_EMATCH_TREE_MAX
+};
+#define TCA_EMATCH_TREE_MAX (__TCA_EMATCH_TREE_MAX - 1)
+
+struct tcf_ematch_hdr
+{
+	__u16		handle;
+	__u16		matchID;
+	__u16		kind;
+	__u8		flags;
+	__u8		pad; /* currently unused */
+};
+
+enum
+{
+	TCF_EM_CONTAINER,
+	__TCF_EM_MAX
+};
+
+#define TCF_EM_REL_MASK	3
+#define TCF_EM_REL_VALID(v) \
+	(!(((v) & TCF_EM_REL_MASK) == TCF_EM_REL_MASK))
+#define TCF_EM_LAST_KEY(v) (!((v) & TCF_EM_REL_MASK))
+
+#define TCF_EM_REL_OBVIOUS(v, r) (TCF_EM_LAST_KEY(v) || \
+	(!(r) && ((v) & TCF_EM_REL_AND)) || ((r) && ((v) & TCF_EM_REL_OR)))
+	    
+#define TCF_EM_REL_END	(1<<0)
+#define TCF_EM_REL_AND	(1<<1)
+#define TCF_EM_REL_OR	(1<<2)
+#define TCF_EM_INVERT	(1<<3)
+
 #endif
diff -Nru linux-2.6.10-bk4.orig/include/linux/rtnetlink.h linux-2.6.10-bk4/include/linux/rtnetlink.h
--- linux-2.6.10-bk4.orig/include/linux/rtnetlink.h	2005-01-02 21:39:16.000000000 +0100
+++ linux-2.6.10-bk4/include/linux/rtnetlink.h	2005-01-02 21:32:46.000000000 +0100
@@ -779,6 +779,11 @@
 		 goto rtattr_failure; \
    	__rta_fill(skb, attrtype, attrlen, data); }) 
 
+#define RTA_PUT_NOHDR(skb, attrlen, data) \
+({	if (unlikely(skb_tailroom(skb) < (int)(attrlen))) \
+		goto rtattr_failure; \
+	memcpy(skb_put(skb, RTA_ALIGN(attrlen)), data, attrlen); })
+		
 static inline struct rtattr *
 __rta_reserve(struct sk_buff *skb, int attrtype, int attrlen)
 {
diff -Nru linux-2.6.10-bk4.orig/include/net/pkt_cls.h linux-2.6.10-bk4/include/net/pkt_cls.h
--- linux-2.6.10-bk4.orig/include/net/pkt_cls.h	2005-01-02 21:39:16.000000000 +0100
+++ linux-2.6.10-bk4/include/net/pkt_cls.h	2005-01-02 21:33:21.000000000 +0100
@@ -149,6 +149,75 @@
 extern int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
 	                       struct tcf_ext_map *map);
 
+#ifdef CONFIG_NET_EMATCH
+
+struct tcf_ematch_ops;
+
+struct tcf_ematch
+{
+	struct tcf_ematch_hdr	hdr;
+	struct tcf_ematch_ops * ops;
+	unsigned long		data;
+};
+
+struct tcf_ematch_tree
+{
+	struct tcf_ematch_tree_hdr hdr;
+	struct tcf_ematch *	matches;
+	
+};
+
+#define em_lookup_match(t, i) (&(t)->matches[(i)])
+
+struct tcf_ematch_ops
+{
+	int		kind;
+
+	int	      (*change)(struct tcf_proto *tp, void *data,
+				int len, struct tcf_ematch *m);
+
+	int	      (*match)(struct sk_buff *skb, struct tcf_ematch *m);
+	int	      (*destroy)(struct tcf_proto *tp, struct tcf_ematch *m);
+	int	      (*dump)(struct sk_buff *skb, struct tcf_ematch *m);
+
+	struct module *         owner;
+	struct list_head	link;
+};
+
+extern int tcf_em_register(struct tcf_ematch_ops *);
+extern int tcf_em_unregister(struct tcf_ematch_ops *);
+extern int tcf_em_tree_validate(struct tcf_proto *, struct rtattr *,
+				struct tcf_ematch_tree *);
+extern void tcf_em_tree_destroy(struct tcf_proto *, struct tcf_ematch_tree *);
+extern int tcf_em_tree_dump(struct sk_buff *, struct tcf_ematch_tree *, int);
+extern int __tcf_em_tree_match(struct sk_buff *, struct tcf_ematch_tree *);
+
+static inline void
+tcf_em_tree_change(struct tcf_proto *tp, struct tcf_ematch_tree *dst,
+		   struct tcf_ematch_tree *src)
+{
+	tcf_tree_lock(tp);
+	memcpy(dst, src, sizeof(*dst));
+	tcf_tree_unlock(tp);
+}
+
+#define tcf_em_tree_match(skb, t) \
+	((t)->hdr.nmatches ? __tcf_em_tree_match(skb, t) : 1)
+
+#else /* CONFIG_NET_EMATCH */
+
+struct tcf_ematch_tree
+{
+};
+
+#define tcf_em_tree_validate(tp, tb, t) do { } while(0)
+#define tcf_em_tree_destroy(tp, t) do { } while(0)
+#define tcf_em_tree_dump(skb, t, tlv) do { } while(0)
+#define tcf_em_tree_change(tp, dst, src) do { } while(0)
+#define tcf_em_tree_match(skb, t) do { } while(0)
+
+#endif /* CONFIG_NET_EMATCH */
+
 #ifdef CONFIG_NET_CLS_IND
 static inline int
 tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
diff -Nru linux-2.6.10-bk4.orig/net/sched/Kconfig linux-2.6.10-bk4/net/sched/Kconfig
--- linux-2.6.10-bk4.orig/net/sched/Kconfig	2005-01-02 21:39:16.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/Kconfig	2005-01-02 21:31:44.000000000 +0100
@@ -375,6 +375,12 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called cls_rsvp6.
 
+config NET_EMATCH
+	bool "Extended Matches"
+	depends on NET_CLS
+	---help---
+	  TODO
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.10-bk4.orig/net/sched/Makefile linux-2.6.10-bk4/net/sched/Makefile
--- linux-2.6.10-bk4.orig/net/sched/Makefile	2005-01-02 21:39:16.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/Makefile	2005-01-02 21:31:48.000000000 +0100
@@ -33,3 +33,4 @@
 obj-$(CONFIG_NET_CLS_RSVP)	+= cls_rsvp.o
 obj-$(CONFIG_NET_CLS_TCINDEX)	+= cls_tcindex.o
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
+obj-$(CONFIG_NET_EMATCH)	+= ematch.o
diff -Nru linux-2.6.10-bk4.orig/net/sched/ematch.c linux-2.6.10-bk4/net/sched/ematch.c
--- linux-2.6.10-bk4.orig/net/sched/ematch.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/ematch.c	2005-01-01 23:32:13.000000000 +0100
@@ -0,0 +1,300 @@
+/*
+ * net/sched/ematch.c	Extended Match API
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/rtnetlink.h>
+#include <linux/skbuff.h>
+#include <net/pkt_cls.h>
+
+#define EMATCH_STACK_SIZE 32
+
+static LIST_HEAD(ematch_ops);
+static rwlock_t ematch_mod_lock = RW_LOCK_UNLOCKED;
+
+static inline struct tcf_ematch_ops *
+tcf_em_lookup(u16 kind)
+{
+	struct tcf_ematch_ops *e = NULL;
+
+	read_lock(&ematch_mod_lock);
+	list_for_each_entry(e, &ematch_ops, link) {
+		if (kind == e->kind) {
+			if (!try_module_get(e->owner))
+				e = NULL;
+			break;
+		}
+	}
+	read_unlock(&ematch_mod_lock);
+
+	return e;
+}
+
+int tcf_em_register(struct tcf_ematch_ops *ops)
+{
+	int err = -EEXIST;
+	struct tcf_ematch_ops *e;
+
+	write_lock(&ematch_mod_lock);
+	list_for_each_entry(e, &ematch_ops, link)
+		if (ops->kind == e->kind)
+			goto errout;
+
+	list_add_tail(&ops->link, &ematch_ops);
+	err = 0;
+errout:
+	write_unlock(&ematch_mod_lock);
+	return err;
+}
+
+int tcf_em_unregister(struct tcf_ematch_ops *ops)
+{
+	int err = 0;
+	struct tcf_ematch_ops *e;
+
+	write_lock(&ematch_mod_lock);
+	list_for_each_entry(e, &ematch_ops, link) {
+		if (e == ops) {
+			list_del(&e->link);
+			goto out;
+		}
+	}
+
+	err = -ENOENT;
+out:
+	write_unlock(&ematch_mod_lock);
+	return err;
+}
+
+static int tcf_em_validate(struct tcf_proto *tp, struct tcf_ematch_tree_hdr *th,
+			   struct tcf_ematch *m, struct rtattr *rta)
+{
+	int err = -EINVAL;
+	struct tcf_ematch_hdr *mh = RTA_DATA(rta);
+	int datalen = RTA_PAYLOAD(rta) - sizeof(*mh);
+	void *data = (void *) data + sizeof(*mh);
+
+	if (!TCF_EM_REL_VALID(mh->flags))
+		goto errout;
+
+	memcpy(&m->hdr, mh, sizeof(*mh));
+
+	if (mh->kind == TCF_EM_CONTAINER) {
+		u32 ref;
+
+		if (datalen < sizeof(ref))
+			goto errout;
+		ref = *(u32 *) data;
+		if (ref >= th->nmatches)
+			goto errout;
+		m->data = ref;
+	} else {
+		struct tcf_ematch_ops *ops = tcf_em_lookup(mh->kind);
+
+		if (ops == NULL) {
+			err = -ENOENT;
+			goto errout;
+		}
+
+		if (ops->change) {
+			err = ops->change(tp, data, datalen, m);
+			if (err < 0)
+				goto errout;
+		}
+	}
+
+	err = 0;
+errout:
+	return err;
+}
+
+int tcf_em_tree_validate(struct tcf_proto *tp, struct rtattr *rta,
+			 struct tcf_ematch_tree *tree)
+{
+	int i, len, mlen, err = -EINVAL;
+	struct rtattr *m, *tb[TCA_EMATCH_TREE_MAX];
+	struct tcf_ematch_tree_hdr *th;
+
+	if (!rta || rtattr_parse_nested(tb, TCA_EMATCH_TREE_MAX, rta) < 0)
+		goto errout;
+
+	if (RTA_PAYLOAD(tb[TCA_EMATCH_TREE_HDR-1]) < sizeof(*th) ||
+	    RTA_PAYLOAD(tb[TCA_EMATCH_TREE_LIST-1]) < sizeof(*m))
+		goto errout;
+
+	th = RTA_DATA(tb[TCA_EMATCH_TREE_HDR-1]);
+	m = RTA_DATA(tb[TCA_EMATCH_TREE_LIST-1]);
+	len = RTA_PAYLOAD(tb[TCA_EMATCH_TREE_LIST-1]);
+	mlen = th->nmatches * sizeof(struct tcf_ematch);
+
+	memcpy(&tree->hdr, th, sizeof(*th));
+
+	tree->matches = kmalloc(mlen, GFP_KERNEL);
+	if (tree->matches == NULL)
+		goto errout;
+	memset(tree->matches, 0, mlen);
+
+	for (i = 0; RTA_OK(m, len); i++) {
+		if (rta->rta_type != (i+1) || i >= th->nmatches ||
+		    RTA_PAYLOAD(rta) < sizeof(struct tcf_ematch_hdr)) {
+			err = -EINVAL;
+			goto errout_abort;
+		}
+
+		err = tcf_em_validate(tp, th, em_lookup_match(tree, i), rta);
+		if (err < 0)
+			goto errout_abort;
+
+		m = RTA_NEXT(m, len);
+	}
+
+	if (i != th->nmatches) {
+		err = -EINVAL;
+		goto errout_abort;
+	}
+		
+
+	err = 0;
+errout:
+	return err;
+
+errout_abort:
+	tcf_em_tree_destroy(tp, tree);
+	return err;
+}
+
+
+void tcf_em_tree_destroy(struct tcf_proto *tp, struct tcf_ematch_tree *t)
+{
+	int i;
+
+	if (t->matches == NULL)
+		return;
+
+	for (i = 0; i < t->hdr.nmatches; i++) {
+		struct tcf_ematch *m = em_lookup_match(t, i);
+		if (m->ops) {
+			if (m->ops->destroy)
+				m->ops->destroy(tp, m);
+			module_put(m->ops->owner);
+		}
+	}
+	
+	kfree(t->matches);
+}
+
+int tcf_em_tree_dump(struct sk_buff *skb, struct tcf_ematch_tree *t, int tlv)
+{
+	int i;
+	struct rtattr * p_rta = (struct rtattr*) skb->tail;
+	struct rtattr * pm_rta;
+
+	RTA_PUT(skb, tlv, 0, NULL);
+	RTA_PUT(skb, TCA_EMATCH_TREE_HDR, sizeof(t->hdr), &t->hdr);
+
+	pm_rta = (struct rtattr *) skb->tail;
+	RTA_PUT(skb, TCA_EMATCH_TREE_LIST, 0, NULL);
+
+	for (i = 0; i < t->hdr.nmatches; i++) {
+		struct rtattr * pd_rta = (struct rtattr*) skb->tail;
+		struct tcf_ematch *m = em_lookup_match(t, i);
+
+		RTA_PUT(skb, i+1, sizeof(m->hdr), &m->hdr);
+		if (m->ops->dump && m->ops->dump(skb, m) < 0)
+			goto rtattr_failure;
+		pd_rta->rta_len = skb->tail - (u8*) pd_rta;
+	}
+
+	pm_rta->rta_len = skb->tail - (u8*)pm_rta;
+	p_rta->rta_len = skb->tail - (u8*)p_rta;
+	return 0;
+rtattr_failure:
+	return -1;
+}
+
+static inline int tcf_em_match(struct sk_buff *skb, struct tcf_ematch *m)
+{
+	int r = 0;
+
+	if (m->ops->match)
+		r = m->ops->match(skb, m);
+
+	return m->hdr.flags & TCF_EM_INVERT ? !r : r;
+}
+
+/* Do not use this function directly, use tcf_em_tree_match */
+int __tcf_em_tree_match(struct sk_buff *skb, struct tcf_ematch_tree *t)
+{
+	int i = 0, n = 0, r = 0;
+	struct tcf_ematch *m;
+	int stack[EMATCH_STACK_SIZE];
+
+	memset(stack, 0, sizeof(stack));
+
+proceed:
+	while (n < t->hdr.nmatches) {
+		m = em_lookup_match(t, n);
+
+		if (m->hdr.kind == TCF_EM_CONTAINER) {
+			if (unlikely(i >= EMATCH_STACK_SIZE)) {
+				if (net_ratelimit())
+					printk("Local stack overflow, " \
+					    "increase EMATCH_STACK_SIZE\n");
+				return -1;
+			}
+
+			if (unlikely(m->data <= n)) {
+				if (net_ratelimit())
+					printk("Detected backward precedence " \
+					    "jump, fix your filter.\n");
+				return -1;
+			}
+
+			stack[i++] = n;
+			n = m->data;
+			continue;
+		}
+
+		r = tcf_em_match(skb, m);
+		if (TCF_EM_REL_OBVIOUS(m->hdr.flags, r))
+			break;
+		n++;
+	}
+
+pop_stack:
+	if (i > 0) {
+		n = stack[--i];
+		m = em_lookup_match(t, n);
+
+		if (TCF_EM_REL_OBVIOUS(m->hdr.flags, r))
+			goto pop_stack;
+		else {
+			n++;
+			goto proceed;
+		}
+	}
+
+	return r;
+}
+
+EXPORT_SYMBOL(tcf_em_register);
+EXPORT_SYMBOL(tcf_em_unregister);
+EXPORT_SYMBOL(tcf_em_tree_validate);
+EXPORT_SYMBOL(tcf_em_tree_destroy);
+EXPORT_SYMBOL(tcf_em_tree_dump);
+EXPORT_SYMBOL(__tcf_em_tree_match);
+

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="02_em_u32.diff"

diff -Nru linux-2.6.10-bk4.orig/include/linux/pkt_cls.h linux-2.6.10-bk4/include/linux/pkt_cls.h
--- linux-2.6.10-bk4.orig/include/linux/pkt_cls.h	2005-01-02 22:37:46.000000000 +0100
+++ linux-2.6.10-bk4/include/linux/pkt_cls.h	2005-01-02 22:37:39.000000000 +0100
@@ -346,6 +346,7 @@
 enum
 {
 	TCF_EM_CONTAINER,
+	TCF_EM_U32,
 	__TCF_EM_MAX
 };
 
@@ -362,4 +363,28 @@
 #define TCF_EM_REL_OR	(1<<2)
 #define TCF_EM_INVERT	(1<<3)
 
+struct tcf_em_u32
+{
+	__u32		val;
+	__u32		mask;
+	__u16		off;
+	__u8		align;
+	__u8		layer:4;
+	__u8		opnd:4;
+};
+
+enum
+{
+	TCF_EM_ALIGN_U8  = 1,
+	TCF_EM_ALIGN_U16 = 2,
+	TCF_EM_ALIGN_U32 = 4
+};
+
+enum
+{
+	TCF_EM_OPND_EQ,
+	TCF_EM_OPND_GT,
+	TCF_EM_OPND_LT
+};
+
 #endif
diff -Nru linux-2.6.10-bk4.orig/include/net/pkt_cls.h linux-2.6.10-bk4/include/net/pkt_cls.h
--- linux-2.6.10-bk4.orig/include/net/pkt_cls.h	2005-01-02 22:37:46.000000000 +0100
+++ linux-2.6.10-bk4/include/net/pkt_cls.h	2005-01-02 22:23:24.000000000 +0100
@@ -218,6 +218,36 @@
 
 #endif /* CONFIG_NET_EMATCH */
 
+static inline u32 tcf_read_bucket(u8 *ptr, u8 align)
+{
+	switch (align) {
+		case TCF_EM_ALIGN_U8:
+			return *ptr;
+		case TCF_EM_ALIGN_U16:
+			return (*ptr << 8) | *(ptr+1);
+		case TCF_EM_ALIGN_U32:
+			return (*ptr << 24) | (*(ptr+1) << 16) |
+				(*(ptr+2) << 8) | *(ptr+3);
+	}
+	return 0;
+}
+
+static inline u8 * tcf_get_base_ptr(struct sk_buff *skb, u8 layer)
+{
+	switch (layer) {
+		case 0:
+			return skb->data;
+		case 1:
+			return skb->nh.raw;
+		case 2:
+			return skb->h.raw;
+	}
+	return NULL;
+}
+
+#define tcf_valid_offset(skb, ptr, off, len) \
+	((ptr + off + len) < skb->tail && (ptr + off) > skb->head)
+
 #ifdef CONFIG_NET_CLS_IND
 static inline int
 tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
diff -Nru linux-2.6.10-bk4.orig/net/sched/Kconfig linux-2.6.10-bk4/net/sched/Kconfig
--- linux-2.6.10-bk4.orig/net/sched/Kconfig	2005-01-02 22:37:46.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/Kconfig	2005-01-02 22:37:39.000000000 +0100
@@ -381,6 +381,12 @@
 	---help---
 	  TODO
 
+config NET_EMATCH_U32
+	tristate "U32"
+	depends on NET_EMATCH
+	---help---
+	  TODO
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.10-bk4.orig/net/sched/Makefile linux-2.6.10-bk4/net/sched/Makefile
--- linux-2.6.10-bk4.orig/net/sched/Makefile	2005-01-02 22:37:46.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/Makefile	2005-01-02 22:37:39.000000000 +0100
@@ -34,3 +34,4 @@
 obj-$(CONFIG_NET_CLS_TCINDEX)	+= cls_tcindex.o
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
+obj-$(CONFIG_NET_EMATCH_U32)	+= em_u32.o
diff -Nru linux-2.6.10-bk4.orig/net/sched/em_u32.c linux-2.6.10-bk4/net/sched/em_u32.c
--- linux-2.6.10-bk4.orig/net/sched/em_u32.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/em_u32.c	2005-01-02 22:38:27.000000000 +0100
@@ -0,0 +1,98 @@
+/*
+ * net/sched/em_u32.c	U32 ematch
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/rtnetlink.h>
+#include <linux/skbuff.h>
+#include <net/pkt_cls.h>
+
+static int em_u32_change(struct tcf_proto *tp, void *data, int len,
+			   struct tcf_ematch *m)
+{
+	if (len != sizeof(struct tcf_em_u32))
+		return -EINVAL;
+
+	m->data = (unsigned long) kmalloc(len, GFP_KERNEL);
+	if (!m->data)
+		return -ENOBUFS;
+
+	memcpy((void *) m->data, data, len);
+	return 0;
+}
+
+static int em_u32_match(struct sk_buff *skb, struct tcf_ematch *m)
+{
+	struct tcf_em_u32 *u = (struct tcf_em_u32 *) m->data;
+	u8 *ptr = tcf_get_base_ptr(skb, u->layer);
+	u32 v;
+
+	if (unlikely(!tcf_valid_offset(skb, ptr, u->off, u->align)))
+		return 0;
+
+	v = tcf_read_bucket(ptr + u->off, u->align) & u->mask;
+
+	switch (u->opnd) {
+		case TCF_EM_OPND_EQ:
+			return v == u->val;
+		case TCF_EM_OPND_LT:
+			return v < u->val;
+		case TCF_EM_OPND_GT:
+			return v > u->val;
+	}
+	
+	return 0;
+}
+
+static int em_u32_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
+{
+	kfree((void *) m->data);
+	return 0;
+}
+
+static int em_u32_dump(struct sk_buff *skb, struct tcf_ematch *m)
+{
+	RTA_PUT_NOHDR(skb, sizeof(struct tcf_em_u32), (void *) m->data);
+	return 0;
+rtattr_failure:
+	return -1;
+}
+
+static struct tcf_ematch_ops em_u32_ops = {
+	.kind	  = TCF_EM_U32,
+	.change	  = em_u32_change,
+	.match	  = em_u32_match,
+	.destroy  = em_u32_destroy,
+	.dump	  = em_u32_dump,
+	.owner	  = THIS_MODULE,
+	.link	  = LIST_HEAD_INIT(em_u32_ops.link)
+};
+
+static int __init init_em_u32(void)
+{
+	return tcf_em_register(&em_u32_ops);
+}
+
+static void __exit exit_em_u32(void) 
+{
+	tcf_em_unregister(&em_u32_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_em_u32);
+module_exit(exit_em_u32);
+

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="03_em_nbyte.diff"

diff -Nru linux-2.6.10-bk4.orig/include/linux/pkt_cls.h linux-2.6.10-bk4/include/linux/pkt_cls.h
--- linux-2.6.10-bk4.orig/include/linux/pkt_cls.h	2005-01-02 22:44:16.000000000 +0100
+++ linux-2.6.10-bk4/include/linux/pkt_cls.h	2005-01-02 22:44:31.000000000 +0100
@@ -347,6 +347,7 @@
 {
 	TCF_EM_CONTAINER,
 	TCF_EM_U32,
+	TCF_EM_NBYTE,
 	__TCF_EM_MAX
 };
 
@@ -387,4 +388,11 @@
 	TCF_EM_OPND_LT
 };
 
+struct tcf_em_nbyte
+{
+	__u16		off;
+	__u16		len:12;
+	__u8		layer:4;
+};
+
 #endif
diff -Nru linux-2.6.10-bk4.orig/net/sched/Kconfig linux-2.6.10-bk4/net/sched/Kconfig
--- linux-2.6.10-bk4.orig/net/sched/Kconfig	2005-01-02 22:44:16.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/Kconfig	2005-01-02 22:44:31.000000000 +0100
@@ -387,6 +387,12 @@
 	---help---
 	  TODO
 
+config NET_EMATCH_NBYTE
+	tristate "N-Byte"
+	depends on NET_EMATCH
+	---help---
+	  TODO
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.10-bk4.orig/net/sched/Makefile linux-2.6.10-bk4/net/sched/Makefile
--- linux-2.6.10-bk4.orig/net/sched/Makefile	2005-01-02 22:44:16.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/Makefile	2005-01-02 22:44:31.000000000 +0100
@@ -35,3 +35,4 @@
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
 obj-$(CONFIG_NET_EMATCH_U32)	+= em_u32.o
+obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
diff -Nru linux-2.6.10-bk4.orig/net/sched/em_nbyte.c linux-2.6.10-bk4/net/sched/em_nbyte.c
--- linux-2.6.10-bk4.orig/net/sched/em_nbyte.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/em_nbyte.c	2005-01-02 22:54:20.000000000 +0100
@@ -0,0 +1,95 @@
+/*
+ * net/sched/em_nbyte.c	N-Byte ematch
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/rtnetlink.h>
+#include <linux/skbuff.h>
+#include <net/pkt_cls.h>
+
+struct nbyte_data
+{
+	struct tcf_em_nbyte	hdr;
+	char			pattern[0];
+};
+	
+static int em_nbyte_validate(struct tcf_proto *tp, void *data, int len,
+			     struct tcf_ematch *m)
+{
+	struct tcf_em_nbyte *n = data;
+
+	if (len < sizeof(*n) || len < (sizeof(*n) + n->len))
+		return -EINVAL;
+
+	m->data = (unsigned long) kmalloc(sizeof(*n) + n->len, GFP_KERNEL);
+	if (!m->data)
+		return -ENOBUFS;
+
+	memcpy((void *) m->data, data, sizeof(*n) + n->len);
+	return 0;
+}
+
+static int em_nbyte_match(struct sk_buff *skb, struct tcf_ematch *m)
+{
+	struct nbyte_data *d = (struct nbyte_data *) m->data;
+	u8 *ptr = tcf_get_base_ptr(skb, d->hdr.layer);
+
+	if (unlikely(!tcf_valid_offset(skb, ptr, d->hdr.off, d->hdr.len)))
+	    return 0;
+
+	return !memcmp(ptr + d->hdr.off, d->pattern, d->hdr.len);
+}
+
+static int em_nbyte_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
+{
+	kfree((void *) m->data);
+	return 0;
+}
+
+static int em_nbyte_dump(struct sk_buff *skb, struct tcf_ematch *m)
+{
+	struct nbyte_data *d = (struct nbyte_data *) m->data;
+	RTA_PUT_NOHDR(skb, sizeof(*d) + d->hdr.len, d);
+	return 0;
+rtattr_failure:
+	return -1;
+}
+
+static struct tcf_ematch_ops em_nbyte_ops = {
+	.kind	  = TCF_EM_NBYTE,
+	.change	  = em_nbyte_validate,
+	.match	  = em_nbyte_match,
+	.destroy  = em_nbyte_destroy,
+	.dump	  = em_nbyte_dump,
+	.owner	  = THIS_MODULE,
+	.link	  = LIST_HEAD_INIT(em_nbyte_ops.link)
+};
+
+static int __init init_em_nbyte(void)
+{
+	return tcf_em_register(&em_nbyte_ops);
+}
+
+static void __exit exit_em_nbyte(void) 
+{
+	tcf_em_unregister(&em_nbyte_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_em_nbyte);
+module_exit(exit_em_nbyte);
+

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="04_cls_basic.diff"

diff -Nru linux-2.6.10-bk4.orig/include/linux/pkt_cls.h linux-2.6.10-bk4/include/linux/pkt_cls.h
--- linux-2.6.10-bk4.orig/include/linux/pkt_cls.h	2005-01-02 22:57:36.000000000 +0100
+++ linux-2.6.10-bk4/include/linux/pkt_cls.h	2005-01-03 02:43:05.000000000 +0100
@@ -319,6 +319,20 @@
 
 #define TCA_TCINDEX_MAX     (__TCA_TCINDEX_MAX - 1)
 
+/* Basic filter */
+
+enum
+{
+	TCA_BASIC_UNSPEC,
+	TCA_BASIC_CLASSID,
+	TCA_BASIC_EMATCHES,
+	TCA_BASIC_ACT,
+	TCA_BASIC_POLICE,
+	__TCA_BASIC_MAX
+};
+
+#define TCA_BASIC_MAX (__TCA_BASIC_MAX - 1)
+
 struct tcf_ematch_tree_hdr
 {
 	__u16		nmatches;
diff -Nru linux-2.6.10-bk4.orig/net/sched/Kconfig linux-2.6.10-bk4/net/sched/Kconfig
--- linux-2.6.10-bk4.orig/net/sched/Kconfig	2005-01-02 22:57:36.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/Kconfig	2005-01-03 03:27:54.000000000 +0100
@@ -269,6 +269,12 @@
 	  Documentation and software is at
 	  <http://diffserv.sourceforge.net/>.
 
+config NET_CLS_BASIC
+	tristate "Basic classifier"
+	depends on NET_CLS
+	---help---
+	  TODO
+
 config NET_CLS_TCINDEX
 	tristate "TC index classifier"
 	depends on NET_CLS
diff -Nru linux-2.6.10-bk4.orig/net/sched/Makefile linux-2.6.10-bk4/net/sched/Makefile
--- linux-2.6.10-bk4.orig/net/sched/Makefile	2005-01-02 22:57:36.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/Makefile	2005-01-03 03:27:21.000000000 +0100
@@ -33,6 +33,7 @@
 obj-$(CONFIG_NET_CLS_RSVP)	+= cls_rsvp.o
 obj-$(CONFIG_NET_CLS_TCINDEX)	+= cls_tcindex.o
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
+obj-$(CONFIG_NET_CLS_BASIC)	+= cls_basic.o
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
 obj-$(CONFIG_NET_EMATCH_U32)	+= em_u32.o
 obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
diff -Nru linux-2.6.10-bk4.orig/net/sched/cls_basic.c linux-2.6.10-bk4/net/sched/cls_basic.c
--- linux-2.6.10-bk4.orig/net/sched/cls_basic.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.10-bk4/net/sched/cls_basic.c	2005-01-03 13:32:00.000000000 +0100
@@ -0,0 +1,300 @@
+/*
+ * net/sched/cls_basic.c	Basic Packet Classifier.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/errno.h>
+#include <linux/rtnetlink.h>
+#include <linux/skbuff.h>
+#include <net/act_api.h>
+#include <net/pkt_cls.h>
+
+struct basic_head
+{
+	u32			hgenerator;
+	struct list_head	flist;
+};
+
+struct basic_filter
+{
+	u32			handle;
+	struct tcf_exts		exts;
+	struct tcf_ematch_tree	ematches;
+	struct tcf_result	res;
+	struct list_head	link;
+};
+
+static struct tcf_ext_map basic_ext_map = {
+	.action = TCA_BASIC_ACT,
+	.police = TCA_BASIC_POLICE
+};
+
+static int basic_classify(struct sk_buff *skb, struct tcf_proto *tp,
+			  struct tcf_result *res)
+{
+	int r;
+	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_filter *f;
+
+	list_for_each_entry(f, &head->flist, link) {
+		if (!tcf_em_tree_match(skb, &f->ematches))
+			continue;
+		*res = f->res;
+		r = tcf_exts_exec(skb, &f->exts, res);
+		if (r < 0)
+			continue;
+		return r;
+	}
+	return -1;
+}
+
+static unsigned long basic_get(struct tcf_proto *tp, u32 handle)
+{
+	unsigned long l = 0UL;
+	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_filter *f;
+
+	list_for_each_entry(f, &head->flist, link)
+		if (f->handle == handle)
+			l = (unsigned long) f;
+
+	return l;
+}
+
+static void basic_put(struct tcf_proto *tp, unsigned long f)
+{
+}
+
+static int basic_init(struct tcf_proto *tp)
+{
+	return 0;
+}
+
+static inline void
+basic_delete_filter(struct tcf_proto *tp, struct basic_filter *f)
+{
+	tcf_unbind_filter(tp, &f->res);
+	tcf_exts_destroy(tp, &f->exts);
+	tcf_em_tree_destroy(tp, &f->ematches);
+	kfree(f);
+}
+
+static void basic_destroy(struct tcf_proto *tp)
+{
+	struct basic_head *head = (struct basic_head *) xchg(&tp->root, NULL);
+	struct basic_filter *f, *n;
+	
+	list_for_each_entry_safe(f, n, &head->flist, link) {
+		list_del(&f->link);
+		basic_delete_filter(tp, f);
+	}
+}
+
+static int basic_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_filter *t, *f = (struct basic_filter *) arg;
+
+	list_for_each_entry(t, &head->flist, link)
+		if (t == f) {
+			tcf_tree_lock(tp);
+			list_del(&t->link);
+			tcf_tree_unlock(tp);
+			basic_delete_filter(tp, t);
+			return 0;
+		}
+
+	return -ENOENT;
+}
+
+static inline int basic_set_parms(struct tcf_proto *tp, struct basic_filter *f,
+				  unsigned long base, struct rtattr **tb,
+				  struct rtattr *est)
+{
+	int err;
+	struct tcf_exts e;
+	struct tcf_ematch_tree t;
+
+	err = tcf_exts_validate(tp, tb, est, &e, &basic_ext_map);
+	if (err < 0)
+		return err;
+
+	err = tcf_em_tree_validate(tp, tb[TCA_BASIC_EMATCHES-1], &t);
+	if (err < 0)
+		goto errout;
+
+	if (tb[TCA_BASIC_CLASSID-1]) {
+		err = -EINVAL;
+		if (RTA_PAYLOAD(tb[TCA_BASIC_CLASSID-1]) < sizeof(u32))
+			goto errout;
+
+		f->res.classid = *(u32*)RTA_DATA(tb[TCA_BASIC_CLASSID-1]);
+		tcf_bind_filter(tp, &f->res, base);
+	}
+
+	tcf_exts_change(tp, &f->exts, &e);
+	tcf_em_tree_change(tp, &f->ematches, &t);
+
+	return 0;
+errout:
+	tcf_exts_destroy(tp, &e);
+	return err;
+}
+
+static int basic_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+		        struct rtattr **tca, unsigned long *arg)
+{
+	int err = -EINVAL;
+	struct basic_head *head = (struct basic_head *) tp->root;
+	struct rtattr *tb[TCA_BASIC_MAX];
+	struct basic_filter *f = (struct basic_filter *) *arg;
+
+	if (!tca[TCA_OPTIONS-1])
+		return -EINVAL;
+
+	if (rtattr_parse_nested(tb, TCA_BASIC_MAX, tca[TCA_OPTIONS-1]) < 0)
+		return -EINVAL;
+
+	if (f != NULL) {
+		if (handle && f->handle != handle)
+			return -EINVAL;
+		return basic_set_parms(tp, f, base, tb, tca[TCA_RATE-1]);
+	}
+
+	err = -ENOBUFS;
+	if (!head) {
+		head = kmalloc(sizeof(*head), GFP_KERNEL);
+		if (!head)
+			goto errout;
+
+		memset(head, 0, sizeof(*head));
+		INIT_LIST_HEAD(&head->flist);
+		tp->root = head;
+	}
+
+	f = kmalloc(sizeof(*f), GFP_KERNEL);
+	if (!f)
+		goto errout;
+	memset(f, 0, sizeof(*f));
+
+	err = -EINVAL;
+	if (handle)
+		f->handle = handle;
+	else {
+		int i = 0x80000000;
+		do {
+			if (++head->hgenerator == 0x7FFFFFFF)
+				head->hgenerator = 1;
+		} while (--i > 0 && basic_get(tp, head->hgenerator));
+
+		if (i <= 0) {
+			printk(KERN_ERR "Insufficient number of handles\n");
+			goto errout;
+		}
+
+		f->handle = head->hgenerator;
+	}
+
+	err = basic_set_parms(tp, f, base, tb, tca[TCA_RATE-1]);
+	if (err < 0)
+		goto errout;
+
+	tcf_tree_lock(tp);
+	list_add(&f->link, &head->flist);
+	tcf_tree_unlock(tp);
+	*arg = (unsigned long) f;
+
+	return 0;
+errout:
+	if (*arg == 0UL && f)
+		kfree(f);
+
+	return err;
+}
+
+static void basic_walk(struct tcf_proto *tp, struct tcf_walker *arg)
+{
+	struct basic_head *head = (struct basic_head *) tp->root;
+	struct basic_filter *f;
+
+	list_for_each_entry(f, &head->flist, link) {
+		if (arg->count < arg->skip)
+			goto skip;
+
+		if (arg->fn(tp, (unsigned long) f, arg) < 0) {
+			arg->stop = 1;
+			break;
+		}
+skip:
+		arg->count++;
+	}
+}
+
+static int basic_dump(struct tcf_proto *tp, unsigned long fh,
+		      struct sk_buff *skb, struct tcmsg *t)
+{
+	struct basic_filter *f = (struct basic_filter *) fh;
+	unsigned char *b = skb->tail;
+	struct rtattr *rta;
+
+	if (!f)
+		return skb->len;
+
+	t->tcm_handle = f->handle;
+
+	rta = (struct rtattr *) b;
+	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+
+	if (tcf_exts_dump(skb, &f->exts, &basic_ext_map) < 0 ||
+	    tcf_em_tree_dump(skb, &f->ematches, TCA_BASIC_EMATCHES) < 0)
+		goto rtattr_failure;
+
+	rta->rta_len = (skb->tail - b);
+	return skb->len;
+
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static struct tcf_proto_ops cls_basic_ops = {
+	.kind		=	"basic",
+	.classify	=	basic_classify,
+	.init		=	basic_init,
+	.destroy	=	basic_destroy,
+	.get		=	basic_get,
+	.put		=	basic_put,
+	.change		=	basic_change,
+	.delete		=	basic_delete,
+	.walk		=	basic_walk,
+	.dump		=	basic_dump,
+	.owner		=	THIS_MODULE,
+};
+
+static int __init init_basic(void)
+{
+	return register_tcf_proto_ops(&cls_basic_ops);
+}
+
+static void __exit exit_basic(void) 
+{
+	unregister_tcf_proto_ops(&cls_basic_ops);
+}
+
+module_init(init_basic)
+module_exit(exit_basic)
+MODULE_LICENSE("GPL");
+

--4Ckj6UjgE2iN1+kY--
