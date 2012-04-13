From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 17/37] atl1c: clear PCIE error status in atl1c_reset_pcie
Date: Fri, 13 Apr 2012 08:14:42 +0800
Message-ID: <1334276102-15866-18-git-send-email-xiong@qca.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

clear PCIE error status (error log is write-1-clear).
Reg definition of REG_PCIE_UC_SEVERITY is refined as well.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   34 +++++++++++++++-------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    5 ++-
 2 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index b9fa854..a4fd36e 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -70,6 +70,18 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define DEVICE_CTRL_NFERR_EN		BIT(1)
 #define DEVICE_CTRL_CERR_EN		BIT(0)
 
+#define REG_DEVICE_STAT			0x62	/* 16bit */
+#define DEVICE_STAT_XS_PEND		BIT(5)
+#define DEVICE_STAT_AUXPWR		BIT(4)
+#define DEVICE_STAT_UR			BIT(3)
+#define DEVICE_STAT_FERR		BIT(2)
+#define DEVICE_STAT_NFERR		BIT(1)
+#define DEVICE_STAT_CERR		BIT(0)
+#define DEVICE_STAT_ERR			(\
+	DEVICE_STAT_UR			|\
+	DEVICE_STAT_FERR		|\
+	DEVICE_STAT_NFERR		|\
+	DEVICE_STAT_CERR)
 
 #define REG_LINK_CTRL			0x68
 #define LINK_CTRL_L0S_EN		0x01
@@ -77,17 +89,17 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define LINK_CTRL_EXT_SYNC		0x80
 
 #define REG_PCIE_UC_SEVERITY		0x10C
-#define PCIE_UC_SERVRITY_TRN		0x00000001
-#define PCIE_UC_SERVRITY_DLP		0x00000010
-#define PCIE_UC_SERVRITY_PSN_TLP	0x00001000
-#define PCIE_UC_SERVRITY_FCP		0x00002000
-#define PCIE_UC_SERVRITY_CPL_TO		0x00004000
-#define PCIE_UC_SERVRITY_CA		0x00008000
-#define PCIE_UC_SERVRITY_UC		0x00010000
-#define PCIE_UC_SERVRITY_ROV		0x00020000
-#define PCIE_UC_SERVRITY_MLFP		0x00040000
-#define PCIE_UC_SERVRITY_ECRC		0x00080000
-#define PCIE_UC_SERVRITY_UR		0x00100000
+#define PCIE_UC_SEVERITY_UR		BIT(20)
+#define PCIE_UC_SERVRITY_ECRC		BIT(19)
+#define PCIE_UC_SERVRITY_MLFP		BIT(18)
+#define PCIE_UC_SERVRITY_ROV		BIT(17)
+#define PCIE_UC_SERVRITY_UC		BIT(16)
+#define PCIE_UC_SERVRITY_CA		BIT(15)
+#define PCIE_UC_SERVRITY_CPL_TO		BIT(14)
+#define PCIE_UC_SERVRITY_FCP		BIT(13)
+#define PCIE_UC_SERVRITY_PSN_TLP	BIT(12)
+#define PCIE_UC_SERVRITY_DLP		BIT(4)
+#define PCIE_UC_SERVRITY_TRN		BIT(0)
 
 #define REG_DEV_SERIALNUM_CTRL		0x200
 #define REG_DEV_MAC_SEL_MASK		0x0 /* 0:EUI; 1:MAC */
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 4a0d26c..9295aee 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -125,9 +125,10 @@ static void atl1c_reset_pcie(struct atl1c_hw *hw, u32 flag)
 	 * Mask some pcie error bits
 	 */
 	AT_READ_REG(hw, REG_PCIE_UC_SEVERITY, &data);
-	data &= ~PCIE_UC_SERVRITY_DLP;
-	data &= ~PCIE_UC_SERVRITY_FCP;
+	data &= ~(PCIE_UC_SERVRITY_DLP | PCIE_UC_SERVRITY_FCP);
 	AT_WRITE_REG(hw, REG_PCIE_UC_SEVERITY, data);
+	/* clear error status */
+	AT_WRITE_REGW(hw, REG_DEVICE_STAT, DEVICE_STAT_ERR);
 
 	AT_READ_REG(hw, REG_LTSSM_ID_CTRL, &data);
 	data &= ~LTSSM_ID_EN_WRO;
-- 
1.7.7
