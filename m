From: Rostislav Lisovy <lisovy@gmail.com>
Subject: [RFC] net/sched/em_canid: Ematch rule to match CAN frames according to their CAN IDs
Date: Tue, 12 Jun 2012 15:48:33 +0200
Message-ID: <1339508913-7784-1-git-send-email-lisovy@gmail.com>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz,
	Rostislav Lisovy <lisovy@gmail.com>
To: eric.dumazet@gmail.com
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

em_canid is an ematch capable of classifying CAN frames according to
their CAN IDs.

This RFC/Patch contains a reworked classifier initially posted in
http://www.spinics.net/lists/netdev/msg200114.html
The functionality is the same however there is almost 50% reduction
in the source code length.

There is a slight difference between this ematch and other available
ematches. Other ematches implement only a simple match operation and
are meant to be combined with logic conjunctions (e.g. AND, OR).
Our ematch makes it possible to use up to 32 rules in single
'configuration statement' (with OR semantics). This allows us to take
the advantage of the bit field data-structure in the implementation of
the match function.

Example: canid(sff 0x123 eff 0x124 sff 0x230:0x7f0)
This ematch would match CAN SFF frames with the following IDs:
0x123, 0x230--0x23f or EFF frame with ID 0x124.

Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
---
 include/linux/can.h     |    3 +
 include/linux/pkt_cls.h |    5 +-
 net/sched/Kconfig       |   10 +++
 net/sched/Makefile      |    1 +
 net/sched/em_canid.c    |  217 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 234 insertions(+), 2 deletions(-)
 create mode 100644 net/sched/em_canid.c

diff --git a/include/linux/can.h b/include/linux/can.h
index 9a19bcb..08d1610 100644
--- a/include/linux/can.h
+++ b/include/linux/can.h
@@ -38,6 +38,9 @@
  */
 typedef __u32 canid_t;
 
+#define CAN_SFF_ID_BITS		11
+#define CAN_EFF_ID_BITS		29
+
 /*
  * Controller Area Network Error Frame Mask structure
  *
diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index defbde2..6b16f90 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -451,8 +451,9 @@ enum {
 #define	TCF_EM_U32		3
 #define	TCF_EM_META		4
 #define	TCF_EM_TEXT		5
-#define        TCF_EM_VLAN		6
-#define	TCF_EM_MAX		6
+#define TCF_EM_VLAN		6
+#define        TCF_EM_CANID		7
+#define	TCF_EM_MAX		7
 
 enum {
 	TCF_EM_PROG_TC
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 75b58f8..bc0ceab 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -485,6 +485,16 @@ config NET_EMATCH_TEXT
 	  To compile this code as a module, choose M here: the
 	  module will be called em_text.
 
+config NET_EMATCH_CANID
+	tristate "CAN ID"
+	depends on NET_EMATCH && CAN
+	---help---
+          Say Y here if you want to be able to classify CAN frames based
+          on CAN ID.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called em_canid.
+
 config NET_CLS_ACT
 	bool "Actions"
 	---help---
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 8cdf4e2..47f9262 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -53,3 +53,4 @@ obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
 obj-$(CONFIG_NET_EMATCH_U32)	+= em_u32.o
 obj-$(CONFIG_NET_EMATCH_META)	+= em_meta.o
 obj-$(CONFIG_NET_EMATCH_TEXT)	+= em_text.o
+obj-$(CONFIG_NET_EMATCH_CANID)	+= em_canid.o
diff --git a/net/sched/em_canid.c b/net/sched/em_canid.c
new file mode 100644
index 0000000..ef68eef
--- /dev/null
+++ b/net/sched/em_canid.c
@@ -0,0 +1,217 @@
+/*
+ * net/sched/em_canid.c	CAN ID ematch
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors: Rostislav Lisovy (lisovy@gmail.com)
+ */
+
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <net/pkt_cls.h>
+#include <linux/can.h>
+
+#define EM_CAN_RULES_SIZE				32
+
+struct canid_match {
+	struct can_filter rules_raw[EM_CAN_RULES_SIZE]; /* Raw rules copied
+		from netlink message; Used for sending information to
+		userspace (when 'tc filter show' is invoked) AND when
+		matching EFF frames*/
+	DECLARE_BITMAP(match_sff, (1 << CAN_SFF_ID_BITS)); /* For each SFF CAN
+		ID (11 bit) there is one record in this	bitfield */
+	int rules_count;
+	int eff_rules_count;
+	int sff_rules_count;
+
+	struct rcu_head rcu;
+};
+
+/**
+ * em_canid_get_id() - Extracts Can ID out of the sk_buff structure.
+ */
+static canid_t em_canid_get_id(struct sk_buff *skb)
+{
+	/* CAN ID is stored within the data field */
+	struct can_frame *cf = (struct can_frame *)skb->data;
+
+	return cf->can_id;
+}
+
+static void em_canid_sff_match_add(struct canid_match *cm, u32 can_id, u32 can_mask)
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
+		set_bit(can_id, cm->match_sff);
+		return;
+	}
+
+	/* all frames */
+	if (can_mask == 0) {
+		bitmap_fill(cm->match_sff, (1 << CAN_SFF_ID_BITS));
+		return;
+	}
+
+	/* individual frame filter */
+	/* Add record (set bit to 1) for each ID that
+	conforms particular rule */
+	for (i = 0; i < (1 << CAN_SFF_ID_BITS); i++) {
+		if ((i & can_mask) == can_id)
+			set_bit(i, cm->match_sff);
+	}
+}
+
+static inline struct canid_match *em_canid_priv(struct tcf_ematch *m)
+{
+	return (struct canid_match *) (m)->data;
+}
+
+static int em_canid_match(struct sk_buff *skb, struct tcf_ematch *m,
+			 struct tcf_pkt_info *info)
+{
+	struct canid_match *cm = em_canid_priv(m);
+	canid_t can_id;
+	unsigned int match = false;
+	int i;
+
+	can_id = em_canid_get_id(skb);
+
+	if (can_id & CAN_EFF_FLAG) {
+		can_id &= CAN_EFF_MASK;
+
+		for (i = 0; i < cm->eff_rules_count; i++) {
+			if (!(((cm->rules_raw[i].can_id ^ can_id) &
+			    cm->rules_raw[i].can_mask) & CAN_EFF_MASK)) {
+				match = true;
+				break;
+			}
+		}
+	} else { /* SFF */
+		can_id &= CAN_SFF_MASK;
+		match = test_bit(can_id, cm->match_sff);
+	}
+
+	if (match)
+		return 1;
+
+	return 0;
+}
+
+static int em_canid_change(struct tcf_proto *tp, void *data, int len,
+			  struct tcf_ematch *m)
+{
+	struct can_filter *conf = data; /* Array with rules,
+					fixed size EM_CAN_RULES_SIZE */
+	struct canid_match *cm;
+	int err;
+	int i;
+
+	if (len < sizeof(struct can_filter))
+		return -EINVAL;
+
+	err = -ENOBUFS;
+	cm = kzalloc(sizeof(*cm), GFP_KERNEL);
+	if (cm == NULL)
+		goto errout;
+
+	cm->sff_rules_count = 0;
+	cm->eff_rules_count = 0;
+	cm->rules_count = len/sizeof(struct can_filter);
+	err = -EINVAL;
+	if (cm->rules_count > EM_CAN_RULES_SIZE) /* Be sure to fit into the array */
+		goto errout_free;
+
+	/* We need two for() loops for copying rules into
+	two contiguous areas in rules_raw */
+
+	/* Process EFF frame rules*/
+	for (i = 0; i < cm->rules_count; i++) {
+		if ((conf[i].can_id & CAN_EFF_FLAG) &&
+		    (conf[i].can_mask & CAN_EFF_FLAG)) {
+			memcpy(cm->rules_raw + cm->eff_rules_count,
+				&conf[i],
+				sizeof(struct can_filter));
+			cm->eff_rules_count++;
+		} else {
+			continue;
+		}
+	}
+
+	/* Process SFF frame rules */
+	for (i = 0; i < cm->rules_count; i++) {
+		if ((conf[i].can_id & CAN_EFF_FLAG) &&
+		    (conf[i].can_mask & CAN_EFF_FLAG)) {
+			continue;
+		} else {
+			memcpy(cm->rules_raw + cm->eff_rules_count + cm->sff_rules_count,
+				&conf[i],
+				sizeof(struct can_filter));
+			cm->sff_rules_count++;
+			em_canid_sff_match_add(cm,
+				conf[i].can_id, conf[i].can_mask);
+		}
+	}
+
+	m->datalen = sizeof(*cm);
+	m->data = (unsigned long) cm;
+
+	return 0;
+
+errout_free:
+	kfree(cm);
+errout:
+	return err;
+}
+
+static void em_canid_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
+{
+	struct canid_match *cm = em_canid_priv(m);
+
+	kfree(cm);
+}
+
+static int em_canid_dump(struct sk_buff *skb, struct tcf_ematch *m)
+{
+	return 0;
+}
+
+static struct tcf_ematch_ops em_canid_ops = {
+	.kind	  = TCF_EM_CANID,
+	.change	  = em_canid_change,
+	.match	  = em_canid_match,
+	.destroy  = em_canid_destroy,
+	.dump	  = em_canid_dump,
+	.owner	  = THIS_MODULE,
+	.link	  = LIST_HEAD_INIT(em_canid_ops.link)
+};
+
+static int __init init_em_canid(void)
+{
+	return tcf_em_register(&em_canid_ops);
+}
+
+static void __exit exit_em_canid(void)
+{
+	tcf_em_unregister(&em_canid_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_em_canid);
+module_exit(exit_em_canid);
+
+MODULE_ALIAS_TCF_EMATCH(TCF_EM_CANID);
-- 
1.7.9.5

