From: Kejian Yan <yankejian@huawei.com>
Subject: [PATCH v3 net-next 1/2] net: hns: fix return value of the function about rss
Date: Fri, 11 Mar 2016 11:25:46 +0800
Message-ID: <1457666747-244953-2-git-send-email-yankejian@huawei.com>
References: <1457666747-244953-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<chenny.xu@huawei.com>, <ivecera@redhat.com>,
	<lisheng011@huawei.com>, <fengguang.wu@intel.com>,
	<haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457666747-244953-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both .get_rxfh and .get_rxfh are always return 0, it should return result
from hardware when getting or setting rss. And the rss function should
return the correct data type.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
---
change log:
PATCH v3:
 - This patch removes unused variable 'ret' to fix the build warning

PATCH v2:
 - This patch fixes the comments provided by Andy Shevchenko <Andy Shevchenko>

 Link: https://lkml.org/lkml/2016/3/10/266

PATCH v1:
 - first submit

 Link: https://lkml.org/lkml/2016/3/9/978
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  | 14 ++++----------
 3 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index d4f92ed..d07db1f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -799,7 +799,7 @@ static int hns_ae_set_rss(struct hnae_handle *handle, const u32 *indir,
 
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
index 3c4a3bc..01b65eb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1178,7 +1178,7 @@ hns_get_rss_key_size(struct net_device *netdev)
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
 			   "RSS feature is not supported on this hardware\n");
-		return -EOPNOTSUPP;
+		return (u32)-EOPNOTSUPP;
 	}
 
 	ops = priv->ae_handle->dev->ops;
@@ -1197,7 +1197,7 @@ hns_get_rss_indir_size(struct net_device *netdev)
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
 			   "RSS feature is not supported on this hardware\n");
-		return -EOPNOTSUPP;
+		return (u32)-EOPNOTSUPP;
 	}
 
 	ops = priv->ae_handle->dev->ops;
@@ -1211,7 +1211,6 @@ hns_get_rss(struct net_device *netdev, u32 *indir, u8 *key, u8 *hfunc)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
-	int ret;
 
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
@@ -1224,9 +1223,7 @@ hns_get_rss(struct net_device *netdev, u32 *indir, u8 *key, u8 *hfunc)
 	if (!indir)
 		return 0;
 
-	ret = ops->get_rss(priv->ae_handle, indir, key, hfunc);
-
-	return 0;
+	return ops->get_rss(priv->ae_handle, indir, key, hfunc);
 }
 
 static int
@@ -1235,7 +1232,6 @@ hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
-	int ret;
 
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
@@ -1252,9 +1248,7 @@ hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
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
