From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/23] netfilter: nf_tables: extend tracing infrastructure
Date: Fri, 18 Dec 2015 21:26:40 +0100
Message-ID: <1450470409-31427-15-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58094 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965213AbbLRUeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:34:11 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id CFE7A17F1B4
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5B960DA7FF
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1F2BFDA3FA
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:02 +0100 (CET)
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

nft monitor mode can then decode and display this trace data.

Parts of LL/Network/Transport headers are provided as separate
attributes.

Otherwise, printing IP address data becomes virtually impossible
for userspace since in the case of the netdev family we really don't
want userspace to have to know all the possible link layer types
and/or sizes just to display/print an ip address.

We also don't want userspace to have to follow ipv6 header chains
to get the s/dport info, the kernel already did this work for us.

To avoid bloating nft_do_chain all data required for tracing is
encapsulated in nft_traceinfo.

The structure is initialized unconditionally(!) for each nft_do_chain
invocation.

This unconditionall call will be moved under a static key in a
followup patch.

With lots of help from Patrick McHardy and Pablo Neira.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |  32 ++++
 include/uapi/linux/netfilter/nf_tables.h |  52 ++++++
 include/uapi/linux/netfilter/nfnetlink.h |   2 +
 net/netfilter/Makefile                   |   2 +-
 net/netfilter/nf_tables_api.c            |  12 +-
 net/netfilter/nf_tables_core.c           |  45 +++--
 net/netfilter/nf_tables_trace.c          | 271 +++++++++++++++++++++++++++++++
 net/netfilter/nfnetlink.c                |   1 +
 8 files changed, 398 insertions(+), 19 deletions(-)
 create mode 100644 net/netfilter/nf_tables_trace.c

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 101d7d7..b313cda 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -888,6 +888,38 @@ void nft_unregister_chain_type(const struct nf_chain_type *);
 int nft_register_expr(struct nft_expr_type *);
 void nft_unregister_expr(struct nft_expr_type *);
 
+int nft_verdict_dump(struct sk_buff *skb, int type,
+		     const struct nft_verdict *v);
+
+/**
+ *	struct nft_traceinfo - nft tracing information and state
+ *
+ *	@pkt: pktinfo currently processed
+ *	@basechain: base chain currently processed
+ *	@chain: chain currently processed
+ *	@rule:  rule that was evaluated
+ *	@verdict: verdict given by rule
+ *	@type: event type (enum nft_trace_types)
+ *	@packet_dumped: packet headers sent in a previous traceinfo message
+ *	@trace: other struct members are initialised
+ */
+struct nft_traceinfo {
+	const struct nft_pktinfo	*pkt;
+	const struct nft_base_chain	*basechain;
+	const struct nft_chain		*chain;
+	const struct nft_rule		*rule;
+	const struct nft_verdict	*verdict;
+	enum nft_trace_types		type;
+	bool				packet_dumped;
+	bool				trace;
+};
+
+void nft_trace_init(struct nft_traceinfo *info, const struct nft_pktinfo *pkt,
+		    const struct nft_verdict *verdict,
+		    const struct nft_chain *basechain);
+
+void nft_trace_notify(struct nft_traceinfo *info);
+
 #define nft_dereference(p)					\
 	nfnl_dereference(p, NFNL_SUBSYS_NFTABLES)
 
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 5f3ecec..b48a3ab 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -83,6 +83,7 @@ enum nft_verdicts {
  * @NFT_MSG_DELSETELEM: delete a set element (enum nft_set_elem_attributes)
  * @NFT_MSG_NEWGEN: announce a new generation, only for events (enum nft_gen_attributes)
  * @NFT_MSG_GETGEN: get the rule-set generation (enum nft_gen_attributes)
+ * @NFT_MSG_TRACE: trace event (enum nft_trace_attributes)
  */
 enum nf_tables_msg_types {
 	NFT_MSG_NEWTABLE,
@@ -102,6 +103,7 @@ enum nf_tables_msg_types {
 	NFT_MSG_DELSETELEM,
 	NFT_MSG_NEWGEN,
 	NFT_MSG_GETGEN,
+	NFT_MSG_TRACE,
 	NFT_MSG_MAX,
 };
 
@@ -987,4 +989,54 @@ enum nft_gen_attributes {
 };
 #define NFTA_GEN_MAX		(__NFTA_GEN_MAX - 1)
 
+/**
+ * enum nft_trace_attributes - nf_tables trace netlink attributes
+ *
+ * @NFTA_TRACE_TABLE: name of the table (NLA_STRING)
+ * @NFTA_TRACE_CHAIN: name of the chain (NLA_STRING)
+ * @NFTA_TRACE_RULE_HANDLE: numeric handle of the rule (NLA_U64)
+ * @NFTA_TRACE_TYPE: type of the event (NLA_U32: nft_trace_types)
+ * @NFTA_TRACE_VERDICT: verdict returned by hook (NLA_NESTED: nft_verdicts)
+ * @NFTA_TRACE_ID: pseudo-id, same for each skb traced (NLA_U32)
+ * @NFTA_TRACE_LL_HEADER: linklayer header (NLA_BINARY)
+ * @NFTA_TRACE_NETWORK_HEADER: network header (NLA_BINARY)
+ * @NFTA_TRACE_TRANSPORT_HEADER: transport header (NLA_BINARY)
+ * @NFTA_TRACE_IIF: indev ifindex (NLA_U32)
+ * @NFTA_TRACE_IIFTYPE: netdev->type of indev (NLA_U16)
+ * @NFTA_TRACE_OIF: outdev ifindex (NLA_U32)
+ * @NFTA_TRACE_OIFTYPE: netdev->type of outdev (NLA_U16)
+ * @NFTA_TRACE_MARK: nfmark (NLA_U32)
+ * @NFTA_TRACE_NFPROTO: nf protocol processed (NLA_U32)
+ * @NFTA_TRACE_POLICY: policy that decided fate of packet (NLA_U32)
+ */
+enum nft_trace_attibutes {
+	NFTA_TRACE_UNSPEC,
+	NFTA_TRACE_TABLE,
+	NFTA_TRACE_CHAIN,
+	NFTA_TRACE_RULE_HANDLE,
+	NFTA_TRACE_TYPE,
+	NFTA_TRACE_VERDICT,
+	NFTA_TRACE_ID,
+	NFTA_TRACE_LL_HEADER,
+	NFTA_TRACE_NETWORK_HEADER,
+	NFTA_TRACE_TRANSPORT_HEADER,
+	NFTA_TRACE_IIF,
+	NFTA_TRACE_IIFTYPE,
+	NFTA_TRACE_OIF,
+	NFTA_TRACE_OIFTYPE,
+	NFTA_TRACE_MARK,
+	NFTA_TRACE_NFPROTO,
+	NFTA_TRACE_POLICY,
+	__NFTA_TRACE_MAX
+};
+#define NFTA_TRACE_MAX (__NFTA_TRACE_MAX - 1)
+
+enum nft_trace_types {
+	NFT_TRACETYPE_UNSPEC,
+	NFT_TRACETYPE_POLICY,
+	NFT_TRACETYPE_RETURN,
+	NFT_TRACETYPE_RULE,
+	__NFT_TRACETYPE_MAX
+};
+#define NFT_TRACETYPE_MAX (__NFT_TRACETYPE_MAX - 1)
 #endif /* _LINUX_NF_TABLES_H */
diff --git a/include/uapi/linux/netfilter/nfnetlink.h b/include/uapi/linux/netfilter/nfnetlink.h
index 354a7e5..4bb8cb7 100644
--- a/include/uapi/linux/netfilter/nfnetlink.h
+++ b/include/uapi/linux/netfilter/nfnetlink.h
@@ -22,6 +22,8 @@ enum nfnetlink_groups {
 #define NFNLGRP_NFTABLES                NFNLGRP_NFTABLES
 	NFNLGRP_ACCT_QUOTA,
 #define NFNLGRP_ACCT_QUOTA		NFNLGRP_ACCT_QUOTA
+	NFNLGRP_NFTRACE,
+#define NFNLGRP_NFTRACE			NFNLGRP_NFTRACE
 	__NFNLGRP_MAX,
 };
 #define NFNLGRP_MAX	(__NFNLGRP_MAX - 1)
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 7638c36..2293484 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -67,7 +67,7 @@ obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
 obj-$(CONFIG_NETFILTER_SYNPROXY) += nf_synproxy_core.o
 
 # nf_tables
-nf_tables-objs += nf_tables_core.o nf_tables_api.o
+nf_tables-objs += nf_tables_core.o nf_tables_api.o nf_tables_trace.o
 nf_tables-objs += nft_immediate.o nft_cmp.o nft_lookup.o nft_dynset.o
 nf_tables-objs += nft_bitwise.o nft_byteorder.o nft_payload.o
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 93cc473..c4969a0 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4446,22 +4446,22 @@ static void nft_verdict_uninit(const struct nft_data *data)
 	}
 }
 
-static int nft_verdict_dump(struct sk_buff *skb, const struct nft_data *data)
+int nft_verdict_dump(struct sk_buff *skb, int type, const struct nft_verdict *v)
 {
 	struct nlattr *nest;
 
-	nest = nla_nest_start(skb, NFTA_DATA_VERDICT);
+	nest = nla_nest_start(skb, type);
 	if (!nest)
 		goto nla_put_failure;
 
-	if (nla_put_be32(skb, NFTA_VERDICT_CODE, htonl(data->verdict.code)))
+	if (nla_put_be32(skb, NFTA_VERDICT_CODE, htonl(v->code)))
 		goto nla_put_failure;
 
-	switch (data->verdict.code) {
+	switch (v->code) {
 	case NFT_JUMP:
 	case NFT_GOTO:
 		if (nla_put_string(skb, NFTA_VERDICT_CHAIN,
-				   data->verdict.chain->name))
+				   v->chain->name))
 			goto nla_put_failure;
 	}
 	nla_nest_end(skb, nest);
@@ -4572,7 +4572,7 @@ int nft_data_dump(struct sk_buff *skb, int attr, const struct nft_data *data,
 		err = nft_value_dump(skb, data, len);
 		break;
 	case NFT_DATA_VERDICT:
-		err = nft_verdict_dump(skb, data);
+		err = nft_verdict_dump(skb, NFTA_DATA_VERDICT, &data->verdict);
 		break;
 	default:
 		err = -EINVAL;
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index f3695a4..2395de7 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -44,22 +44,36 @@ static struct nf_loginfo trace_loginfo = {
 	},
 };
 
-static void __nft_trace_packet(const struct nft_pktinfo *pkt,
-			       const struct nft_chain *chain,
-			       int rulenum, enum nft_trace type)
+static noinline void __nft_trace_packet(struct nft_traceinfo *info,
+					const struct nft_chain *chain,
+					int rulenum, enum nft_trace type)
 {
+	const struct nft_pktinfo *pkt = info->pkt;
+
+	if (!pkt->skb->nf_trace)
+		return;
+
+	info->chain = chain;
+	info->type = type;
+
+	nft_trace_notify(info);
+
 	nf_log_trace(pkt->net, pkt->pf, pkt->hook, pkt->skb, pkt->in,
 		     pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
 		     chain->table->name, chain->name, comments[type],
 		     rulenum);
 }
 
-static inline void nft_trace_packet(const struct nft_pktinfo *pkt,
+static inline void nft_trace_packet(struct nft_traceinfo *info,
 				    const struct nft_chain *chain,
-				    int rulenum, enum nft_trace type)
+				    const struct nft_rule *rule,
+				    int rulenum,
+				    enum nft_trace_types type)
 {
-	if (unlikely(pkt->skb->nf_trace))
-		__nft_trace_packet(pkt, chain, rulenum, type);
+	if (unlikely(info->trace)) {
+		info->rule = rule;
+		__nft_trace_packet(info, chain, rulenum, type);
+	}
 }
 
 static void nft_cmp_fast_eval(const struct nft_expr *expr,
@@ -121,7 +135,9 @@ nft_do_chain(struct nft_pktinfo *pkt, void *priv)
 	struct nft_stats *stats;
 	int rulenum;
 	unsigned int gencursor = nft_genmask_cur(net);
+	struct nft_traceinfo info;
 
+	nft_trace_init(&info, pkt, &regs.verdict, basechain);
 do_chain:
 	rulenum = 0;
 	rule = list_entry(&chain->rules, struct nft_rule, list);
@@ -151,7 +167,8 @@ next_rule:
 			regs.verdict.code = NFT_CONTINUE;
 			continue;
 		case NFT_CONTINUE:
-			nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
+			nft_trace_packet(&info, chain, rule,
+					 rulenum, NFT_TRACETYPE_RULE);
 			continue;
 		}
 		break;
@@ -161,7 +178,8 @@ next_rule:
 	case NF_ACCEPT:
 	case NF_DROP:
 	case NF_QUEUE:
-		nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
+		nft_trace_packet(&info, chain, rule,
+				 rulenum, NFT_TRACETYPE_RULE);
 		return regs.verdict.code;
 	}
 
@@ -174,7 +192,8 @@ next_rule:
 		stackptr++;
 		/* fall through */
 	case NFT_GOTO:
-		nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
+		nft_trace_packet(&info, chain, rule,
+				 rulenum, NFT_TRACETYPE_RULE);
 
 		chain = regs.verdict.chain;
 		goto do_chain;
@@ -182,7 +201,8 @@ next_rule:
 		rulenum++;
 		/* fall through */
 	case NFT_RETURN:
-		nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RETURN);
+		nft_trace_packet(&info, chain, rule,
+				 rulenum, NFT_TRACETYPE_RETURN);
 		break;
 	default:
 		WARN_ON(1);
@@ -196,7 +216,8 @@ next_rule:
 		goto next_rule;
 	}
 
-	nft_trace_packet(pkt, basechain, -1, NFT_TRACE_POLICY);
+	nft_trace_packet(&info, basechain, NULL, -1,
+			 NFT_TRACETYPE_POLICY);
 
 	rcu_read_lock_bh();
 	stats = this_cpu_ptr(rcu_dereference(nft_base_chain(basechain)->stats));
diff --git a/net/netfilter/nf_tables_trace.c b/net/netfilter/nf_tables_trace.c
new file mode 100644
index 0000000..36fd7ad
--- /dev/null
+++ b/net/netfilter/nf_tables_trace.c
@@ -0,0 +1,271 @@
+/*
+ * (C) 2015 Red Hat GmbH
+ * Author: Florian Westphal <fw@strlen.de>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/hash.h>
+#include <linux/jhash.h>
+#include <linux/if_vlan.h>
+#include <linux/init.h>
+#include <linux/skbuff.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_core.h>
+#include <net/netfilter/nf_tables.h>
+
+#define NFT_TRACETYPE_LL_HSIZE		20
+#define NFT_TRACETYPE_NETWORK_HSIZE	40
+#define NFT_TRACETYPE_TRANSPORT_HSIZE	20
+
+static int trace_fill_id(struct sk_buff *nlskb, struct sk_buff *skb)
+{
+	__be32 id;
+
+	/* using skb address as ID results in a limited number of
+	 * values (and quick reuse).
+	 *
+	 * So we attempt to use as many skb members that will not
+	 * change while skb is with netfilter.
+	 */
+	id = (__be32)jhash_2words(hash32_ptr(skb), skb_get_hash(skb),
+				  skb->skb_iif);
+
+	return nla_put_be32(nlskb, NFTA_TRACE_ID, id);
+}
+
+static int trace_fill_header(struct sk_buff *nlskb, u16 type,
+			     const struct sk_buff *skb,
+			     int off, unsigned int len)
+{
+	struct nlattr *nla;
+
+	if (len == 0)
+		return 0;
+
+	nla = nla_reserve(nlskb, type, len);
+	if (!nla || skb_copy_bits(skb, off, nla_data(nla), len))
+		return -1;
+
+	return 0;
+}
+
+static int nf_trace_fill_ll_header(struct sk_buff *nlskb,
+				   const struct sk_buff *skb)
+{
+	struct vlan_ethhdr veth;
+	int off;
+
+	BUILD_BUG_ON(sizeof(veth) > NFT_TRACETYPE_LL_HSIZE);
+
+	off = skb_mac_header(skb) - skb->data;
+	if (off != -ETH_HLEN)
+		return -1;
+
+	if (skb_copy_bits(skb, off, &veth, ETH_HLEN))
+		return -1;
+
+	veth.h_vlan_proto = skb->vlan_proto;
+	veth.h_vlan_TCI = htons(skb_vlan_tag_get(skb));
+	veth.h_vlan_encapsulated_proto = skb->protocol;
+
+	return nla_put(nlskb, NFTA_TRACE_LL_HEADER, sizeof(veth), &veth);
+}
+
+static int nf_trace_fill_dev_info(struct sk_buff *nlskb,
+				  const struct net_device *indev,
+				  const struct net_device *outdev)
+{
+	if (indev) {
+		if (nla_put_be32(nlskb, NFTA_TRACE_IIF,
+				 htonl(indev->ifindex)))
+			return -1;
+
+		if (nla_put_be16(nlskb, NFTA_TRACE_IIFTYPE,
+				 htons(indev->type)))
+			return -1;
+	}
+
+	if (outdev) {
+		if (nla_put_be32(nlskb, NFTA_TRACE_OIF,
+				 htonl(outdev->ifindex)))
+			return -1;
+
+		if (nla_put_be16(nlskb, NFTA_TRACE_OIFTYPE,
+				 htons(outdev->type)))
+			return -1;
+	}
+
+	return 0;
+}
+
+static int nf_trace_fill_pkt_info(struct sk_buff *nlskb,
+				  const struct nft_pktinfo *pkt)
+{
+	const struct sk_buff *skb = pkt->skb;
+	unsigned int len = min_t(unsigned int,
+				 pkt->xt.thoff - skb_network_offset(skb),
+				 NFT_TRACETYPE_NETWORK_HSIZE);
+	int off = skb_network_offset(skb);
+
+	if (trace_fill_header(nlskb, NFTA_TRACE_NETWORK_HEADER, skb, off, len))
+		return -1;
+
+	len = min_t(unsigned int, skb->len - pkt->xt.thoff,
+		    NFT_TRACETYPE_TRANSPORT_HSIZE);
+
+	if (trace_fill_header(nlskb, NFTA_TRACE_TRANSPORT_HEADER, skb,
+			      pkt->xt.thoff, len))
+		return -1;
+
+	if (!skb_mac_header_was_set(skb))
+		return 0;
+
+	if (skb_vlan_tag_get(skb))
+		return nf_trace_fill_ll_header(nlskb, skb);
+
+	off = skb_mac_header(skb) - skb->data;
+	len = min_t(unsigned int, -off, NFT_TRACETYPE_LL_HSIZE);
+	return trace_fill_header(nlskb, NFTA_TRACE_LL_HEADER,
+				 skb, off, len);
+}
+
+static int nf_trace_fill_rule_info(struct sk_buff *nlskb,
+				   const struct nft_traceinfo *info)
+{
+	if (!info->rule)
+		return 0;
+
+	/* a continue verdict with ->type == RETURN means that this is
+	 * an implicit return (end of chain reached).
+	 *
+	 * Since no rule matched, the ->rule pointer is invalid.
+	 */
+	if (info->type == NFT_TRACETYPE_RETURN &&
+	    info->verdict->code == NFT_CONTINUE)
+		return 0;
+
+	return nla_put_be64(nlskb, NFTA_TRACE_RULE_HANDLE,
+			    cpu_to_be64(info->rule->handle));
+}
+
+void nft_trace_notify(struct nft_traceinfo *info)
+{
+	const struct nft_pktinfo *pkt = info->pkt;
+	struct nfgenmsg *nfmsg;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	unsigned int size;
+	int event = (NFNL_SUBSYS_NFTABLES << 8) | NFT_MSG_TRACE;
+
+	if (!nfnetlink_has_listeners(pkt->net, NFNLGRP_NFTRACE))
+		return;
+
+	size = nlmsg_total_size(sizeof(struct nfgenmsg)) +
+		nla_total_size(NFT_TABLE_MAXNAMELEN) +
+		nla_total_size(NFT_CHAIN_MAXNAMELEN) +
+		nla_total_size(sizeof(__be64)) +	/* rule handle */
+		nla_total_size(sizeof(__be32)) +	/* trace type */
+		nla_total_size(0) +			/* VERDICT, nested */
+			nla_total_size(sizeof(u32)) +	/* verdict code */
+			nla_total_size(NFT_CHAIN_MAXNAMELEN) + /* jump target */
+		nla_total_size(sizeof(u32)) +		/* id */
+		nla_total_size(NFT_TRACETYPE_LL_HSIZE) +
+		nla_total_size(NFT_TRACETYPE_NETWORK_HSIZE) +
+		nla_total_size(NFT_TRACETYPE_TRANSPORT_HSIZE) +
+		nla_total_size(sizeof(u32)) +		/* iif */
+		nla_total_size(sizeof(__be16)) +	/* iiftype */
+		nla_total_size(sizeof(u32)) +		/* oif */
+		nla_total_size(sizeof(__be16)) +	/* oiftype */
+		nla_total_size(sizeof(u32)) +		/* mark */
+		nla_total_size(sizeof(u32)) +		/* nfproto */
+		nla_total_size(sizeof(u32));		/* policy */
+
+	skb = nlmsg_new(size, GFP_ATOMIC);
+	if (!skb)
+		return;
+
+	nlh = nlmsg_put(skb, 0, 0, event, sizeof(struct nfgenmsg), 0);
+	if (!nlh)
+		goto nla_put_failure;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->nfgen_family	= info->basechain->type->family;
+	nfmsg->version		= NFNETLINK_V0;
+	nfmsg->res_id		= 0;
+
+	if (nla_put_be32(skb, NFTA_TRACE_NFPROTO, htonl(pkt->pf)))
+		goto nla_put_failure;
+
+	if (nla_put_be32(skb, NFTA_TRACE_TYPE, htonl(info->type)))
+		goto nla_put_failure;
+
+	if (trace_fill_id(skb, pkt->skb))
+		goto nla_put_failure;
+
+	if (info->chain) {
+		if (nla_put_string(skb, NFTA_TRACE_CHAIN,
+				   info->chain->name))
+			goto nla_put_failure;
+		if (nla_put_string(skb, NFTA_TRACE_TABLE,
+				   info->chain->table->name))
+			goto nla_put_failure;
+	}
+
+	if (nf_trace_fill_rule_info(skb, info))
+		goto nla_put_failure;
+
+	switch (info->type) {
+	case NFT_TRACETYPE_UNSPEC:
+	case __NFT_TRACETYPE_MAX:
+		break;
+	case NFT_TRACETYPE_RETURN:
+	case NFT_TRACETYPE_RULE:
+		if (nft_verdict_dump(skb, NFTA_TRACE_VERDICT, info->verdict))
+			goto nla_put_failure;
+		break;
+	case NFT_TRACETYPE_POLICY:
+		if (nla_put_be32(skb, NFTA_TRACE_POLICY,
+				 info->basechain->policy))
+			goto nla_put_failure;
+		break;
+	}
+
+	if (pkt->skb->mark &&
+	    nla_put_be32(skb, NFTA_TRACE_MARK, htonl(pkt->skb->mark)))
+		goto nla_put_failure;
+
+	if (!info->packet_dumped) {
+		if (nf_trace_fill_dev_info(skb, pkt->in, pkt->out))
+			goto nla_put_failure;
+
+		if (nf_trace_fill_pkt_info(skb, pkt))
+			goto nla_put_failure;
+		info->packet_dumped = true;
+	}
+
+	nlmsg_end(skb, nlh);
+	nfnetlink_send(skb, pkt->net, 0, NFNLGRP_NFTRACE, 0, GFP_ATOMIC);
+	return;
+
+ nla_put_failure:
+	WARN_ON_ONCE(1);
+	kfree_skb(skb);
+}
+
+void nft_trace_init(struct nft_traceinfo *info, const struct nft_pktinfo *pkt,
+		    const struct nft_verdict *verdict,
+		    const struct nft_chain *chain)
+{
+	info->basechain = nft_base_chain(chain);
+	info->trace = true;
+	info->packet_dumped = false;
+	info->pkt = pkt;
+	info->verdict = verdict;
+}
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 46453ab..28591fa 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -49,6 +49,7 @@ static const int nfnl_group2type[NFNLGRP_MAX+1] = {
 	[NFNLGRP_CONNTRACK_EXP_DESTROY] = NFNL_SUBSYS_CTNETLINK_EXP,
 	[NFNLGRP_NFTABLES]		= NFNL_SUBSYS_NFTABLES,
 	[NFNLGRP_ACCT_QUOTA]		= NFNL_SUBSYS_ACCT,
+	[NFNLGRP_NFTRACE]		= NFNL_SUBSYS_NFTABLES,
 };
 
 void nfnl_lock(__u8 subsys_id)
-- 
2.1.4
