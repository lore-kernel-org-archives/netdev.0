From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 8/8] sfc: Implement module EEPROM access for
 SFE4002 and SFN4112F
Date: Thu, 10 May 2012 03:32:37 +0100
Message-ID: <1336617157.2499.41.camel@bwh-desktop.uk.solarflarecom.com>
References: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51925 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753319Ab2EJCck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:32:40 -0400
In-Reply-To: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/qt202x_phy.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/qt202x_phy.c b/drivers/net/ethernet/sfc/qt202x_phy.c
index 8a7caf88..326a286 100644
--- a/drivers/net/ethernet/sfc/qt202x_phy.c
+++ b/drivers/net/ethernet/sfc/qt202x_phy.c
@@ -449,6 +449,37 @@ static void qt202x_phy_remove(struct efx_nic *efx)
 	efx->phy_data = NULL;
 }
 
+static int qt202x_phy_get_module_info(struct efx_nic *efx,
+				      struct ethtool_modinfo *modinfo)
+{
+	modinfo->type = ETH_MODULE_SFF_8079;
+	modinfo->eeprom_len = ETH_MODULE_SFF_8079_LEN;
+	return 0;
+}
+
+static int qt202x_phy_get_module_eeprom(struct efx_nic *efx,
+					struct ethtool_eeprom *ee, u8 *data)
+{
+	int mmd, reg_base, rc, i;		
+
+	if (efx->phy_type == PHY_TYPE_QT2025C) {
+		mmd = MDIO_MMD_PCS;
+		reg_base = 0xd000;
+	} else {
+		mmd = MDIO_MMD_PMAPMD;
+		reg_base = 0x8007;
+	}
+
+	for (i = 0; i < ee->len; i++) {
+		rc = efx_mdio_read(efx, mmd, reg_base + ee->offset + i);
+		if (rc < 0)
+			return rc;
+		data[i] = rc;
+	}
+
+	return 0;
+}
+
 const struct efx_phy_operations falcon_qt202x_phy_ops = {
 	.probe		 = qt202x_phy_probe,
 	.init		 = qt202x_phy_init,
@@ -459,4 +490,6 @@ const struct efx_phy_operations falcon_qt202x_phy_ops = {
 	.get_settings	 = qt202x_phy_get_settings,
 	.set_settings	 = efx_mdio_set_settings,
 	.test_alive	 = efx_mdio_test_alive,
+	.get_module_eeprom = qt202x_phy_get_module_eeprom,
+	.get_module_info = qt202x_phy_get_module_info,
 };
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
