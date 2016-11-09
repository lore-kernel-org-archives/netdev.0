From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 12/17] net: hns: modify table index to get mac entry
Date: Wed, 9 Nov 2016 18:13:56 +0000
Message-ID: <20161109181401.913728-13-salil.mehta@huawei.com>
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

Big-endian is not supported by the current definition of table index to get
mac entry. It needs to be modified to support both Little-endian
and Big-endian.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 1713f8d..bd6e5b0 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2054,6 +2054,7 @@ int hns_dsaf_get_mac_entry_by_index(
 
 	struct dsaf_tbl_tcam_mcast_cfg mac_data;
 	struct dsaf_tbl_tcam_ucast_cfg mac_uc_data;
+	struct dsaf_tbl_tcam_data tcam_data;
 	char mac_addr[ETH_ALEN] = {0};
 
 	if (entry_index >= dsaf_dev->tcam_max_num) {
@@ -2064,8 +2065,10 @@ int hns_dsaf_get_mac_entry_by_index(
 	}
 
 	/* mc entry, do read opt */
-	hns_dsaf_tcam_mc_get(dsaf_dev, entry_index,
-			     (struct dsaf_tbl_tcam_data *)&mac_key, &mac_data);
+	hns_dsaf_tcam_mc_get(dsaf_dev, entry_index, &tcam_data, &mac_data);
+
+	mac_key.high.val = le32_to_cpu(tcam_data.tbl_tcam_data_high);
+	mac_key.low.val = le32_to_cpu(tcam_data.tbl_tcam_data_low);
 
 	mac_entry->port_mask[0] = mac_data.tbl_mcast_port_msk[0] & 0x3F;
 
@@ -2082,9 +2085,12 @@ int hns_dsaf_get_mac_entry_by_index(
 		/**mc donot do*/
 	} else {
 		/*is not mc, just uc... */
-		hns_dsaf_tcam_uc_get(dsaf_dev, entry_index,
-				     (struct dsaf_tbl_tcam_data *)&mac_key,
+		hns_dsaf_tcam_uc_get(dsaf_dev, entry_index, &tcam_data,
 				     &mac_uc_data);
+
+		mac_key.high.val = le32_to_cpu(tcam_data.tbl_tcam_data_high);
+		mac_key.low.val = le32_to_cpu(tcam_data.tbl_tcam_data_low);
+
 		mac_entry->port_mask[0] = (1 << mac_uc_data.tbl_ucast_out_port);
 	}
 
-- 
1.7.9.5
