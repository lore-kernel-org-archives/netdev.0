From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e/i40evf: control auto ITR through ethtool
Date: Wed, 21 May 2014 05:01:07 -0700
Message-ID: <1400673673-31626-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:21038 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346AbaEUMBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:30 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

For all of our supported kernels, ethtool allows us to directly control
adaptive ITR instead of just faking it with an ITR value. Support this
capability so that user knows explicitly when ITR is being controlled
dynamically. Suggested by Ben Hutchings.

CC: Ben Hutchings <ben@decadent.org.uk>
Change-ID: Iae6b79c5db767a63d22ecd9a9c24acaff02a096e
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 57 ++++++++-----------
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 65 ++++++++++------------
 2 files changed, 52 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index f629294..a89b3c6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1009,14 +1009,13 @@ static int i40e_get_coalesce(struct net_device *netdev,
 	ec->rx_max_coalesced_frames_irq = vsi->work_limit;
 
 	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting))
-		ec->rx_coalesce_usecs = 1;
-	else
-		ec->rx_coalesce_usecs = vsi->rx_itr_setting;
+		ec->use_adaptive_rx_coalesce = 1;
 
 	if (ITR_IS_DYNAMIC(vsi->tx_itr_setting))
-		ec->tx_coalesce_usecs = 1;
-	else
-		ec->tx_coalesce_usecs = vsi->tx_itr_setting;
+		ec->use_adaptive_tx_coalesce = 1;
+
+	ec->rx_coalesce_usecs = vsi->rx_itr_setting & ~I40E_ITR_DYNAMIC;
+	ec->tx_coalesce_usecs = vsi->tx_itr_setting & ~I40E_ITR_DYNAMIC;
 
 	return 0;
 }
@@ -1035,37 +1034,27 @@ static int i40e_set_coalesce(struct net_device *netdev,
 	if (ec->tx_max_coalesced_frames_irq || ec->rx_max_coalesced_frames_irq)
 		vsi->work_limit = ec->tx_max_coalesced_frames_irq;
 
-	switch (ec->rx_coalesce_usecs) {
-	case 0:
-		vsi->rx_itr_setting = 0;
-		break;
-	case 1:
-		vsi->rx_itr_setting = (I40E_ITR_DYNAMIC |
-				       ITR_REG_TO_USEC(I40E_ITR_RX_DEF));
-		break;
-	default:
-		if ((ec->rx_coalesce_usecs < (I40E_MIN_ITR << 1)) ||
-		    (ec->rx_coalesce_usecs > (I40E_MAX_ITR << 1)))
-			return -EINVAL;
+	if ((ec->rx_coalesce_usecs >= (I40E_MIN_ITR << 1)) &&
+	    (ec->rx_coalesce_usecs <= (I40E_MAX_ITR << 1)))
 		vsi->rx_itr_setting = ec->rx_coalesce_usecs;
-		break;
-	}
+	else
+		return -EINVAL;
 
-	switch (ec->tx_coalesce_usecs) {
-	case 0:
-		vsi->tx_itr_setting = 0;
-		break;
-	case 1:
-		vsi->tx_itr_setting = (I40E_ITR_DYNAMIC |
-				       ITR_REG_TO_USEC(I40E_ITR_TX_DEF));
-		break;
-	default:
-		if ((ec->tx_coalesce_usecs < (I40E_MIN_ITR << 1)) ||
-		    (ec->tx_coalesce_usecs > (I40E_MAX_ITR << 1)))
-			return -EINVAL;
+	if ((ec->tx_coalesce_usecs >= (I40E_MIN_ITR << 1)) &&
+	    (ec->tx_coalesce_usecs <= (I40E_MAX_ITR << 1)))
 		vsi->tx_itr_setting = ec->tx_coalesce_usecs;
-		break;
-	}
+	else
+		return -EINVAL;
+
+	if (ec->use_adaptive_rx_coalesce)
+		vsi->rx_itr_setting |= I40E_ITR_DYNAMIC;
+	else
+		vsi->rx_itr_setting &= ~I40E_ITR_DYNAMIC;
+
+	if (ec->use_adaptive_tx_coalesce)
+		vsi->tx_itr_setting |= I40E_ITR_DYNAMIC;
+	else
+		vsi->tx_itr_setting &= ~I40E_ITR_DYNAMIC;
 
 	vector = vsi->base_vector;
 	for (i = 0; i < vsi->num_q_vectors; i++, vector++) {
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index c079166f..df4dcfd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -295,14 +295,13 @@ static int i40evf_get_coalesce(struct net_device *netdev,
 	ec->rx_max_coalesced_frames = vsi->work_limit;
 
 	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting))
-		ec->rx_coalesce_usecs = 1;
-	else
-		ec->rx_coalesce_usecs = vsi->rx_itr_setting;
+		ec->use_adaptive_rx_coalesce = 1;
 
 	if (ITR_IS_DYNAMIC(vsi->tx_itr_setting))
-		ec->tx_coalesce_usecs = 1;
-	else
-		ec->tx_coalesce_usecs = vsi->tx_itr_setting;
+		ec->use_adaptive_tx_coalesce = 1;
+
+	ec->rx_coalesce_usecs = vsi->rx_itr_setting & ~I40E_ITR_DYNAMIC;
+	ec->tx_coalesce_usecs = vsi->tx_itr_setting & ~I40E_ITR_DYNAMIC;
 
 	return 0;
 }
@@ -323,40 +322,34 @@ static int i40evf_set_coalesce(struct net_device *netdev,
 	struct i40e_q_vector *q_vector;
 	int i;
 
-	if (ec->tx_max_coalesced_frames || ec->rx_max_coalesced_frames)
-		vsi->work_limit = ec->tx_max_coalesced_frames;
+	if (ec->tx_max_coalesced_frames_irq || ec->rx_max_coalesced_frames_irq)
+		vsi->work_limit = ec->tx_max_coalesced_frames_irq;
 
-	switch (ec->rx_coalesce_usecs) {
-	case 0:
-		vsi->rx_itr_setting = 0;
-		break;
-	case 1:
-		vsi->rx_itr_setting = (I40E_ITR_DYNAMIC
-				       | ITR_REG_TO_USEC(I40E_ITR_RX_DEF));
-		break;
-	default:
-		if ((ec->rx_coalesce_usecs < (I40E_MIN_ITR << 1)) ||
-		    (ec->rx_coalesce_usecs > (I40E_MAX_ITR << 1)))
-			return -EINVAL;
+	if ((ec->rx_coalesce_usecs >= (I40E_MIN_ITR << 1)) &&
+	    (ec->rx_coalesce_usecs <= (I40E_MAX_ITR << 1)))
 		vsi->rx_itr_setting = ec->rx_coalesce_usecs;
-		break;
-	}
 
-	switch (ec->tx_coalesce_usecs) {
-	case 0:
-		vsi->tx_itr_setting = 0;
-		break;
-	case 1:
-		vsi->tx_itr_setting = (I40E_ITR_DYNAMIC
-				       | ITR_REG_TO_USEC(I40E_ITR_TX_DEF));
-		break;
-	default:
-		if ((ec->tx_coalesce_usecs < (I40E_MIN_ITR << 1)) ||
-		    (ec->tx_coalesce_usecs > (I40E_MAX_ITR << 1)))
-			return -EINVAL;
+	else
+		return -EINVAL;
+
+	if ((ec->tx_coalesce_usecs >= (I40E_MIN_ITR << 1)) &&
+	    (ec->tx_coalesce_usecs <= (I40E_MAX_ITR << 1)))
 		vsi->tx_itr_setting = ec->tx_coalesce_usecs;
-		break;
-	}
+	else if (ec->use_adaptive_tx_coalesce)
+		vsi->tx_itr_setting = (I40E_ITR_DYNAMIC |
+				       ITR_REG_TO_USEC(I40E_ITR_RX_DEF));
+	else
+		return -EINVAL;
+
+	if (ec->use_adaptive_rx_coalesce)
+		vsi->rx_itr_setting |= I40E_ITR_DYNAMIC;
+	else
+		vsi->rx_itr_setting &= ~I40E_ITR_DYNAMIC;
+
+	if (ec->use_adaptive_tx_coalesce)
+		vsi->tx_itr_setting |= I40E_ITR_DYNAMIC;
+	else
+		vsi->tx_itr_setting &= ~I40E_ITR_DYNAMIC;
 
 	for (i = 0; i < adapter->num_msix_vectors - NONQ_VECS; i++) {
 		q_vector = adapter->q_vector[i];
-- 
1.9.0
