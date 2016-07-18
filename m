From: kan.liang@intel.com
Subject: [RFC PATCH 07/30] net/netpolicy: create CPU and queue mapping
Date: Sun, 17 Jul 2016 23:56:01 -0700
Message-ID: <1468824984-65318-8-git-send-email-kan.liang@intel.com>
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

Current implementation forces CPU and queue 1:1 mapping. This patch
introduces the function netpolicy_update_sys_map to create this mapping.
The result is stored in netpolicy_sys_info.
If the CPU count and queue count are different, the remaining
CPUs/queues are not used.
CPU hotplug, device hotplug or ethtool may change the CPU count or
queue count. For these cases, this function can also be called to
reconstruct the mapping. These cases will be handled later in this
series.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h | 18 ++++++++++++
 net/core/netpolicy.c      | 74 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 92 insertions(+)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index fc87d9b..a946b75c 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -30,9 +30,27 @@ struct netpolicy_dev_info {
 	u32	*tx_irq;
 };
 
+struct netpolicy_sys_map {
+	u32	cpu;
+	u32	queue;
+	u32	irq;
+};
+
+struct netpolicy_sys_info {
+	/*
+	 * Record the cpu and queue 1:1 mapping
+	 */
+	u32				avail_rx_num;
+	struct netpolicy_sys_map	*rx;
+	u32				avail_tx_num;
+	struct netpolicy_sys_map	*tx;
+};
+
 struct netpolicy_info {
 	enum netpolicy_name	cur_policy;
 	unsigned long avail_policy[BITS_TO_LONGS(NET_POLICY_MAX)];
+	/* cpu and queue mapping information */
+	struct netpolicy_sys_info	sys_info;
 };
 
 #endif /*__LINUX_NETPOLICY_H*/
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 075aaca..ff7fc04 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -54,6 +54,80 @@ static u32 netpolicy_get_cpu_information(void)
 	return num_online_cpus();
 }
 
+static void netpolicy_free_sys_map(struct net_device *dev)
+{
+	struct netpolicy_sys_info *s_info = &dev->netpolicy->sys_info;
+
+	kfree(s_info->rx);
+	s_info->rx = NULL;
+	s_info->avail_rx_num = 0;
+	kfree(s_info->tx);
+	s_info->tx = NULL;
+	s_info->avail_tx_num = 0;
+}
+
+static int netpolicy_update_sys_map(struct net_device *dev,
+				    struct netpolicy_dev_info *d_info,
+				    u32 cpu)
+{
+	struct netpolicy_sys_info *s_info = &dev->netpolicy->sys_info;
+	u32 num, i, online_cpu;
+	cpumask_var_t cpumask;
+
+	if (!alloc_cpumask_var(&cpumask, GFP_ATOMIC))
+		return -ENOMEM;
+
+	/* update rx cpu map */
+	if (cpu > d_info->rx_num)
+		num = d_info->rx_num;
+	else
+		num = cpu;
+
+	s_info->avail_rx_num = num;
+	s_info->rx = kcalloc(num, sizeof(*s_info->rx), GFP_ATOMIC);
+	if (!s_info->rx)
+		goto err;
+	cpumask_copy(cpumask, cpu_online_mask);
+
+	i = 0;
+	for_each_cpu(online_cpu, cpumask) {
+		if (i == num)
+			break;
+		s_info->rx[i].cpu = online_cpu;
+		s_info->rx[i].queue = i;
+		s_info->rx[i].irq = d_info->rx_irq[i];
+		i++;
+	}
+
+	/* update tx cpu map */
+	if (cpu >= d_info->tx_num)
+		num = d_info->tx_num;
+	else
+		num = cpu;
+
+	s_info->avail_tx_num = num;
+	s_info->tx = kcalloc(num, sizeof(*s_info->tx), GFP_ATOMIC);
+	if (!s_info->tx)
+		goto err;
+
+	i = 0;
+	for_each_cpu(online_cpu, cpumask) {
+		if (i == num)
+			break;
+		s_info->tx[i].cpu = online_cpu;
+		s_info->tx[i].queue = i;
+		s_info->tx[i].irq = d_info->tx_irq[i];
+		i++;
+	}
+
+	free_cpumask_var(cpumask);
+	return 0;
+err:
+	netpolicy_free_sys_map(dev);
+	free_cpumask_var(cpumask);
+	return -ENOMEM;
+}
+
 const char *policy_name[NET_POLICY_MAX] = {
 	"NONE"
 };
-- 
2.5.5
