From: David Dillow <dave@thedillows.org>
Subject: [PATCH] Typhoon (3CR990) updates for 2.5
Date: 26 Nov 2003 23:09:08 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069906147.4552.10.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1486  -> 1.1487 
#	drivers/net/typhoon.c	1.8     -> 1.12   
#
# The following is the BitKeeper ChangeSet Log
# --
# 03/11/26	dave@thedillows.org	1.1487
# Bug fixes:
# * Avoid short timeouts when waiting for a reset
# * Fix issue with loading runtime image on newer versions of the sleep image
# * Fix link status reporting
# --
#
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
-- a/drivers/net/typhoon.c	Wed Nov 26 01:28:53 2003
+++ b/drivers/net/typhoon.c	Wed Nov 26 01:28:53 2003
@@ -85,8 +85,8 @@
 #define PKT_BUF_SZ		1536
 
 #define DRV_MODULE_NAME		"typhoon"
-#define DRV_MODULE_VERSION 	"1.5.1"
-#define DRV_MODULE_RELDATE	"03/06/26"
+#define DRV_MODULE_VERSION 	"1.5.2"
+#define DRV_MODULE_RELDATE	"03/11/25"
 #define PFX			DRV_MODULE_NAME ": "
 #define ERR_PFX			KERN_ERR PFX
 
@@ -127,7 +127,7 @@
 static char version[] __devinitdata =
     "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
-MODULE_AUTHOR("David Dillow <dillowd@y12.doe.gov>");
+MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("3Com Typhoon Family (3C990, 3CR990, and variants)");
 MODULE_PARM(rx_copybreak, "i");
@@ -146,11 +146,12 @@
 	int capabilities;
 };
 
-#define TYPHOON_CRYPTO_NONE		0
-#define TYPHOON_CRYPTO_DES		1
-#define TYPHOON_CRYPTO_3DES		2
-#define	TYPHOON_CRYPTO_VARIABLE		4
-#define TYPHOON_FIBER			8
+#define TYPHOON_CRYPTO_NONE		0x00
+#define TYPHOON_CRYPTO_DES		0x01
+#define TYPHOON_CRYPTO_3DES		0x02
+#define	TYPHOON_CRYPTO_VARIABLE		0x04
+#define TYPHOON_FIBER			0x08
+#define TYPHOON_WAKEUP_NEEDS_RESET	0x10
 
 enum typhoon_cards {
 	TYPHOON_TX = 0, TYPHOON_TX95, TYPHOON_TX97, TYPHOON_SVR,
@@ -307,7 +308,8 @@
 /* We'll wait up to six seconds for a reset, and half a second normally.
  */
 #define TYPHOON_UDELAY			50
-#define TYPHOON_RESET_TIMEOUT		(6 * HZ)
+#define TYPHOON_RESET_TIMEOUT_SLEEP	(6 * HZ)
+#define TYPHOON_RESET_TIMEOUT_NOSLEEP	((6 * 1000000) / TYPHOON_UDELAY)
 #define TYPHOON_WAIT_TIMEOUT		((1000000 / 2) / TYPHOON_UDELAY)
 
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2, 5, 28)
@@ -375,10 +377,12 @@
 typhoon_reset(unsigned long ioaddr, int wait_type)
 {
 	int i, err = 0;
-	int timeout = TYPHOON_RESET_TIMEOUT;
+	int timeout;
 
 	if(wait_type == WaitNoSleep)
-		timeout = (timeout * 1000000) / (HZ * TYPHOON_UDELAY);
+		timeout = TYPHOON_RESET_TIMEOUT_NOSLEEP;
+	else
+		timeout = TYPHOON_RESET_TIMEOUT_SLEEP;
 
 	writel(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
 	writel(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_STATUS);
@@ -1858,6 +1862,11 @@
 	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_SLEEPING) < 0)
 		return -ETIMEDOUT;
 
+	/* Since we cannot monitor the status of the link while sleeping,
+	 * tell the world it went away.
+	 */
+	netif_carrier_off(tp->dev);
+
 	pci_enable_wake(tp->pdev, state, 1);
 	pci_disable_device(pdev);
 	return pci_set_power_state(pdev, state);
@@ -1872,8 +1881,13 @@
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev, tp->pci_state);
 
+	/* Post 2.x.x versions of the Sleep Image require a reset before
+	 * we can download the Runtime Image. But let's not make users of
+	 * the old firmware pay for the reset.
+	 */
 	writel(TYPHOON_BOOTCMD_WAKEUP, ioaddr + TYPHOON_REG_COMMAND);
-	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_HOST) < 0)
+	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_WAITING_FOR_HOST) < 0 ||
+			(tp->capabilities & TYPHOON_WAKEUP_NEEDS_RESET))
 		return typhoon_reset(ioaddr, wait_type);
 
 	return 0;
@@ -2251,7 +2265,7 @@
 	void *shared;
 	dma_addr_t shared_dma;
 	struct cmd_desc xp_cmd;
-	struct resp_desc xp_resp;
+	struct resp_desc xp_resp[3];
 	int i;
 	int err = 0;
 
@@ -2380,15 +2394,15 @@
 	}
 
 	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_MAC_ADDRESS);
-	if(typhoon_issue_command(tp, 1, &xp_cmd, 1, &xp_resp) < 0) {
+	if(typhoon_issue_command(tp, 1, &xp_cmd, 1, xp_resp) < 0) {
 		printk(ERR_PFX "%s: cannot read MAC address\n",
 		       pci_name(pdev));
 		err = -EIO;
 		goto error_out_reset;
 	}
 
-	*(u16 *)&dev->dev_addr[0] = htons(le16_to_cpu(xp_resp.parm1));
-	*(u32 *)&dev->dev_addr[2] = htonl(le32_to_cpu(xp_resp.parm2));
+	*(u16 *)&dev->dev_addr[0] = htons(le16_to_cpu(xp_resp[0].parm1));
+	*(u32 *)&dev->dev_addr[2] = htonl(le32_to_cpu(xp_resp[0].parm2));
 
 	if(!is_valid_ether_addr(dev->dev_addr)) {
 		printk(ERR_PFX "%s: Could not obtain valid ethernet address, "
@@ -2396,6 +2410,28 @@
 		goto error_out_reset;
 	}
 
+	/* Read the Sleep Image version last, so the response is valid
+	 * later when we print out the version reported.
+	 */
+	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
+	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
+		printk(ERR_PFX "%s: Could not get Sleep Image version\n",
+			pdev->slot_name);
+		goto error_out_reset;
+	}
+
+	tp->capabilities = typhoon_card_info[card_id].capabilities;
+	tp->xcvr_select = TYPHOON_XCVR_AUTONEG;
+
+	/* Typhoon 1.0 Sleep Images return one response descriptor to the
+	 * READ_VERSIONS command. Those versions are OK after waking up
+	 * from sleep without needing a reset. Typhoon 1.1+ Sleep Images
+	 * seem to need a little extra help to get started. Since we don't
+	 * know how to nudge it along, just kick it.
+	 */
+	if(xp_resp[0].numDesc != 0)
+		tp->capabilities |= TYPHOON_WAKEUP_NEEDS_RESET;
+
 	if(typhoon_sleep(tp, 3, 0) < 0) {
 		printk(ERR_PFX "%s: cannot put adapter to sleep\n",
 		       pci_name(pdev));
@@ -2403,9 +2439,6 @@
 		goto error_out_reset;
 	}
 
-	tp->capabilities = typhoon_card_info[card_id].capabilities;
-	tp->xcvr_select = TYPHOON_XCVR_AUTONEG;
-
 	/* The chip-specific entries in the device structure. */
 	dev->open		= typhoon_open;
 	dev->hard_start_xmit	= typhoon_start_tx;
@@ -2442,6 +2475,32 @@
 		printk("%2.2x:", dev->dev_addr[i]);
 	printk("%2.2x\n", dev->dev_addr[i]);
 
+	/* xp_resp still contains the response to the READ_VERSIONS command.
+	 * For debugging, let the user know what version he has.
+	 */
+	if(xp_resp[0].numDesc == 0) {
+		/* This is the Typhoon 1.0 type Sleep Image, last 16 bits
+		 * of version is Month/Day of build.
+		 */
+		u16 monthday = le32_to_cpu(xp_resp[0].parm2) & 0xffff;
+		printk(KERN_INFO "%s: Typhoon 1.0 Sleep Image built "
+			"%02u/%02u/2000\n", dev->name, monthday >> 8,
+			monthday & 0xff);
+	} else if(xp_resp[0].numDesc == 2) {
+		/* This is the Typhoon 1.1+ type Sleep Image
+		 */
+		u32 sleep_ver = le32_to_cpu(xp_resp[0].parm2);
+		u8 *ver_string = (u8 *) &xp_resp[1];
+		ver_string[25] = 0;
+		printk(KERN_INFO "%s: Typhoon 1.1+ Sleep Image version "
+			"%u.%u.%u.%u %s\n", dev->name, HIPQUAD(sleep_ver),
+			ver_string);
+	} else {
+		printk(KERN_WARNING "%s: Unknown Sleep Image version "
+			"(%u:%04x)\n", dev->name, xp_resp[0].numDesc,
+			le32_to_cpu(xp_resp[0].parm2));
+	}
+		
 	return 0;
 
 error_out_reset:
