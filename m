From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Tue, 7 Nov 2006 23:58:30 -0500
Message-ID: <20061108045825.GA15272@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:13839 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1754299AbWKHFY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 00:24:57 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit edd106fc8ac1826dbe231b70ce0762db24133e5c:
  Auke Kok:
        e1000: Fix regression: garbled stats and irq allocation during swsusp

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Adrian Bunk:
      bcm43xx: Add error checking in bcm43xx_sprom_write()

Michael Buesch:
      bcm43xx: Drain TX status before starting IRQs

 drivers/net/wireless/bcm43xx/bcm43xx_main.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 65edb56..a1b7838 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -746,7 +746,7 @@ int bcm43xx_sprom_write(struct bcm43xx_p
 	if (err)
 		goto err_ctlreg;
 	spromctl |= 0x10; /* SPROM WRITE enable. */
-	bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
+	err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
 	if (err)
 		goto err_ctlreg;
 	/* We must burn lots of CPU cycles here, but that does not
@@ -768,7 +768,7 @@ int bcm43xx_sprom_write(struct bcm43xx_p
 		mdelay(20);
 	}
 	spromctl &= ~0x10; /* SPROM WRITE enable. */
-	bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
+	err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
 	if (err)
 		goto err_ctlreg;
 	mdelay(500);
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
@@ -3532,6 +3549,7 @@ int bcm43xx_select_wireless_core(struct 
 	bcm43xx_macfilter_clear(bcm, BCM43xx_MACFILTER_ASSOC);
 	bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_SELF, (u8 *)(bcm->net_dev->dev_addr));
 	bcm43xx_security_init(bcm);
+	drain_txstatus_queue(bcm);
 	ieee80211softmac_start(bcm->net_dev);
 
 	/* Let's go! Be careful after enabling the IRQs.
-- 
John W. Linville
linville@tuxdriver.com
