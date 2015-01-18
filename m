From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 1/2] bgmac: register napi before the device
Date: Sun, 18 Jan 2015 19:49:58 +0100
Message-ID: <1421606999-23692-2-git-send-email-hauke@hauke-m.de>
References: <1421606999-23692-1-git-send-email-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, Hauke Mehrtens <hauke@hauke-m.de>
To: zajec5@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:33042 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbbARSum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2015 13:50:42 -0500
In-Reply-To: <1421606999-23692-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

napi should get registered before the netdev and not after.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 05c6af6..aa9f950 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1515,6 +1515,8 @@ static int bgmac_probe(struct bcma_device *core)
 	if (core->bus->sprom.boardflags_lo & BGMAC_BFL_ENETADM)
 		bgmac_warn(bgmac, "Support for ADMtek ethernet switch not implemented\n");
 
+	netif_napi_add(net_dev, &bgmac->napi, bgmac_poll, BGMAC_WEIGHT);
+
 	err = bgmac_mii_register(bgmac);
 	if (err) {
 		bgmac_err(bgmac, "Cannot register MDIO\n");
@@ -1529,8 +1531,6 @@ static int bgmac_probe(struct bcma_device *core)
 
 	netif_carrier_off(net_dev);
 
-	netif_napi_add(net_dev, &bgmac->napi, bgmac_poll, BGMAC_WEIGHT);
-
 	return 0;
 
 err_mii_unregister:
@@ -1549,9 +1549,9 @@ static void bgmac_remove(struct bcma_device *core)
 {
 	struct bgmac *bgmac = bcma_get_drvdata(core);
 
-	netif_napi_del(&bgmac->napi);
 	unregister_netdev(bgmac->net_dev);
 	bgmac_mii_unregister(bgmac);
+	netif_napi_del(&bgmac->napi);
 	bgmac_dma_free(bgmac);
 	bcma_set_drvdata(core, NULL);
 	free_netdev(bgmac->net_dev);
-- 
1.9.1
