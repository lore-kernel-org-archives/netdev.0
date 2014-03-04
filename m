From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv3 net-next 31/31] Revert "cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit()"
Date: Tue,  4 Mar 2014 18:11:57 +0530
Message-ID: <1393936917-25847-32-git-send-email-hariprasad@chelsio.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393936917-25847-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 0034b29 (cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit())
introduced a regression causing chip-hang. This patch needs more debugging and
more work. So reverting for now.

Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 32 ++++++++++----------------------
 1 file changed, 10 insertions(+), 22 deletions(-)

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
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
