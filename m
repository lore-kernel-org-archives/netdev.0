From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH] net: mvneta: enable features before registering the driver
Date: Sat, 6 Apr 2013 20:47:01 +0200
Message-ID: <20130406184701.GA16142@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thomas.petazzoni@free-electrons.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:46479 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761703Ab3DFSrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 14:47:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I noticed that mvneta's tx-csum/sg were off until disabled then
enabled, which led me to think that something was not made in the
correct sequence. And indeed, setting the dev features _before_
registering the device works much better :-)

This patch is for master but may be backported to 3.8-stable as well,
which is where I first experienced the issue.

Thanks,
Willy

>From 005eb7594a4304eed5e9b427ca6b745260c9eded Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Mon, 11 Mar 2013 07:56:58 +0100
Subject: [PATCH] net: mvneta: enable features before registering the driver,
 not after

It seems that the reason why the dev features were ignored was because
they were enabled after registeration.

Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 drivers/net/ethernet/marvell/mvneta.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index cd345b8..1e628ce 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2771,16 +2771,17 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	netif_napi_add(dev, &pp->napi, mvneta_poll, pp->weight);
 
+	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->hw_features |= NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->vlan_features |= NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->priv_flags |= IFF_UNICAST_FLT;
+
 	err = register_netdev(dev);
 	if (err < 0) {
 		dev_err(&pdev->dev, "failed to register\n");
 		goto err_deinit;
 	}
 
-	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
-	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM;
-	dev->priv_flags |= IFF_UNICAST_FLT;
-
 	netdev_info(dev, "mac: %pM\n", dev->dev_addr);
 
 	platform_set_drvdata(pdev, pp->dev);
-- 
1.7.12.2.21.g234cd45.dirty
