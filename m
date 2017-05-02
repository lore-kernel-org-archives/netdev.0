From: Timmy Li <lixiaoping3@huawei.com>
Subject: [PATCH net v2] net: hns: fix ethtool_get_strings overflow in hns driver
Date: Tue, 2 May 2017 10:46:52 +0800
Message-ID: <20170502024652.39536-1-lixiaoping3@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mbrugger@suse.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Timmy Li <lixiaoping3@huawei.com>
To: <davem@davemloft.net>, <huangdaode@hisilicon.com>,
        <lipeng321@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <yankejian@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hns_get_sset_count() returns HNS_NET_STATS_CNT and the data space allocated
is not enough for ethtool_get_strings(), which will cause random memory
corruption.

When SLAB and DEBUG_SLAB are both enabled, memory corruptions like the
the following can be observed without this patch:
[   43.115200] Slab corruption (Not tainted): Acpi-ParseExt start=ffff801fb0b69030, len=80
[   43.115206] Redzone: 0x9f911029d006462/0x5f78745f31657070.
[   43.115208] Last user: [<5f7272655f746b70>](0x5f7272655f746b70)
[   43.115214] 010: 70 70 65 31 5f 74 78 5f 70 6b 74 00 6b 6b 6b 6b  ppe1_tx_pkt.kkkk
[   43.115217] 030: 70 70 65 31 5f 74 78 5f 70 6b 74 5f 6f 6b 00 6b  ppe1_tx_pkt_ok.k
[   43.115218] Next obj: start=ffff801fb0b69098, len=80
[   43.115220] Redzone: 0x706d655f6f666966/0x9f911029d74e35b.
[   43.115229] Last user: [<ffff0000084b11b0>](acpi_os_release_object+0x28/0x38)
[   43.115231] 000: 74 79 00 6b 6b 6b 6b 6b 70 70 65 31 5f 74 78 5f  ty.kkkkkppe1_tx_
[   43.115232] 010: 70 6b 74 5f 65 72 72 5f 63 73 75 6d 5f 66 61 69  pkt_err_csum_fai

Signed-off-by: Timmy Li <lixiaoping3@huawei.com>
---
Changelog:

v1 -> v2:
    * Remove unnecessary parenthesis
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c  | 2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c   | 2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c   | 2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 3382441..310cc92 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -672,7 +672,7 @@ static void hns_gmac_get_strings(u32 stringset, u8 *data)
 
 static int hns_gmac_get_sset_count(int stringset)
 {
-	if (stringset == ETH_SS_STATS)
+	if (stringset == ETH_SS_STATS || stringset == ETH_SS_PRIV_FLAGS)
 		return ARRAY_SIZE(g_gmac_stats_string);
 
 	return 0;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index 6ea8722..4ecb809 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -422,7 +422,7 @@ void hns_ppe_update_stats(struct hns_ppe_cb *ppe_cb)
 
 int hns_ppe_get_sset_count(int stringset)
 {
-	if (stringset == ETH_SS_STATS)
+	if (stringset == ETH_SS_STATS || stringset == ETH_SS_PRIV_FLAGS)
 		return ETH_PPE_STATIC_NUM;
 	return 0;
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index f0ed80d6..c176db0 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -799,7 +799,7 @@ void hns_rcb_get_stats(struct hnae_queue *queue, u64 *data)
  */
 int hns_rcb_get_ring_sset_count(int stringset)
 {
-	if (stringset == ETH_SS_STATS)
+	if (stringset == ETH_SS_STATS || stringset == ETH_SS_PRIV_FLAGS)
 		return HNS_RING_STATIC_REG_NUM;
 
 	return 0;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
index aae830a..faacab8 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
@@ -793,7 +793,7 @@ static void hns_xgmac_get_strings(u32 stringset, u8 *data)
  */
 static int hns_xgmac_get_sset_count(int stringset)
 {
-	if (stringset == ETH_SS_STATS)
+	if (stringset == ETH_SS_STATS || stringset == ETH_SS_PRIV_FLAGS)
 		return ARRAY_SIZE(g_xgmac_stats_string);
 
 	return 0;
-- 
1.9.1
