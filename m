From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/17] ixgbe: configure minimal packet buffers to support TC
Date: Sun, 19 Jun 2011 17:58:30 -0700
Message-ID: <1308531518-17298-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10991 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369Ab1FTA67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 20:58:59 -0400
In-Reply-To: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

ixgbe devices support different numbers of packet buffers either
8 or 4. Here we only allocate the minimal number of packet
buffers required to implement the net_devices number of traffic
classes.

Fewer traffic classes allows for larger packet buffers in
hardware. Also more Tx/Rx queues can be given to each
traffic class.

This patch is mostly about propagating the number of traffic
classes through the init path. Specifically this adds the 4TC
cases to the MRQC and MTQC setup routines. Also ixgbe_setup_tc()
was sanitized to handle other traffic class value.

Finally changing the number of packet buffers in the hardware
requires the device to reinit. So this moves the reinit work
from DCB into the main ixgbe_setup_tc() routine to consolidate
the reset code. Now dcbnl_xxx ops call ixgbe_setup_tc() to
configure packet buffers if needed.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   16 +---
 drivers/net/ixgbe/ixgbe_main.c   |  235 ++++++++++++++++++++++----------------
 drivers/net/ixgbe/ixgbe_type.h   |    1 +
 3 files changed, 138 insertions(+), 114 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 293ff06..b229feb 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -125,9 +125,7 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			goto out;
 		}
 
-		if (netif_running(netdev))
-			netdev->netdev_ops->ndo_stop(netdev);
-		ixgbe_clear_interrupt_scheme(adapter);
+		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
 
 		switch (adapter->hw.mac.type) {
 		case ixgbe_mac_82598EB:
@@ -143,18 +141,12 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			break;
 		}
 
-		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
-		if (!netdev_get_num_tc(netdev))
-			ixgbe_setup_tc(netdev, MAX_TRAFFIC_CLASS);
+		ixgbe_setup_tc(netdev, MAX_TRAFFIC_CLASS);
 	} else {
 		/* Turn off DCB */
 		if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
 			goto out;
 
-		if (netif_running(netdev))
-			netdev->netdev_ops->ndo_stop(netdev);
-		ixgbe_clear_interrupt_scheme(adapter);
-
 		adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
 		adapter->temp_dcb_cfg.pfc_mode_enable = false;
 		adapter->dcb_cfg.pfc_mode_enable = false;
@@ -167,13 +159,9 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 		default:
 			break;
 		}
-
 		ixgbe_setup_tc(netdev, 0);
 	}
 
-	ixgbe_init_interrupt_scheme(adapter);
-	if (netif_running(netdev))
-		netdev->netdev_ops->ndo_open(netdev);
 out:
 	return err;
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 20467da..7e3850a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2815,8 +2815,8 @@ static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rttdcs;
-	u32 mask;
 	u32 reg;
+	u8 tcs = netdev_get_num_tc(adapter->netdev);
 
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		return;
@@ -2827,28 +2827,27 @@ static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, rttdcs);
 
 	/* set transmit pool layout */
-	mask = (IXGBE_FLAG_SRIOV_ENABLED | IXGBE_FLAG_DCB_ENABLED);
-	switch (adapter->flags & mask) {
-
+	switch (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
 	case (IXGBE_FLAG_SRIOV_ENABLED):
 		IXGBE_WRITE_REG(hw, IXGBE_MTQC,
 				(IXGBE_MTQC_VT_ENA | IXGBE_MTQC_64VF));
 		break;
+	default:
+		if (!tcs)
+			reg = IXGBE_MTQC_64Q_1PB;
+		else if (tcs <= 4)
+			reg = IXGBE_MTQC_RT_ENA | IXGBE_MTQC_4TC_4TQ;
+		else
+			reg = IXGBE_MTQC_RT_ENA | IXGBE_MTQC_8TC_8TQ;
 
-	case (IXGBE_FLAG_DCB_ENABLED):
-		/* We enable 8 traffic classes, DCB only */
-		IXGBE_WRITE_REG(hw, IXGBE_MTQC,
-			      (IXGBE_MTQC_RT_ENA | IXGBE_MTQC_8TC_8TQ));
-
-		/* Enable Security TX Buffer IFG for DCB */
-		reg = IXGBE_READ_REG(hw, IXGBE_SECTXMINIFG);
-		reg |= IXGBE_SECTX_DCB;
-		IXGBE_WRITE_REG(hw, IXGBE_SECTXMINIFG, reg);
-
-		break;
+		IXGBE_WRITE_REG(hw, IXGBE_MTQC, reg);
 
-	default:
-		IXGBE_WRITE_REG(hw, IXGBE_MTQC, IXGBE_MTQC_64Q_1PB);
+		/* Enable Security TX Buffer IFG for multiple pb */
+		if (tcs) {
+			reg = IXGBE_READ_REG(hw, IXGBE_SECTXMINIFG);
+			reg |= IXGBE_SECTX_DCB;
+			IXGBE_WRITE_REG(hw, IXGBE_SECTXMINIFG, reg);
+		}
 		break;
 	}
 
@@ -2939,7 +2938,7 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	u32 mrqc = 0, reta = 0;
 	u32 rxcsum;
 	int i, j;
-	int mask;
+	u8 tcs = netdev_get_num_tc(adapter->netdev);
 
 	/* Fill out hash function seeds */
 	for (i = 0; i < 10; i++)
@@ -2961,33 +2960,28 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	rxcsum |= IXGBE_RXCSUM_PCSD;
 	IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
 
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
-		mask = adapter->flags & IXGBE_FLAG_RSS_ENABLED;
-	else
-		mask = adapter->flags & (IXGBE_FLAG_RSS_ENABLED
-#ifdef CONFIG_IXGBE_DCB
-					 | IXGBE_FLAG_DCB_ENABLED
-#endif
-					 | IXGBE_FLAG_SRIOV_ENABLED
-					);
-
-	switch (mask) {
-#ifdef CONFIG_IXGBE_DCB
-	case (IXGBE_FLAG_DCB_ENABLED | IXGBE_FLAG_RSS_ENABLED):
-		mrqc = IXGBE_MRQC_RTRSS8TCEN;
-		break;
-	case (IXGBE_FLAG_DCB_ENABLED):
-		mrqc = IXGBE_MRQC_RT8TCEN;
-		break;
-#endif /* CONFIG_IXGBE_DCB */
-	case (IXGBE_FLAG_RSS_ENABLED):
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB &&
+	    (adapter->flags & IXGBE_FLAG_RSS_ENABLED)) {
 		mrqc = IXGBE_MRQC_RSSEN;
-		break;
-	case (IXGBE_FLAG_SRIOV_ENABLED):
-		mrqc = IXGBE_MRQC_VMDQEN;
-		break;
-	default:
-		break;
+	} else {
+		int mask = adapter->flags & (IXGBE_FLAG_RSS_ENABLED
+					     | IXGBE_FLAG_SRIOV_ENABLED);
+
+		switch (mask) {
+		case (IXGBE_FLAG_RSS_ENABLED):
+			if (!tcs)
+				mrqc = IXGBE_MRQC_RSSEN;
+			else if (tcs <= 4)
+				mrqc = IXGBE_MRQC_RTRSS4TCEN;
+			else
+				mrqc = IXGBE_MRQC_RTRSS8TCEN;
+			break;
+		case (IXGBE_FLAG_SRIOV_ENABLED):
+			mrqc = IXGBE_MRQC_VMDQEN;
+			break;
+		default:
+			break;
+		}
 	}
 
 	/* Perform hash on these packet types */
@@ -4461,14 +4455,17 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 {
 	bool ret = false;
 	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_DCB];
-	int i, q;
+	int tcs = netdev_get_num_tc(adapter->netdev);
+	int max_q, i, q;
 
-	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED) || !tcs)
 		return ret;
 
+	max_q = adapter->netdev->num_tx_queues / tcs;
+
 	f->indices = 0;
-	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		q = min((int)num_online_cpus(), MAX_TRAFFIC_CLASS);
+	for (i = 0; i < tcs; i++) {
+		q = min((int)num_online_cpus(), max_q);
 		f->indices += q;
 	}
 
@@ -4680,55 +4677,6 @@ static void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
 	}
 }
 
-#define IXGBE_MAX_Q_PER_TC	(IXGBE_MAX_DCB_INDICES / MAX_TRAFFIC_CLASS)
-
-/* ixgbe_setup_tc - routine to configure net_device for multiple traffic
- * classes.
- *
- * @netdev: net device to configure
- * @tc: number of traffic classes to enable
- */
-int ixgbe_setup_tc(struct net_device *dev, u8 tc)
-{
-	int i;
-	unsigned int q, offset = 0;
-
-	if (!tc) {
-		netdev_reset_tc(dev);
-	} else {
-		struct ixgbe_adapter *adapter = netdev_priv(dev);
-
-		/* Hardware supports up to 8 traffic classes */
-		if (tc > MAX_TRAFFIC_CLASS || netdev_set_num_tc(dev, tc))
-			return -EINVAL;
-
-		/* Partition Tx queues evenly amongst traffic classes */
-		for (i = 0; i < tc; i++) {
-			q = min((int)num_online_cpus(), IXGBE_MAX_Q_PER_TC);
-			netdev_set_prio_tc_map(dev, i, i);
-			netdev_set_tc_queue(dev, i, q, offset);
-			offset += q;
-		}
-
-		/* This enables multiple traffic class support in the hardware
-		 * which defaults to strict priority transmission by default.
-		 * If traffic classes are already enabled perhaps through DCB
-		 * code path then existing configuration will be used.
-		 */
-		if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
-		    dev->dcbnl_ops && dev->dcbnl_ops->setdcbx) {
-			struct ieee_ets ets = {
-					.prio_tc = {0, 1, 2, 3, 4, 5, 6, 7},
-					      };
-			u8 mode = DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE;
-
-			dev->dcbnl_ops->setdcbx(dev, mode);
-			dev->dcbnl_ops->ieee_setets(dev, &ets);
-		}
-	}
-	return 0;
-}
-
 /**
  * ixgbe_cache_ring_dcb - Descriptor ring to register mapping for DCB
  * @adapter: board private structure to initialize
@@ -4742,7 +4690,7 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 	int i, j, k;
 	u8 num_tcs = netdev_get_num_tc(dev);
 
-	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+	if (!num_tcs)
 		return false;
 
 	for (i = 0, k = 0; i < num_tcs; i++) {
@@ -7220,6 +7168,95 @@ static struct rtnl_link_stats64 *ixgbe_get_stats64(struct net_device *netdev,
 	return stats;
 }
 
+/* ixgbe_validate_rtr - verify 802.1Qp to Rx packet buffer mapping is valid.
+ * #adapter: pointer to ixgbe_adapter
+ * @tc: number of traffic classes currently enabled
+ *
+ * Configure a valid 802.1Qp to Rx packet buffer mapping ie confirm
+ * 802.1Q priority maps to a packet buffer that exists.
+ */
+static void ixgbe_validate_rtr(struct ixgbe_adapter *adapter, u8 tc)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 reg, rsave;
+	int i;
+
+	/* 82598 have a static priority to TC mapping that can not
+	 * be changed so no validation is needed.
+	 */
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		return;
+
+	reg = IXGBE_READ_REG(hw, IXGBE_RTRUP2TC);
+	rsave = reg;
+
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		u8 up2tc = reg >> (i * IXGBE_RTRUP2TC_UP_SHIFT);
+
+		/* If up2tc is out of bounds default to zero */
+		if (up2tc > tc)
+			reg &= ~(0x7 << IXGBE_RTRUP2TC_UP_SHIFT);
+	}
+
+	if (reg != rsave)
+		IXGBE_WRITE_REG(hw, IXGBE_RTRUP2TC, reg);
+
+	return;
+}
+
+
+/* ixgbe_setup_tc - routine to configure net_device for multiple traffic
+ * classes.
+ *
+ * @netdev: net device to configure
+ * @tc: number of traffic classes to enable
+ */
+int ixgbe_setup_tc(struct net_device *dev, u8 tc)
+{
+	unsigned int q, i, offset = 0;
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	int max_q = adapter->netdev->num_tx_queues / tc;
+
+	/* If DCB is anabled do not remove traffic classes, multiple
+	 * traffic classes are required to implement DCB
+	 */
+	if (!tc && (adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+		return 0;
+
+	/* Hardware supports up to 8 traffic classes */
+	if (tc > MAX_TRAFFIC_CLASS ||
+	    (hw->mac.type == ixgbe_mac_82598EB && tc < MAX_TRAFFIC_CLASS))
+		return -EINVAL;
+
+	/* Hardware has to reinitialize queues and interrupts to
+	 * match packet buffer alignment. Unfortunantly, the
+	 * hardware is not flexible enough to do this dynamically.
+	 */
+	if (netif_running(dev))
+		ixgbe_close(dev);
+	ixgbe_clear_interrupt_scheme(adapter);
+
+	if (tc)
+		netdev_set_num_tc(dev, tc);
+	else
+		netdev_reset_tc(dev);
+
+	/* Partition Tx queues evenly amongst traffic classes */
+	for (i = 0; i < tc; i++) {
+		q = min((int)num_online_cpus(), max_q);
+		netdev_set_prio_tc_map(dev, i, i);
+		netdev_set_tc_queue(dev, i, q, offset);
+		offset += q;
+	}
+
+	ixgbe_init_interrupt_scheme(adapter);
+	ixgbe_validate_rtr(adapter, tc);
+	if (netif_running(dev))
+		ixgbe_open(dev);
+
+	return 0;
+}
 
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
@@ -7240,9 +7277,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_tx_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
-#ifdef CONFIG_IXGBE_DCB
 	.ndo_setup_tc		= ixgbe_setup_tc,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index c0849a6..5455064 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1881,6 +1881,7 @@ enum {
 #define IXGBE_MTQC_32VF         0x8 /* 4 TX Queues per pool w/32VF's */
 #define IXGBE_MTQC_64VF         0x4 /* 2 TX Queues per pool w/64VF's */
 #define IXGBE_MTQC_8TC_8TQ      0xC /* 8 TC if RT_ENA or 8 TQ if VT_ENA */
+#define IXGBE_MTQC_4TC_4TQ	0x8 /* 4 TC if RT_ENA or 4 TQ if VT_ENA */
 
 /* Receive Descriptor bit definitions */
 #define IXGBE_RXD_STAT_DD       0x01    /* Descriptor Done */
-- 
1.7.5.4

