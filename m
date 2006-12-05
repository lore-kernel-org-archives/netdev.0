From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: receive queue watermark tweak
Date: Mon, 4 Dec 2006 17:08:19 -0800
Message-ID: <20061204170819.6d7c85e6@localhost>
References: <20061204155345.0c276a90@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:51684 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967949AbWLEBJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 20:09:02 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061204155345.0c276a90@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the receive performance on some systems go from
714MB/s to 941MB/s. It adjusts the watermark of the receive queue
to be lower, thereby avoiding excess hardware flow control. This is
most important on the systems which have little/no additional buffering.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


---
 drivers/net/sky2.c |   11 ++++++++---
 drivers/net/sky2.h |    1 +
 2 files changed, 9 insertions(+), 3 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-12-04 16:53:22.000000000 -0800
+++ sky2/drivers/net/sky2.c	2006-12-04 17:03:51.000000000 -0800
@@ -1062,11 +1062,16 @@
 	sky2->rx_put = sky2->rx_next = 0;
 	sky2_qset(hw, rxq);
 
+	/* On PCI express lowering the watermark gives better performance */
+	if (pci_find_capability(hw->pdev, PCI_CAP_ID_EXP))
+		sky2_write32(hw, Q_ADDR(rxq, Q_WM), BMU_WM_PEX);
+
+	/* These chips have no ram buffer?
+	 * MAC Rx RAM Read is controlled by hardware */
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
-	    (hw->chip_rev == CHIP_REV_YU_EC_U_A1 || hw->chip_rev == CHIP_REV_YU_EC_U_B0)) {
-		/* MAC Rx RAM Read is controlled by hardware */
+	    (hw->chip_rev == CHIP_REV_YU_EC_U_A1
+	     || hw->chip_rev == CHIP_REV_YU_EC_U_B0))
 		sky2_write32(hw, Q_ADDR(rxq, Q_F), F_M_RX_RAM_DIS);
-	}
 
 	sky2_prefetch_init(hw, rxq, sky2->rx_le_map, RX_LE_SIZE - 1);
 
--- sky2.orig/drivers/net/sky2.h	2006-12-04 16:56:24.000000000 -0800
+++ sky2/drivers/net/sky2.h	2006-12-04 17:01:05.000000000 -0800
@@ -680,6 +680,7 @@
 			  BMU_FIFO_ENA | BMU_OP_ON,
 
 	BMU_WM_DEFAULT = 0x600,
+	BMU_WM_PEX     = 0x80,
 };
 
 /* Tx BMU Control / Status Registers (Yukon-2) */
