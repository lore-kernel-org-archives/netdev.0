From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 4/4] samples/bpf: bpf_tail_call example for networking
Date: Tue, 19 May 2015 16:59:06 -0700
Message-ID: <1432079946-9878-5-git-send-email-ast@plumgrid.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Zi Shen Lim <zlim.lnx@gmail.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432079946-9878-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Usage:
$ sudo ./sockex3
IP     src.port -> dst.port               bytes      packets
127.0.0.1.42010 -> 127.0.0.1.12865         1568            8
127.0.0.1.59526 -> 127.0.0.1.33778     11422636       173070
127.0.0.1.33778 -> 127.0.0.1.59526  11260224828       341974
127.0.0.1.12865 -> 127.0.0.1.42010         1832           12
IP     src.port -> dst.port               bytes      packets
127.0.0.1.42010 -> 127.0.0.1.12865         1568            8
127.0.0.1.59526 -> 127.0.0.1.33778     23198092       351486
127.0.0.1.33778 -> 127.0.0.1.59526  22972698518       698616
127.0.0.1.12865 -> 127.0.0.1.42010         1832           12

this example is similar to sockex2 in a way that it accumulates per-flow
statistics, but it does packet parsing differently.
sockex2 inlines full packet parser routine into single bpf program.
This sockex3 example have 4 independent programs that parse vlan, mpls, ip, ipv6
and one main program that starts the process.
bpf_tail_call() mechanism allows each program to be small and be called
on demand potentially multiple times, so that many vlan, mpls, ip in ip,
gre encapsulations can be parsed. These and other protocol parsers can
be added or removed at runtime. TLVs can be parsed in similar manner.
Note, tail_call_cnt dynamic check limits the number of tail calls to 32.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile       |    4 +
 samples/bpf/bpf_helpers.h  |    2 +
 samples/bpf/sockex3_kern.c |  303 ++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/sockex3_user.c |   66 ++++++++++
 4 files changed, 375 insertions(+)
 create mode 100644 samples/bpf/sockex3_kern.c
 create mode 100644 samples/bpf/sockex3_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index ded10d05617e..46c6a8cf74d3 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -6,6 +6,7 @@ hostprogs-y := test_verifier test_maps
 hostprogs-y += sock_example
 hostprogs-y += sockex1
 hostprogs-y += sockex2
+hostprogs-y += sockex3
 hostprogs-y += tracex1
 hostprogs-y += tracex2
 hostprogs-y += tracex3
@@ -17,6 +18,7 @@ test_maps-objs := test_maps.o libbpf.o
 sock_example-objs := sock_example.o libbpf.o
 sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
 sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
+sockex3-objs := bpf_load.o libbpf.o sockex3_user.o
 tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
 tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
 tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
@@ -27,6 +29,7 @@ tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
 always := $(hostprogs-y)
 always += sockex1_kern.o
 always += sockex2_kern.o
+always += sockex3_kern.o
 always += tracex1_kern.o
 always += tracex2_kern.o
 always += tracex3_kern.o
@@ -39,6 +42,7 @@ HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
 HOSTLOADLIBES_sockex1 += -lelf
 HOSTLOADLIBES_sockex2 += -lelf
+HOSTLOADLIBES_sockex3 += -lelf
 HOSTLOADLIBES_tracex1 += -lelf
 HOSTLOADLIBES_tracex2 += -lelf
 HOSTLOADLIBES_tracex3 += -lelf
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 699ed8dbdd64..f531a0b3282d 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -23,6 +23,8 @@ static int (*bpf_trace_printk)(const char *fmt, int fmt_size, ...) =
 	(void *) BPF_FUNC_trace_printk;
 static void (*bpf_tail_call)(void *ctx, void *map, int index) =
 	(void *) BPF_FUNC_tail_call;
+static unsigned long long (*bpf_get_smp_processor_id)(void) =
+	(void *) BPF_FUNC_get_smp_processor_id;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/sockex3_kern.c b/samples/bpf/sockex3_kern.c
new file mode 100644
index 000000000000..f1576341daa6
--- /dev/null
+++ b/samples/bpf/sockex3_kern.c
@@ -0,0 +1,303 @@
+/* Copyright (c) 2015 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+#include <uapi/linux/in.h>
+#include <uapi/linux/if.h>
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/ip.h>
+#include <uapi/linux/ipv6.h>
+#include <uapi/linux/if_tunnel.h>
+#include <uapi/linux/mpls.h>
+#define IP_MF		0x2000
+#define IP_OFFSET	0x1FFF
+
+#define PROG(F) SEC("socket/"__stringify(F)) int bpf_func_##F
+
+struct bpf_map_def SEC("maps") jmp_table = {
+	.type = BPF_MAP_TYPE_PROG_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(u32),
+	.max_entries = 8,
+};
+
+#define PARSE_VLAN 1
+#define PARSE_MPLS 2
+#define PARSE_IP 3
+#define PARSE_IPV6 4
+
+/* protocol dispatch routine.
+ * It tail-calls next BPF program depending on eth proto
+ * Note, we could have used:
+ * bpf_tail_call(skb, &jmp_table, proto);
+ * but it would need large prog_array
+ */
+static inline void parse_eth_proto(struct __sk_buff *skb, u32 proto)
+{
+	switch (proto) {
+	case ETH_P_8021Q:
+	case ETH_P_8021AD:
+		bpf_tail_call(skb, &jmp_table, PARSE_VLAN);
+		break;
+	case ETH_P_MPLS_UC:
+	case ETH_P_MPLS_MC:
+		bpf_tail_call(skb, &jmp_table, PARSE_MPLS);
+		break;
+	case ETH_P_IP:
+		bpf_tail_call(skb, &jmp_table, PARSE_IP);
+		break;
+	case ETH_P_IPV6:
+		bpf_tail_call(skb, &jmp_table, PARSE_IPV6);
+		break;
+	}
+}
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
+	__u32 ip_proto;
+};
+
+static inline int ip_is_fragment(struct __sk_buff *ctx, __u64 nhoff)
+{
+	return load_half(ctx, nhoff + offsetof(struct iphdr, frag_off))
+		& (IP_MF | IP_OFFSET);
+}
+
+static inline __u32 ipv6_addr_hash(struct __sk_buff *ctx, __u64 off)
+{
+	__u64 w0 = load_word(ctx, off);
+	__u64 w1 = load_word(ctx, off + 4);
+	__u64 w2 = load_word(ctx, off + 8);
+	__u64 w3 = load_word(ctx, off + 12);
+
+	return (__u32)(w0 ^ w1 ^ w2 ^ w3);
+}
+
+struct globals {
+	struct flow_keys flow;
+	__u32 nhoff;
+};
+
+struct bpf_map_def SEC("maps") percpu_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(__u32),
+	.value_size = sizeof(struct globals),
+	.max_entries = 32,
+};
+
+/* user poor man's per_cpu until native support is ready */
+static struct globals *this_cpu_globals(void)
+{
+	u32 key = bpf_get_smp_processor_id();
+
+	return bpf_map_lookup_elem(&percpu_map, &key);
+}
+
+/* some simple stats for user space consumption */
+struct pair {
+	__u64 packets;
+	__u64 bytes;
+};
+
+struct bpf_map_def SEC("maps") hash_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(struct flow_keys),
+	.value_size = sizeof(struct pair),
+	.max_entries = 1024,
+};
+
+static void update_stats(struct __sk_buff *skb, struct globals *g)
+{
+	struct flow_keys key = g->flow;
+	struct pair *value;
+
+	value = bpf_map_lookup_elem(&hash_map, &key);
+	if (value) {
+		__sync_fetch_and_add(&value->packets, 1);
+		__sync_fetch_and_add(&value->bytes, skb->len);
+	} else {
+		struct pair val = {1, skb->len};
+
+		bpf_map_update_elem(&hash_map, &key, &val, BPF_ANY);
+	}
+}
+
+static __always_inline void parse_ip_proto(struct __sk_buff *skb,
+					   struct globals *g, __u32 ip_proto)
+{
+	__u32 nhoff = g->nhoff;
+	int poff;
+
+	switch (ip_proto) {
+	case IPPROTO_GRE: {
+		struct gre_hdr {
+			__be16 flags;
+			__be16 proto;
+		};
+
+		__u32 gre_flags = load_half(skb,
+					    nhoff + offsetof(struct gre_hdr, flags));
+		__u32 gre_proto = load_half(skb,
+					    nhoff + offsetof(struct gre_hdr, proto));
+
+		if (gre_flags & (GRE_VERSION|GRE_ROUTING))
+			break;
+
+		nhoff += 4;
+		if (gre_flags & GRE_CSUM)
+			nhoff += 4;
+		if (gre_flags & GRE_KEY)
+			nhoff += 4;
+		if (gre_flags & GRE_SEQ)
+			nhoff += 4;
+
+		g->nhoff = nhoff;
+		parse_eth_proto(skb, gre_proto);
+		break;
+	}
+	case IPPROTO_IPIP:
+		parse_eth_proto(skb, ETH_P_IP);
+		break;
+	case IPPROTO_IPV6:
+		parse_eth_proto(skb, ETH_P_IPV6);
+		break;
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+		g->flow.ports = load_word(skb, nhoff);
+	case IPPROTO_ICMP:
+		g->flow.ip_proto = ip_proto;
+		update_stats(skb, g);
+		break;
+	default:
+		break;
+	}
+}
+
+PROG(PARSE_IP)(struct __sk_buff *skb)
+{
+	struct globals *g = this_cpu_globals();
+	__u32 nhoff, verlen, ip_proto;
+
+	if (!g)
+		return 0;
+
+	nhoff = g->nhoff;
+
+	if (unlikely(ip_is_fragment(skb, nhoff)))
+		return 0;
+
+	ip_proto = load_byte(skb, nhoff + offsetof(struct iphdr, protocol));
+
+	if (ip_proto != IPPROTO_GRE) {
+		g->flow.src = load_word(skb, nhoff + offsetof(struct iphdr, saddr));
+		g->flow.dst = load_word(skb, nhoff + offsetof(struct iphdr, daddr));
+	}
+
+	verlen = load_byte(skb, nhoff + 0/*offsetof(struct iphdr, ihl)*/);
+	nhoff += (verlen & 0xF) << 2;
+
+	g->nhoff = nhoff;
+	parse_ip_proto(skb, g, ip_proto);
+	return 0;
+}
+
+PROG(PARSE_IPV6)(struct __sk_buff *skb)
+{
+	struct globals *g = this_cpu_globals();
+	__u32 nhoff, ip_proto;
+	
+	if (!g)
+		return 0;
+
+	nhoff = g->nhoff;
+
+	ip_proto = load_byte(skb,
+			     nhoff + offsetof(struct ipv6hdr, nexthdr));
+	g->flow.src = ipv6_addr_hash(skb,
+				     nhoff + offsetof(struct ipv6hdr, saddr));
+	g->flow.dst = ipv6_addr_hash(skb,
+				     nhoff + offsetof(struct ipv6hdr, daddr));
+	nhoff += sizeof(struct ipv6hdr);
+
+	g->nhoff = nhoff;
+	parse_ip_proto(skb, g, ip_proto);
+	return 0;
+}
+
+PROG(PARSE_VLAN)(struct __sk_buff *skb)
+{
+	struct globals *g = this_cpu_globals();
+	__u32 nhoff, proto;
+	
+	if (!g)
+		return 0;
+
+	nhoff = g->nhoff;
+
+	proto = load_half(skb, nhoff + offsetof(struct vlan_hdr,
+						h_vlan_encapsulated_proto));
+	nhoff += sizeof(struct vlan_hdr);
+	g->nhoff = nhoff;
+
+	parse_eth_proto(skb, proto);
+
+	return 0;
+}
+
+PROG(PARSE_MPLS)(struct __sk_buff *skb)
+{
+	struct globals *g = this_cpu_globals();
+	__u32 nhoff, label;
+	
+	if (!g)
+		return 0;
+
+	nhoff = g->nhoff;
+
+	label = load_word(skb, nhoff);
+	nhoff += sizeof(struct mpls_label);
+	g->nhoff = nhoff;
+
+	if (label & MPLS_LS_S_MASK) {
+		__u8 verlen = load_byte(skb, nhoff);
+		if ((verlen & 0xF0) == 4)
+			parse_eth_proto(skb, ETH_P_IP);
+		else
+			parse_eth_proto(skb, ETH_P_IPV6);
+	} else {
+		parse_eth_proto(skb, ETH_P_MPLS_UC);
+	}
+
+	return 0;
+}
+
+SEC("socket/0")
+int main_prog(struct __sk_buff *skb)
+{
+	struct globals *g = this_cpu_globals();
+	__u32 nhoff = ETH_HLEN;
+	__u32 proto = load_half(skb, 12);
+	
+	if (!g)
+		return 0;
+
+	g->nhoff = nhoff;
+	parse_eth_proto(skb, proto);
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/sockex3_user.c b/samples/bpf/sockex3_user.c
new file mode 100644
index 000000000000..2617772d060d
--- /dev/null
+++ b/samples/bpf/sockex3_user.c
@@ -0,0 +1,66 @@
+#include <stdio.h>
+#include <assert.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+#include <unistd.h>
+#include <arpa/inet.h>
+
+struct flow_keys {
+	__be32 src;
+	__be32 dst;
+	union {
+		__be32 ports;
+		__be16 port16[2];
+	};
+	__u32 ip_proto;
+};
+
+struct pair {
+	__u64 packets;
+	__u64 bytes;
+};
+
+int main(int argc, char **argv)
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
+	assert(setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, &prog_fd[4],
+			  sizeof(__u32)) == 0);
+
+	if (argc > 1)
+		f = popen("ping -c5 localhost", "r");
+	else
+		f = popen("netperf -l 4 localhost", "r");
+	(void) f;
+
+	for (i = 0; i < 5; i++) {
+		struct flow_keys key = {}, next_key;
+		struct pair value;
+
+		sleep(1);
+		printf("IP     src.port -> dst.port               bytes      packets\n");
+		while (bpf_get_next_key(map_fd[2], &key, &next_key) == 0) {
+			bpf_lookup_elem(map_fd[2], &next_key, &value);
+			printf("%s.%05d -> %s.%05d %12lld %12lld\n",
+			       inet_ntoa((struct in_addr){htonl(next_key.src)}),
+			       next_key.port16[0],
+			       inet_ntoa((struct in_addr){htonl(next_key.dst)}),
+			       next_key.port16[1],
+			       value.bytes, value.packets);
+			key = next_key;
+		}
+	}
+	return 0;
+}
-- 
1.7.9.5
