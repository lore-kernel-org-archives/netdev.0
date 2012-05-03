From: Deng-Cheng Zhu <dczhu@mips.com>
Subject: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Thu, 3 May 2012 16:56:52 +0800
Message-ID: <1336035412-2161-1-git-send-email-dczhu@mips.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <dczhu@mips.com>
To: <davem@davemloft.net>, <therbert@google.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns0.mips.com ([12.201.5.70]:46094 "EHLO dns0.mips.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754740Ab2ECI5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 04:57:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deng-Cheng Zhu <dczhu@mips.com>

Currently, choosing target CPU to process the incoming packet is based on
skb->rxhash. In the case of sparse connections, this could lead to
relatively low and inconsistent bandwidth while doing network throughput
tests -- CPU selection in the RPS map is imbalanced. Even with the same
hash value, 2 packets could come from different devices.

This patch introduces a feature that allows some flows to select their CPUs
by looping the RPS CPU maps. Some tests were performed on the MIPS Malta
1004K platform (2 cores, each with 2 VPEs) at 25Mhz with 2 Intel Pro/1000
NICs. The Malta board works as a router between 2 PCs. Using iperf, here
are results:

       | Original Kernel             | Patched Kernel              |
-------|-----------------------------|-----------------------------|-------
       | SUM    SUM    SUM2   SUM3   | SUM    SUM    SUM2   SUM3   | SUM3
       | 1->2   2->1                 | 1->2   2->1                 | Delta
-------|-----------------------------|-----------------------------|-------
1x  1  | 33.70  29.10  62.80  657.40 | 46.70  46.30  93.00  928.80 | 41.28%
    2  | 46.20  29.30  75.50         | 46.80  46.20  93.00         |
    3  | 25.50  17.60  43.10         | 46.70  45.90  92.60         |
    4  | 38.00  29.10  67.10         | 46.80  46.20  93.00         |
    5  | 46.10  17.30  63.40         | 46.80  46.40  93.20         |
    6  | 36.80  29.00  65.80         | 46.60  46.20  92.80         |
    7  | 46.10  28.10  74.20         | 46.70  46.20  92.90         |
    8  | 46.10  27.90  74.00         | 46.70  46.00  92.70         |
    9  | 36.70  27.80  64.50         | 46.80  46.20  93.00         |
    10 | 38.00  29.00  67.00         | 46.60  46.00  92.60         |
-------|-----------------------------|-----------------------------|-------
2x  1  | 30.90  35.60  66.50  674.32 | 47.40  44.60  92.00  902.80 | 33.88%
    2  | 36.80  17.81  54.61         | 46.30  39.20  85.50         |
    3  | 41.10  17.35  58.45         | 47.40  44.70  92.10         |
    4  | 41.10  35.50  76.60         | 47.50  45.20  92.70         |
    5  | 41.20  35.70  76.90         | 47.50  39.00  86.50         |
    6  | 36.70  40.20  76.90         | 47.40  44.90  92.30         |
    7  | 29.40  18.06  47.46         | 46.90  45.20  92.10         |
    8  | 34.50  40.10  74.60         | 47.00  44.80  91.80         |
    9  | 34.00  35.80  69.80         | 46.40  45.00  91.40         |
    10 | 37.00  35.50  72.50         | 47.40  39.00  86.40         |
-------|-----------------------------|-----------------------------|-------
3x  1  | 45.40  36.90  82.30  774.89 | 45.30  46.90  92.20  895.50 | 15.56%
    2  | 44.00  19.12  63.12         | 45.20  46.50  91.70         |
    3  | 36.90  38.20  75.10         | 45.90  40.60  86.50         |
    4  | 39.20  37.30  76.50         | 45.50  40.30  85.80         |
    5  | 43.30  39.43  82.73         | 45.60  46.10  91.70         |
    6  | 42.70  39.55  82.25         | 45.40  46.30  91.70         |
    7  | 41.20  39.56  80.76         | 45.60  46.20  91.80         |
    8  | 44.60  38.00  82.60         | 45.30  40.30  85.60         |
    9  | 35.43  37.30  72.73         | 45.50  40.50  86.00         |
    10 | 39.70  37.10  76.80         | 45.80  46.70  92.50         |
-------|-----------------------------|-----------------------------|-------
4x  1  | 41.07  35.09  76.16  738.34 | 41.79  45.70  87.49  845.24 | 14.48%
    2  | 38.40  34.92  73.32         | 42.30  40.21  82.51         |
    3  | 33.18  34.76  67.94         | 41.95  44.70  86.65         |
    4  | 41.18  34.81  75.99         | 41.44  39.69  81.13         |
    5  | 34.52  34.46  68.98         | 41.07  39.61  80.68         |
    6  | 41.72  34.15  75.87         | 40.76  45.40  86.16         |
    7  | 38.81  39.43  78.24         | 42.40  45.30  87.70         |
    8  | 40.86  38.08  78.94         | 41.58  44.02  85.60         |
    9  | 34.80  38.82  73.62         | 42.20  39.95  82.15         |
    10 | 30.48  38.80  69.28         | 41.37  43.80  85.17         |
-------|-----------------------------|-----------------------------|-------
6x  1  | 35.59  34.10  69.69  706.58 | 37.28  41.59  78.87  772.02 | 9.26%
    2  | 35.53  39.02  74.55         | 39.42  38.47  77.89         |
    3  | 40.74  31.54  72.28         | 37.12  36.17  73.29         |
    4  | 37.64  35.66  73.30         | 39.16  41.60  80.76         |
    5  | 36.87  31.35  68.22         | 39.83  38.03  77.86         |
    6  | 37.65  34.99  72.64         | 39.72  39.56  79.28         |
    7  | 37.05  38.70  75.75         | 35.72  36.13  71.85         |
    8  | 35.56  34.15  69.71         | 38.24  41.17  79.41         |
    9  | 29.18  31.16  60.34         | 39.81  37.39  77.20         |
    10 | 34.09  36.01  70.10         | 39.88  35.73  75.61         |
-------|-----------------------------|-----------------------------|-------
8x  1  | 31.38  36.37  67.75  677.76 | 38.25  37.38  75.63  739.60 | 9.12%
    2  | 35.77  34.04  69.81         | 36.37  41.39  77.76         |
    3  | 32.53  32.83  65.36         | 34.64  34.54  69.18         |
    4  | 29.67  36.76  66.43         | 38.37  37.45  75.82         |
    5  | 33.99  34.77  68.76         | 35.39  36.71  72.10         |
    6  | 32.31  34.05  66.36         | 34.23  37.65  71.88         |
    7  | 33.37  38.29  71.66         | 38.28  35.32  73.60         |
    8  | 30.83  36.18  67.01         | 38.26  37.32  75.58         |
    9  | 34.37  33.14  67.51         | 35.01  37.81  72.82         |
    10 | 32.74  34.37  67.11         | 34.20  41.03  75.23         |
-------|-----------------------------|-----------------------------|-------
12x 1  | 31.22  32.81  64.03  649.48 | 30.47  37.07  67.54  681.10 | 4.87%
    2  | 29.63  34.46  64.09         | 34.98  35.63  70.61         |
    3  | 32.47  28.61  61.08         | 33.09  35.88  68.97         |
    4  | 32.22  31.01  63.23         | 32.89  36.09  68.98         |
    5  | 29.49  35.92  65.41         | 32.92  33.48  66.40         |
    6  | 32.07  34.29  66.36         | 32.56  34.62  67.18         |
    7  | 31.13  35.65  66.78         | 35.22  36.62  71.84         |
    8  | 32.96  37.00  69.96         | 32.53  37.08  69.61         |
    9  | 28.85  32.59  61.44         | 32.67  34.46  67.13         |
    10 | 32.71  34.39  67.10         | 30.94  31.90  62.84         |
-------|-----------------------------|-----------------------------|-------
16x 1  | 29.55  35.64  65.19  634.00 | 30.03  34.37  64.40  643.42 | 1.49%
    2  | 29.13  32.61  61.74         | 30.86  30.66  61.52         |
    3  | 29.87  34.52  64.39         | 29.53  36.59  66.12         |
    4  | 28.16  30.54  58.70         | 29.01  35.66  64.67         |
    5  | 30.04  34.35  64.39         | 30.72  35.18  65.90         |
    6  | 27.45  36.73  64.18         | 30.81  28.83  59.64         |
    7  | 28.34  38.18  66.52         | 30.71  33.56  64.27         |
    8  | 27.11  38.22  65.33         | 32.35  35.85  68.20         |
    9  | 28.53  32.93  61.46         | 31.21  32.35  63.56         |
    10 | 28.77  33.33  62.10         | 30.99  34.15  65.14         |
-------|-----------------------------|-----------------------------|-------
20x 1  | 30.57  36.96  67.53  641.27 | 30.27  34.99  65.26  617.18 | -3.76%
    2  | 26.23  36.64  62.87         | 28.85  32.50  61.35         |
    3  | 28.84  36.58  65.42         | 28.97  33.79  62.76         |
    4  | 30.59  31.27  61.86         | 27.34  32.83  60.17         |
    5  | 27.91  32.32  60.23         | 28.32  32.82  61.14         |
    6  | 28.77  33.32  62.09         | 26.95  33.08  60.03         |
    7  | 29.60  38.10  67.70         | 28.14  35.74  63.88         |
    8  | 29.84  36.38  66.22         | 29.00  30.01  59.01         |
    9  | 28.68  35.84  64.52         | 27.67  31.44  59.11         |
    10 | 28.16  34.67  62.83         | 30.54  33.93  64.47         |
-------|-----------------------------|-----------------------------|-------
24x 1  | 30.89  34.15  65.05  617.21 | 28.75  33.91  62.66  618.79 | 0.26%
    2  | 30.53  34.38  64.91         | 29.39  31.85  61.24         |
    3  | 28.13  35.20  63.33         | 28.36  34.01  62.37         |
    4  | 29.21  30.46  59.67         | 25.12  34.24  59.36         |
    5  | 24.72  35.46  60.18         | 29.38  32.60  61.98         |
    6  | 28.52  27.00  55.52         | 30.23  35.08  65.32         |
    7  | 25.12  35.46  60.57         | 28.44  31.91  60.35         |
    8  | 27.46  35.93  63.39         | 29.10  34.27  63.37         |
    9  | 27.62  32.56  60.18         | 27.85  34.83  62.68         |
    10 | 30.44  33.99  64.42         | 28.61  30.84  59.46         |
-------|-----------------------------|-----------------------------|-------
28x 1  | 28.30  30.15  58.45  613.21 | 26.97  30.28  57.25  592.80 | -3.33%
    2  | 30.78  31.02  61.80         | 28.27  30.33  58.61         |
    3  | 26.76  34.01  60.77         | 27.89  31.18  59.07         |
    4  | 27.18  32.31  59.49         | 29.42  33.19  62.61         |
    5  | 30.44  35.69  66.13         | 25.56  32.96  58.52         |
    6  | 27.70  30.55  58.25         | 27.94  32.19  60.12         |
    7  | 28.60  34.18  62.77         | 25.18  31.26  56.44         |
    8  | 29.40  31.41  60.81         | 28.78  28.71  57.49         |
    9  | 27.11  34.13  61.24         | 28.65  32.48  61.13         |
    10 | 30.07  33.43  63.50         | 25.99  35.59  61.57         |
-------|-----------------------------|-----------------------------|-------
32x 1  | 27.41  29.16  56.58  590.24 | 27.94  30.75  58.69  584.15 | -1.03%
    2  | 26.54  27.85  54.39         | 28.92  34.46  63.37         |
    3  | 26.68  34.18  60.86         | 25.71  31.12  56.83         |
    4  | 27.31  34.72  62.03         | 26.70  31.35  58.04         |
    5  | 28.82  32.89  61.71         | 27.45  33.83  61.28         |
    6  | 25.49  28.59  54.08         | 27.94  32.06  60.00         |
    7  | 25.80  34.75  60.55         | 26.63  33.22  59.85         |
    8  | 24.39  32.44  56.83         | 26.17  32.27  58.43         |
    9  | 29.33  35.19  64.53         | 24.11  26.43  50.54         |
    10 | 28.02  30.66  58.68         | 25.45  31.67  57.11         |

Note:
1. Data unit: Mbits/sec
2. 1x, 2x...32x: N iperf instances were running in parallel.
3. SUM 1->2: PC1 is the iperf client and PC2 is the iperf server. The sum
   of all instances. Bidirectional tests were performed as well.
4. Tested with iptables/NAT + RPS (RPS CPU mask is 0xe for both NICs, which
   means CPU1/2/3 are covered).
5. CONFIG_NR_RPS_MAP_LOOPS == 4 by default.
6. Duration for each test: 100 seconds.
7. The results show that the overhead brought in by this feature is limited
   as the number of connections goes higher.

Reference: http://www.spinics.net/lists/netdev/msg196734.html
Signed-off-by: Deng-Cheng Zhu <dczhu@mips.com>
---
Changes:
v2 - v1:
o Use percpu variables instead of static NR_CPUS array.
o Delete ARCH details -- let user choose optimal masks.
o Move structure definition to header file.

 include/linux/netdevice.h |   12 +++++++++
 net/Kconfig               |   22 ++++++++++++++++
 net/core/dev.c            |   59 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5cbaa20..22ac47d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -589,6 +589,18 @@ static inline void netdev_queue_numa_node_write(struct netdev_queue *q, int node
 }
 
 #ifdef CONFIG_RPS
+#ifdef CONFIG_RPS_SPARSE_FLOW_OPTIMIZATION
+/*
+ * This structure defines a flow that will be active on a given CPU for a
+ * certain period.
+ */
+struct cpu_flow {
+	struct net_device *dev;
+	u32 rxhash;
+	unsigned long ts;
+};
+#endif
+
 /*
  * This structure holds an RPS map which can be of variable length.  The
  * map is an array of CPUs.
diff --git a/net/Kconfig b/net/Kconfig
index e07272d..d5aa682 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -222,6 +222,28 @@ config RPS
 	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
 	default y
 
+config RPS_SPARSE_FLOW_OPTIMIZATION
+	bool "RPS optimizations for sparse flows"
+	depends on RPS
+	default n
+	---help---
+	  This feature will try to map some network flows to consecutive
+	  CPUs in the RPS map. It will bring in some per packet overhead
+	  but should be able to do good to network throughput in the case
+	  of low number of connections while not much affecting other
+	  cases. (e.g. relatively consistent and high bandwidth in single
+	  connection tests).
+
+config NR_RPS_MAP_LOOPS
+	int "Number of loops walking RPS map before hash indexing (1-5)"
+	range 1 5
+	depends on RPS_SPARSE_FLOW_OPTIMIZATION
+	default "4"
+	---help---
+	  It defines how many loops to go through the RPS map while
+	  determing target CPU to process the incoming packet. After that,
+	  the decision will fall back on hash indexing the RPS map.
+
 config RFS_ACCEL
 	boolean
 	depends on RPS && GENERIC_HARDIRQS
diff --git a/net/core/dev.c b/net/core/dev.c
index c25d453..92e292b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2698,6 +2698,61 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	return rflow;
 }
 
+#ifdef CONFIG_RPS_SPARSE_FLOW_OPTIMIZATION
+static DEFINE_PER_CPU(struct cpu_flow [CONFIG_NR_RPS_MAP_LOOPS], cpu_flows);
+static unsigned long hash_active;
+
+#define FLOW_INACTIVE(now, base) (time_after((now), (base) + HZ) || \
+			 unlikely(time_before((now), (base))))
+
+static u16 find_cpu(const struct rps_map *map, const struct sk_buff *skb)
+{
+	struct cpu_flow *flow;
+	u16 cpu;
+	int i, l, do_alloc = 0;
+	unsigned long now = jiffies;
+
+retry:
+	for (l = 0; l < CONFIG_NR_RPS_MAP_LOOPS; l++) {
+		for (i = map->len - 1; i >= 0; i--) {
+			cpu = map->cpus[i];
+			flow = &per_cpu(cpu_flows, cpu)[l];
+
+			if (do_alloc) {
+				if (flow->dev == NULL ||
+				    FLOW_INACTIVE(now, flow->ts)) {
+					flow->dev = skb->dev;
+					flow->rxhash = skb->rxhash;
+					flow->ts = now;
+					return cpu;
+				}
+			} else {
+				/*
+				 * Unlike hash indexing, this avoids packet
+				 * processing imbalance across CPUs.
+				 */
+				if (flow->rxhash == skb->rxhash &&
+				    flow->dev == skb->dev &&
+				    !FLOW_INACTIVE(now, flow->ts)) {
+					flow->ts = now;
+					return cpu;
+				}
+			}
+		}
+	}
+
+	if (FLOW_INACTIVE(now, hash_active) && do_alloc == 0) {
+		do_alloc = 1;
+		goto retry;
+	}
+
+	/* For all other flows */
+	hash_active = now;
+
+	return map->cpus[((u64) skb->rxhash * map->len) >> 32];
+}
+#endif
+
 /*
  * get_rps_cpu is called from netif_receive_skb and returns the target
  * CPU from the RPS map of the receiving queue for a given skb.
@@ -2780,7 +2835,11 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	}
 
 	if (map) {
+#ifdef CONFIG_RPS_SPARSE_FLOW_OPTIMIZATION
+		tcpu = find_cpu(map, skb);
+#else
 		tcpu = map->cpus[((u64) skb->rxhash * map->len) >> 32];
+#endif
 
 		if (cpu_online(tcpu)) {
 			cpu = tcpu;
-- 
1.7.1
