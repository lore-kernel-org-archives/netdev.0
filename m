From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/23] netfilter: nft_meta: add l4proto support
Date: Fri, 10 Jan 2014 01:35:26 +0100
Message-ID: <1389314142-17969-8-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51523 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756162AbaAJAgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:06 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

For L3-proto independant rules we need to get at the L4 protocol value
directly. Add it to the nft_pktinfo struct and use the meta expression
to retrieve it.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |    1 +
 include/net/netfilter/nf_tables_ipv4.h   |    3 ++-
 include/net/netfilter/nf_tables_ipv6.h   |    1 +
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nft_meta.c                 |    4 ++++
 5 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index f066f25..5d2b703 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -16,6 +16,7 @@ struct nft_pktinfo {
 	const struct nf_hook_ops	*ops;
 	u8				nhoff;
 	u8				thoff;
+	u8				tprot;
 	/* for x_tables compatibility */
 	struct xt_action_param		xt;
 };
diff --git a/include/net/netfilter/nf_tables_ipv4.h b/include/net/netfilter/nf_tables_ipv4.h
index f7b3a66..cba143f 100644
--- a/include/net/netfilter/nf_tables_ipv4.h
+++ b/include/net/netfilter/nf_tables_ipv4.h
@@ -15,8 +15,9 @@ nft_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
 
 	nft_set_pktinfo(pkt, ops, skb, in, out);
 
-	pkt->xt.thoff = ip_hdrlen(pkt->skb);
 	ip = ip_hdr(pkt->skb);
+	pkt->tprot = ip->protocol;
+	pkt->xt.thoff = ip_hdrlen(pkt->skb);
 	pkt->xt.fragoff = ntohs(ip->frag_off) & IP_OFFSET;
 }
 
diff --git a/include/net/netfilter/nf_tables_ipv6.h b/include/net/netfilter/nf_tables_ipv6.h
index 3d8ae48..74d9761 100644
--- a/include/net/netfilter/nf_tables_ipv6.h
+++ b/include/net/netfilter/nf_tables_ipv6.h
@@ -21,6 +21,7 @@ nft_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 	if (protohdr < 0)
 		return -1;
 
+	pkt->tprot = protohdr;
 	pkt->xt.thoff = thoff;
 	pkt->xt.fragoff = frag_off;
 
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 10afbfc..448593c 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -532,6 +532,7 @@ enum nft_exthdr_attributes {
  * @NFT_META_RTCLASSID: realm value of packet's route (skb->dst->tclassid)
  * @NFT_META_SECMARK: packet secmark (skb->secmark)
  * @NFT_META_NFPROTO: netfilter protocol
+ * @NFT_META_L4PROTO: layer 4 protocol number
  */
 enum nft_meta_keys {
 	NFT_META_LEN,
@@ -550,6 +551,7 @@ enum nft_meta_keys {
 	NFT_META_RTCLASSID,
 	NFT_META_SECMARK,
 	NFT_META_NFPROTO,
+	NFT_META_L4PROTO,
 };
 
 /**
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 999d046..b43975a 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -46,6 +46,9 @@ static void nft_meta_get_eval(const struct nft_expr *expr,
 	case NFT_META_NFPROTO:
 		dest->data[0] = pkt->ops->pf;
 		break;
+	case NFT_META_L4PROTO:
+		dest->data[0] = pkt->tprot;
+		break;
 	case NFT_META_PRIORITY:
 		dest->data[0] = skb->priority;
 		break;
@@ -185,6 +188,7 @@ static int nft_meta_init_validate_get(uint32_t key)
 	case NFT_META_LEN:
 	case NFT_META_PROTOCOL:
 	case NFT_META_NFPROTO:
+	case NFT_META_L4PROTO:
 	case NFT_META_PRIORITY:
 	case NFT_META_MARK:
 	case NFT_META_IIF:
-- 
1.7.10.4
