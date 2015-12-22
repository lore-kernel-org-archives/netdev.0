From: Luuk Paulussen <luuk.paulussen-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>
Subject: [PATCH v2] net-next: Add tcindex to conntrack and add netfilter target/matches
Date: Wed, 23 Dec 2015 10:50:40 +1300
Message-ID: <1450821040-18837-2-git-send-email-luuk.paulussen@alliedtelesis.co.nz>
References: <1450821040-18837-1-git-send-email-luuk.paulussen@alliedtelesis.co.nz>
Cc: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Jozsef Kadlecsik <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Luuk Paulussen <luuk.paulussen-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450821040-18837-1-git-send-email-luuk.paulussen-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch implements support for setting/matching the skb->tc_index
field from Xtables, as well as allowing it to be saved/restored using
connection tracking.

This provides 16 extra bits of mark space that can be saved/restored from
the connection (for performance benefits) when the marking is being done
for tc purposes.

Currently the tc_index field can be set by a number of ingress schedulers,
but if these are not being used, then there is no reason why this field
couldn't also be marked from netfilter.

Once the tc_index field has been set, it can be matched with the existing
tcindex filter in the scheduling code.

Benefits:
1. Marking for tc purposes can be done in this field, alleviating space
   restrictions in generic packet mark.
2. Doesn't increase sk_buff size.
3. tc_index can be saved/restored from connection so that if a flow has
   already been classified, it doesn't have to be done again.
4. save/restore can be done with a mark so that separate marking can be
   done for the two directions of the flow.

Reviewed-by: Matt Bennett <matt.bennett-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>
Reviewed-by: Kyeong Yoo <kyeong.yoo-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>
Signed-off-by: Luuk Paulussen <luuk.paulussen-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>
---
 include/net/netfilter/nf_conntrack.h               |   6 +-
 include/uapi/linux/netfilter/Kbuild                |   4 +
 include/uapi/linux/netfilter/nf_conntrack_common.h |   1 +
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |   1 +
 include/uapi/linux/netfilter/xt_CONNTCINDEX.h      |   6 +
 include/uapi/linux/netfilter/xt_TCINDEX.h          |   6 +
 include/uapi/linux/netfilter/xt_conntcindex.h      |  31 ++++
 include/uapi/linux/netfilter/xt_tcindex.h          |  15 ++
 net/netfilter/Kconfig                              |  30 ++++
 net/netfilter/Makefile                             |   2 +
 net/netfilter/nf_conntrack_netlink.c               |  38 ++++-
 net/netfilter/xt_conntcindex.c                     | 165 +++++++++++++++++++++
 net/netfilter/xt_tcindex.c                         |  84 +++++++++++
 13 files changed, 385 insertions(+), 4 deletions(-)
 create mode 100644 include/uapi/linux/netfilter/xt_CONNTCINDEX.h
 create mode 100644 include/uapi/linux/netfilter/xt_TCINDEX.h
 create mode 100644 include/uapi/linux/netfilter/xt_conntcindex.h
 create mode 100644 include/uapi/linux/netfilter/xt_tcindex.h
 create mode 100644 net/netfilter/xt_conntcindex.c
 create mode 100644 net/netfilter/xt_tcindex.c

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index fde4068..9b0ab48 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -105,7 +105,11 @@ struct nf_conn {
 
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	u_int32_t mark;
-#endif
+
+#ifdef CONFIG_NET_SCHED
+	u_int16_t tc_index;
+#endif /* CONFIG_NET_SCHED */
+#endif /* CONFIG_NF_CONNTRACK_MARK */
 
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 	u_int32_t secmark;
diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index 1d973d2..fedaaab 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -22,6 +22,7 @@ header-y += xt_CHECKSUM.h
 header-y += xt_CLASSIFY.h
 header-y += xt_CONNMARK.h
 header-y += xt_CONNSECMARK.h
+header-y += xt_CONNTCINDEX.h
 header-y += xt_CT.h
 header-y += xt_DSCP.h
 header-y += xt_HMARK.h
@@ -33,6 +34,7 @@ header-y += xt_NFLOG.h
 header-y += xt_NFQUEUE.h
 header-y += xt_RATEEST.h
 header-y += xt_SECMARK.h
+header-y += xt_TCINDEX.h
 header-y += xt_TCPMSS.h
 header-y += xt_TCPOPTSTRIP.h
 header-y += xt_TEE.h
@@ -46,6 +48,7 @@ header-y += xt_connbytes.h
 header-y += xt_connlabel.h
 header-y += xt_connlimit.h
 header-y += xt_connmark.h
+header-y += xt_conntcindex.h
 header-y += xt_conntrack.h
 header-y += xt_cpu.h
 header-y += xt_dccp.h
@@ -81,6 +84,7 @@ header-y += xt_socket.h
 header-y += xt_state.h
 header-y += xt_statistic.h
 header-y += xt_string.h
+header-y += xt_tcindex.h
 header-y += xt_tcpmss.h
 header-y += xt_tcpudp.h
 header-y += xt_time.h
diff --git a/include/uapi/linux/netfilter/nf_conntrack_common.h b/include/uapi/linux/netfilter/nf_conntrack_common.h
index 319f471..b211bb8 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_common.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_common.h
@@ -107,6 +107,7 @@ enum ip_conntrack_events {
 	IPCT_NATSEQADJ = IPCT_SEQADJ,
 	IPCT_SECMARK,		/* new security mark has been set */
 	IPCT_LABEL,		/* new connlabel has been set */
+	IPCT_TCINDEX,		/* new tc_index has been set */
 };
 
 enum ip_conntrack_expect_events {
diff --git a/include/uapi/linux/netfilter/nfnetlink_conntrack.h b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
index c1a4e144..cfdd15f 100644
--- a/include/uapi/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
@@ -53,6 +53,7 @@ enum ctattr_type {
 	CTA_MARK_MASK,
 	CTA_LABELS,
 	CTA_LABELS_MASK,
+	CTA_TC_INDEX,
 	__CTA_MAX
 };
 #define CTA_MAX (__CTA_MAX - 1)
diff --git a/include/uapi/linux/netfilter/xt_CONNTCINDEX.h b/include/uapi/linux/netfilter/xt_CONNTCINDEX.h
new file mode 100644
index 0000000..96eccf3
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_CONNTCINDEX.h
@@ -0,0 +1,6 @@
+#ifndef _XT_CONNTCINDEX_H_target
+#define _XT_CONNTCINDEX_H_target
+
+#include <linux/netfilter/xt_conntcindex.h>
+
+#endif /*_XT_CONNTCINDEX_H_target*/
diff --git a/include/uapi/linux/netfilter/xt_TCINDEX.h b/include/uapi/linux/netfilter/xt_TCINDEX.h
new file mode 100644
index 0000000..a35af8b
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_TCINDEX.h
@@ -0,0 +1,6 @@
+#ifndef _XT_TCINDEX_H_target
+#define _XT_TCINDEX_H_target
+
+#include <linux/netfilter/xt_tcindex.h>
+
+#endif /*_XT_TCINDEX_H_target */
diff --git a/include/uapi/linux/netfilter/xt_conntcindex.h b/include/uapi/linux/netfilter/xt_conntcindex.h
new file mode 100644
index 0000000..d82329a
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_conntcindex.h
@@ -0,0 +1,31 @@
+#ifndef _XT_CONNTCINDEX_H
+#define _XT_CONNTCINDEX_H
+
+#include <linux/types.h>
+
+/* Copyright (C) 2015 Allied Telesis Labs NZ
+ * by Luuk Paulussen <luuk.paulussen-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+enum {
+	XT_CONNTCINDEX_SET = 0,
+	XT_CONNTCINDEX_SAVE,
+	XT_CONNTCINDEX_RESTORE
+};
+
+struct xt_conntcindex_tginfo1 {
+	__u16 ctmark, ctmask, nfmask;
+	__u8 mode;
+};
+
+struct xt_conntcindex_mtinfo1 {
+	__u16 mark, mask;
+	__u8 invert;
+};
+
+#endif /*_XT_CONNTCINDEX_H*/
diff --git a/include/uapi/linux/netfilter/xt_tcindex.h b/include/uapi/linux/netfilter/xt_tcindex.h
new file mode 100644
index 0000000..cb012fa
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_tcindex.h
@@ -0,0 +1,15 @@
+#ifndef _XT_TCINDEX_H
+#define _XT_TCINDEX_H
+
+#include <linux/types.h>
+
+struct xt_tcindex_tginfo1 {
+	__u16 mark, mask;
+};
+
+struct xt_tcindex_mtinfo1 {
+	__u16 mark, mask;
+	__u8 invert;
+};
+
+#endif /*_XT_TCINDEX_H*/
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 4692782..8623157 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -603,6 +603,36 @@ config NETFILTER_XT_CONNMARK
 	ctmark), similarly to the packet mark (nfmark). Using this
 	target and match, you can set and match on this mark.
 
+config NETFILTER_XT_TCINDEX
+	tristate 'tc_index mark target and match support'
+	depends on NETFILTER_ADVANCED
+	depends on NET_SCHED
+	default n
+	---help---
+	This option adds the "TCINDEX" target and "tcindex" match.
+
+	tcindex matching allows you to match packets based on the "tc_index" value
+	in the packet.
+	The target allows you to create rules in the "mangle" table which alter
+	the tc_index field associated with the packet.
+
+	This is an alternative to setting the tc_index field based on the priority
+	fields of the incoming traffic.  In traffic control, this mark can be matched
+	using the tcindex filter.
+
+config NETFILTER_XT_CONNTCINDEX
+	tristate 'ct tc_index mark target and match support'
+	depends on NF_CONNTRACK
+	depends on NF_CONNTRACK_MARK
+	depends on NETFILTER_ADVANCED
+	depends on NET_SCHED
+	default n
+	---help---
+	This option adds the "CONNTCINDEX" target and "conntcindex" match.
+
+	Using this target and match, you can set and match on the tc_index mark in the
+	connection.  This can also be saved/restored to the packet tc_index mark.
+
 config NETFILTER_XT_SET
 	tristate 'set target and match support'
 	depends on IP_SET
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 2293484..d648ae0 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -96,6 +96,8 @@ obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
 # combos
 obj-$(CONFIG_NETFILTER_XT_MARK) += xt_mark.o
 obj-$(CONFIG_NETFILTER_XT_CONNMARK) += xt_connmark.o
+obj-$(CONFIG_NETFILTER_XT_TCINDEX) += xt_tcindex.o
+obj-$(CONFIG_NETFILTER_XT_CONNTCINDEX) += xt_conntcindex.o
 obj-$(CONFIG_NETFILTER_XT_SET) += xt_set.o
 obj-$(CONFIG_NETFILTER_XT_NAT) += xt_nat.o
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9f52729..e33a765 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -314,6 +314,21 @@ nla_put_failure:
 #define ctnetlink_dump_mark(a, b) (0)
 #endif
 
+#if defined CONFIG_NET_SCHED && defined CONFIG_NF_CONNTRACK_MARK
+static inline int
+ctnetlink_dump_tcindex(struct sk_buff *skb, const struct nf_conn *ct)
+{
+	if (nla_put_be16(skb, CTA_TC_INDEX, htonl(ct->tc_index)))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+#else
+#define ctnetlink_dump_tcindex(a, b) (0)
+#endif
+
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 static inline int
 ctnetlink_dump_secctx(struct sk_buff *skb, const struct nf_conn *ct)
@@ -521,6 +536,7 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	    ctnetlink_dump_protoinfo(skb, ct) < 0 ||
 	    ctnetlink_dump_helpinfo(skb, ct) < 0 ||
 	    ctnetlink_dump_mark(skb, ct) < 0 ||
+	    ctnetlink_dump_tcindex(skb, ct) < 0 ||
 	    ctnetlink_dump_secctx(skb, ct) < 0 ||
 	    ctnetlink_dump_labels(skb, ct) < 0 ||
 	    ctnetlink_dump_id(skb, ct) < 0 ||
@@ -749,7 +765,13 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	if ((events & (1 << IPCT_MARK) || ct->mark)
 	    && ctnetlink_dump_mark(skb, ct) < 0)
 		goto nla_put_failure;
-#endif
+
+#ifdef CONFIG_NET_SCHED
+	if ((events & (1 << IPCT_TCINDEX) || ct->tc_index) &&
+	    ctnetlink_dump_tcindex(skb, ct) < 0)
+		goto nla_put_failure;
+#endif /* CONFIG_NET_SCHED */
+#endif /* CONFIG_NF_CONNTRACK_MARK */
 	rcu_read_unlock();
 
 	nlmsg_end(skb, nlh);
@@ -1092,6 +1114,7 @@ static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 				    .len = NF_CT_LABELS_MAX_SIZE },
 	[CTA_LABELS_MASK]	= { .type = NLA_BINARY,
 				    .len = NF_CT_LABELS_MAX_SIZE },
+	[CTA_TC_INDEX]		= { .type = NLA_U16 },
 };
 
 static int ctnetlink_flush_conntrack(struct net *net,
@@ -1697,7 +1720,12 @@ ctnetlink_change_conntrack(struct nf_conn *ct,
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	if (cda[CTA_MARK])
 		ct->mark = ntohl(nla_get_be32(cda[CTA_MARK]));
-#endif
+#ifdef CONFIG_NET_SCHED
+	if (cda[CTA_TC_INDEX])
+		ct->tc_index = ntohs(nla_get_be16(cda[CTA_TC_INDEX]));
+#endif /* CONFIG_NET_SCHED */
+#endif /* CONFIG_NF_CONNTRACK_MARK */
+
 
 	if (cda[CTA_SEQ_ADJ_ORIG] || cda[CTA_SEQ_ADJ_REPLY]) {
 		err = ctnetlink_change_seq_adj(ct, cda);
@@ -1824,7 +1852,11 @@ ctnetlink_create_conntrack(struct net *net,
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	if (cda[CTA_MARK])
 		ct->mark = ntohl(nla_get_be32(cda[CTA_MARK]));
-#endif
+#ifdef CONFIG_NET_SCHED
+	if (cda[CTA_TC_INDEX])
+		ct->tc_index = ntohs(nla_get_be16(cda[CTA_TC_INDEX]));
+#endif /* CONFIG_NET_SCHED */
+#endif /* CONFIG_NF_CONNTRACK_MARK */
 
 	/* setup master conntrack: this is a confirmed expectation */
 	if (cda[CTA_TUPLE_MASTER]) {
diff --git a/net/netfilter/xt_conntcindex.c b/net/netfilter/xt_conntcindex.c
new file mode 100644
index 0000000..1b37562
--- /dev/null
+++ b/net/netfilter/xt_conntcindex.c
@@ -0,0 +1,165 @@
+/*
+ * xt_conntcindex - Netfilter module to operate on connection tc_index marks
+ *
+ * Copyright (C) 2015 Allied Telesis Labs NZ
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * Heavily based on xt_connmark.c
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_ecache.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_conntcindex.h>
+
+MODULE_AUTHOR("Luuk Paulussen <luuk.paulussen-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>");
+MODULE_DESCRIPTION("Xtables: connection tc_index mark operations");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_CONNTCINDEX");
+MODULE_ALIAS("ip6t_CONNTCINDEX");
+MODULE_ALIAS("ipt_conntcindex");
+MODULE_ALIAS("ip6t_conntcindex");
+
+static unsigned int
+conntcindex_tg(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_conntcindex_tginfo1 *info = par->targinfo;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+	u32 newmark;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct)
+		return XT_CONTINUE;
+
+	switch (info->mode) {
+	case XT_CONNTCINDEX_SET:
+		newmark = (ct->tc_index & ~info->ctmask) ^ info->ctmark;
+		if (ct->tc_index != newmark) {
+			ct->tc_index = newmark;
+			nf_conntrack_event_cache(IPCT_TCINDEX, ct);
+		}
+		break;
+	case XT_CONNTCINDEX_SAVE:
+		newmark = (ct->tc_index & ~info->ctmask) ^
+			  (skb->tc_index & info->nfmask);
+		if (ct->tc_index != newmark) {
+			ct->tc_index = newmark;
+			nf_conntrack_event_cache(IPCT_TCINDEX, ct);
+		}
+		break;
+	case XT_CONNTCINDEX_RESTORE:
+		newmark = (skb->tc_index & ~info->nfmask) ^
+			  (ct->tc_index & info->ctmask);
+		skb->tc_index = newmark;
+		break;
+	}
+
+	return XT_CONTINUE;
+}
+
+static int conntcindex_tg_check(const struct xt_tgchk_param *par)
+{
+	int ret;
+
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0)
+		pr_info("cannot load conntrack support for proto=%u\n",
+			par->family);
+	return ret;
+}
+
+static void conntcindex_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	nf_ct_l3proto_module_put(par->family);
+}
+
+static bool
+conntcindex_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_conntcindex_mtinfo1 *info = par->matchinfo;
+	enum ip_conntrack_info ctinfo;
+	const struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct)
+		return false;
+
+	return ((ct->tc_index & info->mask) == info->mark) ^ info->invert;
+}
+
+static int conntcindex_mt_check(const struct xt_mtchk_param *par)
+{
+	int ret;
+
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0)
+		pr_info("cannot load conntrack support for proto=%u\n",
+			par->family);
+	return ret;
+}
+
+static void conntcindex_mt_destroy(const struct xt_mtdtor_param *par)
+{
+	nf_ct_l3proto_module_put(par->family);
+}
+
+static struct xt_target conntcindex_tg_reg __read_mostly = {
+	.name           = "CONNTCINDEX",
+	.revision       = 1,
+	.family         = NFPROTO_UNSPEC,
+	.checkentry     = conntcindex_tg_check,
+	.target         = conntcindex_tg,
+	.targetsize     = sizeof(struct xt_conntcindex_tginfo1),
+	.destroy        = conntcindex_tg_destroy,
+	.me             = THIS_MODULE,
+};
+
+static struct xt_match conntcindex_mt_reg __read_mostly = {
+	.name           = "conntcindex",
+	.revision       = 1,
+	.family         = NFPROTO_UNSPEC,
+	.checkentry     = conntcindex_mt_check,
+	.match          = conntcindex_mt,
+	.matchsize      = sizeof(struct xt_conntcindex_mtinfo1),
+	.destroy        = conntcindex_mt_destroy,
+	.me             = THIS_MODULE,
+};
+
+static int __init conntcindex_mt_init(void)
+{
+	int ret;
+
+	ret = xt_register_target(&conntcindex_tg_reg);
+	if (ret < 0)
+		return ret;
+	ret = xt_register_match(&conntcindex_mt_reg);
+	if (ret < 0) {
+		xt_unregister_target(&conntcindex_tg_reg);
+		return ret;
+	}
+	return 0;
+}
+
+static void __exit conntcindex_mt_exit(void)
+{
+	xt_unregister_match(&conntcindex_mt_reg);
+	xt_unregister_target(&conntcindex_tg_reg);
+}
+
+module_init(conntcindex_mt_init);
+module_exit(conntcindex_mt_exit);
diff --git a/net/netfilter/xt_tcindex.c b/net/netfilter/xt_tcindex.c
new file mode 100644
index 0000000..7de29cd
--- /dev/null
+++ b/net/netfilter/xt_tcindex.c
@@ -0,0 +1,84 @@
+/*
+ *	xt_tcindex - Netfilter module to match/tag on tc_index mark value
+ *
+ *	(C) 2015 Allied Telesis Labs NZ.
+  *
+ *	This program is free software; you can redistribute it and/or modify
+ *	it under the terms of the GNU General Public License version 2 as
+ *	published by the Free Software Foundation.
+ *
+ *	Heavily based on xt_mark.c
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter/xt_tcindex.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Luuk Paulussen <luuk.paulussen-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>");
+MODULE_DESCRIPTION("Xtables: packet tc_index mark operations");
+MODULE_ALIAS("ipt_tcindex");
+MODULE_ALIAS("ip6t_tcindex");
+MODULE_ALIAS("ipt_TCINDEX");
+MODULE_ALIAS("ip6t_TCINDEX");
+
+static unsigned int
+tcindex_tg(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_tcindex_tginfo1 *info = par->targinfo;
+
+	skb->tc_index = (skb->tc_index & ~info->mask) ^ info->mark;
+	return XT_CONTINUE;
+}
+
+static bool
+tcindex_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_tcindex_mtinfo1 *info = par->matchinfo;
+
+	return ((skb->tc_index & info->mask) == info->mark) ^ info->invert;
+}
+
+static struct xt_target tcindex_tg_reg __read_mostly = {
+	.name           = "TCINDEX",
+	.revision       = 1,
+	.family         = NFPROTO_UNSPEC,
+	.target         = tcindex_tg,
+	.targetsize     = sizeof(struct xt_tcindex_tginfo1),
+	.me             = THIS_MODULE,
+};
+
+static struct xt_match tcindex_mt_reg __read_mostly = {
+	.name           = "tcindex",
+	.revision       = 1,
+	.family         = NFPROTO_UNSPEC,
+	.match          = tcindex_mt,
+	.matchsize      = sizeof(struct xt_tcindex_mtinfo1),
+	.me             = THIS_MODULE,
+};
+
+static int __init tcindex_mt_init(void)
+{
+	int ret;
+
+	ret = xt_register_target(&tcindex_tg_reg);
+	if (ret < 0)
+		return ret;
+	ret = xt_register_match(&tcindex_mt_reg);
+	if (ret < 0) {
+		xt_unregister_target(&tcindex_tg_reg);
+		return ret;
+	}
+	return 0;
+}
+
+static void __exit tcindex_mt_exit(void)
+{
+	xt_unregister_match(&tcindex_mt_reg);
+	xt_unregister_target(&tcindex_tg_reg);
+}
+
+module_init(tcindex_mt_init);
+module_exit(tcindex_mt_exit);
-- 
2.6.4
