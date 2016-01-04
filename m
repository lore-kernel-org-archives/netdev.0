From: kan.liang@intel.com
Subject: [PATCH V2 5/5] i40e/ethtool: support coalesce setting by queue
Date: Mon,  4 Jan 2016 07:54:01 -0500
Message-ID: <1451912041-8860-5-git-send-email-kan.liang@intel.com>
References: <1451912041-8860-1-git-send-email-kan.liang@intel.com>
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, ben@decadent.org.uk,
	Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47950 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753804AbcADUMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 15:12:38 -0500
In-Reply-To: <1451912041-8860-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patch implements set_per_queue_coalesce for i40e driver.
For i40e driver, only rx and tx usecs have per queue value. Usually, the
queues number is the same as vectors number. Queue has its own vector.
Changing these two parameters by setting specific vector only impact the
specific queue. However, sometimes queues number is larger than vectors
number. Some queues have to share a vector. For this case, setting the
vector can impact all queues in the same vector.
Except rx and tx usecs, for other interrupt coalescing parameters, they
are shared among queues. The change to one queue will impact all queues.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---

Changes since V1:
 - Correct the way to find the vector for specific queue.

 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 46 +++++++++++++++++++++++---
 1 file changed, 41 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 2e7fdf5..9c15abb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1905,8 +1905,9 @@ static int i40e_get_per_queue_coalesce(struct net_device *netdev, int queue,
 	return __i40e_get_coalesce(netdev, ec, queue);
 }
 
-static int i40e_set_coalesce(struct net_device *netdev,
-			     struct ethtool_coalesce *ec)
+static int __i40e_set_coalesce(struct net_device *netdev,
+			       struct ethtool_coalesce *ec,
+			       int queue)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_q_vector *q_vector;
@@ -1914,6 +1915,7 @@ static int i40e_set_coalesce(struct net_device *netdev,
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
 	u16 vector;
+	u16 intrl;
 	int i;
 
 	if (ec->tx_max_coalesced_frames_irq || ec->rx_max_coalesced_frames_irq)
@@ -1968,14 +1970,35 @@ static int i40e_set_coalesce(struct net_device *netdev,
 	else
 		vsi->tx_itr_setting &= ~I40E_ITR_DYNAMIC;
 
-	for (i = 0; i < vsi->num_q_vectors; i++, vector++) {
-		u16 intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
+	if (queue < 0) {
+		for (i = 0; i < vsi->num_q_vectors; i++, vector++) {
+			intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
+
+			q_vector = vsi->q_vectors[i];
+			q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
+			wr32(hw, I40E_PFINT_ITRN(0, vector - 1), q_vector->rx.itr);
+			q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
+			wr32(hw, I40E_PFINT_ITRN(1, vector - 1), q_vector->tx.itr);
+			wr32(hw, I40E_PFINT_RATEN(vector - 1), intrl);
+			i40e_flush(hw);
+		}
+	} else {
+		if (queue >= vsi->num_queue_pairs) {
+			netif_info(pf, drv, netdev, "Invalid queue value, queue range is 0 - %d\n", vsi->num_queue_pairs - 1);
+			return -EINVAL;
+		}
+		intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
 
-		q_vector = vsi->q_vectors[i];
+		q_vector = vsi->rx_rings[queue]->q_vector;
+		vector = vsi->base_vector + q_vector->v_idx;
 		q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
 		wr32(hw, I40E_PFINT_ITRN(0, vector - 1), q_vector->rx.itr);
+
+		q_vector = vsi->tx_rings[queue]->q_vector;
+		vector = vsi->base_vector + q_vector->v_idx;
 		q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
 		wr32(hw, I40E_PFINT_ITRN(1, vector - 1), q_vector->tx.itr);
+
 		wr32(hw, I40E_PFINT_RATEN(vector - 1), intrl);
 		i40e_flush(hw);
 	}
@@ -1983,6 +2006,18 @@ static int i40e_set_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+static int i40e_set_coalesce(struct net_device *netdev,
+			     struct ethtool_coalesce *ec)
+{
+	return __i40e_set_coalesce(netdev, ec, -1);
+}
+
+static int i40e_set_per_queue_coalesce(struct net_device *netdev, int queue,
+				       struct ethtool_coalesce *ec)
+{
+	return __i40e_set_coalesce(netdev, ec, queue);
+}
+
 /**
  * i40e_get_rss_hash_opts - Get RSS hash Input Set for each flow type
  * @pf: pointer to the physical function struct
@@ -2844,6 +2879,7 @@ static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_priv_flags		= i40e_get_priv_flags,
 	.set_priv_flags		= i40e_set_priv_flags,
 	.get_per_queue_coalesce	= i40e_get_per_queue_coalesce,
+	.set_per_queue_coalesce	= i40e_set_per_queue_coalesce,
 };
 
 void i40e_set_ethtool_ops(struct net_device *netdev)
-- 
1.8.3.1
