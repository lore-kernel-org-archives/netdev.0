From: David Dillow <dave@thedillows.org>
Subject: [PATCH 2.6] typhoon: fix PCI enable, add port IO option
Date: Sat, 27 Nov 2004 01:01:13 -0500
Message-ID: <1101535273.4734.3.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff, please do a

	bk pull http://typhoon.bkbits.net/typhoon-2.6

This will update the following files:

 drivers/net/typhoon.c |  236 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 157 insertions(+), 79 deletions(-)

through these ChangeSets:

<dave@thedillows.org> (04/11/27 1.2098)
   PCI enable bug fix, allow use of port IO, removal of depreciated
   MODULE_PARM macros.

Attached for convienience...

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/27 00:28:22-05:00 dave@thedillows.org 
#   PCI enable bug fix, allow use of port IO, removal of depreciated
#   MODULE_PARM macros.
# 
# drivers/net/typhoon.c
#   2004/11/27 00:28:04-05:00 dave@thedillows.org +2 -2
#   Bump version and release date.
# 
# drivers/net/typhoon.c
#   2004/11/27 00:24:56-05:00 dave@thedillows.org +9 -2
#   Use module_param() and add descriptions.
# 
# drivers/net/typhoon.c
#   2004/11/27 00:24:12-05:00 dave@thedillows.org +144 -72
#   Teach typhoon to use port IO on machines that need it. It will attempt
#   to use MMIO, but if that fails (or the user asks), it will fallback
#   to port IO.
# 
# drivers/net/typhoon.c
#   2004/11/27 00:17:58-05:00 dave@thedillows.org +3 -4
#   Enable bus mastering before saving our state, or we'll only be able
#   to load the modules one time.
# 
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2004-11-27 00:55:59 -05:00
+++ b/drivers/net/typhoon.c	2004-11-27 00:55:59 -05:00
@@ -50,6 +50,13 @@
  */
 static int rx_copybreak = 200;
 
+/* Should we use MMIO or Port IO?
+ * 0: Port IO
+ * 1: MMIO
+ * 2: Try MMIO, fallback to Port IO
+ */
+static unsigned int use_mmio = 2;
+
 /* end user-configurable values */
 
 /* Maximum number of multicast addresses to filter (vs. rx-all-multicast).
@@ -93,12 +100,13 @@
 #define PKT_BUF_SZ		1536
 
 #define DRV_MODULE_NAME		"typhoon"
-#define DRV_MODULE_VERSION 	"1.5.4"
-#define DRV_MODULE_RELDATE	"04/09/09"
+#define DRV_MODULE_VERSION 	"1.5.5"
+#define DRV_MODULE_RELDATE	"04/11/27"
 #define PFX			DRV_MODULE_NAME ": "
 #define ERR_PFX			KERN_ERR PFX
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
@@ -131,9 +139,16 @@
     "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
+MODULE_VERSION(DRV_MODULE_VERSION);
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("3Com Typhoon Family (3C990, 3CR990, and variants)");
-MODULE_PARM(rx_copybreak, "i");
+MODULE_PARM_DESC(rx_copybreak, "Packets smaller than this are copied and "
+			       "the buffer given back to the NIC. Default "
+			       "is 200.");
+MODULE_PARM_DESC(use_mmio, "Use MMIO (1) or PIO(0) to access the NIC. "
+			   "Default is to try MMIO and fallback to PIO.");
+module_param(rx_copybreak, int, 0);
+module_param(use_mmio, int, 0);
 
 #if defined(NETIF_F_TSO) && MAX_SKB_FRAGS > 32
 #warning Typhoon only supports 32 entries in its SG list for TSO, disabling TSO
@@ -310,7 +325,7 @@
  * cannot pass a read, so this forces current writes to post.
  */
 #define typhoon_post_pci_writes(x) \
-	do { readl(x + TYPHOON_REG_HEARTBEAT); } while(0)
+	do { if(likely(use_mmio)) ioread32(x+TYPHOON_REG_HEARTBEAT); } while(0)
 
 /* We'll wait up to six seconds for a reset, and half a second normally.
  */
@@ -391,17 +406,17 @@
 	else
 		timeout = TYPHOON_RESET_TIMEOUT_SLEEP;
 
-	writel(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
-	writel(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_STATUS);
+	iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
+	iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_STATUS);
 
-	writel(TYPHOON_RESET_ALL, ioaddr + TYPHOON_REG_SOFT_RESET);
+	iowrite32(TYPHOON_RESET_ALL, ioaddr + TYPHOON_REG_SOFT_RESET);
 	typhoon_post_pci_writes(ioaddr);
 	udelay(1);
-	writel(TYPHOON_RESET_NONE, ioaddr + TYPHOON_REG_SOFT_RESET);
+	iowrite32(TYPHOON_RESET_NONE, ioaddr + TYPHOON_REG_SOFT_RESET);
 
 	if(wait_type != NoWait) {
 		for(i = 0; i < timeout; i++) {
-			if(readl(ioaddr + TYPHOON_REG_STATUS) ==
+			if(ioread32(ioaddr + TYPHOON_REG_STATUS) ==
 			   TYPHOON_STATUS_WAITING_FOR_HOST)
 				goto out;
 
@@ -416,8 +431,8 @@
 	}
 
 out:
-	writel(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
-	writel(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_STATUS);
+	iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
+	iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_STATUS);
 
 	/* The 3XP seems to need a little extra time to complete the load
 	 * of the sleep image before we can reliably boot it. Failure to
@@ -442,7 +457,7 @@
 	int i, err = 0;
 
 	for(i = 0; i < TYPHOON_WAIT_TIMEOUT; i++) {
-		if(readl(ioaddr + TYPHOON_REG_STATUS) == wait_value)
+		if(ioread32(ioaddr + TYPHOON_REG_STATUS) == wait_value)
 			goto out;
 		udelay(TYPHOON_UDELAY);
 	}
@@ -478,7 +493,7 @@
 
 		INIT_COMMAND_NO_RESPONSE(cmd, TYPHOON_CMD_HELLO_RESP);
 		smp_wmb();
-		writel(ring->lastWrite, tp->ioaddr + TYPHOON_REG_CMD_READY);
+		iowrite32(ring->lastWrite, tp->ioaddr + TYPHOON_REG_CMD_READY);
 		spin_unlock(&tp->command_lock);
 	}
 }
@@ -633,7 +648,7 @@
 	/* "I feel a presence... another warrior is on the the mesa."
 	 */
 	wmb();
-	writel(ring->lastWrite, tp->ioaddr + TYPHOON_REG_CMD_READY);
+	iowrite32(ring->lastWrite, tp->ioaddr + TYPHOON_REG_CMD_READY);
 	typhoon_post_pci_writes(tp->ioaddr);
 
 	if((cmd->flags & TYPHOON_CMD_RESPOND) == 0)
@@ -687,7 +702,7 @@
 		 * is the case.
 		 */
 		if(indexes->respCleared != indexes->respReady)
-			writel(1, tp->ioaddr + TYPHOON_REG_SELF_INTERRUPT);
+			iowrite32(1, tp->ioaddr + TYPHOON_REG_SELF_INTERRUPT);
 	}
 
 	spin_unlock(&tp->command_lock);
@@ -889,7 +904,7 @@
 	/* Kick the 3XP
 	 */
 	wmb();
-	writel(txRing->lastWrite, tp->tx_ioaddr + txRing->writeRegister);
+	iowrite32(txRing->lastWrite, tp->tx_ioaddr + txRing->writeRegister);
 
 	dev->trans_start = jiffies;
 
@@ -1251,7 +1266,7 @@
 	int i, err = 0;
 
 	for(i = 0; i < TYPHOON_WAIT_TIMEOUT; i++) {
-		if(readl(ioaddr + TYPHOON_REG_INTR_STATUS) &
+		if(ioread32(ioaddr + TYPHOON_REG_INTR_STATUS) &
 		   TYPHOON_INTR_BOOTCMD)
 			goto out;
 		udelay(TYPHOON_UDELAY);
@@ -1260,7 +1275,7 @@
 	err = -ETIMEDOUT;
 
 out:
-	writel(TYPHOON_INTR_BOOTCMD, ioaddr + TYPHOON_REG_INTR_STATUS);
+	iowrite32(TYPHOON_INTR_BOOTCMD, ioaddr + TYPHOON_REG_INTR_STATUS);
 	return err;
 }
 
@@ -1394,11 +1409,11 @@
 		goto err_out;
 	}
 
-	irqEnabled = readl(ioaddr + TYPHOON_REG_INTR_ENABLE);
-	writel(irqEnabled | TYPHOON_INTR_BOOTCMD,
+	irqEnabled = ioread32(ioaddr + TYPHOON_REG_INTR_ENABLE);
+	iowrite32(irqEnabled | TYPHOON_INTR_BOOTCMD,
 	       ioaddr + TYPHOON_REG_INTR_ENABLE);
-	irqMasked = readl(ioaddr + TYPHOON_REG_INTR_MASK);
-	writel(irqMasked | TYPHOON_INTR_BOOTCMD,
+	irqMasked = ioread32(ioaddr + TYPHOON_REG_INTR_MASK);
+	iowrite32(irqMasked | TYPHOON_INTR_BOOTCMD,
 	       ioaddr + TYPHOON_REG_INTR_MASK);
 
 	err = -ETIMEDOUT;
@@ -1410,24 +1425,24 @@
 	numSections = le32_to_cpu(fHdr->numSections);
 	load_addr = le32_to_cpu(fHdr->startAddr);
 
-	writel(TYPHOON_INTR_BOOTCMD, ioaddr + TYPHOON_REG_INTR_STATUS);
-	writel(load_addr, ioaddr + TYPHOON_REG_DOWNLOAD_BOOT_ADDR);
+	iowrite32(TYPHOON_INTR_BOOTCMD, ioaddr + TYPHOON_REG_INTR_STATUS);
+	iowrite32(load_addr, ioaddr + TYPHOON_REG_DOWNLOAD_BOOT_ADDR);
 	hmac = le32_to_cpu(fHdr->hmacDigest[0]);
-	writel(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_0);
+	iowrite32(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_0);
 	hmac = le32_to_cpu(fHdr->hmacDigest[1]);
-	writel(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_1);
+	iowrite32(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_1);
 	hmac = le32_to_cpu(fHdr->hmacDigest[2]);
-	writel(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_2);
+	iowrite32(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_2);
 	hmac = le32_to_cpu(fHdr->hmacDigest[3]);
-	writel(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_3);
+	iowrite32(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_3);
 	hmac = le32_to_cpu(fHdr->hmacDigest[4]);
-	writel(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_4);
+	iowrite32(hmac, ioaddr + TYPHOON_REG_DOWNLOAD_HMAC_4);
 	typhoon_post_pci_writes(ioaddr);
-	writel(TYPHOON_BOOTCMD_RUNTIME_IMAGE, ioaddr + TYPHOON_REG_COMMAND);
+	iowrite32(TYPHOON_BOOTCMD_RUNTIME_IMAGE, ioaddr + TYPHOON_REG_COMMAND);
 
 	image_data += sizeof(struct typhoon_file_header);
 
-	/* The readl() in typhoon_wait_interrupt() will force the
+	/* The ioread32() in typhoon_wait_interrupt() will force the
 	 * last write to the command register to post, so
 	 * we don't need a typhoon_post_pci_writes() after it.
 	 */
@@ -1441,7 +1456,7 @@
 			len = min_t(u32, section_len, PAGE_SIZE);
 
 			if(typhoon_wait_interrupt(ioaddr) < 0 ||
-			   readl(ioaddr + TYPHOON_REG_STATUS) !=
+			   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
 			   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
 				printk(KERN_ERR "%s: segment ready timeout\n",
 				       tp->name);
@@ -1458,13 +1473,14 @@
 			csum = csum_fold(csum);
 			csum = le16_to_cpu(csum);
 
-			writel(len, ioaddr + TYPHOON_REG_BOOT_LENGTH);
-			writel(csum, ioaddr + TYPHOON_REG_BOOT_CHECKSUM);
-			writel(load_addr, ioaddr + TYPHOON_REG_BOOT_DEST_ADDR);
-			writel(0, ioaddr + TYPHOON_REG_BOOT_DATA_HI);
-			writel(dpage_dma, ioaddr + TYPHOON_REG_BOOT_DATA_LO);
+			iowrite32(len, ioaddr + TYPHOON_REG_BOOT_LENGTH);
+			iowrite32(csum, ioaddr + TYPHOON_REG_BOOT_CHECKSUM);
+			iowrite32(load_addr,
+					ioaddr + TYPHOON_REG_BOOT_DEST_ADDR);
+			iowrite32(0, ioaddr + TYPHOON_REG_BOOT_DATA_HI);
+			iowrite32(dpage_dma, ioaddr + TYPHOON_REG_BOOT_DATA_LO);
 			typhoon_post_pci_writes(ioaddr);
-			writel(TYPHOON_BOOTCMD_SEG_AVAILABLE,
+			iowrite32(TYPHOON_BOOTCMD_SEG_AVAILABLE,
 			       ioaddr + TYPHOON_REG_COMMAND);
 
 			image_data += len;
@@ -1474,25 +1490,25 @@
 	}
 
 	if(typhoon_wait_interrupt(ioaddr) < 0 ||
-	   readl(ioaddr + TYPHOON_REG_STATUS) !=
+	   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
 	   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
 		printk(KERN_ERR "%s: final segment ready timeout\n", tp->name);
 		goto err_out_irq;
 	}
 
-	writel(TYPHOON_BOOTCMD_DNLD_COMPLETE, ioaddr + TYPHOON_REG_COMMAND);
+	iowrite32(TYPHOON_BOOTCMD_DNLD_COMPLETE, ioaddr + TYPHOON_REG_COMMAND);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_BOOT) < 0) {
 		printk(KERN_ERR "%s: boot ready timeout, status 0x%0x\n",
-		       tp->name, readl(ioaddr + TYPHOON_REG_STATUS));
+		       tp->name, ioread32(ioaddr + TYPHOON_REG_STATUS));
 		goto err_out_irq;
 	}
 
 	err = 0;
 
 err_out_irq:
-	writel(irqMasked, ioaddr + TYPHOON_REG_INTR_MASK);
-	writel(irqEnabled, ioaddr + TYPHOON_REG_INTR_ENABLE);
+	iowrite32(irqMasked, ioaddr + TYPHOON_REG_INTR_MASK);
+	iowrite32(irqEnabled, ioaddr + TYPHOON_REG_INTR_ENABLE);
 
 	pci_free_consistent(pdev, PAGE_SIZE, dpage, dpage_dma);
 
@@ -1510,24 +1526,25 @@
 		goto out_timeout;
 	}
 
-	writel(0, ioaddr + TYPHOON_REG_BOOT_RECORD_ADDR_HI);
-	writel(tp->shared_dma, ioaddr + TYPHOON_REG_BOOT_RECORD_ADDR_LO);
+	iowrite32(0, ioaddr + TYPHOON_REG_BOOT_RECORD_ADDR_HI);
+	iowrite32(tp->shared_dma, ioaddr + TYPHOON_REG_BOOT_RECORD_ADDR_LO);
 	typhoon_post_pci_writes(ioaddr);
-	writel(TYPHOON_BOOTCMD_REG_BOOT_RECORD, ioaddr + TYPHOON_REG_COMMAND);
+	iowrite32(TYPHOON_BOOTCMD_REG_BOOT_RECORD,
+				ioaddr + TYPHOON_REG_COMMAND);
 
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_RUNNING) < 0) {
 		printk(KERN_ERR "%s: boot finish timeout (status 0x%x)\n",
-		       tp->name, readl(ioaddr + TYPHOON_REG_STATUS));
+		       tp->name, ioread32(ioaddr + TYPHOON_REG_STATUS));
 		goto out_timeout;
 	}
 
 	/* Clear the Transmit and Command ready registers
 	 */
-	writel(0, ioaddr + TYPHOON_REG_TX_HI_READY);
-	writel(0, ioaddr + TYPHOON_REG_CMD_READY);
-	writel(0, ioaddr + TYPHOON_REG_TX_LO_READY);
+	iowrite32(0, ioaddr + TYPHOON_REG_TX_HI_READY);
+	iowrite32(0, ioaddr + TYPHOON_REG_CMD_READY);
+	iowrite32(0, ioaddr + TYPHOON_REG_TX_LO_READY);
 	typhoon_post_pci_writes(ioaddr);
-	writel(TYPHOON_BOOTCMD_BOOT, ioaddr + TYPHOON_REG_COMMAND);
+	iowrite32(TYPHOON_BOOTCMD_BOOT, ioaddr + TYPHOON_REG_COMMAND);
 
 	return 0;
 
@@ -1806,7 +1823,8 @@
 
 	if(done) {
 		netif_rx_complete(dev);
-		writel(TYPHOON_INTR_NONE, tp->ioaddr + TYPHOON_REG_INTR_MASK);
+		iowrite32(TYPHOON_INTR_NONE,
+				tp->ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(tp->ioaddr);
 	}
 
@@ -1821,14 +1839,14 @@
 	void __iomem *ioaddr = tp->ioaddr;
 	u32 intr_status;
 
-	intr_status = readl(ioaddr + TYPHOON_REG_INTR_STATUS);
+	intr_status = ioread32(ioaddr + TYPHOON_REG_INTR_STATUS);
 	if(!(intr_status & TYPHOON_INTR_HOST_INT))
 		return IRQ_NONE;
 
-	writel(intr_status, ioaddr + TYPHOON_REG_INTR_STATUS);
+	iowrite32(intr_status, ioaddr + TYPHOON_REG_INTR_STATUS);
 
 	if(netif_rx_schedule_prep(dev)) {
-		writel(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
+		iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(ioaddr);
 		__netif_rx_schedule(dev);
 	} else {
@@ -1905,7 +1923,7 @@
 	 * we can download the Runtime Image. But let's not make users of
 	 * the old firmware pay for the reset.
 	 */
-	writel(TYPHOON_BOOTCMD_WAKEUP, ioaddr + TYPHOON_REG_COMMAND);
+	iowrite32(TYPHOON_BOOTCMD_WAKEUP, ioaddr + TYPHOON_REG_COMMAND);
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_HOST) < 0 ||
 			(tp->capabilities & TYPHOON_WAKEUP_NEEDS_RESET))
 		return typhoon_reset(ioaddr, wait_type);
@@ -1994,8 +2012,8 @@
 	tp->card_state = Running;
 	smp_wmb();
 
-	writel(TYPHOON_INTR_ENABLE_ALL, ioaddr + TYPHOON_REG_INTR_ENABLE);
-	writel(TYPHOON_INTR_NONE, ioaddr + TYPHOON_REG_INTR_MASK);
+	iowrite32(TYPHOON_INTR_ENABLE_ALL, ioaddr + TYPHOON_REG_INTR_ENABLE);
+	iowrite32(TYPHOON_INTR_NONE, ioaddr + TYPHOON_REG_INTR_MASK);
 	typhoon_post_pci_writes(ioaddr);
 
 	return 0;
@@ -2020,7 +2038,7 @@
 	 * when called with !netif_running(). This will be posted
 	 * when we force the posting of the command.
 	 */
-	writel(TYPHOON_INTR_NONE, ioaddr + TYPHOON_REG_INTR_ENABLE);
+	iowrite32(TYPHOON_INTR_NONE, ioaddr + TYPHOON_REG_INTR_ENABLE);
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_RX_DISABLE);
 	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
@@ -2275,14 +2293,59 @@
 #endif
 
 static int __devinit
+typhoon_test_mmio(struct pci_dev *pdev)
+{
+	void __iomem *ioaddr = pci_iomap(pdev, 1, 128);
+	int mode = 0;
+	u32 val;
+
+	if(!ioaddr)
+		goto out;
+
+	if(ioread32(ioaddr + TYPHOON_REG_STATUS) !=
+				TYPHOON_STATUS_WAITING_FOR_HOST)
+		goto out_unmap;
+
+	iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
+	iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_STATUS);
+	iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_ENABLE);
+
+	/* Ok, see if we can change our interrupt status register by
+	 * sending ourselves an interrupt. If so, then MMIO works.
+	 * The 50usec delay is arbitrary -- it could probably be smaller.
+	 */
+	val = ioread32(ioaddr + TYPHOON_REG_INTR_STATUS);
+	if((val & TYPHOON_INTR_SELF) == 0) {
+		iowrite32(1, ioaddr + TYPHOON_REG_SELF_INTERRUPT);
+		ioread32(ioaddr + TYPHOON_REG_INTR_STATUS);
+		udelay(50);
+		val = ioread32(ioaddr + TYPHOON_REG_INTR_STATUS);
+		if(val & TYPHOON_INTR_SELF)
+			mode = 1;
+	}
+
+	iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
+	iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_STATUS);
+	iowrite32(TYPHOON_INTR_NONE, ioaddr + TYPHOON_REG_INTR_ENABLE);
+	ioread32(ioaddr + TYPHOON_REG_INTR_STATUS);
+
+out_unmap:
+	pci_iounmap(pdev, ioaddr);
+
+out:
+	if(!mode)
+		printk(KERN_INFO PFX "falling back to port IO\n");
+	return mode;
+}
+
+static int __devinit
 typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int did_version = 0;
 	struct net_device *dev;
 	struct typhoon *tp;
 	int card_id = (int) ent->driver_data;
-	unsigned long ioaddr;
-	void __iomem *ioaddr_mapped;
+	void __iomem *ioaddr;
 	void *shared;
 	dma_addr_t shared_dma;
 	struct cmd_desc xp_cmd;
@@ -2323,8 +2386,21 @@
 		goto error_out_mwi;
 	}
 
-	/* sanity checks, resource #1 is our mmio area
+	/* sanity checks on IO and MMIO BARs
 	 */
+	if(!(pci_resource_flags(pdev, 0) & IORESOURCE_IO)) {
+		printk(ERR_PFX
+		       "%s: region #1 not a PCI IO resource, aborting\n",
+		       pci_name(pdev));
+		err = -ENODEV;
+		goto error_out_mwi;
+	}
+	if(pci_resource_len(pdev, 0) < 128) {
+		printk(ERR_PFX "%s: Invalid PCI IO region size, aborting\n",
+		       pci_name(pdev));
+		err = -ENODEV;
+		goto error_out_mwi;
+	}
 	if(!(pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
 		printk(ERR_PFX
 		       "%s: region #1 not a PCI MMIO resource, aborting\n",
@@ -2346,12 +2422,14 @@
 		goto error_out_mwi;
 	}
 
-	/* map our MMIO region
+	/* map our registers
 	 */
-	ioaddr = pci_resource_start(pdev, 1);
-	ioaddr_mapped = ioremap(ioaddr, 128);
-	if (!ioaddr_mapped) {
-		printk(ERR_PFX "%s: cannot remap MMIO, aborting\n",
+	if(use_mmio != 0 && use_mmio != 1)
+		use_mmio = typhoon_test_mmio(pdev);
+
+	ioaddr = pci_iomap(pdev, use_mmio, 128);
+	if (!ioaddr) {
+		printk(ERR_PFX "%s: cannot remap registers, aborting\n",
 		       pci_name(pdev));
 		err = -EIO;
 		goto error_out_regions;
@@ -2374,13 +2452,10 @@
 	tp->shared_dma = shared_dma;
 	tp->pdev = pdev;
 	tp->tx_pdev = pdev;
-	tp->ioaddr = ioaddr_mapped;
-	tp->tx_ioaddr = ioaddr_mapped;
+	tp->ioaddr = ioaddr;
+	tp->tx_ioaddr = ioaddr;
 	tp->dev = dev;
 
-	/* need to be able to restore PCI state after a suspend */
-	pci_save_state(pdev);
-
 	/* Init sequence:
 	 * 1) Reset the adapter to clear any bad juju
 	 * 2) Reload the sleep image
@@ -2388,16 +2463,18 @@
 	 * 4) Get the hardware address.
 	 * 5) Put the card to sleep.
 	 */
-	if (typhoon_reset(ioaddr_mapped, WaitSleep) < 0) {
+	if (typhoon_reset(ioaddr, WaitSleep) < 0) {
 		printk(ERR_PFX "%s: could not reset 3XP\n", pci_name(pdev));
 		err = -EIO;
 		goto error_out_dma;
 	}
 
 	/* Now that we've reset the 3XP and are sure it's not going to
-	 * write all over memory, enable bus mastering.
+	 * write all over memory, enable bus mastering, and save our
+	 * state for resuming after a suspend.
 	 */
 	pci_set_master(pdev);
+	pci_save_state(pdev);
 
 	/* dev->name is not valid until we register, but we need to
 	 * use some common routines to initialize the card. So that those
@@ -2491,8 +2568,9 @@
 
 	pci_set_drvdata(pdev, dev);
 
-	printk(KERN_INFO "%s: %s at 0x%lx, ",
-	       dev->name, typhoon_card_info[card_id].name, ioaddr);
+	printk(KERN_INFO "%s: %s at %s 0x%lx, ",
+	       dev->name, typhoon_card_info[card_id].name,
+	       use_mmio ? "MMIO" : "IO", pci_resource_start(pdev, use_mmio));
 	for(i = 0; i < 5; i++)
 		printk("%2.2x:", dev->dev_addr[i]);
 	printk("%2.2x\n", dev->dev_addr[i]);
@@ -2526,13 +2604,13 @@
 	return 0;
 
 error_out_reset:
-	typhoon_reset(ioaddr_mapped, NoWait);
+	typhoon_reset(ioaddr, NoWait);
 
 error_out_dma:
 	pci_free_consistent(pdev, sizeof(struct typhoon_shared),
 			    shared, shared_dma);
 error_out_remap:
-	iounmap(ioaddr_mapped);
+	pci_iounmap(pdev, ioaddr);
 error_out_regions:
 	pci_release_regions(pdev);
 error_out_mwi:
@@ -2555,7 +2633,7 @@
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev);
 	typhoon_reset(tp->ioaddr, NoWait);
-	iounmap(tp->ioaddr);
+	pci_iounmap(pdev, tp->ioaddr);
 	pci_free_consistent(pdev, sizeof(struct typhoon_shared),
 			    tp->shared, tp->shared_dma);
 	pci_release_regions(pdev);
