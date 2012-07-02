From: Rostislav Lisovy <lisovy@gmail.com>
Subject: [PATCH net-next v3] em_canid: Ematch rule to match CAN frames according to their identifiers
Date: Mon,  2 Jul 2012 17:06:08 +0200
Message-ID: <1341241568-13438-1-git-send-email-lisovy@gmail.com>
Cc: linux-can@vger.kernel.org, lartc@vger.kernel.org,
	pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz,
	Rostislav Lisovy <lisovy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This ematch makes it possible to classify CAN frames (AF_CAN) according
to their identifiers. This functionality can not be easily achieved with
existing classifiers, such as u32, because CAN identifier is always stored
in native endianness, whereas u32 expects Network byte order.

Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
---
Results of simple benchmark are available at address:
  http://rtime.felk.cvut.cz/~lisovros/em_canid_benchmark.pdf
In short: there is no significant difference between em_canid and cls_can
(i.e. stand-alone AF_CAN classifier).

Changes in v3:
  * Added zero-length check for configuration data
  * Small fixes in patch format (patch created against net-next)

Changes in v2:
  * Integrated remarks received from the mailing list
  * Array containing rules (rules_raw) is dynamically allocated
  * When processing a rule during configuration, CAN_EFF_FLAG in mask
    determines if we care about the value of CAN_EFF_FLAG in an identifier
    -- i.e. when CAN_EFF_FLAG is set in the mask, the rule will be added
    as SFF or EFF only depending on CAN_EFF_FLAG value in the identifier.
    If CAN_EFF_FLAG is 0 in the mask, the rule will be added as both SFF
    and EFF.

---
 include/linux/can.h     |    3 +
 include/linux/pkt_cls.h |    5 +-
 net/sched/Kconfig       |   10 ++
 net/sched/Makefile      |    1 +
 net/sched/em_canid.c    |  250 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 267 insertions(+), 2 deletions(-)
 create mode 100644 net/sched/em_canid.c

diff --git a/include/linux/can.h b/include/linux/can.h
index 1a66cf61..018055e 100644
--- a/include/linux/can.h
+++ b/include/linux/can.h
@@ -38,6 +38,9 @@
  */
 typedef __u32 canid_t;
 
+#define CAN_SFF_ID_BITS		11
+#define CAN_EFF_ID_BITS		29
+
 /*
  * Controller Area Network Error Message Frame Mask structure
  *
diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index defbde2..7fbe6c2 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -451,8 +451,9 @@ enum {
 #define	TCF_EM_U32		3
 #define	TCF_EM_META		4
 #define	TCF_EM_TEXT		5
-#define        TCF_EM_VLAN		6
-#define	TCF_EM_MAX		6
+#define	TCF_EM_VLAN		6
+#define        TCF_EM_CANID		7
+#define	TCF_EM_MAX		7
 
 enum {
 	TCF_EM_PROG_TC
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index e7a8976..8f759b6 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -507,6 +507,16 @@ config NET_EMATCH_TEXT
 	  To compile this code as a module, choose M here: the
 	  module will be called em_text.
 
+config NET_EMATCH_CANID
+	tristate "CAN Identifier"
+	depends on NET_EMATCH && CAN
+	---help---
+          Say Y here if you want to be able to classify CAN frames based
+          on CAN Identifier.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called em_canid.
+
 config NET_CLS_ACT
 	bool "Actions"
 	---help---
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 5940a19..bcada75 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -55,3 +55,4 @@ obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
 obj-$(CONFIG_NET_EMATCH_U32)	+= em_u32.o
 obj-$(CONFIG_NET_EMATCH_META)	+= em_meta.o
 obj-$(CONFIG_NET_EMATCH_TEXT)	+= em_text.o
+obj-$(CONFIG_NET_EMATCH_CANID)	+= em_canid.o
diff --git a/net/sched/em_canid.c b/net/sched/em_canid.c
new file mode 100644
index 0000000..f12ce98
--- /dev/null
+++ b/net/sched/em_canid.c
@@ -0,0 +1,250 @@
+/*
+ * em_canid.c  Ematch rule to match CAN frames according to their CAN IDs
+ *
+ *              This program is free software; you can distribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Idea:       Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
+ * Copyright:  (c) 2011 Czech Technical University in Prague
+ *             (c) 2011 Volkswagen Group Research
+ * Authors:    Michal Sojka <sojkam1@fel.cvut.cz>
+ *             Pavel Pisa <pisa@cmp.felk.cvut.cz>
+ *             Rostislav Lisovy <lisovy@gmail.cz>
+ * Funded by:  Volkswagen Group Research
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
+#define EM_CAN_RULES_MAX 500
+
+struct canid_match {
+	/* For each SFF CAN ID (11 bit) there is one record in this bitfield */
+	DECLARE_BITMAP(match_sff, (1 << CAN_SFF_ID_BITS));
+
+	int rules_count;
+	int sff_rules_count;
+	int eff_rules_count;
+
+	/*
+	 * Raw rules copied from netlink message; Used for sending
+	 * information to userspace (when 'tc filter show' is invoked)
+	 * AND when matching EFF frames
+	 */
+	struct can_filter rules_raw[];
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
+static void em_canid_sff_match_add(struct canid_match *cm, u32 can_id,
+					u32 can_mask)
+{
+	int i;
+
+	/*
+	 * Limit can_mask and can_id to SFF range to
+	 * protect against write after end of array
+	 */
+	can_mask &= CAN_SFF_MASK;
+	can_id &= can_mask;
+
+	/* Single frame */
+	if (can_mask == CAN_SFF_MASK) {
+		set_bit(can_id, cm->match_sff);
+		return;
+	}
+
+	/* All frames */
+	if (can_mask == 0) {
+		bitmap_fill(cm->match_sff, (1 << CAN_SFF_ID_BITS));
+		return;
+	}
+
+	/*
+	 * Individual frame filter.
+	 * Add record (set bit to 1) for each ID that
+	 * conforms particular rule
+	 */
+	for (i = 0; i < (1 << CAN_SFF_ID_BITS); i++) {
+		if ((i & can_mask) == can_id)
+			set_bit(i, cm->match_sff);
+	}
+}
+
+static inline struct canid_match *em_canid_priv(struct tcf_ematch *m)
+{
+	return (struct canid_match *)m->data;
+}
+
+static int em_canid_match(struct sk_buff *skb, struct tcf_ematch *m,
+			 struct tcf_pkt_info *info)
+{
+	struct canid_match *cm = em_canid_priv(m);
+	canid_t can_id;
+	int match = 0;
+	int i;
+	const struct can_filter *lp;
+
+	can_id = em_canid_get_id(skb);
+
+	if (can_id & CAN_EFF_FLAG) {
+		for (i = 0, lp = cm->rules_raw;
+		     i < cm->eff_rules_count; i++, lp++) {
+			if (!(((lp->can_id ^ can_id) & lp->can_mask))) {
+				match = 1;
+				break;
+			}
+		}
+	} else { /* SFF */
+		can_id &= CAN_SFF_MASK;
+		match = (test_bit(can_id, cm->match_sff) ? 1 : 0);
+	}
+
+	return match;
+}
+
+static int em_canid_change(struct tcf_proto *tp, void *data, int len,
+			  struct tcf_ematch *m)
+{
+	struct can_filter *conf = data; /* Array with rules,
+					 * fixed size EM_CAN_RULES_SIZE
+					 */
+	struct canid_match *cm;
+	struct canid_match *cm_old = (struct canid_match *)m->data;
+	int i;
+	int rulescnt;
+
+	if (!len)
+		return -EINVAL;
+
+	if (len % sizeof(struct can_filter))
+		return -EINVAL;
+
+	if (len > sizeof(struct can_filter) * EM_CAN_RULES_MAX)
+		return -EINVAL;
+
+	rulescnt = len / sizeof(struct can_filter);
+
+	cm = kzalloc(sizeof(struct canid_match) + sizeof(struct can_filter) *
+		rulescnt, GFP_KERNEL);
+	if (!cm)
+		return -ENOMEM;
+
+	cm->sff_rules_count = 0;
+	cm->eff_rules_count = 0;
+	cm->rules_count = rulescnt;
+
+	/*
+	 * We need two for() loops for copying rules into
+	 * two contiguous areas in rules_raw
+	 */
+
+	/* Process EFF frame rules*/
+	for (i = 0; i < cm->rules_count; i++) {
+		if (((conf[i].can_id & CAN_EFF_FLAG) &&
+		    (conf[i].can_mask & CAN_EFF_FLAG)) ||
+		    !(conf[i].can_mask & CAN_EFF_FLAG)) {
+			memcpy(cm->rules_raw + cm->eff_rules_count,
+				&conf[i],
+				sizeof(struct can_filter));
+
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
+			memcpy(cm->rules_raw
+				+ cm->eff_rules_count
+				+ cm->sff_rules_count,
+				&conf[i], sizeof(struct can_filter));
+
+			cm->sff_rules_count++;
+
+			em_canid_sff_match_add(cm,
+				conf[i].can_id, conf[i].can_mask);
+		}
+	}
+
+	m->datalen = sizeof(*cm);
+	m->data = (unsigned long)cm;
+
+	if (cm_old != NULL) {
+		pr_err("canid: Configuring an existing ematch!\n");
+		kfree(cm_old);
+	}
+
+	return 0;
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
+	struct canid_match *cm = em_canid_priv(m);
+
+	/*
+	 * When configuring this ematch 'rules_count' is set not to exceed
+	 * 'rules_raw' array size
+	 */
+	if (nla_put_nohdr(skb, sizeof(struct can_filter) * cm->rules_count,
+	    &cm->rules_raw) < 0)
+		return -EMSGSIZE;
+
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
1.7.10

