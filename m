From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 31/31] Revert "cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit()"
Date: Mon,  3 Mar 2014 12:11:15 +0530
Message-ID: <1393828875-13452-32-git-send-email-hariprasad@chelsio.com>
References: <1393828875-13452-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, kumaras@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, hariprasad@chelsio.com, nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7866 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753942AbaCCGoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 01:44:30 -0500
In-Reply-To: <1393828875-13452-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0034b29 (cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit())
introduced a regression causing chip-hang. This patch needs more debugging and
more work. So reverting for now.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c |   32 +++++++++--------------------
 1 files changed, 10 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index c2e142d..25f8981 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -716,17 +716,11 @@ static inline unsigned int flits_to_desc(unsigned int n)
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
@@ -739,10 +733,9 @@ static inline int is_eth_imm(const struct sk_buff *skb)
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
@@ -990,7 +983,6 @@ static inline void txq_advance(struct sge_txq *q, unsigned int n)
  */
 netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	int len;
 	u32 wr_mid;
 	u64 cntrl, *end;
 	int qidx, credits;
@@ -1002,7 +994,6 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct cpl_tx_pkt_core *cpl;
 	const struct skb_shared_info *ssi;
 	dma_addr_t addr[MAX_SKB_FRAGS + 1];
-	bool immediate = false;
 
 	/*
 	 * The chip min packet length is 10 octets but play safe and reject
@@ -1032,10 +1023,7 @@ out_free:	dev_kfree_skb(skb);
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
@@ -1052,8 +1040,6 @@ out_free:	dev_kfree_skb(skb);
 	wr->r3 = cpu_to_be64(0);
 	end = (u64 *)wr + flits;
 
-	len = immediate ? skb->len : 0;
-	len += sizeof(*cpl);
 	ssi = skb_shinfo(skb);
 	if (ssi->gso_size) {
 		struct cpl_tx_pkt_lso *lso = (void *)wr;
@@ -1061,9 +1047,8 @@ out_free:	dev_kfree_skb(skb);
 		int l3hdr_len = skb_network_header_len(skb);
 		int eth_xtra_len = skb_network_offset(skb) - ETH_HLEN;
 
-		len += sizeof(*lso);
 		wr->op_immdlen = htonl(FW_WR_OP(FW_ETH_TX_PKT_WR) |
-				       FW_WR_IMMDLEN(len));
+				       FW_WR_IMMDLEN(sizeof(*lso)));
 		lso->c.lso_ctrl = htonl(LSO_OPCODE(CPL_TX_PKT_LSO) |
 					LSO_FIRST_SLICE | LSO_LAST_SLICE |
 					LSO_IPV6(v6) |
@@ -1081,6 +1066,9 @@ out_free:	dev_kfree_skb(skb);
 		q->tso++;
 		q->tx_cso += ssi->gso_segs;
 	} else {
+		int len;
+
+		len = is_eth_imm(skb) ? skb->len + sizeof(*cpl) : sizeof(*cpl);
 		wr->op_immdlen = htonl(FW_WR_OP(FW_ETH_TX_PKT_WR) |
 				       FW_WR_IMMDLEN(len));
 		cpl = (void *)(wr + 1);
@@ -1102,7 +1090,7 @@ out_free:	dev_kfree_skb(skb);
 	cpl->len = htons(skb->len);
 	cpl->ctrl1 = cpu_to_be64(cntrl);
 
-	if (immediate) {
+	if (is_eth_imm(skb)) {
 		inline_tx_skb(skb, &q->q, cpl + 1);
 		dev_kfree_skb(skb);
 	} else {
-- 
1.7.1
