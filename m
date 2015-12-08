From: kan.liang@intel.com
Subject: [RFC 2/2] i40e/ethtool: support per queue coalesce getting/setting
Date: Tue,  8 Dec 2015 04:42:30 +0000
Message-ID: <1449549750-12448-2-git-send-email-kan.liang@intel.com>
References: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46536 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933527AbbLHQYT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 11:24:19 -0500
In-Reply-To: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

If queue is not -1, apply rx and tx interrupt moderation value on
specific queue. Otherwise, apply the interrupt moderation value to all
queues.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 54 ++++++++++++++++++++------
 1 file changed, 42 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 6cb2b34..6f63e11 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1849,6 +1849,10 @@ static int i40e_get_coalesce(struct net_device *netdev,
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	struct i40e_q_vector *q_vector;
+	u16 vector = vsi->base_vector;
 
 	ec->tx_max_coalesced_frames_irq = vsi->work_limit;
 	ec->rx_max_coalesced_frames_irq = vsi->work_limit;
@@ -1870,17 +1874,44 @@ static int i40e_get_coalesce(struct net_device *netdev,
 	ec->rx_coalesce_usecs_high = vsi->int_rate_limit;
 	ec->tx_coalesce_usecs_high = vsi->int_rate_limit;
 
+	if (ec->queue > -1) {
+		if (ec->queue >= vsi->num_q_vectors) {
+			netif_info(pf, drv, netdev, "Invalid queue value, queue range is 0 - %d\n", vsi->num_q_vectors - 1);
+			return -EINVAL;
+		}
+
+		q_vector = vsi->q_vectors[ec->queue];
+		vector += ec->queue;
+
+		ec->rx_coalesce_usecs = ITR_REG_TO_USEC(rd32(hw, I40E_PFINT_ITRN(0, vector - 1)));
+		ec->tx_coalesce_usecs = ITR_REG_TO_USEC(rd32(hw, I40E_PFINT_ITRN(1, vector - 1)));
+	}
+
 	return 0;
 }
 
+static void i40e_set_itr_for_queue(struct i40e_vsi *vsi, int queue, u16 vector)
+{
+	struct i40e_q_vector *q_vector;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	u16 intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
+
+	q_vector = vsi->q_vectors[queue];
+	q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
+	wr32(hw, I40E_PFINT_ITRN(0, vector - 1), q_vector->rx.itr);
+	q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
+	wr32(hw, I40E_PFINT_ITRN(1, vector - 1), q_vector->tx.itr);
+	wr32(hw, I40E_PFINT_RATEN(vector - 1), intrl);
+	i40e_flush(hw);
+}
+
 static int i40e_set_coalesce(struct net_device *netdev,
 			     struct ethtool_coalesce *ec)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
-	struct i40e_q_vector *q_vector;
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
-	struct i40e_hw *hw = &pf->hw;
 	u16 vector;
 	int i;
 
@@ -1936,16 +1967,15 @@ static int i40e_set_coalesce(struct net_device *netdev,
 	else
 		vsi->tx_itr_setting &= ~I40E_ITR_DYNAMIC;
 
-	for (i = 0; i < vsi->num_q_vectors; i++, vector++) {
-		u16 intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
-
-		q_vector = vsi->q_vectors[i];
-		q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
-		wr32(hw, I40E_PFINT_ITRN(0, vector - 1), q_vector->rx.itr);
-		q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
-		wr32(hw, I40E_PFINT_ITRN(1, vector - 1), q_vector->tx.itr);
-		wr32(hw, I40E_PFINT_RATEN(vector - 1), intrl);
-		i40e_flush(hw);
+	if (ec->queue < 0) {
+		for (i = 0; i < vsi->num_q_vectors; i++, vector++)
+			i40e_set_itr_for_queue(vsi, i, vector);
+	} else {
+		if (ec->queue >= vsi->num_q_vectors) {
+			netif_info(pf, drv, netdev, "Invalid queue value, queue range is 0 - %d\n", vsi->num_q_vectors - 1);
+			return -EINVAL;
+		}
+		i40e_set_itr_for_queue(vsi, ec->queue, vector + ec->queue);
 	}
 
 	return 0;
-- 
1.7.11.7
