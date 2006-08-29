From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 11/26] e1000: clean up skb allocation code, patch submitted by Christoph
Date: Tue, 29 Aug 2006 09:44:39 -0700
Message-ID: <20060829164439.6872.18771.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:39178 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965084AbWH2QgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:25 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 87a562f..656db12 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3741,7 +3741,6 @@ e1000_clean_rx_irq(struct e1000_adapter 
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
 				skb_reserve(new_skb, NET_IP_ALIGN);
-				new_skb->dev = netdev;
 				memcpy(new_skb->data - NET_IP_ALIGN,
 				       skb->data - NET_IP_ALIGN,
 				       length + NET_IP_ALIGN);
@@ -4008,13 +4007,13 @@ e1000_alloc_rx_buffers(struct e1000_adap
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while (cleaned_count--) {
-		if (!(skb = buffer_info->skb))
-			skb = netdev_alloc_skb(netdev, bufsz);
-		else {
+		skb = buffer_info->skb;
+		if (skb) {
 			skb_trim(skb, 0);
 			goto map_skb;
 		}
 
+		skb = netdev_alloc_skb(netdev, bufsz);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
 			adapter->alloc_rx_buff_failed++;
@@ -4039,10 +4038,10 @@ e1000_alloc_rx_buffers(struct e1000_adap
 				dev_kfree_skb(skb);
 				dev_kfree_skb(oldskb);
 				break; /* while !buffer_info->skb */
-			} else {
-				/* Use new allocation */
-				dev_kfree_skb(oldskb);
 			}
+
+			/* Use new allocation */
+			dev_kfree_skb(oldskb);
 		}
 		/* Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
@@ -4050,8 +4049,6 @@ e1000_alloc_rx_buffers(struct e1000_adap
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 
-		skb->dev = netdev;
-
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
 map_skb:
@@ -4165,8 +4162,6 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 
-		skb->dev = netdev;
-
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_ps_bsize0;
 		buffer_info->dma = pci_map_single(pdev, skb->data,



---
Auke Kok <auke-jan.h.kok@intel.com>
