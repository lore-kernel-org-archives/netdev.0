From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/8] tg3: Re-inline VLAN tags when appropriate
Date: Mon, 12 Apr 2010 09:58:28 -0700
Message-ID: <1271091511-11173-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1830 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753196Ab0DLQ66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 12:58:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tg3 driver is written so that VLAN tagged packets can be accepted,
even if CONFIG_VLAN_8021Q or CONFIG_VLAN_8021Q_MODULE is not defined.
(Think raw interfaces.)  If the device has ASF support enabled, the
firmware requires the driver to enable VLAN tag stripping.  If VLAN
tagging is not explicitly supported by the kernel and ASF is enabled,
the driver will have to reinject the VLAN tag back into the packet
stream.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   44 +++++++++++++++++++++++++++++++++-----------
 1 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5791405..3263f50 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -126,6 +126,9 @@
 				 TG3_TX_RING_SIZE)
 #define NEXT_TX(N)		(((N) + 1) & (TG3_TX_RING_SIZE - 1))
 
+#define TG3_RX_DMA_ALIGN		16
+#define TG3_RX_HEADROOM			ALIGN(VLAN_HLEN, TG3_RX_DMA_ALIGN)
+
 #define TG3_DMA_BYTE_ENAB		64
 
 #define TG3_RX_STD_DMA_SZ		1536
@@ -4624,6 +4627,8 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		struct sk_buff *skb;
 		dma_addr_t dma_addr;
 		u32 opaque_key, desc_idx, *post_ptr;
+		bool hw_vlan __maybe_unused = false;
+		u16 vtag __maybe_unused = 0;
 
 		desc_idx = desc->opaque & RXD_OPAQUE_INDEX_MASK;
 		opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
@@ -4682,12 +4687,12 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			tg3_recycle_rx(tnapi, tpr, opaque_key,
 				       desc_idx, *post_ptr);
 
-			copy_skb = netdev_alloc_skb(tp->dev,
-						    len + TG3_RAW_IP_ALIGN);
+			copy_skb = netdev_alloc_skb(tp->dev, len + VLAN_HLEN +
+						    TG3_RAW_IP_ALIGN);
 			if (copy_skb == NULL)
 				goto drop_it_no_recycle;
 
-			skb_reserve(copy_skb, TG3_RAW_IP_ALIGN);
+			skb_reserve(copy_skb, TG3_RAW_IP_ALIGN + VLAN_HLEN);
 			skb_put(copy_skb, len);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
 			skb_copy_from_linear_data(skb, copy_skb->data, len);
@@ -4713,12 +4718,29 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			goto next_pkt;
 		}
 
+		if (desc->type_flags & RXD_FLAG_VLAN &&
+		    !(tp->rx_mode & RX_MODE_KEEP_VLAN_TAG)) {
+			vtag = desc->err_vlan & RXD_VLAN_MASK;
 #if TG3_VLAN_TAG_USED
-		if (tp->vlgrp != NULL &&
-		    desc->type_flags & RXD_FLAG_VLAN) {
-			vlan_gro_receive(&tnapi->napi, tp->vlgrp,
-					 desc->err_vlan & RXD_VLAN_MASK, skb);
-		} else
+			if (tp->vlgrp)
+				hw_vlan = true;
+			else
+#endif
+			{
+				struct vlan_ethhdr *ve = (struct vlan_ethhdr *)
+						    __skb_push(skb, VLAN_HLEN);
+
+				memmove(ve, skb->data + VLAN_HLEN,
+					ETH_ALEN * 2);
+				ve->h_vlan_proto = htons(ETH_P_8021Q);
+				ve->h_vlan_TCI = htons(vtag);
+			}
+		}
+
+#if TG3_VLAN_TAG_USED
+		if (hw_vlan)
+			vlan_gro_receive(&tnapi->napi, tp->vlgrp, vtag, skb);
+		else
 #endif
 			napi_gro_receive(&tnapi->napi, skb);
 
@@ -13481,13 +13503,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	else
 		tp->tg3_flags &= ~TG3_FLAG_POLL_SERDES;
 
-	tp->rx_offset = NET_IP_ALIGN;
+	tp->rx_offset = NET_IP_ALIGN + TG3_RX_HEADROOM;
 	tp->rx_copy_thresh = TG3_RX_COPY_THRESHOLD;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
 	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE) != 0) {
-		tp->rx_offset = 0;
+		tp->rx_offset -= NET_IP_ALIGN;
 #ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
-		tp->rx_copy_thresh = ~0;
+		tp->rx_copy_thresh = ~(u16)0;
 #endif
 	}
 
-- 
1.6.4.4


