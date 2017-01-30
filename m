From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2] net: aquantia: atlantic: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 30 Jan 2017 23:04:42 +0100
Message-ID: <1485813882-9887-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: Alexander.Loktionov@aquantia.com, Pavel.Belous@aquantia.com,
        davem@davemloft.net, Dmitry.Bezrukov@aquantia.com,
        vomlehn@texas.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33302 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752347AbdA3WGk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 17:06:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
Changelog:
v2:
- add support and advertise for TP

 .../net/ethernet/aquantia/atlantic/aq_ethtool.c    |   23 +++++----
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    |   51 +++++++++++++-------
 drivers/net/ethernet/aquantia/atlantic/aq_nic.h    |    6 ++-
 3 files changed, 49 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c b/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
index c5b025e..a761e91 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
@@ -35,24 +35,25 @@ static u32 aq_ethtool_get_link(struct net_device *ndev)
 	return ethtool_op_get_link(ndev);
 }
 
-static int aq_ethtool_get_settings(struct net_device *ndev,
-				   struct ethtool_cmd *cmd)
+static int aq_ethtool_get_link_ksettings(struct net_device *ndev,
+					 struct ethtool_link_ksettings *cmd)
 {
 	struct aq_nic_s *aq_nic = netdev_priv(ndev);
 
-	aq_nic_get_link_settings(aq_nic, cmd);
-	ethtool_cmd_speed_set(cmd, netif_carrier_ok(ndev) ?
-				aq_nic_get_link_speed(aq_nic) : 0U);
+	aq_nic_get_link_ksettings(aq_nic, cmd);
+	cmd->base.speed = netif_carrier_ok(ndev) ?
+				aq_nic_get_link_speed(aq_nic) : 0U;
 
 	return 0;
 }
 
-static int aq_ethtool_set_settings(struct net_device *ndev,
-				   struct ethtool_cmd *cmd)
+static int
+aq_ethtool_set_link_ksettings(struct net_device *ndev,
+			      const struct ethtool_link_ksettings *cmd)
 {
 	struct aq_nic_s *aq_nic = netdev_priv(ndev);
 
-	return aq_nic_set_link_settings(aq_nic, cmd);
+	return aq_nic_set_link_ksettings(aq_nic, cmd);
 }
 
 /* there "5U" is number of queue[#] stats lines (InPackets+...+InErrors) */
@@ -248,8 +249,6 @@ static int aq_ethtool_get_rxnfc(struct net_device *ndev,
 	.get_link            = aq_ethtool_get_link,
 	.get_regs_len        = aq_ethtool_get_regs_len,
 	.get_regs            = aq_ethtool_get_regs,
-	.get_settings        = aq_ethtool_get_settings,
-	.set_settings        = aq_ethtool_set_settings,
 	.get_drvinfo         = aq_ethtool_get_drvinfo,
 	.get_strings         = aq_ethtool_get_strings,
 	.get_rxfh_indir_size = aq_ethtool_get_rss_indir_size,
@@ -257,5 +256,7 @@ static int aq_ethtool_get_rxnfc(struct net_device *ndev,
 	.get_rxfh            = aq_ethtool_get_rss,
 	.get_rxnfc           = aq_ethtool_get_rxnfc,
 	.get_sset_count      = aq_ethtool_get_sset_count,
-	.get_ethtool_stats   = aq_ethtool_stats
+	.get_ethtool_stats   = aq_ethtool_stats,
+	.get_link_ksettings  = aq_ethtool_get_link_ksettings,
+	.set_link_ksettings  = aq_ethtool_set_link_ksettings,
 };
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 84bb441..bed25ab 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -734,50 +734,65 @@ void aq_nic_get_stats(struct aq_nic_s *self, u64 *data)
 	(void)err;
 }
 
-void aq_nic_get_link_settings(struct aq_nic_s *self, struct ethtool_cmd *cmd)
+void aq_nic_get_link_ksettings(struct aq_nic_s *self,
+			       struct ethtool_link_ksettings *cmd)
 {
-	cmd->port = PORT_TP;
-	cmd->transceiver = XCVR_EXTERNAL;
+	u32 supported, advertising;
+
+	cmd->base.port = PORT_TP;
 	/* This driver supports only 10G capable adapters, so DUPLEX_FULL */
-	cmd->duplex = DUPLEX_FULL;
-	cmd->autoneg = self->aq_nic_cfg.is_autoneg;
+	cmd->base.duplex = DUPLEX_FULL;
+	cmd->base.autoneg = self->aq_nic_cfg.is_autoneg;
+
+	ethtool_convert_link_mode_to_legacy_u32(&supported,
+						cmd->link_modes.supported);
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
-	cmd->supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_10G) ?
+	supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_10G) ?
 				ADVERTISED_10000baseT_Full : 0U;
-	cmd->supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_1G) ?
+	supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_1G) ?
 				ADVERTISED_1000baseT_Full : 0U;
-	cmd->supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_100M) ?
+	supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_100M) ?
 				ADVERTISED_100baseT_Full : 0U;
-	cmd->supported |= self->aq_hw_caps.flow_control ? SUPPORTED_Pause : 0;
-	cmd->supported |= SUPPORTED_Autoneg;
+	supported |= self->aq_hw_caps.flow_control ? SUPPORTED_Pause : 0;
+	supported |= SUPPORTED_Autoneg;
+	supported |= SUPPORTED_TP;
 
-	cmd->advertising = (self->aq_nic_cfg.is_autoneg) ?
+	advertising = (self->aq_nic_cfg.is_autoneg) ?
 							ADVERTISED_Autoneg : 0U;
-	cmd->advertising |=
+	advertising |=
 			(self->aq_nic_cfg.link_speed_msk & AQ_NIC_RATE_10G) ?
 			ADVERTISED_10000baseT_Full : 0U;
-	cmd->advertising |=
+	advertising |=
 			(self->aq_nic_cfg.link_speed_msk & AQ_NIC_RATE_1G) ?
 			ADVERTISED_1000baseT_Full : 0U;
 
-	cmd->advertising |=
+	advertising |=
 			(self->aq_nic_cfg.link_speed_msk & AQ_NIC_RATE_100M) ?
 			ADVERTISED_100baseT_Full : 0U;
-	cmd->advertising |= (self->aq_nic_cfg.flow_control) ?
+	advertising |= (self->aq_nic_cfg.flow_control) ?
 				ADVERTISED_Pause : 0U;
+	advertising |= ADVERTISED_TP;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 }
 
-int aq_nic_set_link_settings(struct aq_nic_s *self, struct ethtool_cmd *cmd)
+int aq_nic_set_link_ksettings(struct aq_nic_s *self,
+			      const struct ethtool_link_ksettings *cmd)
 {
 	u32 speed = 0U;
 	u32 rate = 0U;
 	int err = 0;
 
-	if (cmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		rate = self->aq_hw_caps.link_speed_msk;
 		self->aq_nic_cfg.is_autoneg = true;
 	} else {
-		speed = ethtool_cmd_speed(cmd);
+		speed = cmd->base.speed;
 
 		switch (speed) {
 		case SPEED_100:
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.h b/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
index 055e2cd..7fc2a5e 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
@@ -99,8 +99,10 @@ void aq_nic_set_tx_ring(struct aq_nic_s *self, unsigned int idx,
 int aq_nic_set_packet_filter(struct aq_nic_s *self, unsigned int flags);
 int aq_nic_set_multicast_list(struct aq_nic_s *self, struct net_device *ndev);
 unsigned int aq_nic_get_link_speed(struct aq_nic_s *self);
-void aq_nic_get_link_settings(struct aq_nic_s *self, struct ethtool_cmd *cmd);
-int aq_nic_set_link_settings(struct aq_nic_s *self, struct ethtool_cmd *cmd);
+void aq_nic_get_link_ksettings(struct aq_nic_s *self,
+			       struct ethtool_link_ksettings *cmd);
+int aq_nic_set_link_ksettings(struct aq_nic_s *self,
+			      const struct ethtool_link_ksettings *cmd);
 struct aq_nic_cfg_s *aq_nic_get_cfg(struct aq_nic_s *self);
 u32 aq_nic_get_fw_version(struct aq_nic_s *self);
 int aq_nic_change_pm_state(struct aq_nic_s *self, pm_message_t *pm_msg);
-- 
1.7.4.4
