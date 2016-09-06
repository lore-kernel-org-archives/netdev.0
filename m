From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v4 5/6] net: core: run cgroup eBPF egress programs
Date: Tue,  6 Sep 2016 15:46:07 +0200
Message-ID: <1473169568-30525-6-git-send-email-daniel@zonque.org>
References: <1473169568-30525-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, cgroups@vger.kernel.org,
        Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:38350 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756160AbcIFNqV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 09:46:21 -0400
In-Reply-To: <1473169568-30525-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the cgroup associated with the receiving socket has an eBPF
programs installed, run them from __dev_queue_xmit().

eBPF programs used in this context are expected to either return 1 to
let the packet pass, or != 1 to drop them. The programs have access to
the full skb, including the MAC headers.

Note that cgroup_bpf_run_filter() is stubbed out as static inline nop
for !CONFIG_CGROUP_BPF, and is otherwise guarded by a static key if
the feature is unused.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 net/core/dev.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 34b5322..eb2bd20 100644
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
@@ -3414,8 +3419,8 @@ recursion_alert:
 
 	rc = -ENETDOWN;
 	rcu_read_unlock_bh();
-
 	atomic_long_inc(&dev->tx_dropped);
+free_skb_list:
 	kfree_skb_list(skb);
 	return rc;
 out:
-- 
2.5.5
