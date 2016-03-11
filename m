From: Kejian Yan <yankejian@huawei.com>
Subject: [PATCH v3 net-next 2/2] net: hns: fixes a bug of RSS
Date: Fri, 11 Mar 2016 11:25:47 +0800
Message-ID: <1457666747-244953-3-git-send-email-yankejian@huawei.com>
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

If trying to get receive flow hash indirection table by ethtool, it needs
to call .get_rxnfc to get ring number first. So this patch implements the
.get_rxnfc of ethtool. And the data type of rss_indir_table is u32, it has
to be multiply by the width of data type when using memcpy.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
---
change log:
PATCH v3:
 - This patch modifies the return value of .get_rxnfc to fix building error

PATCH v2:
 - This patch fixes the comments provided by Andy Shevchenko <Andy Shevchenko>

 Link: https://lkml.org/lkml/2016/3/10/267

PATCH v1:
 - first submit

 Link: https://lkml.org/lkml/2016/3/9/981
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  6 ++++--
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  | 18 ++++++++++++++++++
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index d07db1f..7b06e9b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -787,7 +787,8 @@ static int hns_ae_get_rss(struct hnae_handle *handle, u32 *indir, u8 *key,
 		memcpy(key, ppe_cb->rss_key, HNS_PPEV2_RSS_KEY_SIZE);
 
 	/* update the current hash->queue mappings from the shadow RSS table */
-	memcpy(indir, ppe_cb->rss_indir_table, HNS_PPEV2_RSS_IND_TBL_SIZE);
+	memcpy(indir, ppe_cb->rss_indir_table,
+	       HNS_PPEV2_RSS_IND_TBL_SIZE * sizeof(*indir));
 
 	return 0;
 }
@@ -802,7 +803,8 @@ static int hns_ae_set_rss(struct hnae_handle *handle, const u32 *indir,
 		hns_ppe_set_rss_key(ppe_cb, (u32 *)key);
 
 	/* update the shadow RSS table with user specified qids */
-	memcpy(ppe_cb->rss_indir_table, indir, HNS_PPEV2_RSS_IND_TBL_SIZE);
+	memcpy(ppe_cb->rss_indir_table, indir,
+	       HNS_PPEV2_RSS_IND_TBL_SIZE * sizeof(*indir));
 
 	/* now update the hardware */
 	hns_ppe_set_indir_table(ppe_cb, ppe_cb->rss_indir_table);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 01b65eb..46379ce 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1251,6 +1251,23 @@ hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
 	return ops->set_rss(priv->ae_handle, indir, key, hfunc);
 }
 
+static int hns_get_rxnfc(struct net_device *netdev,
+			 struct ethtool_rxnfc *cmd,
+			 u32 *rule_locs)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXRINGS:
+		cmd->data = priv->ae_handle->q_num;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
 static struct ethtool_ops hns_ethtool_ops = {
 	.get_drvinfo = hns_nic_get_drvinfo,
 	.get_link  = hns_nic_get_link,
@@ -1274,6 +1291,7 @@ static struct ethtool_ops hns_ethtool_ops = {
 	.get_rxfh_indir_size = hns_get_rss_indir_size,
 	.get_rxfh = hns_get_rss,
 	.set_rxfh = hns_set_rss,
+	.get_rxnfc = hns_get_rxnfc,
 };
 
 void hns_ethtool_set_ops(struct net_device *ndev)
-- 
1.9.1
