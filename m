From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] rps: document flow limit in scaling.txt
Date: Wed, 22 May 2013 13:54:40 -0400
Message-ID: <1369245280-9585-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:35098 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259Ab3EVS6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 14:58:12 -0400
Received: by mail-vc0-f202.google.com with SMTP id m17so251067vca.5
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 11:58:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Explain the mechanism and API of the recently merged
rps flow limit patch.

Signed-off-by: Willem de Bruijn <willemb@google.com>

---

Perhaps a bit wordy. I can strip the context and leave only the API
documentation.
---
 Documentation/networking/scaling.txt | 58 ++++++++++++++++++++++++++++++++++++
 1 file changed, 58 insertions(+)

diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
index 579994a..ca6977f 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -163,6 +163,64 @@ and unnecessary. If there are fewer hardware queues than CPUs, then
 RPS might be beneficial if the rps_cpus for each queue are the ones that
 share the same memory domain as the interrupting CPU for that queue.
 
+==== RPS Flow Limit
+
+RPS scales kernel receive processing across CPUs without introducing
+reordering. The trade-off to sending all packets from the same flow
+to the same CPU is CPU load imbalance if flows vary in packet rate.
+In the extreme case a single flow dominates traffic. Especially on
+common server workloads with many concurrent connections, such
+behavior indicates a problem such as a misconfiguration or spoofed
+source Denial of Service attack.
+
+Flow Limit is an optional RPS feature that prioritizes small flows
+during CPU contention by dropping packets from large flows slightly
+ahead of those from small flows. It is active only when an RPS or RFS
+destination CPU approaches saturation.  Once a CPU's input packet
+queue exceeds half the maximum queue length (as set by sysctl
+net.core.netdev_max_backlog), the kernel starts a per-flow packet
+count over the last 256 packets. If a flow exceeds a set ratio (by
+default, half) of these packets when a new packet arrives, then the
+new packet is dropped. Packets from other flows are still only
+dropped once the input packet queue reaches netdev_max_backlog.
+No packets are dropped when the input packet queue length is below
+the threshold, so flow limit does not sever connections outright:
+even large flows maintain connectivity.
+
+== Interface
+
+Flow limit is compiled in by default (CONFIG_NET_FLOW_LIMIT), but not
+turned on. It is implemented for each CPU independently (to avoid lock
+and cache contention) and toggled per CPU by setting the relevant bit
+in sysctl net.core.flow_limit_cpu_bitmap. It exposes the same CPU
+bitmap interface as rps_cpus (see above) when called from procfs:
+
+ /proc/sys/net/core/flow_limit_cpu_bitmap
+
+Per-flow rate is calculated by hashing each packet into a hashtable
+bucket and incrementing a per-bucket counter. The hash function is
+the same that selects a CPU in RPS, but as the number of buckets can
+be much larger than the number of CPUs, flow limit has finer-grained
+identification of large flows and fewer false positives. The default
+table has 4096 buckets. This value can be modified through sysctl
+
+ net.core.flow_limit_table_len
+
+The value is only consulted when a new table is allocated. Modifying
+it does not update active tables.
+
+== Suggested Configuration
+
+Flow limit is useful on systems with many concurrent connections,
+where a single connection taking up 50% of a CPU indicates a problem.
+In such environments, enable the feature on all CPUs that handle
+network rx interrupts (as set in /proc/irq/N/smp_affinity).
+
+The feature depends on the input packet queue length to exceed
+the flow limit threshold (50%) + the flow history length (256).
+Setting net.core.netdev_max_backlog to either 1000 or 10000
+performed well in experiments.
+
 
 RFS: Receive Flow Steering
 ==========================
-- 
1.8.2.1
