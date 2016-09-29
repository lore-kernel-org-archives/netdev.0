From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 for-next 2/8] net: hns: bug fix about setting coalsecs-usecs to 0
Date: Thu, 29 Sep 2016 18:09:10 +0100
Message-ID: <20160929170916.631972-3-salil.mehta@huawei.com>
References: <20160929170916.631972-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <xavier.huwei@huawei.com>, <oulijun@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, Daode Huang <huangdaode@hisilicon.com>
To: <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160929170916.631972-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

When set rx/tx coalesce usecs to 0, the interrupt coalesce will be
disabled, but there is a interrupt rate limit which set to 1us, it
will cause no interrupt occurs. This patch disable interrupt limit
when sets coalsecs usecs to 0, and restores it to 1 in other case.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c |   16 ++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |    4 ++++
 2 files changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index ef11077..f0ed80d6 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -543,6 +543,22 @@ int hns_rcb_set_coalesce_usecs(
 			"error: coalesce_usecs setting supports 0~1023us\n");
 		return -EINVAL;
 	}
+
+	if (!AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver)) {
+		if (timeout == 0)
+			/* set timeout to 0, Disable gap time */
+			dsaf_set_reg_field(rcb_common->io_base,
+					   RCB_INT_GAP_TIME_REG + port_idx * 4,
+					   PPE_INT_GAPTIME_M, PPE_INT_GAPTIME_B,
+					   0);
+		else
+			/* set timeout non 0, restore gap time to 1 */
+			dsaf_set_reg_field(rcb_common->io_base,
+					   RCB_INT_GAP_TIME_REG + port_idx * 4,
+					   PPE_INT_GAPTIME_M, PPE_INT_GAPTIME_B,
+					   1);
+	}
+
 	hns_rcb_set_port_timeout(rcb_common, port_idx, timeout);
 	return 0;
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 4b8b803..878950a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -417,6 +417,7 @@
 #define RCB_CFG_OVERTIME_REG			0x9300
 #define RCB_CFG_PKTLINE_INT_NUM_REG		0x9304
 #define RCB_CFG_OVERTIME_INT_NUM_REG		0x9308
+#define RCB_INT_GAP_TIME_REG			0x9400
 #define RCB_PORT_CFG_OVERTIME_REG		0x9430
 
 #define RCB_RING_RX_RING_BASEADDR_L_REG		0x00000
@@ -898,6 +899,9 @@
 #define PPE_CNT_CLR_CE_B	0
 #define PPE_CNT_CLR_SNAP_EN_B	1
 
+#define PPE_INT_GAPTIME_B	0
+#define PPE_INT_GAPTIME_M	0x3ff
+
 #define PPE_COMMON_CNT_CLR_CE_B	0
 #define PPE_COMMON_CNT_CLR_SNAP_EN_B	1
 #define RCB_COM_TSO_MODE_B	0
-- 
1.7.9.5
