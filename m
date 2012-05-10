From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 7/8] sfc: Added support for new ethtool APIs for
 obtaining module eeprom
Date: Thu, 10 May 2012 03:32:16 +0100
Message-ID: <1336617136.2499.40.camel@bwh-desktop.uk.solarflarecom.com>
References: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51921 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753809Ab2EJCcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:32:20 -0400
In-Reply-To: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stuart Hodgson <smhodgson@solarflare.com>

Currently allows for SFP+ eeprom to be returned using the ethtool API.
This can be extended in future to handle different eeprom formats
and sizes

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
[bwh: Drop redundant validation, comment, whitespace]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c    |   35 +++++++++++++++
 drivers/net/ethernet/sfc/mcdi_phy.c   |   76 +++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/net_driver.h |    5 ++
 3 files changed, 116 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index f22f45f..b0a4558 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1108,6 +1108,39 @@ static int efx_ethtool_set_rxfh_indir(struct net_device *net_dev,
 	return 0;
 }
 
+static int efx_ethtool_get_module_eeprom(struct net_device *net_dev,
+					 struct ethtool_eeprom *ee,
+					 u8 *data)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	int ret;
+
+	if (!efx->phy_op || !efx->phy_op->get_module_eeprom)
+		return -EOPNOTSUPP;
+
+	mutex_lock(&efx->mac_lock);
+	ret = efx->phy_op->get_module_eeprom(efx, ee, data);
+	mutex_unlock(&efx->mac_lock);
+
+	return ret;
+}
+
+static int efx_ethtool_get_module_info(struct net_device *net_dev,
+				       struct ethtool_modinfo *modinfo)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	int ret;
+
+	if (!efx->phy_op || !efx->phy_op->get_module_info)
+		return -EOPNOTSUPP;
+
+	mutex_lock(&efx->mac_lock);
+	ret = efx->phy_op->get_module_info(efx, modinfo);
+	mutex_unlock(&efx->mac_lock);
+
+	return ret;
+}
+
 const struct ethtool_ops efx_ethtool_ops = {
 	.get_settings		= efx_ethtool_get_settings,
 	.set_settings		= efx_ethtool_set_settings,
@@ -1137,4 +1170,6 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_rxfh_indir_size	= efx_ethtool_get_rxfh_indir_size,
 	.get_rxfh_indir		= efx_ethtool_get_rxfh_indir,
 	.set_rxfh_indir		= efx_ethtool_set_rxfh_indir,
+	.get_module_info	= efx_ethtool_get_module_info,
+	.get_module_eeprom	= efx_ethtool_get_module_eeprom,
 };
diff --git a/drivers/net/ethernet/sfc/mcdi_phy.c b/drivers/net/ethernet/sfc/mcdi_phy.c
index 7bcad89..13cb40f 100644
--- a/drivers/net/ethernet/sfc/mcdi_phy.c
+++ b/drivers/net/ethernet/sfc/mcdi_phy.c
@@ -739,6 +739,80 @@ static const char *efx_mcdi_phy_test_name(struct efx_nic *efx,
 	return NULL;
 }
 
+#define SFP_PAGE_SIZE	128
+#define SFP_NUM_PAGES	2
+static int efx_mcdi_phy_get_module_eeprom(struct efx_nic *efx,
+					  struct ethtool_eeprom *ee, u8 *data)
+{
+	u8 outbuf[MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMAX];
+	u8 inbuf[MC_CMD_GET_PHY_MEDIA_INFO_IN_LEN];
+	size_t outlen;
+	int rc;
+	unsigned int payload_len;
+	unsigned int space_remaining = ee->len;
+	unsigned int page;
+	unsigned int page_off;
+	unsigned int to_copy;
+	u8 *user_data = data;
+
+	BUILD_BUG_ON(SFP_PAGE_SIZE * SFP_NUM_PAGES != ETH_MODULE_SFF_8079_LEN);
+
+	page_off = ee->offset % SFP_PAGE_SIZE;
+	page = ee->offset / SFP_PAGE_SIZE;
+
+	while (space_remaining && (page < SFP_NUM_PAGES)) {
+		MCDI_SET_DWORD(inbuf, GET_PHY_MEDIA_INFO_IN_PAGE, page);
+
+		rc = efx_mcdi_rpc(efx, MC_CMD_GET_PHY_MEDIA_INFO,
+				  inbuf, sizeof(inbuf),
+				  outbuf, sizeof(outbuf),
+				  &outlen);
+		if (rc)
+			return rc;
+
+		if (outlen < (MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATA_OFST +
+			      SFP_PAGE_SIZE))
+			return -EIO;
+
+		payload_len = MCDI_DWORD(outbuf,
+					 GET_PHY_MEDIA_INFO_OUT_DATALEN);
+		if (payload_len != SFP_PAGE_SIZE)
+			return -EIO;
+
+		/* Copy as much as we can into data */
+		payload_len -= page_off;
+		to_copy = (space_remaining < payload_len) ?
+			space_remaining : payload_len;
+
+		memcpy(user_data,
+		       outbuf + page_off +
+		       MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATA_OFST,
+		       to_copy);
+
+		space_remaining -= to_copy;
+		user_data += to_copy;
+		page_off = 0;
+		page++;
+	}
+
+	return 0;
+}
+
+static int efx_mcdi_phy_get_module_info(struct efx_nic *efx,
+					struct ethtool_modinfo *modinfo)
+{
+	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
+
+	switch (phy_cfg->media) {
+	case MC_CMD_MEDIA_SFP_PLUS:
+		modinfo->type = ETH_MODULE_SFF_8079;
+		modinfo->eeprom_len = ETH_MODULE_SFF_8079_LEN;
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 const struct efx_phy_operations efx_mcdi_phy_ops = {
 	.probe		= efx_mcdi_phy_probe,
 	.init		= efx_port_dummy_op_int,
@@ -751,4 +825,6 @@ const struct efx_phy_operations efx_mcdi_phy_ops = {
 	.test_alive	= efx_mcdi_phy_test_alive,
 	.run_tests	= efx_mcdi_phy_run_tests,
 	.test_name	= efx_mcdi_phy_test_name,
+	.get_module_eeprom = efx_mcdi_phy_get_module_eeprom,
+	.get_module_info = efx_mcdi_phy_get_module_info,
 };
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index eaca447..0e57535 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -519,6 +519,11 @@ struct efx_phy_operations {
 	int (*test_alive) (struct efx_nic *efx);
 	const char *(*test_name) (struct efx_nic *efx, unsigned int index);
 	int (*run_tests) (struct efx_nic *efx, int *results, unsigned flags);
+	int (*get_module_eeprom) (struct efx_nic *efx,
+			       struct ethtool_eeprom *ee,
+			       u8 *data);
+	int (*get_module_info) (struct efx_nic *efx,
+				struct ethtool_modinfo *modinfo);
 };
 
 /**
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
