From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH net 2/2] net: hns: update pause regs to dump function
Date: Fri, 4 Mar 2016 12:40:50 +0800
Message-ID: <1457066450-72395-3-git-send-email-lisheng011@huawei.com>
References: <1457066450-72395-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: haifeng.wei@huawei.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, xuwei5@hisilicon.com, linuxarm@huawei.com,
 linux-arm-kernel@lists.infradead.org, kenneth-lee-2012@foxmail.com
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
 <liguozhu@huawei.com>, <huangdaode@hisilicon.com>,
 <lisheng011@huawei.com>, <yankejian@huawei.com>, <arnd@arndb.de>,
 <andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
 <chenny.xu@huawei.com>, <ivecera@redhat.com>, <fengguang.wu@intel.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1457066450-72395-1-git-send-email-lisheng011@huawei.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Add two new regs to dump and stats function:
	DSAF_PAUSE_CFG_REG
	DSAFV2_INODE_FINAL_IN_PAUSE_NUM_0_REG.

Signed-off-by: Lisheng <lisheng011@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 58d6091..d10f036 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2012,6 +2012,8 @@ void hns_dsaf_update_stats(struct dsaf_device *dsaf_dev, u32 node_num)
 {
 	struct dsaf_hw_stats *hw_stats
 		= &dsaf_dev->hw_stats[node_num];
+	bool is_ver1 = AE_IS_VER1(dsaf_dev->dsaf_ver);
+	u32 reg_tmp;
 
 	hw_stats->pad_drop += dsaf_read_dev(dsaf_dev,
 		DSAF_INODE_PAD_DISCARD_NUM_0_REG + 0x80 * (u64)node_num);
@@ -2021,8 +2023,12 @@ void hns_dsaf_update_stats(struct dsaf_device *dsaf_dev, u32 node_num)
 		DSAF_INODE_FINAL_IN_PKT_NUM_0_REG + 0x80 * (u64)node_num);
 	hw_stats->rx_pkt_id += dsaf_read_dev(dsaf_dev,
 		DSAF_INODE_SBM_PID_NUM_0_REG + 0x80 * (u64)node_num);
-	hw_stats->rx_pause_frame += dsaf_read_dev(dsaf_dev,
-		DSAF_INODE_FINAL_IN_PAUSE_NUM_0_REG + 0x80 * (u64)node_num);
+
+	reg_tmp = is_ver1 ? DSAF_INODE_FINAL_IN_PAUSE_NUM_0_REG :
+			    DSAFV2_INODE_FINAL_IN_PAUSE_NUM_0_REG;
+	hw_stats->rx_pause_frame +=
+		dsaf_read_dev(dsaf_dev, reg_tmp + 0x80 * (u64)node_num);
+
 	hw_stats->release_buf_num += dsaf_read_dev(dsaf_dev,
 		DSAF_INODE_SBM_RELS_NUM_0_REG + 0x80 * (u64)node_num);
 	hw_stats->sbm_drop += dsaf_read_dev(dsaf_dev,
@@ -2055,6 +2061,8 @@ void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data)
 	u32 i = 0;
 	u32 j;
 	u32 *p = data;
+	u32 reg_tmp;
+	bool is_ver1 = AE_IS_VER1(ddev->dsaf_ver);
 
 	/* dsaf common registers */
 	p[0] = dsaf_read_dev(ddev, DSAF_SRAM_INIT_OVER_0_REG);
@@ -2119,8 +2127,9 @@ void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data)
 				DSAF_INODE_FINAL_IN_PKT_NUM_0_REG + j * 0x80);
 		p[190 + i] = dsaf_read_dev(ddev,
 				DSAF_INODE_SBM_PID_NUM_0_REG + j * 0x80);
-		p[193 + i] = dsaf_read_dev(ddev,
-				DSAF_INODE_FINAL_IN_PAUSE_NUM_0_REG + j * 0x80);
+		reg_tmp = is_ver1 ? DSAF_INODE_FINAL_IN_PAUSE_NUM_0_REG :
+				    DSAFV2_INODE_FINAL_IN_PAUSE_NUM_0_REG;
+		p[193 + i] = dsaf_read_dev(ddev, reg_tmp + j * 0x80);
 		p[196 + i] = dsaf_read_dev(ddev,
 				DSAF_INODE_SBM_RELS_NUM_0_REG + j * 0x80);
 		p[199 + i] = dsaf_read_dev(ddev,
@@ -2367,8 +2376,11 @@ void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data)
 	p[496] = dsaf_read_dev(ddev, DSAF_NETPORT_CTRL_SIG_0_REG + port * 0x4);
 	p[497] = dsaf_read_dev(ddev, DSAF_XGE_CTRL_SIG_CFG_0_REG + port * 0x4);
 
+	if (!is_ver1)
+		p[498] = dsaf_read_dev(ddev, DSAF_PAUSE_CFG_REG + port * 0x4);
+
 	/* mark end of dsaf regs */
-	for (i = 498; i < 504; i++)
+	for (i = 499; i < 504; i++)
 		p[i] = 0xdddddddd;
 }
 
-- 
1.9.1
