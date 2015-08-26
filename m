From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH RFC V2 2/2] net: Optimize snmp stat aggregation by walking all the percpu data at once
Date: Wed, 26 Aug 2015 23:07:33 +0530
Message-ID: <1440610653-14210-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: <y>
 <1440610653-14210-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Cc: <jiri@resnulli.us>, <edumazet@google.com>,
	<hannes@stressinduktion.org>, <tom@herbertland.com>,
	<azhou@nicira.com>, <ebiederm@xmission.com>,
	<ipm@chirality.org.uk>, <nicolas.dichtel@6wind.com>,
	<serge.hallyn@canonical.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<raghavendra.kt@linux.vnet.ibm.com>, <anton@au1.ibm.com>,
	<nacc@linux.vnet.ibm.com>, <srikar@linux.vnet.ibm.com>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440610653-14210-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Docker container creation linearly increased from around 1.6 sec to 7.5 sec
(at 1000 containers) and perf data showed 50% ovehead in snmp_fold_field.

reason: currently __snmp6_fill_stats64 calls snmp_fold_field that walks
through per cpu data of an item (iteratively for around 90 items).

idea: This patch tries to aggregate the statistics by going through
all the items of each cpu sequentially which is reducing cache
misses.

Docker creation got faster by more than 2x after the patch.

Result:
                       Before           After
Docker creation time   6.836s           3.357s
cache miss             2.7%             1.38%

perf before:
    50.73%  docker           [kernel.kallsyms]       [k] snmp_fold_field
     9.07%  swapper          [kernel.kallsyms]       [k] snooze_loop
     3.49%  docker           [kernel.kallsyms]       [k] veth_stats_one
     2.85%  swapper          [kernel.kallsyms]       [k] _raw_spin_lock

perf after:
    10.56%  swapper          [kernel.kallsyms]     [k] snooze_loop
     8.72%  docker           [kernel.kallsyms]     [k] snmp_get_cpu_field
     7.59%  docker           [kernel.kallsyms]     [k] veth_stats_one
     3.65%  swapper          [kernel.kallsyms]     [k] _raw_spin_lock

Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 net/ipv6/addrconf.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

 Change in V2:
 - Allocate stat calculation buffer in stack (Eric)

Thanks David and Eric for coments on V1 and as both of them pointed,
unfortunately we cannot get rid of buffer for calculation without avoiding
unaligned op.

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 21c2c81..0f6c7a5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4624,16 +4624,22 @@ static inline void __snmp6_fill_statsdev(u64 *stats, atomic_long_t *mib,
 }
 
 static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
-				      int items, int bytes, size_t syncpoff)
+					int items, int bytes, size_t syncpoff,
+					u64 *buff)
 {
-	int i;
+	int i, c;
 	int pad = bytes - sizeof(u64) * items;
 	BUG_ON(pad < 0);
 
 	/* Use put_unaligned() because stats may not be aligned for u64. */
 	put_unaligned(items, &stats[0]);
+
+	for_each_possible_cpu(c)
+		for (i = 1; i < items; i++)
+			buff[i] += snmp_get_cpu_field64(mib, c, i, syncpoff);
+
 	for (i = 1; i < items; i++)
-		put_unaligned(snmp_fold_field64(mib, i, syncpoff), &stats[i]);
+		put_unaligned(buff[i], &stats[i]);
 
 	memset(&stats[items], 0, pad);
 }
@@ -4641,10 +4647,12 @@ static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
 static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
 			     int bytes)
 {
+	u64 buff[IPSTATS_MIB_MAX] = {0,};
+
 	switch (attrtype) {
 	case IFLA_INET6_STATS:
-		__snmp6_fill_stats64(stats, idev->stats.ipv6,
-				     IPSTATS_MIB_MAX, bytes, offsetof(struct ipstats_mib, syncp));
+		__snmp6_fill_stats64(stats, idev->stats.ipv6, IPSTATS_MIB_MAX, bytes,
+				     offsetof(struct ipstats_mib, syncp), buff);
 		break;
 	case IFLA_INET6_ICMP6STATS:
 		__snmp6_fill_statsdev(stats, idev->stats.icmpv6dev->mibs, ICMP6_MIB_MAX, bytes);
-- 
1.7.11.7
