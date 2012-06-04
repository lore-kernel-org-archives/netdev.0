From: Rostislav Lisovy <lisovy@gmail.com>
Subject: [PATCH 2/2] net/sched: CAN Filter/Classifier
Date: Mon,  4 Jun 2012 18:09:36 +0200
Message-ID: <1338826176-11646-2-git-send-email-lisovy@gmail.com>
References: <1338826176-11646-1-git-send-email-lisovy@gmail.com>
Cc: linux-can@vger.kernel.org, lartc@vger.kernel.org,
	pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz,
	Rostislav Lisovy <lisovy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1338826176-11646-1-git-send-email-lisovy@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This classifier classifies CAN frames (AF_CAN) according to their
identifiers. This functionality can not be easily achieved with
existing classifiers, such as u32. This classifier can be used
with any available qdisc and it is able to classify both SFF
or EFF frames.

The filtering rules for EFF frames are stored in an array, which
is traversed during classification. A bitmap is used to store SFF
rules -- one bit for each ID.

More info about the project:
http://rtime.felk.cvut.cz/can/socketcan-qdisc-final.pdf

Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
---
 net/sched/Kconfig   |   10 +
 net/sched/Makefile  |    1 +
 net/sched/cls_can.c |  572 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 583 insertions(+)
 create mode 100644 net/sched/cls_can.c

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index e7a8976..aeb3c29 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -323,6 +323,16 @@ config NET_CLS_BASIC
 	  To compile this code as a module, choose M here: the
 	  module will be called cls_basic.
 
+config NET_CLS_CAN
+	tristate "Controller Area Network classifier (CAN)"
+	select NET_CLS
+	---help---
+	  Say Y here if you want to be able to classify CAN frames according
+	  to their CAN identifiers (can_id).
+
+	  To compile this code as a module, choose M here: the
+	  module will be called cls_can.
+
 config NET_CLS_TCINDEX
 	tristate "Traffic-Control Index (TCINDEX)"
 	select NET_CLS
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 5940a19..0217341 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -47,6 +47,7 @@ obj-$(CONFIG_NET_CLS_RSVP)	+= cls_rsvp.o
 obj-$(CONFIG_NET_CLS_TCINDEX)	+= cls_tcindex.o
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
 obj-$(CONFIG_NET_CLS_BASIC)	+= cls_basic.o
+obj-$(CONFIG_NET_CLS_CAN)	+= cls_can.o
 obj-$(CONFIG_NET_CLS_FLOW)	+= cls_flow.o
 obj-$(CONFIG_NET_CLS_CGROUP)	+= cls_cgroup.o
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
diff --git a/net/sched/cls_can.c b/net/sched/cls_can.c
new file mode 100644
index 0000000..659be45
--- /dev/null
+++ b/net/sched/cls_can.c
@@ -0,0 +1,572 @@
+/*
+ * cls_can.c  -- Controller Area Network classifier.
+ * Makes decisions according to Controller Area Network identifiers (can_id).
+ *
+ *             This program is free software; you can distribute it and/or
+ *             modify it under the terms of the GNU General Public License
+ *             as published by the Free Software Foundation; version 2 of
+ *             the License.
+ *
+ * Idea:       Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
+ * Copyright:  (c) 2011 Czech Technical University in Prague
+ *             (c) 2011 Volkswagen Group Research
+ * Authors:    Michal Sojka <sojkam1@fel.cvut.cz>
+ *             Pavel Pisa <pisa@cmp.felk.cvut.cz>
+ *             Rostislav Lisovy <lisovy@gmail.cz>
+ * Funded by:  Volkswagen Group Research
+ *
+ * Some function descriptions are heavily inspired by article "Linux Network
+ * Traffic Control -- Implementation Overview" by Werner Almesberger
+ */
+
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/rtnetlink.h>
+#include <linux/skbuff.h>
+#include <net/netlink.h>
+#include <net/act_api.h>
+#include <net/pkt_cls.h>
+#include <linux/bitmap.h>
+#include <linux/spinlock.h>
+#include <linux/rcupdate.h>
+#include <linux/can.h>
+
+/* Definition of Netlink message parts */
+enum {
+	TCA_CANFLTR_UNSPEC,
+	TCA_CANFLTR_CLASSID,
+	TCA_CANFLTR_RULES,	/* Array of can_filter structs; We are able
+				to determine the length after receiving */
+	__TCA_CANFLTR_MAX
+};
+#define TCA_CANFLTR_MAX (__TCA_CANFLTR_MAX - 1)
+
+static const struct nla_policy canfltr_policy[TCA_CANFLTR_MAX + 1] = {
+	[TCA_CANFLTR_CLASSID]    = { .type = NLA_U32 }, /* Be aware of possible
+						problems with 64bit kernel and
+						32bit userspace etc. */
+	[TCA_CANFLTR_RULES]      = { .type = NLA_NESTED }
+};
+
+struct canfltr_rules {
+	struct can_filter *rules_raw;	/* Raw rules copied from netlink
+					message; Used for sending information
+					to userspace (when 'tc filter show' is
+					invoked) AND when matching EFF frames*/
+	DECLARE_BITMAP(match_sff, (1 << CAN_SFF_ID_BITS)); /* For each SFF CAN
+					ID (11 bit) there is one record in this
+					bitfield */
+	int rules_count;
+	int eff_rules_count;
+	int sff_rules_count;
+
+	struct rcu_head rcu;
+};
+
+struct canfltr_head {
+	u32 hgenerator;
+	struct list_head flist;
+};
+
+struct canfltr_state {
+	u32 handle;
+	struct canfltr_rules *rules;	/* All rules necessary for
+					classification */
+	struct tcf_result res;		/* Class ID (flow id) the instance
+					of a filter is bound to */
+	struct list_head link;
+};
+
+/*
+ * ----------------------------------------------------------------------------
+ */
+
+static void canfltr_sff_match_add(struct canfltr_rules *rls,
+				u32 can_id, u32 can_mask)
+{
+	int i;
+
+	/* Limit can_mask and can_id to SFF range to
+	protect against write after end of array */
+	can_mask &= CAN_SFF_MASK;
+	can_id &= can_mask;
+
+	/* single frame */
+	if (can_mask == CAN_SFF_MASK) {
+		set_bit(can_id, rls->match_sff);
+		return;
+	}
+
+	/* all frames */
+	if (can_mask == 0) {
+		bitmap_fill(rls->match_sff, (1 << CAN_SFF_ID_BITS));
+		return;
+	}
+
+	/* individual frame filter */
+	/* Add record (set bit to 1) for each ID that
+	conforms particular rule */
+	for (i = 0; i < (1 << CAN_SFF_ID_BITS); i++) {
+		if ((i & can_mask) == can_id)
+			set_bit(i, rls->match_sff);
+	}
+}
+
+/**
+ * canfltr_get_id() - Extracts Can ID out of the sk_buff structure.
+ */
+static canid_t canfltr_get_id(struct sk_buff *skb)
+{
+	/* Can ID is inside of data field */
+	struct can_frame *cf = (struct can_frame *)skb->data;
+
+	return cf->can_id;
+}
+
+/**
+ * canfltr_classify() - Performs the classification.
+ *
+ * @skb: Socket buffer
+ * @tp:
+ * @res: Is used for setting Class ID as a result of classification
+ *
+ * Iterates over all instances of filter, checking for CAN ID match.
+ *
+ * Returns value relevant for policing. Used return values:
+ *   TC_POLICE_OK if succesfully classified (without regard to policing rules)
+ *   TC_POLICE_UNSPEC if no matching rule was found
+ */
+static int canfltr_classify(struct sk_buff *skb, const struct tcf_proto *tp,
+			  struct tcf_result *res)
+{
+	struct canfltr_head *head = (struct canfltr_head *)tp->root;
+	struct canfltr_state *f;
+	struct canfltr_rules *r;
+	canid_t can_id;
+	int i;
+
+	can_id = canfltr_get_id(skb);
+
+	rcu_read_lock();
+	list_for_each_entry(f, &head->flist, link) {
+		bool match = false;
+		r = rcu_dereference(f->rules);
+
+
+		if (can_id & CAN_EFF_FLAG) {
+			can_id &= CAN_EFF_MASK;
+
+			for (i = 0; i < r->eff_rules_count; i++) {
+				if (!(((r->rules_raw[i].can_id ^ can_id) &
+				r->rules_raw[i].can_mask) & CAN_EFF_MASK)) {
+					match = true;
+					break;
+				}
+			}
+		} else { /* SFF */
+			can_id &= CAN_SFF_MASK;
+			match = test_bit(can_id, r->match_sff);
+		}
+
+		if (match) {
+			*res = f->res;
+			rcu_read_unlock();
+			return TC_POLICE_OK;
+		}
+	}
+
+	rcu_read_unlock();
+	return TC_POLICE_UNSPEC;
+}
+
+/**
+ * canfltr_get() - Looks up a filter element by its handle and returns the
+ * internal filter ID (i.e. pointer)
+ */
+static unsigned long canfltr_get(struct tcf_proto *tp, u32 handle)
+{
+	struct canfltr_head *head = (struct canfltr_head *)tp->root;
+	struct canfltr_state *f;
+
+	if (head == NULL)
+		return 0UL;
+
+	list_for_each_entry(f, &head->flist, link) {
+		if (f->handle == handle)
+			return (unsigned long) f;
+	}
+
+	return 0UL;
+}
+
+/**
+ * canfltr_put() - Is invoked when a filter element previously referenced
+ * with get() is no longer used
+ */
+static void canfltr_put(struct tcf_proto *tp, unsigned long f)
+{
+}
+
+/**
+ * canfltr_gen_handle() - Generate handle for newly created filter
+ *
+ * This code is heavily inspired by handle generator in cls_basic.c
+ */
+static unsigned int canfltr_gen_handle(struct tcf_proto *tp)
+{
+	struct canfltr_head *head = (struct canfltr_head *)tp->root;
+	unsigned int i = 0x80000000;
+
+	do {
+		if (++head->hgenerator == 0x7FFFFFFF)
+			head->hgenerator = 1;
+	} while (--i > 0 && canfltr_get(tp, head->hgenerator));
+
+	if (i == 0)
+		return 0;
+
+	return head->hgenerator;
+}
+
+static void canfltr_rules_free_rcu(struct rcu_head *rcu)
+{
+	kfree(container_of(rcu, struct canfltr_rules, rcu));
+}
+
+static int canfltr_set_parms(struct tcf_proto *tp, struct canfltr_state *f,
+				unsigned long base, struct nlattr **tb,
+				struct nlattr *est)
+{
+	struct can_filter *canfltr_nl_rules;
+	struct canfltr_rules *rules_tmp;
+	int err;
+	int i;
+
+	rules_tmp = kzalloc(sizeof(*rules_tmp), GFP_KERNEL);
+	if (!rules_tmp)
+		return -ENOBUFS;
+
+	err = -EINVAL;
+	if (tb[TCA_CANFLTR_CLASSID] == NULL)
+		goto errout;
+
+	if (tb[TCA_CANFLTR_RULES]) {
+		canfltr_nl_rules = nla_data(tb[TCA_CANFLTR_RULES]);
+		rules_tmp->sff_rules_count = 0;
+		rules_tmp->eff_rules_count = 0;
+		rules_tmp->rules_count = (nla_len(tb[TCA_CANFLTR_RULES]) /
+			sizeof(struct can_filter));
+
+		rules_tmp->rules_raw = kzalloc(sizeof(struct can_filter) *
+			rules_tmp->rules_count, GFP_KERNEL);
+		err = -ENOMEM;
+		if (rules_tmp->rules_raw == NULL)
+			goto errout;
+
+		/* We need two for() loops for copying rules into
+		two contiguous areas in rules_raw */
+
+		/* Process EFF frame rules*/
+		for (i = 0; i < rules_tmp->rules_count; i++) {
+			if ((canfltr_nl_rules[i].can_id & CAN_EFF_FLAG) &&
+			    (canfltr_nl_rules[i].can_mask & CAN_EFF_FLAG)) {
+				memcpy(rules_tmp->rules_raw +
+					rules_tmp->eff_rules_count,
+					&canfltr_nl_rules[i],
+					sizeof(struct can_filter));
+				rules_tmp->eff_rules_count++;
+			} else {
+				continue;
+			}
+		}
+
+		/* Process SFF frame rules */
+		for (i = 0; i < rules_tmp->rules_count; i++) {
+			if ((canfltr_nl_rules[i].can_id & CAN_EFF_FLAG) &&
+			    (canfltr_nl_rules[i].can_mask & CAN_EFF_FLAG)) {
+				continue;
+			} else {
+				memcpy(rules_tmp->rules_raw +
+					rules_tmp->eff_rules_count +
+					rules_tmp->sff_rules_count,
+					&canfltr_nl_rules[i],
+					sizeof(struct can_filter));
+				rules_tmp->sff_rules_count++;
+				canfltr_sff_match_add(rules_tmp,
+					canfltr_nl_rules[i].can_id,
+					canfltr_nl_rules[i].can_mask);
+			}
+		}
+	}
+
+
+	/* Setting parameters for newly created filter */
+	if (f->rules == NULL) {
+		rcu_assign_pointer(f->rules, rules_tmp);
+	} else { /* Changing existing filter */
+		struct canfltr_rules *rules_old;
+
+		rules_old = xchg(&f->rules, rules_tmp);
+		call_rcu(&rules_old->rcu, canfltr_rules_free_rcu);
+	}
+
+	return 0;
+
+errout:
+	kfree(rules_tmp);
+	return err;
+}
+
+/**
+ * canfltr_change() - Called for changing properties of an existing filter or
+ * after addition of a new filter to a class (by calling bind_tcf which binds
+ * an instance of a filter to the class).
+ *
+ * @tp:     Structure representing instance of a filter.
+ *          Part of a linked list of all filters.
+ * @base:
+ * @handle:
+ * @tca:    Messages passed through the Netlink from userspace.
+ * @arg:
+ */
+static int canfltr_change(struct tcf_proto *tp, unsigned long base, u32 handle,
+			  struct nlattr **tca, unsigned long *arg)
+{
+	struct canfltr_head *head = (struct canfltr_head *)tp->root;
+	struct canfltr_state *f = (struct canfltr_state *)*arg;
+	struct nlattr *tb[TCA_CANFLTR_MAX + 1];
+	int err;
+
+	if (tca[TCA_OPTIONS] == NULL)
+		return -EINVAL;
+
+	/* Parses a stream of attributes and stores a pointer to each
+	attribute in the tb array accessible via the attribute type.
+	Policy may be set to NULL if no validation is required.*/
+	err = nla_parse_nested(tb, TCA_CANFLTR_MAX, tca[TCA_OPTIONS],
+		canfltr_policy);
+	if (err < 0)
+		return err;
+	/* Change existing filter (remove all settings and add
+	them thereafter as if filter was newly created) */
+	if (f != NULL) {
+		if (handle && f->handle != handle)
+			return -EINVAL;
+
+		return canfltr_set_parms(tp, f, base, tb, tca[TCA_RATE]);
+	}
+
+	/* Create new filter */
+	err = -ENOBUFS;
+	f = kzalloc(sizeof(*f), GFP_KERNEL);
+	if (f == NULL)
+		goto errout;
+
+	if (tb[TCA_CANFLTR_CLASSID]) {
+		f->res.classid = nla_get_u32(tb[TCA_U32_CLASSID]);
+		tcf_bind_filter(tp, &f->res, base);
+	}
+
+	err = -EINVAL;
+	if (handle) /* handle passed from userspace */
+		f->handle = handle;
+	else {
+		f->handle = canfltr_gen_handle(tp);
+		if (f->handle == 0)
+			goto errout;
+	}
+
+	/* Configure filter */
+	err = canfltr_set_parms(tp, f, base, tb, tca[TCA_RATE]);
+	if (err < 0)
+		goto errout;
+
+	/* Add newly created filter to list of all filters */
+	tcf_tree_lock(tp);
+	list_add(&f->link, &head->flist);
+	tcf_tree_unlock(tp);
+	*arg = (unsigned long) f;
+
+	return 0;
+
+errout:
+	if (*arg == 0UL && f)
+		kfree(f);
+
+	return err;
+}
+
+
+static void canfltr_delete_filter(struct tcf_proto *tp,
+				struct canfltr_state *f)
+{
+	tcf_unbind_filter(tp, &f->res);
+
+	rcu_barrier();
+	kfree(f->rules->rules_raw);
+	kfree(f->rules);
+	kfree(f);
+}
+
+/**
+ * canfltr_destroy() - Remove whole filter.
+ */
+static void canfltr_destroy(struct tcf_proto *tp)
+{
+	struct canfltr_head *head = tp->root;
+	struct canfltr_state *f, *n;
+
+	list_for_each_entry_safe(f, n, &head->flist, link) {
+		list_del(&f->link);
+		canfltr_delete_filter(tp, f);
+	}
+	kfree(head);
+}
+
+/**
+ * canfltr_delete() - Delete one instance of a filter.
+ */
+static int canfltr_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	struct canfltr_head *head = (struct canfltr_head *)tp->root;
+	struct canfltr_state *t;
+	struct canfltr_state *f = (struct canfltr_state *)arg;
+
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
+
+	list_for_each_entry(t, &head->flist, link)
+		if (t == f) {
+			tcf_tree_lock(tp);
+			list_del(&t->link);
+			tcf_tree_unlock(tp);
+			canfltr_delete_filter(tp, t);
+			return 0;
+		}
+
+	return -ENOENT;
+}
+
+
+/**
+ * canfltr_init() - Initialize filter
+ */
+static int canfltr_init(struct tcf_proto *tp)
+{
+	struct canfltr_head *head;
+
+	if ((tp->protocol != htons(ETH_P_ALL)) &&
+	    (tp->protocol != htons(ETH_P_CAN)))
+		return -1;
+
+	/* Work only on CAN frames */
+	if (tp->protocol == htons(ETH_P_ALL))
+		tp->protocol = htons(ETH_P_CAN);
+
+	head = kzalloc(sizeof(*head), GFP_KERNEL);
+	if (head == NULL)
+		return -ENOBUFS;
+
+	INIT_LIST_HEAD(&head->flist);
+	tp->root = head;
+
+	return 0;
+}
+
+/**
+ * canfltr_walk() - Iterates over all elements of a filter and invokes a
+ * callback function for each of them. This is used to obtain diagnostic data.
+ */
+static void canfltr_walk(struct tcf_proto *tp, struct tcf_walker *arg)
+{
+	struct canfltr_head *head = (struct canfltr_head *) tp->root;
+	struct canfltr_state *f;
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
+/**
+ * canfltr_dump() - Returns diagnostic data for a filter or one of its elements.
+ */
+static int canfltr_dump(struct tcf_proto *tp, unsigned long fh,
+			struct sk_buff *skb, struct tcmsg *t)
+{
+	struct canfltr_state *f = (struct canfltr_state *) fh;
+	struct nlattr *nest;
+	struct canfltr_rules *r;
+
+	if (f == NULL)
+		return skb->len;
+
+	rcu_read_lock();
+	r = rcu_dereference(f->rules);
+	t->tcm_handle = f->handle;
+
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
+
+	if (f->res.classid &&
+	    nla_put_u32(skb, TCA_CANFLTR_CLASSID, f->res.classid))
+		goto nla_put_failure;
+
+	if (nla_put(skb, TCA_CANFLTR_RULES, r->rules_count *
+	    sizeof(struct can_filter), r->rules_raw))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, nest);
+
+	rcu_read_unlock();
+	return skb->len;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nest);
+	rcu_read_unlock();
+	return -1;
+}
+
+
+static struct tcf_proto_ops cls_canfltr_ops __read_mostly = {
+	.kind           =       "can",
+	.classify       =       canfltr_classify,
+	.init           =       canfltr_init,
+	.destroy        =       canfltr_destroy,
+	.get            =       canfltr_get,
+	.put            =       canfltr_put,
+	.change         =       canfltr_change,
+	.delete         =       canfltr_delete,
+	.walk           =       canfltr_walk,
+	.dump           =       canfltr_dump,
+	.owner          =       THIS_MODULE,
+};
+
+static int __init init_canfltr(void)
+{
+	pr_debug("canfltr: CAN filter loaded\n");
+	return register_tcf_proto_ops(&cls_canfltr_ops);
+}
+
+static void __exit exit_canfltr(void)
+{
+	pr_debug("canfltr: CAN filter removed\n");
+	unregister_tcf_proto_ops(&cls_canfltr_ops);
+}
+
+module_init(init_canfltr);
+module_exit(exit_canfltr);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Rostislav Lisovy <lisovy@gmail.cz>");
+MODULE_DESCRIPTION("Controller Area Network classifier");
-- 
1.7.9.5

