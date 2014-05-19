From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 5/9] net: mv643xx_eth: Factorize initial checksum and command preparation
Date: Mon, 19 May 2014 13:59:56 -0300
Message-ID: <1400518800-6111-6-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53608 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751596AbaESRBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 13:01:10 -0400
In-Reply-To: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the code more readable by moving the initial checksum setup
and the command/status preparation to its own function.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 113 +++++++++++++++++------------
 1 file changed, 65 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index df1d1b9..14a0dbb 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -661,6 +661,64 @@ static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
 	return 0;
 }
 
+static inline __be16 sum16_as_be(__sum16 sum)
+{
+	return (__force __be16)sum;
+}
+
+static int skb_tx_csum(struct mv643xx_eth_private *mp, struct sk_buff *skb,
+		       u16 *l4i_chk, u32 *command, int length)
+{
+	int ret;
+	u32 cmd = 0;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		int hdr_len;
+		int tag_bytes;
+
+		BUG_ON(skb->protocol != htons(ETH_P_IP) &&
+		       skb->protocol != htons(ETH_P_8021Q));
+
+		hdr_len = (void *)ip_hdr(skb) - (void *)skb->data;
+		tag_bytes = hdr_len - ETH_HLEN;
+
+		if (length - hdr_len > mp->shared->tx_csum_limit ||
+		    unlikely(tag_bytes & ~12)) {
+			ret = skb_checksum_help(skb);
+			if (!ret)
+				goto no_csum;
+			return ret;
+		}
+
+		if (tag_bytes & 4)
+			cmd |= MAC_HDR_EXTRA_4_BYTES;
+		if (tag_bytes & 8)
+			cmd |= MAC_HDR_EXTRA_8_BYTES;
+
+		cmd |= GEN_TCP_UDP_CHECKSUM |
+			   GEN_IP_V4_CHECKSUM   |
+			   ip_hdr(skb)->ihl << TX_IHL_SHIFT;
+
+		switch (ip_hdr(skb)->protocol) {
+		case IPPROTO_UDP:
+			cmd |= UDP_FRAME;
+			*l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
+			break;
+		case IPPROTO_TCP:
+			*l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
+			break;
+		default:
+			WARN(1, "protocol not supported");
+		}
+	} else {
+no_csum:
+		/* Errata BTS #50, IHL must be 5 if no HW checksum */
+		cmd |= 5 << TX_IHL_SHIFT;
+	}
+	*command = cmd;
+	return 0;
+}
+
 static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
@@ -699,11 +757,6 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 	}
 }
 
-static inline __be16 sum16_as_be(__sum16 sum)
-{
-	return (__force __be16)sum;
-}
-
 static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
@@ -712,53 +765,17 @@ static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 	struct tx_desc *desc;
 	u32 cmd_sts;
 	u16 l4i_chk;
-	int length;
+	int length, ret;
 
-	cmd_sts = TX_FIRST_DESC | GEN_CRC | BUFFER_OWNED_BY_DMA;
+	cmd_sts = 0;
 	l4i_chk = 0;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		int hdr_len;
-		int tag_bytes;
-
-		BUG_ON(skb->protocol != htons(ETH_P_IP) &&
-		       skb->protocol != htons(ETH_P_8021Q));
-
-		hdr_len = (void *)ip_hdr(skb) - (void *)skb->data;
-		tag_bytes = hdr_len - ETH_HLEN;
-		if (skb->len - hdr_len > mp->shared->tx_csum_limit ||
-		    unlikely(tag_bytes & ~12)) {
-			if (skb_checksum_help(skb) == 0)
-				goto no_csum;
-			dev_kfree_skb_any(skb);
-			return 1;
-		}
-
-		if (tag_bytes & 4)
-			cmd_sts |= MAC_HDR_EXTRA_4_BYTES;
-		if (tag_bytes & 8)
-			cmd_sts |= MAC_HDR_EXTRA_8_BYTES;
-
-		cmd_sts |= GEN_TCP_UDP_CHECKSUM |
-			   GEN_IP_V4_CHECKSUM   |
-			   ip_hdr(skb)->ihl << TX_IHL_SHIFT;
-
-		switch (ip_hdr(skb)->protocol) {
-		case IPPROTO_UDP:
-			cmd_sts |= UDP_FRAME;
-			l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
-			break;
-		case IPPROTO_TCP:
-			l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
-			break;
-		default:
-			BUG();
-		}
-	} else {
-no_csum:
-		/* Errata BTS #50, IHL must be 5 if no HW checksum */
-		cmd_sts |= 5 << TX_IHL_SHIFT;
+	ret = skb_tx_csum(mp, skb, &l4i_chk, &cmd_sts, skb->len);
+	if (ret) {
+		dev_kfree_skb_any(skb);
+		return ret;
 	}
+	cmd_sts |= TX_FIRST_DESC | GEN_CRC | BUFFER_OWNED_BY_DMA;
 
 	tx_index = txq->tx_curr_desc++;
 	if (txq->tx_curr_desc == txq->tx_ring_size)
-- 
1.9.1
