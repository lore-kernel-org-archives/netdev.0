From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 5/7] r8169: irq mask helpers.
Date: Fri, 27 Jan 2012 21:57:23 +0100
Message-ID: <20120127205723.GE24507@electric-eye.fr.zoreil.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57447 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385Ab2A0VIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 16:08:17 -0500
Content-Disposition: inline
In-Reply-To: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   37 +++++++++++++++++++++++++++------
 1 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 9f9abb5..610f4b3 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1184,6 +1184,29 @@ static u8 rtl8168d_efuse_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
+static u16 rtl_get_events(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R16(IntrStatus);
+}
+
+static void rtl_ack_events(struct rtl8169_private *tp, u16 bits)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W16(IntrStatus, bits);
+	mmiowb();
+}
+
+static void rtl_irq_disable(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W16(IntrMask, 0);
+	mmiowb();
+}
+
 static void rtl_irq_enable(struct rtl8169_private *tp, u16 bits)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1195,8 +1218,8 @@ static void rtl8169_irq_mask_and_ack(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	RTL_W16(IntrMask, 0x0000);
-	RTL_W16(IntrStatus, tp->intr_event);
+	rtl_irq_disable(tp);
+	rtl_ack_events(tp, tp->intr_event);
 	RTL_R8(ChipCmd);
 }
 
@@ -4057,11 +4080,11 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rtl_init_rxcfg(tp);
 
-	RTL_W16(IntrMask, 0x0000);
+	rtl_irq_disable(tp);
 
 	rtl_hw_reset(tp);
 
-	RTL_W16(IntrStatus, 0xffff);
+	rtl_ack_events(tp, 0xffff);
 
 	pci_set_master(pdev);
 
@@ -5775,12 +5798,12 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	int handled = 0;
-	int status;
+	u16 status;
 
 	/* loop handling interrupts until we have no new ones or
 	 * we hit a invalid/hotplug case.
 	 */
-	status = RTL_R16(IntrStatus);
+	status = rtl_get_events(tp);
 	while (status && status != 0xffff) {
 		status &= tp->intr_event;
 		if (!status)
@@ -5839,7 +5862,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		 */
 		RTL_W16(IntrStatus,
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
-		status = RTL_R16(IntrStatus);
+		status = rtl_get_events(tp);
 	}
 done:
 	return IRQ_RETVAL(handled);
-- 
1.7.6.5
