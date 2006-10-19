From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: Drain TX status before starting IRQs
Date: Thu, 19 Oct 2006 17:29:34 +0200
Message-ID: <200610191729.35402.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:27069
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1946106AbWJSPaa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 11:30:30 -0400
To: linville@tuxdriver.com, Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drain the Microcode TX-status-FIFO before we enable IRQs.
This is required, because the FIFO may still have entries left
from a previous run. Those would immediately fire after enabling
IRQs and would lead to an oops in the DMA TXstatus handling code.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

--

Please consider also pushing this into the -stable tree.
The bug is not likely to trigger, but at least ben
triggered it in the past. Anyway, it can't hurt much to
drain the FIFO before running the device.

Note that this is diffed against 2.6.18.1 and not 2.6.18
as the diff prolog suggests. I just forgot to rename
the directory. ;)


Index: linux-2.6.18/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.18.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-10-15 21:10:37.000000000 +0200
+++ linux-2.6.18/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-10-19 17:17:16.000000000 +0200
@@ -1463,6 +1463,21 @@ static void handle_irq_transmit_status(s
 	}
 }
 
+static void drain_txstatus_queue(struct bcm43xx_private *bcm)
+{
+	u32 dummy;
+
+	/* Read all entries from the microcode TXstatus FIFO
+	 * and throw them away.
+	 */
+	while (1) {
+		dummy = bcm43xx_read32(bcm, BCM43xx_MMIO_XMITSTAT_0);
+		if (!dummy)
+			break;
+		dummy = bcm43xx_read32(bcm, BCM43xx_MMIO_XMITSTAT_1);
+	}
+}
+
 static void bcm43xx_generate_noise_sample(struct bcm43xx_private *bcm)
 {
 	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x408, 0x7F7F);
@@ -3509,6 +3524,7 @@ int bcm43xx_select_wireless_core(struct 
 	bcm43xx_macfilter_clear(bcm, BCM43xx_MACFILTER_ASSOC);
 	bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_SELF, (u8 *)(bcm->net_dev->dev_addr));
 	bcm43xx_security_init(bcm);
+	drain_txstatus_queue(bcm);
 	ieee80211softmac_start(bcm->net_dev);
 
 	/* Let's go! Be careful after enabling the IRQs.


-- 
Greetings Michael.
