From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH] net:ethernet:aquantia: Add 2500/5000 mbit link modes support.
Date: Thu,  9 Feb 2017 23:53:10 +0300
Message-ID: <985062aeff6287805fa59f2d8a51636bc296ff47.1486672746.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0069.outbound.protection.outlook.com ([104.47.36.69]:33845
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753585AbdBIUxk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 15:53:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Using new link mode indices instead deprecated SUPPORTED_/ADVERTISED_
macro.

Added indication for 2500 and 5000mbit link modes (AQtion adapter already
supports these speeds).

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 96 +++++++++++++++----------
 1 file changed, 59 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index bed25ab..aa22a7c 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -737,48 +737,70 @@ err_exit:;
 void aq_nic_get_link_ksettings(struct aq_nic_s *self,
 			       struct ethtool_link_ksettings *cmd)
 {
-	u32 supported, advertising;
-
 	cmd->base.port = PORT_TP;
 	/* This driver supports only 10G capable adapters, so DUPLEX_FULL */
 	cmd->base.duplex = DUPLEX_FULL;
 	cmd->base.autoneg = self->aq_nic_cfg.is_autoneg;
 
-	ethtool_convert_link_mode_to_legacy_u32(&supported,
-						cmd->link_modes.supported);
-	ethtool_convert_link_mode_to_legacy_u32(&advertising,
-						cmd->link_modes.advertising);
-
-	supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_10G) ?
-				ADVERTISED_10000baseT_Full : 0U;
-	supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_1G) ?
-				ADVERTISED_1000baseT_Full : 0U;
-	supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_100M) ?
-				ADVERTISED_100baseT_Full : 0U;
-	supported |= self->aq_hw_caps.flow_control ? SUPPORTED_Pause : 0;
-	supported |= SUPPORTED_Autoneg;
-	supported |= SUPPORTED_TP;
-
-	advertising = (self->aq_nic_cfg.is_autoneg) ?
-							ADVERTISED_Autoneg : 0U;
-	advertising |=
-			(self->aq_nic_cfg.link_speed_msk & AQ_NIC_RATE_10G) ?
-			ADVERTISED_10000baseT_Full : 0U;
-	advertising |=
-			(self->aq_nic_cfg.link_speed_msk & AQ_NIC_RATE_1G) ?
-			ADVERTISED_1000baseT_Full : 0U;
-
-	advertising |=
-			(self->aq_nic_cfg.link_speed_msk & AQ_NIC_RATE_100M) ?
-			ADVERTISED_100baseT_Full : 0U;
-	advertising |= (self->aq_nic_cfg.flow_control) ?
-				ADVERTISED_Pause : 0U;
-	advertising |= ADVERTISED_TP;
-
-	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
-						supported);
-	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
-						advertising);
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+
+	if (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_10G)
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     10000baseT_Full);
+
+	if (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_5G)
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     5000baseT_Full);
+
+	if (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_2GS)
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     2500baseT_Full);
+
+	if (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_1G)
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     1000baseT_Full);
+
+	if (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_100M)
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     100baseT_Full);
+
+	if (self->aq_hw_caps.flow_control)
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     Pause);
+
+	ethtool_link_ksettings_add_link_mode(cmd, supported, Autoneg);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, TP);
+
+	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
+
+	if (self->aq_nic_cfg.is_autoneg)
+		ethtool_link_ksettings_add_link_mode(cmd, advertising, Autoneg);
+
+	if (self->aq_nic_cfg.link_speed_msk  & AQ_NIC_RATE_10G)
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     10000baseT_Full);
+
+	if (self->aq_nic_cfg.link_speed_msk  & AQ_NIC_RATE_5G)
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     5000baseT_Full);
+
+	if (self->aq_nic_cfg.link_speed_msk  & AQ_NIC_RATE_2GS)
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     2500baseT_Full);
+
+	if (self->aq_nic_cfg.link_speed_msk  & AQ_NIC_RATE_1G)
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     1000baseT_Full);
+
+	if (self->aq_nic_cfg.link_speed_msk  & AQ_NIC_RATE_100M)
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     100baseT_Full);
+
+	if (self->aq_nic_cfg.flow_control)
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     Pause);
+
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, TP);
 }
 
 int aq_nic_set_link_ksettings(struct aq_nic_s *self,
-- 
2.7.4
