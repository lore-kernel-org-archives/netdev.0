From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 2/7] r8169: modify the flow of the hw reset
Date: Wed, 6 Jul 2011 15:58:03 +0800
Message-ID: <1309939088-31994-2-git-send-email-hayeswang@realtek.com>
References: <1309939088-31994-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1309939088-31994-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-Disable tx and rx by resetting hw, so replace rtl8169_asic_down with
 rtl8169_hw_reset.
-RxConfig bits 0 ~ 5 have to be clear before hw reset to avoid the
 coming of rx data.
-Certain chips need to do some checking before reset.
-Remove hw reset which is done before hw_start, because it would be
 done in close or down functions.
-Move rtl8169_init_ring_indexes function into rtl_hw_reset function.
 The indexes of tx and rx need to be zero only when the hw reset
 occures.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   53 ++++++++++++++++++++++++++------------------------
 1 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a8de449..a579da0 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1071,13 +1071,6 @@ static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
 	RTL_W16(IntrStatus, 0xffff);
 }
 
-static void rtl8169_asic_down(void __iomem *ioaddr)
-{
-	RTL_W8(ChipCmd, 0x00);
-	rtl8169_irq_mask_and_ack(ioaddr);
-	RTL_R16(CPlusCmd);
-}
-
 static unsigned int rtl8169_tbi_reset_pending(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -3337,6 +3330,11 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	}
 }
 
+static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
+{
+	tp->dirty_tx = tp->dirty_rx = tp->cur_tx = tp->cur_rx = 0;
+}
+
 static void rtl_hw_reset(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -3349,8 +3347,10 @@ static void rtl_hw_reset(struct rtl8169_private *tp)
 	for (i = 0; i < 100; i++) {
 		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
 			break;
-		msleep_interruptible(1);
+		udelay(100);
 	}
+
+	rtl8169_init_ring_indexes(tp);
 }
 
 static int __devinit
@@ -3732,6 +3732,16 @@ err_pm_runtime_put:
 	goto out;
 }
 
+static void rtl_rx_close(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 rxcfg = RTL_R32(RxConfig);
+
+	rxcfg &= ~(AcceptErr | AcceptRunt | AcceptBroadcast | AcceptMulticast |
+		   AcceptMyPhys | AcceptAllPhys);
+	RTL_W32(RxConfig, rxcfg);
+}
+
 static void rtl8169_hw_reset(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -3739,19 +3749,19 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	/* Disable interrupts */
 	rtl8169_irq_mask_and_ack(ioaddr);
 
+	rtl_rx_close(tp);
+
 	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
-
+	} else {
+		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
+		udelay(100);
 	}
 
-	/* Reset the chipset */
-	RTL_W8(ChipCmd, CmdReset);
-
-	/* PCI commit */
-	RTL_R8(ChipCmd);
+	rtl_hw_reset(tp);
 }
 
 static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
@@ -3771,8 +3781,6 @@ static void rtl_hw_start(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	rtl_hw_reset(tp);
-
 	tp->hw_start(dev);
 
 	netif_start_queue(dev);
@@ -4581,11 +4589,6 @@ err_out:
 	return -ENOMEM;
 }
 
-static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
-{
-	tp->dirty_tx = tp->dirty_rx = tp->cur_tx = tp->cur_rx = 0;
-}
-
 static int rtl8169_init_ring(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4713,7 +4716,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 
 	rtl8169_tx_clear(tp);
 
-	rtl8169_init_ring_indexes(tp);
+	rtl8169_hw_reset(tp);
 	rtl_hw_start(dev);
 	netif_wake_queue(dev);
 	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
@@ -5127,7 +5130,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		 * the chip, so just exit the loop.
 		 */
 		if (unlikely(!netif_running(dev))) {
-			rtl8169_asic_down(ioaddr);
+			rtl8169_hw_reset(tp);
 			break;
 		}
 
@@ -5250,7 +5253,7 @@ static void rtl8169_down(struct net_device *dev)
 
 	spin_lock_irq(&tp->lock);
 
-	rtl8169_asic_down(ioaddr);
+	rtl8169_hw_reset(tp);
 	/*
 	 * At this point device interrupts can not be enabled in any function,
 	 * as netif_running is not true (rtl8169_interrupt, rtl8169_reset_task,
@@ -5504,7 +5507,7 @@ static void rtl_shutdown(struct pci_dev *pdev)
 
 	spin_lock_irq(&tp->lock);
 
-	rtl8169_asic_down(ioaddr);
+	rtl8169_hw_reset(tp);
 
 	spin_unlock_irq(&tp->lock);
 
-- 
1.7.3.2
