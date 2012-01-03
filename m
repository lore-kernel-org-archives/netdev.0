From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] e1000e: cleanup Rx checksum offload code
Date: Tue,  3 Jan 2012 11:19:12 -0800
Message-ID: <1325618356-2655-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57343 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754786Ab2ACTTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 14:19:48 -0500
In-Reply-To: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

1) cleanup whitespace in e1000_rx_checksum() function header comment
2) do not check hardware checksum when Rx checksum is disabled
3) reduce duplicated calls to le16_to_cpu() by just using it within
   e1000_rx_checksum() instead of in each call to the function

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 3911401..e01ffce 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -487,10 +487,10 @@ static void e1000_receive_skb(struct e1000_adapter *adapter,
 
 /**
  * e1000_rx_checksum - Receive Checksum Offload
- * @adapter:     board private structure
- * @status_err:  receive descriptor status and error fields
- * @csum:	receive descriptor csum field
- * @sk_buff:     socket buffer with received data
+ * @adapter: board private structure
+ * @status_err: receive descriptor status and error fields
+ * @csum: receive descriptor csum field
+ * @sk_buff: socket buffer with received data
  **/
 static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 			      u32 csum, struct sk_buff *skb)
@@ -500,9 +500,14 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 
 	skb_checksum_none_assert(skb);
 
+	/* Rx checksum disabled */
+	if (!(adapter->netdev->features & NETIF_F_RXCSUM))
+		return;
+
 	/* Ignore Checksum bit is set */
 	if (status & E1000_RXD_STAT_IXSM)
 		return;
+
 	/* TCP/UDP checksum error bit is set */
 	if (errors & E1000_RXD_ERR_TCPE) {
 		/* let the stack verify checksum errors */
@@ -524,7 +529,7 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 		 * Hardware complements the payload checksum, so we undo it
 		 * and then put the value in host order for further stack use.
 		 */
-		__sum16 sum = (__force __sum16)htons(csum);
+		__sum16 sum = (__force __sum16)htons(le16_to_cpu(csum));
 		skb->csum = csum_unfold(~sum);
 		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
@@ -957,8 +962,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		/* Receive Checksum Offload */
 		e1000_rx_checksum(adapter, staterr,
-				  le16_to_cpu(rx_desc->wb.lower.hi_dword.
-					      csum_ip.csum), skb);
+				  rx_desc->wb.lower.hi_dword.csum_ip.csum, skb);
 
 		e1000_receive_skb(adapter, netdev, skb, staterr,
 				  rx_desc->wb.upper.vlan);
@@ -1318,8 +1322,8 @@ copydone:
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
 
-		e1000_rx_checksum(adapter, staterr, le16_to_cpu(
-			rx_desc->wb.lower.hi_dword.csum_ip.csum), skb);
+		e1000_rx_checksum(adapter, staterr,
+				  rx_desc->wb.lower.hi_dword.csum_ip.csum, skb);
 
 		if (rx_desc->wb.upper.header_status &
 			   cpu_to_le16(E1000_RXDPS_HDRSTAT_HDRSP))
@@ -1491,8 +1495,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 
 		/* Receive Checksum Offload XXX recompute due to CRC strip? */
 		e1000_rx_checksum(adapter, staterr,
-				  le16_to_cpu(rx_desc->wb.lower.hi_dword.
-					      csum_ip.csum), skb);
+				  rx_desc->wb.lower.hi_dword.csum_ip.csum, skb);
 
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
-- 
1.7.7.4
