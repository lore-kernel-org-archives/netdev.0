From: Stuart Hodgson <smhodgson@solarflare.com>
Subject: [RFC PATCH 2/2] net: ethtool: Add capability to retrieve plug-in
 module EEPROM
Date: Tue, 27 Mar 2012 18:51:17 +0100
Message-ID: <4F71FE15.7060708@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implementation in sfc driver to return the plugin module eeprom

Currently allows for SFP+ eeprom to be returned using the ethtool API.
This can be extended in future to handle different eeprom formats
and sizes.

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
---
  drivers/net/ethernet/sfc/ethtool.c    |   36 +++++++++++
  drivers/net/ethernet/sfc/mcdi_phy.c   |  105 
+++++++++++++++++++++++++++++++++
  drivers/net/ethernet/sfc/net_driver.h |    5 ++
  3 files changed, 146 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c 
b/drivers/net/ethernet/sfc/ethtool.c
index f22f45f..e77895f 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1108,6 +1108,40 @@ static int efx_ethtool_set_rxfh_indir(struct 
net_device *net_dev,
      return 0;
  }

+static int efx_ethtool_get_module_eeprom(struct net_device *net_dev,
+                     struct ethtool_eeprom *ee,
+                     u8 *data)
+{
+    struct efx_nic *efx = netdev_priv(net_dev);
+    int ret;
+
+    if (!efx->phy_op ||
+        !efx->phy_op->get_module_eeprom)
+        return -EOPNOTSUPP;
+
+    mutex_lock(&efx->mac_lock);
+    ret = efx->phy_op->get_module_eeprom(efx, ee, data);
+    mutex_unlock(&efx->mac_lock);
+
+    return ret;
+}
+
+static int efx_ethtool_get_module_info(struct net_device *net_dev,
+                       struct ethtool_modinfo *modinfo)
+{
+    struct efx_nic *efx = netdev_priv(net_dev);
+    int ret;
+
+    if (!efx->phy_op || !efx->phy_op->get_module_info)
+        return 0;
+
+    mutex_lock(&efx->mac_lock);
+    ret = efx->phy_op->get_module_info(efx, modinfo);
+    mutex_unlock(&efx->mac_lock);
+
+    return ret;
+}
+
  const struct ethtool_ops efx_ethtool_ops = {
      .get_settings        = efx_ethtool_get_settings,
      .set_settings        = efx_ethtool_set_settings,
@@ -1137,4 +1171,6 @@ const struct ethtool_ops efx_ethtool_ops = {
      .get_rxfh_indir_size    = efx_ethtool_get_rxfh_indir_size,
      .get_rxfh_indir        = efx_ethtool_get_rxfh_indir,
      .set_rxfh_indir        = efx_ethtool_set_rxfh_indir,
+    .get_module_info    = efx_ethtool_get_module_info,
+    .get_module_eeprom    = efx_ethtool_get_module_eeprom,
  };
diff --git a/drivers/net/ethernet/sfc/mcdi_phy.c 
b/drivers/net/ethernet/sfc/mcdi_phy.c
index 7bcad89..be8e372 100644
--- a/drivers/net/ethernet/sfc/mcdi_phy.c
+++ b/drivers/net/ethernet/sfc/mcdi_phy.c
@@ -304,6 +304,17 @@ static u32 mcdi_to_ethtool_media(u32 media)
      }
  }

+static u32 mcdi_to_module_eeprom_len(u32 media)
+{
+    switch (media) {
+    case MC_CMD_MEDIA_SFP_PLUS:
+        return SFF_8079_LEN;
+    case MC_CMD_MEDIA_XFP:
+    default:
+        return 0;
+    }
+}
+
  static int efx_mcdi_phy_probe(struct efx_nic *efx)
  {
      struct efx_mcdi_phy_data *phy_data;
@@ -739,6 +750,98 @@ static const char *efx_mcdi_phy_test_name(struct 
efx_nic *efx,
      return NULL;
  }

+#define SFP_PAGE_SIZE    128
+#define NUM_PAGES    2
+#define OFF_TO_BUFF(x)    (x + MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATA_OFST)
+static int efx_mcdi_phy_get_module_eeprom(struct efx_nic *efx,
+                      struct ethtool_eeprom *ee, u8 *data)
+{
+    u8 outbuf[MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMAX];
+    u8 inbuf[MC_CMD_GET_PHY_MEDIA_INFO_IN_LEN];
+    size_t outlen;
+    int rc;
+    int payload_len;
+    int copied = 0;
+    int space_remaining = ee->len;
+    int page;
+    int page_off;
+    int to_copy;
+    u8 *user_data = data;
+
+    if (!data || !ee)
+        return -EINVAL;
+
+    if (ee->offset > (SFP_PAGE_SIZE * NUM_PAGES)) {
+        rc = -EINVAL;
+        goto fail;
+    }
+
+    page_off = (ee->offset % SFP_PAGE_SIZE);
+    page = (ee->offset > SFP_PAGE_SIZE) ? 1 : 0;
+
+    while (space_remaining && (page < NUM_PAGES)) {
+
+        MCDI_SET_DWORD(inbuf, GET_PHY_MEDIA_INFO_IN_PAGE, page);
+
+        rc = efx_mcdi_rpc(efx, MC_CMD_GET_PHY_MEDIA_INFO,
+                  inbuf, sizeof(inbuf),
+                  outbuf, sizeof(outbuf),
+ &outlen);
+
+        if (rc)
+            goto fail;
+
+        /* Copy as much as we can into data */
+        if (outlen < MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMIN ||
+            outlen > MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMAX) {
+            rc = -EIO;
+            goto fail;
+        }
+
+        payload_len = MCDI_DWORD(outbuf,
+                     GET_PHY_MEDIA_INFO_OUT_DATALEN);
+
+        to_copy = (space_remaining < payload_len) ?
+                space_remaining : payload_len;
+
+        to_copy -= page_off;
+
+        memcpy(user_data,
+               (outbuf + OFF_TO_BUFF(page_off)),
+               to_copy);
+
+        space_remaining -= to_copy;
+        user_data += to_copy;
+        copied += to_copy;
+        page_off = 0;
+        page++;
+    }
+
+    ee->len = copied;
+
+    return 0;
+fail:
+    return rc;
+}
+
+static int efx_mcdi_phy_get_module_info(struct efx_nic *efx,
+                    struct ethtool_modinfo *modinfo)
+{
+    /* This will return a length of the eeprom
+     * type of the module that was detected during the probe,
+     * if not modules inserted then phy_data will be NULL */
+    struct efx_mcdi_phy_data *phy_cfg;
+
+    if (!efx || !efx->phy_data)
+        return -EOPNOTSUPP;
+
+    phy_cfg = efx->phy_data;
+    modinfo->eeprom_len = mcdi_to_module_eeprom_len(phy_cfg->media);
+    modinfo->type = SFF_8079;
+
+    return 0;
+}
+
  const struct efx_phy_operations efx_mcdi_phy_ops = {
      .probe        = efx_mcdi_phy_probe,
      .init        = efx_port_dummy_op_int,
@@ -751,4 +854,6 @@ const struct efx_phy_operations efx_mcdi_phy_ops = {
      .test_alive    = efx_mcdi_phy_test_alive,
      .run_tests    = efx_mcdi_phy_run_tests,
      .test_name    = efx_mcdi_phy_test_name,
+    .get_module_eeprom    = efx_mcdi_phy_get_module_eeprom,
+    .get_module_info    = efx_mcdi_phy_get_module_info,
  };
diff --git a/drivers/net/ethernet/sfc/net_driver.h 
b/drivers/net/ethernet/sfc/net_driver.h
index 0b95505..245fc42 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -524,6 +524,11 @@ struct efx_phy_operations {
      int (*test_alive) (struct efx_nic *efx);
      const char *(*test_name) (struct efx_nic *efx, unsigned int index);
      int (*run_tests) (struct efx_nic *efx, int *results, unsigned flags);
+    int (*get_module_eeprom) (struct efx_nic *efx,
+                   struct ethtool_eeprom *ee,
+                   u8 *data);
+    int (*get_module_info) (struct efx_nic *efx,
+                struct ethtool_modinfo *modinfo);
  };

  /**
-- 
1.7.7.6
