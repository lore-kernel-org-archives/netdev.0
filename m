From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] ixgbe: Fix VF rate limiting to correctly account for more queues per VF
Date: Sun, 16 Sep 2012 21:15:37 -0700
Message-ID: <1347855342-6610-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44766 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750782Ab2IQEPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 00:15:49 -0400
In-Reply-To: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change fixes the assumptions of the rate limiting code that previously
assumed that each VF would only ever have 2 queues.  This update makes it
so that we now use a queues per pool value that is determined based on the
VMDq feature mask.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-By: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Robert Garrett <RobertX.Garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 100 +++++++++++++++----------
 1 file changed, 59 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 3b1c914..dce48bf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -815,9 +815,9 @@ out:
        return err;
 }
 
-static int ixgbe_link_mbps(int internal_link_speed)
+static int ixgbe_link_mbps(struct ixgbe_adapter *adapter)
 {
-	switch (internal_link_speed) {
+	switch (adapter->link_speed) {
 	case IXGBE_LINK_SPEED_100_FULL:
 		return 100;
 	case IXGBE_LINK_SPEED_1GB_FULL:
@@ -829,27 +829,30 @@ static int ixgbe_link_mbps(int internal_link_speed)
 	}
 }
 
-static void ixgbe_set_vf_rate_limit(struct ixgbe_hw *hw, int vf, int tx_rate,
-				    int link_speed)
+static void ixgbe_set_vf_rate_limit(struct ixgbe_adapter *adapter, int vf)
 {
-	int rf_dec, rf_int;
-	u32 bcnrc_val;
+	struct ixgbe_ring_feature *vmdq = &adapter->ring_feature[RING_F_VMDQ];
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 bcnrc_val = 0;
+	u16 queue, queues_per_pool;
+	u16 tx_rate = adapter->vfinfo[vf].tx_rate;
+
+	if (tx_rate) {
+		/* start with base link speed value */
+		bcnrc_val = adapter->vf_rate_link_speed;
 
-	if (tx_rate != 0) {
 		/* Calculate the rate factor values to set */
-		rf_int = link_speed / tx_rate;
-		rf_dec = (link_speed - (rf_int * tx_rate));
-		rf_dec = (rf_dec * (1<<IXGBE_RTTBCNRC_RF_INT_SHIFT)) / tx_rate;
-
-		bcnrc_val = IXGBE_RTTBCNRC_RS_ENA;
-		bcnrc_val |= ((rf_int<<IXGBE_RTTBCNRC_RF_INT_SHIFT) &
-		               IXGBE_RTTBCNRC_RF_INT_MASK);
-		bcnrc_val |= (rf_dec & IXGBE_RTTBCNRC_RF_DEC_MASK);
-	} else {
-		bcnrc_val = 0;
+		bcnrc_val <<= IXGBE_RTTBCNRC_RF_INT_SHIFT;
+		bcnrc_val /= tx_rate;
+
+		/* clear everything but the rate factor */
+		bcnrc_val &= IXGBE_RTTBCNRC_RF_INT_MASK |
+			     IXGBE_RTTBCNRC_RF_DEC_MASK;
+
+		/* enable the rate scheduler */
+		bcnrc_val |= IXGBE_RTTBCNRC_RS_ENA;
 	}
 
-	IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, 2*vf); /* vf Y uses queue 2*Y */
 	/*
 	 * Set global transmit compensation time to the MMW_SIZE in RTTBCNRM
 	 * register. Typically MMW_SIZE=0x014 if 9728-byte jumbo is supported
@@ -866,53 +869,68 @@ static void ixgbe_set_vf_rate_limit(struct ixgbe_hw *hw, int vf, int tx_rate,
 		break;
 	}
 
-	IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRC, bcnrc_val);
+	/* determine how many queues per pool based on VMDq mask */
+	queues_per_pool = __ALIGN_MASK(1, ~vmdq->mask);
+
+	/* write value for all Tx queues belonging to VF */
+	for (queue = 0; queue < queues_per_pool; queue++) {
+		unsigned int reg_idx = (vf * queues_per_pool) + queue;
+
+		IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, reg_idx);
+		IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRC, bcnrc_val);
+	}
 }
 
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter)
 {
-	int actual_link_speed, i;
-	bool reset_rate = false;
+	int i;
 
 	/* VF Tx rate limit was not set */
-	if (adapter->vf_rate_link_speed == 0)
+	if (!adapter->vf_rate_link_speed)
 		return;
 
-	actual_link_speed = ixgbe_link_mbps(adapter->link_speed);
-	if (actual_link_speed != adapter->vf_rate_link_speed) {
-		reset_rate = true;
+	if (ixgbe_link_mbps(adapter) != adapter->vf_rate_link_speed) {
 		adapter->vf_rate_link_speed = 0;
 		dev_info(&adapter->pdev->dev,
-		         "Link speed has been changed. VF Transmit rate "
-		         "is disabled\n");
+			 "Link speed has been changed. VF Transmit rate is disabled\n");
 	}
 
 	for (i = 0; i < adapter->num_vfs; i++) {
-		if (reset_rate)
+		if (!adapter->vf_rate_link_speed)
 			adapter->vfinfo[i].tx_rate = 0;
 
-		ixgbe_set_vf_rate_limit(&adapter->hw, i,
-					adapter->vfinfo[i].tx_rate,
-					actual_link_speed);
+		ixgbe_set_vf_rate_limit(adapter, i);
 	}
 }
 
 int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
-	int actual_link_speed;
+	int link_speed;
 
-	actual_link_speed = ixgbe_link_mbps(adapter->link_speed);
-	if ((vf >= adapter->num_vfs) || (!adapter->link_up) ||
-	    (tx_rate > actual_link_speed) || (actual_link_speed != 10000) ||
-	    ((tx_rate != 0) && (tx_rate <= 10)))
-	    /* rate limit cannot be set to 10Mb or less in 10Gb adapters */
+	/* verify VF is active */
+	if (vf >= adapter->num_vfs)
 		return -EINVAL;
 
-	adapter->vf_rate_link_speed = actual_link_speed;
-	adapter->vfinfo[vf].tx_rate = (u16)tx_rate;
-	ixgbe_set_vf_rate_limit(hw, vf, tx_rate, actual_link_speed);
+	/* verify link is up */
+	if (!adapter->link_up)
+		return -EINVAL;
+
+	/* verify we are linked at 10Gbps */
+	link_speed = ixgbe_link_mbps(adapter);
+	if (link_speed != 10000)
+		return -EINVAL;
+
+	/* rate limit cannot be less than 10Mbs or greater than link speed */
+	if (tx_rate && ((tx_rate <= 10) || (tx_rate > link_speed)))
+		return -EINVAL;
+
+	/* store values */
+	adapter->vf_rate_link_speed = link_speed;
+	adapter->vfinfo[vf].tx_rate = tx_rate;
+
+	/* update hardware configuration */
+	ixgbe_set_vf_rate_limit(adapter, vf);
 
 	return 0;
 }
-- 
1.7.11.4
