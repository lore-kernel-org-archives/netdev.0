From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc3-mm2 3/5] r8169: automatic pci dac step down
Date: Mon, 4 Oct 2004 21:50:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004195051.GB20379@electric-eye.fr.zoreil.com>
References: <20041004194826.GA18404@electric-eye.fr.zoreil.com> <20041004194949.GA20379@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041004194949.GA20379@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Automatic adjustement of highmem dma feature.

The first interruption encountered on systems where the 8169 does not
perform PCI DAC correctly seems to always be a PCI error one.
When DAC is enabled, the driver tries to issue a complete down/up
sequence as an addition to the usual halt of the device.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-210 drivers/net/r8169.c
--- linux-2.6.9-rc3/drivers/net/r8169.c~r8169-210	2004-10-04 21:18:14.000000000 +0200
+++ linux-2.6.9-rc3-fr/drivers/net/r8169.c	2004-10-04 21:25:07.000000000 +0200
@@ -1716,6 +1716,34 @@ static void rtl8169_schedule_work(struct
 	schedule_delayed_work(&tp->task, 4);
 }
 
+static void rtl8169_wait_for_quiescence(struct net_device *dev)
+{
+	synchronize_irq(dev->irq);
+
+	/* Wait for any pending NAPI task to complete */
+	netif_poll_disable(dev);
+}
+
+static void rtl8169_reinit_task(void *_data)
+{
+	struct net_device *dev = _data;
+	int ret;
+
+	if (netif_running(dev)) {
+		rtl8169_wait_for_quiescence(dev);
+		rtl8169_close(dev);
+	}
+
+	ret = rtl8169_open(dev);
+	if (unlikely(ret < 0)) {
+		if (net_ratelimit()) {
+			printk(PFX KERN_ERR "%s: reinit failure (status = %d)."
+			       " Rescheduling.\n", dev->name, ret);
+		}
+		rtl8169_schedule_work(dev, rtl8169_reinit_task);
+	}
+}
+
 static void rtl8169_reset_task(void *_data)
 {
 	struct net_device *dev = _data;
@@ -1724,10 +1752,7 @@ static void rtl8169_reset_task(void *_da
 	if (!netif_running(dev))
 		return;
 
-	synchronize_irq(dev->irq);
-
-	/* Wait for any pending NAPI task to complete */
-	netif_poll_disable(dev);
+	rtl8169_wait_for_quiescence(dev);
 
 	rtl8169_rx_interrupt(dev, tp, tp->mmio_addr);
 	rtl8169_tx_clear(tp);
@@ -1893,6 +1918,46 @@ err_update_stats:
 	goto out;
 }
 
+static void rtl8169_pcierr_interrupt(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct pci_dev *pdev = tp->pci_dev;
+	void *ioaddr = tp->mmio_addr;
+	u16 pci_status, pci_cmd;
+
+	pci_read_config_word(pdev, PCI_COMMAND, &pci_cmd);
+	pci_read_config_word(pdev, PCI_STATUS, &pci_status);
+
+	printk(KERN_ERR PFX "%s: PCI error (cmd = 0x%04x, status = 0x%04x).\n",
+	       dev->name, pci_cmd, pci_status);
+
+	/*
+	 * The recovery sequence below admits a very elaborated explanation:
+	 * - it seems to work;
+	 * - I did not see what else could be done.
+	 *
+	 * Feel free to adjust to your needs.
+	 */
+	pci_write_config_word(pdev, PCI_COMMAND,
+			      pci_cmd | PCI_COMMAND_SERR | PCI_COMMAND_PARITY);
+
+	pci_write_config_word(pdev, PCI_STATUS,
+		pci_status & (PCI_STATUS_DETECTED_PARITY |
+		PCI_STATUS_SIG_SYSTEM_ERROR | PCI_STATUS_REC_MASTER_ABORT |
+		PCI_STATUS_REC_TARGET_ABORT | PCI_STATUS_SIG_TARGET_ABORT));
+
+	/* The infamous DAC f*ckup only happens at boot time */
+	if ((tp->cp_cmd & PCIDAC) && (tp->dirty_rx == tp->cur_rx == 0)) {
+		printk(KERN_INFO PFX "%s: disabling PCI DAC.\n", dev->name);
+		tp->cp_cmd &= ~PCIDAC;
+		RTL_W16(CPlusCmd, tp->cp_cmd);
+		dev->features &= ~NETIF_F_HIGHDMA;
+		rtl8169_schedule_work(dev, rtl8169_reinit_task);
+	}
+
+	rtl8169_hw_reset(ioaddr);
+}
+
 static void
 rtl8169_tx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 		     void *ioaddr)
@@ -2094,9 +2159,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 			break;
 
 		if (unlikely(status & SYSErr)) {
-			printk(KERN_ERR PFX "%s: PCI error (status: 0x%04x)."
-			       " Device disabled.\n", dev->name, status);
-			rtl8169_hw_reset(ioaddr);
+			rtl8169_pcierr_interrupt(dev);
 			break;
 		}
 

_
