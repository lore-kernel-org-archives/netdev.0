From: kan.liang@intel.com
Subject: [PATCH V2 4/5] i40e/ethtool: support coalesce getting by queue
Date: Mon,  4 Jan 2016 07:54:00 -0500
Message-ID: <1451912041-8860-4-git-send-email-kan.liang@intel.com>
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
	id S1753815AbcADUMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 15:12:40 -0500
In-Reply-To: <1451912041-8860-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patch implements get_per_queue_coalesce for i40e driver.
For i40e driver, only rx and tx usecs has per queue value. So only these
two parameters are read from specific vectors. Usually, the queues
number is the same as vectors number. Queue has its own vector. However,
sometimes queues number is larger than vectors number. some queues have
to share a vector. For this case, the last value assigned to any queues
in the same vector is return.
Except rx and tx usecs, for other interrupt coalescing parameters, they
are shared among queues. The values which are stored in vsi will be
return.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---

Changes since V1:
 - Correct the way to find the vector for specific queue.

 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 36 ++++++++++++++++++++++++--
 1 file changed, 34 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 29d5833..2e7fdf5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1845,11 +1845,16 @@ static int i40e_set_phys_id(struct net_device *netdev,
  * 125us (8000 interrupts per second) == ITR(62)
  */
 
-static int i40e_get_coalesce(struct net_device *netdev,
-			     struct ethtool_coalesce *ec)
+static int __i40e_get_coalesce(struct net_device *netdev,
+			       struct ethtool_coalesce *ec,
+			       int queue)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	struct i40e_q_vector *q_vector;
+	u16 vector;
 
 	ec->tx_max_coalesced_frames_irq = vsi->work_limit;
 	ec->rx_max_coalesced_frames_irq = vsi->work_limit;
@@ -1871,9 +1876,35 @@ static int i40e_get_coalesce(struct net_device *netdev,
 	ec->rx_coalesce_usecs_high = vsi->int_rate_limit;
 	ec->tx_coalesce_usecs_high = vsi->int_rate_limit;
 
+	if (queue > -1) {
+		if (queue >= vsi->num_queue_pairs) {
+			netif_info(pf, drv, netdev, "Invalid queue value, queue range is 0 - %d\n", vsi->num_queue_pairs - 1);
+			return -EINVAL;
+		}
+
+		q_vector = vsi->rx_rings[queue]->q_vector;
+		vector = vsi->base_vector + q_vector->v_idx;
+		ec->rx_coalesce_usecs = ITR_REG_TO_USEC(rd32(hw, I40E_PFINT_ITRN(0, vector - 1)));
+
+		q_vector = vsi->tx_rings[queue]->q_vector;
+		vector = vsi->base_vector + q_vector->v_idx;
+		ec->tx_coalesce_usecs = ITR_REG_TO_USEC(rd32(hw, I40E_PFINT_ITRN(1, vector - 1)));
+	}
 	return 0;
 }
 
+static int i40e_get_coalesce(struct net_device *netdev,
+			     struct ethtool_coalesce *ec)
+{
+	return __i40e_get_coalesce(netdev, ec, -1);
+}
+
+static int i40e_get_per_queue_coalesce(struct net_device *netdev, int queue,
+				       struct ethtool_coalesce *ec)
+{
+	return __i40e_get_coalesce(netdev, ec, queue);
+}
+
 static int i40e_set_coalesce(struct net_device *netdev,
 			     struct ethtool_coalesce *ec)
 {
@@ -2812,6 +2843,7 @@ static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_ts_info		= i40e_get_ts_info,
 	.get_priv_flags		= i40e_get_priv_flags,
 	.set_priv_flags		= i40e_set_priv_flags,
+	.get_per_queue_coalesce	= i40e_get_per_queue_coalesce,
 };
 
 void i40e_set_ethtool_ops(struct net_device *netdev)
-- 
1.8.3.1
