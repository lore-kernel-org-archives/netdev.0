From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 13/17] net: hns: modify tcam table of mac mc-port
Date: Wed, 9 Nov 2016 18:13:57 +0000
Message-ID: <20161109181401.913728-14-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Qianqian Xie <xieqianqian@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:55119 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754552AbcKISPy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:15:54 -0500
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

Little-endian is only supported by current tcam table to add
or delete mac mc-port. This patch makes it support both
Little-endian and Big-endian.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index bd6e5b0..27eb85c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -1688,6 +1688,7 @@ int hns_dsaf_add_mac_mc_port(struct dsaf_device *dsaf_dev,
 	struct dsaf_tbl_tcam_mcast_cfg mac_data;
 	struct dsaf_drv_priv *priv = hns_dsaf_dev_priv(dsaf_dev);
 	struct dsaf_drv_soft_mac_tbl *soft_mac_entry = priv->soft_mac_tbl;
+	struct dsaf_drv_tbl_tcam_key tmp_mac_key;
 	struct dsaf_tbl_tcam_data tcam_data;
 	u8 mc_addr[ETH_ALEN];
 	u8 *mc_mask;
@@ -1738,6 +1739,10 @@ int hns_dsaf_add_mac_mc_port(struct dsaf_device *dsaf_dev,
 		/* if exist, add in */
 		hns_dsaf_tcam_mc_get(dsaf_dev, entry_index, &tcam_data,
 				     &mac_data);
+
+		tmp_mac_key.high.val =
+			le32_to_cpu(tcam_data.tbl_tcam_data_high);
+		tmp_mac_key.low.val = le32_to_cpu(tcam_data.tbl_tcam_data_low);
 	}
 
 	/* config hardware entry */
@@ -1762,8 +1767,8 @@ int hns_dsaf_add_mac_mc_port(struct dsaf_device *dsaf_dev,
 		dsaf_dev->ae_dev.name, mac_key.high.val,
 		mac_key.low.val, entry_index);
 
-	tcam_data.tbl_tcam_data_high = mac_key.high.val;
-	tcam_data.tbl_tcam_data_low = mac_key.low.val;
+	tcam_data.tbl_tcam_data_high = cpu_to_le32(mac_key.high.val);
+	tcam_data.tbl_tcam_data_low = cpu_to_le32(mac_key.low.val);
 
 	/* config mc entry with mask */
 	hns_dsaf_tcam_mc_cfg(dsaf_dev, entry_index, &tcam_data,
@@ -1847,7 +1852,7 @@ int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
 	struct dsaf_tbl_tcam_data tcam_data;
 	int mskid;
 	const u8 empty_msk[sizeof(mac_data.tbl_mcast_port_msk)] = {0};
-	struct dsaf_drv_tbl_tcam_key mask_key;
+	struct dsaf_drv_tbl_tcam_key mask_key, tmp_mac_key;
 	struct dsaf_tbl_tcam_data *pmask_key = NULL;
 	u8 mc_addr[ETH_ALEN];
 	u8 *mc_mask;
@@ -1905,6 +1910,9 @@ int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
 	/* read entry */
 	hns_dsaf_tcam_mc_get(dsaf_dev, entry_index, &tcam_data, &mac_data);
 
+	tmp_mac_key.high.val = le32_to_cpu(tcam_data.tbl_tcam_data_high);
+	tmp_mac_key.low.val = le32_to_cpu(tcam_data.tbl_tcam_data_low);
+
 	/*del the port*/
 	if (mac_entry->port_num < DSAF_SERVICE_NW_NUM) {
 		mskid = mac_entry->port_num;
@@ -1929,8 +1937,8 @@ int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
 		soft_mac_entry += entry_index;
 		soft_mac_entry->index = DSAF_INVALID_ENTRY_IDX;
 	} else { /* not zero, just del port, update */
-		tcam_data.tbl_tcam_data_high = mac_key.high.val;
-		tcam_data.tbl_tcam_data_low = mac_key.low.val;
+		tcam_data.tbl_tcam_data_high = cpu_to_le32(mac_key.high.val);
+		tcam_data.tbl_tcam_data_low = cpu_to_le32(mac_key.low.val);
 
 		hns_dsaf_tcam_mc_cfg(dsaf_dev, entry_index,
 				     &tcam_data,
-- 
1.7.9.5
