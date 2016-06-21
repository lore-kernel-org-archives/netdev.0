From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 11/19] net: hns: add spin lock for tcam table operation
Date: Tue, 21 Jun 2016 11:56:31 +0800
Message-ID: <1466481399-70080-12-git-send-email-Yisen.Zhuang@huawei.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

This patch adds spin lock for tcam table operation,
there maybe a race condition happens when more than
one thread try to change the tcam talbe entries.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 25 ++++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  2 ++
 2 files changed, 27 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 0edea9c..0958ceb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -860,6 +860,8 @@ static void hns_dsaf_single_line_tbl_cfg(
 	struct dsaf_device *dsaf_dev,
 	u32 address, struct dsaf_tbl_line_cfg *ptbl_line)
 {
+	spin_lock_bh(&dsaf_dev->tcam_lock);
+
 	/*Write Addr*/
 	hns_dsaf_tbl_line_addr_cfg(dsaf_dev, address);
 
@@ -868,6 +870,8 @@ static void hns_dsaf_single_line_tbl_cfg(
 
 	/*Write Plus*/
 	hns_dsaf_tbl_line_pul(dsaf_dev);
+
+	spin_unlock_bh(&dsaf_dev->tcam_lock);
 }
 
 /**
@@ -881,6 +885,8 @@ static void hns_dsaf_tcam_uc_cfg(
 	struct dsaf_tbl_tcam_data *ptbl_tcam_data,
 	struct dsaf_tbl_tcam_ucast_cfg *ptbl_tcam_ucast)
 {
+	spin_lock_bh(&dsaf_dev->tcam_lock);
+
 	/*Write Addr*/
 	hns_dsaf_tbl_tcam_addr_cfg(dsaf_dev, address);
 	/*Write Tcam Data*/
@@ -889,6 +895,8 @@ static void hns_dsaf_tcam_uc_cfg(
 	hns_dsaf_tbl_tcam_ucast_cfg(dsaf_dev, ptbl_tcam_ucast);
 	/*Write Plus*/
 	hns_dsaf_tbl_tcam_data_ucast_pul(dsaf_dev);
+
+	spin_unlock_bh(&dsaf_dev->tcam_lock);
 }
 
 /**
@@ -903,6 +911,8 @@ static void hns_dsaf_tcam_mc_cfg(
 	struct dsaf_tbl_tcam_data *ptbl_tcam_data,
 	struct dsaf_tbl_tcam_mcast_cfg *ptbl_tcam_mcast)
 {
+	spin_lock_bh(&dsaf_dev->tcam_lock);
+
 	/*Write Addr*/
 	hns_dsaf_tbl_tcam_addr_cfg(dsaf_dev, address);
 	/*Write Tcam Data*/
@@ -911,6 +921,8 @@ static void hns_dsaf_tcam_mc_cfg(
 	hns_dsaf_tbl_tcam_mcast_cfg(dsaf_dev, ptbl_tcam_mcast);
 	/*Write Plus*/
 	hns_dsaf_tbl_tcam_data_mcast_pul(dsaf_dev);
+
+	spin_unlock_bh(&dsaf_dev->tcam_lock);
 }
 
 /**
@@ -920,6 +932,8 @@ static void hns_dsaf_tcam_mc_cfg(
  */
 static void hns_dsaf_tcam_mc_invld(struct dsaf_device *dsaf_dev, u32 address)
 {
+	spin_lock_bh(&dsaf_dev->tcam_lock);
+
 	/*Write Addr*/
 	hns_dsaf_tbl_tcam_addr_cfg(dsaf_dev, address);
 
@@ -932,6 +946,8 @@ static void hns_dsaf_tcam_mc_invld(struct dsaf_device *dsaf_dev, u32 address)
 
 	/*Write Plus*/
 	hns_dsaf_tbl_tcam_mcast_pul(dsaf_dev);
+
+	spin_unlock_bh(&dsaf_dev->tcam_lock);
 }
 
 /**
@@ -949,6 +965,8 @@ static void hns_dsaf_tcam_uc_get(
 	u32 tcam_read_data0;
 	u32 tcam_read_data4;
 
+	spin_lock_bh(&dsaf_dev->tcam_lock);
+
 	/*Write Addr*/
 	hns_dsaf_tbl_tcam_addr_cfg(dsaf_dev, address);
 
@@ -981,6 +999,8 @@ static void hns_dsaf_tcam_uc_get(
 				 DSAF_TBL_UCAST_CFG1_OUT_PORT_S);
 	ptbl_tcam_ucast->tbl_ucast_dvc
 		= dsaf_get_bit(tcam_read_data0, DSAF_TBL_UCAST_CFG1_DVC_S);
+
+	spin_unlock_bh(&dsaf_dev->tcam_lock);
 }
 
 /**
@@ -997,6 +1017,8 @@ static void hns_dsaf_tcam_mc_get(
 {
 	u32 data_tmp;
 
+	spin_lock_bh(&dsaf_dev->tcam_lock);
+
 	/*Write Addr*/
 	hns_dsaf_tbl_tcam_addr_cfg(dsaf_dev, address);
 
@@ -1027,6 +1049,8 @@ static void hns_dsaf_tcam_mc_get(
 	ptbl_tcam_mcast->tbl_mcast_port_msk[4] =
 		dsaf_get_field(data_tmp, DSAF_TBL_MCAST_CFG4_VM128_112_M,
 			       DSAF_TBL_MCAST_CFG4_VM128_112_S);
+
+	spin_unlock_bh(&dsaf_dev->tcam_lock);
 }
 
 /**
@@ -1351,6 +1375,7 @@ static int hns_dsaf_init(struct dsaf_device *dsaf_dev)
 	if (HNS_DSAF_IS_DEBUG(dsaf_dev))
 		return 0;
 
+	spin_lock_init(&dsaf_dev->tcam_lock);
 	ret = hns_dsaf_init_hw(dsaf_dev);
 	if (ret)
 		return ret;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 00a13de..1daf018 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -322,6 +322,8 @@ struct dsaf_device {
 
 	struct dsaf_hw_stats hw_stats[DSAF_NODE_NUM];
 	struct dsaf_int_stat int_stat;
+	/* make sure tcam table config spinlock */
+	spinlock_t tcam_lock;
 };
 
 static inline void *hns_dsaf_dev_priv(const struct dsaf_device *dsaf_dev)
-- 
1.9.1
