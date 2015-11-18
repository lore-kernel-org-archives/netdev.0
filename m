From: jon@ringle.org
Subject: [PATCH net-next] net: encx24j600: move rev announcement to probe function
Date: Wed, 18 Nov 2015 16:22:21 -0500
Message-ID: <1447881741-30386-1-git-send-email-jon@ringle.org>
Cc: Jon Ringle <jringle@gridpoint.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:33746 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756831AbbKRVW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 16:22:27 -0500
Received: by qgea14 with SMTP id a14so38243933qge.0
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 13:22:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Ringle <jringle@gridpoint.com>

When encx24j600 is open and closed many times due to userspace polling the
interface, the log gets noise with this log message.

Moving this to encx24j600_spi_probe function where it belongs.

Signed-off-by: Jon Ringle <jringle@gridpoint.com>
---
 drivers/net/ethernet/microchip/encx24j600.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index bf08ce2..f13c489 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -600,22 +600,11 @@ static void encx24j600_set_rxfilter_mode(struct encx24j600_priv *priv)
 
 static int encx24j600_hw_init(struct encx24j600_priv *priv)
 {
-	struct net_device *dev = priv->ndev;
 	int ret = 0;
-	u16 eidled;
 	u16 macon2;
 
 	priv->hw_enabled = false;
 
-	eidled = encx24j600_read_reg(priv, EIDLED);
-	if (((eidled & DEVID_MASK) >> DEVID_SHIFT) != ENCX24J600_DEV_ID) {
-		ret = -EINVAL;
-		goto err_out;
-	}
-
-	netif_info(priv, drv, dev, "Silicon rev ID: 0x%02x\n",
-		   (eidled & REVID_MASK) >> REVID_SHIFT);
-
 	/* PHY Leds: link status,
 	 * LEDA: Link State + collision events
 	 * LEDB: Link State + transmit/receive events
@@ -655,7 +644,6 @@ static int encx24j600_hw_init(struct encx24j600_priv *priv)
 	if (netif_msg_hw(priv))
 		encx24j600_dump_config(priv, "Hw is initialized");
 
-err_out:
 	return ret;
 }
 
@@ -1004,6 +992,7 @@ static int encx24j600_spi_probe(struct spi_device *spi)
 
 	struct net_device *ndev;
 	struct encx24j600_priv *priv;
+	u16 eidled;
 
 	ndev = alloc_etherdev(sizeof(struct encx24j600_priv));
 
@@ -1072,10 +1061,21 @@ static int encx24j600_spi_probe(struct spi_device *spi)
 		goto out_free;
 	}
 
+	eidled = encx24j600_read_reg(priv, EIDLED);
+	if (((eidled & DEVID_MASK) >> DEVID_SHIFT) != ENCX24J600_DEV_ID) {
+		ret = -EINVAL;
+		goto out_unregister;
+	}
+
+	netif_info(priv, probe, ndev, "Silicon rev ID: 0x%02x\n",
+		   (eidled & REVID_MASK) >> REVID_SHIFT);
+
 	netif_info(priv, drv, priv->ndev, "MAC address %pM\n", ndev->dev_addr);
 
 	return ret;
 
+out_unregister:
+	unregister_netdev(priv->ndev);
 out_free:
 	free_netdev(ndev);
 
-- 
2.4.1
