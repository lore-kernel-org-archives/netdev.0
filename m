From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 36/37] atl1c: refine mac address related code
Date: Fri, 13 Apr 2012 08:15:01 +0800
Message-ID: <1334276102-15866-37-git-send-email-xiong@qca.qualcomm.com>
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

On some platform with EEPROM/OTP existing, the BIOS could overwrite
a new MAC address for the NIC. so, the permanent mac address should
be from BIOS. the address is restored when driver removing.
Voltage raising isn't applicable for l1d.
Replace swab32 with htonl for big/little endian platform.
related Registers are refined as well.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c   |   93 ++++++++++-------------
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   32 +++-----
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    6 +-
 3 files changed, 57 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index 3eaf78a..97f0f7e 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -43,7 +43,7 @@ int atl1c_check_eeprom_exist(struct atl1c_hw *hw)
 	return 0;
 }
 
-void atl1c_hw_set_mac_addr(struct atl1c_hw *hw)
+void atl1c_hw_set_mac_addr(struct atl1c_hw *hw, u8 *mac_addr)
 {
 	u32 value;
 	/*
@@ -51,33 +51,48 @@ void atl1c_hw_set_mac_addr(struct atl1c_hw *hw)
 	 * 0:  6AF600DC 1: 000B
 	 * low dword
 	 */
-	value = (((u32)hw->mac_addr[2]) << 24) |
-		(((u32)hw->mac_addr[3]) << 16) |
-		(((u32)hw->mac_addr[4]) << 8)  |
-		(((u32)hw->mac_addr[5])) ;
+	value = mac_addr[2] << 24 |
+		mac_addr[3] << 16 |
+		mac_addr[4] << 8  |
+		mac_addr[5];
 	AT_WRITE_REG_ARRAY(hw, REG_MAC_STA_ADDR, 0, value);
 	/* hight dword */
-	value = (((u32)hw->mac_addr[0]) << 8) |
-		(((u32)hw->mac_addr[1])) ;
+	value = mac_addr[0] << 8 |
+		mac_addr[1];
 	AT_WRITE_REG_ARRAY(hw, REG_MAC_STA_ADDR, 1, value);
 }
 
+/* read mac address from hardware register */
+static bool atl1c_read_current_addr(struct atl1c_hw *hw, u8 *eth_addr)
+{
+	u32 addr[2];
+
+	AT_READ_REG(hw, REG_MAC_STA_ADDR, &addr[0]);
+	AT_READ_REG(hw, REG_MAC_STA_ADDR + 4, &addr[1]);
+
+	*(u32 *) &eth_addr[2] = htonl(addr[0]);
+	*(u16 *) &eth_addr[0] = htons((u16)addr[1]);
+
+	return is_valid_ether_addr(eth_addr);
+}
+
 /*
  * atl1c_get_permanent_address
  * return 0 if get valid mac address,
  */
 static int atl1c_get_permanent_address(struct atl1c_hw *hw)
 {
-	u32 addr[2];
 	u32 i;
 	u32 otp_ctrl_data;
 	u32 twsi_ctrl_data;
-	u8  eth_addr[ETH_ALEN];
 	u16 phy_data;
 	bool raise_vol = false;
 
+	/* MAC-address from BIOS is the 1st priority */
+	if (atl1c_read_current_addr(hw, hw->perm_mac_addr))
+		return 0;
+
 	/* init */
-	addr[0] = addr[1] = 0;
 	AT_READ_REG(hw, REG_OTP_CTRL, &otp_ctrl_data);
 	if (atl1c_check_eeprom_exist(hw)) {
 		if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c) {
@@ -89,21 +104,14 @@ static int atl1c_get_permanent_address(struct atl1c_hw *hw)
 				msleep(1);
 			}
 		}
-
-		if (hw->nic_type == athr_l2c_b ||
-		    hw->nic_type == athr_l2c_b2 ||
-		    hw->nic_type == athr_l1d) {
-			atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x00);
-			if (atl1c_read_phy_reg(hw, MII_DBG_DATA, &phy_data))
-				goto out;
-			phy_data &= 0xFF7F;
-			atl1c_write_phy_reg(hw, MII_DBG_DATA, phy_data);
-
-			atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x3B);
-			if (atl1c_read_phy_reg(hw, MII_DBG_DATA, &phy_data))
-				goto out;
-			phy_data |= 0x8;
-			atl1c_write_phy_reg(hw, MII_DBG_DATA, phy_data);
+		/* raise voltage temporally for l2cb */
+		if (hw->nic_type == athr_l2c_b || hw->nic_type == athr_l2c_b2) {
+			atl1c_read_phy_dbg(hw, MIIDBG_ANACTRL, &phy_data);
+			phy_data &= ~ANACTRL_HB_EN;
+			atl1c_write_phy_dbg(hw, MIIDBG_ANACTRL, phy_data);
+			atl1c_read_phy_dbg(hw, MIIDBG_VOLT_CTRL, &phy_data);
+			phy_data |= VOLT_CTRL_SWLOWEST;
+			atl1c_write_phy_dbg(hw, MIIDBG_VOLT_CTRL, phy_data);
 			udelay(20);
 			raise_vol = true;
 		}
@@ -127,37 +135,18 @@ static int atl1c_get_permanent_address(struct atl1c_hw *hw)
 		msleep(1);
 	}
 	if (raise_vol) {
-		if (hw->nic_type == athr_l2c_b ||
-		    hw->nic_type == athr_l2c_b2 ||
-		    hw->nic_type == athr_l1d ||
-		    hw->nic_type == athr_l1d_2) {
-			atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x00);
-			if (atl1c_read_phy_reg(hw, MII_DBG_DATA, &phy_data))
-				goto out;
-			phy_data |= 0x80;
-			atl1c_write_phy_reg(hw, MII_DBG_DATA, phy_data);
-
-			atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x3B);
-			if (atl1c_read_phy_reg(hw, MII_DBG_DATA, &phy_data))
-				goto out;
-			phy_data &= 0xFFF7;
-			atl1c_write_phy_reg(hw, MII_DBG_DATA, phy_data);
-			udelay(20);
-		}
+		atl1c_read_phy_dbg(hw, MIIDBG_ANACTRL, &phy_data);
+		phy_data |= ANACTRL_HB_EN;
+		atl1c_write_phy_dbg(hw, MIIDBG_ANACTRL, phy_data);
+		atl1c_read_phy_dbg(hw, MIIDBG_VOLT_CTRL, &phy_data);
+		phy_data &= ~VOLT_CTRL_SWLOWEST;
+		atl1c_write_phy_dbg(hw, MIIDBG_VOLT_CTRL, phy_data);
+		udelay(20);
 	}
 
-	/* maybe MAC-address is from BIOS */
-	AT_READ_REG(hw, REG_MAC_STA_ADDR, &addr[0]);
-	AT_READ_REG(hw, REG_MAC_STA_ADDR + 4, &addr[1]);
-	*(u32 *) &eth_addr[2] = swab32(addr[0]);
-	*(u16 *) &eth_addr[0] = swab16(*(u16 *)&addr[1]);
-
-	if (is_valid_ether_addr(eth_addr)) {
-		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
+	if (atl1c_read_current_addr(hw, hw->perm_mac_addr))
 		return 0;
-	}
 
-out:
 	return -1;
 }
 
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index 47b0f3d..2e6fbb9 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -36,7 +36,7 @@ struct atl1c_hw;
 
 /* function prototype */
 void atl1c_phy_disable(struct atl1c_hw *hw);
-void atl1c_hw_set_mac_addr(struct atl1c_hw *hw);
+void atl1c_hw_set_mac_addr(struct atl1c_hw *hw, u8 *mac_addr);
 int atl1c_phy_reset(struct atl1c_hw *hw);
 int atl1c_read_mac_addr(struct atl1c_hw *hw);
 int atl1c_get_speed_and_duplex(struct atl1c_hw *hw, u16 *speed, u16 *duplex);
@@ -133,25 +133,17 @@ void atl1c_post_phy_linkchg(struct atl1c_hw *hw, u16 link_speed);
 #define REG_DEV_SERIAL_NUM_EN_SHIFT	1
 
 #define REG_TWSI_CTRL               	0x218
+#define TWSI_CTLR_FREQ_MASK		0x3UL
+#define TWSI_CTRL_FREQ_SHIFT		24
+#define TWSI_CTRL_FREQ_100K		0
+#define TWSI_CTRL_FREQ_200K		1
+#define TWSI_CTRL_FREQ_300K		2
+#define TWSI_CTRL_FREQ_400K		3
+#define TWSI_CTRL_LD_EXIST		BIT(23)
+#define TWSI_CTRL_HW_LDSTAT		BIT(12)	/* 0:finish,1:in progress */
+#define TWSI_CTRL_SW_LDSTART            BIT(11)
 #define TWSI_CTRL_LD_OFFSET_MASK        0xFF
 #define TWSI_CTRL_LD_OFFSET_SHIFT       0
-#define TWSI_CTRL_LD_SLV_ADDR_MASK      0x7
-#define TWSI_CTRL_LD_SLV_ADDR_SHIFT     8
-#define TWSI_CTRL_SW_LDSTART            0x800
-#define TWSI_CTRL_HW_LDSTART            0x1000
-#define TWSI_CTRL_SMB_SLV_ADDR_MASK     0x7F
-#define TWSI_CTRL_SMB_SLV_ADDR_SHIFT    15
-#define TWSI_CTRL_LD_EXIST              0x400000
-#define TWSI_CTRL_READ_FREQ_SEL_MASK    0x3
-#define TWSI_CTRL_READ_FREQ_SEL_SHIFT   23
-#define TWSI_CTRL_FREQ_SEL_100K         0
-#define TWSI_CTRL_FREQ_SEL_200K         1
-#define TWSI_CTRL_FREQ_SEL_300K         2
-#define TWSI_CTRL_FREQ_SEL_400K         3
-#define TWSI_CTRL_SMB_SLV_ADDR
-#define TWSI_CTRL_WRITE_FREQ_SEL_MASK   0x3
-#define TWSI_CTRL_WRITE_FREQ_SEL_SHIFT  24
-
 
 #define REG_PCIE_DEV_MISC_CTRL      	0x21C
 #define PCIE_DEV_MISC_EXT_PIPE     	0x2
@@ -174,7 +166,7 @@ void atl1c_post_phy_linkchg(struct atl1c_hw *hw, u16 link_speed);
 #define L2CB1_PCIE_PHYMISC2_CDR_BW	3
 
 #define REG_TWSI_DEBUG			0x1108
-#define TWSI_DEBUG_DEV_EXIST		0x20000000
+#define TWSI_DEBUG_DEV_EXIST		BIT(29)
 
 #define REG_DMA_DBG			0x1114
 #define DMA_DBG_VENDOR_MSG		BIT(0)
@@ -190,7 +182,7 @@ void atl1c_post_phy_linkchg(struct atl1c_hw *hw, u16 link_speed);
 #define REG_EEPROM_DATA_LO		0x12C4
 
 #define REG_OTP_CTRL			0x12F0
-#define OTP_CTRL_CLK_EN			0x0002
+#define OTP_CTRL_CLK_EN			BIT(1)
 
 #define REG_PM_CTRL			0x12F8
 #define PM_CTRL_HOTRST			BIT(31)
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 79dae19..4b9865b 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -457,7 +457,7 @@ static int atl1c_set_mac_addr(struct net_device *netdev, void *p)
 	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
 	netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
 
-	atl1c_hw_set_mac_addr(&adapter->hw);
+	atl1c_hw_set_mac_addr(&adapter->hw, adapter->hw.mac_addr);
 
 	return 0;
 }
@@ -2536,7 +2536,7 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
 		dev_dbg(&pdev->dev, "mac address : %pM\n",
 			adapter->hw.mac_addr);
 
-	atl1c_hw_set_mac_addr(&adapter->hw);
+	atl1c_hw_set_mac_addr(&adapter->hw, adapter->hw.mac_addr);
 	INIT_WORK(&adapter->common_task, atl1c_common_task);
 	adapter->work_event = 0;
 	err = register_netdev(netdev);
@@ -2580,6 +2580,8 @@ static void __devexit atl1c_remove(struct pci_dev *pdev)
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
 	unregister_netdev(netdev);
+	/* restore permanent address */
+	atl1c_hw_set_mac_addr(&adapter->hw, adapter->hw.perm_mac_addr);
 	atl1c_phy_disable(&adapter->hw);
 
 	iounmap(adapter->hw.hw_addr);
-- 
1.7.7
