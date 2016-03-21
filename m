From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 06/10] net: hns: fix return value of the function about rss
Date: Mon, 21 Mar 2016 19:06:37 +0800
Message-ID: <1458558401-190165-7-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<xieqianqian@huawei.com>, <andrew@lunn.ch>, <ivecera@redhat.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

Both .get_rxfh and .get_rxfh are always return 0, it should return result
from hardware when getting or setting rss. And the rss function should
return the correct data type.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  | 28 +++++++----------------
 3 files changed, 10 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 5e0cedf..1d0da87 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -803,7 +803,7 @@ static int hns_ae_set_rss(struct hnae_handle *handle, const u32 *indir,
 
 	/* set the RSS Hash Key if specififed by the user */
 	if (key)
-		hns_ppe_set_rss_key(ppe_cb, (int *)key);
+		hns_ppe_set_rss_key(ppe_cb, (u32 *)key);
 
 	/* update the shadow RSS table with user specified qids */
 	memcpy(ppe_cb->rss_indir_table, indir, HNS_PPEV2_RSS_IND_TBL_SIZE);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index f302ef9..811ef35 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -27,7 +27,7 @@ void hns_ppe_set_tso_enable(struct hns_ppe_cb *ppe_cb, u32 value)
 void hns_ppe_set_rss_key(struct hns_ppe_cb *ppe_cb,
 			 const u32 rss_key[HNS_PPEV2_RSS_KEY_NUM])
 {
-	int key_item = 0;
+	u32 key_item = 0;
 
 	for (key_item = 0; key_item < HNS_PPEV2_RSS_KEY_NUM; key_item++)
 		dsaf_write_dev(ppe_cb, PPEV2_RSS_KEY_REG + key_item * 0x4,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3c4a3bc..f3a5e05 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1173,18 +1173,15 @@ hns_get_rss_key_size(struct net_device *netdev)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
-	u32 ret;
 
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
 			   "RSS feature is not supported on this hardware\n");
-		return -EOPNOTSUPP;
+		return (u32)-EOPNOTSUPP;
 	}
 
 	ops = priv->ae_handle->dev->ops;
-	ret = ops->get_rss_key_size(priv->ae_handle);
-
-	return ret;
+	return ops->get_rss_key_size(priv->ae_handle);
 }
 
 static u32
@@ -1192,18 +1189,15 @@ hns_get_rss_indir_size(struct net_device *netdev)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
-	u32 ret;
 
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
 			   "RSS feature is not supported on this hardware\n");
-		return -EOPNOTSUPP;
+		return (u32)-EOPNOTSUPP;
 	}
 
 	ops = priv->ae_handle->dev->ops;
-	ret = ops->get_rss_indir_size(priv->ae_handle);
-
-	return ret;
+	return ops->get_rss_indir_size(priv->ae_handle);
 }
 
 static int
@@ -1211,12 +1205,11 @@ hns_get_rss(struct net_device *netdev, u32 *indir, u8 *key, u8 *hfunc)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
-	int ret;
 
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
 			   "RSS feature is not supported on this hardware\n");
-		return -EOPNOTSUPP;
+		return (u32)-EOPNOTSUPP;
 	}
 
 	ops = priv->ae_handle->dev->ops;
@@ -1224,9 +1217,7 @@ hns_get_rss(struct net_device *netdev, u32 *indir, u8 *key, u8 *hfunc)
 	if (!indir)
 		return 0;
 
-	ret = ops->get_rss(priv->ae_handle, indir, key, hfunc);
-
-	return 0;
+	return ops->get_rss(priv->ae_handle, indir, key, hfunc);
 }
 
 static int
@@ -1235,12 +1226,11 @@ hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
-	int ret;
 
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
 			   "RSS feature is not supported on this hardware\n");
-		return -EOPNOTSUPP;
+		return (u32)-EOPNOTSUPP;
 	}
 
 	ops = priv->ae_handle->dev->ops;
@@ -1252,9 +1242,7 @@ hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
 	if (!indir)
 		return 0;
 
-	ret = ops->set_rss(priv->ae_handle, indir, key, hfunc);
-
-	return 0;
+	return ops->set_rss(priv->ae_handle, indir, key, hfunc);
 }
 
 static struct ethtool_ops hns_ethtool_ops = {
-- 
1.9.1
