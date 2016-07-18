From: kan.liang@intel.com
Subject: [RFC PATCH 12/30] i40e/netpolicy: implement ndo_set_net_policy
Date: Sun, 17 Jul 2016 23:56:06 -0700
Message-ID: <1468824984-65318-13-git-send-email-kan.liang@intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com,
	andi@firstfloor.org, Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

Setting net policy for all tx and rx queues according to policy name.
For i40e driver, the policy only changes per queue interrupt moderation.
It uses new ethtool callback (per queue coalesce setting) to configure
the driver.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  3 ++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  6 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 43 ++++++++++++++++++++++++++
 3 files changed, 49 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index e83fc8a..a4bd430 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -862,4 +862,7 @@ i40e_status i40e_get_npar_bw_setting(struct i40e_pf *pf);
 i40e_status i40e_set_npar_bw_setting(struct i40e_pf *pf);
 i40e_status i40e_commit_npar_bw_setting(struct i40e_pf *pf);
 void i40e_print_link_message(struct i40e_vsi *vsi, bool isup);
+void i40e_set_itr_per_queue(struct i40e_vsi *vsi,
+			    struct ethtool_coalesce *ec,
+			    int queue);
 #endif /* _I40E_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 4962e85..1f3537e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2012,9 +2012,9 @@ static int i40e_get_per_queue_coalesce(struct net_device *netdev, u32 queue,
 	return __i40e_get_coalesce(netdev, ec, queue);
 }
 
-static void i40e_set_itr_per_queue(struct i40e_vsi *vsi,
-				   struct ethtool_coalesce *ec,
-				   int queue)
+void i40e_set_itr_per_queue(struct i40e_vsi *vsi,
+			    struct ethtool_coalesce *ec,
+			    int queue)
 {
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8a919e44..3336373 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9035,6 +9035,48 @@ static int i40e_ndo_get_irq_info(struct net_device *dev,
 
 	return 0;
 }
+
+/**
+ * i40e_set_net_policy
+ * @dev: the net device pointer
+ * @name: policy name
+ *
+ * set policy to each tx and rx queue
+ * Returns 0 on success, negative on failure
+ */
+static int i40e_set_net_policy(struct net_device *dev,
+			       enum netpolicy_name name)
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct netpolicy_object *obj;
+	struct ethtool_coalesce ec;
+
+	if (policy_param[name][NETPOLICY_RX] > 0) {
+		ec.rx_coalesce_usecs = policy_param[name][NETPOLICY_RX];
+		ec.use_adaptive_rx_coalesce = 0;
+	} else if (policy_param[name][NETPOLICY_RX] == 0) {
+		ec.use_adaptive_rx_coalesce = 1;
+	} else {
+		return -EINVAL;
+	}
+
+	if (policy_param[name][NETPOLICY_TX] > 0) {
+		ec.tx_coalesce_usecs = policy_param[name][NETPOLICY_TX];
+		ec.use_adaptive_tx_coalesce = 0;
+	} else if (policy_param[name][NETPOLICY_TX] == 0) {
+		ec.use_adaptive_tx_coalesce = 1;
+	} else {
+		return -EINVAL;
+	}
+
+	/*For i40e driver, tx and rx are always in pair */
+	list_for_each_entry(obj, &dev->netpolicy->obj_list[NETPOLICY_RX][name], list) {
+		i40e_set_itr_per_queue(vsi, &ec, obj->queue);
+	}
+
+	return 0;
+}
 #endif /* CONFIG_NETPOLICY */
 
 static const struct net_device_ops i40e_netdev_ops = {
@@ -9076,6 +9118,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 #ifdef CONFIG_NETPOLICY
 	.ndo_netpolicy_init	= i40e_ndo_netpolicy_init,
 	.ndo_get_irq_info	= i40e_ndo_get_irq_info,
+	.ndo_set_net_policy	= i40e_set_net_policy,
 #endif /* CONFIG_NETPOLICY */
 };
 
-- 
2.5.5
