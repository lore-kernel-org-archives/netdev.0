From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/3] cxgb4vf: Adds SRIOV driver changes for T6 adapter
Date: Tue,  2 Jun 2015 06:32:05 +0530
Message-ID: <1433206925-5997-4-git-send-email-hariprasad@chelsio.com>
References: <1433206925-5997-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9888 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752731AbbFATtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 15:49:07 -0400
In-Reply-To: <1433206925-5997-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds vnic driver register related changes for T6 adapter

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         | 45 ++++++++++++++--------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |  8 ++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     | 24 ++++++++----
 3 files changed, 54 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index be4ab09..ad53e5a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -524,7 +524,7 @@ static void unmap_rx_buf(struct adapter *adapter, struct sge_fl *fl)
  */
 static inline void ring_fl_db(struct adapter *adapter, struct sge_fl *fl)
 {
-	u32 val;
+	u32 val = adapter->params.arch.sge_fl_db;
 
 	/* The SGE keeps track of its Producer and Consumer Indices in terms
 	 * of Egress Queue Units so we can only tell it about integral numbers
@@ -532,11 +532,9 @@ static inline void ring_fl_db(struct adapter *adapter, struct sge_fl *fl)
 	 */
 	if (fl->pend_cred >= FL_PER_EQ_UNIT) {
 		if (is_t4(adapter->params.chip))
-			val = PIDX_V(fl->pend_cred / FL_PER_EQ_UNIT);
+			val |= PIDX_V(fl->pend_cred / FL_PER_EQ_UNIT);
 		else
-			val = PIDX_T5_V(fl->pend_cred / FL_PER_EQ_UNIT) |
-			      DBTYPE_F;
-		val |= DBPRIO_F;
+			val |= PIDX_T5_V(fl->pend_cred / FL_PER_EQ_UNIT);
 
 		/* Make sure all memory writes to the Free List queue are
 		 * committed before we tell the hardware about them.
@@ -1084,7 +1082,7 @@ static void inline_tx_skb(const struct sk_buff *skb, const struct sge_txq *tq,
  * Figure out what HW csum a packet wants and return the appropriate control
  * bits.
  */
-static u64 hwcsum(const struct sk_buff *skb)
+static u64 hwcsum(enum chip_type chip, const struct sk_buff *skb)
 {
 	int csum_type;
 	const struct iphdr *iph = ip_hdr(skb);
@@ -1116,11 +1114,16 @@ nocsum:
 			goto nocsum;
 	}
 
-	if (likely(csum_type >= TX_CSUM_TCPIP))
-		return TXPKT_CSUM_TYPE_V(csum_type) |
-			TXPKT_IPHDR_LEN_V(skb_network_header_len(skb)) |
-			TXPKT_ETHHDR_LEN_V(skb_network_offset(skb) - ETH_HLEN);
-	else {
+	if (likely(csum_type >= TX_CSUM_TCPIP)) {
+		u64 hdr_len = TXPKT_IPHDR_LEN_V(skb_network_header_len(skb));
+		int eth_hdr_len = skb_network_offset(skb) - ETH_HLEN;
+
+		if (chip <= CHELSIO_T5)
+			hdr_len |= TXPKT_ETHHDR_LEN_V(eth_hdr_len);
+		else
+			hdr_len |= T6_TXPKT_ETHHDR_LEN_V(eth_hdr_len);
+		return TXPKT_CSUM_TYPE_V(csum_type) | hdr_len;
+	} else {
 		int start = skb_transport_offset(skb);
 
 		return TXPKT_CSUM_TYPE_V(csum_type) |
@@ -1308,10 +1311,15 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * accounting.
 		 */
 		cpl = (void *)(lso + 1);
-		cntrl = (TXPKT_CSUM_TYPE_V(v6 ?
+
+		if (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5)
+			cntrl = TXPKT_ETHHDR_LEN_V(eth_xtra_len);
+		else
+			cntrl = T6_TXPKT_ETHHDR_LEN_V(eth_xtra_len);
+
+		cntrl |= TXPKT_CSUM_TYPE_V(v6 ?
 					   TX_CSUM_TCPIP6 : TX_CSUM_TCPIP) |
-			 TXPKT_IPHDR_LEN_V(l3hdr_len) |
-			 TXPKT_ETHHDR_LEN_V(eth_xtra_len));
+			 TXPKT_IPHDR_LEN_V(l3hdr_len);
 		txq->tso++;
 		txq->tx_cso += ssi->gso_segs;
 	} else {
@@ -1328,7 +1336,8 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		cpl = (void *)(wr + 1);
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			cntrl = hwcsum(skb) | TXPKT_IPCSUM_DIS_F;
+			cntrl = hwcsum(adapter->params.chip, skb) |
+				TXPKT_IPCSUM_DIS_F;
 			txq->tx_cso++;
 		} else
 			cntrl = TXPKT_L4CSUM_DIS_F | TXPKT_IPCSUM_DIS_F;
@@ -2247,6 +2256,8 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 	cmd.iqaddr = cpu_to_be64(rspq->phys_addr);
 
 	if (fl) {
+		enum chip_type chip =
+			CHELSIO_CHIP_VERSION(adapter->params.chip);
 		/*
 		 * Allocate the ring for the hardware free list (with space
 		 * for its status page) along with the associated software
@@ -2286,7 +2297,9 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 		cmd.fl0dcaen_to_fl0cidxfthresh =
 			cpu_to_be16(
 				FW_IQ_CMD_FL0FBMIN_V(SGE_FETCHBURSTMIN_64B) |
-				FW_IQ_CMD_FL0FBMAX_V(SGE_FETCHBURSTMAX_512B));
+				FW_IQ_CMD_FL0FBMAX_V((chip <= CHELSIO_T5) ?
+						     FETCHBURSTMAX_512B_X :
+						     FETCHBURSTMAX_256B_X));
 		cmd.fl0size = cpu_to_be16(flsz);
 		cmd.fl0addr = cpu_to_be64(fl->addr);
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 75df259..88b8981b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -51,6 +51,7 @@
  */
 #define CHELSIO_T4		0x4
 #define CHELSIO_T5		0x5
+#define CHELSIO_T6		0x6
 
 enum chip_type {
 	T4_A1 = CHELSIO_CHIP_CODE(CHELSIO_T4, 1),
@@ -156,6 +157,12 @@ struct vpd_params {
 	u32 cclk;			/* Core Clock (KHz) */
 };
 
+/* Stores chip specific parameters */
+struct arch_specific_params {
+	u32 sge_fl_db;
+	u16 mps_tcam_size;
+};
+
 /*
  * Global Receive Side Scaling (RSS) parameters in host-native format.
  */
@@ -215,6 +222,7 @@ struct adapter_params {
 	struct vpd_params vpd;		/* Vital Product Data */
 	struct rss_params rss;		/* Receive Side Scaling */
 	struct vf_resources vfres;	/* Virtual Function Resource limits */
+	struct arch_specific_params arch; /* chip specific params */
 	enum chip_type chip;		/* chip code */
 	u8 nports;			/* # of Ethernet "ports" */
 };
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 135909e..0db6dc9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -1191,9 +1191,7 @@ int t4vf_alloc_mac_filt(struct adapter *adapter, unsigned int viid, bool free,
 	unsigned nfilters = 0;
 	unsigned int rem = naddr;
 	struct fw_vi_mac_cmd cmd, rpl;
-	unsigned int max_naddr = is_t4(adapter->params.chip) ?
-				 NUM_MPS_CLS_SRAM_L_INSTANCES :
-				 NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
+	unsigned int max_naddr = adapter->params.arch.mps_tcam_size;
 
 	if (naddr > max_naddr)
 		return -EINVAL;
@@ -1285,9 +1283,7 @@ int t4vf_change_mac(struct adapter *adapter, unsigned int viid,
 	struct fw_vi_mac_exact *p = &cmd.u.exact[0];
 	size_t len16 = DIV_ROUND_UP(offsetof(struct fw_vi_mac_cmd,
 					     u.exact[1]), 16);
-	unsigned int max_naddr = is_t4(adapter->params.chip) ?
-				 NUM_MPS_CLS_SRAM_L_INSTANCES :
-				 NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
+	unsigned int max_mac_addr = adapter->params.arch.mps_tcam_size;
 
 	/*
 	 * If this is a new allocation, determine whether it should be
@@ -1310,7 +1306,7 @@ int t4vf_change_mac(struct adapter *adapter, unsigned int viid,
 	if (ret == 0) {
 		p = &rpl.u.exact[0];
 		ret = FW_VI_MAC_CMD_IDX_G(be16_to_cpu(p->valid_to_idx));
-		if (ret >= max_naddr)
+		if (ret >= max_mac_addr)
 			ret = -ENOMEM;
 	}
 	return ret;
@@ -1590,11 +1586,25 @@ int t4vf_prep_adapter(struct adapter *adapter)
 	switch (CHELSIO_PCI_ID_VER(adapter->pdev->device)) {
 	case CHELSIO_T4:
 		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T4, 0);
+		adapter->params.arch.sge_fl_db = DBPRIO_F;
+		adapter->params.arch.mps_tcam_size =
+				NUM_MPS_CLS_SRAM_L_INSTANCES;
 		break;
 
 	case CHELSIO_T5:
 		chipid = REV_G(t4_read_reg(adapter, PL_VF_REV_A));
 		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T5, chipid);
+		adapter->params.arch.sge_fl_db = DBPRIO_F | DBTYPE_F;
+		adapter->params.arch.mps_tcam_size =
+				NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
+		break;
+
+	case CHELSIO_T6:
+		chipid = REV_G(t4_read_reg(adapter, PL_VF_REV_A));
+		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T6, chipid);
+		adapter->params.arch.sge_fl_db = 0;
+		adapter->params.arch.mps_tcam_size =
+				NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
 		break;
 	}
 
-- 
2.3.4
