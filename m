From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 02/26] igb: move setting of buffsz out of repeated
	path in alloc_rx_buffers
Date: Sat, 07 Feb 2009 01:15:25 -0800
Message-ID: <20090207091525.15697.62535.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:54485 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752099AbZBGJPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:15:44 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

buffsz is being repeatedly set when allocaing buffers.  Since this value
should only need to be set once in the function I am moving it out of the
looped portion of the path.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 21f0c22..ec5855a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3943,10 +3943,17 @@ static void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring,
 	struct igb_buffer *buffer_info;
 	struct sk_buff *skb;
 	unsigned int i;
+	int bufsz;
 
 	i = rx_ring->next_to_use;
 	buffer_info = &rx_ring->buffer_info[i];
 
+	if (adapter->rx_ps_hdr_size)
+		bufsz = adapter->rx_ps_hdr_size;
+	else
+		bufsz = adapter->rx_buffer_len;
+	bufsz += NET_IP_ALIGN;
+
 	while (cleaned_count--) {
 		rx_desc = E1000_RX_DESC_ADV(*rx_ring, i);
 
@@ -3962,23 +3969,14 @@ static void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring,
 				buffer_info->page_offset ^= PAGE_SIZE / 2;
 			}
 			buffer_info->page_dma =
-				pci_map_page(pdev,
-					     buffer_info->page,
+				pci_map_page(pdev, buffer_info->page,
 					     buffer_info->page_offset,
 					     PAGE_SIZE / 2,
 					     PCI_DMA_FROMDEVICE);
 		}
 
 		if (!buffer_info->skb) {
-			int bufsz;
-
-			if (adapter->rx_ps_hdr_size)
-				bufsz = adapter->rx_ps_hdr_size;
-			else
-				bufsz = adapter->rx_buffer_len;
-			bufsz += NET_IP_ALIGN;
 			skb = netdev_alloc_skb(netdev, bufsz);
-
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
 				goto no_buffers;
@@ -3994,7 +3992,6 @@ static void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring,
 			buffer_info->dma = pci_map_single(pdev, skb->data,
 							  bufsz,
 							  PCI_DMA_FROMDEVICE);
-
 		}
 		/* Refresh the desc even if buffer_addrs didn't change because
 		 * each write-back erases this info. */

