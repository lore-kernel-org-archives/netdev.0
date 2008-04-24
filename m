From: frank.blaschka@de.ibm.com
Subject: [patch 06/11] qeth: provide get ethtool settings
Date: Thu, 24 Apr 2008 10:15:23 +0200
Message-ID: <20080424081905.582382000@de.ibm.com>
References: <20080424081517.987104000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:41687 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbYDXITI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:19:08 -0400
Content-Disposition: inline; filename=705-qeth-ethtool.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Load balancing bonding queries the speed of the slave interfaces.
To support a bond consisting of different slave speeds we have to
report the speed by ethtool settings.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    1 
 drivers/s390/net/qeth_core_main.c |   90 ++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/qeth_l2_main.c   |    1 
 drivers/s390/net/qeth_l3_main.c   |    1 
 4 files changed, 93 insertions(+)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2008-04-23 17:55:50.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2008-04-23 17:55:51.000000000 +0200
@@ -880,6 +880,7 @@ void qeth_core_get_ethtool_stats(struct 
 void qeth_core_get_strings(struct net_device *, u32, u8 *);
 void qeth_core_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
 void qeth_dbf_longtext(enum qeth_dbf_names dbf_nix, int level, char *text, ...);
+int qeth_core_ethtool_get_settings(struct net_device *, struct ethtool_cmd *);
 
 /* exports for OSN */
 int qeth_osn_assist(struct net_device *, void *, int);
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2008-04-23 17:55:50.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2008-04-23 17:55:51.000000000 +0200
@@ -4423,6 +4423,96 @@ void qeth_core_get_drvinfo(struct net_de
 }
 EXPORT_SYMBOL_GPL(qeth_core_get_drvinfo);
 
+int qeth_core_ethtool_get_settings(struct net_device *netdev,
+					struct ethtool_cmd *ecmd)
+{
+	struct qeth_card *card = netdev_priv(netdev);
+	enum qeth_link_types link_type;
+
+	if ((card->info.type == QETH_CARD_TYPE_IQD) || (card->info.guestlan))
+		link_type = QETH_LINK_TYPE_10GBIT_ETH;
+	else
+		link_type = card->info.link_type;
+
+	ecmd->transceiver = XCVR_INTERNAL;
+	ecmd->supported = SUPPORTED_Autoneg;
+	ecmd->advertising = ADVERTISED_Autoneg;
+	ecmd->duplex = DUPLEX_FULL;
+	ecmd->autoneg = AUTONEG_ENABLE;
+
+	switch (link_type) {
+	case QETH_LINK_TYPE_FAST_ETH:
+	case QETH_LINK_TYPE_LANE_ETH100:
+		ecmd->supported |= SUPPORTED_10baseT_Half |
+					SUPPORTED_10baseT_Full |
+					SUPPORTED_100baseT_Half |
+					SUPPORTED_100baseT_Full |
+					SUPPORTED_TP;
+		ecmd->advertising |= ADVERTISED_10baseT_Half |
+					ADVERTISED_10baseT_Full |
+					ADVERTISED_100baseT_Half |
+					ADVERTISED_100baseT_Full |
+					ADVERTISED_TP;
+		ecmd->speed = SPEED_100;
+		ecmd->port = PORT_TP;
+		break;
+
+	case QETH_LINK_TYPE_GBIT_ETH:
+	case QETH_LINK_TYPE_LANE_ETH1000:
+		ecmd->supported |= SUPPORTED_10baseT_Half |
+					SUPPORTED_10baseT_Full |
+					SUPPORTED_100baseT_Half |
+					SUPPORTED_100baseT_Full |
+					SUPPORTED_1000baseT_Half |
+					SUPPORTED_1000baseT_Full |
+					SUPPORTED_FIBRE;
+		ecmd->advertising |= ADVERTISED_10baseT_Half |
+					ADVERTISED_10baseT_Full |
+					ADVERTISED_100baseT_Half |
+					ADVERTISED_100baseT_Full |
+					ADVERTISED_1000baseT_Half |
+					ADVERTISED_1000baseT_Full |
+					ADVERTISED_FIBRE;
+		ecmd->speed = SPEED_1000;
+		ecmd->port = PORT_FIBRE;
+		break;
+
+	case QETH_LINK_TYPE_10GBIT_ETH:
+		ecmd->supported |= SUPPORTED_10baseT_Half |
+					SUPPORTED_10baseT_Full |
+					SUPPORTED_100baseT_Half |
+					SUPPORTED_100baseT_Full |
+					SUPPORTED_1000baseT_Half |
+					SUPPORTED_1000baseT_Full |
+					SUPPORTED_10000baseT_Full |
+					SUPPORTED_FIBRE;
+		ecmd->advertising |= ADVERTISED_10baseT_Half |
+					ADVERTISED_10baseT_Full |
+					ADVERTISED_100baseT_Half |
+					ADVERTISED_100baseT_Full |
+					ADVERTISED_1000baseT_Half |
+					ADVERTISED_1000baseT_Full |
+					ADVERTISED_10000baseT_Full |
+					ADVERTISED_FIBRE;
+		ecmd->speed = SPEED_10000;
+		ecmd->port = PORT_FIBRE;
+		break;
+
+	default:
+		ecmd->supported |= SUPPORTED_10baseT_Half |
+					SUPPORTED_10baseT_Full |
+					SUPPORTED_TP;
+		ecmd->advertising |= ADVERTISED_10baseT_Half |
+					ADVERTISED_10baseT_Full |
+					ADVERTISED_TP;
+		ecmd->speed = SPEED_10;
+		ecmd->port = PORT_TP;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(qeth_core_ethtool_get_settings);
+
 static int __init qeth_core_init(void)
 {
 	int rc;
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2008-04-23 17:55:50.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2008-04-23 17:55:51.000000000 +0200
@@ -861,6 +861,7 @@ static struct ethtool_ops qeth_l2_ethtoo
 	.get_ethtool_stats = qeth_core_get_ethtool_stats,
 	.get_stats_count = qeth_core_get_stats_count,
 	.get_drvinfo = qeth_core_get_drvinfo,
+	.get_settings = qeth_core_ethtool_get_settings,
 };
 
 static struct ethtool_ops qeth_l2_osn_ops = {
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2008-04-23 17:55:51.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2008-04-23 17:55:51.000000000 +0200
@@ -2889,6 +2889,7 @@ static struct ethtool_ops qeth_l3_ethtoo
 	.get_ethtool_stats = qeth_core_get_ethtool_stats,
 	.get_stats_count = qeth_core_get_stats_count,
 	.get_drvinfo = qeth_core_get_drvinfo,
+	.get_settings = qeth_core_ethtool_get_settings,
 };
 
 /*

-- 
