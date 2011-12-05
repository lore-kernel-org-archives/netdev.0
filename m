From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH] net/fec: fix the use of pdev->id
Date: Mon,  5 Dec 2011 23:01:15 +0800
Message-ID: <1323097275-7846-1-git-send-email-shawn.guo@linaro.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:53939 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932319Ab1LEOxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 09:53:30 -0500
Received: by iakc1 with SMTP id c1so2197521iak.19
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2011 06:53:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pdev->id is used in several places for different purpose.  All
these uses assume it's always the id of fec device which is >= 0.
However this is only true for non-DT case.  When DT plays, pdev->id
is always -1, which will break these pdev->id users.

Instead of fixing all these users one by one, this patch introduces
a new member 'dev_id' to 'struct fec_enet_private' for holding the
correct fec device id, and replaces all the existing uses of pdev->id
with this dev_id.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 1124ce0..c136230 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -232,6 +232,7 @@ struct fec_enet_private {
 	struct	platform_device *pdev;
 
 	int	opened;
+	int	dev_id;
 
 	/* Phylib and MDIO interface */
 	struct	mii_bus *mii_bus;
@@ -837,7 +838,7 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 
 	/* Adjust MAC if using macaddr */
 	if (iap == macaddr)
-		 ndev->dev_addr[ETH_ALEN-1] = macaddr[ETH_ALEN-1] + fep->pdev->id;
+		 ndev->dev_addr[ETH_ALEN-1] = macaddr[ETH_ALEN-1] + fep->dev_id;
 }
 
 /* ------------------------------------------------------------------------- */
@@ -953,7 +954,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	char mdio_bus_id[MII_BUS_ID_SIZE];
 	char phy_name[MII_BUS_ID_SIZE + 3];
 	int phy_id;
-	int dev_id = fep->pdev->id;
+	int dev_id = fep->dev_id;
 
 	fep->phy_dev = NULL;
 
@@ -1031,7 +1032,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	 * mdio interface in board design, and need to be configured by
 	 * fec0 mii_bus.
 	 */
-	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && pdev->id > 0) {
+	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && fep->dev_id > 0) {
 		/* fec1 uses fec0 mii_bus */
 		fep->mii_bus = fec0_mii_bus;
 		return 0;
@@ -1063,7 +1064,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	fep->mii_bus->read = fec_enet_mdio_read;
 	fep->mii_bus->write = fec_enet_mdio_write;
 	fep->mii_bus->reset = fec_enet_mdio_reset;
-	snprintf(fep->mii_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id + 1);
+	snprintf(fep->mii_bus->id, MII_BUS_ID_SIZE, "%x", fep->dev_id + 1);
 	fep->mii_bus->priv = fep;
 	fep->mii_bus->parent = &pdev->dev;
 
@@ -1521,6 +1522,7 @@ fec_probe(struct platform_device *pdev)
 	int i, irq, ret = 0;
 	struct resource *r;
 	const struct of_device_id *of_id;
+	static int dev_id;
 
 	of_id = of_match_device(fec_dt_ids, &pdev->dev);
 	if (of_id)
@@ -1548,6 +1550,7 @@ fec_probe(struct platform_device *pdev)
 
 	fep->hwp = ioremap(r->start, resource_size(r));
 	fep->pdev = pdev;
+	fep->dev_id = dev_id++;
 
 	if (!fep->hwp) {
 		ret = -ENOMEM;
-- 
1.7.4.1
