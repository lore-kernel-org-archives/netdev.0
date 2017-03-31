From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 net-next 09/18] net: hns: Correct HNS RSS key set function
Date: Fri, 31 Mar 2017 12:20:23 +0100
Message-ID: <20170331112032.4692-10-salil.mehta@huawei.com>
References: <20170331112032.4692-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        lipeng <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170331112032.4692-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lipeng <lipeng321@huawei.com>

This patch fixes below ethtool configuration error:

localhost:~ # ethtool -X eth0 hkey XX:XX:XX...
Cannot set Rx flow hash configuration: Operation not supported

Signed-off-by: lipeng <lipeng321@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c | 23 ++++++++++++++---------
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  |  9 ++++-----
 2 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index cd7e88e..f0142e5 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -826,8 +826,9 @@ static int hns_ae_get_rss(struct hnae_handle *handle, u32 *indir, u8 *key,
 		memcpy(key, ppe_cb->rss_key, HNS_PPEV2_RSS_KEY_SIZE);
 
 	/* update the current hash->queue mappings from the shadow RSS table */
-	memcpy(indir, ppe_cb->rss_indir_table,
-	       HNS_PPEV2_RSS_IND_TBL_SIZE * sizeof(*indir));
+	if (indir)
+		memcpy(indir, ppe_cb->rss_indir_table,
+		       HNS_PPEV2_RSS_IND_TBL_SIZE  * sizeof(*indir));
 
 	return 0;
 }
@@ -838,15 +839,19 @@ static int hns_ae_set_rss(struct hnae_handle *handle, const u32 *indir,
 	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
 
 	/* set the RSS Hash Key if specififed by the user */
-	if (key)
-		hns_ppe_set_rss_key(ppe_cb, (u32 *)key);
+	if (key) {
+		memcpy(ppe_cb->rss_key, key, HNS_PPEV2_RSS_KEY_SIZE);
+		hns_ppe_set_rss_key(ppe_cb, ppe_cb->rss_key);
+	}
 
-	/* update the shadow RSS table with user specified qids */
-	memcpy(ppe_cb->rss_indir_table, indir,
-	       HNS_PPEV2_RSS_IND_TBL_SIZE * sizeof(*indir));
+	if (indir) {
+		/* update the shadow RSS table with user specified qids */
+		memcpy(ppe_cb->rss_indir_table, indir,
+		       HNS_PPEV2_RSS_IND_TBL_SIZE  * sizeof(*indir));
 
-	/* now update the hardware */
-	hns_ppe_set_indir_table(ppe_cb, ppe_cb->rss_indir_table);
+		/* now update the hardware */
+		hns_ppe_set_indir_table(ppe_cb, ppe_cb->rss_indir_table);
+	}
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3404eac..3a2a342 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1244,6 +1244,7 @@ hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_ae_ops *ops;
+	int ret;
 
 	if (AE_IS_VER1(priv->enet_ver)) {
 		netdev_err(netdev,
@@ -1253,12 +1254,10 @@ hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
 
 	ops = priv->ae_handle->dev->ops;
 
-	/* currently hfunc can only be Toeplitz hash */
-	if (key ||
-	    (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP))
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP) {
+		netdev_err(netdev, "Invalid hfunc!\n");
 		return -EOPNOTSUPP;
-	if (!indir)
-		return 0;
+	}
 
 	return ops->set_rss(priv->ae_handle, indir, key, hfunc);
 }
-- 
2.7.4
