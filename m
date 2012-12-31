From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 11/15] via-rhine: WOL: separate WOL configuration (and its logging).
Date: Mon, 31 Dec 2012 16:25:45 +0100
Message-ID: <1356967549-5056-12-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54144 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab2LaPep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:45 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Add helper rhine_power_state_configure().

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |  129 +++++++++++++++++++++-------------
 1 files changed, 80 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 7e13d50..8950eb0 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -562,6 +562,81 @@ static void rhine_ack_events(struct rhine_private *rp, u32 mask)
 	mmiowb();
 }
 
+/* Configures ACPI D0..D3 on card side. */
+static void
+rhine_power_state_configure(struct rhine_private *rp, u8 pci_state)
+{
+	void __iomem *ioaddr = rp->base;
+	u8 other_bits;
+	WARN_ON(!((pci_state >= 0) && (pci_state <= 3)));
+
+	other_bits = ioread8(ioaddr + StickyHW) & 0xFC;
+	iowrite8(other_bits | pci_state, ioaddr + StickyHW);
+}
+
+static inline void
+rhine_wol_configure(struct net_device *dev, u16 *wolstat_out)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	void __iomem *ioaddr = rp->base;
+	u16 wolstat = 0;
+
+	/* Make sure chip is in power state D0 */
+	rhine_power_state_configure(rp, 0);
+
+	/* Disable "force PME-enable" */
+	iowrite8(0x80, ioaddr + WOLcgClr);
+
+	/* Clear power-event config bits (WOL) */
+	iowrite8(0xFF, ioaddr + WOLcrClr);
+	/* More recent cards can manage two additional patterns */
+	if (rp->quirks & rq6patterns)
+		iowrite8(0x03, ioaddr + WOLcrClr1);
+
+	/* Save power-event status bits */
+	wolstat = ioread8(ioaddr + PwrcsrSet);
+	if (rp->quirks & rq6patterns)
+		wolstat |= (ioread8(ioaddr + PwrcsrSet1) & 0x03) << 8;
+
+	/* Clear power-event status bits */
+	iowrite8(0xFF, ioaddr + PwrcsrClr);
+	if (rp->quirks & rq6patterns)
+		iowrite8(0x03, ioaddr + PwrcsrClr1);
+
+	if (wolstat_out)
+		*wolstat_out = wolstat;
+}
+
+static inline void
+rhine_wol_log_wakeup_reason(struct net_device *dev, u16 wolstat)
+{
+	if (wolstat) {
+		const char *reason;
+		switch (wolstat) {
+		case WOLmagic:
+			reason = "Magic packet";
+			break;
+		case WOLlnkon:
+			reason = "Link went up";
+			break;
+		case WOLlnkoff:
+			reason = "Link went down";
+			break;
+		case WOLucast:
+			reason = "Unicast packet";
+			break;
+		case WOLbmcast:
+			reason = "Multicast/broadcast packet";
+			break;
+		default:
+			reason = "Unknown";
+			break;
+		}
+		netdev_info(dev, "Woke system up. Reason: %s\n",
+			    reason);
+	}
+}
+
 /*
  * Get power related registers into sane state.
  * Notify user about past WOL event.
@@ -569,56 +644,12 @@ static void rhine_ack_events(struct rhine_private *rp, u32 mask)
 static void rhine_power_init(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
-	void __iomem *ioaddr = rp->base;
-	u16 wolstat;
 
 	if (rp->quirks & rqHaveWOL) {
-		/* Make sure chip is in power state D0 */
-		iowrite8(ioread8(ioaddr + StickyHW) & 0xFC, ioaddr + StickyHW);
-
-		/* Disable "force PME-enable" */
-		iowrite8(0x80, ioaddr + WOLcgClr);
-
-		/* Clear power-event config bits (WOL) */
-		iowrite8(0xFF, ioaddr + WOLcrClr);
-		/* More recent cards can manage two additional patterns */
-		if (rp->quirks & rq6patterns)
-			iowrite8(0x03, ioaddr + WOLcrClr1);
-
-		/* Save power-event status bits */
-		wolstat = ioread8(ioaddr + PwrcsrSet);
-		if (rp->quirks & rq6patterns)
-			wolstat |= (ioread8(ioaddr + PwrcsrSet1) & 0x03) << 8;
-
-		/* Clear power-event status bits */
-		iowrite8(0xFF, ioaddr + PwrcsrClr);
-		if (rp->quirks & rq6patterns)
-			iowrite8(0x03, ioaddr + PwrcsrClr1);
-
-		if (wolstat) {
-			char *reason;
-			switch (wolstat) {
-			case WOLmagic:
-				reason = "Magic packet";
-				break;
-			case WOLlnkon:
-				reason = "Link went up";
-				break;
-			case WOLlnkoff:
-				reason = "Link went down";
-				break;
-			case WOLucast:
-				reason = "Unicast packet";
-				break;
-			case WOLbmcast:
-				reason = "Multicast/broadcast packet";
-				break;
-			default:
-				reason = "Unknown";
-			}
-			netdev_info(dev, "Woke system up. Reason: %s\n",
-				    reason);
-		}
+		u16 wolstat;
+		rhine_wol_configure(dev, &wolstat);
+
+		rhine_wol_log_wakeup_reason(dev, wolstat);
 	}
 }
 
@@ -2325,7 +2356,7 @@ rhine_shutdown_and_keep_wol(struct pci_dev *pdev)
 	spin_unlock(&rp->lock);
 
 	if (system_state == SYSTEM_POWER_OFF && !avoid_D3) {
-		iowrite8(ioread8(ioaddr + StickyHW) | 0x03, ioaddr + StickyHW);
+		rhine_power_state_configure(rp, 3);
 
 		pci_wake_from_d3(pdev, true);
 		pci_set_power_state(pdev, PCI_D3hot);
-- 
1.7.2.5
