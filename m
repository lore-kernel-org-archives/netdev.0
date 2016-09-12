From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v5 5/6] net: core: run cgroup eBPF egress programs
Date: Mon, 12 Sep 2016 18:12:14 +0200
Message-ID: <1473696735-11269-6-git-send-email-daniel@zonque.org>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
To: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1473696735-11269-1-git-send-email-daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If the cgroup associated with the receiving socket has an eBPF
programs installed, run them from __dev_queue_xmit().

eBPF programs used in this context are expected to either return 1 to
let the packet pass, or != 1 to drop them. The programs have access to
the full skb, including the MAC headers.

Note that cgroup_bpf_run_filter() is stubbed out as static inline nop
for !CONFIG_CGROUP_BPF, and is otherwise guarded by a static key if
the feature is unused.

Signed-off-by: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
---
 net/core/dev.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 34b5322..f951db2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -141,6 +141,7 @@
 #include <linux/netfilter_ingress.h>
 #include <linux/sctp.h>
 #include <linux/crash_dump.h>
+#include <linux/bpf-cgroup.h>
 
 #include "net-sysfs.h"
 
@@ -3329,6 +3330,10 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_SCHED_TSTAMP))
 		__skb_tstamp_tx(skb, NULL, skb->sk, SCM_TSTAMP_SCHED);
 
+	rc = cgroup_bpf_run_filter(skb->sk, skb, BPF_CGROUP_INET_EGRESS);
+	if (rc)
+		goto free_skb_list;
+
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
@@ -3416,6 +3421,7 @@ recursion_alert:
 	rcu_read_unlock_bh();
 
 	atomic_long_inc(&dev->tx_dropped);
+free_skb_list:
 	kfree_skb_list(skb);
 	return rc;
 out:
-- 
2.5.5
