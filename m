From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 14/17] net: hns: modify tcam table of mac mc-entry
Date: Wed, 9 Nov 2016 18:13:58 +0000
Message-ID: <20161109181401.913728-15-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Qianqian Xie <xieqianqian@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:55115 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753949AbcKISPx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:15:53 -0500
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

The current definition of mac_mc_entry is only suitable for
Little-endian. Thus it needs to modify tcam table of mac mc-entry
to support both Little-endian and Big-endian.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   25 +++++++++++++-------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 27eb85c..74ca53d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -1604,6 +1604,7 @@ int hns_dsaf_set_mac_mc_entry(
 	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
 	struct dsaf_drv_soft_mac_tbl *soft_mac_entry = priv->soft_mac_tbl;
 	struct dsaf_drv_tbl_tcam_key tmp_mac_key;
+	struct dsaf_tbl_tcam_data tcam_data;
 
 	/* mac addr check */
 	if (MAC_IS_ALL_ZEROS(mac_entry->addr)) {
@@ -1636,9 +1637,12 @@ int hns_dsaf_set_mac_mc_entry(
 		       0, sizeof(mac_data.tbl_mcast_port_msk));
 	} else {
 		/* config hardware entry */
-		hns_dsaf_tcam_mc_get(
-			dsaf_dev, entry_index,
-			(struct dsaf_tbl_tcam_data *)(&tmp_mac_key), &mac_data);
+		hns_dsaf_tcam_mc_get(dsaf_dev, entry_index, &tcam_data,
+				     &mac_data);
+
+		tmp_mac_key.high.val =
+			le32_to_cpu(tcam_data.tbl_tcam_data_high);
+		tmp_mac_key.low.val = le32_to_cpu(tcam_data.tbl_tcam_data_low);
 	}
 	mac_data.tbl_mcast_old_en = 0;
 	mac_data.tbl_mcast_item_vld = 1;
@@ -1650,9 +1654,11 @@ int hns_dsaf_set_mac_mc_entry(
 		dsaf_dev->ae_dev.name, mac_key.high.val,
 		mac_key.low.val, entry_index);
 
-	hns_dsaf_tcam_mc_cfg(
-		dsaf_dev, entry_index,
-		(struct dsaf_tbl_tcam_data *)(&mac_key), NULL, &mac_data);
+	tcam_data.tbl_tcam_data_high = cpu_to_le32(mac_key.high.val);
+	tcam_data.tbl_tcam_data_low = cpu_to_le32(mac_key.low.val);
+
+	hns_dsaf_tcam_mc_cfg(dsaf_dev, entry_index, &tcam_data, NULL,
+			     &mac_data);
 
 	/* config software entry */
 	soft_mac_entry += entry_index;
@@ -2012,6 +2018,7 @@ int hns_dsaf_get_mac_mc_entry(struct dsaf_device *dsaf_dev,
 	struct dsaf_drv_tbl_tcam_key mac_key;
 
 	struct dsaf_tbl_tcam_mcast_cfg mac_data;
+	struct dsaf_tbl_tcam_data tcam_data;
 
 	/*check mac addr */
 	if (MAC_IS_ALL_ZEROS(mac_entry->addr) ||
@@ -2041,8 +2048,10 @@ int hns_dsaf_get_mac_mc_entry(struct dsaf_device *dsaf_dev,
 		mac_key.low.val, entry_index);
 
 	/*read entry */
-	hns_dsaf_tcam_mc_get(dsaf_dev, entry_index,
-			     (struct dsaf_tbl_tcam_data *)&mac_key, &mac_data);
+	hns_dsaf_tcam_mc_get(dsaf_dev, entry_index, &tcam_data, &mac_data);
+
+	mac_key.high.val = le32_to_cpu(tcam_data.tbl_tcam_data_high);
+	mac_key.low.val = le32_to_cpu(tcam_data.tbl_tcam_data_low);
 
 	mac_entry->port_mask[0] = mac_data.tbl_mcast_port_msk[0] & 0x3F;
 	return 0;
-- 
1.7.9.5
