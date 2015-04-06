From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 3/4] via-rhine: gotoize rhine_open error path.
Date: Mon,  6 Apr 2015 20:01:51 +0200
Message-ID: <f376fac9f517494f08e024d28110d42135f41773.1428340371.git.romieu@fr.zoreil.com>
References: <cover.1428340371.git.romieu@fr.zoreil.com>
Cc: "Nix" <nix@esperi.org.uk>, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, "Bjarke Istrup Pedersen" <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50041 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbbDFSCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 14:02:15 -0400
In-Reply-To: <cover.1428340371.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1428340371.git.romieu@fr.zoreil.com>
References: <cover.1428340371.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index cf8dfcd..ae1ab6b 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1684,15 +1684,14 @@ static int rhine_open(struct net_device *dev)
 
 	rc = request_irq(rp->irq, rhine_interrupt, IRQF_SHARED, dev->name, dev);
 	if (rc)
-		return rc;
+		goto out;
 
 	netif_dbg(rp, ifup, dev, "%s() irq %d\n", __func__, rp->irq);
 
 	rc = alloc_ring(dev);
-	if (rc) {
-		free_irq(rp->irq, dev);
-		return rc;
-	}
+	if (rc < 0)
+		goto out_free_irq;
+
 	alloc_rbufs(dev);
 	alloc_tbufs(dev);
 	rhine_chip_reset(dev);
@@ -1705,7 +1704,12 @@ static int rhine_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 
-	return 0;
+out:
+	return rc;
+
+out_free_irq:
+	free_irq(rp->irq, dev);
+	goto out;
 }
 
 static void rhine_reset_task(struct work_struct *work)
-- 
2.1.0
