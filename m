From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/14] ixgbe: add a callback to set the maximum transmit bitrate
Date: Mon,  4 Apr 2016 17:59:02 -0700
Message-ID: <1459817945-144915-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459817945-144915-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Rostislav Pehlivanov <atomnuker@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7124 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756759AbcDEA7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 20:59:12 -0400
In-Reply-To: <1459817945-144915-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rostislav Pehlivanov <atomnuker@gmail.com>

This commit adds a callback which allows to adjust the maximum transmit
bitrate the card can output. This makes it possible to get a smooth
traffic instead of the default burst-y behaviour when trying to output
e.g. a video stream.

Much of the logic needed to get a correct bcnrc_val was taken from the
ixgbe_set_vf_rate_limit() function.

Signed-off-by: Rostislav Pehlivanov <atomnuker@gmail.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 31 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  1 +
 3 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0f007d9..115656c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1078,6 +1078,36 @@ static void ixgbe_tx_timeout_reset(struct ixgbe_adapter *adapter)
 }
 
 /**
+ * ixgbe_tx_maxrate - callback to set the maximum per-queue bitrate
+ **/
+static int ixgbe_tx_maxrate(struct net_device *netdev,
+			    int queue_index, u32 maxrate)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 bcnrc_val = ixgbe_link_mbps(adapter);
+
+	if (!maxrate)
+		return 0;
+
+	/* Calculate the rate factor values to set */
+	bcnrc_val <<= IXGBE_RTTBCNRC_RF_INT_SHIFT;
+	bcnrc_val /= maxrate;
+
+	/* clear everything but the rate factor */
+	bcnrc_val &= IXGBE_RTTBCNRC_RF_INT_MASK |
+	IXGBE_RTTBCNRC_RF_DEC_MASK;
+
+	/* enable the rate scheduler */
+	bcnrc_val |= IXGBE_RTTBCNRC_RS_ENA;
+
+	IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, queue_index);
+	IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRC, bcnrc_val);
+
+	return 0;
+}
+
+/**
  * ixgbe_clean_tx_irq - Reclaim resources after transmit completes
  * @q_vector: structure containing interrupt and ring information
  * @tx_ring: tx ring to clean
@@ -8807,6 +8837,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_mac_address	= ixgbe_set_mac,
 	.ndo_change_mtu		= ixgbe_change_mtu,
 	.ndo_tx_timeout		= ixgbe_tx_timeout,
+	.ndo_set_tx_maxrate	= ixgbe_tx_maxrate,
 	.ndo_vlan_rx_add_vid	= ixgbe_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ixgbe_vlan_rx_kill_vid,
 	.ndo_do_ioctl		= ixgbe_ioctl,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 4bc24963..adcf000 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1398,7 +1398,7 @@ out:
 	return err;
 }
 
-static int ixgbe_link_mbps(struct ixgbe_adapter *adapter)
+int ixgbe_link_mbps(struct ixgbe_adapter *adapter)
 {
 	switch (adapter->link_speed) {
 	case IXGBE_LINK_SPEED_100_FULL:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index dad9257..47e65e2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -44,6 +44,7 @@ void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter);
 int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int queue, u8 *mac);
 int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int queue, u16 vlan,
 			   u8 qos);
+int ixgbe_link_mbps(struct ixgbe_adapter *adapter);
 int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int min_tx_rate,
 			int max_tx_rate);
 int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
-- 
2.5.5
