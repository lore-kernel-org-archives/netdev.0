From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH] ath5k: do not free irq after resume when card has been removed
Date: Tue,  8 Sep 2009 21:52:31 -0300
Message-ID: <1252457551-4909-1-git-send-email-cascardo@holoscopio.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, me@bobcopeland.com,
	lrodriguez@atheros.com, mickflemm@gmail.com, jirislaby@gmail.com,
	linville@tuxdriver.com, johannes@sipsolutions.net,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
To: ath5k-devel@lists.ath5k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from liberdade.minaslivre.org ([72.232.18.203]:34542 "EHLO
	liberdade.minaslivre.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbZIIAwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 20:52:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ath5k will try to request irq when resuming and fails if the device
(like a PCMCIA card) has been removed. The driver remove function will,
then, be called, trying to free the failed requested irq, resulting in
a warning.

This solves this issue defining a new flag for the status bitmap to
indicate when irq has been successfully requested and does not try to
release it if not.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 drivers/net/wireless/ath/ath5k/base.c |   13 +++++++++++--
 drivers/net/wireless/ath/ath5k/base.h |    3 ++-
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 029c1bc..c5e2d5b 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -553,6 +553,7 @@ ath5k_pci_probe(struct pci_dev *pdev,
 		ATH5K_ERR(sc, "request_irq failed\n");
 		goto err_free;
 	}
+	__set_bit(ATH_STAT_IRQREQUESTED, sc->status);
 
 	/* Initialize device */
 	sc->ah = ath5k_hw_attach(sc, id->driver_data);
@@ -628,6 +629,7 @@ ath5k_pci_probe(struct pci_dev *pdev,
 err_ah:
 	ath5k_hw_detach(sc->ah);
 err_irq:
+	__clear_bit(ATH_STAT_IRQREQUESTED, sc->status);
 	free_irq(pdev->irq, sc);
 err_free:
 	ieee80211_free_hw(hw);
@@ -650,7 +652,10 @@ ath5k_pci_remove(struct pci_dev *pdev)
 	ath5k_debug_finish_device(sc);
 	ath5k_detach(pdev, hw);
 	ath5k_hw_detach(sc->ah);
-	free_irq(pdev->irq, sc);
+	if (test_bit(ATH_STAT_IRQREQUESTED, sc->status)) {
+		__clear_bit(ATH_STAT_IRQREQUESTED, sc->status);
+		free_irq(pdev->irq, sc);
+	}
 	pci_iounmap(pdev, sc->iobase);
 	pci_release_region(pdev, 0);
 	pci_disable_device(pdev);
@@ -666,7 +671,10 @@ ath5k_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	ath5k_led_off(sc);
 
-	free_irq(pdev->irq, sc);
+	if (test_bit(ATH_STAT_IRQREQUESTED, sc->status)) {
+		__clear_bit(ATH_STAT_IRQREQUESTED, sc->status);
+		free_irq(pdev->irq, sc);
+	}
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
@@ -699,6 +707,7 @@ ath5k_pci_resume(struct pci_dev *pdev)
 		ATH5K_ERR(sc, "request_irq failed\n");
 		goto err_no_irq;
 	}
+	__set_bit(ATH_STAT_IRQREQUESTED, sc->status);
 
 	ath5k_led_enable(sc);
 	return 0;
diff --git a/drivers/net/wireless/ath/ath5k/base.h b/drivers/net/wireless/ath/ath5k/base.h
index f9b7f2f..4a71437 100644
--- a/drivers/net/wireless/ath/ath5k/base.h
+++ b/drivers/net/wireless/ath/ath5k/base.h
@@ -137,12 +137,13 @@ struct ath5k_softc {
 	size_t			desc_len;	/* size of TX/RX descriptors */
 	u16			cachelsz;	/* cache line size */
 
-	DECLARE_BITMAP(status, 5);
+	DECLARE_BITMAP(status, 6);
 #define ATH_STAT_INVALID	0		/* disable hardware accesses */
 #define ATH_STAT_MRRETRY	1		/* multi-rate retry support */
 #define ATH_STAT_PROMISC	2
 #define ATH_STAT_LEDSOFT	3		/* enable LED gpio status */
 #define ATH_STAT_STARTED	4		/* opened & irqs enabled */
+#define ATH_STAT_IRQREQUESTED	5		/* irq requested */
 
 	unsigned int		filter_flags;	/* HW flags, AR5K_RX_FILTER_* */
 	unsigned int		curmode;	/* current phy mode */
-- 
1.6.3.3

