From: kan.liang@intel.com
Subject: [RFC V3 PATCH 06/26] net/netpolicy: set and remove IRQ affinity
Date: Mon, 12 Sep 2016 07:55:39 -0700
Message-ID: <1473692159-4017-7-git-send-email-kan.liang@intel.com>
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

This patches introduces functions to set and remove IRQ affinity
according to cpu and queue mapping.

The functions will not record the previous affinity status. After a
set/remove cycles, it will set the affinity on all online CPU with IRQ
balance enabling.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 net/core/netpolicy.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 0972341..adcb5e3 100644
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
@@ -129,6 +130,38 @@ err:
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
