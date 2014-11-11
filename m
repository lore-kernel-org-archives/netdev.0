From: Johan Hovold <johan@kernel.org>
Subject: [RFC 22/22] net: phy: micrel: use generic config_init for KSZ8021/KSZ8031
Date: Tue, 11 Nov 2014 18:37:40 +0100
Message-ID: <1415727460-20417-23-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>,
	Bruno Thomsen <bth@kamstrup.dk>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:50190 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbaKKRis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 12:38:48 -0500
In-Reply-To: <1415727460-20417-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use generic config_init callback also for KSZ8021 and KSZ8031.

This has been avoided this far due to commit a95a18afe4c8 ("phy/micrel:
KSZ8031RNL RMII clock reconfiguration bug"), which claims that the PHY
becomes unresponsive if the broadcast disable flag is set before
configuring the clock mode.

Disabling the broadcast address in generally the first think you want to
do, and if PHY 0 is probed first, this will disable the broadcast
address for all (Micrel) PHYs on the bus and prevent unnecessary
reconfigurations. Note that if parallel probing is ever allowed, this
will be a requirement.

Cc: Bruno Thomsen <bth@kamstrup.dk>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 3b89548e6063..bbd1c9ea0cbf 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -88,6 +88,7 @@ struct kszphy_priv {
 
 static const struct kszphy_type ksz8021_type = {
 	.led_mode_reg		= MII_KSZPHY_CTRL_2,
+	.has_broadcast_disable	= true,
 	.has_rmii_ref_clk_sel	= true,
 };
 
@@ -258,19 +259,6 @@ static int kszphy_config_init(struct phy_device *phydev)
 	return 0;
 }
 
-static int ksz8021_config_init(struct phy_device *phydev)
-{
-	int rc;
-
-	rc = kszphy_config_init(phydev);
-	if (rc)
-		return rc;
-
-	rc = kszphy_broadcast_disable(phydev);
-
-	return rc < 0 ? rc : 0;
-}
-
 static int ksz9021_load_values_from_of(struct phy_device *phydev,
 				       struct device_node *of_node, u16 reg,
 				       char *field1, char *field2,
@@ -584,7 +572,7 @@ static struct phy_driver ksphy_driver[] = {
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8021_type,
 	.probe		= kszphy_probe,
-	.config_init	= ksz8021_config_init,
+	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
@@ -601,7 +589,7 @@ static struct phy_driver ksphy_driver[] = {
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8021_type,
 	.probe		= kszphy_probe,
-	.config_init	= ksz8021_config_init,
+	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
-- 
2.0.4
