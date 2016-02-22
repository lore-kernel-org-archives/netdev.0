From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 1/5] introduce IFE action
Date: Mon, 22 Feb 2016 08:21:40 -0500
Message-ID: <1456147304-13355-2-git-send-email-jhs@emojatatu.com>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33012 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217AbcBVNV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 08:21:57 -0500
Received: by mail-io0-f174.google.com with SMTP id z135so176661759iof.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 05:21:57 -0800 (PST)
In-Reply-To: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

This action allows for a sending side to encapsulate arbitrary metadata
which is decapsulated by the receiving end.
The sender runs in encoding mode and the receiver in decode mode.
Both sender and receiver must specify the same ethertype.
At some point we hope to have a registered ethertype and we'll
then provide a default so the user doesnt have to specify it.
For now we enforce the user specify it.

Lets show example usage where we encode icmp from a sender towards
a receiver with an skbmark of 17; both sender and receiver use
ethertype of 0xdead to interop.

YYYY: Lets start with Receiver-side policy config:
xxx: add an ingress qdisc
sudo tc qdisc add dev $ETH ingress

xxx: any packets with ethertype 0xdead will be subjected to ife decoding
xxx: we then restart the classification so we can match on icmp at prio 3
sudo $TC filter add dev $ETH parent ffff: prio 2 protocol 0xdead \
u32 match u32 0 0 flowid 1:1 \
action ife decode reclassify

xxx: on restarting the classification from above if it was an icmp
xxx: packet, then match it here and continue to the next rule at prio 4
xxx: which will match based on skb mark of 17
sudo tc filter add dev $ETH parent ffff: prio 3 protocol ip \
u32 match ip protocol 1 0xff flowid 1:1 \
action continue

xxx: match on skbmark of 0x11 (decimal 17) and accept
sudo tc filter add dev $ETH parent ffff: prio 4 protocol ip \
handle 0x11 fw flowid 1:1 \
action ok

xxx: Lets show the decoding policy
sudo tc -s filter ls dev $ETH parent ffff: protocol 0xdead
xxx:
filter pref 2 u32
filter pref 2 u32 fh 800: ht divisor 1
filter pref 2 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1  (rule hit 0 success 0)
  match 00000000/00000000 at 0 (success 0 )
        action order 1: ife decode action reclassify
         index 1 ref 1 bind 1 installed 14 sec used 14 sec
         type: 0x0
         Metadata: allow mark allow hash allow prio allow qmap
        Action statistics:
        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
        backlog 0b 0p requeues 0
xxx:
Observe that above lists all metadatum it can decode. Typically these
submodules will already be compiled into a monolithic kernel or
loaded as modules

YYYY: Lets show the sender side now ..

xxx: Add an egress qdisc on the sender netdev
sudo tc qdisc add dev $ETH root handle 1: prio
xxx:
xxx: Match all icmp packets to 192.168.122.237/24, then
xxx: tag the packet with skb mark of decimal 17, then
xxx: Encode it with:
xxx:	ethertype 0xdead
xxx:	add skb->mark to whitelist of metadatum to send
xxx:	rewrite target dst MAC address to 02:15:15:15:15:15
xxx:
sudo $TC filter add dev $ETH parent 1: protocol ip prio 10  u32 \
match ip dst 192.168.122.237/24 \
match ip protocol 1 0xff \
flowid 1:2 \
action skbedit mark 17 \
action ife encode \
type 0xDEAD \
allow mark \
dst 02:15:15:15:15:15

xxx: Lets show the encoding policy
sudo tc -s filter ls dev $ETH parent 1: protocol ip
xxx:
filter pref 10 u32
filter pref 10 u32 fh 800: ht divisor 1
filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:2  (rule hit 0 success 0)
  match c0a87aed/ffffffff at 16 (success 0 )
  match 00010000/00ff0000 at 8 (success 0 )

	action order 1:  skbedit mark 17
	 index 6 ref 1 bind 1
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

	action order 2: ife encode action pipe
	 index 3 ref 1 bind 1
	 dst MAC: 02:15:15:15:15:15 type: 0xDEAD
 	 Metadata: allow mark
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0
xxx:

test by sending ping from sender to destination

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/tc_act/tc_ife.h        |  60 +++
 include/uapi/linux/tc_act/tc_ife.h |  38 ++
 net/sched/Kconfig                  |  12 +
 net/sched/Makefile                 |   1 +
 net/sched/act_ife.c                | 865 +++++++++++++++++++++++++++++++++++++
 5 files changed, 976 insertions(+)
 create mode 100644 include/net/tc_act/tc_ife.h
 create mode 100644 include/uapi/linux/tc_act/tc_ife.h
 create mode 100644 net/sched/act_ife.c

diff --git a/include/net/tc_act/tc_ife.h b/include/net/tc_act/tc_ife.h
new file mode 100644
index 0000000..fbbc23c
--- /dev/null
+++ b/include/net/tc_act/tc_ife.h
@@ -0,0 +1,60 @@
+#ifndef __NET_TC_IFE_H
+#define __NET_TC_IFE_H
+
+#include <net/act_api.h>
+#include <linux/etherdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/module.h>
+
+#define IFE_METAHDRLEN 2
+struct tcf_ife_info {
+	struct tcf_common common;
+	u8 eth_dst[ETH_ALEN];
+	u8 eth_src[ETH_ALEN];
+	u16 eth_type;
+	u16 flags;
+	/* list of metaids allowed */
+	struct list_head metalist;
+};
+#define to_ife(a) \
+	container_of(a->priv, struct tcf_ife_info, common)
+
+struct tcf_meta_info {
+	const struct tcf_meta_ops *ops;
+	void *metaval;
+	u16 metaid;
+	struct list_head metalist;
+};
+
+struct tcf_meta_ops {
+	u16 metaid; /*Maintainer provided ID */
+	u16 metatype; /*netlink attribute type (look at net/netlink.h) */
+	const char *name;
+	const char *synopsis;
+	struct list_head list;
+	int	(*check_presence)(struct sk_buff *, struct tcf_meta_info *);
+	int	(*encode)(struct sk_buff *, void *, struct tcf_meta_info *);
+	int	(*decode)(struct sk_buff *, void *, u16 len);
+	int	(*get)(struct sk_buff *skb, struct tcf_meta_info *mi);
+	int	(*alloc)(struct tcf_meta_info *, void *);
+	void	(*release)(struct tcf_meta_info *);
+	int	(*validate)(void *val, int len);
+	struct module	*owner;
+};
+
+#define MODULE_ALIAS_IFE_META(metan)   MODULE_ALIAS("ifemeta" __stringify_1(metan))
+
+int get_meta_u32(struct sk_buff *skb, struct tcf_meta_info *mi);
+int get_meta_u16(struct sk_buff *skb, struct tcf_meta_info *mi);
+int tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval);
+int alloc_meta_u32(struct tcf_meta_info *mi, void *metaval);
+int alloc_meta_u16(struct tcf_meta_info *mi, void *metaval);
+int check_meta_u32(u32 metaval, struct tcf_meta_info *mi);
+int encode_meta_u32(u32 metaval, void *skbdata, struct tcf_meta_info *mi);
+int validate_meta_u32(void *val, int len);
+int validate_meta_u16(void *val, int len);
+void release_meta_gen(struct tcf_meta_info *mi);
+int register_ife_op(struct tcf_meta_ops *mops);
+int unregister_ife_op(struct tcf_meta_ops *mops);
+
+#endif /* __NET_TC_IFE_H */
diff --git a/include/uapi/linux/tc_act/tc_ife.h b/include/uapi/linux/tc_act/tc_ife.h
new file mode 100644
index 0000000..f11bcda
--- /dev/null
+++ b/include/uapi/linux/tc_act/tc_ife.h
@@ -0,0 +1,38 @@
+#ifndef __UAPI_TC_IFE_H
+#define __UAPI_TC_IFE_H
+
+#include <linux/types.h>
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_IFE 25
+/* Flag bits for now just encoding/decoding */
+#define IFE_ENCODE 1
+#define IFE_DECODE 2
+
+struct tc_ife {
+	tc_gen;
+	__u16 flags;
+};
+
+/*XXX: We need to encode the total number of bytes consumed */
+enum {
+	TCA_IFE_UNSPEC,
+	TCA_IFE_PARMS,
+	TCA_IFE_TM,
+	TCA_IFE_DMAC,
+	TCA_IFE_SMAC,
+	TCA_IFE_TYPE,
+	TCA_IFE_METALST,
+	__TCA_IFE_MAX
+};
+#define TCA_IFE_MAX (__TCA_IFE_MAX - 1)
+
+#define IFE_META_SKBMARK 1
+#define IFE_META_HASHID 2
+#define	IFE_META_PRIO 3
+#define	IFE_META_QMAP 4
+/*Can be overriden at runtime by module option*/
+#define	__IFE_META_MAX 5
+#define IFE_META_MAX (__IFE_META_MAX - 1)
+
+#endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 8283082..4d48ef5 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -739,6 +739,18 @@ config NET_ACT_CONNMARK
 	  To compile this code as a module, choose M here: the
 	  module will be called act_connmark.
 
+config NET_ACT_IFE
+        tristate "Inter-FE action based on IETF ForCES InterFE LFB"
+        depends on NET_CLS_ACT
+        ---help---
+	  Say Y here to allow for sourcing and terminating metadata
+	  For details refer to netdev01 paper:
+	  "Distributing Linux Traffic Control Classifier-Action Subsystem"
+	   Authors: Jamal Hadi Salim and Damascene M. Joachimpillai
+
+	  To compile this code as a module, choose M here: the
+	  module will be called act_ife.
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 690c1689..3d17667 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_NET_ACT_CSUM)	+= act_csum.o
 obj-$(CONFIG_NET_ACT_VLAN)	+= act_vlan.o
 obj-$(CONFIG_NET_ACT_BPF)	+= act_bpf.o
 obj-$(CONFIG_NET_ACT_CONNMARK)	+= act_connmark.o
+obj-$(CONFIG_NET_ACT_IFE)	+= act_ife.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
new file mode 100644
index 0000000..153a202
--- /dev/null
+++ b/net/sched/act_ife.c
@@ -0,0 +1,865 @@
+/*
+ * net/sched/ife.c	Inter-FE action based on ForCES WG InterFE LFB
+ *
+ *		Refer to:
+ *		draft-ietf-forces-interfelfb-03
+ *		and
+ *		netdev01 paper:
+ *		"Distributing Linux Traffic Control Classifier-Action
+ *		Subsystem"
+ *		Authors: Jamal Hadi Salim and Damascene M. Joachimpillai
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * copyright 	Jamal Hadi Salim (2015)
+ *
+*/
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+#include <uapi/linux/tc_act/tc_ife.h>
+#include <net/tc_act/tc_ife.h>
+#include <linux/etherdevice.h>
+
+#define IFE_TAB_MASK	15
+
+static int max_metacnt = IFE_META_MAX + 1;
+static const struct nla_policy ife_policy[TCA_IFE_MAX + 1] = {
+	[TCA_IFE_PARMS] = {.len = sizeof(struct tc_ife)},
+	[TCA_IFE_DMAC] = {.type = NLA_BINARY,.len = ETH_ALEN},
+	[TCA_IFE_SMAC] = {.type = NLA_BINARY,.len = ETH_ALEN},
+	[TCA_IFE_TYPE] = {.type = NLA_U16},
+};
+
+/*
+ * Caller takes care of presenting data in network order
+*/
+int tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
+{
+	u32 *tlv = (u32 *) (skbdata);
+	u16 totlen = nla_total_size(dlen);	/*alignment + hdr */
+	char *dptr = (char *)tlv + NLA_HDRLEN;
+	u32 htlv = attrtype << 16 | totlen;
+
+	*tlv = htonl(htlv);
+	memset(dptr, 0, totlen - NLA_HDRLEN);
+	memcpy(dptr, dval, dlen);
+
+	return totlen;
+}
+EXPORT_SYMBOL_GPL(tlv_meta_encode);
+
+int get_meta_u32(struct sk_buff *skb, struct tcf_meta_info *mi)
+{
+	if (mi->metaval)
+		return nla_put_u32(skb, mi->metaid, *(u32 *) mi->metaval);
+	else
+		return nla_put(skb, mi->metaid, 0, NULL);
+}
+EXPORT_SYMBOL_GPL(get_meta_u32);
+
+int check_meta_u32(u32 metaval, struct tcf_meta_info *mi)
+{
+	if (metaval || mi->metaval)
+		return 8;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(check_meta_u32);
+
+int encode_meta_u32(u32 metaval, void *skbdata, struct tcf_meta_info *mi)
+{
+	u32 edata = metaval;
+
+	if (mi->metaval)
+		edata = *(u32 *)mi->metaval;
+	else if (metaval)
+		edata = metaval;
+
+	if (!edata) /* will not encode */
+		return 0;
+
+	edata = htonl(edata);
+	return tlv_meta_encode(skbdata, mi->metaid, 4, &edata);
+}
+EXPORT_SYMBOL_GPL(encode_meta_u32);
+
+int get_meta_u16(struct sk_buff *skb, struct tcf_meta_info *mi)
+{
+	if (mi->metaval)
+		return nla_put_u16(skb, mi->metaid, *(u16 *) mi->metaval);
+	else
+		return nla_put(skb, mi->metaid, 0, NULL);
+}
+EXPORT_SYMBOL_GPL(get_meta_u16);
+
+int alloc_meta_u32(struct tcf_meta_info *mi, void *metaval)
+{
+	mi->metaval = kzalloc(sizeof(u32), GFP_KERNEL);
+	if (!mi->metaval)
+		return -ENOMEM;
+
+	memcpy(mi->metaval, metaval, 4);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(alloc_meta_u32);
+
+int alloc_meta_u16(struct tcf_meta_info *mi, void *metaval)
+{
+	mi->metaval = kzalloc(sizeof(u16), GFP_KERNEL);
+	if (!mi->metaval)
+		return -ENOMEM;
+
+	memcpy(mi->metaval, metaval, 2);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(alloc_meta_u16);
+
+void release_meta_gen(struct tcf_meta_info *mi)
+{
+	kfree(mi->metaval);
+}
+
+EXPORT_SYMBOL_GPL(release_meta_gen);
+
+int validate_meta_u32(void *val, int len)
+{
+	if (len == 4)
+		return 0;
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL_GPL(validate_meta_u32);
+
+int validate_meta_u16(void *val, int len)
+{
+	/* length will include padding */
+	if (len == NLA_ALIGN(2))
+		return 0;
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL_GPL(validate_meta_u16);
+
+static LIST_HEAD(ifeoplist);
+static DEFINE_RWLOCK(ife_mod_lock);
+
+struct tcf_meta_ops *find_ife_oplist(u16 metaid)
+{
+	struct tcf_meta_ops *o;
+
+	read_lock(&ife_mod_lock);
+	list_for_each_entry(o, &ifeoplist, list) {
+		if (o->metaid == metaid) {
+			if (!try_module_get(o->owner))
+				o = NULL;
+			read_unlock(&ife_mod_lock);
+			return o;
+		}
+	}
+	read_unlock(&ife_mod_lock);
+
+	return NULL;
+}
+
+int register_ife_op(struct tcf_meta_ops *mops)
+{
+	struct tcf_meta_ops *m;
+
+	if (!mops->metaid || !mops->metatype || !mops->name ||
+	    !mops->check_presence || !mops->encode || !mops->decode ||
+	    !mops->get || !mops->alloc)
+		return -EINVAL;
+
+	write_lock(&ife_mod_lock);
+
+	list_for_each_entry(m, &ifeoplist, list) {
+		if (m->metaid == mops->metaid ||
+		    (strcmp(mops->name, m->name) == 0)) {
+			write_unlock(&ife_mod_lock);
+			return -EEXIST;
+		}
+	}
+
+	if (!mops->release)
+		mops->release = release_meta_gen;
+
+	INIT_LIST_HEAD(&mops->list);
+	list_add_tail(&mops->list, &ifeoplist);
+	write_unlock(&ife_mod_lock);
+	return 0;
+}
+
+int unregister_ife_op(struct tcf_meta_ops *mops)
+{
+	struct tcf_meta_ops *m;
+	int err = -ENOENT;
+
+	write_lock(&ife_mod_lock);
+	list_for_each_entry(m, &ifeoplist, list) {
+		if (m->metaid == mops->metaid) {
+			list_del(&mops->list);
+			err = 0;
+			break;
+		}
+	}
+	write_unlock(&ife_mod_lock);
+
+	return err;
+}
+
+EXPORT_SYMBOL_GPL(register_ife_op);
+EXPORT_SYMBOL_GPL(unregister_ife_op);
+
+void print_ife_oplist(void)
+{
+	struct tcf_meta_ops *o;
+	int i = 0;
+
+	read_lock(&ife_mod_lock);
+	list_for_each_entry(o, &ifeoplist, list) {
+		pr_debug("%d: %s metaid %d\n", ++i, o->name, o->metaid);
+	}
+	read_unlock(&ife_mod_lock);
+}
+
+/* called when adding new meta information
+ * under ife->tcf_lock
+*/
+int load_metaops_and_vet(struct tcf_ife_info *ife, u32 metaid,
+			 void *val, int len)
+{
+	struct tcf_meta_ops *ops = find_ife_oplist(metaid);
+	int ret = 0;
+
+	if (!ops) {
+		ret = -ENOENT;
+#ifdef CONFIG_MODULES
+		spin_unlock_bh(&ife->tcf_lock);
+		rtnl_unlock();
+		request_module("ifemeta%u", metaid);
+		rtnl_lock();
+		spin_lock_bh(&ife->tcf_lock);
+		ops = find_ife_oplist(metaid);
+#endif
+	}
+
+	if (ops) {
+		ret = 0;
+
+		/* XXX: unfortunately cant use nla_policy at this point
+		 * because a length of 0 is valid in the case of 
+		 * "allow". "use" semantics do enforce for proper
+		 * length and i couldve use nla_policy but it makes it hard
+		 * to use it just for that..
+		 */
+		if (len) {
+			if (ops->validate) {
+				ret = ops->validate(val, len);
+			} else {
+				if (ops->metatype == NLA_U32) {
+					ret = validate_meta_u32(val, len);
+				} else if (ops->metatype == NLA_U16) {
+					ret = validate_meta_u16(val, len);
+				}
+			}
+		}
+
+		module_put(ops->owner);
+	}
+
+	return ret;
+}
+
+/* called when adding new meta information
+ * under ife->tcf_lock
+*/
+int add_metainfo(struct tcf_ife_info *ife, u32 metaid, void *metaval, int len)
+{
+	struct tcf_meta_info *mi = NULL;
+	struct tcf_meta_ops *ops = find_ife_oplist(metaid);
+	int ret = 0;
+
+	if (!ops) {
+		return -ENOENT;
+	}
+
+	mi = kzalloc(sizeof(*mi), GFP_KERNEL);
+	if (!mi) {
+		/*put back what find_ife_oplist took */
+		module_put(ops->owner);
+		return -ENOMEM;
+	}
+
+	mi->metaid = metaid;
+	mi->ops = ops;
+	if (len > 0) {
+		ret = ops->alloc(mi, metaval);
+		if (ret != 0) {
+			kfree(mi);
+			module_put(ops->owner);
+			return ret;
+		}
+	}
+
+	/*XXX: if it becomes necessary add per tcf_meta_info lock;
+	 * for now use Thor's hammer */
+	write_lock(&ife_mod_lock);
+	list_add_tail(&mi->metalist, &ife->metalist);
+	write_unlock(&ife_mod_lock);
+
+	return ret;
+}
+
+int use_all_metadata(struct tcf_ife_info *ife)
+{
+	struct tcf_meta_ops *o;
+	int rc = 0;
+	int installed = 0;
+
+	list_for_each_entry(o, &ifeoplist, list) {
+		rc = add_metainfo(ife, o->metaid, NULL, 0);
+		if (rc == 0)
+			installed +=1;
+	}
+
+	if (installed)
+		return 0;
+	else
+		return -EINVAL;
+}
+
+int dump_metalist(struct sk_buff *skb, struct tcf_ife_info *ife)
+{
+	struct tcf_meta_info *e;
+	struct nlattr *nest;
+	unsigned char *b = skb_tail_pointer(skb);
+	int total_encoded = 0;
+
+	/*can only happen on decode */
+	if (list_empty(&ife->metalist))
+		return 0;
+
+	nest = nla_nest_start(skb, TCA_IFE_METALST);
+	if (nest == NULL)
+		goto out_nlmsg_trim;
+
+	list_for_each_entry(e, &ife->metalist, metalist) {
+		if (!e->ops->get(skb, e))
+			total_encoded += 1;
+	}
+
+	if (!total_encoded)
+		goto out_nlmsg_trim;
+
+	nla_nest_end(skb, nest);
+
+	return 0;
+
+out_nlmsg_trim:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+/* under ife->tcf_lock */
+static void _tcf_ife_cleanup(struct tc_action *a, int bind)
+{
+	struct tcf_ife_info *ife = a->priv;
+	struct tcf_meta_info *e, *n;
+
+	list_for_each_entry_safe(e, n, &ife->metalist, metalist) {
+		module_put(e->ops->owner);
+		list_del(&e->metalist);
+		if (e->metaval) {
+			if (e->ops->release)
+				e->ops->release(e);
+			else
+				kfree(e->metaval);
+		}
+		kfree(e);
+	}
+}
+
+static void tcf_ife_cleanup(struct tc_action *a, int bind)
+{
+	struct tcf_ife_info *ife = a->priv;
+
+	spin_lock_bh(&ife->tcf_lock);
+	_tcf_ife_cleanup(a, bind);
+	spin_unlock_bh(&ife->tcf_lock);
+}
+
+/* under ife->tcf_lock */
+int populate_metalist(struct tcf_ife_info *ife, struct nlattr **tb)
+{
+	int len = 0;
+	int rc = 0;
+	int i = 0;
+	void *val;
+
+	for (i = 1; i < max_metacnt; i++) {
+		if (tb[i]) {
+			val = nla_data(tb[i]);
+			len = nla_len(tb[i]);
+
+			rc = load_metaops_and_vet(ife, i, val, len);
+			if (rc != 0)
+				return rc;
+
+			rc = add_metainfo(ife, i, val, len);
+			if (rc)
+				return rc;
+		}
+	}
+
+	return rc;
+}
+
+static int tcf_ife_init(struct net *net, struct nlattr *nla,
+			struct nlattr *est, struct tc_action *a,
+			int ovr, int bind)
+{
+	struct nlattr *tb[TCA_IFE_MAX + 1];
+	struct nlattr *tb2[IFE_META_MAX + 1];
+	struct tcf_ife_info *ife;
+	struct tc_ife *parm;
+	u16 ife_type = 0;
+	u8 *daddr = NULL;
+	u8 *saddr = NULL;
+	int ret = 0;
+	int err;
+
+	err = nla_parse_nested(tb, TCA_IFE_MAX, nla, ife_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_IFE_PARMS] == NULL)
+		return -EINVAL;
+
+	parm = nla_data(tb[TCA_IFE_PARMS]);
+
+	if ((parm->flags & IFE_ENCODE) && (parm->flags & IFE_DECODE)) {
+		pr_info("Ambigous: Cant have both encode and decode\n");
+		return -EINVAL;
+	}
+	if (!(parm->flags & IFE_ENCODE) && !(parm->flags & IFE_DECODE)) {
+		pr_info("MUST have either encode or decode\n");
+		return -EINVAL;
+	}
+
+	if (parm->flags & IFE_ENCODE) {
+		/* Until we get issued the ethertype, we cant have
+		 * a default..
+		**/
+		if (tb[TCA_IFE_TYPE] == NULL) {
+			pr_info("You MUST pass etherype for encoding\n");
+			return -EINVAL;
+		}
+	}
+
+	if (!tcf_hash_check(parm->index, a, bind)) {
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*ife),
+				      bind, false);
+		if (ret)
+			return ret;
+		ret = ACT_P_CREATED;
+	} else {
+		if (bind)	/* dont override defaults */
+			return 0;
+		tcf_hash_release(a, bind);
+		if (!ovr)
+			return -EEXIST;
+	}
+
+	ife = to_ife(a);
+	ife->flags = parm->flags;
+
+	if (parm->flags & IFE_ENCODE) {
+		ife_type = *(u16 *) nla_data(tb[TCA_IFE_TYPE]);
+		if (tb[TCA_IFE_DMAC] != NULL)
+			daddr = nla_data(tb[TCA_IFE_DMAC]);
+		if (tb[TCA_IFE_SMAC] != NULL)
+			saddr = nla_data(tb[TCA_IFE_SMAC]);
+	}
+
+	spin_lock_bh(&ife->tcf_lock);
+	ife->tcf_action = parm->action;
+
+	if (parm->flags & IFE_ENCODE) {
+		if (daddr)
+			ether_addr_copy(ife->eth_dst, daddr);
+		else
+			eth_zero_addr(ife->eth_dst);
+
+		if (saddr)
+			ether_addr_copy(ife->eth_src, saddr);
+		else
+			eth_zero_addr(ife->eth_src);
+
+		ife->eth_type = ife_type;
+	}
+
+	if (ret == ACT_P_CREATED)
+		INIT_LIST_HEAD(&ife->metalist);
+
+	if (tb[TCA_IFE_METALST] != NULL) {
+		err = nla_parse_nested(tb2, IFE_META_MAX, tb[TCA_IFE_METALST],
+				       NULL);
+		if (err) {
+metadata_parse_err:
+			if (ret == ACT_P_CREATED)
+				_tcf_ife_cleanup(a, bind);
+
+			spin_unlock_bh(&ife->tcf_lock);
+			return err;
+		}
+
+		err = populate_metalist(ife, tb2);
+		if (err)
+			goto metadata_parse_err;
+
+	} else {
+		/* if no passed metadata allow list or passed allow-all 
+		 * then here we process by adding as many supported metadatum
+		 * as we can. You better have at least one else we are
+		 * going to bail out
+		 */
+		err = use_all_metadata(ife);
+		if (err) {
+			if (ret == ACT_P_CREATED)
+				_tcf_ife_cleanup(a, bind);
+
+			spin_unlock_bh(&ife->tcf_lock);
+			return err;
+		}
+	}
+
+	spin_unlock_bh(&ife->tcf_lock);
+
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(a);
+
+	print_ife_oplist();
+	return ret;
+}
+
+static int tcf_ife_dump(struct sk_buff *skb, struct tc_action *a, int bind,
+			int ref)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tcf_ife_info *ife = a->priv;
+	struct tc_ife opt = {
+		.index = ife->tcf_index,
+		.refcnt = ife->tcf_refcnt - ref,
+		.bindcnt = ife->tcf_bindcnt - bind,
+		.action = ife->tcf_action,
+		.flags = ife->flags,
+	};
+	struct tcf_t t;
+
+	if (nla_put(skb, TCA_IFE_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
+
+	t.install = jiffies_to_clock_t(jiffies - ife->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - ife->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(ife->tcf_tm.expires);
+	if (nla_put(skb, TCA_IFE_TM, sizeof(t), &t))
+		goto nla_put_failure;
+
+	if (!is_zero_ether_addr(ife->eth_dst)) {
+		if (nla_put(skb, TCA_IFE_DMAC, ETH_ALEN, ife->eth_dst))
+			goto nla_put_failure;
+	}
+
+	if (!is_zero_ether_addr(ife->eth_src)) {
+		if (nla_put(skb, TCA_IFE_SMAC, ETH_ALEN, ife->eth_src))
+			goto nla_put_failure;
+	}
+
+	if (nla_put(skb, TCA_IFE_TYPE, 2, &ife->eth_type))
+		goto nla_put_failure;
+
+	if (dump_metalist(skb, ife)) {
+		/*ignore failure to dump metalist */
+		pr_info("Failed to dump metalist\n");
+	}
+
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+int find_decode_metaid(struct sk_buff *skb, struct tcf_ife_info *ife,
+		       u16 metaid, u16 mlen, void *mdata)
+{
+	struct tcf_meta_info *e;
+
+	/* XXX: use hash to speed up */
+	list_for_each_entry(e, &ife->metalist, metalist) {
+		if (metaid == e->metaid) {
+			if (e->ops) {
+				/* We check for decode presence already */
+				return e->ops->decode(skb, mdata, mlen);
+			}
+		}
+	}
+
+	return 0;
+}
+
+struct ifeheadr {
+	__be16 metalen;
+	u8 tlv_data[];
+};
+
+struct meta_tlvhdr {
+	__be16 type;
+	__be16 len;
+};
+
+static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
+			  struct tcf_result *res)
+{
+	struct tcf_ife_info *ife = a->priv;
+	int action = ife->tcf_action;
+	struct ifeheadr *ifehdr = (struct ifeheadr *)skb->data;
+	u16 ifehdrln = ifehdr->metalen;
+	struct meta_tlvhdr *tlv = (struct meta_tlvhdr *)(ifehdr->tlv_data);
+
+	spin_lock(&ife->tcf_lock);
+	bstats_update(&ife->tcf_bstats, skb);
+	ife->tcf_tm.lastuse = jiffies;
+	spin_unlock(&ife->tcf_lock);
+
+	ifehdrln = ntohs(ifehdrln);
+	if (unlikely(!pskb_may_pull(skb, ifehdrln))) {
+		spin_lock(&ife->tcf_lock);
+		ife->tcf_qstats.drops++;
+		spin_unlock(&ife->tcf_lock);
+		return TC_ACT_SHOT;
+	}
+
+	skb_set_mac_header(skb, ifehdrln);
+	__skb_pull(skb, ifehdrln);
+	skb->protocol = eth_type_trans(skb, skb->dev);
+	ifehdrln -= IFE_METAHDRLEN;
+
+	while (ifehdrln > 0) {
+		u8 *tlvdata = (u8 *) tlv;
+		u16 mtype = tlv->type;
+		u16 mlen = tlv->len;
+		mtype = ntohs(mtype);
+		mlen = ntohs(mlen);
+
+		if (find_decode_metaid(skb, ife, mtype, (mlen - 4),
+					(void *)(tlvdata + 4))) {
+			/* abuse overlimits to count when we receive metadata
+			 * but dont have an ops for it
+			 */
+			if (net_ratelimit())
+				printk("Unknown incoming metaid %d alnlen %d\n",
+				       mtype, mlen);
+			ife->tcf_qstats.overlimits++;
+		}
+
+		tlvdata += mlen;
+		ifehdrln -= mlen;
+		tlv = (struct meta_tlvhdr *)tlvdata;
+	}
+
+	skb_reset_network_header(skb);
+	return action;
+}
+
+/*XXX: check if we can do this at install time instead of current
+ * send data path
+**/
+static int ife_get_sz(struct sk_buff *skb, struct tcf_ife_info *ife)
+{
+	struct tcf_meta_info *e, *n;
+	int tot_run_sz = 0, run_sz = 0;
+
+	list_for_each_entry_safe(e, n, &ife->metalist, metalist) {
+		if (e->ops->check_presence) {
+			run_sz = e->ops->check_presence(skb, e);
+			tot_run_sz += run_sz;
+		}
+	}
+
+	return tot_run_sz;
+}
+
+static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
+			  struct tcf_result *res)
+{
+	struct tcf_ife_info *ife = a->priv;
+	int action = ife->tcf_action;
+	struct ethhdr *oethh;	/* outer ether header */
+	struct ethhdr *iethh;	/* inner eth header */
+	struct tcf_meta_info *e;
+	/*
+	   OUTERHDR:TOTMETALEN:{TLVHDR:Metadatum:TLVHDR..}:ORIGDATA
+	   where ORIGDATA = original ethernet header ...
+	 */
+	u16 metalen = ife_get_sz(skb, ife);
+	int hdrm = metalen + skb->dev->hard_header_len + IFE_METAHDRLEN;
+	unsigned int skboff = skb->dev->hard_header_len;
+	u32 at = G_TC_AT(skb->tc_verd);
+	int new_len = skb->len + hdrm;
+	int exceed_mtu = 0;
+	int err;
+
+	if (at & AT_EGRESS) {
+		if (new_len > skb->dev->mtu) {
+			exceed_mtu = 1;
+		}
+	}
+
+	spin_lock(&ife->tcf_lock);
+	bstats_update(&ife->tcf_bstats, skb);
+	ife->tcf_tm.lastuse = jiffies;
+
+	if (!metalen) {		/* no metadata to send */
+		spin_unlock(&ife->tcf_lock);
+		/* abuse overlimits to count when we allow packet
+		 * with no metadata
+		 */
+		ife->tcf_qstats.overlimits++;
+		return action;
+	}
+	/* could be stupid policy setup or mtu config
+	 * so lets be conservative.. */
+	if ((action == TC_ACT_SHOT) || exceed_mtu) {
+		ife->tcf_qstats.drops++;
+		spin_unlock(&ife->tcf_lock);
+		return TC_ACT_SHOT;
+	}
+
+	iethh = eth_hdr(skb);
+
+	err = skb_cow_head(skb, hdrm);
+	if (unlikely(err)) {
+		ife->tcf_qstats.drops++;
+		spin_unlock(&ife->tcf_lock);
+		return TC_ACT_SHOT;
+	}
+
+	if (!(at & AT_EGRESS)) {
+		skb_push(skb, skb->dev->hard_header_len);
+	}
+
+	__skb_push(skb, hdrm);
+	memcpy(skb->data, iethh, skb->mac_len);
+	skb_reset_mac_header(skb);
+	oethh = eth_hdr(skb);
+
+	/*total metadata length */
+	metalen += IFE_METAHDRLEN;
+	metalen = htons(metalen);
+	memcpy((void *)(skb->data + skboff), &metalen, IFE_METAHDRLEN);
+	skboff += IFE_METAHDRLEN;
+
+	/*XXX: we dont have a clever way of telling encode to 
+	 * not repeat some of the computations that are done by 
+	 * ops->presence_check...
+	 */
+	list_for_each_entry(e, &ife->metalist, metalist) {
+		if (e->ops->encode) {
+			err = e->ops->encode(skb, (void *)(skb->data + skboff),
+					     e);
+		}
+		if (err < 0) {
+			/* too corrupt to keep around if overwritten */
+			ife->tcf_qstats.drops++;
+			spin_unlock(&ife->tcf_lock);
+			return TC_ACT_SHOT;
+		}
+		skboff += err;
+	}
+
+	if (!is_zero_ether_addr(ife->eth_src))
+		ether_addr_copy(oethh->h_source, ife->eth_src);
+	else
+		ether_addr_copy(oethh->h_source, iethh->h_source);
+	if (!is_zero_ether_addr(ife->eth_dst))
+		ether_addr_copy(oethh->h_dest, ife->eth_dst);
+	else
+		ether_addr_copy(oethh->h_dest, iethh->h_dest);
+	oethh->h_proto = htons(ife->eth_type);
+
+	if (!(at & AT_EGRESS)) {
+		skb_pull(skb, skb->dev->hard_header_len);
+	}
+
+	spin_unlock(&ife->tcf_lock);
+
+	return action;
+}
+
+static int tcf_ife(struct sk_buff *skb, const struct tc_action *a,
+		   struct tcf_result *res)
+{
+	struct tcf_ife_info *ife = a->priv;
+
+	if (ife->flags & IFE_ENCODE) {
+		return tcf_ife_encode(skb, a, res);
+	}
+
+	if (ife->flags & IFE_DECODE) {
+		return tcf_ife_decode(skb, a, res);
+	}
+
+	pr_info("unknown failure(policy neither de/encode\n");
+	spin_lock(&ife->tcf_lock);
+	bstats_update(&ife->tcf_bstats, skb);
+	ife->tcf_tm.lastuse = jiffies;
+	ife->tcf_qstats.drops++;
+	spin_unlock(&ife->tcf_lock);
+
+	return TC_ACT_SHOT;
+}
+
+static struct tc_action_ops act_ife_ops = {
+	.kind = "ife",
+	.type = TCA_ACT_IFE,
+	.owner = THIS_MODULE,
+	.act = tcf_ife,
+	.dump = tcf_ife_dump,
+	.cleanup = tcf_ife_cleanup,
+	.init = tcf_ife_init,
+};
+
+static int __init ife_init_module(void)
+{
+	pr_info("Loaded IFE maximum metaid %d\n", max_metacnt);
+	INIT_LIST_HEAD(&ifeoplist);
+	return tcf_register_action(&act_ife_ops, IFE_TAB_MASK);
+}
+
+static void __exit ife_cleanup_module(void)
+{
+	pr_info("Unloaded IFE\n");
+	tcf_unregister_action(&act_ife_ops);
+}
+
+module_init(ife_init_module);
+module_exit(ife_cleanup_module);
+
+module_param(max_metacnt, int, 0);
+MODULE_AUTHOR("Jamal Hadi Salim(2015)");
+MODULE_DESCRIPTION("Inter-FE LFB action");
+MODULE_LICENSE("GPL");
+MODULE_PARM_DESC(max_metacnt, "Upper bound of metadata id");
-- 
1.9.1
