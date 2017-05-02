From: David Miller <davem@davemloft.net>
Subject: [PATCH] selftests: bpf: Use bpf_endian.h in test_xdp.c
Date: Tue, 02 May 2017 10:54:13 -0400 (EDT)
Message-ID: <20170502.105413.1648914947505904393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49422 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751181AbdEBOyP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 10:54:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This fixes the testcase on big-endian.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-next, I almost have test_progs working fully
on sparc with a small verifier hack...

 tools/testing/selftests/bpf/test_xdp.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_xdp.c b/tools/testing/selftests/bpf/test_xdp.c
index 9a33b03..5e7df8b 100644
--- a/tools/testing/selftests/bpf/test_xdp.c
+++ b/tools/testing/selftests/bpf/test_xdp.c
@@ -17,10 +17,9 @@
 #include <linux/pkt_cls.h>
 #include <sys/socket.h>
 #include "bpf_helpers.h"
+#include "bpf_endian.h"
 #include "test_iptunnel_common.h"
 
-#define htons __builtin_bswap16
-#define ntohs __builtin_bswap16
 int _version SEC("version") = 1;
 
 struct bpf_map_def SEC("maps") rxcnt = {
@@ -104,7 +103,7 @@ static __always_inline int handle_ipv4(struct xdp_md *xdp)
 	vip.family = AF_INET;
 	vip.daddr.v4 = iph->daddr;
 	vip.dport = dport;
-	payload_len = ntohs(iph->tot_len);
+	payload_len = bpf_ntohs(iph->tot_len);
 
 	tnl = bpf_map_lookup_elem(&vip2tnl, &vip);
 	/* It only does v4-in-v4 */
@@ -126,7 +125,7 @@ static __always_inline int handle_ipv4(struct xdp_md *xdp)
 	    iph + 1 > data_end)
 		return XDP_DROP;
 
-	set_ethhdr(new_eth, old_eth, tnl, htons(ETH_P_IP));
+	set_ethhdr(new_eth, old_eth, tnl, bpf_htons(ETH_P_IP));
 
 	iph->version = 4;
 	iph->ihl = sizeof(*iph) >> 2;
@@ -134,7 +133,7 @@ static __always_inline int handle_ipv4(struct xdp_md *xdp)
 	iph->protocol = IPPROTO_IPIP;
 	iph->check = 0;
 	iph->tos = 0;
-	iph->tot_len = htons(payload_len + sizeof(*iph));
+	iph->tot_len = bpf_htons(payload_len + sizeof(*iph));
 	iph->daddr = tnl->daddr.v4;
 	iph->saddr = tnl->saddr.v4;
 	iph->ttl = 8;
@@ -195,12 +194,12 @@ static __always_inline int handle_ipv6(struct xdp_md *xdp)
 	    ip6h + 1 > data_end)
 		return XDP_DROP;
 
-	set_ethhdr(new_eth, old_eth, tnl, htons(ETH_P_IPV6));
+	set_ethhdr(new_eth, old_eth, tnl, bpf_htons(ETH_P_IPV6));
 
 	ip6h->version = 6;
 	ip6h->priority = 0;
 	memset(ip6h->flow_lbl, 0, sizeof(ip6h->flow_lbl));
-	ip6h->payload_len = htons(ntohs(payload_len) + sizeof(*ip6h));
+	ip6h->payload_len = bpf_htons(bpf_ntohs(payload_len) + sizeof(*ip6h));
 	ip6h->nexthdr = IPPROTO_IPV6;
 	ip6h->hop_limit = 8;
 	memcpy(ip6h->saddr.s6_addr32, tnl->saddr.v6, sizeof(tnl->saddr.v6));
@@ -224,9 +223,9 @@ int _xdp_tx_iptunnel(struct xdp_md *xdp)
 
 	h_proto = eth->h_proto;
 
-	if (h_proto == htons(ETH_P_IP))
+	if (h_proto == bpf_htons(ETH_P_IP))
 		return handle_ipv4(xdp);
-	else if (h_proto == htons(ETH_P_IPV6))
+	else if (h_proto == bpf_htons(ETH_P_IPV6))
 
 		return handle_ipv6(xdp);
 	else
-- 
2.1.2.532.g19b5d50
