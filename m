From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/32] sfc: QT202x: Reset before reading PHY id
Date: Sat, 28 Nov 2009 03:44:02 +0000
Message-ID: <1259379842.2811.9.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42367 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600AbZK1Dn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:43:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Reading standard registers on the QT2025C before its firmware has
booted may cause the boot process to fail.  Therefore, follow the
recommended reset sequence before reading its id registers.  Either
order works for the QT2022C2, so don't differentiate.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/qt202x_phy.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 1b174c3..3d7370e 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -138,33 +138,27 @@ static int qt202x_reset_phy(struct efx_nic *efx)
 static int qt202x_phy_init(struct efx_nic *efx)
 {
 	struct qt202x_phy_data *phy_data;
-	u32 devid = efx_mdio_read_id(efx, MDIO_MMD_PHYXS);
+	u32 devid;
 	int rc;
 
+	rc = qt202x_reset_phy(efx);
+	if (rc) {
+		EFX_ERR(efx, "PHY init failed\n");
+		return rc;
+	}
+
 	phy_data = kzalloc(sizeof(struct qt202x_phy_data), GFP_KERNEL);
 	if (!phy_data)
 		return -ENOMEM;
 	efx->phy_data = phy_data;
 
+	devid = efx_mdio_read_id(efx, MDIO_MMD_PHYXS);
 	EFX_INFO(efx, "PHY ID reg %x (OUI %06x model %02x revision %x)\n",
 		 devid, efx_mdio_id_oui(devid), efx_mdio_id_model(devid),
 		 efx_mdio_id_rev(devid));
 
 	phy_data->phy_mode = efx->phy_mode;
-
-	rc = qt202x_reset_phy(efx);
-
-	EFX_INFO(efx, "PHY init %s.\n",
-		 rc ? "failed" : "successful");
-	if (rc < 0)
-		goto fail;
-
 	return 0;
-
- fail:
-	kfree(efx->phy_data);
-	efx->phy_data = NULL;
-	return rc;
 }
 
 static int qt202x_link_ok(struct efx_nic *efx)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

