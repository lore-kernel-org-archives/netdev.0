From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] Revert "cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit()"
Date: Wed,  5 Mar 2014 16:19:16 +0530
Message-ID: <1394016556-12358-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, dm@chelsio.com,
	leedom@chelsio.com, santosh@chelsio.com, hariprasad@chelsio.com,
	nirranjan@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28531 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753926AbaCEKuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 05:50:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0034b29 (cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit())
introduced a regression causing chip-hang. This patch needs more debugging and
more work. So reverting for now.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 32 ++++++++++----------------------
 1 file changed, 10 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index af76b25..23dbe28 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -706,17 +706,11 @@ static inline unsigned int flits_to_desc(unsigned int n)
  *	@skb: the packet
  *
  *	Returns whether an Ethernet packet is small enough to fit as
- *	immediate data. Return value corresponds to headroom required.
+ *	immediate data.
  */
 static inline int is_eth_imm(const struct sk_buff *skb)
 {
-	int hdrlen = skb_shinfo(skb)->gso_size ?
-			sizeof(struct cpl_tx_pkt_lso_core) : 0;
-
-	hdrlen += sizeof(struct cpl_tx_pkt);
-	if (skb->len <= MAX_IMM_TX_PKT_LEN - hdrlen)
-		return hdrlen;
-	return 0;
+	return skb->len <= MAX_IMM_TX_PKT_LEN - sizeof(struct cpl_tx_pkt);
 }
 
 /**
@@ -729,10 +723,9 @@ static inline int is_eth_imm(const struct sk_buff *skb)
 static inline unsigned int calc_tx_flits(const struct sk_buff *skb)
 {
 	unsigned int flits;
-	int hdrlen = is_eth_imm(skb);
 
-	if (hdrlen)
-		return DIV_ROUND_UP(skb->len + hdrlen, sizeof(__be64));
+	if (is_eth_imm(skb))
+		return DIV_ROUND_UP(skb->len + sizeof(struct cpl_tx_pkt), 8);
 
 	flits = sgl_len(skb_shinfo(skb)->nr_frags + 1) + 4;
 	if (skb_shinfo(skb)->gso_size)
@@ -978,7 +971,6 @@ static inline void txq_advance(struct sge_txq *q, unsigned int n)
  */
 netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	int len;
 	u32 wr_mid;
 	u64 cntrl, *end;
 	int qidx, credits;
@@ -990,7 +982,6 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct cpl_tx_pkt_core *cpl;
 	const struct skb_shared_info *ssi;
 	dma_addr_t addr[MAX_SKB_FRAGS + 1];
-	bool immediate = false;
 
 	/*
 	 * The chip min packet length is 10 octets but play safe and reject
@@ -1020,10 +1011,7 @@ out_free:	dev_kfree_skb(skb);
 		return NETDEV_TX_BUSY;
 	}
 
-	if (is_eth_imm(skb))
-		immediate = true;
-
-	if (!immediate &&
+	if (!is_eth_imm(skb) &&
 	    unlikely(map_skb(adap->pdev_dev, skb, addr) < 0)) {
 		q->mapping_err++;
 		goto out_free;
@@ -1040,8 +1028,6 @@ out_free:	dev_kfree_skb(skb);
 	wr->r3 = cpu_to_be64(0);
 	end = (u64 *)wr + flits;
 
-	len = immediate ? skb->len : 0;
-	len += sizeof(*cpl);
 	ssi = skb_shinfo(skb);
 	if (ssi->gso_size) {
 		struct cpl_tx_pkt_lso *lso = (void *)wr;
@@ -1049,9 +1035,8 @@ out_free:	dev_kfree_skb(skb);
 		int l3hdr_len = skb_network_header_len(skb);
 		int eth_xtra_len = skb_network_offset(skb) - ETH_HLEN;
 
-		len += sizeof(*lso);
 		wr->op_immdlen = htonl(FW_WR_OP(FW_ETH_TX_PKT_WR) |
-				       FW_WR_IMMDLEN(len));
+				       FW_WR_IMMDLEN(sizeof(*lso)));
 		lso->c.lso_ctrl = htonl(LSO_OPCODE(CPL_TX_PKT_LSO) |
 					LSO_FIRST_SLICE | LSO_LAST_SLICE |
 					LSO_IPV6(v6) |
@@ -1069,6 +1054,9 @@ out_free:	dev_kfree_skb(skb);
 		q->tso++;
 		q->tx_cso += ssi->gso_segs;
 	} else {
+		int len;
+
+		len = is_eth_imm(skb) ? skb->len + sizeof(*cpl) : sizeof(*cpl);
 		wr->op_immdlen = htonl(FW_WR_OP(FW_ETH_TX_PKT_WR) |
 				       FW_WR_IMMDLEN(len));
 		cpl = (void *)(wr + 1);
@@ -1090,7 +1078,7 @@ out_free:	dev_kfree_skb(skb);
 	cpl->len = htons(skb->len);
 	cpl->ctrl1 = cpu_to_be64(cntrl);
 
-	if (immediate) {
+	if (is_eth_imm(skb)) {
 		inline_tx_skb(skb, &q->q, cpl + 1);
 		dev_kfree_skb(skb);
 	} else {
-- 
1.8.4
