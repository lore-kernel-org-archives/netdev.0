From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v3 1/2] net: ethoc: Fix early error paths
Date: Tue, 12 Jul 2016 16:04:35 -0700
Message-ID: <1468364676-19242-2-git-send-email-f.fainelli@gmail.com>
References: <1468364676-19242-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jcmvbkbc@gmail.com, colin.king@canonical.com,
	tklauser@distanz.ch, thierry.reding@gmail.com, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33387 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbcGLXFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 19:05:10 -0400
Received: by mail-pf0-f195.google.com with SMTP id i6so1606443pfe.0
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 16:05:09 -0700 (PDT)
In-Reply-To: <1468364676-19242-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case any operation fails before we can successfully go the point
where we would register a MDIO bus, we would be going to an error label
which involves unregistering then freeing this yet to be created MDIO
bus. Update all error paths to go to label free which is the only one
valid until either the clock is enabled, or the MDIO bus is allocated
and registered. This fixes kernel oops observed while trying to
dereference the MDIO bus structure which is not yet allocated.

Fixes: a1702857724f ("net: Add support for the OpenCores 10/100 Mbps Ethernet MAC.")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 4edb98c3c6c7..06ae14a8e946 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1086,7 +1086,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	if (!priv->iobase) {
 		dev_err(&pdev->dev, "cannot remap I/O memory space\n");
 		ret = -ENXIO;
-		goto error;
+		goto free;
 	}
 
 	if (netdev->mem_end) {
@@ -1095,7 +1095,7 @@ static int ethoc_probe(struct platform_device *pdev)
 		if (!priv->membase) {
 			dev_err(&pdev->dev, "cannot remap memory space\n");
 			ret = -ENXIO;
-			goto error;
+			goto free;
 		}
 	} else {
 		/* Allocate buffer memory */
@@ -1106,7 +1106,7 @@ static int ethoc_probe(struct platform_device *pdev)
 			dev_err(&pdev->dev, "cannot allocate %dB buffer\n",
 				buffer_size);
 			ret = -ENOMEM;
-			goto error;
+			goto free;
 		}
 		netdev->mem_end = netdev->mem_start + buffer_size;
 		priv->dma_alloc = buffer_size;
@@ -1120,7 +1120,7 @@ static int ethoc_probe(struct platform_device *pdev)
 		128, (netdev->mem_end - netdev->mem_start + 1) / ETHOC_BUFSIZ);
 	if (num_bd < 4) {
 		ret = -ENODEV;
-		goto error;
+		goto free;
 	}
 	priv->num_bd = num_bd;
 	/* num_tx must be a power of two */
@@ -1133,7 +1133,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	priv->vma = devm_kzalloc(&pdev->dev, num_bd*sizeof(void *), GFP_KERNEL);
 	if (!priv->vma) {
 		ret = -ENOMEM;
-		goto error;
+		goto free;
 	}
 
 	/* Allow the platform setup code to pass in a MAC address. */
-- 
2.7.4
