From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 2/2] smsc9420: add ethtool eeprom support
Date: Thu, 11 Dec 2008 11:01:52 +0000
Message-ID: <1228993312-16738-3-git-send-email-steve.glendinning@smsc.com>
References: <1228993312-16738-1-git-send-email-steve.glendinning@smsc.com>
 <1228993312-16738-2-git-send-email-steve.glendinning@smsc.com>
Cc: Vlad Lyalikov <vlad.lyalikov@smsc.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:55109 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754979AbYLKLBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 06:01:53 -0500
In-Reply-To: <1228993312-16738-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc9420.c |  121 ++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/smsc9420.h |    3 +
 2 files changed, 124 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 80dab8b..2a8e9b7 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -293,6 +293,124 @@ static int smsc9420_ethtool_nway_reset(struct net_device *netdev)
 	return phy_start_aneg(pd->phy_dev);
 }
 
+static void smsc9420_eeprom_enable_access(struct smsc9420_pdata *pd)
+{
+	unsigned int temp = smsc9420_reg_read(pd, GPIO_CFG);
+	temp &= ~GPIO_CFG_EEPR_EN_;
+	smsc9420_reg_write(pd, GPIO_CFG, temp);
+	msleep(1);
+}
+
+static int smsc9420_eeprom_send_cmd(struct smsc9420_pdata *pd, u32 op)
+{
+	int timeout = 100;
+	u32 e2cmd;
+
+	smsc_dbg(HW, "op 0x%08x", op);
+	if (smsc9420_reg_read(pd, E2P_CMD) & E2P_CMD_EPC_BUSY_) {
+		smsc_warn(HW, "Busy at start");
+		return -EBUSY;
+	}
+
+	e2cmd = op | E2P_CMD_EPC_BUSY_;
+	smsc9420_reg_write(pd, E2P_CMD, e2cmd);
+
+	do {
+		msleep(1);
+		e2cmd = smsc9420_reg_read(pd, E2P_CMD);
+	} while ((e2cmd & E2P_CMD_EPC_BUSY_) && (timeout--));
+
+	if (!timeout) {
+		smsc_info(HW, "TIMED OUT");
+		return -EAGAIN;
+	}
+
+	if (e2cmd & E2P_CMD_EPC_TIMEOUT_) {
+		smsc_info(HW, "Error occured during eeprom operation");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int smsc9420_eeprom_read_location(struct smsc9420_pdata *pd,
+					 u8 address, u8 *data)
+{
+	u32 op = E2P_CMD_EPC_CMD_READ_ | address;
+	int ret;
+
+	smsc_dbg(HW, "address 0x%x", address);
+	ret = smsc9420_eeprom_send_cmd(pd, op);
+
+	if (!ret)
+		data[address] = smsc9420_reg_read(pd, E2P_DATA);
+
+	return ret;
+}
+
+static int smsc9420_eeprom_write_location(struct smsc9420_pdata *pd,
+					  u8 address, u8 data)
+{
+	u32 op = E2P_CMD_EPC_CMD_ERASE_ | address;
+	int ret;
+
+	smsc_dbg(HW, "address 0x%x, data 0x%x", address, data);
+	ret = smsc9420_eeprom_send_cmd(pd, op);
+
+	if (!ret) {
+		op = E2P_CMD_EPC_CMD_WRITE_ | address;
+		smsc9420_reg_write(pd, E2P_DATA, (u32)data);
+		ret = smsc9420_eeprom_send_cmd(pd, op);
+	}
+
+	return ret;
+}
+
+static int smsc9420_ethtool_get_eeprom_len(struct net_device *dev)
+{
+	return SMSC9420_EEPROM_SIZE;
+}
+
+static int smsc9420_ethtool_get_eeprom(struct net_device *dev,
+				       struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	u8 eeprom_data[SMSC9420_EEPROM_SIZE];
+	int len, i;
+
+	smsc9420_eeprom_enable_access(pd);
+
+	len = min(eeprom->len, SMSC9420_EEPROM_SIZE);
+	for (i = 0; i < len; i++) {
+		int ret = smsc9420_eeprom_read_location(pd, i, eeprom_data);
+		if (ret < 0) {
+			eeprom->len = 0;
+			return ret;
+		}
+	}
+
+	memcpy(data, &eeprom_data[eeprom->offset], len);
+	eeprom->len = len;
+	return 0;
+}
+
+static int smsc9420_ethtool_set_eeprom(struct net_device *dev,
+				       struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	int ret;
+
+	smsc9420_eeprom_enable_access(pd);
+	smsc9420_eeprom_send_cmd(pd, E2P_CMD_EPC_CMD_EWEN_);
+	ret = smsc9420_eeprom_write_location(pd, eeprom->offset, *data);
+	smsc9420_eeprom_send_cmd(pd, E2P_CMD_EPC_CMD_EWDS_);
+
+	/* Single byte write, according to man page */
+	eeprom->len = 1;
+
+	return ret;
+}
+
 static const struct ethtool_ops smsc9420_ethtool_ops = {
 	.get_settings = smsc9420_ethtool_get_settings,
 	.set_settings = smsc9420_ethtool_set_settings,
@@ -301,6 +419,9 @@ static const struct ethtool_ops smsc9420_ethtool_ops = {
 	.set_msglevel = smsc9420_ethtool_set_msglevel,
 	.nway_reset = smsc9420_ethtool_nway_reset,
 	.get_link = ethtool_op_get_link,
+	.get_eeprom_len = smsc9420_ethtool_get_eeprom_len,
+	.get_eeprom = smsc9420_ethtool_get_eeprom,
+	.set_eeprom = smsc9420_ethtool_set_eeprom,
 };
 
 /* Sets the device MAC address to dev_addr */
diff --git a/drivers/net/smsc9420.h b/drivers/net/smsc9420.h
index afda2d2..80c426d 100644
--- a/drivers/net/smsc9420.h
+++ b/drivers/net/smsc9420.h
@@ -43,6 +43,8 @@
 
 #define LAN_REGISTER_EXTENT		(0x400)
 
+#define SMSC9420_EEPROM_SIZE		((u32)11)
+
 #define FLOW_CTRL_TX			(1)
 #define FLOW_CTRL_RX			(2)
 
@@ -238,6 +240,7 @@
 #define GPIO_CFG_LED_3_			(0x40000000)
 #define GPIO_CFG_LED_2_			(0x20000000)
 #define GPIO_CFG_LED_1_			(0x10000000)
+#define GPIO_CFG_EEPR_EN_		(0x00700000)
 
 #define GPT_CFG				(0xD4)
 #define GPT_CFG_TIMER_EN_		(0x20000000)
-- 
1.5.6.5

