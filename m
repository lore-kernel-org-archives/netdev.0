From: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Subject: [PATCH 1/5] sh_eth: Use the platform device for memory allocation
Date: Thu, 20 Mar 2014 15:00:31 +0100
Message-ID: <1395324035-22918-2-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1395324035-22918-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Cc: linux-sh@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perceval.ideasonboard.com ([95.142.166.194]:33927 "EHLO
	perceval.ideasonboard.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755769AbaCTN6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 09:58:51 -0400
In-Reply-To: <1395324035-22918-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Memory allocated for the MDIO bus with the devm_kzalloc() API is
associated with the network device. While this will cause memory to be
freed at the right time, it doesn't allow allocating memory before the
network device is initialized.

Replace the network device with the parent platform device for memory
allocation to remove that dependency. This also improves consistency
with the other devm_* calls in the driver that all use the platform
device.

Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/renesas/sh_eth.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index efaca6d..f669e2a 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2606,10 +2606,10 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 	int ret, i;
 	struct bb_info *bitbang;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct device *dev = &mdp->pdev->dev;
 
 	/* create bit control struct for PHY */
-	bitbang = devm_kzalloc(&ndev->dev, sizeof(struct bb_info),
-			       GFP_KERNEL);
+	bitbang = devm_kzalloc(dev, sizeof(struct bb_info), GFP_KERNEL);
 	if (!bitbang) {
 		ret = -ENOMEM;
 		goto out;
@@ -2638,8 +2638,7 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 		 mdp->pdev->name, id);
 
 	/* PHY IRQ */
-	mdp->mii_bus->irq = devm_kzalloc(&ndev->dev,
-					 sizeof(int) * PHY_MAX_ADDR,
+	mdp->mii_bus->irq = devm_kzalloc(dev, sizeof(int) * PHY_MAX_ADDR,
 					 GFP_KERNEL);
 	if (!mdp->mii_bus->irq) {
 		ret = -ENOMEM;
-- 
1.8.3.2
