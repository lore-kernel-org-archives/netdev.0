From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/4] bnx2: Reinsert VLAN tag when necessary.
Date: Thu, 14 Aug 2008 15:22:58 -0700
Message-ID: <1218752579-20506-4-git-send-email-mchan@broadcom.com>
References: <1218752579-20506-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2527 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126AbYHNWTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 18:19:18 -0400
In-Reply-To: <1218752579-20506-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In certain cases when ASF or other management firmware is running, the
chip may be configured to always strip out the VLAN tag even when
VLAN acceleration is not enabled.  This causes some VLAN tagged
packets to be received by the host stack without any knowledge that
the original packet was VLAN tagged.

We fix this by re-inserting the VLAN tag into the packet when necessary.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/bnx2.c |   35 +++++++++++++++++++++++++++--------
 1 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a2a010e..1f2e76f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2876,6 +2876,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		struct sw_bd *rx_buf;
 		struct sk_buff *skb;
 		dma_addr_t dma_addr;
+		u16 vtag = 0;
+		int hw_vlan __maybe_unused = 0;
 
 		sw_ring_cons = RX_RING_IDX(sw_cons);
 		sw_ring_prod = RX_RING_IDX(sw_prod);
@@ -2919,7 +2921,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		if (len <= bp->rx_copy_thresh) {
 			struct sk_buff *new_skb;
 
-			new_skb = netdev_alloc_skb(bp->dev, len + 2);
+			new_skb = netdev_alloc_skb(bp->dev, len + 6);
 			if (new_skb == NULL) {
 				bnx2_reuse_rx_skb(bp, rxr, skb, sw_ring_cons,
 						  sw_ring_prod);
@@ -2928,9 +2930,9 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 			/* aligned copy */
 			skb_copy_from_linear_data_offset(skb,
-							 BNX2_RX_OFFSET - 2,
-				      new_skb->data, len + 2);
-			skb_reserve(new_skb, 2);
+							 BNX2_RX_OFFSET - 6,
+				      new_skb->data, len + 6);
+			skb_reserve(new_skb, 6);
 			skb_put(new_skb, len);
 
 			bnx2_reuse_rx_skb(bp, rxr, skb,
@@ -2941,6 +2943,25 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			   dma_addr, (sw_ring_cons << 16) | sw_ring_prod)))
 			goto next_rx;
 
+		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) &&
+		    !(bp->rx_mode & BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG)) {
+			vtag = rx_hdr->l2_fhdr_vlan_tag;
+#ifdef BCM_VLAN
+			if (bp->vlgrp)
+				hw_vlan = 1;
+			else
+#endif
+			{
+				struct vlan_ethhdr *ve = (struct vlan_ethhdr *)
+					__skb_push(skb, 4);
+
+				memmove(ve, skb->data + 4, ETH_ALEN * 2);
+				ve->h_vlan_proto = htons(ETH_P_8021Q);
+				ve->h_vlan_TCI = htons(vtag);
+				len += 4;
+			}
+		}
+
 		skb->protocol = eth_type_trans(skb, bp->dev);
 
 		if ((len > (bp->dev->mtu + ETH_HLEN)) &&
@@ -2962,10 +2983,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		}
 
 #ifdef BCM_VLAN
-		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) && bp->vlgrp) {
-			vlan_hwaccel_receive_skb(skb, bp->vlgrp,
-				rx_hdr->l2_fhdr_vlan_tag);
-		}
+		if (hw_vlan)
+			vlan_hwaccel_receive_skb(skb, bp->vlgrp, vtag);
 		else
 #endif
 			netif_receive_skb(skb);
-- 
1.5.6.GIT


