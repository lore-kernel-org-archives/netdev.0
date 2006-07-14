From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/4] e1000: remove CRC bytes from measured packet length
Date: Fri, 14 Jul 2006 16:29:45 -0700
Message-ID: <20060714232945.22378.53835.stgit@gitlost.site>
References: <20060714232452.22378.32866.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:9993 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1945909AbWGNXXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 19:23:02 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060714232452.22378.32866.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


After removing the hardware CRC stripping which causes problems with
SOL and related issues, we need to compensate for this changed size.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 1c6bcad..0074a3a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3673,6 +3673,9 @@ e1000_clean_rx_irq(struct e1000_adapter 
 
 		length = le16_to_cpu(rx_desc->length);
 
+		/* adjust length to remove Ethernet CRC */
+		length -= 4;
+
 		if (unlikely(!(status & E1000_RXD_STAT_EOP))) {
 			/* All receives must fit into a single buffer */
 			E1000_DBG("%s: Receive packet consumed multiple"
@@ -3877,8 +3880,9 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 			pci_dma_sync_single_for_device(pdev,
 				ps_page_dma->ps_page_dma[0],
 				PAGE_SIZE, PCI_DMA_FROMDEVICE);
+			/* remove the CRC */
+			l1 -= 4;
 			skb_put(skb, l1);
-			length += l1;
 			goto copydone;
 		} /* if */
 		}
@@ -3897,6 +3901,10 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 			skb->truesize += length;
 		}
 
+		/* strip the ethernet crc, problem is we're using pages now so
+		 * this whole operation can get a little cpu intensive */
+		pskb_trim(skb, skb->len - 4);
+
 copydone:
 		e1000_rx_checksum(adapter, staterr,
 				  le16_to_cpu(rx_desc->wb.lower.hi_dword.csum_ip.csum), skb);



--
Auke Kok <auke-jan.h.kok@intel.com>
