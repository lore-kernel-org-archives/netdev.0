From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/6] PKT_SCHED: Extended Matches API
Date: Mon, 24 Jan 2005 00:01:32 +0100
Message-ID: <20050123230132.GC23931@postel.suug.ch>
References: <20050123230012.GB23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050123230012.GB23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

An extended match (ematch) is a small classifiction tool not worth
writing a full classifier for. Ematches can be interconnected to form
a logic expression and get attached to classifiers to extend their
functionatlity.

The userspace part transforms the logic expressions into an array
consisting of multiple sequences of interconnected ematches separated
by markers. Precedence is implemented by a special ematch kind
referencing a sequence beyond the marker of the current sequence
causing the current position in the sequence to be pushed onto a stack
to allow the current position to be overwritten by the position
referenced in the special ematch. Matching continues in the new sequence
until a marker is reached causing the position to be restored from the
stack.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.11-rc2-bk1.orig/include/linux/pkt_cls.h linux-2.6.11-rc2-bk1/include/linux/pkt_cls.h
--- linux-2.6.11-rc2-bk1.orig/include/linux/pkt_cls.h	2005-01-23 19:08:31.000000000 +0100
+++ linux-2.6.11-rc2-bk1/include/linux/pkt_cls.h	2005-01-23 19:08:13.000000000 +0100
@@ -319,4 +319,76 @@
 
 #define TCA_TCINDEX_MAX     (__TCA_TCINDEX_MAX - 1)
 
+/* Extended Matches */
+
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
+	__u16		matchid;
+	__u16		kind;
+	__u16		flags;
+	__u16		pad; /* currently unused */
+};
+
+/*  0                   1
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 
+ * +-----------------------+-+-+---+
+ * |         Unused        |S|I| R |
+ * +-----------------------+-+-+---+
+ *
+ * R(2) ::= relation to next ematch
+ *          where: 0 0 END (last ematch)
+ *                 0 1 AND
+ *                 1 0 OR
+ *                 1 1 Unused (invalid)
+ * I(1) ::= invert result
+ * S(1) ::= simple payload
+ */
+#define TCF_EM_REL_END	0
+#define TCF_EM_REL_AND	(1<<0)
+#define TCF_EM_REL_OR	(1<<1)
+#define TCF_EM_INVERT	(1<<2)
+#define TCF_EM_SIMPLE	(1<<3)
+
+#define TCF_EM_REL_MASK	3
+#define TCF_EM_REL_VALID(v) (((v) & TCF_EM_REL_MASK) != TCF_EM_REL_MASK)
+
+enum
+{
+	TCF_LAYER_LINK,
+	TCF_LAYER_NETWORK,
+	TCF_LAYER_TRANSPORT,
+	__TCF_LAYER_MAX
+};
+#define TCF_LAYER_MAX (__TCF_LAYER_MAX - 1)
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
+enum
+{
+	TCF_EM_PROG_TC
+};
+
 #endif
diff -Nru linux-2.6.11-rc2-bk1.orig/include/linux/rtnetlink.h linux-2.6.11-rc2-bk1/include/linux/rtnetlink.h
--- linux-2.6.11-rc2-bk1.orig/include/linux/rtnetlink.h	2005-01-23 19:08:31.000000000 +0100
+++ linux-2.6.11-rc2-bk1/include/linux/rtnetlink.h	2005-01-23 16:31:57.000000000 +0100
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
diff -Nru linux-2.6.11-rc2-bk1.orig/include/net/pkt_cls.h linux-2.6.11-rc2-bk1/include/net/pkt_cls.h
--- linux-2.6.11-rc2-bk1.orig/include/net/pkt_cls.h	2005-01-23 19:08:31.000000000 +0100
+++ linux-2.6.11-rc2-bk1/include/net/pkt_cls.h	2005-01-23 19:08:44.000000000 +0100
@@ -148,6 +148,176 @@
 extern int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
 	                       struct tcf_ext_map *map);
 
+/**
+ * struct tcf_pkt_info - packet information
+ */
+struct tcf_pkt_info
+{
+};
+
+#ifdef CONFIG_NET_EMATCH
+
+struct tcf_ematch_ops;
+
+/**
+ * struct tcf_ematch - extended match (ematch)
+ * 
+ * @matchid: identifier to allow userspace to reidentify a match
+ * @flags: flags specifying attributes and the relation to other matches
+ * @ops: the operations lookup table of the corresponding ematch module
+ * @datalen: length of the ematch specific configuration data
+ * @data: ematch specific data
+ */
+struct tcf_ematch
+{
+	u16			matchid;
+	u16			flags;
+	struct tcf_ematch_ops * ops;
+	unsigned int		datalen;
+	unsigned long		data;
+};
+
+static inline int tcf_em_is_container(struct tcf_ematch *em)
+{
+	return !em->ops;
+}
+
+static inline int tcf_em_is_simple(struct tcf_ematch *em)
+{
+	return em->flags & TCF_EM_SIMPLE;
+}
+
+static inline int tcf_em_is_inverted(struct tcf_ematch *em)
+{
+	return em->flags & TCF_EM_INVERT;
+}
+
+static inline int tcf_em_last_match(struct tcf_ematch *em)
+{
+	return (em->flags & TCF_EM_REL_MASK) == TCF_EM_REL_END;
+}
+
+static inline int tcf_em_early_end(struct tcf_ematch *em, int result)
+{
+	if (tcf_em_last_match(em))
+		return 1;
+
+	if (result == 0 && em->flags & TCF_EM_REL_AND)
+		return 1;
+
+	if (result != 0 && em->flags & TCF_EM_REL_OR)
+		return 1;
+
+	return 0;
+}
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
+	int			(*match)(struct sk_buff *, struct tcf_ematch *,
+					 struct tcf_pkt_info *);
+	void			(*destroy)(struct tcf_proto *,
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
+extern int __tcf_em_tree_match(struct sk_buff *, struct tcf_ematch_tree *,
+			       struct tcf_pkt_info *);
+
+/**
+ * tcf_em_tree_change - replace ematch tree of a running classifier
+ *
+ * @tp: classifier kind handle
+ * @dst: destination ematch tree variable
+ * @src: source ematch tree (temporary tree from tcf_em_tree_validate)
+ *
+ * This functions replaces the ematch tree in @dst with the ematch
+ * tree in @src. The classifier in charge of the ematch tree may be
+ * running.
+ */
+static inline void tcf_em_tree_change(struct tcf_proto *tp,
+				      struct tcf_ematch_tree *dst,
+				      struct tcf_ematch_tree *src)
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
+ * @tree: ematch tree to be used for evaluation
+ * @info: packet information examined by classifier
+ *
+ * This function matches @skb against the ematch tree in @tree by going
+ * through all ematches respecting their logic relations returning
+ * as soon as the result is obvious.
+ *
+ * Returns 1 if the ematch tree as-one matches, no ematches are configured
+ * or ematch is not enabled in the kernel, otherwise 0 is returned.
+ */
+static inline int tcf_em_tree_match(struct sk_buff *skb,
+				    struct tcf_ematch_tree *tree,
+				    struct tcf_pkt_info *info)
+{
+	if (tree->hdr.nmatches)
+		return __tcf_em_tree_match(skb, tree, info);
+	else
+		return 1;
+}
+
+#else /* CONFIG_NET_EMATCH */
+
+struct tcf_ematch_tree
+{
+};
+
+#define tcf_em_tree_validate(tp, tb, t) ((void)(t), 0)
+#define tcf_em_tree_destroy(tp, t) do { (void)(t); } while(0)
+#define tcf_em_tree_dump(skb, t, tlv) (0)
+#define tcf_em_tree_change(tp, dst, src) do { } while(0)
+#define tcf_em_tree_match(skb, t, info) ((void)(info), 1)
+
+#endif /* CONFIG_NET_EMATCH */
+
 #ifdef CONFIG_NET_CLS_IND
 static inline int
 tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
diff -Nru linux-2.6.11-rc2-bk1.orig/net/sched/Kconfig linux-2.6.11-rc2-bk1/net/sched/Kconfig
--- linux-2.6.11-rc2-bk1.orig/net/sched/Kconfig	2005-01-23 19:08:31.000000000 +0100
+++ linux-2.6.11-rc2-bk1/net/sched/Kconfig	2005-01-23 19:08:13.000000000 +0100
@@ -375,6 +375,29 @@
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
+config NET_EMATCH_STACK
+	int "Stack size"
+	depends on NET_EMATCH
+	default "32"
+	---help---
+	  Size of the local stack variable used while evaluating the tree of
+	  ematches. Limits the depth of the tree, i.e. the number of
+	  encapsulated precedences. Every level requires 4 bytes of addtional
+	  stack space.
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.11-rc2-bk1.orig/net/sched/Makefile linux-2.6.11-rc2-bk1/net/sched/Makefile
--- linux-2.6.11-rc2-bk1.orig/net/sched/Makefile	2005-01-23 19:08:31.000000000 +0100
+++ linux-2.6.11-rc2-bk1/net/sched/Makefile	2005-01-23 19:08:13.000000000 +0100
@@ -33,3 +33,4 @@
 obj-$(CONFIG_NET_CLS_RSVP)	+= cls_rsvp.o
 obj-$(CONFIG_NET_CLS_TCINDEX)	+= cls_tcindex.o
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
+obj-$(CONFIG_NET_EMATCH)	+= ematch.o
diff -Nru linux-2.6.11-rc2-bk1.orig/net/sched/ematch.c linux-2.6.11-rc2-bk1/net/sched/ematch.c
--- linux-2.6.11-rc2-bk1.orig/net/sched/ematch.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.11-rc2-bk1/net/sched/ematch.c	2005-01-23 16:31:57.000000000 +0100
@@ -0,0 +1,526 @@
+/*
+ * net/sched/ematch.c		Extended Match API
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ *
+ * ==========================================================================
+ *
+ * An extended match (ematch) is a small classification tool not worth
+ * writing a full classifier for. Ematches can be interconnected to form
+ * a logic expression and get attached to classifiers to extend their
+ * functionatlity.
+ *
+ * The userspace part transforms the logic expressions into an array
+ * consisting of multiple sequences of interconnected ematches separated
+ * by markers. Precedence is implemented by a special ematch kind
+ * referencing a sequence beyond the marker of the current sequence
+ * causing the current position in the sequence to be pushed onto a stack
+ * to allow the current position to be overwritten by the position referenced
+ * in the special ematch. Matching continues in the new sequence until a
+ * marker is reached causing the position to be restored from the stack.
+ *
+ * Example:
+ *          A AND (B1 OR B2) AND C AND D
+ *
+ *              ------->-PUSH-------
+ *    -->--    /         -->--      \   -->--
+ *   /     \  /         /     \      \ /     \
+ * +-------+-------+-------+-------+-------+--------+
+ * | A AND | B AND | C AND | D END | B1 OR | B2 END |
+ * +-------+-------+-------+-------+-------+--------+
+ *                    \                      /
+ *                     --------<-POP---------
+ *
+ * where B is a virtual ematch referencing to sequence starting with B1.
+ * 
+ * ==========================================================================
+ *
+ * How to write an ematch in 60 seconds
+ * ------------------------------------
+ * 
+ *   1) Provide a matcher function:
+ *      static int my_match(struct sk_buff *skb, struct tcf_ematch *m,
+ *                          struct tcf_pkt_info *info)
+ *      {
+ *      	struct mydata *d = (struct mydata *) m->data;
+ *
+ *      	if (...matching goes here...)
+ *      		return 1;
+ *      	else
+ *      		return 0;
+ *      }
+ *
+ *   2) Fill out a struct tcf_ematch_ops:
+ *      static struct tcf_ematch_ops my_ops = {
+ *      	.kind = unique id,
+ *      	.datalen = sizeof(struct mydata),
+ *      	.match = my_match,
+ *      	.owner = THIS_MODULE,
+ *      };
+ *
+ *   3) Register/Unregister your ematch:
+ *      static int __init init_my_ematch(void)
+ *      {
+ *      	return tcf_em_register(&my_ops);
+ *      }
+ *
+ *      static void __exit exit_my_ematch(void)
+ *      {
+ *      	return tcf_em_unregister(&my_ops);
+ *      }
+ *
+ *      module_init(init_my_ematch);
+ *      module_exit(exit_my_ematch);
+ *
+ *   4) By now you should have two more seconds left, barely enough to
+ *      open up a beer to watch the compilation going.
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
+#include <config/net/ematch/stack.h>
+
+static LIST_HEAD(ematch_ops);
+static DEFINE_RWLOCK(ematch_mod_lock);
+
+static inline struct tcf_ematch_ops * tcf_em_lookup(u16 kind)
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
+static inline struct tcf_ematch * tcf_em_get_match(struct tcf_ematch_tree *tree,
+						   int index)
+{
+	return &tree->matches[index];
+}
+
+
+static int tcf_em_validate(struct tcf_proto *tp,
+			   struct tcf_ematch_tree_hdr *tree_hdr,
+			   struct tcf_ematch *em, struct rtattr *rta, int idx)
+{
+	int err = -EINVAL;
+	struct tcf_ematch_hdr *em_hdr = RTA_DATA(rta);
+	int data_len = RTA_PAYLOAD(rta) - sizeof(*em_hdr);
+	void *data = (void *) em_hdr + sizeof(*em_hdr);
+
+	if (!TCF_EM_REL_VALID(em_hdr->flags))
+		goto errout;
+
+	if (em_hdr->kind == TCF_EM_CONTAINER) {
+		/* Special ematch called "container", carries an index
+		 * referencing an external ematch sequence. */
+		u32 ref;
+
+		if (data_len < sizeof(ref))
+			goto errout;
+		ref = *(u32 *) data;
+
+		if (ref >= tree_hdr->nmatches)
+			goto errout;
+
+		/* We do not allow backward jumps to avoid loops and jumps
+		 * to our own position are of course illegal. */
+		if (ref <= idx)
+			goto errout;
+
+		
+		em->data = ref;
+	} else {
+		/* Note: This lookup will increase the module refcnt
+		 * of the ematch module referenced. In case of a failure,
+		 * a destroy function is called by the underlying layer
+		 * which automatically releases the reference again, therefore
+		 * the module MUST not be given back under any circumstances
+		 * here. Be aware, the destroy function assumes that the
+		 * module is held if the ops field is non zero. */
+		em->ops = tcf_em_lookup(em_hdr->kind);
+
+		if (em->ops == NULL) {
+			err = -ENOENT;
+			goto errout;
+		}
+
+		/* ematch module provides expected length of data, so we
+		 * can do a basic sanity check. */
+		if (em->ops->datalen && data_len < em->ops->datalen)
+			goto errout;
+
+		if (em->ops->change) {
+			err = em->ops->change(tp, data, data_len, em);
+			if (err < 0)
+				goto errout;
+		} else if (data_len > 0) {
+			/* ematch module doesn't provide an own change
+			 * procedure and expects us to allocate and copy
+			 * the ematch data.
+			 *
+			 * TCF_EM_SIMPLE may be specified stating that the
+			 * data only consists of a u32 integer and the module
+			 * does not expected a memory reference but rather
+			 * the value carried. */
+			if (em_hdr->flags & TCF_EM_SIMPLE) {
+				if (data_len < sizeof(u32))
+					goto errout;
+				em->data = *(u32 *) data;
+			} else {
+				void *v = kmalloc(data_len, GFP_KERNEL);
+				if (v == NULL) {
+					err = -ENOBUFS;
+					goto errout;
+				}
+				memcpy(v, data, data_len);
+				em->data = (unsigned long) v;
+			}
+		}
+	}
+
+	em->matchid = em_hdr->matchid;
+	em->flags = em_hdr->flags;
+	em->datalen = data_len;
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
+	int idx, list_len, matches_len, err = -EINVAL;
+	struct rtattr *tb[TCA_EMATCH_TREE_MAX];
+	struct rtattr *rt_match, *rt_hdr, *rt_list;
+	struct tcf_ematch_tree_hdr *tree_hdr;
+	struct tcf_ematch *em;
+
+	if (rtattr_parse_nested(tb, TCA_EMATCH_TREE_MAX, rta) < 0)
+		goto errout;
+
+	rt_hdr = tb[TCA_EMATCH_TREE_HDR-1];
+	rt_list = tb[TCA_EMATCH_TREE_LIST-1];
+
+	if (rt_hdr == NULL || rt_list == NULL)
+		goto errout;
+
+	if (RTA_PAYLOAD(rt_hdr) < sizeof(*tree_hdr) ||
+	    RTA_PAYLOAD(rt_list) < sizeof(*rt_match))
+		goto errout;
+
+	tree_hdr = RTA_DATA(rt_hdr);
+	memcpy(&tree->hdr, tree_hdr, sizeof(*tree_hdr));
+
+	rt_match = RTA_DATA(rt_list);
+	list_len = RTA_PAYLOAD(rt_list);
+	matches_len = tree_hdr->nmatches * sizeof(*em);
+
+	tree->matches = kmalloc(matches_len, GFP_KERNEL);
+	if (tree->matches == NULL)
+		goto errout;
+	memset(tree->matches, 0, matches_len);
+
+	/* We do not use rtattr_parse_nested here because the maximum
+	 * number of attributes is unknown. This saves us the allocation
+	 * for a tb buffer which would serve no purpose at all.
+	 * 
+	 * The array of rt attributes is parsed in the order as they are
+	 * provided, their type must be incremental from 1 to n. Even
+	 * if it does not serve any real purpose, a failure of sticking
+	 * to this policy will result in parsing failure. */
+	for (idx = 0; RTA_OK(rt_match, list_len); idx++) {
+		err = -EINVAL;
+
+		if (rt_match->rta_type != (idx + 1))
+			goto errout_abort;
+
+		if (idx >= tree_hdr->nmatches)
+			goto errout_abort;
+
+		if (RTA_PAYLOAD(rt_match) < sizeof(struct tcf_ematch_hdr))
+			goto errout_abort;
+
+		em = tcf_em_get_match(tree, idx);
+
+		err = tcf_em_validate(tp, tree_hdr, em, rt_match, idx);
+		if (err < 0)
+			goto errout_abort;
+
+		rt_match = RTA_NEXT(rt_match, list_len);
+	}
+
+	/* Check if the number of matches provided by userspace actually
+	 * complies with the array of matches. The number was used for
+	 * the validation of references and a mismatch could lead to
+	 * undefined references during the matching process. */
+	if (idx != tree_hdr->nmatches) {
+		err = -EINVAL;
+		goto errout_abort;
+	}
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
+ * @tree: ematch tree to be deleted
+ *
+ * This functions destroys an ematch tree previously created by
+ * tcf_em_tree_validate()/tcf_em_tree_change(). You must ensure that
+ * the ematch tree is not in use before calling this function.
+ */
+void tcf_em_tree_destroy(struct tcf_proto *tp, struct tcf_ematch_tree *tree)
+{
+	int i;
+
+	if (tree->matches == NULL)
+		return;
+
+	for (i = 0; i < tree->hdr.nmatches; i++) {
+		struct tcf_ematch *em = tcf_em_get_match(tree, i);
+
+		if (em->ops) {
+			if (em->ops->destroy)
+				em->ops->destroy(tp, em);
+			else if (!tcf_em_is_simple(em) && em->data)
+				kfree((void *) em->data);
+			module_put(em->ops->owner);
+		}
+	}
+	
+	tree->hdr.nmatches = 0;
+	kfree(xchg(&tree->matches, NULL));
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
+int tcf_em_tree_dump(struct sk_buff *skb, struct tcf_ematch_tree *tree, int tlv)
+{
+	int i;
+	struct rtattr * top_start = (struct rtattr*) skb->tail;
+	struct rtattr * list_start;
+
+	RTA_PUT(skb, tlv, 0, NULL);
+	RTA_PUT(skb, TCA_EMATCH_TREE_HDR, sizeof(tree->hdr), &tree->hdr);
+
+	list_start = (struct rtattr *) skb->tail;
+	RTA_PUT(skb, TCA_EMATCH_TREE_LIST, 0, NULL);
+
+	for (i = 0; i < tree->hdr.nmatches; i++) {
+		struct rtattr *match_start = (struct rtattr*) skb->tail;
+		struct tcf_ematch *em = tcf_em_get_match(tree, i);
+		struct tcf_ematch_hdr em_hdr = {
+			.kind = em->ops ? em->ops->kind : TCF_EM_CONTAINER,
+			.matchid = em->matchid,
+			.flags = em->flags
+		};
+
+		RTA_PUT(skb, i+1, sizeof(em_hdr), &em_hdr);
+
+		if (em->ops && em->ops->dump) {
+			if (em->ops->dump(skb, em) < 0)
+				goto rtattr_failure;
+		} else if (tcf_em_is_container(em) || tcf_em_is_simple(em)) {
+			u32 u = em->data;
+			RTA_PUT_NOHDR(skb, sizeof(u), &u);
+		} else if (em->datalen > 0)
+			RTA_PUT_NOHDR(skb, em->datalen, (void *) em->data);
+
+		match_start->rta_len = skb->tail - (u8*) match_start;
+	}
+
+	list_start->rta_len = skb->tail - (u8 *) list_start;
+	top_start->rta_len = skb->tail - (u8 *) top_start;
+
+	return 0;
+
+rtattr_failure:
+	return -1;
+}
+
+static inline int tcf_em_match(struct sk_buff *skb, struct tcf_ematch *em,
+			       struct tcf_pkt_info *info)
+{
+	int r;
+
+	if (likely(em->ops->match))
+		r = em->ops->match(skb, em, info);
+	else
+		r = 0;
+
+	return tcf_em_is_inverted(em) ? !r : r;
+}
+
+/* Do not use this function directly, use tcf_em_tree_match instead */
+int __tcf_em_tree_match(struct sk_buff *skb, struct tcf_ematch_tree *tree,
+			struct tcf_pkt_info *info)
+{
+	int stackp = 0, match_idx = 0, res = 0;
+	struct tcf_ematch *cur_match;
+	int stack[CONFIG_NET_EMATCH_STACK];
+
+proceed:
+	while (match_idx < tree->hdr.nmatches) {
+		cur_match = tcf_em_get_match(tree, match_idx);
+
+		if (tcf_em_is_container(cur_match)) {
+			if (unlikely(stackp >= CONFIG_NET_EMATCH_STACK))
+				goto stack_overflow;
+
+			stack[stackp++] = match_idx;
+			match_idx = cur_match->data;
+			goto proceed;
+		}
+
+		res = tcf_em_match(skb, cur_match, info);
+
+		if (tcf_em_early_end(cur_match, res))
+			break;
+
+		match_idx++;
+	}
+
+pop_stack:
+	if (stackp > 0) {
+		match_idx = stack[--stackp];
+		cur_match = tcf_em_get_match(tree, match_idx);
+
+		if (tcf_em_early_end(cur_match, res))
+			goto pop_stack;
+		else {
+			match_idx++;
+			goto proceed;
+		}
+	}
+
+	return res;
+
+stack_overflow:
+	if (net_ratelimit())
+		printk("Local stack overflow, increase NET_EMATCH_STACK\n");
+	return -1;
+}
+
+EXPORT_SYMBOL(tcf_em_register);
+EXPORT_SYMBOL(tcf_em_unregister);
+EXPORT_SYMBOL(tcf_em_tree_validate);
+EXPORT_SYMBOL(tcf_em_tree_destroy);
+EXPORT_SYMBOL(tcf_em_tree_dump);
+EXPORT_SYMBOL(__tcf_em_tree_match);
