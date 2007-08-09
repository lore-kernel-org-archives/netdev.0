From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc2-mm1
Date: Thu, 9 Aug 2007 11:37:10 -0700
Message-ID: <20070809113710.bc0e3b80.akpm@linux-foundation.org>
References: <20070809015106.cd0bfc53.akpm@linux-foundation.org>
	<46BB155D.8050501@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755355AbXHISj0@vger.kernel.org>
In-Reply-To: <46BB155D.8050501@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 09 Aug 2007 15:23:41 +0200
Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:

> Andrew Morton pisze:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc2/2.6.23-rc2-mm1/
> 
> I am experiencing some problems with 8139too
> 
> [   28.847004] 8139too 0000:02:0d.0: region #0 not a PIO resource, aborting
> [   28.854722] Bad IO access at port 0 ()
> [   28.859459] WARNING: at /home/devel/linux-mm/lib/iomap.c:44 bad_io_access()
> [   28.867415]  [<c040536b>] show_trace_log_lvl+0x1a/0x30
> [   28.873568]  [<c0405ff3>] show_trace+0x12/0x14
> [   28.879015]  [<c0406128>] dump_stack+0x16/0x18
> [   28.884451]  [<c052a904>] bad_io_access+0x58/0x5a
> [   28.890129]  [<c052a927>] pci_iounmap+0x21/0x2b
> [   28.895635]  [<c05b3746>] __rtl8139_cleanup_dev+0x75/0xc6
> [   28.902037]  [<c05b42c4>] rtl8139_init_one+0x59b/0xa9f
> [   28.908170]  [<c053e344>] pci_device_probe+0x44/0x5f
> [   28.914116]  [<c05a7cd0>] driver_probe_device+0xa7/0x19a
> [   28.920402]  [<c05a7f1a>] __driver_attach+0xa6/0xa8
> [   28.926236]  [<c05a71d3>] bus_for_each_dev+0x43/0x61
> [   28.932139]  [<c05a7b51>] driver_attach+0x19/0x1b
> [   28.937776]  [<c05a7504>] bus_add_driver+0x7e/0x1a5
> [   28.943567]  [<c05a80cf>] driver_register+0x45/0x75
> [   28.949358]  [<c053e4a5>] __pci_register_driver+0x56/0x84
> [   28.955678]  [<c0819118>] rtl8139_init_module+0x14/0x1c
> [   28.961832]  [<c0800521>] kernel_init+0x132/0x306
> [   28.967451]  [<c0404fb3>] kernel_thread_helper+0x7/0x14
> [   28.973588]  =======================
> [   28.978151] initcall 0xc0819104: rtl8139_init_module+0x0/0x1c() returned 0.
> [   28.986114] initcall 0xc0819104 ran for 161 msecs: rtl8139_init_module+0x0/0x1c()
> 
> http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.23-rc2-mm1/mm-dmesg
> http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.23-rc2-mm1/mm-config
> 

Please try reverting 8139too-force-media-setting-fix.patch, then
applying this:


From: Andrew Morton <akpm@linux-foundation.org>

Revert git-netdev-all's 9ee6b32a47b9abc565466a9c3b127a5246b452e5

Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/8139too.c |   50 +++++++++++++++++++++++-----------------
 1 file changed, 29 insertions(+), 21 deletions(-)

diff -puN drivers/net/8139too.c~revert-8139too-clean-up-i-o-remapping drivers/net/8139too.c
--- a/drivers/net/8139too.c~revert-8139too-clean-up-i-o-remapping
+++ a/drivers/net/8139too.c
@@ -121,15 +121,8 @@
 
 
 /* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected */
-enum rtl_bar_map_info {
-	rtl_pio_bar	= 0,	/* PCI BAR #0: PIO */
-	rtl_mmio_bar	= 1,	/* PCI BAR #1: MMIO */
-};
-
 #ifdef CONFIG_8139TOO_PIO
-static int use_pio	= 1;
-#else
-static int use_pio;
+#define USE_IO_OPS 1
 #endif
 
 /* define to 1, 2 or 3 to enable copious debugging info */
@@ -620,17 +613,14 @@ MODULE_DESCRIPTION ("RealTek RTL-8139 Fa
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-module_param(multicast_filter_limit, int, 0444);
+module_param(multicast_filter_limit, int, 0);
 module_param_array(media, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
-module_param(debug, int, 0444);
-module_param(use_pio, int, 0444);
-
+module_param(debug, int, 0);
+MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
 MODULE_PARM_DESC (multicast_filter_limit, "8139too maximum number of filtered multicast addresses");
 MODULE_PARM_DESC (media, "8139too: Bits 4+9: force full duplex, bit 5: 100Mbps");
 MODULE_PARM_DESC (full_duplex, "8139too: Force full duplex for board(s) (1)");
-MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
-MODULE_PARM_DESC (use_pio, "Non-zero to enable PIO (rather than MMIO) register mapping");
 
 static int read_eeprom (void __iomem *ioaddr, int location, int addr_len);
 static int rtl8139_open (struct net_device *dev);
@@ -718,7 +708,13 @@ static void __rtl8139_cleanup_dev (struc
 	assert (tp->pci_dev != NULL);
 	pdev = tp->pci_dev;
 
-	pci_iounmap (pdev, tp->mmio_addr);
+#ifdef USE_IO_OPS
+	if (tp->mmio_addr)
+		ioport_unmap (tp->mmio_addr);
+#else
+	if (tp->mmio_addr)
+		pci_iounmap (pdev, tp->mmio_addr);
+#endif /* USE_IO_OPS */
 
 	/* it's ok to call this even if we have no regions to free */
 	pci_release_regions (pdev);
@@ -794,32 +790,32 @@ static int __devinit rtl8139_init_board 
 	DPRINTK("PIO region size == 0x%02X\n", pio_len);
 	DPRINTK("MMIO region size == 0x%02lX\n", mmio_len);
 
+#ifdef USE_IO_OPS
 	/* make sure PCI base addr 0 is PIO */
 	if (!(pio_flags & IORESOURCE_IO)) {
 		dev_err(&pdev->dev, "region #0 not a PIO resource, aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
-
 	/* check for weird/broken PCI region reporting */
 	if (pio_len < RTL_MIN_IO_SIZE) {
 		dev_err(&pdev->dev, "Invalid PCI I/O region size(s), aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
-
+#else
 	/* make sure PCI base addr 1 is MMIO */
 	if (!(mmio_flags & IORESOURCE_MEM)) {
 		dev_err(&pdev->dev, "region #1 not an MMIO resource, aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
-
 	if (mmio_len < RTL_MIN_IO_SIZE) {
 		dev_err(&pdev->dev, "Invalid PCI mem region size(s), aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
+#endif
 
 	rc = pci_request_regions (pdev, DRV_NAME);
 	if (rc)
@@ -829,16 +825,28 @@ static int __devinit rtl8139_init_board 
 	/* enable PCI bus-mastering */
 	pci_set_master (pdev);
 
-	/* iomap MMIO region */
-	ioaddr = pci_iomap(pdev, use_pio ? rtl_pio_bar : rtl_mmio_bar, 0);
+#ifdef USE_IO_OPS
+	ioaddr = ioport_map(pio_start, pio_len);
+	if (!ioaddr) {
+		dev_err(&pdev->dev, "cannot map PIO, aborting\n");
+		rc = -EIO;
+		goto err_out;
+	}
+	dev->base_addr = pio_start;
+	tp->mmio_addr = ioaddr;
+	tp->regs_len = pio_len;
+#else
+	/* ioremap MMIO region */
+	ioaddr = pci_iomap(pdev, 1, 0);
 	if (ioaddr == NULL) {
-		dev_err(&pdev->dev, "cannot map I/O regions, aborting\n");
+		dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
 		rc = -EIO;
 		goto err_out;
 	}
 	dev->base_addr = (long) ioaddr;
 	tp->mmio_addr = ioaddr;
 	tp->regs_len = mmio_len;
+#endif /* USE_IO_OPS */
 
 	/* Bring old chips out of low-power mode. */
 	RTL_W8 (HltClk, 'R');
_
