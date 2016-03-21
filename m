From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 07/10] net: hns: fixes a bug of RSS
Date: Mon, 21 Mar 2016 19:06:38 +0800
Message-ID: <1458558401-190165-8-git-send-email-Yisen.Zhuang@huawei.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:51852 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754650AbcCUKsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 06:48:45 -0400
In-Reply-To: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kejian Yan <yankejian@huawei.com>

If trying to get receive flow hash indirection table by ethtool, it needs
to call .get_rxnfc to get ring number first. So this patch implements the
.get_rxnfc of ethtool. And the data type of rss_indir_table is u32, it has
to be multiply by the width of data type when using memcpy.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  6 ++++--
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  | 18 ++++++++++++++++++
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 1d0da87..d2cca60 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -791,7 +791,8 @@ static int hns_ae_get_rss(struct hnae_handle *handle, u32 *indir, u8 *key,
 		memcpy(key, ppe_cb->rss_key, HNS_PPEV2_RSS_KEY_SIZE);
 
 	/* update the current hash->queue mappings from the shadow RSS table */
-	memcpy(indir, ppe_cb->rss_indir_table, HNS_PPEV2_RSS_IND_TBL_SIZE);
+	memcpy(indir, ppe_cb->rss_indir_table,
+	       HNS_PPEV2_RSS_IND_TBL_SIZE * sizeof(*indir));
 
 	return 0;
 }
@@ -806,7 +807,8 @@ static int hns_ae_set_rss(struct hnae_handle *handle, const u32 *indir,
 		hns_ppe_set_rss_key(ppe_cb, (u32 *)key);
 
 	/* update the shadow RSS table with user specified qids */
-	memcpy(ppe_cb->rss_indir_table, indir, HNS_PPEV2_RSS_IND_TBL_SIZE);
+	memcpy(ppe_cb->rss_indir_table, indir,
+	       HNS_PPEV2_RSS_IND_TBL_SIZE * sizeof(*indir));
 
 	/* now update the hardware */
 	hns_ppe_set_indir_table(ppe_cb, ppe_cb->rss_indir_table);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index f3a5e05..02e9fa2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1245,6 +1245,23 @@ hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
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
@@ -1268,6 +1285,7 @@ static struct ethtool_ops hns_ethtool_ops = {
 	.get_rxfh_indir_size = hns_get_rss_indir_size,
 	.get_rxfh = hns_get_rss,
 	.set_rxfh = hns_set_rss,
+	.get_rxnfc = hns_get_rxnfc,
 };
 
 void hns_ethtool_set_ops(struct net_device *ndev)
-- 
1.9.1
