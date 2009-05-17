From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 09/11] ixgbe: Allow link flow control in DCB mode
	for 82599 adapters
Date: Sun, 17 May 2009 15:35:16 -0700
Message-ID: <20090517223515.14124.63670.stgit@localhost.localdomain>
References: <20090517223213.14124.61405.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:50950 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755348AbZEQWfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 18:35:33 -0400
In-Reply-To: <20090517223213.14124.61405.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

82599 supports using either link flow control or priority flow control when
in DCB mode.  The dcbnl interface already supports sending down
configurations through rtnetlink that can enable LFC when DCB is enabled,
so the driver should take advantage of this.

82598 does not support using LFC when DCB is enabled, so explicitly disable
it when we're in DCB mode.  This means we always run in PFC mode when DCB
is enabled.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h           |    1 +
 drivers/net/ixgbe/ixgbe_82598.c     |    2 +-
 drivers/net/ixgbe/ixgbe_common.c    |    5 +++--
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    4 ++++
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |   32 +++++++++++++++++++++++++++++---
 drivers/net/ixgbe/ixgbe_ethtool.c   |   10 ++++++++++
 drivers/net/ixgbe/ixgbe_main.c      |   19 ++++++++++++++++++-
 7 files changed, 66 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 3f83a12..d291d1c 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -252,6 +252,7 @@ struct ixgbe_adapter {
 	struct ixgbe_dcb_config dcb_cfg;
 	struct ixgbe_dcb_config temp_dcb_cfg;
 	u8 dcb_set_bitmap;
+	enum ixgbe_fc_mode last_lfc_mode;
 
 	/* Interrupt Throttle Rate */
 	u32 itr_setting;
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 55186dc..afc9fe3 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -363,7 +363,7 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 	}
 
 	/* Configure pause time (2 TCs per register) */
-	reg = IXGBE_READ_REG(hw, IXGBE_FCTTV(packetbuf_num));
+	reg = IXGBE_READ_REG(hw, IXGBE_FCTTV(packetbuf_num / 2));
 	if ((packetbuf_num & 1) == 0)
 		reg = (reg & 0xFFFF0000) | hw->fc.pause_time;
 	else
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 530da90..0cc3c47 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1661,9 +1661,10 @@ s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
 	reg = IXGBE_READ_REG(hw, IXGBE_MTQC);
 	/* Thresholds are different for link flow control when in DCB mode */
 	if (reg & IXGBE_MTQC_RT_ENA) {
-		rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(packetbuf_num));
-
 		/* Always disable XON for LFC when in DCB mode */
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(packetbuf_num), 0);
+
+		rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(packetbuf_num));
 		reg = (rx_pba_size >> 2) & 0xFFE0;
 		if (hw->fc.current_mode & ixgbe_fc_tx_pause)
 			reg |= IXGBE_FCRTH_FCEN;
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index 6220627..f302638 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -294,6 +294,9 @@ s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw,
 	u32 reg, rx_pba_size;
 	u8  i;
 
+	if (!dcb_config->pfc_mode_enable)
+		goto out;
+
 	/* Enable Transmit Priority Flow Control */
 	reg = IXGBE_READ_REG(hw, IXGBE_RMCS);
 	reg &= ~IXGBE_RMCS_TFCE_802_3X;
@@ -341,6 +344,7 @@ s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw,
 	/* Configure flow control refresh threshold value */
 	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, 0x3400);
 
+out:
 	return 0;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 5d5d390..6cbff96 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -126,7 +126,10 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			netdev->netdev_ops->ndo_stop(netdev);
 		ixgbe_clear_interrupt_scheme(adapter);
 
-		adapter->hw.fc.requested_mode = ixgbe_fc_pfc;
+		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+			adapter->last_lfc_mode = adapter->hw.fc.current_mode;
+			adapter->hw.fc.requested_mode = ixgbe_fc_none;
+		}
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
 		ixgbe_init_interrupt_scheme(adapter);
@@ -135,11 +138,13 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 	} else {
 		/* Turn off DCB */
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			adapter->hw.fc.requested_mode = ixgbe_fc_default;
 			if (netif_running(netdev))
 				netdev->netdev_ops->ndo_stop(netdev);
 			ixgbe_clear_interrupt_scheme(adapter);
 
+			adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
+			adapter->temp_dcb_cfg.pfc_mode_enable = false;
+			adapter->dcb_cfg.pfc_mode_enable = false;
 			adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 			adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 			ixgbe_init_interrupt_scheme(adapter);
@@ -329,9 +334,24 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		return ret;
 	}
 
+	if (adapter->dcb_cfg.pfc_mode_enable) {
+		if ((adapter->hw.mac.type != ixgbe_mac_82598EB) &&
+			(adapter->hw.fc.current_mode != ixgbe_fc_pfc))
+			adapter->last_lfc_mode = adapter->hw.fc.current_mode;
+		adapter->hw.fc.requested_mode = ixgbe_fc_pfc;
+	} else {
+		if (adapter->hw.mac.type != ixgbe_mac_82598EB)
+			adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
+		else
+			adapter->hw.fc.requested_mode = ixgbe_fc_none;
+	}
+
 	if (netif_running(netdev))
 		ixgbe_up(adapter);
 
+	if (adapter->dcb_cfg.pfc_mode_enable)
+		adapter->hw.fc.current_mode = ixgbe_fc_pfc;
+
 	adapter->dcb_set_bitmap = 0x00;
 	clear_bit(__IXGBE_RESETTING, &adapter->state);
 	return ret;
@@ -409,11 +429,17 @@ static u8 ixgbe_dcbnl_getpfcstate(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	return !!(adapter->flags & IXGBE_FLAG_DCB_ENABLED);
+	return adapter->dcb_cfg.pfc_mode_enable;
 }
 
 static void ixgbe_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
 {
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	adapter->temp_dcb_cfg.pfc_mode_enable = state;
+	if (adapter->temp_dcb_cfg.pfc_mode_enable !=
+		adapter->dcb_cfg.pfc_mode_enable)
+		adapter->dcb_set_bitmap |= BIT_PFC;
 	return;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 39fb98f..6c73243 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -270,6 +270,13 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
+#ifdef CONFIG_DCB
+	if (adapter->dcb_cfg.pfc_mode_enable ||
+		((hw->mac.type == ixgbe_mac_82598EB) &&
+		(adapter->flags & IXGBE_FLAG_DCB_ENABLED)))
+		return -EINVAL;
+
+#endif
 	if (pause->autoneg != AUTONEG_ENABLE)
 		hw->fc.disable_fc_autoneg = true;
 	else
@@ -286,6 +293,9 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 	else
 		return -EINVAL;
 
+#ifdef CONFIG_DCB
+	adapter->last_lfc_mode = hw->fc.requested_mode;
+#endif
 	hw->mac.ops.setup_fc(hw, 0);
 
 	return 0;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 1b4af3f..b53f265 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3554,6 +3554,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->dcb_cfg.bw_percentage[DCB_TX_CONFIG][0] = 100;
 	adapter->dcb_cfg.bw_percentage[DCB_RX_CONFIG][0] = 100;
 	adapter->dcb_cfg.rx_pba_cfg = pba_equal;
+	adapter->dcb_cfg.pfc_mode_enable = false;
 	adapter->dcb_cfg.round_robin_enable = false;
 	adapter->dcb_set_bitmap = 0x00;
 	ixgbe_copy_dcb_cfg(&adapter->dcb_cfg, &adapter->temp_dcb_cfg,
@@ -3564,6 +3565,9 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	/* default flow control settings */
 	hw->fc.requested_mode = ixgbe_fc_full;
 	hw->fc.current_mode = ixgbe_fc_full;	/* init for ethtool output */
+#ifdef CONFIG_DCB
+	adapter->last_lfc_mode = hw->fc.current_mode;
+#endif
 	hw->fc.high_water = IXGBE_DEFAULT_FCRTH;
 	hw->fc.low_water = IXGBE_DEFAULT_FCRTL;
 	hw->fc.pause_time = IXGBE_DEFAULT_FCPAUSE;
@@ -4319,11 +4323,24 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 
 	if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE) {
 		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
+		if (link_up) {
+#ifdef CONFIG_DCB
+			if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+				for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
+					hw->mac.ops.setup_fc(hw, i);
+			} else {
+				hw->mac.ops.setup_fc(hw, 0);
+			}
+#else
+			hw->mac.ops.setup_fc(hw, 0);
+#endif
+		}
+
 		if (link_up ||
 		    time_after(jiffies, (adapter->link_check_timeout +
 		                         IXGBE_TRY_LINK_TIMEOUT))) {
-			IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMC_LSC);
 			adapter->flags &= ~IXGBE_FLAG_NEED_LINK_UPDATE;
+			IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMC_LSC);
 		}
 		adapter->link_up = link_up;
 		adapter->link_speed = link_speed;

