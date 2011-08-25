From: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/9] IB: nes: convert to SKB paged frag API.
Date: Thu, 25 Aug 2011 09:28:09 +0100
Message-ID: <1314260895-15936-3-git-send-email-ian.campbell@citrix.com>
References: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1314260881.10283.48.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/infiniband/hw/nes/nes_nic.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 66e1229..96cb35a 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -441,11 +441,11 @@ static int nes_nic_send(struct sk_buff *skb, struct net_device *netdev)
 		nesnic->tx_skb[nesnic->sq_head] = skb;
 		for (skb_fragment_index = 0; skb_fragment_index < skb_shinfo(skb)->nr_frags;
 				skb_fragment_index++) {
-			bus_address = pci_map_page( nesdev->pcidev,
-					skb_shinfo(skb)->frags[skb_fragment_index].page,
-					skb_shinfo(skb)->frags[skb_fragment_index].page_offset,
-					skb_shinfo(skb)->frags[skb_fragment_index].size,
-					PCI_DMA_TODEVICE);
+			skb_frag_t *frag =
+				&skb_shinfo(skb)->frags[skb_fragment_index];
+			bus_address = skb_frag_dma_map(&nesdev->pcidev->dev,
+						       frag, 0, frag->size,
+						       PCI_DMA_TODEVICE);
 			wqe_fragment_length[wqe_fragment_index] =
 					cpu_to_le16(skb_shinfo(skb)->frags[skb_fragment_index].size);
 			set_wqe_64bit_value(nic_sqe->wqe_words, NES_NIC_SQ_WQE_FRAG0_LOW_IDX+(2*wqe_fragment_index),
@@ -561,11 +561,12 @@ tso_sq_no_longer_full:
 			/* Map all the buffers */
 			for (tso_frag_count=0; tso_frag_count < skb_shinfo(skb)->nr_frags;
 					tso_frag_count++) {
-				tso_bus_address[tso_frag_count] = pci_map_page( nesdev->pcidev,
-						skb_shinfo(skb)->frags[tso_frag_count].page,
-						skb_shinfo(skb)->frags[tso_frag_count].page_offset,
-						skb_shinfo(skb)->frags[tso_frag_count].size,
-						PCI_DMA_TODEVICE);
+				skb_frag_t *frag =
+					&skb_shinfo(skb)->frags[tso_frag_count];
+				tso_bus_address[tso_frag_count] =
+					skb_frag_dma_map(&nesdev->pcidev->dev,
+							 frag, 0, frag->size,
+							 PCI_DMA_TODEVICE);
 			}
 
 			tso_frag_index = 0;
-- 
1.7.2.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
