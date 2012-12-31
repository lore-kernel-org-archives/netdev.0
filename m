From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 07/15] via-rhine: MMIO: move register verify into helper function.
Date: Mon, 31 Dec 2012 16:25:41 +0100
Message-ID: <1356967549-5056-8-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54116 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327Ab2LaPeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:44 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Add mmio_verify_registers() function.
Gets rid of a useless USE_MMIO define section, too.
Reverse logging of MMIO vs. PIO values since the description suggests
different order.

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   49 +++++++++++++++++++--------------
 1 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 053375b..a16e227 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -338,14 +338,6 @@ enum bcr1_bits {
 	BCR1_MED1=0x80,		/* for VT6102 */
 };
 
-#ifdef USE_MMIO
-/* Registers we check that mmio and reg are the same. */
-static const int mmio_verify_registers[] = {
-	RxConfig, TxConfig, IntrEnable, ConfigA, ConfigB, ConfigC, ConfigD,
-	0
-};
-#endif
-
 /* Bits in the interrupt status/mask registers. */
 enum intr_status_bits {
 	IntrRxDone	= 0x0001,
@@ -659,6 +651,31 @@ static void enable_mmio(long pioaddr, u32 quirks)
 		outb(n, pioaddr + ConfigD);
 	}
 }
+/* Check that selected MMIO registers match the PIO ones */
+static inline bool
+mmio_verify_registers(struct pci_dev *pdev, long pioaddr, void __iomem *ioaddr)
+{
+	/* Registers we check to verify that mmio and reg are the same. */
+	static const int registers_to_verify[] = {
+		RxConfig, TxConfig, IntrEnable,
+		ConfigA, ConfigB, ConfigC, ConfigD,
+		0
+	};
+
+	int i = 0;
+	while (registers_to_verify[i]) {
+		int reg = registers_to_verify[i++];
+		unsigned char pio = inb(pioaddr+reg);
+		unsigned char mmio = readb(ioaddr+reg);
+		if (pio != mmio) {
+			dev_err(&pdev->dev,
+			"MMIO do not match PIO [%02x] (%02x != %02x)\n",
+			reg, mmio, pio);
+			return false;
+		}
+	}
+	return true;
+}
 #endif
 
 /*
@@ -969,19 +986,9 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifdef USE_MMIO
 	enable_mmio(rp->pioaddr, rp->quirks);
 
-	/* Check that selected MMIO registers match the PIO ones */
-	i = 0;
-	while (mmio_verify_registers[i]) {
-		int reg = mmio_verify_registers[i++];
-		unsigned char a = inb(pioaddr+reg);
-		unsigned char b = readb(ioaddr+reg);
-		if (a != b) {
-			rc = -EIO;
-			dev_err(&pdev->dev,
-				"MMIO do not match PIO [%02x] (%02x != %02x)\n",
-				reg, a, b);
-			goto err_out_unmap;
-		}
+	if (!mmio_verify_registers(pdev, pioaddr, ioaddr)) {
+		rc = -EIO;
+		goto err_out_unmap;
 	}
 #endif /* USE_MMIO */
 
-- 
1.7.2.5
