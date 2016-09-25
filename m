From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 32/53] netfilter: nf_tables: check tprot_set first when we use xt.thoff
Date: Mon, 26 Sep 2016 01:06:42 +0200
Message-ID: <1474844823-2026-33-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

pkt->xt.thoff is not always set properly, but we use it without any check.
For payload expr, it will cause wrong results. For nftrace, we may notify
the wrong network or transport header to the user space, furthermore,
input the following nft rules, warning message will be printed out:
  # nft add rule arp filter output meta nftrace set 1

  WARNING: CPU: 0 PID: 13428 at net/netfilter/nf_tables_trace.c:263
  nft_trace_notify+0x4a3/0x5e0 [nf_tables]
  Call Trace:
  [<ffffffff813d58ae>] dump_stack+0x63/0x85
  [<ffffffff810a4c0b>] __warn+0xcb/0xf0
  [<ffffffff810a4d3d>] warn_slowpath_null+0x1d/0x20
  [<ffffffffa0589703>] nft_trace_notify+0x4a3/0x5e0 [nf_tables]
  [ ... ]
  [<ffffffffa05690a8>] nft_do_chain_arp+0x78/0x90 [nf_tables_arp]
  [<ffffffff816f4aa2>] nf_iterate+0x62/0x80
  [<ffffffff816f4b33>] nf_hook_slow+0x73/0xd0
  [<ffffffff81732bbf>] arp_xmit+0x8f/0xb0
  [ ... ]
  [<ffffffff81732d36>] arp_solicit+0x106/0x2c0

So before we use pkt->xt.thoff, check the tprot_set first.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c  |  5 ++++-
 net/netfilter/nf_tables_trace.c | 20 +++++++++++---------
 net/netfilter/nft_payload.c     |  4 ++++
 3 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 36ba4e55d84e..67259cefef06 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -93,8 +93,11 @@ static bool nft_payload_fast_eval(const struct nft_expr *expr,
 
 	if (priv->base == NFT_PAYLOAD_NETWORK_HEADER)
 		ptr = skb_network_header(skb);
-	else
+	else {
+		if (!pkt->tprot_set)
+			return false;
 		ptr = skb_network_header(skb) + pkt->xt.thoff;
+	}
 
 	ptr += priv->offset;
 
diff --git a/net/netfilter/nf_tables_trace.c b/net/netfilter/nf_tables_trace.c
index 39eb1cc62e91..696fe8f6f2f2 100644
--- a/net/netfilter/nf_tables_trace.c
+++ b/net/netfilter/nf_tables_trace.c
@@ -113,20 +113,22 @@ static int nf_trace_fill_pkt_info(struct sk_buff *nlskb,
 				  const struct nft_pktinfo *pkt)
 {
 	const struct sk_buff *skb = pkt->skb;
-	unsigned int len = min_t(unsigned int,
-				 pkt->xt.thoff - skb_network_offset(skb),
-				 NFT_TRACETYPE_NETWORK_HSIZE);
 	int off = skb_network_offset(skb);
+	unsigned int len, nh_end;
 
+	nh_end = pkt->tprot_set ? pkt->xt.thoff : skb->len;
+	len = min_t(unsigned int, nh_end - skb_network_offset(skb),
+		    NFT_TRACETYPE_NETWORK_HSIZE);
 	if (trace_fill_header(nlskb, NFTA_TRACE_NETWORK_HEADER, skb, off, len))
 		return -1;
 
-	len = min_t(unsigned int, skb->len - pkt->xt.thoff,
-		    NFT_TRACETYPE_TRANSPORT_HSIZE);
-
-	if (trace_fill_header(nlskb, NFTA_TRACE_TRANSPORT_HEADER, skb,
-			      pkt->xt.thoff, len))
-		return -1;
+	if (pkt->tprot_set) {
+		len = min_t(unsigned int, skb->len - pkt->xt.thoff,
+			    NFT_TRACETYPE_TRANSPORT_HSIZE);
+		if (trace_fill_header(nlskb, NFTA_TRACE_TRANSPORT_HEADER, skb,
+				      pkt->xt.thoff, len))
+			return -1;
+	}
 
 	if (!skb_mac_header_was_set(skb))
 		return 0;
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 12cd4bf16d17..b2f88617611a 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -92,6 +92,8 @@ static void nft_payload_eval(const struct nft_expr *expr,
 		offset = skb_network_offset(skb);
 		break;
 	case NFT_PAYLOAD_TRANSPORT_HEADER:
+		if (!pkt->tprot_set)
+			goto err;
 		offset = pkt->xt.thoff;
 		break;
 	default:
@@ -184,6 +186,8 @@ static void nft_payload_set_eval(const struct nft_expr *expr,
 		offset = skb_network_offset(skb);
 		break;
 	case NFT_PAYLOAD_TRANSPORT_HEADER:
+		if (!pkt->tprot_set)
+			goto err;
 		offset = pkt->xt.thoff;
 		break;
 	default:
-- 
2.1.4

