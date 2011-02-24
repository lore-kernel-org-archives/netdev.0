From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 5/7] igb: add support for VF Transmit rate limit using iproute2
Date: Thu, 24 Feb 2011 02:58:27 -0800
Message-ID: <1298545109-8990-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1298545109-8990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Lior Levy <lior.levy@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8720 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756099Ab1BXK6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 05:58:37 -0500
In-Reply-To: <1298545109-8990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lior Levy <lior.levy@intel.com>

Implemented igb_ndo_set_vf_bw function which is being used
by iproute2 tool. In addition, updated igb_ndo_get_vf_config function
to show the actual rate limit to the user.

The rate limitation can be configured only when the link is up.
The rate limit value can be ranged between 0 and actual
link speed measured in Mbps. A value of '0' disables the rate limit for
this specific VF.

iproute2 usage will be 'ip link set ethX vf Y rate Z'.
After the command is made, the rate will be changed instantly.
To view the current rate limit, use 'ip link show ethX'.

The rates will be zeroed only upon driver reload or a link speed change.

This feature is being supported only by 82576 device.

Signed-off-by: Lior Levy <lior.levy@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_defines.h |    7 +++
 drivers/net/igb/e1000_regs.h    |    4 ++
 drivers/net/igb/igb.h           |    2 +
 drivers/net/igb/igb_main.c      |   88 ++++++++++++++++++++++++++++++++++++++-
 4 files changed, 99 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 6319ed9..ff46c91 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -770,4 +770,11 @@
 #define E1000_PCIEMISC_LX_DECISION      0x00000080 /* Lx power decision based
                                                       on DMA coal */
 
+/* Tx Rate-Scheduler Config fields */
+#define E1000_RTTBCNRC_RS_ENA		0x80000000
+#define E1000_RTTBCNRC_RF_DEC_MASK	0x00003FFF
+#define E1000_RTTBCNRC_RF_INT_SHIFT	14
+#define E1000_RTTBCNRC_RF_INT_MASK	\
+	(E1000_RTTBCNRC_RF_DEC_MASK << E1000_RTTBCNRC_RF_INT_SHIFT)
+
 #endif
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 8ac83c5..3a6f847 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -106,6 +106,10 @@
 
 #define E1000_RQDPC(_n) (0x0C030 + ((_n) * 0x40))
 
+/* TX Rate Limit Registers */
+#define E1000_RTTDQSEL	0x3604	/* Tx Desc Plane Queue Select - WO */
+#define E1000_RTTBCNRC	0x36B0	/* Tx BCN Rate-Scheduler Config - WO */
+
 /* Split and Replication RX Control - RW */
 #define E1000_RXPBS    0x02404  /* Rx Packet Buffer Size - RW */
 /*
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 92a4ef0..bbc5ebf 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -77,6 +77,7 @@ struct vf_data_storage {
 	unsigned long last_nack;
 	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
 	u16 pf_qos;
+	u16 tx_rate;
 };
 
 #define IGB_VF_FLAG_CTS            0x00000001 /* VF is clear to send data */
@@ -323,6 +324,7 @@ struct igb_adapter {
 	u16 rx_ring_count;
 	unsigned int vfs_allocated_count;
 	struct vf_data_storage *vf_data;
+	int vf_rate_link_speed;
 	u32 rss_queues;
 	u32 wvbr;
 };
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index cb6bf7b..88f8925 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -150,6 +150,7 @@ static int igb_ndo_set_vf_vlan(struct net_device *netdev,
 static int igb_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate);
 static int igb_ndo_get_vf_config(struct net_device *netdev, int vf,
 				 struct ifla_vf_info *ivi);
+static void igb_check_vf_rate_limit(struct igb_adapter *);
 
 #ifdef CONFIG_PM
 static int igb_suspend(struct pci_dev *, pm_message_t);
@@ -3511,6 +3512,7 @@ static void igb_watchdog_task(struct work_struct *work)
 			netif_carrier_on(netdev);
 
 			igb_ping_all_vfs(adapter);
+			igb_check_vf_rate_limit(adapter);
 
 			/* link state has changed, schedule phy info update */
 			if (!test_bit(__IGB_DOWN, &adapter->state))
@@ -6599,9 +6601,91 @@ static int igb_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	return igb_set_vf_mac(adapter, vf, mac);
 }
 
+static int igb_link_mbps(int internal_link_speed)
+{
+	switch (internal_link_speed) {
+	case SPEED_100:
+		return 100;
+	case SPEED_1000:
+		return 1000;
+	default:
+		return 0;
+	}
+}
+
+static void igb_set_vf_rate_limit(struct e1000_hw *hw, int vf, int tx_rate,
+				  int link_speed)
+{
+	int rf_dec, rf_int;
+	u32 bcnrc_val;
+
+	if (tx_rate != 0) {
+		/* Calculate the rate factor values to set */
+		rf_int = link_speed / tx_rate;
+		rf_dec = (link_speed - (rf_int * tx_rate));
+		rf_dec = (rf_dec * (1<<E1000_RTTBCNRC_RF_INT_SHIFT)) / tx_rate;
+
+		bcnrc_val = E1000_RTTBCNRC_RS_ENA;
+		bcnrc_val |= ((rf_int<<E1000_RTTBCNRC_RF_INT_SHIFT) &
+		               E1000_RTTBCNRC_RF_INT_MASK);
+		bcnrc_val |= (rf_dec & E1000_RTTBCNRC_RF_DEC_MASK);
+	} else {
+		bcnrc_val = 0;
+	}
+
+	wr32(E1000_RTTDQSEL, vf); /* vf X uses queue X */
+	wr32(E1000_RTTBCNRC, bcnrc_val);
+}
+
+static void igb_check_vf_rate_limit(struct igb_adapter *adapter)
+{
+	int actual_link_speed, i;
+	bool reset_rate = false;
+
+	/* VF TX rate limit was not set or not supported */
+	if ((adapter->vf_rate_link_speed == 0) ||
+	    (adapter->hw.mac.type != e1000_82576))
+		return;
+
+	actual_link_speed = igb_link_mbps(adapter->link_speed);
+	if (actual_link_speed != adapter->vf_rate_link_speed) {
+		reset_rate = true;
+		adapter->vf_rate_link_speed = 0;
+		dev_info(&adapter->pdev->dev,
+		         "Link speed has been changed. VF Transmit "
+		         "rate is disabled\n");
+	}
+
+	for (i = 0; i < adapter->vfs_allocated_count; i++) {
+		if (reset_rate)
+			adapter->vf_data[i].tx_rate = 0;
+
+		igb_set_vf_rate_limit(&adapter->hw, i,
+		                      adapter->vf_data[i].tx_rate,
+		                      actual_link_speed);
+	}
+}
+
 static int igb_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate)
 {
-	return -EOPNOTSUPP;
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	int actual_link_speed;
+
+	if (hw->mac.type != e1000_82576)
+		return -EOPNOTSUPP;
+
+	actual_link_speed = igb_link_mbps(adapter->link_speed);
+	if ((vf >= adapter->vfs_allocated_count) ||
+	    (!(rd32(E1000_STATUS) & E1000_STATUS_LU)) ||
+	    (tx_rate < 0) || (tx_rate > actual_link_speed))
+		return -EINVAL;
+
+	adapter->vf_rate_link_speed = actual_link_speed;
+	adapter->vf_data[vf].tx_rate = (u16)tx_rate;
+	igb_set_vf_rate_limit(hw, vf, tx_rate, actual_link_speed);
+
+	return 0;
 }
 
 static int igb_ndo_get_vf_config(struct net_device *netdev,
@@ -6612,7 +6696,7 @@ static int igb_ndo_get_vf_config(struct net_device *netdev,
 		return -EINVAL;
 	ivi->vf = vf;
 	memcpy(&ivi->mac, adapter->vf_data[vf].vf_mac_addresses, ETH_ALEN);
-	ivi->tx_rate = 0;
+	ivi->tx_rate = adapter->vf_data[vf].tx_rate;
 	ivi->vlan = adapter->vf_data[vf].pf_vlan;
 	ivi->qos = adapter->vf_data[vf].pf_qos;
 	return 0;
-- 
1.7.4

