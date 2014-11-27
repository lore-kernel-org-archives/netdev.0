From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 6/6] samples: bpf: large eBPF program in C
Date: Wed, 26 Nov 2014 21:42:31 -0800
Message-ID: <1417066951-1999-7-git-send-email-ast@plumgrid.com>
References: <1417066951-1999-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417066951-1999-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sockex2_kern.c is purposefully large eBPF program in C.
llvm compiles ~200 lines of C code into ~300 eBPF instructions.

It's similar to __skb_flow_dissect() to demonstrate that complex packet parsing
can be done by eBPF.
Then it uses (struct flow_keys)->dst IP address (or hash of ipv6 dst) to keep
stats of number of packets per IP.
User space loads eBPF program, attaches it to loopback interface and prints
dest_ip->#packets stats every second.

Usage:
$sudo samples/bpf/sockex2
ip 127.0.0.1 count 19
ip 127.0.0.1 count 178115
ip 127.0.0.1 count 369437
ip 127.0.0.1 count 559841
ip 127.0.0.1 count 750539

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile       |    4 +
 samples/bpf/sockex2_kern.c |  215 ++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/sockex2_user.c |   44 +++++++++
 3 files changed, 263 insertions(+)
 create mode 100644 samples/bpf/sockex2_kern.c
 create mode 100644 samples/bpf/sockex2_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 770d145186c3..b5b3600dcdf5 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -5,20 +5,24 @@ obj- := dummy.o
 hostprogs-y := test_verifier test_maps
 hostprogs-y += sock_example
 hostprogs-y += sockex1
+hostprogs-y += sockex2
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
 sock_example-objs := sock_example.o libbpf.o
 sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
+sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
 always += sockex1_kern.o
+always += sockex2_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
 HOSTLOADLIBES_sockex1 += -lelf
+HOSTLOADLIBES_sockex2 += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/sockex2_kern.c b/samples/bpf/sockex2_kern.c
new file mode 100644
index 000000000000..6f0135f0f217
--- /dev/null
+++ b/samples/bpf/sockex2_kern.c
@@ -0,0 +1,215 @@
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+#include <uapi/linux/in.h>
+#include <uapi/linux/if.h>
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/ip.h>
+#include <uapi/linux/ipv6.h>
+#include <uapi/linux/if_tunnel.h>
+#define IP_MF		0x2000
+#define IP_OFFSET	0x1FFF
+
+struct vlan_hdr {
+	__be16 h_vlan_TCI;
+	__be16 h_vlan_encapsulated_proto;
+};
+
+struct flow_keys {
+	__be32 src;
+	__be32 dst;
+	union {
+		__be32 ports;
+		__be16 port16[2];
+	};
+	__u16 thoff;
+	__u8 ip_proto;
+};
+
+static inline int proto_ports_offset(__u64 proto)
+{
+	switch (proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+	case IPPROTO_DCCP:
+	case IPPROTO_ESP:
+	case IPPROTO_SCTP:
+	case IPPROTO_UDPLITE:
+		return 0;
+	case IPPROTO_AH:
+		return 4;
+	default:
+		return 0;
+	}
+}
+
+static inline int ip_is_fragment(struct sk_buff *ctx, __u64 nhoff)
+{
+	return load_half(ctx, nhoff + offsetof(struct iphdr, frag_off))
+		& (IP_MF | IP_OFFSET);
+}
+
+static inline __u32 ipv6_addr_hash(struct sk_buff *ctx, __u64 off)
+{
+	__u64 w0 = load_word(ctx, off);
+	__u64 w1 = load_word(ctx, off + 4);
+	__u64 w2 = load_word(ctx, off + 8);
+	__u64 w3 = load_word(ctx, off + 12);
+
+	return (__u32)(w0 ^ w1 ^ w2 ^ w3);
+}
+
+static inline __u64 parse_ip(struct sk_buff *skb, __u64 nhoff, __u64 *ip_proto,
+			     struct flow_keys *flow)
+{
+	__u64 verlen;
+
+	if (unlikely(ip_is_fragment(skb, nhoff)))
+		*ip_proto = 0;
+	else
+		*ip_proto = load_byte(skb, nhoff + offsetof(struct iphdr, protocol));
+
+	if (*ip_proto != IPPROTO_GRE) {
+		flow->src = load_word(skb, nhoff + offsetof(struct iphdr, saddr));
+		flow->dst = load_word(skb, nhoff + offsetof(struct iphdr, daddr));
+	}
+
+	verlen = load_byte(skb, nhoff + 0/*offsetof(struct iphdr, ihl)*/);
+	if (likely(verlen == 0x45))
+		nhoff += 20;
+	else
+		nhoff += (verlen & 0xF) << 2;
+
+	return nhoff;
+}
+
+static inline __u64 parse_ipv6(struct sk_buff *skb, __u64 nhoff, __u64 *ip_proto,
+			       struct flow_keys *flow)
+{
+	*ip_proto = load_byte(skb,
+			      nhoff + offsetof(struct ipv6hdr, nexthdr));
+	flow->src = ipv6_addr_hash(skb,
+				   nhoff + offsetof(struct ipv6hdr, saddr));
+	flow->dst = ipv6_addr_hash(skb,
+				   nhoff + offsetof(struct ipv6hdr, daddr));
+	nhoff += sizeof(struct ipv6hdr);
+
+	return nhoff;
+}
+
+static inline bool flow_dissector(struct sk_buff *skb, struct flow_keys *flow)
+{
+	__u64 nhoff = ETH_HLEN;
+	__u64 ip_proto;
+	__u64 proto = load_half(skb, 12);
+	int poff;
+
+	if (proto == ETH_P_8021AD) {
+		proto = load_half(skb, nhoff + offsetof(struct vlan_hdr,
+							h_vlan_encapsulated_proto));
+		nhoff += sizeof(struct vlan_hdr);
+	}
+
+	if (proto == ETH_P_8021Q) {
+		proto = load_half(skb, nhoff + offsetof(struct vlan_hdr,
+							h_vlan_encapsulated_proto));
+		nhoff += sizeof(struct vlan_hdr);
+	}
+
+	if (likely(proto == ETH_P_IP))
+		nhoff = parse_ip(skb, nhoff, &ip_proto, flow);
+	else if (proto == ETH_P_IPV6)
+		nhoff = parse_ipv6(skb, nhoff, &ip_proto, flow);
+	else
+		return false;
+
+	switch (ip_proto) {
+	case IPPROTO_GRE: {
+		struct gre_hdr {
+			__be16 flags;
+			__be16 proto;
+		};
+
+		__u64 gre_flags = load_half(skb,
+					    nhoff + offsetof(struct gre_hdr, flags));
+		__u64 gre_proto = load_half(skb,
+					    nhoff + offsetof(struct gre_hdr, proto));
+
+		if (gre_flags & (GRE_VERSION|GRE_ROUTING))
+			break;
+
+		proto = gre_proto;
+		nhoff += 4;
+		if (gre_flags & GRE_CSUM)
+			nhoff += 4;
+		if (gre_flags & GRE_KEY)
+			nhoff += 4;
+		if (gre_flags & GRE_SEQ)
+			nhoff += 4;
+
+		if (proto == ETH_P_8021Q) {
+			proto = load_half(skb,
+					  nhoff + offsetof(struct vlan_hdr,
+							   h_vlan_encapsulated_proto));
+			nhoff += sizeof(struct vlan_hdr);
+		}
+
+		if (proto == ETH_P_IP)
+			nhoff = parse_ip(skb, nhoff, &ip_proto, flow);
+		else if (proto == ETH_P_IPV6)
+			nhoff = parse_ipv6(skb, nhoff, &ip_proto, flow);
+		else
+			return false;
+		break;
+	}
+	case IPPROTO_IPIP:
+		nhoff = parse_ip(skb, nhoff, &ip_proto, flow);
+		break;
+	case IPPROTO_IPV6:
+		nhoff = parse_ipv6(skb, nhoff, &ip_proto, flow);
+		break;
+	default:
+		break;
+	}
+
+	flow->ip_proto = ip_proto;
+	poff = proto_ports_offset(ip_proto);
+	if (poff >= 0) {
+		nhoff += poff;
+		flow->ports = load_word(skb, nhoff);
+	}
+
+	flow->thoff = (__u16) nhoff;
+
+	return true;
+}
+
+struct bpf_map_def SEC("maps") hash_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(__be32),
+	.value_size = sizeof(long),
+	.max_entries = 1024,
+};
+
+SEC("socket2")
+int bpf_prog2(struct sk_buff *skb)
+{
+	struct flow_keys flow;
+	long *value;
+	u32 key;
+
+	if (!flow_dissector(skb, &flow))
+		return 0;
+
+	key = flow.dst;
+	value = bpf_map_lookup_elem(&hash_map, &key);
+	if (value) {
+		__sync_fetch_and_add(value, 1);
+	} else {
+		long val = 1;
+
+		bpf_map_update_elem(&hash_map, &key, &val, BPF_ANY);
+	}
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/sockex2_user.c b/samples/bpf/sockex2_user.c
new file mode 100644
index 000000000000..d2d5f5a790d3
--- /dev/null
+++ b/samples/bpf/sockex2_user.c
@@ -0,0 +1,44 @@
+#include <stdio.h>
+#include <assert.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+#include <unistd.h>
+#include <arpa/inet.h>
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+	FILE *f;
+	int i, sock;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	sock = open_raw_sock("lo");
+
+	assert(setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, prog_fd,
+			  sizeof(prog_fd[0])) == 0);
+
+	f = popen("ping -c5 localhost", "r");
+	(void) f;
+
+	for (i = 0; i < 5; i++) {
+		int key = 0, next_key;
+		long long value;
+
+		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
+			bpf_lookup_elem(map_fd[0], &next_key, &value);
+			printf("ip %s count %lld\n",
+			       inet_ntoa((struct in_addr){htonl(next_key)}),
+			       value);
+			key = next_key;
+		}
+		sleep(1);
+	}
+	return 0;
+}
-- 
1.7.9.5
