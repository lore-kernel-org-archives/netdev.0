From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/5] bpf: fix _htons occurences in test_progs
Date: Thu, 27 Apr 2017 01:39:34 +0200
Message-ID: <5d70b8413026c1184d70bfa625f769345f1caf24.1493249192.git.daniel@iogearbox.net>
References: <cover.1493249192.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57407 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754576AbdDZXk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:40:57 -0400
In-Reply-To: <cover.1493249192.git.daniel@iogearbox.net>
In-Reply-To: <cover.1493249192.git.daniel@iogearbox.net>
References: <cover.1493249192.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave reported that on sparc test_progs generates buggy swapped
eth->h_proto protocol comparisons:

  10: (15) if r3 == 0xdd86 goto pc+9
   R0=imm2,min_value=2,max_value=2 R1=pkt(id=0,off=0,r=14) R2=pkt_end R3=inv
   R4=pkt(id=0,off=14,r=14) R5=inv56 R10=fp

This is due to the unconditional ...

  #define htons __builtin_bswap16
  #define ntohs __builtin_bswap16

... in test_progs that causes this. Make use of asm/byteorder.h
and use __constant_htons() where possible and only perform the
bswap16 when on little endian in non-constant case.

Fixes: 6882804c916b ("selftests/bpf: add a test for overlapping packet range checks")
Fixes: 37821613626e ("selftests/bpf: add l4 load balancer test based on sched_cls")
Reported-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/bpf_util.h        | 19 +++++++++++++++++++
 tools/testing/selftests/bpf/test_l4lb.c       | 11 +++++------
 tools/testing/selftests/bpf/test_pkt_access.c |  6 +++---
 tools/testing/selftests/bpf/test_progs.c      | 10 ++++------
 4 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/tools/testing/selftests/bpf/bpf_util.h b/tools/testing/selftests/bpf/bpf_util.h
index 84a5d18..7de2796 100644
--- a/tools/testing/selftests/bpf/bpf_util.h
+++ b/tools/testing/selftests/bpf/bpf_util.h
@@ -6,6 +6,25 @@
 #include <string.h>
 #include <errno.h>
 
+#include <asm/byteorder.h>
+
+#if __BYTE_ORDER == __LITTLE_ENDIAN
+# define __bpf_ntohs(x)		__builtin_bswap16(x)
+# define __bpf_htons(x)		__builtin_bswap16(x)
+#elif __BYTE_ORDER == __BIG_ENDIAN
+# define __bpf_ntohs(x)		(x)
+# define __bpf_htons(x)		(x)
+#else
+# error "Fix your __BYTE_ORDER?!"
+#endif
+
+#define bpf_htons(x)				\
+	(__builtin_constant_p(x) ?		\
+	 __constant_htons(x) : __bpf_htons(x))
+#define bpf_ntohs(x)				\
+	(__builtin_constant_p(x) ?		\
+	 __constant_ntohs(x) : __bpf_ntohs(x))
+
 static inline unsigned int bpf_num_possible_cpus(void)
 {
 	static const char *fcpu = "/sys/devices/system/cpu/possible";
diff --git a/tools/testing/selftests/bpf/test_l4lb.c b/tools/testing/selftests/bpf/test_l4lb.c
index 368bfe8..b68b212 100644
--- a/tools/testing/selftests/bpf/test_l4lb.c
+++ b/tools/testing/selftests/bpf/test_l4lb.c
@@ -19,9 +19,8 @@
 #include <linux/udp.h>
 #include "bpf_helpers.h"
 #include "test_iptunnel_common.h"
+#include "bpf_util.h"
 
-#define htons __builtin_bswap16
-#define ntohs __builtin_bswap16
 int _version SEC("version") = 1;
 
 static inline __u32 rol32(__u32 word, unsigned int shift)
@@ -355,7 +354,7 @@ static __always_inline int process_packet(void *data, __u64 off, void *data_end,
 		iph_len = sizeof(struct ipv6hdr);
 		protocol = ip6h->nexthdr;
 		pckt.proto = protocol;
-		pkt_bytes = ntohs(ip6h->payload_len);
+		pkt_bytes = bpf_ntohs(ip6h->payload_len);
 		off += iph_len;
 		if (protocol == IPPROTO_FRAGMENT) {
 			return TC_ACT_SHOT;
@@ -377,7 +376,7 @@ static __always_inline int process_packet(void *data, __u64 off, void *data_end,
 
 		protocol = iph->protocol;
 		pckt.proto = protocol;
-		pkt_bytes = ntohs(iph->tot_len);
+		pkt_bytes = bpf_ntohs(iph->tot_len);
 		off += IPV4_HDR_LEN_NO_OPT;
 
 		if (iph->frag_off & PCKT_FRAGMENTED)
@@ -464,9 +463,9 @@ int balancer_ingress(struct __sk_buff *ctx)
 	if (data + nh_off > data_end)
 		return TC_ACT_SHOT;
 	eth_proto = eth->eth_proto;
-	if (eth_proto == htons(ETH_P_IP))
+	if (eth_proto == bpf_htons(ETH_P_IP))
 		return process_packet(data, nh_off, data_end, false, ctx);
-	else if (eth_proto == htons(ETH_P_IPV6))
+	else if (eth_proto == bpf_htons(ETH_P_IPV6))
 		return process_packet(data, nh_off, data_end, true, ctx);
 	else
 		return TC_ACT_SHOT;
diff --git a/tools/testing/selftests/bpf/test_pkt_access.c b/tools/testing/selftests/bpf/test_pkt_access.c
index fd1e083..7113005 100644
--- a/tools/testing/selftests/bpf/test_pkt_access.c
+++ b/tools/testing/selftests/bpf/test_pkt_access.c
@@ -14,8 +14,8 @@
 #include <linux/tcp.h>
 #include <linux/pkt_cls.h>
 #include "bpf_helpers.h"
+#include "bpf_util.h"
 
-#define _htons __builtin_bswap16
 #define barrier() __asm__ __volatile__("": : :"memory")
 int _version SEC("version") = 1;
 
@@ -32,7 +32,7 @@ int process(struct __sk_buff *skb)
 	if (eth + 1 > data_end)
 		return TC_ACT_SHOT;
 
-	if (eth->h_proto == _htons(ETH_P_IP)) {
+	if (eth->h_proto == bpf_htons(ETH_P_IP)) {
 		struct iphdr *iph = (struct iphdr *)(eth + 1);
 
 		if (iph + 1 > data_end)
@@ -40,7 +40,7 @@ int process(struct __sk_buff *skb)
 		ihl_len = iph->ihl * 4;
 		proto = iph->protocol;
 		tcp = (struct tcphdr *)((void *)(iph) + ihl_len);
-	} else if (eth->h_proto == _htons(ETH_P_IPV6)) {
+	} else if (eth->h_proto == bpf_htons(ETH_P_IPV6)) {
 		struct ipv6hdr *ip6h = (struct ipv6hdr *)(eth + 1);
 
 		if (ip6h + 1 > data_end)
diff --git a/tools/testing/selftests/bpf/test_progs.c b/tools/testing/selftests/bpf/test_progs.c
index 5275d4a..7c2d899 100644
--- a/tools/testing/selftests/bpf/test_progs.c
+++ b/tools/testing/selftests/bpf/test_progs.c
@@ -30,8 +30,6 @@
 #include "test_iptunnel_common.h"
 #include "bpf_util.h"
 
-#define _htons __builtin_bswap16
-
 static int error_cnt, pass_cnt;
 
 #define MAGIC_BYTES 123
@@ -42,10 +40,10 @@
 	struct iphdr iph;
 	struct tcphdr tcp;
 } __packed pkt_v4 = {
-	.eth.h_proto = _htons(ETH_P_IP),
+	.eth.h_proto = bpf_htons(ETH_P_IP),
 	.iph.ihl = 5,
 	.iph.protocol = 6,
-	.iph.tot_len = _htons(MAGIC_BYTES),
+	.iph.tot_len = bpf_htons(MAGIC_BYTES),
 	.tcp.urg_ptr = 123,
 };
 
@@ -55,9 +53,9 @@
 	struct ipv6hdr iph;
 	struct tcphdr tcp;
 } __packed pkt_v6 = {
-	.eth.h_proto = _htons(ETH_P_IPV6),
+	.eth.h_proto = bpf_htons(ETH_P_IPV6),
 	.iph.nexthdr = 6,
-	.iph.payload_len = _htons(MAGIC_BYTES),
+	.iph.payload_len = bpf_htons(MAGIC_BYTES),
 	.tcp.urg_ptr = 123,
 };
 
-- 
1.9.3
