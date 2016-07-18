From: kan.liang@intel.com
Subject: [RFC PATCH 15/30] i40e/netpolicy: add MIX policy support
Date: Sun, 17 Jul 2016 23:56:09 -0700
Message-ID: <1468824984-65318-16-git-send-email-kan.liang@intel.com>
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

Enable i40e MIX policy support. Based on the test, the MIX policy has
better performance if increasing rx interrupt moderation a little bit.

For evaluating the MIX policy performance, mixed workloads are tested.
The mixed workloads are combination of throughput-first workload and
latency-first workload. Five different types of combinations are
evaluated.
(pure throughput-first workload, pure latency-first workloads,
 2/3 throughput-first workload + 1/3 latency-first workloads,
 1/3 throughput-first workload + 2/3 latency-first workloads and
 1/2 throughput-first workload + 1/2 latency-first workloads).

For caculating the performance of mixed workloads, a weighted sum system
is also introduced. Here is the formula.

Score = normalized_latency * Weight + normalized_throughput * (1 -
Weight).

If we assume that the user has an equal interest in latency and
throughput performance, the Score for "MIX" policy is on average ~1.52X
than baseline.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 71 +++++++++++++++++++++--------
 1 file changed, 51 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 11b921b..d3f087d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8966,6 +8966,8 @@ static netdev_features_t i40e_features_check(struct sk_buff *skb,
 #define NET_POLICY_CPU_TX	250
 #define NET_POLICY_BULK_RX	50
 #define NET_POLICY_BULK_TX	125
+#define NET_POLICY_MIX_BULK_RX	62
+#define NET_POLICY_MIX_BULK_TX	122
 #define NET_POLICY_LATENCY_RX	5
 #define NET_POLICY_LATENCY_TX	10
 
@@ -9004,6 +9006,9 @@ static int i40e_ndo_netpolicy_init(struct net_device *dev,
 			set_bit(i, info->avail_policy);
 	}
 
+	/* support MIX policy */
+	info->has_mix_policy = true;
+
 	return 0;
 }
 
@@ -9046,6 +9051,30 @@ static int i40e_ndo_get_irq_info(struct net_device *dev,
 	return 0;
 }
 
+static int i40e_fill_coalesce_for_policy(struct ethtool_coalesce *ec,
+					 enum netpolicy_name name)
+{
+	if (policy_param[name][NETPOLICY_RX] > 0) {
+		ec->rx_coalesce_usecs = policy_param[name][NETPOLICY_RX];
+		ec->use_adaptive_rx_coalesce = 0;
+	} else if (policy_param[name][NETPOLICY_RX] == 0) {
+		ec->use_adaptive_rx_coalesce = 1;
+	} else {
+		return -EINVAL;
+	}
+
+	if (policy_param[name][NETPOLICY_TX] > 0) {
+		ec->tx_coalesce_usecs = policy_param[name][NETPOLICY_TX];
+		ec->use_adaptive_tx_coalesce = 0;
+	} else if (policy_param[name][NETPOLICY_TX] == 0) {
+		ec->use_adaptive_tx_coalesce = 1;
+	} else {
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 /**
  * i40e_set_net_policy
  * @dev: the net device pointer
@@ -9061,28 +9090,30 @@ static int i40e_set_net_policy(struct net_device *dev,
 	struct i40e_vsi *vsi = np->vsi;
 	struct netpolicy_object *obj;
 	struct ethtool_coalesce ec;
-
-	if (policy_param[name][NETPOLICY_RX] > 0) {
-		ec.rx_coalesce_usecs = policy_param[name][NETPOLICY_RX];
-		ec.use_adaptive_rx_coalesce = 0;
-	} else if (policy_param[name][NETPOLICY_RX] == 0) {
-		ec.use_adaptive_rx_coalesce = 1;
-	} else {
-		return -EINVAL;
-	}
-
-	if (policy_param[name][NETPOLICY_TX] > 0) {
-		ec.tx_coalesce_usecs = policy_param[name][NETPOLICY_TX];
-		ec.use_adaptive_tx_coalesce = 0;
-	} else if (policy_param[name][NETPOLICY_TX] == 0) {
-		ec.use_adaptive_tx_coalesce = 1;
-	} else {
-		return -EINVAL;
-	}
+	int i, ret;
 
 	/*For i40e driver, tx and rx are always in pair */
-	list_for_each_entry(obj, &dev->netpolicy->obj_list[NETPOLICY_RX][name], list) {
-		i40e_set_itr_per_queue(vsi, &ec, obj->queue);
+	if (name == NET_POLICY_MIX) {
+		/* Under MIX policy, the paramers for BULK object are different */
+		policy_param[NET_POLICY_BULK][NETPOLICY_RX] = NET_POLICY_MIX_BULK_RX;
+		policy_param[NET_POLICY_BULK][NETPOLICY_TX] = NET_POLICY_MIX_BULK_TX;
+		for (i = NET_POLICY_NONE; i < NET_POLICY_MAX; i++) {
+			ret = i40e_fill_coalesce_for_policy(&ec, i);
+			if (ret)
+				return ret;
+			list_for_each_entry(obj, &dev->netpolicy->obj_list[NETPOLICY_RX][i], list) {
+				i40e_set_itr_per_queue(vsi, &ec, obj->queue);
+			}
+		}
+	} else {
+		policy_param[NET_POLICY_BULK][NETPOLICY_RX] = NET_POLICY_BULK_RX;
+		policy_param[NET_POLICY_BULK][NETPOLICY_TX] = NET_POLICY_BULK_TX;
+		ret = i40e_fill_coalesce_for_policy(&ec, name);
+		if (ret)
+			return ret;
+		list_for_each_entry(obj, &dev->netpolicy->obj_list[NETPOLICY_RX][name], list) {
+			i40e_set_itr_per_queue(vsi, &ec, obj->queue);
+		}
 	}
 
 	return 0;
-- 
2.5.5
