From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next v2 2/2] net: ovs: use CRC32 accelerated flow hash if available
Date: Thu, 12 Dec 2013 16:09:06 +0100
Message-ID: <1386860946-1621-3-git-send-email-ffusco@redhat.com>
References: <1386860946-1621-1-git-send-email-ffusco@redhat.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Daniel Borkmann <dborkman@redhat.com>,
	Thomas Graf <tgraf@redhat.com>
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696Ab3LLPJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 10:09:16 -0500
In-Reply-To: <1386860946-1621-1-git-send-email-ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently OVS uses jhash2() for calculating flow hashes in its
internal flow_hash() function. The performance of the flow_hash()
function is critical, as the input data can be hundreds of bytes
long.

OVS is largely deployed in x86_64 based datacenters.  Therefore,
we argue that the performance critical fast path of OVS should
exploit underlying CPU features in order to reduce the per packet
processing costs. We replace jhash2 with the hash implementation
provided by the kernel hash lib, which exploits the crc32l
instruction to achieve high performance

Our patch greatly reduces the hash footprint from ~200 cycles of
jhash2() to around ~90 cycles in case of ovs_flow_hash_crc()
(measured with rdtsc over maximum length flow keys on an i7 Intel
CPU).

Additionally, we wrote a microbenchmark to stress the flow table
performance. The benchmark inserts random flows into the flow
hash and then performs lookups. Our hash deployed on a CRC32
capable CPU reduces the lookup for 1000 flows, 100 masks from
~10,100us to ~6,700us, for example.

Thus, simply use the newly introduced arch_fast_hash2() as a
drop-in replacement.

Signed-off-by: Francesco Fusco <ffusco@redhat.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Thomas Graf <tgraf@redhat.com>
---
 net/openvswitch/flow_table.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index e425427..0e720c3 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -25,7 +25,7 @@
 #include <linux/if_vlan.h>
 #include <net/llc_pdu.h>
 #include <linux/kernel.h>
-#include <linux/jhash.h>
+#include <linux/hash.h>
 #include <linux/jiffies.h>
 #include <linux/llc.h>
 #include <linux/module.h>
@@ -362,7 +362,7 @@ static u32 flow_hash(const struct sw_flow_key *key, int key_start,
 	/* Make sure number of hash bytes are multiple of u32. */
 	BUILD_BUG_ON(sizeof(long) % sizeof(u32));
 
-	return jhash2(hash_key, hash_u32s, 0);
+	return arch_fast_hash2(hash_key, hash_u32s, 0);
 }
 
 static int flow_key_start(const struct sw_flow_key *key)
-- 
1.8.3.1
