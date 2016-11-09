From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 10/17] net: hns: modify tcam table and set mac key
Date: Wed, 9 Nov 2016 18:13:54 +0000
Message-ID: <20161109181401.913728-11-salil.mehta@huawei.com>
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

The current definition of dsaf_drv_tbl_tcam_key is only suitable for
Little-endian. If data is stored in Big-endian, this may lead to
error in data use. Shift operation can make it work normally in both
Big-endian and Little-endian.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   16 ++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |   13 ++++++++-----
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 2721458..db23eef 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -1509,8 +1509,12 @@ static void hns_dsaf_set_mac_key(
 	mac_key->high.bits.mac_3 = addr[3];
 	mac_key->low.bits.mac_4 = addr[4];
 	mac_key->low.bits.mac_5 = addr[5];
-	mac_key->low.bits.vlan = vlan_id;
-	mac_key->low.bits.port = port;
+	dsaf_set_field(mac_key->low.bits.port_vlan, DSAF_TBL_TCAM_KEY_VLAN_M,
+		       DSAF_TBL_TCAM_KEY_VLAN_S, vlan_id);
+	dsaf_set_field(mac_key->low.bits.port_vlan, DSAF_TBL_TCAM_KEY_PORT_M,
+		       DSAF_TBL_TCAM_KEY_PORT_S, port);
+
+	mac_key->low.bits.port_vlan = le16_to_cpu(mac_key->low.bits.port_vlan);
 }
 
 /**
@@ -2760,8 +2764,12 @@ void hns_dsaf_set_promisc_tcam(struct dsaf_device *dsaf_dev,
 	if (enable) {
 		memset(&tbl_tcam_data, 0, sizeof(tbl_tcam_data));
 		memset(&tbl_tcam_mask, 0, sizeof(tbl_tcam_mask));
-		tbl_tcam_data.low.bits.port = port;
-		tbl_tcam_mask.low.bits.port = 0xf;  /* [3:0]: port id */
+		dsaf_set_field(tbl_tcam_data.low.bits.port_vlan,
+			       DSAF_TBL_TCAM_KEY_PORT_M,
+			       DSAF_TBL_TCAM_KEY_PORT_S, port);
+		dsaf_set_field(tbl_tcam_mask.low.bits.port_vlan,
+			       DSAF_TBL_TCAM_KEY_PORT_M,
+			       DSAF_TBL_TCAM_KEY_PORT_S, 0xf);
 
 		/* SUB_QID */
 		dsaf_set_bit(mac_data.tbl_mcast_port_msk[0],
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 7f70f34..c68555b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -357,6 +357,11 @@ static inline void *hns_dsaf_dev_priv(const struct dsaf_device *dsaf_dev)
 	return (void *)((u8 *)dsaf_dev + sizeof(*dsaf_dev));
 }
 
+#define DSAF_TBL_TCAM_KEY_PORT_S 0
+#define DSAF_TBL_TCAM_KEY_PORT_M (((1ULL << 4) - 1) << 0)
+#define DSAF_TBL_TCAM_KEY_VLAN_S 4
+#define DSAF_TBL_TCAM_KEY_VLAN_M (((1ULL << 12) - 1) << 4)
+
 struct dsaf_drv_tbl_tcam_key {
 	union {
 		struct {
@@ -370,11 +375,9 @@ struct dsaf_drv_tbl_tcam_key {
 	} high;
 	union {
 		struct {
-			u32 port:4; /* port id, */
-			/* dsaf-mode fixed 0, non-dsaf-mode port id*/
-			u32 vlan:12; /* vlan id */
-			u32 mac_5:8;
-			u32 mac_4:8;
+			u16 port_vlan;
+			u8 mac_5;
+			u8 mac_4;
 		} bits;
 
 		u32 val;
-- 
1.7.9.5
