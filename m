From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 6/6] selftests/bpf: add l4 load balancer test based on sched_cls
Date: Thu, 30 Mar 2017 18:31:57 -0700
Message-ID: <20170331013157.3298003-7-ast@fb.com>
References: <20170331013157.3298003-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:40242 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934769AbdCaBcC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 21:32:02 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2V1U91i005259
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 18:32:01 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29h9vy0nr1-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 18:32:01 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 d56cb9cc15b111e7b02f24be0593f280-72ef79a0 for <netdev@vger.kernel.org>;        Thu,
 30 Mar 2017 18:31:59 -0700
In-Reply-To: <20170331013157.3298003-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this l4lb demo is a comprehensive test case for LLVM codegen and
kernel verifier. It's using fully inlined jhash(), complex packet
parsing and multiple map lookups of different types to stress
llvm and verifier.
The map sizes, map population and test vectors are artificial to
exercise different paths through the bpf program.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 tools/testing/selftests/bpf/Makefile     |   2 +-
 tools/testing/selftests/bpf/test_l4lb.c  | 474 +++++++++++++++++++++++++++++++
 tools/testing/selftests/bpf/test_progs.c |  88 ++++++
 3 files changed, 563 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/bpf/test_l4lb.c

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index e4acc5b38f43..207e91c5780b 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -6,7 +6,7 @@ LDLIBS += -lcap -lelf
 
 TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test_progs
 
-TEST_GEN_FILES = test_pkt_access.o test_xdp.o
+TEST_GEN_FILES = test_pkt_access.o test_xdp.o test_l4lb.o
 
 TEST_PROGS := test_kmod.sh
 
diff --git a/tools/testing/selftests/bpf/test_l4lb.c b/tools/testing/selftests/bpf/test_l4lb.c
new file mode 100644
index 000000000000..368bfe8b9842
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_l4lb.c
@@ -0,0 +1,474 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stddef.h>
+#include <stdbool.h>
+#include <string.h>
+#include <linux/pkt_cls.h>
+#include <linux/bpf.h>
+#include <linux/in.h>
+#include <linux/if_ether.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/icmp.h>
+#include <linux/icmpv6.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include "bpf_helpers.h"
+#include "test_iptunnel_common.h"
+
+#define htons __builtin_bswap16
+#define ntohs __builtin_bswap16
+int _version SEC("version") = 1;
+
+static inline __u32 rol32(__u32 word, unsigned int shift)
+{
+	return (word << shift) | (word >> ((-shift) & 31));
+}
+
+/* copy paste of jhash from kernel sources to make sure llvm
+ * can compile it into valid sequence of bpf instructions
+ */
+#define __jhash_mix(a, b, c)			\
+{						\
+	a -= c;  a ^= rol32(c, 4);  c += b;	\
+	b -= a;  b ^= rol32(a, 6);  a += c;	\
+	c -= b;  c ^= rol32(b, 8);  b += a;	\
+	a -= c;  a ^= rol32(c, 16); c += b;	\
+	b -= a;  b ^= rol32(a, 19); a += c;	\
+	c -= b;  c ^= rol32(b, 4);  b += a;	\
+}
+
+#define __jhash_final(a, b, c)			\
+{						\
+	c ^= b; c -= rol32(b, 14);		\
+	a ^= c; a -= rol32(c, 11);		\
+	b ^= a; b -= rol32(a, 25);		\
+	c ^= b; c -= rol32(b, 16);		\
+	a ^= c; a -= rol32(c, 4);		\
+	b ^= a; b -= rol32(a, 14);		\
+	c ^= b; c -= rol32(b, 24);		\
+}
+
+#define JHASH_INITVAL		0xdeadbeef
+
+typedef unsigned int u32;
+
+static inline u32 jhash(const void *key, u32 length, u32 initval)
+{
+	u32 a, b, c;
+	const unsigned char *k = key;
+
+	a = b = c = JHASH_INITVAL + length + initval;
+
+	while (length > 12) {
+		a += *(u32 *)(k);
+		b += *(u32 *)(k + 4);
+		c += *(u32 *)(k + 8);
+		__jhash_mix(a, b, c);
+		length -= 12;
+		k += 12;
+	}
+	switch (length) {
+	case 12: c += (u32)k[11]<<24;
+	case 11: c += (u32)k[10]<<16;
+	case 10: c += (u32)k[9]<<8;
+	case 9:  c += k[8];
+	case 8:  b += (u32)k[7]<<24;
+	case 7:  b += (u32)k[6]<<16;
+	case 6:  b += (u32)k[5]<<8;
+	case 5:  b += k[4];
+	case 4:  a += (u32)k[3]<<24;
+	case 3:  a += (u32)k[2]<<16;
+	case 2:  a += (u32)k[1]<<8;
+	case 1:  a += k[0];
+		 __jhash_final(a, b, c);
+	case 0: /* Nothing left to add */
+		break;
+	}
+
+	return c;
+}
+
+static inline u32 __jhash_nwords(u32 a, u32 b, u32 c, u32 initval)
+{
+	a += initval;
+	b += initval;
+	c += initval;
+	__jhash_final(a, b, c);
+	return c;
+}
+
+static inline u32 jhash_2words(u32 a, u32 b, u32 initval)
+{
+	return __jhash_nwords(a, b, 0, initval + JHASH_INITVAL + (2 << 2));
+}
+
+#define PCKT_FRAGMENTED 65343
+#define IPV4_HDR_LEN_NO_OPT 20
+#define IPV4_PLUS_ICMP_HDR 28
+#define IPV6_PLUS_ICMP_HDR 48
+#define RING_SIZE 2
+#define MAX_VIPS 12
+#define MAX_REALS 5
+#define CTL_MAP_SIZE 16
+#define CH_RINGS_SIZE (MAX_VIPS * RING_SIZE)
+#define F_IPV6 (1 << 0)
+#define F_HASH_NO_SRC_PORT (1 << 0)
+#define F_ICMP (1 << 0)
+#define F_SYN_SET (1 << 1)
+
+struct packet_description {
+	union {
+		__be32 src;
+		__be32 srcv6[4];
+	};
+	union {
+		__be32 dst;
+		__be32 dstv6[4];
+	};
+	union {
+		__u32 ports;
+		__u16 port16[2];
+	};
+	__u8 proto;
+	__u8 flags;
+};
+
+struct ctl_value {
+	union {
+		__u64 value;
+		__u32 ifindex;
+		__u8 mac[6];
+	};
+};
+
+struct vip_meta {
+	__u32 flags;
+	__u32 vip_num;
+};
+
+struct real_definition {
+	union {
+		__be32 dst;
+		__be32 dstv6[4];
+	};
+	__u8 flags;
+};
+
+struct vip_stats {
+	__u64 bytes;
+	__u64 pkts;
+};
+
+struct eth_hdr {
+	unsigned char eth_dest[ETH_ALEN];
+	unsigned char eth_source[ETH_ALEN];
+	unsigned short eth_proto;
+};
+
+struct bpf_map_def SEC("maps") vip_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(struct vip),
+	.value_size = sizeof(struct vip_meta),
+	.max_entries = MAX_VIPS,
+};
+
+struct bpf_map_def SEC("maps") ch_rings = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(__u32),
+	.value_size = sizeof(__u32),
+	.max_entries = CH_RINGS_SIZE,
+};
+
+struct bpf_map_def SEC("maps") reals = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(__u32),
+	.value_size = sizeof(struct real_definition),
+	.max_entries = MAX_REALS,
+};
+
+struct bpf_map_def SEC("maps") stats = {
+	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
+	.key_size = sizeof(__u32),
+	.value_size = sizeof(struct vip_stats),
+	.max_entries = MAX_VIPS,
+};
+
+struct bpf_map_def SEC("maps") ctl_array = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(__u32),
+	.value_size = sizeof(struct ctl_value),
+	.max_entries = CTL_MAP_SIZE,
+};
+
+static __always_inline __u32 get_packet_hash(struct packet_description *pckt,
+					     bool ipv6)
+{
+	if (ipv6)
+		return jhash_2words(jhash(pckt->srcv6, 16, MAX_VIPS),
+				    pckt->ports, CH_RINGS_SIZE);
+	else
+		return jhash_2words(pckt->src, pckt->ports, CH_RINGS_SIZE);
+}
+
+static __always_inline bool get_packet_dst(struct real_definition **real,
+					   struct packet_description *pckt,
+					   struct vip_meta *vip_info,
+					   bool is_ipv6)
+{
+	__u32 hash = get_packet_hash(pckt, is_ipv6) % RING_SIZE;
+	__u32 key = RING_SIZE * vip_info->vip_num + hash;
+	__u32 *real_pos;
+
+	real_pos = bpf_map_lookup_elem(&ch_rings, &key);
+	if (!real_pos)
+		return false;
+	key = *real_pos;
+	*real = bpf_map_lookup_elem(&reals, &key);
+	if (!(*real))
+		return false;
+	return true;
+}
+
+static __always_inline int parse_icmpv6(void *data, void *data_end, __u64 off,
+					struct packet_description *pckt)
+{
+	struct icmp6hdr *icmp_hdr;
+	struct ipv6hdr *ip6h;
+
+	icmp_hdr = data + off;
+	if (icmp_hdr + 1 > data_end)
+		return TC_ACT_SHOT;
+	if (icmp_hdr->icmp6_type != ICMPV6_PKT_TOOBIG)
+		return TC_ACT_OK;
+	off += sizeof(struct icmp6hdr);
+	ip6h = data + off;
+	if (ip6h + 1 > data_end)
+		return TC_ACT_SHOT;
+	pckt->proto = ip6h->nexthdr;
+	pckt->flags |= F_ICMP;
+	memcpy(pckt->srcv6, ip6h->daddr.s6_addr32, 16);
+	memcpy(pckt->dstv6, ip6h->saddr.s6_addr32, 16);
+	return TC_ACT_UNSPEC;
+}
+
+static __always_inline int parse_icmp(void *data, void *data_end, __u64 off,
+				      struct packet_description *pckt)
+{
+	struct icmphdr *icmp_hdr;
+	struct iphdr *iph;
+
+	icmp_hdr = data + off;
+	if (icmp_hdr + 1 > data_end)
+		return TC_ACT_SHOT;
+	if (icmp_hdr->type != ICMP_DEST_UNREACH ||
+	    icmp_hdr->code != ICMP_FRAG_NEEDED)
+		return TC_ACT_OK;
+	off += sizeof(struct icmphdr);
+	iph = data + off;
+	if (iph + 1 > data_end)
+		return TC_ACT_SHOT;
+	if (iph->ihl != 5)
+		return TC_ACT_SHOT;
+	pckt->proto = iph->protocol;
+	pckt->flags |= F_ICMP;
+	pckt->src = iph->daddr;
+	pckt->dst = iph->saddr;
+	return TC_ACT_UNSPEC;
+}
+
+static __always_inline bool parse_udp(void *data, __u64 off, void *data_end,
+				      struct packet_description *pckt)
+{
+	struct udphdr *udp;
+	udp = data + off;
+
+	if (udp + 1 > data_end)
+		return false;
+
+	if (!(pckt->flags & F_ICMP)) {
+		pckt->port16[0] = udp->source;
+		pckt->port16[1] = udp->dest;
+	} else {
+		pckt->port16[0] = udp->dest;
+		pckt->port16[1] = udp->source;
+	}
+	return true;
+}
+
+static __always_inline bool parse_tcp(void *data, __u64 off, void *data_end,
+				      struct packet_description *pckt)
+{
+	struct tcphdr *tcp;
+
+	tcp = data + off;
+	if (tcp + 1 > data_end)
+		return false;
+
+	if (tcp->syn)
+		pckt->flags |= F_SYN_SET;
+
+	if (!(pckt->flags & F_ICMP)) {
+		pckt->port16[0] = tcp->source;
+		pckt->port16[1] = tcp->dest;
+	} else {
+		pckt->port16[0] = tcp->dest;
+		pckt->port16[1] = tcp->source;
+	}
+	return true;
+}
+
+static __always_inline int process_packet(void *data, __u64 off, void *data_end,
+					  bool is_ipv6, struct __sk_buff *skb)
+{
+	void *pkt_start = (void *)(long)skb->data;
+	struct packet_description pckt = {};
+	struct eth_hdr *eth = pkt_start;
+	struct bpf_tunnel_key tkey = {};
+	struct vip_stats *data_stats;
+	struct real_definition *dst;
+	struct vip_meta *vip_info;
+	struct ctl_value *cval;
+	__u32 v4_intf_pos = 1;
+	__u32 v6_intf_pos = 2;
+	struct ipv6hdr *ip6h;
+	struct vip vip = {};
+	struct iphdr *iph;
+	int tun_flag = 0;
+	__u16 pkt_bytes;
+	__u64 iph_len;
+	__u32 ifindex;
+	__u8 protocol;
+	__u32 vip_num;
+	int action;
+
+	tkey.tunnel_ttl = 64;
+	if (is_ipv6) {
+		ip6h = data + off;
+		if (ip6h + 1 > data_end)
+			return TC_ACT_SHOT;
+
+		iph_len = sizeof(struct ipv6hdr);
+		protocol = ip6h->nexthdr;
+		pckt.proto = protocol;
+		pkt_bytes = ntohs(ip6h->payload_len);
+		off += iph_len;
+		if (protocol == IPPROTO_FRAGMENT) {
+			return TC_ACT_SHOT;
+		} else if (protocol == IPPROTO_ICMPV6) {
+			action = parse_icmpv6(data, data_end, off, &pckt);
+			if (action >= 0)
+				return action;
+			off += IPV6_PLUS_ICMP_HDR;
+		} else {
+			memcpy(pckt.srcv6, ip6h->saddr.s6_addr32, 16);
+			memcpy(pckt.dstv6, ip6h->daddr.s6_addr32, 16);
+		}
+	} else {
+		iph = data + off;
+		if (iph + 1 > data_end)
+			return TC_ACT_SHOT;
+		if (iph->ihl != 5)
+			return TC_ACT_SHOT;
+
+		protocol = iph->protocol;
+		pckt.proto = protocol;
+		pkt_bytes = ntohs(iph->tot_len);
+		off += IPV4_HDR_LEN_NO_OPT;
+
+		if (iph->frag_off & PCKT_FRAGMENTED)
+			return TC_ACT_SHOT;
+		if (protocol == IPPROTO_ICMP) {
+			action = parse_icmp(data, data_end, off, &pckt);
+			if (action >= 0)
+				return action;
+			off += IPV4_PLUS_ICMP_HDR;
+		} else {
+			pckt.src = iph->saddr;
+			pckt.dst = iph->daddr;
+		}
+	}
+	protocol = pckt.proto;
+
+	if (protocol == IPPROTO_TCP) {
+		if (!parse_tcp(data, off, data_end, &pckt))
+			return TC_ACT_SHOT;
+	} else if (protocol == IPPROTO_UDP) {
+		if (!parse_udp(data, off, data_end, &pckt))
+			return TC_ACT_SHOT;
+	} else {
+		return TC_ACT_SHOT;
+	}
+
+	if (is_ipv6)
+		memcpy(vip.daddr.v6, pckt.dstv6, 16);
+	else
+		vip.daddr.v4 = pckt.dst;
+
+	vip.dport = pckt.port16[1];
+	vip.protocol = pckt.proto;
+	vip_info = bpf_map_lookup_elem(&vip_map, &vip);
+	if (!vip_info) {
+		vip.dport = 0;
+		vip_info = bpf_map_lookup_elem(&vip_map, &vip);
+		if (!vip_info)
+			return TC_ACT_SHOT;
+		pckt.port16[1] = 0;
+	}
+
+	if (vip_info->flags & F_HASH_NO_SRC_PORT)
+		pckt.port16[0] = 0;
+
+	if (!get_packet_dst(&dst, &pckt, vip_info, is_ipv6))
+		return TC_ACT_SHOT;
+
+	if (dst->flags & F_IPV6) {
+		cval = bpf_map_lookup_elem(&ctl_array, &v6_intf_pos);
+		if (!cval)
+			return TC_ACT_SHOT;
+		ifindex = cval->ifindex;
+		memcpy(tkey.remote_ipv6, dst->dstv6, 16);
+		tun_flag = BPF_F_TUNINFO_IPV6;
+	} else {
+		cval = bpf_map_lookup_elem(&ctl_array, &v4_intf_pos);
+		if (!cval)
+			return TC_ACT_SHOT;
+		ifindex = cval->ifindex;
+		tkey.remote_ipv4 = dst->dst;
+	}
+	vip_num = vip_info->vip_num;
+	data_stats = bpf_map_lookup_elem(&stats, &vip_num);
+	if (!data_stats)
+		return TC_ACT_SHOT;
+	data_stats->pkts++;
+	data_stats->bytes += pkt_bytes;
+	bpf_skb_set_tunnel_key(skb, &tkey, sizeof(tkey), tun_flag);
+	*(u32 *)eth->eth_dest = tkey.remote_ipv4;
+	return bpf_redirect(ifindex, 0);
+}
+
+SEC("l4lb-demo")
+int balancer_ingress(struct __sk_buff *ctx)
+{
+	void *data_end = (void *)(long)ctx->data_end;
+	void *data = (void *)(long)ctx->data;
+	struct eth_hdr *eth = data;
+	__u32 eth_proto;
+	__u32 nh_off;
+
+	nh_off = sizeof(struct eth_hdr);
+	if (data + nh_off > data_end)
+		return TC_ACT_SHOT;
+	eth_proto = eth->eth_proto;
+	if (eth_proto == htons(ETH_P_IP))
+		return process_packet(data, nh_off, data_end, false, ctx);
+	else if (eth_proto == htons(ETH_P_IPV6))
+		return process_packet(data, nh_off, data_end, true, ctx);
+	else
+		return TC_ACT_SHOT;
+}
+char _license[] SEC("license") = "GPL";
diff --git a/tools/testing/selftests/bpf/test_progs.c b/tools/testing/selftests/bpf/test_progs.c
index 667b6c5bcc7b..ead686aec43b 100644
--- a/tools/testing/selftests/bpf/test_progs.c
+++ b/tools/testing/selftests/bpf/test_progs.c
@@ -28,11 +28,14 @@ typedef __u16 __sum16;
 #include <bpf/bpf.h>
 #include <bpf/libbpf.h>
 #include "test_iptunnel_common.h"
+#include "bpf_util.h"
 
 #define _htons __builtin_bswap16
 
 static int error_cnt, pass_cnt;
 
+#define MAGIC_BYTES 123
+
 /* ipv4 test vector */
 static struct {
 	struct ethhdr eth;
@@ -42,6 +45,7 @@ static struct {
 	.eth.h_proto = _htons(ETH_P_IP),
 	.iph.ihl = 5,
 	.iph.protocol = 6,
+	.iph.tot_len = _htons(MAGIC_BYTES),
 	.tcp.urg_ptr = 123,
 };
 
@@ -53,6 +57,7 @@ static struct {
 } __packed pkt_v6 = {
 	.eth.h_proto = _htons(ETH_P_IPV6),
 	.iph.nexthdr = 6,
+	.iph.payload_len = _htons(MAGIC_BYTES),
 	.tcp.urg_ptr = 123,
 };
 
@@ -182,6 +187,88 @@ static void test_xdp(void)
 	bpf_object__close(obj);
 }
 
+#define MAGIC_VAL 0x1234
+#define NUM_ITER 100000
+#define VIP_NUM 5
+
+static void test_l4lb(void)
+{
+	unsigned int nr_cpus = bpf_num_possible_cpus();
+	const char *file = "./test_l4lb.o";
+	struct vip key = {.protocol = 6};
+	struct vip_meta {
+		__u32 flags;
+		__u32 vip_num;
+	} value = {.vip_num = VIP_NUM};
+	__u32 stats_key = VIP_NUM;
+	struct vip_stats {
+		__u64 bytes;
+		__u64 pkts;
+	} stats[nr_cpus];
+	struct real_definition {
+		union {
+			__be32 dst;
+			__be32 dstv6[4];
+		};
+		__u8 flags;
+	} real_def = {.dst = MAGIC_VAL};
+	__u32 ch_key = 11, real_num = 3;
+	__u32 duration, retval, size;
+	int err, i, prog_fd, map_fd;
+	__u64 bytes = 0, pkts = 0;
+	struct bpf_object *obj;
+	char buf[128];
+	u32 *magic = (u32 *)buf;
+
+	err = bpf_prog_load(file, BPF_PROG_TYPE_SCHED_CLS, &obj, &prog_fd);
+	if (err)
+		return;
+
+	map_fd = bpf_find_map(__func__, obj, "vip_map");
+	if (map_fd < 0)
+		goto out;
+	bpf_map_update_elem(map_fd, &key, &value, 0);
+
+	map_fd = bpf_find_map(__func__, obj, "ch_rings");
+	if (map_fd < 0)
+		goto out;
+	bpf_map_update_elem(map_fd, &ch_key, &real_num, 0);
+
+	map_fd = bpf_find_map(__func__, obj, "reals");
+	if (map_fd < 0)
+		goto out;
+	bpf_map_update_elem(map_fd, &real_num, &real_def, 0);
+
+	err = bpf_program_test_run(prog_fd, NUM_ITER, &pkt_v4, sizeof(pkt_v4),
+				   buf, &size, &retval, &duration);
+	CHECK(err || errno || retval != 7/*TC_ACT_REDIRECT*/ || size != 54 ||
+	      *magic != MAGIC_VAL, "ipv4",
+	      "err %d errno %d retval %d size %d magic %x\n",
+	      err, errno, retval, size, *magic);
+
+	err = bpf_program_test_run(prog_fd, NUM_ITER, &pkt_v6, sizeof(pkt_v6),
+				   buf, &size, &retval, &duration);
+	CHECK(err || errno || retval != 7/*TC_ACT_REDIRECT*/ || size != 74 ||
+	      *magic != MAGIC_VAL, "ipv6",
+	      "err %d errno %d retval %d size %d magic %x\n",
+	      err, errno, retval, size, *magic);
+
+	map_fd = bpf_find_map(__func__, obj, "stats");
+	if (map_fd < 0)
+		goto out;
+	bpf_map_lookup_elem(map_fd, &stats_key, stats);
+	for (i = 0; i < nr_cpus; i++) {
+		bytes += stats[i].bytes;
+		pkts += stats[i].pkts;
+	}
+	if (bytes != MAGIC_BYTES * NUM_ITER * 2 || pkts != NUM_ITER * 2) {
+		error_cnt++;
+		printf("test_l4lb:FAIL:stats %lld %lld\n", bytes, pkts);
+	}
+out:
+	bpf_object__close(obj);
+}
+
 int main(void)
 {
 	struct rlimit rinf = { RLIM_INFINITY, RLIM_INFINITY };
@@ -190,6 +277,7 @@ int main(void)
 
 	test_pkt_access();
 	test_xdp();
+	test_l4lb();
 
 	printf("Summary: %d PASSED, %d FAILED\n", pass_cnt, error_cnt);
 	return 0;
-- 
2.9.3
