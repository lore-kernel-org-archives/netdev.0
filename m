From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 4/8] sfc: QT2025C: Work around PHY bug
Date: Wed, 23 Dec 2009 23:47:37 +0000
Message-ID: <1261612057.2782.94.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28235 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850AbZLWXrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:47:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Slattery <mslattery@solarflare.com>

If we see the PHY remaining stuck in a link-down state due to PCS being
down while PMA/PMD is up, we briefly switch to PMA/PMD loopback and back,
which usually unsticks it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/qt202x_phy.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 7450e3a..e4590fb 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -52,11 +52,15 @@ void falcon_qt202x_set_led(struct efx_nic *p, int led, int mode)
 
 struct qt202x_phy_data {
 	enum efx_phy_mode phy_mode;
+	bool bug17190_in_bad_state;
+	unsigned long bug17190_timer;
 };
 
 #define QT2022C2_MAX_RESET_TIME 500
 #define QT2022C2_RESET_WAIT 10
 
+#define BUG17190_INTERVAL (2 * HZ)
+
 static int qt2025c_wait_reset(struct efx_nic *efx)
 {
 	unsigned long timeout = jiffies + 10 * HZ;
@@ -96,6 +100,39 @@ static int qt2025c_wait_reset(struct efx_nic *efx)
 	return 0;
 }
 
+static void qt2025c_bug17190_workaround(struct efx_nic *efx)
+{
+	struct qt202x_phy_data *phy_data = efx->phy_data;
+
+	/* The PHY can get stuck in a state where it reports PHY_XS and PMA/PMD
+	 * layers up, but PCS down (no block_lock).  If we notice this state
+	 * persisting for a couple of seconds, we switch PMA/PMD loopback
+	 * briefly on and then off again, which is normally sufficient to
+	 * recover it.
+	 */
+	if (efx->link_state.up ||
+	    !efx_mdio_links_ok(efx, MDIO_DEVS_PMAPMD | MDIO_DEVS_PHYXS)) {
+		phy_data->bug17190_in_bad_state = false;
+		return;
+	}
+
+	if (!phy_data->bug17190_in_bad_state) {
+		phy_data->bug17190_in_bad_state = true;
+		phy_data->bug17190_timer = jiffies + BUG17190_INTERVAL;
+		return;
+	}
+
+	if (time_after_eq(jiffies, phy_data->bug17190_timer)) {
+		EFX_LOG(efx, "bashing QT2025C PMA/PMD\n");
+		efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, MDIO_CTRL1,
+				  MDIO_PMA_CTRL1_LOOPBACK, true);
+		msleep(100);
+		efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, MDIO_CTRL1,
+				  MDIO_PMA_CTRL1_LOOPBACK, false);
+		phy_data->bug17190_timer = jiffies + BUG17190_INTERVAL;
+	}
+}
+
 static int qt202x_reset_phy(struct efx_nic *efx)
 {
 	int rc;
@@ -144,6 +181,8 @@ static int qt202x_phy_probe(struct efx_nic *efx)
 		return -ENOMEM;
 	efx->phy_data = phy_data;
 	phy_data->phy_mode = efx->phy_mode;
+	phy_data->bug17190_in_bad_state = false;
+	phy_data->bug17190_timer = 0;
 
 	efx->mdio.mmds = QT202X_REQUIRED_DEVS;
 	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
@@ -184,6 +223,9 @@ static bool qt202x_phy_poll(struct efx_nic *efx)
 	efx->link_state.fd = true;
 	efx->link_state.fc = efx->wanted_fc;
 
+	if (efx->phy_type == PHY_TYPE_QT2025C)
+		qt2025c_bug17190_workaround(efx);
+
 	return efx->link_state.up != was_up;
 }
 
-- 
1.5.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

