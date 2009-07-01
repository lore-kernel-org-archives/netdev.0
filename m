From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH net-2.6] be2net: fix spurious interrupt handling in intx
	mode
Date: Wed, 1 Jul 2009 16:36:07 +0530
Message-ID: <20090701110607.GA23588@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:42757 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753287AbZGALG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 07:06:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Occasionally we may see an interrupt without an event in the eq.
 In intx, we currently see the event queue and return IRQ_NONE causing
 a the irq to be disabled ("no one cared".) Instead, read the CEV_ISR
 reg to check the existence of the interrupt.


Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_hw.h   |    4 ++++
 drivers/net/benet/be_main.c |   16 +++++++++-------
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index b02e805..29c33c7 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -55,6 +55,10 @@
 #define MEMBAR_CTRL_INT_CTRL_PFUNC_MASK  	0x7 	/* bits 26 - 28 */
 #define MEMBAR_CTRL_INT_CTRL_PFUNC_SHIFT	26
 
+/********* ISR0 Register offset **********/
+#define CEV_ISR0_OFFSET 			0xC18
+#define CEV_ISR_SIZE				4
+
 /********* Event Q door bell *************/
 #define DB_EQ_OFFSET			DB_CQ_OFFSET
 #define DB_EQ_RING_ID_MASK		0x1FF	/* bits 0 - 8 */
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 308eb09..c43f6a1 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1274,15 +1274,17 @@ static irqreturn_t be_intx(int irq, void *dev)
 {
 	struct be_adapter *adapter = dev;
 	struct be_ctrl_info *ctrl = &adapter->ctrl;
-	int rx, tx;
+        int isr;
 
-	tx = event_handle(ctrl, &adapter->tx_eq);
-	rx = event_handle(ctrl, &adapter->rx_eq);
+	isr = ioread32(ctrl->csr + CEV_ISR0_OFFSET +
+                      ctrl->pci_func * CEV_ISR_SIZE);
+	if (!isr)
+                return IRQ_NONE;
 
-	if (rx || tx)
-		return IRQ_HANDLED;
-	else
-		return IRQ_NONE;
+        event_handle(ctrl, &adapter->tx_eq);
+        event_handle(ctrl, &adapter->rx_eq);
+
+        return IRQ_HANDLED;
 }
 
 static irqreturn_t be_msix_rx(int irq, void *dev)
-- 
1.6.0.4

