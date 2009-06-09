From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] ixgbe: Include offloaded FCoE data into total rx/tx
	statistics for 82599
Date: Mon, 08 Jun 2009 17:38:44 -0700
Message-ID: <20090609003844.5208.72539.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:39821
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751432AbZFIAjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 20:39:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Include offloaded FCoE data into total rx/tx statistics for 82599 so they
are properly reflected by ethtool or ifconfig.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |    6 +++++-
 drivers/net/ixgbe/ixgbe_fcoe.h |    1 +
 drivers/net/ixgbe/ixgbe_main.c |   40 ++++++++++++++++++++++++++++++++++++----
 3 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index d5939de..3c3bf1f 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -280,7 +280,9 @@ out_noddp_unmap:
  *
  * This checks ddp status.
  *
- * Returns : 0 for success and skb will not be delivered to ULD
+ * Returns : < 0 indicates an error or not a FCiE ddp, 0 indicates
+ * not passing the skb to ULD, > 0 indicates is the length of data
+ * being ddped.
  */
 int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 		   union ixgbe_adv_rx_desc *rx_desc,
@@ -334,6 +336,8 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 		/* return 0 to bypass going to ULD for DDPed data */
 		if (fcstat == IXGBE_RXDADV_STAT_FCSTAT_DDP)
 			rc = 0;
+		else
+			rc = ddp->len;
 	}
 
 ddp_out:
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
index b7f9b63..c5b5002 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -28,6 +28,7 @@
 #ifndef _IXGBE_FCOE_H
 #define _IXGBE_FCOE_H
 
+#include <scsi/fc/fc_fs.h>
 #include <scsi/fc/fc_fcoe.h>
 
 /* shift bits within STAT fo FCSTAT */
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 09994e9..a551a96 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -293,12 +293,24 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 
 			if (cleaned && skb) {
 				unsigned int segs, bytecount;
+				unsigned int hlen = skb_headlen(skb);
 
 				/* gso_segs is currently only valid for tcp */
 				segs = skb_shinfo(skb)->gso_segs ?: 1;
+#ifdef IXGBE_FCOE
+				/* adjust for FCoE Sequence Offload */
+				if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
+				    && (skb->protocol == htons(ETH_P_FCOE)) &&
+				    skb_is_gso(skb)) {
+					hlen = skb_transport_offset(skb) +
+						sizeof(struct fc_frame_header) +
+						sizeof(struct fcoe_crc_eof);
+					segs = DIV_ROUND_UP(skb->len - hlen,
+						skb_shinfo(skb)->gso_size);
+				}
+#endif /* IXGBE_FCOE */
 				/* multiply data chunks by size of headers */
-				bytecount = ((segs - 1) * skb_headlen(skb)) +
-				            skb->len;
+				bytecount = ((segs - 1) * hlen) + skb->len;
 				total_packets += segs;
 				total_bytes += bytecount;
 			}
@@ -683,6 +695,9 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	bool cleaned = false;
 	int cleaned_count = 0;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
+#ifdef IXGBE_FCOE
+	int ddp_bytes = 0;
+#endif /* IXGBE_FCOE */
 
 	i = rx_ring->next_to_clean;
 	rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
@@ -793,9 +808,11 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		skb->protocol = eth_type_trans(skb, adapter->netdev);
 #ifdef IXGBE_FCOE
 		/* if ddp, not passing to ULD unless for FCP_RSP or error */
-		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
-			if (!ixgbe_fcoe_ddp(adapter, rx_desc, skb))
+		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+			ddp_bytes = ixgbe_fcoe_ddp(adapter, rx_desc, skb);
+			if (!ddp_bytes)
 				goto next_desc;
+		}
 #endif /* IXGBE_FCOE */
 		ixgbe_receive_skb(q_vector, skb, staterr, rx_ring, rx_desc);
 
@@ -821,6 +838,21 @@ next_desc:
 	if (cleaned_count)
 		ixgbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
 
+#ifdef IXGBE_FCOE
+	/* include DDPed FCoE data */
+	if (ddp_bytes > 0) {
+		unsigned int mss;
+
+		mss = adapter->netdev->mtu - sizeof(struct fcoe_hdr) -
+			sizeof(struct fc_frame_header) -
+			sizeof(struct fcoe_crc_eof);
+		if (mss > 512)
+			mss &= ~511;
+		total_rx_bytes += ddp_bytes;
+		total_rx_packets += DIV_ROUND_UP(ddp_bytes, mss);
+	}
+#endif /* IXGBE_FCOE */
+
 	rx_ring->total_packets += total_rx_packets;
 	rx_ring->total_bytes += total_rx_bytes;
 	adapter->net_stats.rx_bytes += total_rx_bytes;

