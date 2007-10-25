From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/4] e1000e: Re-enable SECRC - crc stripping
Date: Thu, 25 Oct 2007 13:57:58 -0700
Message-ID: <20071025205758.32645.66791.stgit@localhost.localdomain>
References: <20071025205744.32645.59503.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7200 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754501AbXJYU6f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 16:58:35 -0400
In-Reply-To: <20071025205744.32645.59503.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This workaround code performed software stripping instead of the
hardware which can do it much faster. None of the e1000e target
hardware has issues with this feature and should work fine. This
gives us some performance back on receive, and removes some
kludging stripping the 4 bytes.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |   19 ++++++-------------
 1 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index e87ed31..03fcc70 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -494,10 +494,6 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			goto next_desc;
 		}
 
-		/* adjust length to remove Ethernet CRC */
-		length -= 4;
-
-		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += length;
 		total_rx_packets++;
 
@@ -964,8 +960,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
 			pci_dma_sync_single_for_device(pdev, ps_page->dma,
 				PAGE_SIZE, PCI_DMA_FROMDEVICE);
-			/* remove the CRC */
-			l1 -= 4;
+
 			skb_put(skb, l1);
 			goto copydone;
 		} /* if */
@@ -987,10 +982,6 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			skb->truesize += length;
 		}
 
-		/* strip the ethernet crc, problem is we're using pages now so
-		 * this whole operation can get a little cpu intensive */
-		pskb_trim(skb, skb->len - 4);
-
 copydone:
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
@@ -2034,9 +2025,11 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 
 		ew32(RFCTL, rfctl);
 
-		/* disable the stripping of CRC because it breaks
-		 * BMC firmware connected over SMBUS */
-		rctl |= E1000_RCTL_DTYP_PS /* | E1000_RCTL_SECRC */;
+		/* Enable Packet split descriptors */
+		rctl |= E1000_RCTL_DTYP_PS;
+		
+		/* Enable hardware CRC frame stripping */
+		rctl |= E1000_RCTL_SECRC;
 
 		psrctl |= adapter->rx_ps_bsize0 >>
 			E1000_PSRCTL_BSIZE0_SHIFT;
