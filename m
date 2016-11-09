From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 11/17] net: hns: modify tcam table of mac uc-entry
Date: Wed, 9 Nov 2016 18:13:55 +0000
Message-ID: <20161109181401.913728-12-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Qianqian Xie <xieqianqian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Qianqian Xie <xieqianqian@huawei.com>

The current definition of mac_uc_entry is only suitable for
Little-endian. Thus it needs to modify tcam table of mac uc-entry
to support both Little-endian and Big-endian.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index db23eef..1713f8d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -1532,6 +1532,7 @@ int hns_dsaf_set_mac_uc_entry(
 	struct dsaf_drv_priv *priv =
 	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
 	struct dsaf_drv_soft_mac_tbl *soft_mac_entry = priv->soft_mac_tbl;
+	struct dsaf_tbl_tcam_data tcam_data;
 
 	/* mac addr check */
 	if (MAC_IS_ALL_ZEROS(mac_entry->addr) ||
@@ -1573,9 +1574,10 @@ int hns_dsaf_set_mac_uc_entry(
 	/* default config dvc to 0 */
 	mac_data.tbl_ucast_dvc = 0;
 	mac_data.tbl_ucast_out_port = mac_entry->port_num;
-	hns_dsaf_tcam_uc_cfg(
-		dsaf_dev, entry_index,
-		(struct dsaf_tbl_tcam_data *)(&mac_key), &mac_data);
+	tcam_data.tbl_tcam_data_high = cpu_to_le32(mac_key.high.val);
+	tcam_data.tbl_tcam_data_low = cpu_to_le32(mac_key.low.val);
+
+	hns_dsaf_tcam_uc_cfg(dsaf_dev, entry_index, &tcam_data, &mac_data);
 
 	/* config software entry */
 	soft_mac_entry += entry_index;
@@ -1950,6 +1952,7 @@ int hns_dsaf_get_mac_uc_entry(struct dsaf_device *dsaf_dev,
 	struct dsaf_drv_tbl_tcam_key mac_key;
 
 	struct dsaf_tbl_tcam_ucast_cfg mac_data;
+	struct dsaf_tbl_tcam_data tcam_data;
 
 	/* check macaddr */
 	if (MAC_IS_ALL_ZEROS(mac_entry->addr) ||
@@ -1978,9 +1981,12 @@ int hns_dsaf_get_mac_uc_entry(struct dsaf_device *dsaf_dev,
 		dsaf_dev->ae_dev.name, mac_key.high.val,
 		mac_key.low.val, entry_index);
 
-	/*read entry*/
-	hns_dsaf_tcam_uc_get(dsaf_dev, entry_index,
-			     (struct dsaf_tbl_tcam_data *)&mac_key, &mac_data);
+	/* read entry */
+	hns_dsaf_tcam_uc_get(dsaf_dev, entry_index, &tcam_data, &mac_data);
+
+	mac_key.high.val = le32_to_cpu(tcam_data.tbl_tcam_data_high);
+	mac_key.low.val = le32_to_cpu(tcam_data.tbl_tcam_data_low);
+
 	mac_entry->port_num = mac_data.tbl_ucast_out_port;
 
 	return 0;
-- 
1.7.9.5
