From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/3] sfc: 10Xpress: Initialise pause advertising flags
Date: Mon, 12 Oct 2009 20:27:07 +0100
Message-ID: <1255375627.2931.15.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43796 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757979AbZJLT12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 15:27:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mdio module now handles reconfiguration of pause advertising
through ethtool, but not initialisation.  Add the necessary
initialisation to tenxpress_phy_init().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tenxpress.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index f4d5090..1a3495c 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -301,6 +301,7 @@ static int tenxpress_init(struct efx_nic *efx)
 static int tenxpress_phy_init(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data;
+	u16 old_adv, adv;
 	int rc = 0;
 
 	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);
@@ -333,6 +334,15 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	if (rc < 0)
 		goto fail;
 
+	/* Set pause advertising */
+	old_adv = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE);
+	adv = ((old_adv & ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM)) |
+	       mii_advertise_flowctrl(efx->wanted_fc));
+	if (adv != old_adv) {
+		efx_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, adv);
+		mdio45_nway_restart(&efx->mdio);
+	}
+
 	if (efx->phy_type == PHY_TYPE_SFT9001B) {
 		rc = device_create_file(&efx->pci_dev->dev,
 					&dev_attr_phy_short_reach);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

