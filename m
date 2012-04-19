From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 05/11] atl1c: clear PCIE error status in atl1c_reset_pcie
Date: Thu, 19 Apr 2012 16:01:25 +0800
Message-ID: <1334822491-30129-6-git-send-email-xiong@qca.qualcomm.com>
References: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

clear PCIE error status (error log is write-1-clear).
REG_PCIE_UC_SEVERITY is removed as it's a standard pcie register,
and using kernle API to access it.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   13 -------------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   15 +++++++++++----
 2 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index c9c6782..6d73ac9 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -61,19 +61,6 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define LINK_CTRL_L1_EN			0x02
 #define LINK_CTRL_EXT_SYNC		0x80
 
-#define REG_PCIE_UC_SEVERITY		0x10C
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
-
 #define REG_DEV_SERIALNUM_CTRL		0x200
 #define REG_DEV_MAC_SEL_MASK		0x0 /* 0:EUI; 1:MAC */
 #define REG_DEV_MAC_SEL_SHIFT		0
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 12b4725..729381a 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -108,6 +108,7 @@ static void atl1c_reset_pcie(struct atl1c_hw *hw, u32 flag)
 	u32 data;
 	u32 pci_cmd;
 	struct pci_dev *pdev = hw->adapter->pdev;
+	int pos;
 
 	AT_READ_REG(hw, PCI_COMMAND, &pci_cmd);
 	pci_cmd &= ~PCI_COMMAND_INTX_DISABLE;
@@ -124,10 +125,16 @@ static void atl1c_reset_pcie(struct atl1c_hw *hw, u32 flag)
 	/*
 	 * Mask some pcie error bits
 	 */
-	AT_READ_REG(hw, REG_PCIE_UC_SEVERITY, &data);
-	data &= ~PCIE_UC_SERVRITY_DLP;
-	data &= ~PCIE_UC_SERVRITY_FCP;
-	AT_WRITE_REG(hw, REG_PCIE_UC_SEVERITY, data);
+	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_ERR);
+	pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_SEVER, &data);
+	data &= ~(PCI_ERR_UNC_DLP | PCI_ERR_UNC_FCP);
+	pci_write_config_dword(pdev, pos + PCI_ERR_UNCOR_SEVER, data);
+	/* clear error status */
+	pci_write_config_word(pdev, pci_pcie_cap(pdev) + PCI_EXP_DEVSTA,
+			PCI_EXP_DEVSTA_NFED |
+			PCI_EXP_DEVSTA_FED |
+			PCI_EXP_DEVSTA_CED |
+			PCI_EXP_DEVSTA_URD);
 
 	AT_READ_REG(hw, REG_LTSSM_ID_CTRL, &data);
 	data &= ~LTSSM_ID_EN_WRO;
-- 
1.7.7
