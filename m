From: kan.liang@intel.com
Subject: [RFC PATCH 18/30] net/netpolicy: handle channel changes
Date: Sun, 17 Jul 2016 23:56:12 -0700
Message-ID: <1468824984-65318-19-git-send-email-kan.liang@intel.com>
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

User can uses ethtool to set the channel number. This patch handles the
channel changes by rebuilding the object list.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h | 8 ++++++++
 net/core/ethtool.c        | 8 +++++++-
 net/core/netpolicy.c      | 1 +
 3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index 579ff98..cc75e3c 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -79,4 +79,12 @@ struct netpolicy_info {
 	struct list_head		obj_list[NETPOLICY_RXTX][NET_POLICY_MAX];
 };
 
+#ifdef CONFIG_NETPOLICY
+extern void update_netpolicy_sys_map(void);
+#else
+static inline void update_netpolicy_sys_map(void)
+{
+}
+#endif
+
 #endif /*__LINUX_NETPOLICY_H*/
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 9774898..e1f8bd0 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1703,6 +1703,7 @@ static noinline_for_stack int ethtool_set_channels(struct net_device *dev,
 {
 	struct ethtool_channels channels, max;
 	u32 max_rx_in_use = 0;
+	int ret;
 
 	if (!dev->ethtool_ops->set_channels || !dev->ethtool_ops->get_channels)
 		return -EOPNOTSUPP;
@@ -1726,7 +1727,12 @@ static noinline_for_stack int ethtool_set_channels(struct net_device *dev,
 	    (channels.combined_count + channels.rx_count) <= max_rx_in_use)
 	    return -EINVAL;
 
-	return dev->ethtool_ops->set_channels(dev, &channels);
+	ret = dev->ethtool_ops->set_channels(dev, &channels);
+#ifdef CONFIG_NETPOLICY
+	if (!ret)
+		update_netpolicy_sys_map();
+#endif
+	return ret;
 }
 
 static int ethtool_get_pauseparam(struct net_device *dev, void __user *useraddr)
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 46af407..da7d9f1 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -887,6 +887,7 @@ unlock:
 		}
 	}
 }
+EXPORT_SYMBOL(update_netpolicy_sys_map);
 
 static int netpolicy_cpu_callback(struct notifier_block *nfb,
 				  unsigned long action, void *hcpu)
-- 
2.5.5
