From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH V2 net 06/10] net: hns: fix return value of the function about rss
Date: Tue, 22 Mar 2016 16:06:27 +0800
Message-ID: <1458633991-64313-7-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<sergei.shtylyov@cogentembedded.com>, <xieqianqian@huawei.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:31779 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbcCVHsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 03:48:24 -0400
In-Reply-To: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kejian Yan <yankejian@huawei.com>

Both .get_rxfh and .set_rxfh are always return 0, it should return result
from hardware when getting or setting rss. And the rss function should
return the correct data type.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
change log:
 PATCH V2:
  - fix the wrong casts:
    1) .get_rxfh_key_size and .get_rxfh_indir_size should return zero if
       not supported
    2) .get_rxfh and .set_rxfh should return negative error if not support

 PATCH V1:
  - first submit

 Link: https://lkml.org/lkml/2016/3/21/222
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  | 24 ++++++-----------------
 3 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index a7427b8..648b31a 100644
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
index f302ef9..06422c2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -27,7 +27,7 @@ void hns_ppe_set_tso_enable(struct hns_ppe_cb *ppe_cb, u32 value)
 void hns_ppe_set_rss_key(struct hns_ppe_cb *ppe_cb,
 			 const u32 rss_key[HNS_PPEV2_RSS_KEY_NUM])
 {
-	int key_item = 0;
+	u32 key_item;
 
 	for (key_item = 0; key_item < HNS_PPEV2_RSS_KEY_NUM; key_item++)
 		dsaf_write_dev(ppe_cb, PPEV2_RSS_KEY_REG + key_item * 0x4,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3c4a3bc..2229905 100644
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
+		return 0;
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
+		return 0;
 	}
 
 	ops = priv->ae_handle->dev->ops;
-	ret = ops->get_rss_indir_size(priv->ae_handle);
-
-	return ret;
+	return ops->get_rss_indir_size(priv->ae_handle);
 }
 
 static int
@@ -1211,7 +1205,6 @@ hns_get_rss(struct net_device *netdev, u32 *indir, u8 *key, u8 *hfunc)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
-	int ret;
 
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
@@ -1224,9 +1217,7 @@ hns_get_rss(struct net_device *netdev, u32 *indir, u8 *key, u8 *hfunc)
 	if (!indir)
 		return 0;
 
-	ret = ops->get_rss(priv->ae_handle, indir, key, hfunc);
-
-	return 0;
+	return ops->get_rss(priv->ae_handle, indir, key, hfunc);
 }
 
 static int
@@ -1235,7 +1226,6 @@ hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
-	int ret;
 
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
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
