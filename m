From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/9][TG3]: Add tg3_poll_fw().
Date: Wed, 27 Sep 2006 13:34:49 -0700
Message-ID: <1159389289.3411.22.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:23570 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030791AbWI0UiO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:38:14 -0400
To: davem@davemloft.net, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add tg3_poll_fw().

Put the firmware polling logic into a separate function.  This makes
the code cleaner.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d443b73..eafca2a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4662,6 +4662,35 @@ static void tg3_write_sig_legacy(struct 
 	}
 }
 
+static int tg3_poll_fw(struct tg3 *tp)
+{
+	int i;
+	u32 val;
+
+	/* Wait for firmware initialization to complete. */
+	for (i = 0; i < 100000; i++) {
+		tg3_read_mem(tp, NIC_SRAM_FIRMWARE_MBOX, &val);
+		if (val == ~NIC_SRAM_FIRMWARE_MBOX_MAGIC1)
+			break;
+		udelay(10);
+	}
+
+	/* Chip might not be fitted with firmware.  Some Sun onboard
+	 * parts are configured like that.  So don't signal the timeout
+	 * of the above loop as an error, but do report the lack of
+	 * running firmware once.
+	 */
+	if (i >= 100000 &&
+	    !(tp->tg3_flags2 & TG3_FLG2_NO_FWARE_REPORTED)) {
+		tp->tg3_flags2 |= TG3_FLG2_NO_FWARE_REPORTED;
+
+		printk(KERN_INFO PFX "%s: No firmware running.\n",
+		       tp->dev->name);
+	}
+
+	return 0;
+}
+
 static void tg3_stop_fw(struct tg3 *);
 
 /* tp->lock is held. */
@@ -4669,7 +4698,7 @@ static int tg3_chip_reset(struct tg3 *tp
 {
 	u32 val;
 	void (*write_op)(struct tg3 *, u32, u32);
-	int i;
+	int err;
 
 	tg3_nvram_lock(tp);
 
@@ -4829,26 +4858,9 @@ static int tg3_chip_reset(struct tg3 *tp
 		tw32_f(MAC_MODE, 0);
 	udelay(40);
 
-	/* Wait for firmware initialization to complete. */
-	for (i = 0; i < 100000; i++) {
-		tg3_read_mem(tp, NIC_SRAM_FIRMWARE_MBOX, &val);
-		if (val == ~NIC_SRAM_FIRMWARE_MBOX_MAGIC1)
-			break;
-		udelay(10);
-	}
-
-	/* Chip might not be fitted with firmare.  Some Sun onboard
-	 * parts are configured like that.  So don't signal the timeout
-	 * of the above loop as an error, but do report the lack of
-	 * running firmware once.
-	 */
-	if (i >= 100000 &&
-	    !(tp->tg3_flags2 & TG3_FLG2_NO_FWARE_REPORTED)) {
-		tp->tg3_flags2 |= TG3_FLG2_NO_FWARE_REPORTED;
-
-		printk(KERN_INFO PFX "%s: No firmware running.\n",
-		       tp->dev->name);
-	}
+	err = tg3_poll_fw(tp);
+	if (err)
+		return err;
 
 	if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
 	    tp->pci_chip_rev_id != CHIPREV_ID_5750_A0) {


