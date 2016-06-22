From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 10/13] liquidio: New xaui info
Date: Tue, 21 Jun 2016 22:53:12 -0700
Message-ID: <1466574795-4306-11-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0054.outbound.protection.outlook.com ([207.46.100.54]:30553
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751984AbcFVIdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 04:33:19 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for host driver support for new Xaui
interfaces.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 23 +++++++++++++++-------
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  8 ++++----
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 2b03095..88994c5 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -73,6 +73,11 @@ enum {
 	INTERFACE_MODE_RXAUI,
 	INTERFACE_MODE_QSGMII,
 	INTERFACE_MODE_AGL,
+	INTERFACE_MODE_XLAUI,
+	INTERFACE_MODE_XFI,
+	INTERFACE_MODE_10G_KR,
+	INTERFACE_MODE_40G_KR4,
+	INTERFACE_MODE_MIXED,
 };
 
 #define ARRAY_LENGTH(a) (sizeof(a) / sizeof((a)[0]))
@@ -195,8 +200,9 @@ static int lio_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	linfo = &lio->linfo;
 
-	if (linfo->link.s.interface == INTERFACE_MODE_XAUI ||
-	    linfo->link.s.interface == INTERFACE_MODE_RXAUI) {
+	if (linfo->link.s.if_mode == INTERFACE_MODE_XAUI ||
+	    linfo->link.s.if_mode == INTERFACE_MODE_RXAUI ||
+	    linfo->link.s.if_mode == INTERFACE_MODE_XFI) {
 		ecmd->port = PORT_FIBRE;
 		ecmd->supported =
 			(SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE |
@@ -207,7 +213,8 @@ static int lio_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ecmd->autoneg = AUTONEG_DISABLE;
 
 	} else {
-		dev_err(&oct->pci_dev->dev, "Unknown link interface reported\n");
+		dev_err(&oct->pci_dev->dev, "Unknown link interface reported %d\n",
+			linfo->link.s.if_mode);
 	}
 
 	if (linfo->link.s.link_up) {
@@ -1450,12 +1457,14 @@ static int lio_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 						  ecmd->duplex != DUPLEX_FULL)))
 		return -EINVAL;
 
-	/* Ethtool Support is not provided for XAUI and RXAUI Interfaces
+	/* Ethtool Support is not provided for XAUI, RXAUI, and XFI Interfaces
 	 * as they operate at fixed Speed and Duplex settings
 	 */
-	if (linfo->link.s.interface == INTERFACE_MODE_XAUI ||
-	    linfo->link.s.interface == INTERFACE_MODE_RXAUI) {
-		dev_info(&oct->pci_dev->dev, "XAUI IFs settings cannot be modified.\n");
+	if (linfo->link.s.if_mode == INTERFACE_MODE_XAUI ||
+	    linfo->link.s.if_mode == INTERFACE_MODE_RXAUI ||
+	    linfo->link.s.if_mode == INTERFACE_MODE_XFI) {
+		dev_info(&oct->pci_dev->dev,
+			 "Autonegotiation, duplex and speed settings cannot be modified.\n");
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 4dc8e54..5aa01f4 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -628,13 +628,13 @@ union oct_link_status {
 		u64 speed:16;
 		u64 link_up:1;
 		u64 autoneg:1;
-		u64 interface:4;
+		u64 if_mode:5;
 		u64 pause:1;
-		u64 reserved:17;
+		u64 reserved:16;
 #else
-		u64 reserved:17;
+		u64 reserved:16;
 		u64 pause:1;
-		u64 interface:4;
+		u64 if_mode:5;
 		u64 autoneg:1;
 		u64 link_up:1;
 		u64 speed:16;
-- 
1.8.3.1
