From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 08/10] s390/qeth: convert to ETHTOOL_GLINKSETTINGS API
Date: Tue, 11 Apr 2017 16:11:17 +0200
Message-ID: <20170411141119.82526-9-jwi@linux.vnet.ibm.com>
References: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53655 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753467AbdDKOLv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:11:51 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3BE8vO2146970
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:46 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29rf064mqs-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:46 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 15:11:43 +0100
In-Reply-To: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

get_settings() is deprecated and lacks support for higher link
speeds, so implement get_link_ksettings() instead.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  3 +-
 drivers/s390/net/qeth_core_main.c | 75 +++++++++++++++++++--------------------
 drivers/s390/net/qeth_l2_main.c   |  2 +-
 drivers/s390/net/qeth_l3_main.c   |  2 +-
 4 files changed, 40 insertions(+), 42 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 760f752034e4..a634ec2a08f3 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -958,7 +958,8 @@ void qeth_core_get_ethtool_stats(struct net_device *,
 void qeth_core_get_strings(struct net_device *, u32, u8 *);
 void qeth_core_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
 void qeth_dbf_longtext(debug_info_t *id, int level, char *text, ...);
-int qeth_core_ethtool_get_settings(struct net_device *, struct ethtool_cmd *);
+int qeth_core_ethtool_get_link_ksettings(struct net_device *netdev,
+					 struct ethtool_link_ksettings *cmd);
 int qeth_set_access_ctrl_online(struct qeth_card *card, int fallback);
 int qeth_hdr_chk_and_bounce(struct sk_buff *, struct qeth_hdr **, int);
 int qeth_configure_cq(struct qeth_card *, enum qeth_cq);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 41fe9631e24e..4304bc2a6620 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -6028,7 +6028,7 @@ EXPORT_SYMBOL_GPL(qeth_core_get_drvinfo);
 /* Autoneg and full-duplex are supported and advertised unconditionally.     */
 /* Always advertise and support all speeds up to specified, and only one     */
 /* specified port type.							     */
-static void qeth_set_ecmd_adv_sup(struct ethtool_cmd *ecmd,
+static void qeth_set_cmd_adv_sup(struct ethtool_link_ksettings *cmd,
 				int maxspeed, int porttype)
 {
 	u32 sup, adv;
@@ -6072,55 +6072,53 @@ static void qeth_set_ecmd_adv_sup(struct ethtool_cmd *ecmd,
 		adv |= ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full;
 		WARN_ON_ONCE(1);
 	}
-	ecmd->supported = sup;
-	ecmd->advertising = adv;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						sup);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						adv);
 }
 
-int qeth_core_ethtool_get_settings(struct net_device *netdev,
-					struct ethtool_cmd *ecmd)
+int qeth_core_ethtool_get_link_ksettings(struct net_device *netdev,
+		struct ethtool_link_ksettings *cmd)
 {
 	struct qeth_card *card = netdev->ml_priv;
 	enum qeth_link_types link_type;
 	struct carrier_info carrier_info;
 	int rc;
-	u32 speed;
 
 	if ((card->info.type == QETH_CARD_TYPE_IQD) || (card->info.guestlan))
 		link_type = QETH_LINK_TYPE_10GBIT_ETH;
 	else
 		link_type = card->info.link_type;
 
-	ecmd->transceiver = XCVR_INTERNAL;
-	ecmd->duplex = DUPLEX_FULL;
-	ecmd->autoneg = AUTONEG_ENABLE;
+	cmd->base.duplex = DUPLEX_FULL;
+	cmd->base.autoneg = AUTONEG_ENABLE;
+	cmd->base.phy_address = 0;
+	cmd->base.mdio_support = 0;
+	cmd->base.eth_tp_mdix = ETH_TP_MDI_INVALID;
+	cmd->base.eth_tp_mdix_ctrl = ETH_TP_MDI_INVALID;
 
 	switch (link_type) {
 	case QETH_LINK_TYPE_FAST_ETH:
 	case QETH_LINK_TYPE_LANE_ETH100:
-		qeth_set_ecmd_adv_sup(ecmd, SPEED_100, PORT_TP);
-		speed = SPEED_100;
-		ecmd->port = PORT_TP;
+		cmd->base.speed = SPEED_100;
+		cmd->base.port = PORT_TP;
 		break;
-
 	case QETH_LINK_TYPE_GBIT_ETH:
 	case QETH_LINK_TYPE_LANE_ETH1000:
-		qeth_set_ecmd_adv_sup(ecmd, SPEED_1000, PORT_FIBRE);
-		speed = SPEED_1000;
-		ecmd->port = PORT_FIBRE;
+		cmd->base.speed = SPEED_1000;
+		cmd->base.port = PORT_FIBRE;
 		break;
-
 	case QETH_LINK_TYPE_10GBIT_ETH:
-		qeth_set_ecmd_adv_sup(ecmd, SPEED_10000, PORT_FIBRE);
-		speed = SPEED_10000;
-		ecmd->port = PORT_FIBRE;
+		cmd->base.speed = SPEED_10000;
+		cmd->base.port = PORT_FIBRE;
 		break;
-
 	default:
-		qeth_set_ecmd_adv_sup(ecmd, SPEED_10, PORT_TP);
-		speed = SPEED_10;
-		ecmd->port = PORT_TP;
+		cmd->base.speed = SPEED_10;
+		cmd->base.port = PORT_TP;
 	}
-	ethtool_cmd_speed_set(ecmd, speed);
+	qeth_set_cmd_adv_sup(cmd, cmd->base.speed, cmd->base.port);
 
 	/* Check if we can obtain more accurate information.	 */
 	/* If QUERY_CARD_INFO command is not supported or fails, */
@@ -6145,49 +6143,48 @@ int qeth_core_ethtool_get_settings(struct net_device *netdev,
 	switch (carrier_info.card_type) {
 	case CARD_INFO_TYPE_1G_COPPER_A:
 	case CARD_INFO_TYPE_1G_COPPER_B:
-		qeth_set_ecmd_adv_sup(ecmd, SPEED_1000, PORT_TP);
-		ecmd->port = PORT_TP;
+		cmd->base.port = PORT_TP;
+		qeth_set_cmd_adv_sup(cmd, SPEED_1000, cmd->base.port);
 		break;
 	case CARD_INFO_TYPE_1G_FIBRE_A:
 	case CARD_INFO_TYPE_1G_FIBRE_B:
-		qeth_set_ecmd_adv_sup(ecmd, SPEED_1000, PORT_FIBRE);
-		ecmd->port = PORT_FIBRE;
+		cmd->base.port = PORT_FIBRE;
+		qeth_set_cmd_adv_sup(cmd, SPEED_1000, cmd->base.port);
 		break;
 	case CARD_INFO_TYPE_10G_FIBRE_A:
 	case CARD_INFO_TYPE_10G_FIBRE_B:
-		qeth_set_ecmd_adv_sup(ecmd, SPEED_10000, PORT_FIBRE);
-		ecmd->port = PORT_FIBRE;
+		cmd->base.port = PORT_FIBRE;
+		qeth_set_cmd_adv_sup(cmd, SPEED_10000, cmd->base.port);
 		break;
 	}
 
 	switch (carrier_info.port_mode) {
 	case CARD_INFO_PORTM_FULLDUPLEX:
-		ecmd->duplex = DUPLEX_FULL;
+		cmd->base.duplex = DUPLEX_FULL;
 		break;
 	case CARD_INFO_PORTM_HALFDUPLEX:
-		ecmd->duplex = DUPLEX_HALF;
+		cmd->base.duplex = DUPLEX_HALF;
 		break;
 	}
 
 	switch (carrier_info.port_speed) {
 	case CARD_INFO_PORTS_10M:
-		speed = SPEED_10;
+		cmd->base.speed = SPEED_10;
 		break;
 	case CARD_INFO_PORTS_100M:
-		speed = SPEED_100;
+		cmd->base.speed = SPEED_100;
 		break;
 	case CARD_INFO_PORTS_1G:
-		speed = SPEED_1000;
+		cmd->base.speed = SPEED_1000;
 		break;
 	case CARD_INFO_PORTS_10G:
-		speed = SPEED_10000;
+		cmd->base.speed = SPEED_10000;
 		break;
 	}
-	ethtool_cmd_speed_set(ecmd, speed);
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(qeth_core_ethtool_get_settings);
+EXPORT_SYMBOL_GPL(qeth_core_ethtool_get_link_ksettings);
 
 /* Callback to handle checksum offload command reply from OSA card.
  * Verify that required features have been enabled on the card.
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 22f8eb007aa1..1b07f382d74c 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -917,7 +917,7 @@ static const struct ethtool_ops qeth_l2_ethtool_ops = {
 	.get_ethtool_stats = qeth_core_get_ethtool_stats,
 	.get_sset_count = qeth_core_get_sset_count,
 	.get_drvinfo = qeth_core_get_drvinfo,
-	.get_settings = qeth_core_ethtool_get_settings,
+	.get_link_ksettings = qeth_core_ethtool_get_link_ksettings,
 };
 
 static const struct ethtool_ops qeth_l2_osn_ops = {
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index bea0bae0faf7..6e0354ef4b86 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2912,7 +2912,7 @@ static const struct ethtool_ops qeth_l3_ethtool_ops = {
 	.get_ethtool_stats = qeth_core_get_ethtool_stats,
 	.get_sset_count = qeth_core_get_sset_count,
 	.get_drvinfo = qeth_core_get_drvinfo,
-	.get_settings = qeth_core_ethtool_get_settings,
+	.get_link_ksettings = qeth_core_ethtool_get_link_ksettings,
 };
 
 /*
-- 
2.10.2
