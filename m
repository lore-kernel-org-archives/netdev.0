From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/7] ixgbe: Add function for testing status bits in Rx descriptor
Date: Fri, 10 Feb 2012 16:08:21 -0800
Message-ID: <1328918904-11511-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:19397 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761180Ab2BKAIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 19:08:30 -0500
In-Reply-To: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds a small function for testing Rx status bits in the
descriptor.  The advantage to this is that we can avoid unnecessary
byte swaps on big endian systems.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   10 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |   59 +++++++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   51 +++++++++------------
 3 files changed, 65 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index fca0553..260e176 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -329,6 +329,13 @@ struct ixgbe_q_vector {
 #define IXGBE_10K_ITR		400
 #define IXGBE_8K_ITR		500
 
+/* ixgbe_test_staterr - tests bits in Rx descriptor status and error fields */
+static inline __le32 ixgbe_test_staterr(union ixgbe_adv_rx_desc *rx_desc,
+					const u32 stat_err_bits)
+{
+	return rx_desc->wb.upper.status_error & cpu_to_le32(stat_err_bits);
+}
+
 static inline u16 ixgbe_desc_unused(struct ixgbe_ring *ring)
 {
 	u16 ntc = ring->next_to_clean;
@@ -618,8 +625,7 @@ extern int ixgbe_fso(struct ixgbe_ring *tx_ring, struct sk_buff *skb,
 extern void ixgbe_cleanup_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 			  union ixgbe_adv_rx_desc *rx_desc,
-			  struct sk_buff *skb,
-			  u32 staterr);
+			  struct sk_buff *skb);
 extern int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
                               struct scatterlist *sgl, unsigned int sgc);
 extern int ixgbe_fcoe_ddp_target(struct net_device *netdev, u16 xid,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 4bc7942..da7da75 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -357,22 +357,20 @@ int ixgbe_fcoe_ddp_target(struct net_device *netdev, u16 xid,
  */
 int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 		   union ixgbe_adv_rx_desc *rx_desc,
-		   struct sk_buff *skb,
-		   u32 staterr)
+		   struct sk_buff *skb)
 {
-	u16 xid;
-	u32 fctl;
-	u32 fceofe, fcerr, fcstat;
 	int rc = -EINVAL;
 	struct ixgbe_fcoe *fcoe;
 	struct ixgbe_fcoe_ddp *ddp;
 	struct fc_frame_header *fh;
 	struct fcoe_crc_eof *crc;
+	__le32 fcerr = ixgbe_test_staterr(rx_desc, IXGBE_RXDADV_ERR_FCERR);
+	__le32 ddp_err;
+	u32 fctl;
+	u16 xid;
 
-	fcerr = (staterr & IXGBE_RXDADV_ERR_FCERR);
-	fceofe = (staterr & IXGBE_RXDADV_ERR_FCEOFE);
-	if (fcerr == IXGBE_FCERR_BADCRC)
-		skb_checksum_none_assert(skb);
+	if (fcerr == cpu_to_le32(IXGBE_FCERR_BADCRC))
+		skb->ip_summed = CHECKSUM_NONE;
 	else
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
@@ -382,6 +380,7 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	else
 		fh = (struct fc_frame_header *)(skb->data +
 			sizeof(struct fcoe_hdr));
+
 	fctl = ntoh24(fh->fh_f_ctl);
 	if (fctl & FC_FC_EX_CTX)
 		xid =  be16_to_cpu(fh->fh_ox_id);
@@ -396,27 +395,39 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	if (!ddp->udl)
 		goto ddp_out;
 
-	if (fcerr | fceofe)
+	ddp_err = ixgbe_test_staterr(rx_desc, IXGBE_RXDADV_ERR_FCEOFE |
+					      IXGBE_RXDADV_ERR_FCERR);
+	if (ddp_err)
 		goto ddp_out;
 
-	fcstat = (staterr & IXGBE_RXDADV_STAT_FCSTAT);
-	if (fcstat) {
+	switch (ixgbe_test_staterr(rx_desc, IXGBE_RXDADV_STAT_FCSTAT)) {
+	/* return 0 to bypass going to ULD for DDPed data */
+	case __constant_cpu_to_le32(IXGBE_RXDADV_STAT_FCSTAT_DDP):
 		/* update length of DDPed data */
 		ddp->len = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
-		/* unmap the sg list when FCP_RSP is received */
-		if (fcstat == IXGBE_RXDADV_STAT_FCSTAT_FCPRSP) {
-			pci_unmap_sg(adapter->pdev, ddp->sgl,
-				     ddp->sgc, DMA_FROM_DEVICE);
-			ddp->err = (fcerr | fceofe);
-			ddp->sgl = NULL;
-			ddp->sgc = 0;
-		}
-		/* return 0 to bypass going to ULD for DDPed data */
-		if (fcstat == IXGBE_RXDADV_STAT_FCSTAT_DDP)
-			rc = 0;
-		else if (ddp->len)
+		rc = 0;
+		break;
+	/* unmap the sg list when FCPRSP is received */
+	case __constant_cpu_to_le32(IXGBE_RXDADV_STAT_FCSTAT_FCPRSP):
+		pci_unmap_sg(adapter->pdev, ddp->sgl,
+			     ddp->sgc, DMA_FROM_DEVICE);
+		ddp->err = ddp_err;
+		ddp->sgl = NULL;
+		ddp->sgc = 0;
+		/* fall through */
+	/* if DDP length is present pass it through to ULD */
+	case __constant_cpu_to_le32(IXGBE_RXDADV_STAT_FCSTAT_NODDP):
+		/* update length of DDPed data */
+		ddp->len = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
+		if (ddp->len)
 			rc = ddp->len;
+		break;
+	/* no match will return as an error */
+	case __constant_cpu_to_le32(IXGBE_RXDADV_STAT_FCSTAT_NOMTCH):
+	default:
+		break;
 	}
+
 	/* In target mode, check the last data frame of the sequence.
 	 * For DDP in target mode, data is already DDPed but the header
 	 * indication of the last data frame ould allow is to tell if we
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 538577b..b0469dd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1019,25 +1019,23 @@ static inline bool ixgbe_rx_is_fcoe(struct ixgbe_adapter *adapter,
  * ixgbe_receive_skb - Send a completed packet up the stack
  * @adapter: board private structure
  * @skb: packet to send up
- * @status: hardware indication of status of receive
  * @rx_ring: rx descriptor ring (for a specific queue) to setup
  * @rx_desc: rx descriptor
  **/
 static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
-			      struct sk_buff *skb, u8 status,
+			      struct sk_buff *skb,
 			      struct ixgbe_ring *ring,
 			      union ixgbe_adv_rx_desc *rx_desc)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct napi_struct *napi = &q_vector->napi;
-	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
-	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-	if (is_vlan && (tag & VLAN_VID_MASK))
-		__vlan_hwaccel_put_tag(skb, tag);
+	if (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_VP)) {
+		u16 vid = le16_to_cpu(rx_desc->wb.upper.vlan);
+		__vlan_hwaccel_put_tag(skb, vid);
+	}
 
 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
-		napi_gro_receive(napi, skb);
+		napi_gro_receive(&q_vector->napi, skb);
 	else
 		netif_rx(skb);
 }
@@ -1047,12 +1045,10 @@ static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
  * @adapter: address of board private structure
  * @status_err: hardware indication of status of receive
  * @skb: skb currently being received and modified
- * @status_err: status error value of last descriptor in packet
  **/
 static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
 				     union ixgbe_adv_rx_desc *rx_desc,
-				     struct sk_buff *skb,
-				     u32 status_err)
+				     struct sk_buff *skb)
 {
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -1061,16 +1057,16 @@ static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
 		return;
 
 	/* if IP and error */
-	if ((status_err & IXGBE_RXD_STAT_IPCS) &&
-	    (status_err & IXGBE_RXDADV_ERR_IPE)) {
+	if (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_IPCS) &&
+	    ixgbe_test_staterr(rx_desc, IXGBE_RXDADV_ERR_IPE)) {
 		adapter->hw_csum_rx_error++;
 		return;
 	}
 
-	if (!(status_err & IXGBE_RXD_STAT_L4CS))
+	if (!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_L4CS))
 		return;
 
-	if (status_err & IXGBE_RXDADV_ERR_TCPE) {
+	if (ixgbe_test_staterr(rx_desc, IXGBE_RXDADV_ERR_TCPE)) {
 		u16 pkt_info = rx_desc->wb.lower.lo_dword.hs_rss.pkt_info;
 
 		/*
@@ -1091,6 +1087,7 @@ static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
 
 static inline void ixgbe_release_rx_desc(struct ixgbe_ring *rx_ring, u32 val)
 {
+	rx_ring->next_to_use = val;
 	/*
 	 * Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
@@ -1219,10 +1216,8 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 
 	i += rx_ring->count;
 
-	if (rx_ring->next_to_use != i) {
-		rx_ring->next_to_use = i;
+	if (rx_ring->next_to_use != i)
 		ixgbe_release_rx_desc(rx_ring, i);
-	}
 }
 
 static inline u16 ixgbe_get_hlen(union ixgbe_adv_rx_desc *rx_desc)
@@ -1469,15 +1464,13 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 #ifdef IXGBE_FCOE
 	int ddp_bytes = 0;
 #endif /* IXGBE_FCOE */
-	u32 staterr;
 	u16 i;
 	u16 cleaned_count = 0;
 
 	i = rx_ring->next_to_clean;
 	rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
-	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 
-	while (staterr & IXGBE_RXD_STAT_DD) {
+	while (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_DD)) {
 		u32 upper_len = 0;
 
 		rmb(); /* read descriptor and rx_buffer_info after status DD */
@@ -1553,12 +1546,13 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		prefetch(next_rxd);
 		cleaned_count++;
 
-		if (!(staterr & IXGBE_RXD_STAT_EOP)) {
+		if ((!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))) {
 			struct ixgbe_rx_buffer *next_buffer;
 			u32 nextp;
 
 			if (IXGBE_CB(skb)->append_cnt) {
-				nextp = staterr & IXGBE_RXDADV_NEXTP_MASK;
+				nextp = le32_to_cpu(
+						rx_desc->wb.upper.status_error);
 				nextp >>= IXGBE_RXDADV_NEXTP_SHIFT;
 			} else {
 				nextp = i;
@@ -1597,12 +1591,13 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		ixgbe_update_rsc_stats(rx_ring, skb);
 
 		/* ERR_MASK will only have valid bits if EOP set */
-		if (unlikely(staterr & IXGBE_RXDADV_ERR_FRAME_ERR_MASK)) {
+		if (unlikely(ixgbe_test_staterr(rx_desc,
+					    IXGBE_RXDADV_ERR_FRAME_ERR_MASK))) {
 			dev_kfree_skb_any(skb);
 			goto next_desc;
 		}
 
-		ixgbe_rx_checksum(adapter, rx_desc, skb, staterr);
+		ixgbe_rx_checksum(adapter, rx_desc, skb);
 		if (adapter->netdev->features & NETIF_F_RXHASH)
 			ixgbe_rx_hash(rx_desc, skb);
 
@@ -1614,15 +1609,14 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 #ifdef IXGBE_FCOE
 		/* if ddp, not passing to ULD unless for FCP_RSP or error */
 		if (ixgbe_rx_is_fcoe(adapter, rx_desc)) {
-			ddp_bytes = ixgbe_fcoe_ddp(adapter, rx_desc, skb,
-						   staterr);
+			ddp_bytes = ixgbe_fcoe_ddp(adapter, rx_desc, skb);
 			if (!ddp_bytes) {
 				dev_kfree_skb_any(skb);
 				goto next_desc;
 			}
 		}
 #endif /* IXGBE_FCOE */
-		ixgbe_receive_skb(q_vector, skb, staterr, rx_ring, rx_desc);
+		ixgbe_receive_skb(q_vector, skb, rx_ring, rx_desc);
 
 		budget--;
 next_desc:
@@ -1637,7 +1631,6 @@ next_desc:
 
 		/* use prefetched values */
 		rx_desc = next_rxd;
-		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
 
 	rx_ring->next_to_clean = i;
-- 
1.7.7.6
