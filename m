From: Stuart Hodgson <smhodgson@solarflare.com>
Subject: [PATCH net-next 3/3] Add capability to retrieve plug-in module EEPROM
Date: Thu, 19 Apr 2012 16:39:51 +0100
Message-ID: <4F9031C7.9070206@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	<bruce.w.allan@intel.com>, <decot@google.com>,
	<alexander.h.duyck@intel.com>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently allows for SFP+ eeprom to be returned using the ethtool API.
This can be extended in future to handle different eeprom formats
and sizes

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c    |   35 ++++++++++
 drivers/net/ethernet/sfc/mcdi_phy.c   |  111 +++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/net_driver.h |    5 ++
 3 files changed, 151 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index f22f45f..60e718f 100644
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
+		return 0;
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
index 7bcad89..4bac56c 100644
--- a/drivers/net/ethernet/sfc/mcdi_phy.c
+++ b/drivers/net/ethernet/sfc/mcdi_phy.c
@@ -304,6 +304,26 @@ static u32 mcdi_to_ethtool_media(u32 media)
 	}
 }

+static u32 mcdi_to_module_eeprom_len(u32 media)
+{
+	switch (media) {
+	case MC_CMD_MEDIA_SFP_PLUS:
+		return ETH_MODULE_SFF_8079_LEN;
+	default:
+		return 0;
+	}
+}
+
+static u32 mcdi_to_module_eeprom_type(u32 media)
+{
+	switch (media) {
+	case MC_CMD_MEDIA_SFP_PLUS:
+		return ETH_MODULE_SFF_8079;
+	default:
+		return 0;
+	}
+}
+
 static int efx_mcdi_phy_probe(struct efx_nic *efx)
 {
 	struct efx_mcdi_phy_data *phy_data;
@@ -739,6 +759,95 @@ static const char *efx_mcdi_phy_test_name(struct efx_nic *efx,
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
+	unsigned int copied = 0;
+	unsigned int space_remaining = ee->len;
+	unsigned int page;
+	unsigned int page_off;
+	unsigned int to_copy;
+	u8 *user_data = data;
+
+	if (ee->offset > (SFP_PAGE_SIZE * SFP_NUM_PAGES))
+		return -EINVAL;
+
+	page_off = (ee->offset % SFP_PAGE_SIZE);
+	page = (ee->offset > SFP_PAGE_SIZE) ? 1 : 0;
+
+	while (space_remaining && (page < SFP_NUM_PAGES)) {
+
+		MCDI_SET_DWORD(inbuf, GET_PHY_MEDIA_INFO_IN_PAGE, page);
+
+		rc = efx_mcdi_rpc(efx, MC_CMD_GET_PHY_MEDIA_INFO,
+				  inbuf, sizeof(inbuf),
+				  outbuf, sizeof(outbuf),
+				  &outlen);
+
+		if (rc)
+			return rc;
+
+		/* Copy as much as we can into data */
+		if (outlen < SFP_PAGE_SIZE ||
+		    outlen < MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMIN ||
+		    outlen > MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMAX)
+			return -EIO;
+
+		payload_len = MCDI_DWORD(outbuf,
+					 GET_PHY_MEDIA_INFO_OUT_DATALEN);
+
+		payload_len -= page_off;
+		to_copy = (space_remaining < payload_len) ?
+				space_remaining : payload_len;
+
+		memcpy(user_data,
+		       (outbuf + page_off +
+		       MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATA_OFST),
+		       to_copy);
+
+		space_remaining -= to_copy;
+		user_data += to_copy;
+		copied += to_copy;
+		page_off = 0;
+		page++;
+	}
+
+	ee->len = copied;
+
+	return 0;
+}
+
+static int efx_mcdi_phy_get_module_info(struct efx_nic *efx,
+					struct ethtool_modinfo *modinfo)
+{
+	/* This will return a length of the eeprom
+	 * type of the module that was detected during the probe,
+	 * if not modules inserted then phy_data will be NULL */
+	struct efx_mcdi_phy_data *phy_cfg;
+
+	phy_cfg = efx->phy_data;
+	modinfo->eeprom_len = 0;
+	modinfo->type = 0;
+
+	switch (phy_cfg->media) {
+	case MC_CMD_MEDIA_SFP_PLUS:
+		modinfo->type = ETH_MODULE_SFF_8079;
+		modinfo->eeprom_len = ETH_MODULE_SFF_8079_LEN;
+		break;
+	default:
+		break;
+	}
+
+	return 0;
+}
+
 const struct efx_phy_operations efx_mcdi_phy_ops = {
 	.probe		= efx_mcdi_phy_probe,
 	.init		= efx_port_dummy_op_int,
@@ -751,4 +860,6 @@ const struct efx_phy_operations efx_mcdi_phy_ops = {
 	.test_alive	= efx_mcdi_phy_test_alive,
 	.run_tests	= efx_mcdi_phy_run_tests,
 	.test_name	= efx_mcdi_phy_test_name,
+	.get_module_eeprom	= efx_mcdi_phy_get_module_eeprom,
+	.get_module_info	= efx_mcdi_phy_get_module_info,
 };
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index f0385e1..0af8c47 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -522,6 +522,11 @@ struct efx_phy_operations {
 	int (*test_alive) (struct efx_nic *efx);
 	const char *(*test_name) (struct efx_nic *efx, unsigned int index);
 	int (*run_tests) (struct efx_nic *efx, int *results, unsigned flags);
+	int (*get_module_eeprom) (struct efx_nic *efx,
+				  struct ethtool_eeprom *ee,
+				  u8 *data);
+	int (*get_module_info) (struct efx_nic *efx,
+				struct ethtool_modinfo *modinfo);
 };

 /**
-- 
1.7.1
