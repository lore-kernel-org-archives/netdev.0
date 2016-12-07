From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/50] netfilter: nft_payload: layer 4 checksum adjustment for pseudoheader fields
Date: Wed,  7 Dec 2016 22:52:34 +0100
Message-ID: <1481147576-5690-29-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60266 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933389AbcLGVxq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:46 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ABE71A4175
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:42 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8E52EDA860
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:42 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5C7D7DA86C
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:40 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new flag that signals the kernel to update layer 4
checksum if the packet field belongs to the layer 4 pseudoheader. This
implicitly provides stateless NAT 1:1 that is useful under very specific
usecases.

Since rules mangling layer 3 fields that are part of the pseudoheader
may potentially convey any layer 4 packet, we have to deal with the
layer 4 checksum adjustment using protocol specific code.

This patch adds support for TCP, UDP and ICMPv6, since they include the
pseudoheader in the layer 4 checksum calculation. ICMP doesn't, so we
can skip it.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_core.h   |   1 +
 include/uapi/linux/netfilter/nf_tables.h |   6 ++
 net/netfilter/nft_payload.c              | 107 +++++++++++++++++++++++++++++--
 3 files changed, 109 insertions(+), 5 deletions(-)

diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index 862373d4ea9d..8f690effec37 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -45,6 +45,7 @@ struct nft_payload_set {
 	enum nft_registers	sreg:8;
 	u8			csum_type;
 	u8			csum_offset;
+	u8			csum_flags;
 };
 
 extern const struct nft_expr_ops nft_payload_fast_ops;
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 14e5f619167e..f030e59aa2ec 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -659,6 +659,10 @@ enum nft_payload_csum_types {
 	NFT_PAYLOAD_CSUM_INET,
 };
 
+enum nft_payload_csum_flags {
+	NFT_PAYLOAD_L4CSUM_PSEUDOHDR = (1 << 0),
+};
+
 /**
  * enum nft_payload_attributes - nf_tables payload expression netlink attributes
  *
@@ -669,6 +673,7 @@ enum nft_payload_csum_types {
  * @NFTA_PAYLOAD_SREG: source register to load data from (NLA_U32: nft_registers)
  * @NFTA_PAYLOAD_CSUM_TYPE: checksum type (NLA_U32)
  * @NFTA_PAYLOAD_CSUM_OFFSET: checksum offset relative to base (NLA_U32)
+ * @NFTA_PAYLOAD_CSUM_FLAGS: checksum flags (NLA_U32)
  */
 enum nft_payload_attributes {
 	NFTA_PAYLOAD_UNSPEC,
@@ -679,6 +684,7 @@ enum nft_payload_attributes {
 	NFTA_PAYLOAD_SREG,
 	NFTA_PAYLOAD_CSUM_TYPE,
 	NFTA_PAYLOAD_CSUM_OFFSET,
+	NFTA_PAYLOAD_CSUM_FLAGS,
 	__NFTA_PAYLOAD_MAX
 };
 #define NFTA_PAYLOAD_MAX	(__NFTA_PAYLOAD_MAX - 1)
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 98fb5d7b8087..36d2b1096546 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2016 Pablo Neira Ayuso <pablo@netfilter.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -17,6 +18,10 @@
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables_core.h>
 #include <net/netfilter/nf_tables.h>
+/* For layer 4 checksum field offset. */
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/icmpv6.h>
 
 /* add vlan header into the user buffer for if tag was removed by offloads */
 static bool
@@ -164,6 +169,87 @@ const struct nft_expr_ops nft_payload_fast_ops = {
 	.dump		= nft_payload_dump,
 };
 
+static inline void nft_csum_replace(__sum16 *sum, __wsum fsum, __wsum tsum)
+{
+	*sum = csum_fold(csum_add(csum_sub(~csum_unfold(*sum), fsum), tsum));
+	if (*sum == 0)
+		*sum = CSUM_MANGLED_0;
+}
+
+static bool nft_payload_udp_checksum(struct sk_buff *skb, unsigned int thoff)
+{
+	struct udphdr *uh, _uh;
+
+	uh = skb_header_pointer(skb, thoff, sizeof(_uh), &_uh);
+	if (!uh)
+		return false;
+
+	return uh->check;
+}
+
+static int nft_payload_l4csum_offset(const struct nft_pktinfo *pkt,
+				     struct sk_buff *skb,
+				     unsigned int *l4csum_offset)
+{
+	switch (pkt->tprot) {
+	case IPPROTO_TCP:
+		*l4csum_offset = offsetof(struct tcphdr, check);
+		break;
+	case IPPROTO_UDP:
+		if (!nft_payload_udp_checksum(skb, pkt->xt.thoff))
+			return -1;
+		/* Fall through. */
+	case IPPROTO_UDPLITE:
+		*l4csum_offset = offsetof(struct udphdr, check);
+		break;
+	case IPPROTO_ICMPV6:
+		*l4csum_offset = offsetof(struct icmp6hdr, icmp6_cksum);
+		break;
+	default:
+		return -1;
+	}
+
+	*l4csum_offset += pkt->xt.thoff;
+	return 0;
+}
+
+static int nft_payload_l4csum_update(const struct nft_pktinfo *pkt,
+				     struct sk_buff *skb,
+				     __wsum fsum, __wsum tsum)
+{
+	int l4csum_offset;
+	__sum16 sum;
+
+	/* If we cannot determine layer 4 checksum offset or this packet doesn't
+	 * require layer 4 checksum recalculation, skip this packet.
+	 */
+	if (nft_payload_l4csum_offset(pkt, skb, &l4csum_offset) < 0)
+		return 0;
+
+	if (skb_copy_bits(skb, l4csum_offset, &sum, sizeof(sum)) < 0)
+		return -1;
+
+	/* Checksum mangling for an arbitrary amount of bytes, based on
+	 * inet_proto_csum_replace*() functions.
+	 */
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		nft_csum_replace(&sum, fsum, tsum);
+		if (skb->ip_summed == CHECKSUM_COMPLETE) {
+			skb->csum = ~csum_add(csum_sub(~(skb->csum), fsum),
+					      tsum);
+		}
+	} else {
+		sum = ~csum_fold(csum_add(csum_sub(csum_unfold(sum), fsum),
+					  tsum));
+	}
+
+	if (!skb_make_writable(skb, l4csum_offset + sizeof(sum)) ||
+	    skb_store_bits(skb, l4csum_offset, &sum, sizeof(sum)) < 0)
+		return -1;
+
+	return 0;
+}
+
 static void nft_payload_set_eval(const struct nft_expr *expr,
 				 struct nft_regs *regs,
 				 const struct nft_pktinfo *pkt)
@@ -204,14 +290,15 @@ static void nft_payload_set_eval(const struct nft_expr *expr,
 
 		fsum = skb_checksum(skb, offset, priv->len, 0);
 		tsum = csum_partial(src, priv->len, 0);
-		sum = csum_fold(csum_add(csum_sub(~csum_unfold(sum), fsum),
-					 tsum));
-		if (sum == 0)
-			sum = CSUM_MANGLED_0;
+		nft_csum_replace(&sum, fsum, tsum);
 
 		if (!skb_make_writable(skb, csum_offset + sizeof(sum)) ||
 		    skb_store_bits(skb, csum_offset, &sum, sizeof(sum)) < 0)
 			goto err;
+
+		if (priv->csum_flags &&
+		    nft_payload_l4csum_update(pkt, skb, fsum, tsum) < 0)
+			goto err;
 	}
 
 	if (!skb_make_writable(skb, max(offset + priv->len, 0)) ||
@@ -240,6 +327,15 @@ static int nft_payload_set_init(const struct nft_ctx *ctx,
 	if (tb[NFTA_PAYLOAD_CSUM_OFFSET])
 		priv->csum_offset =
 			ntohl(nla_get_be32(tb[NFTA_PAYLOAD_CSUM_OFFSET]));
+	if (tb[NFTA_PAYLOAD_CSUM_FLAGS]) {
+		u32 flags;
+
+		flags = ntohl(nla_get_be32(tb[NFTA_PAYLOAD_CSUM_FLAGS]));
+		if (flags & ~NFT_PAYLOAD_L4CSUM_PSEUDOHDR)
+			return -EINVAL;
+
+		priv->csum_flags = flags;
+	}
 
 	switch (priv->csum_type) {
 	case NFT_PAYLOAD_CSUM_NONE:
@@ -262,7 +358,8 @@ static int nft_payload_set_dump(struct sk_buff *skb, const struct nft_expr *expr
 	    nla_put_be32(skb, NFTA_PAYLOAD_LEN, htonl(priv->len)) ||
 	    nla_put_be32(skb, NFTA_PAYLOAD_CSUM_TYPE, htonl(priv->csum_type)) ||
 	    nla_put_be32(skb, NFTA_PAYLOAD_CSUM_OFFSET,
-			 htonl(priv->csum_offset)))
+			 htonl(priv->csum_offset)) ||
+	    nla_put_be32(skb, NFTA_PAYLOAD_CSUM_FLAGS, htonl(priv->csum_flags)))
 		goto nla_put_failure;
 	return 0;
 
-- 
2.1.4
