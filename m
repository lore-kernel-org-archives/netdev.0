From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] r8169: auto detect 32-bit slot
Date: Wed, 9 Mar 2005 11:29:25 -0800
Message-ID: <20050309112925.7f7900ab@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change driver to auto-detect when the board is in a 32-bit PCI slot and
avoid setting 64-bit dma mask. The module parameter method is no longer needed.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	2005-03-09 11:23:58 -08:00
+++ b/drivers/net/r8169.c	2005-03-09 11:23:58 -08:00
@@ -182,7 +182,6 @@
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_copybreak = 200;
-static int use_dac;
 
 enum RTL8169_registers {
 	MAC0 = 0,		/* Ethernet hardware address. */
@@ -419,8 +418,6 @@
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 module_param_array(media, int, &num_media, 0);
 module_param(rx_copybreak, int, 0);
-module_param(use_dac, int, 0);
-MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(RTL8169_VERSION);
 
@@ -1224,18 +1221,6 @@
 
 	tp->cp_cmd = PCIMulRW | RxChkSum;
 
-	if ((sizeof(dma_addr_t) > 4) &&
-	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK) && use_dac) {
-		tp->cp_cmd |= PCIDAC;
-		dev->features |= NETIF_F_HIGHDMA;
-	} else {
-		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
-		if (rc < 0) {
-			printk(KERN_ERR PFX "DMA configuration failed.\n");
-			goto err_out_free_res;
-		}
-	}
-
 	pci_set_master(pdev);
 
 	/* ioremap MMIO region */
@@ -1278,6 +1263,19 @@
 		i++;
 	}
 	tp->chipset = i;
+
+	if ((sizeof(dma_addr_t) > 4) &&
+	    (RTL_R32(Config2) & (1<<3)) && 
+	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+		tp->cp_cmd |= PCIDAC;
+		dev->features |= NETIF_F_HIGHDMA;
+	} else {
+		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		if (rc < 0) {
+			printk(KERN_ERR PFX "DMA configuration failed.\n");
+			goto err_out_free_res;
+		}
+	}
 
 	*ioaddr_out = ioaddr;
 	*dev_out = dev;
