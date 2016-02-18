From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e/i40evf: avoid atomics
Date: Thu, 18 Feb 2016 01:04:05 -0800
Message-ID: <1455786252-71881-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36842 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425721AbcBRJEb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:04:31 -0500
In-Reply-To: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

In the case where we have a page fully used by receive data, we need to
release the page fully to the stack. Instead of calling get_page (which
increments the page count) followed by free_page (which decrements the
page count), just donate our reference to the stack. Although this
donation is not tax deductible, it does allow us to avoid two very
expensive atomic operations that reverse each other.

Change-ID: If70739792d5748995fc175ec92ac2171ed4ad8fc
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 21 +++++++++++++--------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 21 +++++++++++++--------
 2 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5b43585..25e378c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1663,28 +1663,33 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, const int budget)
 					rx_bi->page_offset + copysize,
 					rx_packet_len, I40E_RXBUFFER_2048);
 
-			get_page(rx_bi->page);
-			/* switch to the other half-page here; the allocation
-			 * code programs the right addr into HW. If we haven't
-			 * used this half-page, the address won't be changed,
-			 * and HW can just use it next time through.
-			 */
-			rx_bi->page_offset ^= PAGE_SIZE / 2;
 			/* If the page count is more than 2, then both halves
 			 * of the page are used and we need to free it. Do it
 			 * here instead of in the alloc code. Otherwise one
 			 * of the half-pages might be released between now and
 			 * then, and we wouldn't know which one to use.
+			 * Don't call get_page and free_page since those are
+			 * both expensive atomic operations that just change
+			 * the refcount in opposite directions. Just give the
+			 * page to the stack; he can have our refcount.
 			 */
 			if (page_count(rx_bi->page) > 2) {
 				dma_unmap_page(rx_ring->dev,
 					       rx_bi->page_dma,
 					       PAGE_SIZE,
 					       DMA_FROM_DEVICE);
-				__free_page(rx_bi->page);
 				rx_bi->page = NULL;
 				rx_bi->page_dma = 0;
 				rx_ring->rx_stats.realloc_count++;
+			} else {
+				get_page(rx_bi->page);
+				/* switch to the other half-page here; the
+				 * allocation code programs the right addr
+				 * into HW. If we haven't used this half-page,
+				 * the address won't be changed, and HW can
+				 * just use it next time through.
+				 */
+				rx_bi->page_offset ^= PAGE_SIZE / 2;
 			}
 
 		}
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 0f73a4f..fb6cd7e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1126,28 +1126,33 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, const int budget)
 					rx_bi->page_offset + copysize,
 					rx_packet_len, I40E_RXBUFFER_2048);
 
-			get_page(rx_bi->page);
-			/* switch to the other half-page here; the allocation
-			 * code programs the right addr into HW. If we haven't
-			 * used this half-page, the address won't be changed,
-			 * and HW can just use it next time through.
-			 */
-			rx_bi->page_offset ^= PAGE_SIZE / 2;
 			/* If the page count is more than 2, then both halves
 			 * of the page are used and we need to free it. Do it
 			 * here instead of in the alloc code. Otherwise one
 			 * of the half-pages might be released between now and
 			 * then, and we wouldn't know which one to use.
+			 * Don't call get_page and free_page since those are
+			 * both expensive atomic operations that just change
+			 * the refcount in opposite directions. Just give the
+			 * page to the stack; he can have our refcount.
 			 */
 			if (page_count(rx_bi->page) > 2) {
 				dma_unmap_page(rx_ring->dev,
 					       rx_bi->page_dma,
 					       PAGE_SIZE,
 					       DMA_FROM_DEVICE);
-				__free_page(rx_bi->page);
 				rx_bi->page = NULL;
 				rx_bi->page_dma = 0;
 				rx_ring->rx_stats.realloc_count++;
+			} else {
+				get_page(rx_bi->page);
+				/* switch to the other half-page here; the
+				 * allocation code programs the right addr
+				 * into HW. If we haven't used this half-page,
+				 * the address won't be changed, and HW can
+				 * just use it next time through.
+				 */
+				rx_bi->page_offset ^= PAGE_SIZE / 2;
 			}
 
 		}
-- 
2.5.0
