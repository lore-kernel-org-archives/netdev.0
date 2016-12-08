From: Mao Wenan <maowenan@huawei.com>
Subject: [PATCH] net: add one ethtool option to set relax ordering mode
Date: Thu, 8 Dec 2016 14:51:37 +0800
Message-ID: <1481179898-10668-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:10013 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbcLHG6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 01:58:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides one way to set/unset IXGBE NIC TX and RX
relax ordering mode, which can be set by ethtool.
Relax ordering is one mode of 82599 NIC, to enable this mode
can enhance the performance for some cpu architecure.
example:
ethtool -s enp1s0f0 relaxorder off
ethtool -s enp1s0f0 relaxorder on

Signed-off-by: Mao Wenan <maowenan@huawei.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 34 ++++++++++++++++++++++++
 include/linux/ethtool.h                          |  2 ++
 include/uapi/linux/ethtool.h                     |  6 +++++
 net/core/ethtool.c                               |  5 ++++
 4 files changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index f49f803..9650539 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -493,6 +493,39 @@ static void ixgbe_set_msglevel(struct net_device *netdev, u32 data)
 	adapter->msg_enable = data;
 }
 
+static void ixgbe_set_relaxorder(struct net_device *netdev, u32 data)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 i = 0;
+	pr_info("set relax ordering mode : %s\n",data?"on":"off");
+	
+	for (i = 0; i < hw->mac.max_tx_queues; i++) {
+		u32 regval;
+
+		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(i));
+		if (data)
+			regval |= IXGBE_DCA_TXCTRL_DESC_WRO_EN;
+		else
+			regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(i), regval);
+	}
+
+	for (i = 0; i < hw->mac.max_rx_queues; i++) {
+		u32 regval;
+		
+		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
+		if (data)
+			regval |= (IXGBE_DCA_RXCTRL_DATA_WRO_EN |
+					IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
+		else
+			regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
+					IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
+	}
+
+}
+
 static int ixgbe_get_regs_len(struct net_device *netdev)
 {
 #define IXGBE_REGS_LEN  1139
@@ -3274,6 +3307,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_ts_info		= ixgbe_get_ts_info,
 	.get_module_info	= ixgbe_get_module_info,
 	.get_module_eeprom	= ixgbe_get_module_eeprom,
+	.set_relaxorder         = ixgbe_set_relaxorder,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9ded8c6..0fae148 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -286,6 +286,7 @@ bool ethtool_convert_link_mode_to_legacy_u32(u32 *legacy_u32,
  *	fields should be ignored (use %__ETHTOOL_LINK_MODE_MASK_NBITS
  *	instead of the latter), any change to them will be overwritten
  *	by kernel. Returns a negative error code or zero.
+ * @set_relaxorder: set relax ordering mode, on|off.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -372,5 +373,6 @@ struct ethtool_ops {
 				      struct ethtool_link_ksettings *);
 	int	(*set_link_ksettings)(struct net_device *,
 				      const struct ethtool_link_ksettings *);
+	void    (*set_relaxorder)(struct net_device *, u32);
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 8e54723..86349b9 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1314,6 +1314,8 @@ struct ethtool_per_queue_op {
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
 
+#define ETHTOOL_SRELAXORDER	0x00000050 /* Set relax ordering mode, on or off*/
+
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1494,6 +1496,10 @@ static inline int ethtool_validate_speed(__u32 speed)
 #define DUPLEX_FULL		0x01
 #define DUPLEX_UNKNOWN		0xff
 
+/* Relax Ordering mode, on or off. */
+#define RELAXORDER_OFF          0x00
+#define RELAXORDER_ON           0x01
+
 static inline int ethtool_validate_duplex(__u8 duplex)
 {
 	switch (duplex) {
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 047a175..b7629d1 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2685,6 +2685,11 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SLINKSETTINGS:
 		rc = ethtool_set_link_ksettings(dev, useraddr);
 		break;
+	case ETHTOOL_SRELAXORDER:
+		rc = ethtool_set_value_void(dev, useraddr,
+					dev->ethtool_ops->set_relaxorder);
+		 break;
+
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
2.7.0
