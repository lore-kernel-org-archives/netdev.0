From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc3 4/5] r8169: screaming irq when the device is closed
Date: Sat, 12 Feb 2005 00:44:03 +0100
Message-ID: <20050211234403.GC13644@electric-eye.fr.zoreil.com>
References: <20050211233918.GB8792@electric-eye.fr.zoreil.com> <20050211234106.GA13644@electric-eye.fr.zoreil.com> <20050211234236.GB13644@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, jdmason@us.ibm.com, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050211234236.GB13644@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Close the race for a screaming irq when the device is closed.

- rtl8169_interrupt() try to properly IRQ_HANDLE an interrupt even when
  the network device is going down. As a benefit, rtl8169_poll() does not
  need to care about the close race any more;
- factor code with rtl8169_irq_mask_and_ack();
- rtl8169_init_board(): mitigate some really unexpected events.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-380 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-380	2005-02-05 21:04:32.000000000 +0100
+++ b/drivers/net/r8169.c	2005-02-12 00:25:00.002833963 +0100
@@ -490,6 +490,13 @@ static int mdio_read(void __iomem *ioadd
 	return value;
 }
 
+static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
+{
+	RTL_W16(IntrMask, 0x0000);
+
+	RTL_W16(IntrStatus, 0xffff);
+}
+
 static unsigned int rtl8169_tbi_reset_pending(void __iomem *ioaddr)
 {
 	return RTL_R32(TBICSR) & TBIReset;
@@ -1234,6 +1241,9 @@ rtl8169_init_board(struct pci_dev *pdev,
 		goto err_out_free_res;
 	}
 
+	// Unneeded ? Don't mess with Mrs. Murphy.
+	rtl8169_irq_mask_and_ack(ioaddr);
+
 	// Soft reset the chip. 
 	RTL_W8(ChipCmd, CmdReset);
 
@@ -1540,7 +1550,7 @@ err_free_irq:
 static void rtl8169_hw_reset(void __iomem *ioaddr)
 {
 	/* Disable interrupts */
-	RTL_W16(IntrMask, 0x0000);
+	rtl8169_irq_mask_and_ack(ioaddr);
 
 	/* Reset the chipset */
 	RTL_W8(ChipCmd, CmdReset);
@@ -1824,9 +1834,7 @@ static void rtl8169_wait_for_quiescence(
 	/* Wait for any pending NAPI task to complete */
 	netif_poll_disable(dev);
 
-	RTL_W16(IntrMask, 0x0000);
-
-	RTL_W16(IntrStatus, 0xffff);
+	rtl8169_irq_mask_and_ack(ioaddr);
 
 	netif_poll_enable(dev);
 }
@@ -2244,12 +2252,9 @@ rtl8169_interrupt(int irq, void *dev_ins
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int boguscnt = max_interrupt_work;
 	void __iomem *ioaddr = tp->mmio_addr;
-	int status = 0;
+	int status;
 	int handled = 0;
 
-	if (unlikely(!netif_running(dev)))
-		goto out;
-
 	do {
 		status = RTL_R16(IntrStatus);
 
@@ -2259,6 +2264,9 @@ rtl8169_interrupt(int irq, void *dev_ins
 
 		handled = 1;
 
+		if (unlikely(!netif_running(dev)))
+			goto out_asic_stop;
+
 		status &= tp->intr_mask;
 		RTL_W16(IntrStatus,
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
@@ -2306,6 +2314,12 @@ rtl8169_interrupt(int irq, void *dev_ins
 	}
 out:
 	return IRQ_RETVAL(handled);
+
+out_asic_stop:
+	RTL_W8(ChipCmd, 0x00);
+	rtl8169_irq_mask_and_ack(ioaddr);
+	RTL_R16(CPlusCmd);
+	goto out;
 }
 
 #ifdef CONFIG_R8169_NAPI
@@ -2321,7 +2335,7 @@ static int rtl8169_poll(struct net_devic
 	*budget -= work_done;
 	dev->quota -= work_done;
 
-	if ((work_done < work_to_do) || !netif_running(dev)) {
+	if (work_done < work_to_do) {
 		netif_rx_complete(dev);
 		tp->intr_mask = 0xffff;
 		/*

_
