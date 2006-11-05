From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] bcm43xx: Drain TX status before starting IRQs
Date: Sun, 05 Nov 2006 15:34:36 -0600
Message-ID: <454E58EC.mail20S110EOC@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mb@bu3sch.de, greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-02.rdc-kc.rr.com ([24.94.166.122]:4065 "EHLO
	ms-smtp-02.rdc-kc.rr.com") by vger.kernel.org with ESMTP
	id S1422702AbWKEVfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 16:35:37 -0500
To: stable@kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>

Drain the Microcode TX-status-FIFO before we enable IRQs.
This is required, because the FIFO may still have entries left
from a previous run. Those would immediately fire after enabling
IRQs and would lead to an oops in the DMA TXstatus handling code.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Index: linux-2.6.18/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.18.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ linux-2.6.18/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -1463,6 +1463,23 @@ static void handle_irq_transmit_status(s
 	}
 }
 
+static void drain_txstatus_queue(struct bcm43xx_private *bcm)
+{
+	u32 dummy;
+
+	if (bcm->current_core->rev < 5)
+		return;
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
@@ -3517,6 +3534,7 @@ int bcm43xx_select_wireless_core(struct 
 	bcm43xx_macfilter_clear(bcm, BCM43xx_MACFILTER_ASSOC);
 	bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_SELF, (u8 *)(bcm->net_dev->dev_addr));
 	bcm43xx_security_init(bcm);
+	drain_txstatus_queue(bcm);
 	ieee80211softmac_start(bcm->net_dev);
 
 	/* Let's go! Be careful after enabling the IRQs.



