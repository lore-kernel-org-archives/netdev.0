From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 09/12] netxen: fix skb alloc size for legacy firmware
Date: Sun, 26 Jul 2009 23:07:44 -0700
Message-ID: <1248674867-18821-10-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33580 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751445AbZG0GHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:48 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Request 1532 bytes skb data size for NX3031. NX2031 firmware
needs 1760 sized buffers.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   11 +++--------
 drivers/net/netxen/netxen_nic_init.c |   13 +++++++++----
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index b58d0b2..e7702f6 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -143,18 +143,13 @@
 #define NX_ETHERMTU                    1500
 #define NX_MAX_ETHERHDR                32 /* This contains some padding */
 
-#define NX_RX_NORMAL_BUF_MAX_LEN       (NX_MAX_ETHERHDR + NX_ETHERMTU)
+#define NX_P2_RX_BUF_MAX_LEN           1760
+#define NX_P3_RX_BUF_MAX_LEN           (NX_MAX_ETHERHDR + NX_ETHERMTU)
 #define NX_P2_RX_JUMBO_BUF_MAX_LEN     (NX_MAX_ETHERHDR + P2_MAX_MTU)
 #define NX_P3_RX_JUMBO_BUF_MAX_LEN     (NX_MAX_ETHERHDR + P3_MAX_MTU)
 #define NX_CT_DEFAULT_RX_BUF_LEN	2048
 
-#define MAX_RX_BUFFER_LENGTH		1760
-#define MAX_RX_JUMBO_BUFFER_LENGTH 	8062
-#define MAX_RX_LRO_BUFFER_LENGTH	(8062)
-#define RX_DMA_MAP_LEN			(MAX_RX_BUFFER_LENGTH - 2)
-#define RX_JUMBO_DMA_MAP_LEN	\
-	(MAX_RX_JUMBO_BUFFER_LENGTH - 2)
-#define RX_LRO_DMA_MAP_LEN		(MAX_RX_LRO_BUFFER_LENGTH - 2)
+#define NX_RX_LRO_BUFFER_LENGTH		(8060)
 
 /*
  * Maximum number of ring contexts
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index ef7f1b1..a6b244a 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -247,9 +247,14 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 				rds_ring->skb_size =
 					NX_CT_DEFAULT_RX_BUF_LEN;
 			} else {
-				rds_ring->dma_size = RX_DMA_MAP_LEN;
+				if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+					rds_ring->dma_size =
+						NX_P3_RX_BUF_MAX_LEN;
+				else
+					rds_ring->dma_size =
+						NX_P2_RX_BUF_MAX_LEN;
 				rds_ring->skb_size =
-					MAX_RX_BUFFER_LENGTH;
+					rds_ring->dma_size + NET_IP_ALIGN;
 			}
 			break;
 
@@ -267,8 +272,8 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 
 		case RCV_RING_LRO:
 			rds_ring->num_desc = adapter->num_lro_rxd;
-			rds_ring->dma_size = RX_LRO_DMA_MAP_LEN;
-			rds_ring->skb_size = MAX_RX_LRO_BUFFER_LENGTH;
+			rds_ring->dma_size = NX_RX_LRO_BUFFER_LENGTH;
+			rds_ring->skb_size = rds_ring->dma_size + NET_IP_ALIGN;
 			break;
 
 		}
-- 
1.6.0.2

