From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Tue, 4 Jan 2005 23:36:12 +0100
Message-ID: <20050104223612.GN26856@postel.suug.ch>
References: <20050103125635.GB26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20050103125635.GB26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Updated patch with the following changes (still untested)

 * destroy/dump/change are not optional (only match is required)
 * ematch can set datalen in ematch_ops to have the ematch api
   do a data length sanity check. (to at least avoid bogus memory refs)
 * better nop macros if ematch is not enabled
 * TCF_EM_SIMPLE flag which marks an ematch config as simple, meaning
   that the data consists of a u32 value.
 * API documentation
 * removed handle from ematch_hdr
 * userspace visible ematch header is no longer used in ematch tree
   and the attributes are copied now to avoid duplications such as kind.
 * suggestion comment to use a kind > 2^15 for private/temporary
   ematches to avoid collisions on kernel upgrades
 * some minor cosmetic fixes to make code look more pretty
 * renamed tcf_em_tree_change to tcf_em_tree_replace, it gives a better
   impression on what is being done

Jamal, I know it's still not simple enough for you but can you live
with it? ;->

diff -Nru linux-2.6.10-bk6.orig/include/linux/pkt_cls.h linux-2.6.10-bk6/include/linux/pkt_cls.h
--- linux-2.6.10-bk6.orig/include/linux/pkt_cls.h	2005-01-04 18:10:11.000000000 +0100
+++ linux-2.6.10-bk6/include/linux/pkt_cls.h	2005-01-04 18:10:17.000000000 +0100
@@ -319,4 +319,51 @@
 
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
+	__u16		matchID;
+	__u16		kind;
+	__u16		flags;
+	__u16		pad; /* currently unused */
+};
+
+/* Ematch type assignments
+ *   1..32767		Reserved for ematches inside kernel tree
+ *   32768..65535	Free to use, not reliable
+ */
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
+#define TCF_EM_SIMPLE	(1<<4)
+
 #endif
diff -Nru linux-2.6.10-bk6.orig/include/linux/rtnetlink.h linux-2.6.10-bk6/include/linux/rtnetlink.h
--- linux-2.6.10-bk6.orig/include/linux/rtnetlink.h	2005-01-04 18:10:11.000000000 +0100
+++ linux-2.6.10-bk6/include/linux/rtnetlink.h	2005-01-04 01:33:32.000000000 +0100
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
diff -Nru linux-2.6.10-bk6.orig/include/net/pkt_cls.h linux-2.6.10-bk6/include/net/pkt_cls.h
--- linux-2.6.10-bk6.orig/include/net/pkt_cls.h	2005-01-04 18:10:11.000000000 +0100
+++ linux-2.6.10-bk6/include/net/pkt_cls.h	2005-01-04 19:42:59.000000000 +0100
@@ -149,6 +149,127 @@
 extern int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
 	                       struct tcf_ext_map *map);
 
+#ifdef CONFIG_NET_EMATCH
+
+struct tcf_ematch_ops;
+
+/**
+ * struct tcf_ematch - extended match (ematch)
+ * 
+ * @matchID: identifier to allow userspace to reidentify a match
+ * @flags: flags specifying attributes and the relation to other matches
+ * @ops: the operations lookup table of the corresponding ematch module
+ * @datalen: length of the ematch specific configuration data
+ * @data: ematch specific data
+ */
+struct tcf_ematch
+{
+	u16			matchID;
+	u16			flags;
+	struct tcf_ematch_ops * ops;
+	unsigned int		datalen;
+	unsigned long		data;
+};
+
+/**
+ * struct tcf_ematch_tree - ematch tree handle
+ *
+ * @hdr: ematch tree header supplied by userspace
+ * @matches: array of ematches
+ */
+struct tcf_ematch_tree
+{
+	struct tcf_ematch_tree_hdr hdr;
+	struct tcf_ematch *	matches;
+	
+};
+
+#define em_lookup_match(t, i) (&(t)->matches[(i)])
+
+/**
+ * struct tcf_ematch_ops - ematch module operations
+ * 
+ * @kind: identifier (kind) of this ematch module
+ * @datalen: length of expected configuration data (optional)
+ * @change: called during validation (optional)
+ * @match: called during ematch tree evaluation, must return 1/0
+ * @destroy: called during destroyage (optional)
+ * @dump: called during dumping process (optional)
+ * @owner: owner, must be set to THIS_MODULE
+ * @link: link to previous/next ematch module (internal use)
+ */
+struct tcf_ematch_ops
+{
+	int			kind;
+	int			datalen;
+	int			(*change)(struct tcf_proto *, void *,
+					  int, struct tcf_ematch *);
+	int			(*match)(struct sk_buff *, struct tcf_ematch *);
+	int			(*destroy)(struct tcf_proto *,
+					   struct tcf_ematch *);
+	int			(*dump)(struct sk_buff *, struct tcf_ematch *);
+	struct module		*owner;
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
+/**
+ * tcf_em_tree_replace - replace ematch tree of a running classifier
+ *
+ * @tp: classifier kind handle
+ * @dst: destination ematch tree variable
+ * @src: source ematch tree (temporary tree from tcf_em_tree_validate)
+ *
+ * This functions replaces the ematch tree in @dst with the ematch
+ * tree in @src. The classifier in charge of the ematch tree may be
+ * running.
+ */
+static inline void
+tcf_em_tree_replace(struct tcf_proto *tp, struct tcf_ematch_tree *dst,
+		   struct tcf_ematch_tree *src)
+{
+	tcf_tree_lock(tp);
+	memcpy(dst, src, sizeof(*dst));
+	tcf_tree_unlock(tp);
+}
+
+/**
+ * tcf_em_tree_match - evaulate an ematch tree
+ *
+ * @skb: socket buffer of the packet in question
+ * @t: ematch tree to be used for evaluation
+ *
+ * This function matches @skb against the ematch tree in @t by going
+ * through all ematches respecting their logic relations returning
+ * as soon as the result is obvious.
+ *
+ * Returns 1 if the ematch tree as-one matches, no ematches are configured
+ * or ematch is not enabled in the kernel, otherwise 0 is returned.
+ */
+#define tcf_em_tree_match(skb, t) \
+	((t)->hdr.nmatches ? __tcf_em_tree_match(skb, t) : 1)
+
+#else /* CONFIG_NET_EMATCH */
+
+struct tcf_ematch_tree
+{
+};
+
+#define tcf_em_tree_validate(tp, tb, t) (0)
+#define tcf_em_tree_destroy(tp, t) do { } while(0)
+#define tcf_em_tree_dump(skb, t, tlv) (0)
+#define tcf_em_tree_change(tp, dst, src) do { } while(0)
+#define tcf_em_tree_match(skb, t) (1)
+
+#endif /* CONFIG_NET_EMATCH */
+
 #ifdef CONFIG_NET_CLS_IND
 static inline int
 tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
diff -Nru linux-2.6.10-bk6.orig/net/sched/Kconfig linux-2.6.10-bk6/net/sched/Kconfig
--- linux-2.6.10-bk6.orig/net/sched/Kconfig	2005-01-04 18:10:11.000000000 +0100
+++ linux-2.6.10-bk6/net/sched/Kconfig	2005-01-04 18:10:17.000000000 +0100
@@ -375,6 +375,19 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called cls_rsvp6.
 
+config NET_EMATCH
+	bool "Extended Matches"
+	depends on NET_CLS
+	---help---
+	  Say Y here if you want to use extended matches on top of classifiers
+	  and select the extended matches below.
+
+	  Extended matches are small classification helpers not worth writing
+	  a separate classifier.
+
+	  You must have a recent version of the iproute2 tools in order to use
+	  extended matches.
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.10-bk6.orig/net/sched/Makefile linux-2.6.10-bk6/net/sched/Makefile
--- linux-2.6.10-bk6.orig/net/sched/Makefile	2005-01-04 18:10:11.000000000 +0100
+++ linux-2.6.10-bk6/net/sched/Makefile	2005-01-04 18:10:17.000000000 +0100
@@ -33,3 +33,4 @@
 obj-$(CONFIG_NET_CLS_RSVP)	+= cls_rsvp.o
 obj-$(CONFIG_NET_CLS_TCINDEX)	+= cls_tcindex.o
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
+obj-$(CONFIG_NET_EMATCH)	+= ematch.o
diff -Nru linux-2.6.10-bk6.orig/net/sched/ematch.c linux-2.6.10-bk6/net/sched/ematch.c
--- linux-2.6.10-bk6.orig/net/sched/ematch.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.10-bk6/net/sched/ematch.c	2005-01-04 18:55:40.000000000 +0100
@@ -0,0 +1,396 @@
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
+/**
+ * tcf_em_register - register an extended match
+ * 
+ * @ops: ematch operations lookup table
+ *
+ * This function must be called by ematches to announce their presence.
+ * The given @ops must have kind set to a unique identifier and the
+ * callback match() must be implemented. All other callbacks are optional
+ * and a fallback implementation is used instead.
+ *
+ * Returns -EEXISTS if an ematch of the same kind has already registered.
+ */
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
+/**
+ * tcf_em_unregister - unregster and extended match
+ *
+ * @ops: ematch operations lookup table
+ *
+ * This function must be called by ematches to announce their disappearance
+ * for examples when the module gets unloaded. The @ops parameter must be
+ * the same as the one used for registration.
+ *
+ * Returns -ENOENT if no matching ematch was found.
+ */
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
+		if (ops->datalen && datalen < ops->datalen)
+			goto errout;
+
+		if (ops->change) {
+			err = ops->change(tp, data, datalen, m);
+			if (err < 0)
+				goto errout;
+		} else if (datalen > 0) {
+			if (mh->flags & TCF_EM_SIMPLE) {
+				if (datalen < sizeof(u32))
+					goto errout;
+				m->data = *(u32 *) data;
+			} else {
+				void *v = kmalloc(datalen, GFP_KERNEL);
+				if (v == NULL) {
+					err = -ENOBUFS;
+					goto errout;
+				}
+				memcpy(v, data, datalen);
+				m->data = (unsigned long) v;
+			}
+		}
+	}
+
+	m->matchID = mh->matchID;
+	m->flags = mh->flags;
+	m->datalen = datalen;
+
+	err = 0;
+errout:
+	return err;
+}
+
+/**
+ * tcf_em_tree_validate - validate ematch config TLV and build ematch tree
+ *
+ * @tp: classifier kind handle
+ * @rta: ematch tree configuration TLV
+ * @tree: destination ematch tree variable to store the resulting
+ *        ematch tree.
+ *
+ * This function validates the given configuration TLV @rta and builds an
+ * ematch tree in @tree. The resulting tree must later be copied into
+ * the private classifier data using tcf_em_tree_change(). You MUST NOT
+ * provide the ematch tree variable of the private classifier data directly,
+ * the changes would not be locked properly.
+ *
+ * Returns a negative error code if the configuration TLV contains errors.
+ */
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
+/**
+ * tcf_em_tree_destroy - destroy an ematch tree
+ *
+ * @tp: classifier kind handle
+ * @t: ematch tree to be deleted
+ *
+ * This functions destroys an ematch tree previously created by
+ * tcf_em_tree_validate()/tcf_em_tree_change(). You must ensure that
+ * the ematch tree is not in use before calling this function.
+ */
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
+			else if (!(m->flags & TCF_EM_SIMPLE) && m->data)
+				kfree((void *) m->data);
+			module_put(m->ops->owner);
+		}
+	}
+	
+	t->hdr.nmatches = 0;
+	kfree(t->matches);
+}
+
+/**
+ * tcf_em_tree_dump - dump ematch tree into a rtnl message
+ *
+ * @skb: skb holding the rtnl message
+ * @t: ematch tree to be dumped
+ * @tlv: TLV type to be used to encapsulate the tree
+ *
+ * This function dumps a ematch tree into a rtnl message. It is valid to
+ * call this function while the ematch tree is in use.
+ *
+ * Returns -1 if the skb tailroom is insufficient.
+ */
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
+		struct tcf_ematch_hdr hdr = {
+			.kind = m->ops->kind,
+			.matchID = m->matchID,
+			.flags = m->flags
+		};
+
+		RTA_PUT(skb, i+1, sizeof(hdr), &hdr);
+		if (m->ops->dump) {
+			if (m->ops->dump(skb, m) < 0)
+				goto rtattr_failure;
+		} else if (m->flags & TCF_EM_SIMPLE) {
+			u32 u = m->data;
+			RTA_PUT_NOHDR(skb, sizeof(u32), &u);
+		} else if (m->datalen > 0)
+			RTA_PUT_NOHDR(skb, m->datalen, (void *) m->data);
+
+		pd_rta->rta_len = skb->tail - (u8*) pd_rta;
+	}
+
+	pm_rta->rta_len = skb->tail - (u8*) pm_rta;
+	p_rta->rta_len = skb->tail - (u8*) p_rta;
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
+	return m->flags & TCF_EM_INVERT ? !r : r;
+}
+
+/* Do not use this function directly, use tcf_em_tree_match instead */
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
+		if (m->ops->kind == TCF_EM_CONTAINER) {
+			if (unlikely(i >= EMATCH_STACK_SIZE))
+				goto stack_overflow;
+
+			if (unlikely(m->data <= n))
+				goto backward_jump;
+
+			stack[i++] = n;
+			n = m->data;
+			continue;
+		}
+
+		r = tcf_em_match(skb, m);
+		if (TCF_EM_REL_OBVIOUS(m->flags, r))
+			break;
+		n++;
+	}
+
+pop_stack:
+	if (i > 0) {
+		n = stack[--i];
+		m = em_lookup_match(t, n);
+
+		if (TCF_EM_REL_OBVIOUS(m->flags, r))
+			goto pop_stack;
+		else {
+			n++;
+			goto proceed;
+		}
+	}
+
+	return r;
+
+stack_overflow:
+	if (net_ratelimit())
+		printk("Local stack overflow, increase EMATCH_STACK_SIZE\n");
+	return -1;
+
+backward_jump:
+	if (net_ratelimit())
+		printk("Detected backward precedence jump, fix your filter.\n");
+	return -1;
+}
+
+EXPORT_SYMBOL(tcf_em_register);
+EXPORT_SYMBOL(tcf_em_unregister);
+EXPORT_SYMBOL(tcf_em_tree_validate);
+EXPORT_SYMBOL(tcf_em_tree_destroy);
+EXPORT_SYMBOL(tcf_em_tree_dump);
+EXPORT_SYMBOL(__tcf_em_tree_match);
+
