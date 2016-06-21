From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 07/19] net: hns: select Hilink before serdes loopback for HNS V2
Date: Tue, 21 Jun 2016 11:56:27 +0800
Message-ID: <1466481399-70080-8-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <yankejian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:43090 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbcFUDiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 23:38:23 -0400
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kejian Yan <yankejian@huawei.com>

As Hilink3 and Hilink4 use the same xge training and xge u adaptor for
HNSv2, it needs to select which Hilink to be set before relative serdes
being configed. The hilink_access_sel is the register to do that.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 26 +++++++++++++++++-----
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 09e60d6..aff9d77 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -435,11 +435,6 @@ int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
  */
 static int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, bool en)
 {
-	/* port 0-3 hilink4 base is serdes_vaddr + 0x00280000
-	 * port 4-7 hilink3 base is serdes_vaddr + 0x00200000
-	 */
-	u8 *base_addr = (u8 *)mac_cb->serdes_vaddr +
-		       (mac_cb->mac_id <= 3 ? 0x00280000 : 0x00200000);
 	const u8 lane_id[] = {
 		0,	/* mac 0 -> lane 0 */
 		1,	/* mac 1 -> lane 1 */
@@ -465,11 +460,30 @@ static int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, bool en)
 	}
 
 	if (mac_cb->serdes_ctrl) {
-		u32 origin = dsaf_read_syscon(mac_cb->serdes_ctrl, reg_offset);
+		u32 origin;
+
+		if (!AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver)) {
+#define HILINK_ACCESS_SEL_CFG		0x40008
+			/* hilink4 & hilink3 use the same xge training and
+			 * xge u adaptor. There is a hilink access sel cfg
+			 * register to select which one to be configed
+			 */
+			if ((!HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev)) &&
+			    (mac_cb->mac_id <= 3))
+				dsaf_write_syscon(mac_cb->serdes_ctrl,
+						  HILINK_ACCESS_SEL_CFG, 0);
+			else
+				dsaf_write_syscon(mac_cb->serdes_ctrl,
+						  HILINK_ACCESS_SEL_CFG, 3);
+		}
+
+		origin = dsaf_read_syscon(mac_cb->serdes_ctrl, reg_offset);
 
 		dsaf_set_field(origin, 1ull << 10, 10, en);
 		dsaf_write_syscon(mac_cb->serdes_ctrl, reg_offset, origin);
 	} else {
+		u8 *base_addr = (u8 *)mac_cb->serdes_vaddr +
+				(mac_cb->mac_id <= 3 ? 0x00280000 : 0x00200000);
 		dsaf_set_reg_field(base_addr, reg_offset, 1ull << 10, 10, en);
 	}
 
-- 
1.9.1
