From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 20/21] ixgbe: add support for VF Transmit rate limit using iproute2
Date: Sat, 12 Mar 2011 04:20:27 -0800
Message-ID: <1299932428-3114-21-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Lior Levy <lior.levy@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2695 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754021Ab1CLMVC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:21:02 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lior Levy <lior.levy@intel.com>

Implemented ixgbe_ndo_set_vf_bw function which is being used by iproute2
tool. In addition, updated ixgbe_ndo_get_vf_config function to show the
actual rate limit to the user.

The rate limitation can be configured only when the link is up and the
link speed is 10Gb.
The rate limit value can be 0 or ranged between 11 and actual link
speed measured in Mbps. A value of '0' disables the rate limit for
this specific VF.

iproute2 usage will be 'ip link set ethX vf Y rate Z'.
After the command is made, the rate will be changed instantly.
To view the current rate limit, use 'ip link show ethX'.

The rates will be zeroed only upon driver reload or a link speed change.

This feature is being supported by 82599 and X540 devices.

Signed-off-by: Lior Levy <lior.levy@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h       |    2 +
 drivers/net/ixgbe/ixgbe_main.c  |    1 +
 drivers/net/ixgbe/ixgbe_sriov.c |   85 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_sriov.h |    1 +
 drivers/net/ixgbe/ixgbe_type.h  |    6 +++
 5 files changed, 93 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index b7e62d5..8d46802 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -118,6 +118,7 @@ struct vf_data_storage {
 	bool pf_set_mac;
 	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
 	u16 pf_qos;
+	u16 tx_rate;
 };
 
 /* wrapper around a pointer to a socket buffer,
@@ -468,6 +469,7 @@ struct ixgbe_adapter {
 	DECLARE_BITMAP(active_vfs, IXGBE_MAX_VF_FUNCTIONS);
 	unsigned int num_vfs;
 	struct vf_data_storage *vfinfo;
+	int vf_rate_link_speed;
 };
 
 enum ixbge_state_t {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 38f9758..f17e4a7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6217,6 +6217,7 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 			       (flow_tx ? "TX" : "None"))));
 
 			netif_carrier_on(netdev);
+			ixgbe_check_vf_rate_limit(adapter);
 		} else {
 			/* Force detection of hung controller */
 			for (i = 0; i < adapter->num_tx_queues; i++) {
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index 58c9b45..6e50d83 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -478,9 +478,90 @@ out:
        return err;
 }
 
+static int ixgbe_link_mbps(int internal_link_speed)
+{
+	switch (internal_link_speed) {
+	case IXGBE_LINK_SPEED_100_FULL:
+		return 100;
+	case IXGBE_LINK_SPEED_1GB_FULL:
+		return 1000;
+	case IXGBE_LINK_SPEED_10GB_FULL:
+		return 10000;
+	default:
+		return 0;
+	}
+}
+
+static void ixgbe_set_vf_rate_limit(struct ixgbe_hw *hw, int vf, int tx_rate,
+				    int link_speed)
+{
+	int rf_dec, rf_int;
+	u32 bcnrc_val;
+
+	if (tx_rate != 0) {
+		/* Calculate the rate factor values to set */
+		rf_int = link_speed / tx_rate;
+		rf_dec = (link_speed - (rf_int * tx_rate));
+		rf_dec = (rf_dec * (1<<IXGBE_RTTBCNRC_RF_INT_SHIFT)) / tx_rate;
+
+		bcnrc_val = IXGBE_RTTBCNRC_RS_ENA;
+		bcnrc_val |= ((rf_int<<IXGBE_RTTBCNRC_RF_INT_SHIFT) &
+		               IXGBE_RTTBCNRC_RF_INT_MASK);
+		bcnrc_val |= (rf_dec & IXGBE_RTTBCNRC_RF_DEC_MASK);
+	} else {
+		bcnrc_val = 0;
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, 2*vf); /* vf Y uses queue 2*Y */
+	IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRC, bcnrc_val);
+}
+
+void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter)
+{
+	int actual_link_speed, i;
+	bool reset_rate = false;
+
+	/* VF Tx rate limit was not set */
+	if (adapter->vf_rate_link_speed == 0)
+		return;
+
+	actual_link_speed = ixgbe_link_mbps(adapter->link_speed);
+	if (actual_link_speed != adapter->vf_rate_link_speed) {
+		reset_rate = true;
+		adapter->vf_rate_link_speed = 0;
+		dev_info(&adapter->pdev->dev,
+		         "Link speed has been changed. VF Transmit rate "
+		         "is disabled\n");
+	}
+
+	for (i = 0; i < adapter->num_vfs; i++) {
+		if (reset_rate)
+			adapter->vfinfo[i].tx_rate = 0;
+
+		ixgbe_set_vf_rate_limit(&adapter->hw, i,
+					adapter->vfinfo[i].tx_rate,
+					actual_link_speed);
+	}
+}
+
 int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate)
 {
-	return -EOPNOTSUPP;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	int actual_link_speed;
+
+	actual_link_speed = ixgbe_link_mbps(adapter->link_speed);
+	if ((vf >= adapter->num_vfs) || (!adapter->link_up) ||
+	    (tx_rate > actual_link_speed) || (actual_link_speed != 10000) ||
+	    ((tx_rate != 0) && (tx_rate <= 10)))
+	    /* rate limit cannot be set to 10Mb or less in 10Gb adapters */
+		return -EINVAL;
+
+	adapter->vf_rate_link_speed = actual_link_speed;
+	adapter->vfinfo[vf].tx_rate = (u16)tx_rate;
+	ixgbe_set_vf_rate_limit(hw, vf, tx_rate, actual_link_speed);
+
+	return 0;
 }
 
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
@@ -491,7 +572,7 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 		return -EINVAL;
 	ivi->vf = vf;
 	memcpy(&ivi->mac, adapter->vfinfo[vf].vf_mac_addresses, ETH_ALEN);
-	ivi->tx_rate = 0;
+	ivi->tx_rate = adapter->vfinfo[vf].tx_rate;
 	ivi->vlan = adapter->vfinfo[vf].pf_vlan;
 	ivi->qos = adapter->vfinfo[vf].pf_qos;
 	return 0;
diff --git a/drivers/net/ixgbe/ixgbe_sriov.h b/drivers/net/ixgbe/ixgbe_sriov.h
index e7dd029..3417556 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ixgbe/ixgbe_sriov.h
@@ -40,6 +40,7 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int queue, u16 vlan,
 int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi);
+void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
 
 #endif /* _IXGBE_SRIOV_H_ */
 
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 63d862d..25c1fb7 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -533,6 +533,12 @@
 #define IXGBE_RTTDTECC    0x04990
 #define IXGBE_RTTDTECC_NO_BCN   0x00000100
 #define IXGBE_RTTBCNRC    0x04984
+#define IXGBE_RTTBCNRC_RS_ENA	0x80000000
+#define IXGBE_RTTBCNRC_RF_DEC_MASK	0x00003FFF
+#define IXGBE_RTTBCNRC_RF_INT_SHIFT	14
+#define IXGBE_RTTBCNRC_RF_INT_MASK	\
+	(IXGBE_RTTBCNRC_RF_DEC_MASK << IXGBE_RTTBCNRC_RF_INT_SHIFT)
+
 
 /* FCoE registers */
 #define IXGBE_FCPTRL    0x02410 /* FC User Desc. PTR Low */
-- 
1.7.4

