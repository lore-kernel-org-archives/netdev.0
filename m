From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/5] igb: fix unmap length bug
Date: Tue, 30 Jun 2009 15:45:15 -0700
Message-ID: <20090630224515.17771.76848.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:39216
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753447AbZF3Wpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 18:45:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

driver was mixing NET_IP_ALIGN count bytes in map/unmap calls
unevenly. Only map the bytes that the hardware might dma into

also fix unmap related bug where ->dma was not being cleared
after unmap

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ea17319..468356d 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4549,11 +4549,12 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 		cleaned = true;
 		cleaned_count++;
 
+		/* this is the fast path for the non-packet split case */
 		if (!adapter->rx_ps_hdr_size) {
 			pci_unmap_single(pdev, buffer_info->dma,
-					 adapter->rx_buffer_len +
-					   NET_IP_ALIGN,
+					 adapter->rx_buffer_len,
 					 PCI_DMA_FROMDEVICE);
+			buffer_info->dma = 0;
 			skb_put(skb, length);
 			goto send_up;
 		}
@@ -4570,8 +4571,9 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 
 		if (!skb_shinfo(skb)->nr_frags) {
 			pci_unmap_single(pdev, buffer_info->dma,
-					 adapter->rx_ps_hdr_size + NET_IP_ALIGN,
+					 adapter->rx_ps_hdr_size,
 					 PCI_DMA_FROMDEVICE);
+			buffer_info->dma = 0;
 			skb_put(skb, hlen);
 		}
 
@@ -4713,7 +4715,6 @@ static void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring,
 		bufsz = adapter->rx_ps_hdr_size;
 	else
 		bufsz = adapter->rx_buffer_len;
-	bufsz += NET_IP_ALIGN;
 
 	while (cleaned_count--) {
 		rx_desc = E1000_RX_DESC_ADV(*rx_ring, i);
@@ -4737,7 +4738,7 @@ static void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring,
 		}
 
 		if (!buffer_info->skb) {
-			skb = netdev_alloc_skb(netdev, bufsz);
+			skb = netdev_alloc_skb(netdev, bufsz + NET_IP_ALIGN);
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
 				goto no_buffers;

