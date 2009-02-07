From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 01/26] igb: optomize/refactor receive path
Date: Sat, 07 Feb 2009 01:15:04 -0800
Message-ID: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:33183 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbZBGJPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:15:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

While cleaning up the skb_over panic with small frames I found there was
room for improvement in the ordering of operations within the rx receive
flow.  These changes will place the prefetch for the next descriptor to a
point earlier in the rx path.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   44 ++++++++++++++++++++++----------------------
 1 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8b80fe3..21f0c22 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3803,6 +3803,7 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 	unsigned int total_bytes = 0, total_packets = 0;
 
 	i = rx_ring->next_to_clean;
+	buffer_info = &rx_ring->buffer_info[i];
 	rx_desc = E1000_RX_DESC_ADV(*rx_ring, i);
 	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 
@@ -3810,25 +3811,22 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 		if (*work_done >= budget)
 			break;
 		(*work_done)++;
-		buffer_info = &rx_ring->buffer_info[i];
 
-		/* HW will not DMA in data larger than the given buffer, even
-		 * if it parses the (NFS, of course) header to be larger.  In
-		 * that case, it fills the header buffer and spills the rest
-		 * into the page.
-		 */
-		hlen = (le16_to_cpu(rx_desc->wb.lower.lo_dword.hdr_info) &
-		  E1000_RXDADV_HDRBUFLEN_MASK) >> E1000_RXDADV_HDRBUFLEN_SHIFT;
-		if (hlen > adapter->rx_ps_hdr_size)
-			hlen = adapter->rx_ps_hdr_size;
+		skb = buffer_info->skb;
+		prefetch(skb->data - NET_IP_ALIGN);
+		buffer_info->skb = NULL;
+
+		i++;
+		if (i == rx_ring->count)
+			i = 0;
+		next_rxd = E1000_RX_DESC_ADV(*rx_ring, i);
+		prefetch(next_rxd);
+		next_buffer = &rx_ring->buffer_info[i];
 
 		length = le16_to_cpu(rx_desc->wb.upper.length);
 		cleaned = true;
 		cleaned_count++;
 
-		skb = buffer_info->skb;
-		prefetch(skb->data - NET_IP_ALIGN);
-		buffer_info->skb = NULL;
 		if (!adapter->rx_ps_hdr_size) {
 			pci_unmap_single(pdev, buffer_info->dma,
 					 adapter->rx_buffer_len +
@@ -3838,6 +3836,16 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 			goto send_up;
 		}
 
+		/* HW will not DMA in data larger than the given buffer, even
+		 * if it parses the (NFS, of course) header to be larger.  In
+		 * that case, it fills the header buffer and spills the rest
+		 * into the page.
+		 */
+		hlen = (le16_to_cpu(rx_desc->wb.lower.lo_dword.hdr_info) &
+		  E1000_RXDADV_HDRBUFLEN_MASK) >> E1000_RXDADV_HDRBUFLEN_SHIFT;
+		if (hlen > adapter->rx_ps_hdr_size)
+			hlen = adapter->rx_ps_hdr_size;
+
 		if (!skb_shinfo(skb)->nr_frags) {
 			pci_unmap_single(pdev, buffer_info->dma,
 					 adapter->rx_ps_hdr_size +
@@ -3867,13 +3875,6 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 
 			skb->truesize += length;
 		}
-send_up:
-		i++;
-		if (i == rx_ring->count)
-			i = 0;
-		next_rxd = E1000_RX_DESC_ADV(*rx_ring, i);
-		prefetch(next_rxd);
-		next_buffer = &rx_ring->buffer_info[i];
 
 		if (!(staterr & E1000_RXD_STAT_EOP)) {
 			buffer_info->skb = next_buffer->skb;
@@ -3882,7 +3883,7 @@ send_up:
 			next_buffer->dma = 0;
 			goto next_desc;
 		}
-
+send_up:
 		if (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) {
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
@@ -3909,7 +3910,6 @@ next_desc:
 		/* use prefetched values */
 		rx_desc = next_rxd;
 		buffer_info = next_buffer;
-
 		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
 

