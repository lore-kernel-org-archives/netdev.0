From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH RFC V4 2/2] net: Optimize snmp stat aggregation by walking all the percpu data at once
Date: Sun, 30 Aug 2015 11:29:42 +0530
Message-ID: <1440914382-23126-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: <y>
 <1440914382-23126-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Cc: <jiri@resnulli.us>, <edumazet@google.com>,
	<hannes@stressinduktion.org>, <tom@herbertland.com>,
	<azhou@nicira.com>, <ebiederm@xmission.com>,
	<ipm@chirality.org.uk>, <nicolas.dichtel@6wind.com>,
	<serge.hallyn@canonical.com>, <joe@perches.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<raghavendra.kt@linux.vnet.ibm.com>, <anton@au1.ibm.com>,
	<nacc@linux.vnet.ibm.com>, <srikar@linux.vnet.ibm.com>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e17.ny.us.ibm.com ([129.33.205.207]:45304 "EHLO
	e17.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbbH3F6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 01:58:12 -0400
Received: from /spool/local
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Sun, 30 Aug 2015 01:58:11 -0400
In-Reply-To: <1440914382-23126-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Docker container creation linearly increased from around 1.6 sec to 7.5 sec
(at 1000 containers) and perf data showed 50% ovehead in snmp_fold_field.

reason: currently __snmp6_fill_stats64 calls snmp_fold_field that walks
through per cpu data of an item (iteratively for around 36 items).

idea: This patch tries to aggregate the statistics by going through
all the items of each cpu sequentially which is reducing cache
misses.

Docker creation got faster by more than 2x after the patch.

Result:
                       Before           After
Docker creation time   6.836s           3.25s
cache miss             2.7%             1.41%

perf before:
    50.73%  docker           [kernel.kallsyms]       [k] snmp_fold_field
     9.07%  swapper          [kernel.kallsyms]       [k] snooze_loop
     3.49%  docker           [kernel.kallsyms]       [k] veth_stats_one
     2.85%  swapper          [kernel.kallsyms]       [k] _raw_spin_lock

perf after:
    10.57%  docker           docker                [.] scanblock
     8.37%  swapper          [kernel.kallsyms]     [k] snooze_loop
     6.91%  docker           [kernel.kallsyms]     [k] snmp_get_cpu_field
     6.67%  docker           [kernel.kallsyms]     [k] veth_stats_one

changes/ideas suggested:
Using buffer in stack (Eric), Usage of memset (David), Using memcpy in
place of unaligned_put (Joe).

Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 net/ipv6/addrconf.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

Changes in V4:
 - remove 'item' variable and use IPSTATS_MIB_MAX to avoid sparse
   warning (Eric) also remove 'item' parameter (Joe)
 - add missing memset of padding.

Changes in V3:
 - use memset to initialize temp buffer in leaf function. (David)
 - use memcpy to copy the buffer data to stat instead of unalign_pu (Joe)
 - Move buffer definition to leaf function __snmp6_fill_stats64() (Eric)
 -
Changes in V2:
 - Allocate the stat calculation buffer in stack. (Eric)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 21c2c81..4abc10c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4624,18 +4624,24 @@ static inline void __snmp6_fill_statsdev(u64 *stats, atomic_long_t *mib,
 }
 
 static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
-				      int items, int bytes, size_t syncpoff)
+					int bytes, size_t syncpoff)
 {
-	int i;
-	int pad = bytes - sizeof(u64) * items;
+	int i, c;
+	u64 buff[IPSTATS_MIB_MAX];
+	int pad = bytes - sizeof(u64) * IPSTATS_MIB_MAX;
+
 	BUG_ON(pad < 0);
 
-	/* Use put_unaligned() because stats may not be aligned for u64. */
-	put_unaligned(items, &stats[0]);
-	for (i = 1; i < items; i++)
-		put_unaligned(snmp_fold_field64(mib, i, syncpoff), &stats[i]);
+	memset(buff, 0, sizeof(buff));
+	buff[0] = IPSTATS_MIB_MAX;
 
-	memset(&stats[items], 0, pad);
+	for_each_possible_cpu(c) {
+		for (i = 1; i < IPSTATS_MIB_MAX; i++)
+			buff[i] += snmp_get_cpu_field64(mib, c, i, syncpoff);
+	}
+
+	memcpy(stats, buff, IPSTATS_MIB_MAX * sizeof(u64));
+	memset(&stats[IPSTATS_MIB_MAX], 0, pad);
 }
 
 static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
@@ -4643,8 +4649,8 @@ static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
 {
 	switch (attrtype) {
 	case IFLA_INET6_STATS:
-		__snmp6_fill_stats64(stats, idev->stats.ipv6,
-				     IPSTATS_MIB_MAX, bytes, offsetof(struct ipstats_mib, syncp));
+		__snmp6_fill_stats64(stats, idev->stats.ipv6, bytes,
+				     offsetof(struct ipstats_mib, syncp));
 		break;
 	case IFLA_INET6_ICMP6STATS:
 		__snmp6_fill_statsdev(stats, idev->stats.icmpv6dev->mibs, ICMP6_MIB_MAX, bytes);
-- 
1.7.11.7
