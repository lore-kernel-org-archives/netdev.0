From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH 1/2] bpf samples: fix compiler errors with sockex2 and sockex3
Date: Sat, 24 Sep 2016 02:10:04 +0530
Message-ID: <7b29fba6073924dc4c9e7d639eefb0b15a98660d.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: "Michael Ellerman" <mpe@ellerman.id.au>,
        "Alexei Starovoitov" <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "Ananth N Mavinakayanahalli" <ananth@in.ibm.com>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These samples fail to compile as 'struct flow_keys' conflicts with
definition in net/flow_dissector.h. Fix the same by renaming the
structure used in the sample.

Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 samples/bpf/sockex2_kern.c | 10 +++++-----
 samples/bpf/sockex3_kern.c |  8 ++++----
 samples/bpf/sockex3_user.c |  4 ++--
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/samples/bpf/sockex2_kern.c b/samples/bpf/sockex2_kern.c
index ba0e177..44e5846 100644
--- a/samples/bpf/sockex2_kern.c
+++ b/samples/bpf/sockex2_kern.c
@@ -14,7 +14,7 @@ struct vlan_hdr {
 	__be16 h_vlan_encapsulated_proto;
 };
 
-struct flow_keys {
+struct bpf_flow_keys {
 	__be32 src;
 	__be32 dst;
 	union {
@@ -59,7 +59,7 @@ static inline __u32 ipv6_addr_hash(struct __sk_buff *ctx, __u64 off)
 }
 
 static inline __u64 parse_ip(struct __sk_buff *skb, __u64 nhoff, __u64 *ip_proto,
-			     struct flow_keys *flow)
+			     struct bpf_flow_keys *flow)
 {
 	__u64 verlen;
 
@@ -83,7 +83,7 @@ static inline __u64 parse_ip(struct __sk_buff *skb, __u64 nhoff, __u64 *ip_proto
 }
 
 static inline __u64 parse_ipv6(struct __sk_buff *skb, __u64 nhoff, __u64 *ip_proto,
-			       struct flow_keys *flow)
+			       struct bpf_flow_keys *flow)
 {
 	*ip_proto = load_byte(skb,
 			      nhoff + offsetof(struct ipv6hdr, nexthdr));
@@ -96,7 +96,7 @@ static inline __u64 parse_ipv6(struct __sk_buff *skb, __u64 nhoff, __u64 *ip_pro
 	return nhoff;
 }
 
-static inline bool flow_dissector(struct __sk_buff *skb, struct flow_keys *flow)
+static inline bool flow_dissector(struct __sk_buff *skb, struct bpf_flow_keys *flow)
 {
 	__u64 nhoff = ETH_HLEN;
 	__u64 ip_proto;
@@ -198,7 +198,7 @@ struct bpf_map_def SEC("maps") hash_map = {
 SEC("socket2")
 int bpf_prog2(struct __sk_buff *skb)
 {
-	struct flow_keys flow;
+	struct bpf_flow_keys flow;
 	struct pair *value;
 	u32 key;
 
diff --git a/samples/bpf/sockex3_kern.c b/samples/bpf/sockex3_kern.c
index 41ae2fd..95907f8 100644
--- a/samples/bpf/sockex3_kern.c
+++ b/samples/bpf/sockex3_kern.c
@@ -61,7 +61,7 @@ struct vlan_hdr {
 	__be16 h_vlan_encapsulated_proto;
 };
 
-struct flow_keys {
+struct bpf_flow_keys {
 	__be32 src;
 	__be32 dst;
 	union {
@@ -88,7 +88,7 @@ static inline __u32 ipv6_addr_hash(struct __sk_buff *ctx, __u64 off)
 }
 
 struct globals {
-	struct flow_keys flow;
+	struct bpf_flow_keys flow;
 };
 
 struct bpf_map_def SEC("maps") percpu_map = {
@@ -114,14 +114,14 @@ struct pair {
 
 struct bpf_map_def SEC("maps") hash_map = {
 	.type = BPF_MAP_TYPE_HASH,
-	.key_size = sizeof(struct flow_keys),
+	.key_size = sizeof(struct bpf_flow_keys),
 	.value_size = sizeof(struct pair),
 	.max_entries = 1024,
 };
 
 static void update_stats(struct __sk_buff *skb, struct globals *g)
 {
-	struct flow_keys key = g->flow;
+	struct bpf_flow_keys key = g->flow;
 	struct pair *value;
 
 	value = bpf_map_lookup_elem(&hash_map, &key);
diff --git a/samples/bpf/sockex3_user.c b/samples/bpf/sockex3_user.c
index d4184ab..3fcfd8c4 100644
--- a/samples/bpf/sockex3_user.c
+++ b/samples/bpf/sockex3_user.c
@@ -7,7 +7,7 @@
 #include <arpa/inet.h>
 #include <sys/resource.h>
 
-struct flow_keys {
+struct bpf_flow_keys {
 	__be32 src;
 	__be32 dst;
 	union {
@@ -49,7 +49,7 @@ int main(int argc, char **argv)
 	(void) f;
 
 	for (i = 0; i < 5; i++) {
-		struct flow_keys key = {}, next_key;
+		struct bpf_flow_keys key = {}, next_key;
 		struct pair value;
 
 		sleep(1);
-- 
2.9.3
