From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next] net: ovs: use CRC32 accelerated flow hash if available
Date: Tue, 10 Dec 2013 10:52:58 +0100
Message-ID: <1386669178-14450-1-git-send-email-ffusco@redhat.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Daniel Borkmann <dborkman@redhat.com>,
	Thomas Graf <tgraf@redhat.com>
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47995 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887Ab3LJJxD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 04:53:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently OVS uses jhash2() for calculating flow hashes in its
internal flow_hash() function. The performance of the flow_hash() 
function is critical, as the input data can be hundreds of bytes 
long.

One possible direction to achieve higher performance consists
of replacing jhash2() with an architecture specific hash
function pretty much like the Intel folks have proposed in
DPDK. DPDK provides a very fast hash function that leverages
the 32bit crc32l instruction part of the Intel SSE4.2 
instruction set.

OVS is largely deployed in x86_64 based datacenters.
Therefore, we argue that the performance critical fast path
of OVS should exploit underlying CPU features in order to reduce 
the per packet processing costs.

We adapted and integrated Intel's hashing function from DPDK in
order to be used with OVS internally. Our patch greatly reduces 
the hash footprint from ~200 cycles of jhash2() to around ~90 
cycles in case of ovs_flow_hash_crc() (measured with rdtsc over 
maximum length flow keys on an i7 Intel CPU).

Additionally, we wrote a microbenchmark to stress the flow table 
performance. The benchmark inserts random flows into the flow 
hash and then performs lookups. Our hash deployed on a CRC32 
capable CPU reduces the lookup for 1000 flows, 100 masks from 
~10,100us to ~6,700us, for example.

Signed-off-by: Francesco Fusco <ffusco@redhat.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Thomas Graf <tgraf@redhat.com>
---
 net/openvswitch/flow_table.c | 12 ++++++--
 net/openvswitch/flow_table.h | 66 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 75 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index e425427..262d7ca 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -43,13 +43,16 @@
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/ndisc.h>
-
+#ifdef CONFIG_X86
+#include <asm/cpufeature.h>
+#endif
 #include "datapath.h"
 
 #define TBL_MIN_BUCKETS		1024
 #define REHASH_INTERVAL		(10 * 60 * HZ)
 
 static struct kmem_cache *flow_cache;
+static u32 (*__flow_hash)(const u32 *data, u32 len, u32 seed) = jhash2;
 
 static u16 range_n_bytes(const struct sw_flow_key_range *range)
 {
@@ -362,7 +365,7 @@ static u32 flow_hash(const struct sw_flow_key *key, int key_start,
 	/* Make sure number of hash bytes are multiple of u32. */
 	BUILD_BUG_ON(sizeof(long) % sizeof(u32));
 
-	return jhash2(hash_key, hash_u32s, 0);
+	return __flow_hash(hash_key, hash_u32s, 0);
 }
 
 static int flow_key_start(const struct sw_flow_key *key)
@@ -581,7 +584,10 @@ int ovs_flow_init(void)
 					0, NULL);
 	if (flow_cache == NULL)
 		return -ENOMEM;
-
+#ifdef CONFIG_X86_64
+	if (cpu_has_xmm4_2)
+		__flow_hash = ovs_flow_hash_crc;
+#endif
 	return 0;
 }
 
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index fbe45d5..50cfd1e 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -14,6 +14,37 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
  * 02110-1301, USA
+ *
+ * Some portions derived from code covered by the following notice:
+ *
+ * Copyright (c) 2010-2013 Intel Corporation. All rights reserved.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *   * Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *   * Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in
+ *     the documentation and/or other materials provided with the
+ *     distribution.
+ *   * Neither the name of Intel Corporation nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
 #ifndef FLOW_TABLE_H
@@ -78,4 +109,39 @@ bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
 
 void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
 		       const struct sw_flow_mask *mask);
+
+#ifdef CONFIG_X86_64
+static inline u32 ovs_flow_hash_crc_4b(u32 crc, u32 val)
+{
+	asm ("crc32l %[val], %[crc]\n"
+		: [crc] "+r" (crc)
+		: [val] "rm" (val));
+	return crc;
+}
+
+static inline u32 ovs_flow_hash_crc(const u32 *data, u32 len, u32 seed)
+{
+	const u32 *p32 = (const u32 *) data;
+	u32 i, tmp = 0;
+
+	for (i = 0; i < len; i++)
+		seed = ovs_flow_hash_crc_4b(*p32++, seed);
+
+	switch (3 - ((len * 4) & 0x03)) {
+	case 0:
+		tmp |= *((const u8 *) p32 + 2) << 16;
+		/* Fallthrough */
+	case 1:
+		tmp |= *((const u8 *) p32 + 1) << 8;
+		/* Fallthrough */
+	case 2:
+		tmp |= *((const u8 *) p32);
+		seed = ovs_flow_hash_crc_4b(tmp, seed);
+	default:
+		break;
+	}
+
+	return seed;
+}
+#endif
 #endif /* flow_table.h */
-- 
1.8.3.1
