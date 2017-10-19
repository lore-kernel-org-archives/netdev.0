From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net 6/7] net: aquantia: Enable coalescing management via ethtool interface
Date: Thu, 19 Oct 2017 18:23:58 +0300
Message-ID: <4c72d2ed493ac9a126369051aa46d62aa89deeb7.1508159232.git.igor.russkikh@aquantia.com>
References: <cover.1508159232.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0072.outbound.protection.outlook.com ([104.47.32.72]:7616
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753678AbdJSPZC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 11:25:02 -0400
In-Reply-To: <cover.1508159232.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aquantia NIC allows both TX and RX interrupt throttle rate (ITR)
management, but this was used in a very limited way via predefined
values. This patch allows to setup ITR default values via module
command line arguments and via standard ethtool coalescing settings.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_cfg.h    |  8 ++-
 .../net/ethernet/aquantia/atlantic/aq_ethtool.c    | 65 ++++++++++++++++++
 drivers/net/ethernet/aquantia/atlantic/aq_hw.h     |  3 +-
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    | 36 +++++++---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.h    |  4 +-
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c  | 20 +++---
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c  | 76 ++++++++++++----------
 .../aquantia/atlantic/hw_atl/hw_atl_b0_internal.h  |  3 +
 .../aquantia/atlantic/hw_atl/hw_atl_utils.h        |  2 -
 9 files changed, 155 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h b/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h
index 0fdaaa6..57e7968 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h
@@ -22,8 +22,12 @@
 
 #define AQ_CFG_FORCE_LEGACY_INT 0U
 
-#define AQ_CFG_IS_INTERRUPT_MODERATION_DEF   1U
-#define AQ_CFG_INTERRUPT_MODERATION_RATE_DEF 0xFFFFU
+#define AQ_CFG_INTERRUPT_MODERATION_OFF		0
+#define AQ_CFG_INTERRUPT_MODERATION_ON		1
+#define AQ_CFG_INTERRUPT_MODERATION_AUTO	0xFFFFU
+
+#define AQ_CFG_INTERRUPT_MODERATION_USEC_MAX (0x1FF * 2)
+
 #define AQ_CFG_IRQ_MASK                      0x1FFU
 
 #define AQ_CFG_VECS_MAX   8U
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c b/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
index 3eab408..d5e99b4 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
@@ -221,6 +221,69 @@ static int aq_ethtool_get_rxnfc(struct net_device *ndev,
 	return err;
 }
 
+int aq_ethtool_get_coalesce(struct net_device *ndev,
+			    struct ethtool_coalesce *coal)
+{
+	struct aq_nic_s *aq_nic = netdev_priv(ndev);
+	struct aq_nic_cfg_s *cfg = aq_nic_get_cfg(aq_nic);
+
+	if (cfg->itr == AQ_CFG_INTERRUPT_MODERATION_ON ||
+	    cfg->itr == AQ_CFG_INTERRUPT_MODERATION_AUTO) {
+		coal->rx_coalesce_usecs = cfg->rx_itr;
+		coal->tx_coalesce_usecs = cfg->tx_itr;
+		coal->rx_max_coalesced_frames = 0;
+		coal->tx_max_coalesced_frames = 0;
+	} else {
+		coal->rx_coalesce_usecs = 0;
+		coal->tx_coalesce_usecs = 0;
+		coal->rx_max_coalesced_frames = 1;
+		coal->tx_max_coalesced_frames = 1;
+	}
+	return 0;
+}
+
+int aq_ethtool_set_coalesce(struct net_device *ndev,
+			    struct ethtool_coalesce *coal)
+{
+	struct aq_nic_s *aq_nic = netdev_priv(ndev);
+	struct aq_nic_cfg_s *cfg = aq_nic_get_cfg(aq_nic);
+
+	/* This is not yet supported
+	 */
+	if (coal->use_adaptive_rx_coalesce || coal->use_adaptive_tx_coalesce)
+		return -EOPNOTSUPP;
+
+	/* Atlantic only supports timing based coalescing
+	 */
+	if (coal->rx_max_coalesced_frames > 1 ||
+	    coal->rx_coalesce_usecs_irq ||
+	    coal->rx_max_coalesced_frames_irq)
+		return -EOPNOTSUPP;
+
+	if (coal->tx_max_coalesced_frames > 1 ||
+	    coal->tx_coalesce_usecs_irq ||
+	    coal->tx_max_coalesced_frames_irq)
+		return -EOPNOTSUPP;
+
+	/* We do not support frame counting. Check this
+	 */
+	if (!(coal->rx_max_coalesced_frames == !coal->rx_coalesce_usecs))
+		return -EOPNOTSUPP;
+	if (!(coal->tx_max_coalesced_frames == !coal->tx_coalesce_usecs))
+		return -EOPNOTSUPP;
+
+	if (coal->rx_coalesce_usecs > AQ_CFG_INTERRUPT_MODERATION_USEC_MAX ||
+	    coal->tx_coalesce_usecs > AQ_CFG_INTERRUPT_MODERATION_USEC_MAX)
+		return -EINVAL;
+
+	cfg->itr = AQ_CFG_INTERRUPT_MODERATION_ON;
+
+	cfg->rx_itr = coal->rx_coalesce_usecs;
+	cfg->tx_itr = coal->tx_coalesce_usecs;
+
+	return aq_nic_update_interrupt_moderation_settings(aq_nic);
+}
+
 const struct ethtool_ops aq_ethtool_ops = {
 	.get_link            = aq_ethtool_get_link,
 	.get_regs_len        = aq_ethtool_get_regs_len,
@@ -235,4 +298,6 @@ const struct ethtool_ops aq_ethtool_ops = {
 	.get_ethtool_stats   = aq_ethtool_stats,
 	.get_link_ksettings  = aq_ethtool_get_link_ksettings,
 	.set_link_ksettings  = aq_ethtool_set_link_ksettings,
+	.get_coalesce	     = aq_ethtool_get_coalesce,
+	.set_coalesce	     = aq_ethtool_set_coalesce,
 };
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_hw.h b/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
index 3a8baae..0207927 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
@@ -151,8 +151,7 @@ struct aq_hw_ops {
 				     [ETH_ALEN],
 				     u32 count);
 
-	int (*hw_interrupt_moderation_set)(struct aq_hw_s *self,
-					   bool itr_enabled);
+	int (*hw_interrupt_moderation_set)(struct aq_hw_s *self);
 
 	int (*hw_rss_set)(struct aq_hw_s *self,
 			  struct aq_rss_parameters *rss_params);
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 9378b48..483e976 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -16,6 +16,7 @@
 #include "aq_pci_func.h"
 #include "aq_nic_internal.h"
 
+#include <linux/moduleparam.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/timer.h>
@@ -24,6 +25,18 @@
 #include <linux/tcp.h>
 #include <net/ip.h>
 
+static unsigned int aq_itr = AQ_CFG_INTERRUPT_MODERATION_AUTO;
+module_param_named(aq_itr, aq_itr, uint, 0644);
+MODULE_PARM_DESC(aq_itr, "Interrupt throttling mode");
+
+static unsigned int aq_itr_tx;
+module_param_named(aq_itr_tx, aq_itr_tx, uint, 0644);
+MODULE_PARM_DESC(aq_itr_tx, "TX interrupt throttle rate");
+
+static unsigned int aq_itr_rx;
+module_param_named(aq_itr_rx, aq_itr_rx, uint, 0644);
+MODULE_PARM_DESC(aq_itr_rx, "RX interrupt throttle rate");
+
 static void aq_nic_rss_init(struct aq_nic_s *self, unsigned int num_rss_queues)
 {
 	struct aq_nic_cfg_s *cfg = &self->aq_nic_cfg;
@@ -61,9 +74,9 @@ static void aq_nic_cfg_init_defaults(struct aq_nic_s *self)
 
 	cfg->is_polling = AQ_CFG_IS_POLLING_DEF;
 
-	cfg->is_interrupt_moderation = AQ_CFG_IS_INTERRUPT_MODERATION_DEF;
-	cfg->itr = cfg->is_interrupt_moderation ?
-		AQ_CFG_INTERRUPT_MODERATION_RATE_DEF : 0U;
+	cfg->itr = aq_itr;
+	cfg->tx_itr = aq_itr_tx;
+	cfg->rx_itr = aq_itr_rx;
 
 	cfg->is_rss = AQ_CFG_IS_RSS_DEF;
 	cfg->num_rss_queues = AQ_CFG_NUM_RSS_QUEUES_DEF;
@@ -126,10 +139,12 @@ static int aq_nic_update_link_status(struct aq_nic_s *self)
 	if (err)
 		return err;
 
-	if (self->link_status.mbps != self->aq_hw->aq_link_status.mbps)
+	if (self->link_status.mbps != self->aq_hw->aq_link_status.mbps) {
 		pr_info("%s: link change old %d new %d\n",
 			AQ_CFG_DRV_NAME, self->link_status.mbps,
 			self->aq_hw->aq_link_status.mbps);
+		aq_nic_update_interrupt_moderation_settings(self);
+	}
 
 	self->link_status = self->aq_hw->aq_link_status;
 	if (!netif_carrier_ok(self->ndev) && self->link_status.mbps) {
@@ -164,9 +179,6 @@ static void aq_nic_service_timer_cb(unsigned long param)
 	if (err)
 		goto err_exit;
 
-	self->aq_hw_ops.hw_interrupt_moderation_set(self->aq_hw,
-		    self->aq_nic_cfg.is_interrupt_moderation);
-
 	if (self->aq_hw_ops.hw_update_stats)
 		self->aq_hw_ops.hw_update_stats(self->aq_hw);
 
@@ -425,9 +437,8 @@ int aq_nic_start(struct aq_nic_s *self)
 	if (err < 0)
 		goto err_exit;
 
-	err = self->aq_hw_ops.hw_interrupt_moderation_set(self->aq_hw,
-			    self->aq_nic_cfg.is_interrupt_moderation);
-	if (err < 0)
+	err = aq_nic_update_interrupt_moderation_settings(self);
+	if (err)
 		goto err_exit;
 	setup_timer(&self->service_timer, &aq_nic_service_timer_cb,
 		    (unsigned long)self);
@@ -649,6 +660,11 @@ int aq_nic_xmit(struct aq_nic_s *self, struct sk_buff *skb)
 	return err;
 }
 
+int aq_nic_update_interrupt_moderation_settings(struct aq_nic_s *self)
+{
+	return self->aq_hw_ops.hw_interrupt_moderation_set(self->aq_hw);
+}
+
 int aq_nic_set_packet_filter(struct aq_nic_s *self, unsigned int flags)
 {
 	int err = 0;
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.h b/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
index 0ddd556..4309983 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
@@ -40,6 +40,8 @@ struct aq_nic_cfg_s {
 	u32 vecs;		/* vecs==allocated irqs */
 	u32 irq_type;
 	u32 itr;
+	u16 rx_itr;
+	u16 tx_itr;
 	u32 num_rss_queues;
 	u32 mtu;
 	u32 ucp_0x364;
@@ -49,7 +51,6 @@ struct aq_nic_cfg_s {
 	u16 is_mc_list_enabled;
 	u16 mc_list_count;
 	bool is_autoneg;
-	bool is_interrupt_moderation;
 	bool is_polling;
 	bool is_rss;
 	bool is_lro;
@@ -104,5 +105,6 @@ int aq_nic_set_link_ksettings(struct aq_nic_s *self,
 struct aq_nic_cfg_s *aq_nic_get_cfg(struct aq_nic_s *self);
 u32 aq_nic_get_fw_version(struct aq_nic_s *self);
 int aq_nic_change_pm_state(struct aq_nic_s *self, pm_message_t *pm_msg);
+int aq_nic_update_interrupt_moderation_settings(struct aq_nic_s *self);
 
 #endif /* AQ_NIC_H */
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
index b0747b2..07b3c49 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
@@ -765,24 +765,23 @@ static int hw_atl_a0_hw_multicast_list_set(struct aq_hw_s *self,
 	return err;
 }
 
-static int hw_atl_a0_hw_interrupt_moderation_set(struct aq_hw_s *self,
-						 bool itr_enabled)
+static int hw_atl_a0_hw_interrupt_moderation_set(struct aq_hw_s *self)
 {
 	unsigned int i = 0U;
+	u32 itr_rx;
 
-	if (itr_enabled && self->aq_nic_cfg->itr) {
-		if (self->aq_nic_cfg->itr != 0xFFFFU) {
+	if (self->aq_nic_cfg->itr) {
+		if (self->aq_nic_cfg->itr != AQ_CFG_INTERRUPT_MODERATION_AUTO) {
 			u32 itr_ = (self->aq_nic_cfg->itr >> 1);
 
 			itr_ = min(AQ_CFG_IRQ_MASK, itr_);
 
-			PHAL_ATLANTIC_A0->itr_rx = 0x80000000U |
-					(itr_ << 0x10);
+			itr_rx = 0x80000000U | (itr_ << 0x10);
 		} else  {
 			u32 n = 0xFFFFU & aq_hw_read_reg(self, 0x00002A00U);
 
 			if (n < self->aq_link_status.mbps) {
-				PHAL_ATLANTIC_A0->itr_rx = 0U;
+				itr_rx = 0U;
 			} else {
 				static unsigned int hw_timers_tbl_[] = {
 					0x01CU, /* 10Gbit */
@@ -797,8 +796,7 @@ static int hw_atl_a0_hw_interrupt_moderation_set(struct aq_hw_s *self,
 					hw_atl_utils_mbps_2_speed_index(
 						self->aq_link_status.mbps);
 
-				PHAL_ATLANTIC_A0->itr_rx =
-					0x80000000U |
+				itr_rx = 0x80000000U |
 					(hw_timers_tbl_[speed_index] << 0x10U);
 			}
 
@@ -806,11 +804,11 @@ static int hw_atl_a0_hw_interrupt_moderation_set(struct aq_hw_s *self,
 			aq_hw_write_reg(self, 0x00002A00U, 0x8D000000U);
 		}
 	} else {
-		PHAL_ATLANTIC_A0->itr_rx = 0U;
+		itr_rx = 0U;
 	}
 
 	for (i = HW_ATL_A0_RINGS_MAX; i--;)
-		reg_irq_thr_set(self, PHAL_ATLANTIC_A0->itr_rx, i);
+		reg_irq_thr_set(self, itr_rx, i);
 
 	return aq_hw_err_from_flags(self);
 }
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
index 6f6e70a..11f7e71 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
@@ -788,31 +788,37 @@ static int hw_atl_b0_hw_multicast_list_set(struct aq_hw_s *self,
 	return err;
 }
 
-static int hw_atl_b0_hw_interrupt_moderation_set(struct aq_hw_s *self,
-						 bool itr_enabled)
+static int hw_atl_b0_hw_interrupt_moderation_set(struct aq_hw_s *self)
 {
 	unsigned int i = 0U;
+	u32 itr_tx = 2U;
+	u32 itr_rx = 2U;
 
-	if (itr_enabled && self->aq_nic_cfg->itr) {
+	switch (self->aq_nic_cfg->itr) {
+	case  AQ_CFG_INTERRUPT_MODERATION_ON:
+	case  AQ_CFG_INTERRUPT_MODERATION_AUTO:
 		tdm_tx_desc_wr_wb_irq_en_set(self, 0U);
 		tdm_tdm_intr_moder_en_set(self, 1U);
 		rdm_rx_desc_wr_wb_irq_en_set(self, 0U);
 		rdm_rdm_intr_moder_en_set(self, 1U);
 
-		PHAL_ATLANTIC_B0->itr_tx = 2U;
-		PHAL_ATLANTIC_B0->itr_rx = 2U;
+		if (self->aq_nic_cfg->itr == AQ_CFG_INTERRUPT_MODERATION_ON) {
+			/* HW timers are in 2us units */
+			int tx_max_timer = self->aq_nic_cfg->tx_itr / 2;
+			int tx_min_timer = tx_max_timer / 2;
 
-		if (self->aq_nic_cfg->itr != 0xFFFFU) {
-			unsigned int max_timer = self->aq_nic_cfg->itr / 2U;
-			unsigned int min_timer = self->aq_nic_cfg->itr / 32U;
+			int rx_max_timer = self->aq_nic_cfg->rx_itr / 2;
+			int rx_min_timer = rx_max_timer / 2;
 
-			max_timer = min(0x1FFU, max_timer);
-			min_timer = min(0xFFU, min_timer);
+			tx_max_timer = min(HW_ATL_INTR_MODER_MAX, tx_max_timer);
+			tx_min_timer = min(HW_ATL_INTR_MODER_MIN, tx_min_timer);
+			rx_max_timer = min(HW_ATL_INTR_MODER_MAX, rx_max_timer);
+			rx_min_timer = min(HW_ATL_INTR_MODER_MIN, rx_min_timer);
 
-			PHAL_ATLANTIC_B0->itr_tx |= min_timer << 0x8U;
-			PHAL_ATLANTIC_B0->itr_tx |= max_timer << 0x10U;
-			PHAL_ATLANTIC_B0->itr_rx |= min_timer << 0x8U;
-			PHAL_ATLANTIC_B0->itr_rx |= max_timer << 0x10U;
+			itr_tx |= tx_min_timer << 0x8U;
+			itr_tx |= tx_max_timer << 0x10U;
+			itr_rx |= rx_min_timer << 0x8U;
+			itr_rx |= rx_max_timer << 0x10U;
 		} else {
 			static unsigned int hw_atl_b0_timers_table_tx_[][2] = {
 				{0xffU, 0xffU}, /* 10Gbit */
@@ -836,34 +842,36 @@ static int hw_atl_b0_hw_interrupt_moderation_set(struct aq_hw_s *self,
 					hw_atl_utils_mbps_2_speed_index(
 						self->aq_link_status.mbps);
 
-			PHAL_ATLANTIC_B0->itr_tx |=
-				hw_atl_b0_timers_table_tx_[speed_index]
-				[0] << 0x8U; /* set min timer value */
-			PHAL_ATLANTIC_B0->itr_tx |=
-				hw_atl_b0_timers_table_tx_[speed_index]
-				[1] << 0x10U; /* set max timer value */
-
-			PHAL_ATLANTIC_B0->itr_rx |=
-				hw_atl_b0_timers_table_rx_[speed_index]
-				[0] << 0x8U; /* set min timer value */
-			PHAL_ATLANTIC_B0->itr_rx |=
-				hw_atl_b0_timers_table_rx_[speed_index]
-				[1] << 0x10U; /* set max timer value */
+			/* Update user visible ITR settings */
+			self->aq_nic_cfg->tx_itr = hw_atl_b0_timers_table_tx_
+							[speed_index][1] * 2;
+			self->aq_nic_cfg->rx_itr = hw_atl_b0_timers_table_rx_
+							[speed_index][1] * 2;
+
+			itr_tx |= hw_atl_b0_timers_table_tx_
+						[speed_index][0] << 0x8U;
+			itr_tx |= hw_atl_b0_timers_table_tx_
+						[speed_index][1] << 0x10U;
+
+			itr_rx |= hw_atl_b0_timers_table_rx_
+						[speed_index][0] << 0x8U;
+			itr_rx |= hw_atl_b0_timers_table_rx_
+						[speed_index][1] << 0x10U;
 		}
-	} else {
+		break;
+	case AQ_CFG_INTERRUPT_MODERATION_OFF:
 		tdm_tx_desc_wr_wb_irq_en_set(self, 1U);
 		tdm_tdm_intr_moder_en_set(self, 0U);
 		rdm_rx_desc_wr_wb_irq_en_set(self, 1U);
 		rdm_rdm_intr_moder_en_set(self, 0U);
-		PHAL_ATLANTIC_B0->itr_tx = 0U;
-		PHAL_ATLANTIC_B0->itr_rx = 0U;
+		itr_tx = 0U;
+		itr_rx = 0U;
+		break;
 	}
 
 	for (i = HW_ATL_B0_RINGS_MAX; i--;) {
-		reg_tx_intr_moder_ctrl_set(self,
-					   PHAL_ATLANTIC_B0->itr_tx, i);
-		reg_rx_intr_moder_ctrl_set(self,
-					   PHAL_ATLANTIC_B0->itr_rx, i);
+		reg_tx_intr_moder_ctrl_set(self, itr_tx, i);
+		reg_rx_intr_moder_ctrl_set(self, itr_rx, i);
 	}
 
 	return aq_hw_err_from_flags(self);
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h
index fcf89e2..9aa2c6e 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h
@@ -139,6 +139,9 @@
 
 #define HW_ATL_B0_FW_VER_EXPECTED 0x01050006U
 
+#define HW_ATL_INTR_MODER_MAX  0x1FF
+#define HW_ATL_INTR_MODER_MIN  0xFF
+
 /* Hardware tx descriptor */
 struct __packed hw_atl_txd_s {
 	u64 buf_addr;
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
index 2218bdb..c99cc69 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
@@ -131,8 +131,6 @@ struct __packed hw_atl_s {
 	struct hw_atl_stats_s last_stats;
 	struct hw_atl_stats_s curr_stats;
 	u64 speed;
-	u32 itr_tx;
-	u32 itr_rx;
 	unsigned int chip_features;
 	u32 fw_ver_actual;
 	atomic_t dpc;
-- 
2.7.4
