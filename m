From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next] examples: bpf: fix ld offs to have same prog loaded on ingress/egress
Date: Mon, 20 Apr 2015 13:48:54 +0200
Message-ID: <02fed6731d00ae1af3936c58e363a4e2d1df13e5.1429528359.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34854 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734AbbDTLtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 07:49:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix up the eBPF example program to match our kernel fix in a166151cbe33 ("bpf:
fix bpf helpers to use skb->mac_header relative offsets"). Tested on ingress
and egress paths.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 ( Stephen, this applies on top of "tc: built-in eBPF exec proxy":
   https://patchwork.ozlabs.org/patch/461837/ )

 examples/bpf/bpf_prog.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/examples/bpf/bpf_prog.c b/examples/bpf/bpf_prog.c
index 4dc00c3..009febd 100644
--- a/examples/bpf/bpf_prog.c
+++ b/examples/bpf/bpf_prog.c
@@ -58,6 +58,12 @@
  *    random type none pass val 0
  *    index 38 ref 1 bind 1
  *
+ * The same program can also be installed on ingress side (as opposed to above
+ * egress configuration), e.g.:
+ *
+ * # tc qdisc add dev em1 handle ffff: ingress
+ * # tc filter add dev em1 parent ffff: bpf obj ...
+ *
  * Notes on BPF agent:
  *
  * In the above example, the bpf_agent creates the unix domain socket
@@ -157,6 +163,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/if_tunnel.h>
+#include <linux/filter.h>
 #include <linux/bpf.h>
 
 /* Common, shared definitions with ebpf_agent.c. */
@@ -222,7 +229,7 @@ struct flow_keys {
 		__u32 ports;
 		__u16 port16[2];
 	};
-	__u16 th_off;
+	__s32 th_off;
 	__u8 ip_proto;
 };
 
@@ -242,14 +249,14 @@ static inline int flow_ports_offset(__u8 ip_proto)
 	}
 }
 
-static inline bool flow_is_frag(struct __sk_buff *skb, __u32 nh_off)
+static inline bool flow_is_frag(struct __sk_buff *skb, int nh_off)
 {
 	return !!(load_half(skb, nh_off + offsetof(struct iphdr, frag_off)) &
 		  (IP_MF | IP_OFFSET));
 }
 
-static inline __u32 flow_parse_ipv4(struct __sk_buff *skb, __u32 nh_off,
-				    __u8 *ip_proto, struct flow_keys *flow)
+static inline int flow_parse_ipv4(struct __sk_buff *skb, int nh_off,
+				  __u8 *ip_proto, struct flow_keys *flow)
 {
 	__u8 ip_ver_len;
 
@@ -272,18 +279,18 @@ static inline __u32 flow_parse_ipv4(struct __sk_buff *skb, __u32 nh_off,
 	return nh_off;
 }
 
-static inline __u32 flow_addr_hash_ipv6(struct __sk_buff *skb, __u32 off)
+static inline __u32 flow_addr_hash_ipv6(struct __sk_buff *skb, int off)
 {
 	__u32 w0 = load_word(skb, off);
 	__u32 w1 = load_word(skb, off + sizeof(w0));
 	__u32 w2 = load_word(skb, off + sizeof(w0) * 2);
 	__u32 w3 = load_word(skb, off + sizeof(w0) * 3);
 
-	return (__u32)(w0 ^ w1 ^ w2 ^ w3);
+	return w0 ^ w1 ^ w2 ^ w3;
 }
 
-static inline __u32 flow_parse_ipv6(struct __sk_buff *skb, __u32 nh_off,
-				    __u8 *ip_proto, struct flow_keys *flow)
+static inline int flow_parse_ipv6(struct __sk_buff *skb, int nh_off,
+				  __u8 *ip_proto, struct flow_keys *flow)
 {
 	*ip_proto = load_byte(skb, nh_off + offsetof(struct ipv6hdr, nexthdr));
 
@@ -296,10 +303,9 @@ static inline __u32 flow_parse_ipv6(struct __sk_buff *skb, __u32 nh_off,
 static inline bool flow_dissector(struct __sk_buff *skb,
 				  struct flow_keys *flow)
 {
+	int poff, nh_off = BPF_LL_OFF + ETH_HLEN;
 	__be16 proto = skb->protocol;
-	__u32 nh_off = ETH_HLEN;
 	__u8 ip_proto;
-	int poff;
 
 	/* TODO: check for skb->vlan_tci, skb->vlan_proto first */
 	if (proto == htons(ETH_P_8021AD)) {
@@ -369,7 +375,7 @@ static inline bool flow_dissector(struct __sk_buff *skb,
 	nh_off += flow_ports_offset(ip_proto);
 
 	flow->ports = load_word(skb, nh_off);
-	flow->th_off = (__u16)nh_off;
+	flow->th_off = nh_off;
 	flow->ip_proto = ip_proto;
 
 	return true;
-- 
1.9.3
