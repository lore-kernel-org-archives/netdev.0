From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 1/4] amd-xgbe: Check for Tx hardware queue flushing
 support
Date: Fri, 29 Aug 2014 13:16:50 -0500
Message-ID: <20140829181650.3257.71555.stgit@tlendack-t1.amdoffice.net>
References: <20140829181643.3257.28011.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0142.outbound.protection.outlook.com ([207.46.163.142]:16814
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753382AbaH2SQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 14:16:55 -0400
In-Reply-To: <20140829181643.3257.28011.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The flushing of the Tx hardware queues is only supported at a certain
level of the hardware.  Retrieve the current version of the hardware
and use that to determine if flushing is supported.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |    3 +++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |    2 ++
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |    7 ++++---
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    3 +++
 4 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index edaca44..e43747a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1633,6 +1633,9 @@ static int xgbe_flush_tx_queues(struct xgbe_prv_data *pdata)
 {
 	unsigned int i, count;
 
+	if (XGMAC_GET_BITS(pdata->hw_feat.version, MAC_VR, SNPSVER) < 0x21)
+		return 0;
+
 	for (i = 0; i < pdata->tx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, FTQ, 1);
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index dc84f71..b26d758 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -361,6 +361,8 @@ void xgbe_get_all_hw_features(struct xgbe_prv_data *pdata)
 
 	memset(hw_feat, 0, sizeof(*hw_feat));
 
+	hw_feat->version = XGMAC_IOREAD(pdata, MAC_VR);
+
 	/* Hardware feature register 0 */
 	hw_feat->gmii        = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, GMIISEL);
 	hw_feat->vlhash      = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, VLHASH);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index a076aca..46f6130 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -361,15 +361,16 @@ static void xgbe_get_drvinfo(struct net_device *netdev,
 			     struct ethtool_drvinfo *drvinfo)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_features *hw_feat = &pdata->hw_feat;
 
 	strlcpy(drvinfo->driver, XGBE_DRV_NAME, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, XGBE_DRV_VERSION, sizeof(drvinfo->version));
 	strlcpy(drvinfo->bus_info, dev_name(pdata->dev),
 		sizeof(drvinfo->bus_info));
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version), "%d.%d.%d",
-		 XGMAC_IOREAD_BITS(pdata, MAC_VR, USERVER),
-		 XGMAC_IOREAD_BITS(pdata, MAC_VR, DEVID),
-		 XGMAC_IOREAD_BITS(pdata, MAC_VR, SNPSVER));
+		 XGMAC_GET_BITS(hw_feat->version, MAC_VR, USERVER),
+		 XGMAC_GET_BITS(hw_feat->version, MAC_VR, DEVID),
+		 XGMAC_GET_BITS(hw_feat->version, MAC_VR, SNPSVER));
 	drvinfo->n_stats = XGBE_STATS_COUNT;
 }
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 07bf70a..5af5c38 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -526,6 +526,9 @@ struct xgbe_desc_if {
  * or configurations are present in the device.
  */
 struct xgbe_hw_features {
+	/* HW Version */
+	unsigned int version;
+
 	/* HW Feature Register0 */
 	unsigned int gmii;		/* 1000 Mbps support */
 	unsigned int vlhash;		/* VLAN Hash Filter */
