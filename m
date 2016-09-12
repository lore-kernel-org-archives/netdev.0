From: kan.liang@intel.com
Subject: [RFC V3 PATCH 07/26] net/netpolicy: enable and disable NET policy
Date: Mon, 12 Sep 2016 07:55:40 -0700
Message-ID: <1473692159-4017-8-git-send-email-kan.liang@intel.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
        peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        akpm@linux-foundation.org, keescook@chromium.org,
        viro@zeniv.linux.org.uk, gorcunov@openvz.org,
        john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
        decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
        xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
        stephen@networkplumber.org, alexei.starovoitov@gmail.com,
        jesse.brandeburg@intel.com, andi@firstfloor.org,
        Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

This patch introduces functions to enable and disable NET policy.

For enabling, it collects device and CPU information and setup CPU/queue
mapping. Also, for some drivers like i40e driver, it will get better
performance if setting IRQ affinity. This patch provides an option
irq_affinity for driver to set IRQ affinity in NET policy enabling.

For disabling, it removes the IRQ affinity (if set) and mapping
information.

np_lock should protect the enable and disable state. It will be done
later in this series.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h |  1 +
 net/core/netpolicy.c      | 41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index a946b75c..bfab7b8 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -49,6 +49,7 @@ struct netpolicy_sys_info {
 struct netpolicy_info {
 	enum netpolicy_name	cur_policy;
 	unsigned long avail_policy[BITS_TO_LONGS(NET_POLICY_MAX)];
+	bool irq_affinity;
 	/* cpu and queue mapping information */
 	struct netpolicy_sys_info	sys_info;
 };
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index adcb5e3..a6e240f 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -162,6 +162,47 @@ static void netpolicy_set_affinity(struct net_device *dev)
 	}
 }
 
+static int netpolicy_disable(struct net_device *dev)
+{
+	if (dev->netpolicy->irq_affinity)
+		netpolicy_clear_affinity(dev);
+	netpolicy_free_sys_map(dev);
+
+	return 0;
+}
+
+static int netpolicy_enable(struct net_device *dev)
+{
+	int ret;
+	struct netpolicy_dev_info d_info;
+	u32 cpu;
+
+	if (WARN_ON(!dev->netpolicy))
+		return -EINVAL;
+
+	/* get driver information */
+	ret = netpolicy_get_dev_info(dev, &d_info);
+	if (ret)
+		return ret;
+
+	/* get cpu information */
+	cpu = netpolicy_get_cpu_information();
+
+	/* create sys map */
+	ret = netpolicy_update_sys_map(dev, &d_info, cpu);
+	if (ret) {
+		netpolicy_free_dev_info(&d_info);
+		return ret;
+	}
+
+	/* set irq affinity */
+	if (dev->netpolicy->irq_affinity)
+		netpolicy_set_affinity(dev);
+
+	netpolicy_free_dev_info(&d_info);
+	return 0;
+}
+
 const char *policy_name[NET_POLICY_MAX] = {
 	"NONE"
 };
-- 
2.5.5
