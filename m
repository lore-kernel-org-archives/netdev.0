From: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Subject: [PATCH 5/5] sh_eth: Remove goto statements that jump straight to a return
Date: Thu, 20 Mar 2014 15:00:35 +0100
Message-ID: <1395324035-22918-6-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1395324035-22918-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Cc: linux-sh@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perceval.ideasonboard.com ([95.142.166.194]:33932 "EHLO
	perceval.ideasonboard.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755769AbaCTN6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 09:58:53 -0400
In-Reply-To: <1395324035-22918-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"goto" is well accepted for error paths in the kernel but should not be
used unnecessarily. Return the correct value directly instead of using a
goto when possible.

Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/renesas/sh_eth.c | 30 +++++++++---------------------
 1 file changed, 9 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index ace6da2..e4bff18 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -873,7 +873,7 @@ static int sh_eth_reset(struct net_device *ndev)
 
 		ret = sh_eth_check_reset(ndev);
 		if (ret)
-			goto out;
+			return ret;
 
 		/* Table Init */
 		sh_eth_write(ndev, 0x0, TDLAR);
@@ -900,7 +900,6 @@ static int sh_eth_reset(struct net_device *ndev)
 			     EDMR);
 	}
 
-out:
 	return ret;
 }
 
@@ -1264,7 +1263,7 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
 	/* Soft Reset */
 	ret = sh_eth_reset(ndev);
 	if (ret)
-		goto out;
+		return ret;
 
 	if (mdp->cd->rmiimode)
 		sh_eth_write(ndev, 0x1, RMIIMODE);
@@ -1343,7 +1342,6 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
 		netif_start_queue(ndev);
 	}
 
-out:
 	return ret;
 }
 
@@ -2605,10 +2603,8 @@ static int sh_mdio_init(struct sh_eth_private *mdp,
 
 	/* create bit control struct for PHY */
 	bitbang = devm_kzalloc(dev, sizeof(struct bb_info), GFP_KERNEL);
-	if (!bitbang) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!bitbang)
+		return -ENOMEM;
 
 	/* bitbang init */
 	bitbang->addr = mdp->addr + mdp->reg_offset[PIR];
@@ -2621,10 +2617,8 @@ static int sh_mdio_init(struct sh_eth_private *mdp,
 
 	/* MII controller setting */
 	mdp->mii_bus = alloc_mdio_bitbang(&bitbang->ctrl);
-	if (!mdp->mii_bus) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!mdp->mii_bus)
+		return -ENOMEM;
 
 	/* Hook up MII support for ethtool */
 	mdp->mii_bus->name = "sh_mii";
@@ -2659,8 +2653,6 @@ static int sh_mdio_init(struct sh_eth_private *mdp,
 
 out_free_bus:
 	free_mdio_bitbang(mdp->mii_bus);
-
-out:
 	return ret;
 }
 
@@ -2773,15 +2765,12 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (unlikely(res == NULL)) {
 		dev_err(&pdev->dev, "invalid resource\n");
-		ret = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
 
 	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
-	if (!ndev) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!ndev)
+		return -ENOMEM;
 
 	/* The sh Ether-specific entries in the device structure. */
 	ndev->base_addr = res->start;
@@ -2922,7 +2911,6 @@ out_release:
 	if (ndev)
 		free_netdev(ndev);
 
-out:
 	return ret;
 }
 
-- 
1.8.3.2
