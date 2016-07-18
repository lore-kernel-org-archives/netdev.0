From: kan.liang@intel.com
Subject: [RFC PATCH 08/30] net/netpolicy: set and remove irq affinity
Date: Sun, 17 Jul 2016 23:56:02 -0700
Message-ID: <1468824984-65318-9-git-send-email-kan.liang@intel.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18624 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844AbcGROXV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 10:23:21 -0400
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patches introduces functions to set and remove irq affinity
according to cpu and queue mapping.
The functions will not record the previous affinity status. After a
set/remove cycles, it will set the affinity on all online cpu with irq
balance enabling.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 net/core/netpolicy.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index ff7fc04..c44818d 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -29,6 +29,7 @@
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/init.h>
+#include <linux/irq.h>
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <linux/uaccess.h>
@@ -128,6 +129,38 @@ err:
 	return -ENOMEM;
 }
 
+static void netpolicy_clear_affinity(struct net_device *dev)
+{
+	struct netpolicy_sys_info *s_info = &dev->netpolicy->sys_info;
+	u32 i;
+
+	for (i = 0; i < s_info->avail_rx_num; i++) {
+		irq_clear_status_flags(s_info->rx[i].irq, IRQ_NO_BALANCING);
+		irq_set_affinity_hint(s_info->rx[i].irq, cpu_online_mask);
+	}
+
+	for (i = 0; i < s_info->avail_tx_num; i++) {
+		irq_clear_status_flags(s_info->tx[i].irq, IRQ_NO_BALANCING);
+		irq_set_affinity_hint(s_info->tx[i].irq, cpu_online_mask);
+	}
+}
+
+static void netpolicy_set_affinity(struct net_device *dev)
+{
+	struct netpolicy_sys_info *s_info = &dev->netpolicy->sys_info;
+	u32 i;
+
+	for (i = 0; i < s_info->avail_rx_num; i++) {
+		irq_set_status_flags(s_info->rx[i].irq, IRQ_NO_BALANCING);
+		irq_set_affinity_hint(s_info->rx[i].irq, cpumask_of(s_info->rx[i].cpu));
+	}
+
+	for (i = 0; i < s_info->avail_tx_num; i++) {
+		irq_set_status_flags(s_info->tx[i].irq, IRQ_NO_BALANCING);
+		irq_set_affinity_hint(s_info->tx[i].irq, cpumask_of(s_info->tx[i].cpu));
+	}
+}
+
 const char *policy_name[NET_POLICY_MAX] = {
 	"NONE"
 };
-- 
2.5.5
