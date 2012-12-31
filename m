From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 02/15] via-rhine: some suspend/resume cleanup.
Date: Mon, 31 Dec 2012 16:25:36 +0100
Message-ID: <1356967549-5056-3-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54115 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab2LaPeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:44 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Work towards unifying duplicated power setup sections,
add large comment.

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   27 +++++++++++++++++++++++----
 1 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 5facb0b..928d96f 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -955,8 +955,10 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_res;
 	}
 
+	rp->base = ioaddr;
+
 #ifdef USE_MMIO
-	enable_mmio(pioaddr, quirks);
+	enable_mmio(rp->pioaddr, rp->quirks);
 
 	/* Check that selected MMIO registers match the PIO ones */
 	i = 0;
@@ -974,11 +976,9 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 #endif /* USE_MMIO */
 
-	rp->base = ioaddr;
-
 	/* Get chip registers into a sane state */
 	rhine_power_init(dev);
-	rhine_hw_init(dev, pioaddr);
+	rhine_hw_init(dev, rp->pioaddr);
 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = ioread8(ioaddr + StationAddr + i);
@@ -2324,6 +2324,25 @@ static int rhine_resume(struct device *device)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
 
+	/*
+	 * Resume theory of operation ("state machine" description):
+	 * Card state post resume() needs to be sufficiently restored
+	 * to be at least as "good" as post-probe()
+	 * (plus certain user-side card attribute modifications
+	 * ideally being preserved, too!).
+	 * In the case of an ifdown iface prior to suspend,
+	 * this means equal state.
+	 * open()/close() then do a state elevation (working iface)
+	 * and reversal (back down to post-probe() card state).
+	 * NetworkManager likes to close() ifaces prior to suspend(),
+	 * thus they end up "closed" on resume() yet the card
+	 * needs to be sufficiently restored to have its basics working...
+	 * (open() does NOT and should not carry out such things!!).
+	 * FIXME: the card setup parts here are duplicated
+	 * with corresponding parts in probe() - they should be moved
+	 * into a helper to be commonly called by both places.
+	 */
+
 #ifdef USE_MMIO
 	enable_mmio(rp->pioaddr, rp->quirks);
 #endif
-- 
1.7.2.5
