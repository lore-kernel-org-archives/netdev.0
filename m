From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 10/13] igb: use buffer_info->dma instead of
	shinfo->nr_frags to determine unmap
Date: Thu, 23 Jul 2009 21:10:06 -0700
Message-ID: <20090724041005.30709.61385.stgit@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:33141
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751790AbZGXEKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:10:22 -0400
In-Reply-To: <20090724040700.30709.31473.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we use buffer_info->dma instead of
shinfo->nr_frags to determine if we need to unmap a received skb.  By doing
this we can avoid a cache miss on small packets since the buffer_info
structure should already be prefetched.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   30 ++++++++++++++++++------------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 2ffb51d..12d8683 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4538,6 +4538,20 @@ static inline void igb_rx_checksum_adv(struct igb_adapter *adapter,
 	adapter->hw_csum_good++;
 }
 
+static inline u16 igb_get_hlen(struct igb_adapter *adapter,
+                               union e1000_adv_rx_desc *rx_desc)
+{
+	/* HW will not DMA in data larger than the given buffer, even if it
+	 * parses the (NFS, of course) header to be larger.  In that case, it
+	 * fills the header buffer and spills the rest into the page.
+	 */
+	u16 hlen = (le16_to_cpu(rx_desc->wb.lower.lo_dword.hdr_info) &
+	           E1000_RXDADV_HDRBUFLEN_MASK) >> E1000_RXDADV_HDRBUFLEN_SHIFT;
+	if (hlen > adapter->rx_ps_hdr_size)
+		hlen = adapter->rx_ps_hdr_size;
+	return hlen;
+}
+
 static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 				 int *work_done, int budget)
 {
@@ -4552,7 +4566,8 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 	int cleaned_count = 0;
 	unsigned int total_bytes = 0, total_packets = 0;
 	unsigned int i;
-	u32 length, hlen, staterr;
+	u32 staterr;
+	u16 length;
 
 	i = rx_ring->next_to_clean;
 	buffer_info = &rx_ring->buffer_info[i];
@@ -4589,17 +4604,8 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 			goto send_up;
 		}
 
-		/* HW will not DMA in data larger than the given buffer, even
-		 * if it parses the (NFS, of course) header to be larger.  In
-		 * that case, it fills the header buffer and spills the rest
-		 * into the page.
-		 */
-		hlen = (le16_to_cpu(rx_desc->wb.lower.lo_dword.hdr_info) &
-		  E1000_RXDADV_HDRBUFLEN_MASK) >> E1000_RXDADV_HDRBUFLEN_SHIFT;
-		if (hlen > adapter->rx_ps_hdr_size)
-			hlen = adapter->rx_ps_hdr_size;
-
-		if (!skb_shinfo(skb)->nr_frags) {
+		if (buffer_info->dma) {
+			u16 hlen = igb_get_hlen(adapter, rx_desc);
 			pci_unmap_single(pdev, buffer_info->dma,
 					 adapter->rx_ps_hdr_size,
 					 PCI_DMA_FROMDEVICE);

