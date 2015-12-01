From: kan.liang@intel.com
Subject: [RFC 2/4] i40e: handle per queue tx_usecs setting
Date: Tue,  1 Dec 2015 08:01:30 +0000
Message-ID: <1448956892-15509-2-git-send-email-kan.liang@intel.com>
References: <1448956892-15509-1-git-send-email-kan.liang@intel.com>
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, john.r.fastabend@intel.com,
	ogerlitz@mellanox.com, edumazet@google.com, jiri@mellanox.com,
	sfeldma@gmail.com, gospo@cumulusnetworks.com,
	sasha.levin@oracle.com, f.fainelli@gmail.com, dsahern@gmail.com,
	tj@kernel.org, cascardo@redhat.com, corbet@lwn.net,
	Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4404 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752575AbbLATnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 14:43:20 -0500
In-Reply-To: <1448956892-15509-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Handle ndo_get_per_queue_tx_usecs and ndo_set_per_queue_tx_usecs
options for i40e driver specifically.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 39 +++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4b7d874..d4310ae 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8673,6 +8673,43 @@ static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				       nlflags, 0, 0, filter_mask, NULL);
 }
 
+/**
+ * i40e_ndo_get_per_queue_tx_usecs - Get per queue coalesce parameter tx_usecs
+ * @dev: the netdev being configured
+ * @index: queue index
+ *
+ * Return tx_usecs for specific channel
+ **/
+u32 i40e_ndo_get_per_queue_tx_usecs(struct net_device *dev, int index)
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	u32 val;
+
+	val = rd32(hw, I40E_PFINT_ITRN(1, index));
+
+	return (val * 2);
+}
+
+/**
+ * i40e_ndo_set_per_queue_tx_usecs - Set per queue coalesce parameter tx_usecs
+ * @dev: the netdev being configured
+ * @index: queue index
+ * @val: tx_usecs value
+ **/
+void i40e_ndo_set_per_queue_tx_usecs(struct net_device *dev, int index, u32 val)
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+
+	wr32(hw, I40E_PFINT_ITRN(1, index), val / 2);
+	i40e_flush(hw);
+}
+
 #define I40E_MAX_TUNNEL_HDR_LEN 80
 /**
  * i40e_features_check - Validate encapsulated packet conforms to limits
@@ -8729,6 +8766,8 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_features_check	= i40e_features_check,
 	.ndo_bridge_getlink	= i40e_ndo_bridge_getlink,
 	.ndo_bridge_setlink	= i40e_ndo_bridge_setlink,
+	.ndo_get_per_queue_tx_usecs	= i40e_ndo_get_per_queue_tx_usecs,
+	.ndo_set_per_queue_tx_usecs	= i40e_ndo_set_per_queue_tx_usecs,
 };
 
 /**
-- 
1.7.11.7
