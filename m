From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2 4/5] bgmac: reset all cores on Northstar SoC
Date: Sat,  4 Jan 2014 19:13:57 +0100
Message-ID: <1388859238-22808-5-git-send-email-hauke@hauke-m.de>
References: <1388859238-22808-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:59473 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754987AbaADSOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 13:14:33 -0500
In-Reply-To: <1388859238-22808-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the Northstar SoC (BCM4707 and BCM53018) we have to enable all GMAC
cores when we just want to use on. We iterate over all the cores and
activate them.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 88ec69e..2cdacb8 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1446,6 +1446,27 @@ static int bgmac_probe(struct bcma_device *core)
 
 	bgmac_chip_reset(bgmac);
 
+	/* For Northstar, we have to take all GMAC core out of reset */
+	if (core->id.id == BCMA_CHIP_ID_BCM4707 ||
+	    core->id.id == BCMA_CHIP_ID_BCM53018) {
+		struct bcma_device *ns_core;
+		int ns_gmac;
+
+		/* Northstar has 4 GMAC cores */
+		for (ns_gmac = 0; ns_gmac < 4; ns_gmac++) {
+			/* As northstar requirement, we have to reset all GAMCs
+			 * before accessing one. bgmac_chip_reset() call
+			 * bcma_core_enable() for this core. Then the other
+			 * three GAMCs didn't reset.  We do it here.
+			 */
+			ns_core = bcma_find_core_unit(core->bus,
+						      BCMA_CORE_MAC_GBIT,
+						      ns_gmac);
+			if (ns_core && !bcma_core_is_enabled(ns_core))
+				bcma_core_enable(ns_core, 0);
+		}
+	}
+
 	err = bgmac_dma_alloc(bgmac);
 	if (err) {
 		bgmac_err(bgmac, "Unable to alloc memory for DMA\n");
-- 
1.7.10.4
