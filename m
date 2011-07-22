From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/10] ixgbe: Pass staterr instead of re-reading status and error bits from descriptor
Date: Thu, 21 Jul 2011 19:01:15 -0700
Message-ID: <1311300078-12876-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44276 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223Ab1GVCBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 22:01:25 -0400
In-Reply-To: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to address possible race conditions from the status
and error bits on the RX descriptors being re-read by multiple functions in
the RX cleanup path.  To resolve this I have added code that will pass the
staterr value to those functions.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |    5 +++--
 drivers/net/ixgbe/ixgbe_fcoe.c |   35 ++++++-----------------------------
 drivers/net/ixgbe/ixgbe_main.c |   39 ++++++++++++++++++++++++++++-----------
 3 files changed, 37 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index fbae735..0d610c7 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -600,8 +600,9 @@ extern int ixgbe_fso(struct ixgbe_ring *tx_ring, struct sk_buff *skb,
                      u32 tx_flags, u8 *hdr_len);
 extern void ixgbe_cleanup_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
-                          union ixgbe_adv_rx_desc *rx_desc,
-                          struct sk_buff *skb);
+			  union ixgbe_adv_rx_desc *rx_desc,
+			  struct sk_buff *skb,
+			  u32 staterr);
 extern int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
                               struct scatterlist *sgl, unsigned int sgc);
 extern int ixgbe_fcoe_ddp_target(struct net_device *netdev, u16 xid,
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index f0c1018..824edae 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -37,25 +37,6 @@
 #include <scsi/libfcoe.h>
 
 /**
- * ixgbe_rx_is_fcoe - check the rx desc for incoming pkt type
- * @rx_desc: advanced rx descriptor
- *
- * Returns : true if it is FCoE pkt
- */
-static inline bool ixgbe_rx_is_fcoe(union ixgbe_adv_rx_desc *rx_desc)
-{
-	u16 p;
-
-	p = le16_to_cpu(rx_desc->wb.lower.lo_dword.hs_rss.pkt_info);
-	if (p & IXGBE_RXDADV_PKTTYPE_ETQF) {
-		p &= IXGBE_RXDADV_PKTTYPE_ETQF_MASK;
-		p >>= IXGBE_RXDADV_PKTTYPE_ETQF_SHIFT;
-		return p == IXGBE_ETQF_FILTER_FCOE;
-	}
-	return false;
-}
-
-/**
  * ixgbe_fcoe_clear_ddp - clear the given ddp context
  * @ddp - ptr to the ixgbe_fcoe_ddp
  *
@@ -136,7 +117,6 @@ out_ddp_put:
 	return len;
 }
 
-
 /**
  * ixgbe_fcoe_ddp_setup - called to set up ddp context
  * @netdev: the corresponding net_device
@@ -380,23 +360,20 @@ int ixgbe_fcoe_ddp_target(struct net_device *netdev, u16 xid,
  */
 int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 		   union ixgbe_adv_rx_desc *rx_desc,
-		   struct sk_buff *skb)
+		   struct sk_buff *skb,
+		   u32 staterr)
 {
 	u16 xid;
 	u32 fctl;
-	u32 sterr, fceofe, fcerr, fcstat;
+	u32 fceofe, fcerr, fcstat;
 	int rc = -EINVAL;
 	struct ixgbe_fcoe *fcoe;
 	struct ixgbe_fcoe_ddp *ddp;
 	struct fc_frame_header *fh;
 	struct fcoe_crc_eof *crc;
 
-	if (!ixgbe_rx_is_fcoe(rx_desc))
-		goto ddp_out;
-
-	sterr = le32_to_cpu(rx_desc->wb.upper.status_error);
-	fcerr = (sterr & IXGBE_RXDADV_ERR_FCERR);
-	fceofe = (sterr & IXGBE_RXDADV_ERR_FCEOFE);
+	fcerr = (staterr & IXGBE_RXDADV_ERR_FCERR);
+	fceofe = (staterr & IXGBE_RXDADV_ERR_FCEOFE);
 	if (fcerr == IXGBE_FCERR_BADCRC)
 		skb_checksum_none_assert(skb);
 	else
@@ -425,7 +402,7 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	if (fcerr | fceofe)
 		goto ddp_out;
 
-	fcstat = (sterr & IXGBE_RXDADV_STAT_FCSTAT);
+	fcstat = (staterr & IXGBE_RXDADV_STAT_FCSTAT);
 	if (fcstat) {
 		/* update length of DDPed data */
 		ddp->len = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 298c95b..f8dd730 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1039,6 +1039,24 @@ static inline void ixgbe_rx_hash(union ixgbe_adv_rx_desc *rx_desc,
 }
 
 /**
+ * ixgbe_rx_is_fcoe - check the rx desc for incoming pkt type
+ * @adapter: address of board private structure
+ * @rx_desc: advanced rx descriptor
+ *
+ * Returns : true if it is FCoE pkt
+ */
+static inline bool ixgbe_rx_is_fcoe(struct ixgbe_adapter *adapter,
+				    union ixgbe_adv_rx_desc *rx_desc)
+{
+	__le16 pkt_info = rx_desc->wb.lower.lo_dword.hs_rss.pkt_info;
+
+	return (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
+	       ((pkt_info & cpu_to_le16(IXGBE_RXDADV_PKTTYPE_ETQF_MASK)) ==
+		(cpu_to_le16(IXGBE_ETQF_FILTER_FCOE <<
+			     IXGBE_RXDADV_PKTTYPE_ETQF_SHIFT)));
+}
+
+/**
  * ixgbe_receive_skb - Send a completed packet up the stack
  * @adapter: board private structure
  * @skb: packet to send up
@@ -1070,14 +1088,14 @@ static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
  * @adapter: address of board private structure
  * @status_err: hardware indication of status of receive
  * @skb: skb currently being received and modified
+ * @status_err: status error value of last descriptor in packet
  **/
 static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
 				     union ixgbe_adv_rx_desc *rx_desc,
-				     struct sk_buff *skb)
+				     struct sk_buff *skb,
+				     u32 status_err)
 {
-	u32 status_err = le32_to_cpu(rx_desc->wb.upper.status_error);
-
-	skb_checksum_none_assert(skb);
+	skb->ip_summed = CHECKSUM_NONE;
 
 	/* Rx csum disabled */
 	if (!(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
@@ -1421,14 +1439,12 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		}
 
 		/* ERR_MASK will only have valid bits if EOP set */
-		if (staterr & IXGBE_RXDADV_ERR_FRAME_ERR_MASK) {
-			/* trim packet back to size 0 and recycle it */
-			__pskb_trim(skb, 0);
-			rx_buffer_info->skb = skb;
+		if (unlikely(staterr & IXGBE_RXDADV_ERR_FRAME_ERR_MASK)) {
+			dev_kfree_skb_any(skb);
 			goto next_desc;
 		}
 
-		ixgbe_rx_checksum(adapter, rx_desc, skb);
+		ixgbe_rx_checksum(adapter, rx_desc, skb, staterr);
 		if (adapter->netdev->features & NETIF_F_RXHASH)
 			ixgbe_rx_hash(rx_desc, skb);
 
@@ -1439,8 +1455,9 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 #ifdef IXGBE_FCOE
 		/* if ddp, not passing to ULD unless for FCP_RSP or error */
-		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
-			ddp_bytes = ixgbe_fcoe_ddp(adapter, rx_desc, skb);
+		if (xgbe_rx_is_fcoe(adapter, rx_desc)) {
+			ddp_bytes = ixgbe_fcoe_ddp(adapter, rx_desc, skb,
+						   staterr);
 			if (!ddp_bytes)
 				goto next_desc;
 		}
-- 
1.7.6

