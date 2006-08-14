From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [patch RFC 3/3] b44: convert to ssb module
Date: Tue, 15 Aug 2006 00:18:39 +0200
Message-ID: <200608150018.39548.mb@bu3sch.de>
References: <200608150014.19661.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <200608150014.19661.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://bat.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is not runtime tested.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-dev/drivers/net/Kconfig
===================================================================
--- wireless-dev.orig/drivers/net/Kconfig	2006-08-09 16:52:40.000000000 +0200
+++ wireless-dev/drivers/net/Kconfig	2006-08-14 23:29:25.000000000 +0200
@@ -1388,7 +1388,7 @@
 
 config B44
 	tristate "Broadcom 4400 ethernet support"
-	depends on NET_PCI && PCI
+	depends on NET_PCI && PCI && SONICS_SILICON_BACKPLANE
 	select MII
 	help
 	  If you have a network (Ethernet) controller of this type, say Y and
Index: wireless-dev/drivers/net/b44.c
===================================================================
--- wireless-dev.orig/drivers/net/b44.c	2006-08-09 16:52:40.000000000 +0200
+++ wireless-dev/drivers/net/b44.c	2006-08-15 00:06:58.000000000 +0200
@@ -20,6 +20,7 @@
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
+#include <linux/ssb.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -177,85 +178,6 @@
 	return 0;
 }
 
-/* Sonics SiliconBackplane support routines.  ROFL, you should see all the
- * buzz words used on this company's website :-)
- *
- * All of these routines must be invoked with bp->lock held and
- * interrupts disabled.
- */
-
-#define SB_PCI_DMA             0x40000000      /* Client Mode PCI memory access space (1 GB) */
-#define BCM4400_PCI_CORE_ADDR  0x18002000      /* Address of PCI core on BCM4400 cards */
-
-static u32 ssb_get_core_rev(struct b44 *bp)
-{
-	return (br32(bp, B44_SBIDHIGH) & SBIDHIGH_RC_MASK);
-}
-
-static u32 ssb_pci_setup(struct b44 *bp, u32 cores)
-{
-	u32 bar_orig, pci_rev, val;
-
-	pci_read_config_dword(bp->pdev, SSB_BAR0_WIN, &bar_orig);
-	pci_write_config_dword(bp->pdev, SSB_BAR0_WIN, BCM4400_PCI_CORE_ADDR);
-	pci_rev = ssb_get_core_rev(bp);
-
-	val = br32(bp, B44_SBINTVEC);
-	val |= cores;
-	bw32(bp, B44_SBINTVEC, val);
-
-	val = br32(bp, SSB_PCI_TRANS_2);
-	val |= SSB_PCI_PREF | SSB_PCI_BURST;
-	bw32(bp, SSB_PCI_TRANS_2, val);
-
-	pci_write_config_dword(bp->pdev, SSB_BAR0_WIN, bar_orig);
-
-	return pci_rev;
-}
-
-static void ssb_core_disable(struct b44 *bp)
-{
-	if (br32(bp, B44_SBTMSLOW) & SBTMSLOW_RESET)
-		return;
-
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_REJECT | SBTMSLOW_CLOCK));
-	b44_wait_bit(bp, B44_SBTMSLOW, SBTMSLOW_REJECT, 100000, 0);
-	b44_wait_bit(bp, B44_SBTMSHIGH, SBTMSHIGH_BUSY, 100000, 1);
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_FGC | SBTMSLOW_CLOCK |
-			    SBTMSLOW_REJECT | SBTMSLOW_RESET));
-	br32(bp, B44_SBTMSLOW);
-	udelay(1);
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_REJECT | SBTMSLOW_RESET));
-	br32(bp, B44_SBTMSLOW);
-	udelay(1);
-}
-
-static void ssb_core_reset(struct b44 *bp)
-{
-	u32 val;
-
-	ssb_core_disable(bp);
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_RESET | SBTMSLOW_CLOCK | SBTMSLOW_FGC));
-	br32(bp, B44_SBTMSLOW);
-	udelay(1);
-
-	/* Clear SERR if set, this is a hw bug workaround.  */
-	if (br32(bp, B44_SBTMSHIGH) & SBTMSHIGH_SERR)
-		bw32(bp, B44_SBTMSHIGH, 0);
-
-	val = br32(bp, B44_SBIMSTATE);
-	if (val & (SBIMSTATE_IBE | SBIMSTATE_TO))
-		bw32(bp, B44_SBIMSTATE, val & ~(SBIMSTATE_IBE | SBIMSTATE_TO));
-
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_CLOCK | SBTMSLOW_FGC));
-	br32(bp, B44_SBTMSLOW);
-	udelay(1);
-
-	bw32(bp, B44_SBTMSLOW, (SBTMSLOW_CLOCK));
-	br32(bp, B44_SBTMSLOW);
-	udelay(1);
-}
-
 static int ssb_core_unit(struct b44 *bp)
 {
 #if 0
@@ -281,12 +203,6 @@
 	return 0;
 }
 
-static int ssb_is_core_up(struct b44 *bp)
-{
-	return ((br32(bp, B44_SBTMSLOW) & (SBTMSLOW_RESET | SBTMSLOW_REJECT | SBTMSLOW_CLOCK))
-		== SBTMSLOW_CLOCK);
-}
-
 static void __b44_cam_write(struct b44 *bp, unsigned char *data, int index)
 {
 	u32 val;
@@ -1276,9 +1192,12 @@
 }
 
 /* bp->lock is held. */
-static void b44_chip_reset(struct b44 *bp)
+static int b44_chip_reset(struct b44 *bp)
 {
-	if (ssb_is_core_up(bp)) {
+	struct ssb *ssb = bp->ssb;
+	int err = 0;
+
+	if (ssb_core_is_enabled(ssb)) {
 		bw32(bp, B44_RCV_LAZY, 0);
 		bw32(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE);
 		b44_wait_bit(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE, 100, 1);
@@ -1291,12 +1210,13 @@
 		bw32(bp, B44_DMARX_CTRL, 0);
 		bp->rx_prod = bp->rx_cons = 0;
 	} else {
-		ssb_pci_setup(bp, (bp->core_unit == 0 ?
-				   SBINTVEC_ENET0 :
-				   SBINTVEC_ENET1));
+		err = ssb_cores_connect(ssb, 0x1);
+		if (err)
+			goto out;
+		err = ssb_switch_core(ssb, &(ssb->cores[0]));
 	}
 
-	ssb_core_reset(bp);
+	ssb_core_enable(ssb, 0);
 
 	b44_clear_stats(bp);
 
@@ -1319,6 +1239,8 @@
 		}
 		bp->flags |= B44_FLAG_INTERNAL_PHY;
 	}
+out:
+	return err;
 }
 
 /* bp->lock is held. */
@@ -1592,8 +1514,8 @@
  		b44_setup_pseudo_magicp(bp);
  	}
 
-	val = br32(bp, B44_SBTMSLOW);
-	bw32(bp, B44_SBTMSLOW, val | SBTMSLOW_PE);
+	val = br32(bp, SSB_TMSLOW);
+	bw32(bp, SSB_TMSLOW, val | SSB_TMSLOW_PE);
 
 	pci_read_config_word(bp->pdev, SSB_PMCSR, &pmval);
 	pci_write_config_word(bp->pdev, SSB_PMCSR, pmval | SSB_PE);
@@ -2093,13 +2015,13 @@
 	bp->imask = IMASK_DEF;
 
 	bp->core_unit = ssb_core_unit(bp);
-	bp->dma_offset = SB_PCI_DMA;
+	bp->dma_offset = 0x40000000; /* Client Mode PCI memory access space (1GB) */
 
 	/* XXX - really required?
 	   bp->flags |= B44_FLAG_BUGGY_TXPTR;
          */
 
- 	if (ssb_get_core_rev(bp) >= 7)
+	if (bp->ssb->current_core->rev >= 7)
  		bp->flags |= B44_FLAG_B0_ANDLATER;
 
 out:
@@ -2114,6 +2036,9 @@
 	struct net_device *dev;
 	struct b44 *bp;
 	int err, i;
+	static const struct ssb_nrcores_elem nrcores_fallback[] = {
+		{ .chip_id_key = 0x4400, .nr_cores_value = 3, },
+	};
 
 	if (b44_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -2184,6 +2109,15 @@
 		err = -ENOMEM;
 		goto err_out_free_dev;
 	}
+	bp->ssb = ssb_alloc(pdev, bp->regs);
+	if (!bp->ssb) {
+		err = -ENOMEM;
+		goto err_out_iounmap;
+	}
+	err = ssb_probe_cores(bp->ssb, 0x4400, nrcores_fallback,
+			      ARRAY_SIZE(nrcores_fallback));
+	if (err)
+		goto err_out_ssbfree;
 
 	bp->rx_pending = B44_DEF_RX_RING_PENDING;
 	bp->tx_pending = B44_DEF_TX_RING_PENDING;
@@ -2212,7 +2146,7 @@
 	if (err) {
 		dev_err(&pdev->dev,
 			"Problem fetching invariants of chip, aborting.\n");
-		goto err_out_iounmap;
+		goto err_out_ssbfree;
 	}
 
 	bp->mii_if.dev = dev;
@@ -2232,7 +2166,7 @@
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-		goto err_out_iounmap;
+		goto err_out_ssbfree;
 	}
 
 	pci_set_drvdata(pdev, dev);
@@ -2251,6 +2185,9 @@
 
 	return 0;
 
+err_out_ssbfree:
+	ssb_free(bp->ssb);
+
 err_out_iounmap:
 	iounmap(bp->regs);
 
@@ -2273,6 +2210,7 @@
 
 	unregister_netdev(dev);
 	iounmap(bp->regs);
+	ssb_free(bp->ssb);
 	free_netdev(dev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
Index: wireless-dev/drivers/net/b44.h
===================================================================
--- wireless-dev.orig/drivers/net/b44.h	2006-08-09 16:52:40.000000000 +0200
+++ wireless-dev/drivers/net/b44.h	2006-08-14 23:31:24.000000000 +0200
@@ -227,76 +227,6 @@
 #define B44_RX_PAUSE	0x05D4UL /* MIB RX Pause Packets */
 #define B44_RX_NPAUSE	0x05D8UL /* MIB RX Non-Pause Packets */
 
-/* Silicon backplane register definitions */
-#define B44_SBIMSTATE	0x0F90UL /* SB Initiator Agent State */
-#define  SBIMSTATE_PC		0x0000000f /* Pipe Count */
-#define  SBIMSTATE_AP_MASK	0x00000030 /* Arbitration Priority */
-#define  SBIMSTATE_AP_BOTH	0x00000000 /* Use both timeslices and token */
-#define  SBIMSTATE_AP_TS	0x00000010 /* Use timeslices only */
-#define  SBIMSTATE_AP_TK	0x00000020 /* Use token only */
-#define  SBIMSTATE_AP_RSV	0x00000030 /* Reserved */
-#define  SBIMSTATE_IBE		0x00020000 /* In Band Error */
-#define  SBIMSTATE_TO		0x00040000 /* Timeout */
-#define B44_SBINTVEC	0x0F94UL /* SB Interrupt Mask */
-#define  SBINTVEC_PCI		0x00000001 /* Enable interrupts for PCI */
-#define  SBINTVEC_ENET0		0x00000002 /* Enable interrupts for enet 0 */
-#define  SBINTVEC_ILINE20	0x00000004 /* Enable interrupts for iline20 */
-#define  SBINTVEC_CODEC		0x00000008 /* Enable interrupts for v90 codec */
-#define  SBINTVEC_USB		0x00000010 /* Enable interrupts for usb */
-#define  SBINTVEC_EXTIF		0x00000020 /* Enable interrupts for external i/f */
-#define  SBINTVEC_ENET1		0x00000040 /* Enable interrupts for enet 1 */
-#define B44_SBTMSLOW	0x0F98UL /* SB Target State Low */
-#define  SBTMSLOW_RESET		0x00000001 /* Reset */
-#define  SBTMSLOW_REJECT	0x00000002 /* Reject */
-#define  SBTMSLOW_CLOCK		0x00010000 /* Clock Enable */
-#define  SBTMSLOW_FGC		0x00020000 /* Force Gated Clocks On */
-#define  SBTMSLOW_PE		0x40000000 /* Power Management Enable */
-#define  SBTMSLOW_BE		0x80000000 /* BIST Enable */
-#define B44_SBTMSHIGH	0x0F9CUL /* SB Target State High */
-#define  SBTMSHIGH_SERR		0x00000001 /* S-error */
-#define  SBTMSHIGH_INT		0x00000002 /* Interrupt */
-#define  SBTMSHIGH_BUSY		0x00000004 /* Busy */
-#define  SBTMSHIGH_GCR		0x20000000 /* Gated Clock Request */
-#define  SBTMSHIGH_BISTF	0x40000000 /* BIST Failed */
-#define  SBTMSHIGH_BISTD	0x80000000 /* BIST Done */
-#define B44_SBIDHIGH	0x0FFCUL /* SB Identification High */
-#define  SBIDHIGH_RC_MASK	0x0000000f /* Revision Code */
-#define  SBIDHIGH_CC_MASK	0x0000fff0 /* Core Code */
-#define  SBIDHIGH_CC_SHIFT	4
-#define  SBIDHIGH_VC_MASK	0xffff0000 /* Vendor Code */
-#define  SBIDHIGH_VC_SHIFT	16
-
-/* SSB PCI config space registers.  */
-#define SSB_PMCSR		0x44
-#define  SSB_PE			0x100
-#define	SSB_BAR0_WIN		0x80
-#define	SSB_BAR1_WIN		0x84
-#define	SSB_SPROM_CONTROL	0x88
-#define	SSB_BAR1_CONTROL	0x8c
-
-/* SSB core and host control registers.  */
-#define SSB_CONTROL		0x0000UL
-#define SSB_ARBCONTROL		0x0010UL
-#define SSB_ISTAT		0x0020UL
-#define SSB_IMASK		0x0024UL
-#define SSB_MBOX		0x0028UL
-#define SSB_BCAST_ADDR		0x0050UL
-#define SSB_BCAST_DATA		0x0054UL
-#define SSB_PCI_TRANS_0		0x0100UL
-#define SSB_PCI_TRANS_1		0x0104UL
-#define SSB_PCI_TRANS_2		0x0108UL
-#define SSB_SPROM		0x0800UL
-
-#define SSB_PCI_MEM		0x00000000
-#define SSB_PCI_IO		0x00000001
-#define SSB_PCI_CFG0		0x00000002
-#define SSB_PCI_CFG1		0x00000003
-#define SSB_PCI_PREF		0x00000004
-#define SSB_PCI_BURST		0x00000008
-#define SSB_PCI_MASK0		0xfc000000
-#define SSB_PCI_MASK1		0xfc000000
-#define SSB_PCI_MASK2		0xc0000000
-
 /* 4400 PHY registers */
 #define B44_MII_AUXCTRL		24	/* Auxiliary Control */
 #define  MII_AUXCTRL_DUPLEX	0x0001  /* Full Duplex */
@@ -410,9 +340,13 @@
 #undef _B44
 };
 
+struct ssb;
+
 struct b44 {
 	spinlock_t		lock;
 
+	struct ssb		*ssb; /* Sonics Silicon Backplane */
+
 	u32			imask, istat;
 
 	struct dma_desc		*rx_ring, *tx_ring;

-- 
Greetings Michael.
