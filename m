From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 5/6] selftests/bpf: add a test for basic XDP functionality
Date: Thu, 30 Mar 2017 21:45:42 -0700
Message-ID: <20170331044543.4075183-6-ast@fb.com>
References: <20170331044543.4075183-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47450 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752330AbdCaEpt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 00:45:49 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2V4hEL9002194
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 21:45:47 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29hg5581jc-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 21:45:47 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 e756ca8615cc11e788ff24be05956610-531e89a0 for <netdev@vger.kernel.org>;        Thu,
 30 Mar 2017 21:45:45 -0700
In-Reply-To: <20170331044543.4075183-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add C test for xdp_adjust_head(), packet rewrite and map lookups

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 tools/testing/selftests/bpf/Makefile               |   2 +-
 tools/testing/selftests/bpf/test_iptunnel_common.h |  37 ++++
 tools/testing/selftests/bpf/test_progs.c           |  58 +++++
 tools/testing/selftests/bpf/test_xdp.c             | 236 +++++++++++++++++++++
 4 files changed, 332 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/bpf/test_iptunnel_common.h
 create mode 100644 tools/testing/selftests/bpf/test_xdp.c

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index ff68c9419a67..76cbe1d42dda 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -6,7 +6,7 @@ LDLIBS += -lcap -lelf
 
 TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test_progs
 
-TEST_GEN_FILES = test_pkt_access.o
+TEST_GEN_FILES = test_pkt_access.o test_xdp.o
 
 TEST_PROGS := test_kmod.sh
 
diff --git a/tools/testing/selftests/bpf/test_iptunnel_common.h b/tools/testing/selftests/bpf/test_iptunnel_common.h
new file mode 100644
index 000000000000..e4cd252a1b20
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_iptunnel_common.h
@@ -0,0 +1,37 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef _TEST_IPTNL_COMMON_H
+#define _TEST_IPTNL_COMMON_H
+
+#include <linux/types.h>
+
+#define MAX_IPTNL_ENTRIES 256U
+
+struct vip {
+	union {
+		__u32 v6[4];
+		__u32 v4;
+	} daddr;
+	__u16 dport;
+	__u16 family;
+	__u8 protocol;
+};
+
+struct iptnl_info {
+	union {
+		__u32 v6[4];
+		__u32 v4;
+	} saddr;
+	union {
+		__u32 v6[4];
+		__u32 v4;
+	} daddr;
+	__u16 family;
+	__u8 dmac[6];
+};
+
+#endif
diff --git a/tools/testing/selftests/bpf/test_progs.c b/tools/testing/selftests/bpf/test_progs.c
index 1d9a310e71e5..defcb273242e 100644
--- a/tools/testing/selftests/bpf/test_progs.c
+++ b/tools/testing/selftests/bpf/test_progs.c
@@ -27,6 +27,7 @@ typedef __u16 __sum16;
 #include <linux/err.h>
 #include <bpf/bpf.h>
 #include <bpf/libbpf.h>
+#include "test_iptunnel_common.h"
 
 #define _htons __builtin_bswap16
 
@@ -100,6 +101,20 @@ static int bpf_prog_load(const char *file, enum bpf_prog_type type,
 	return 0;
 }
 
+static int bpf_find_map(const char *test, struct bpf_object *obj,
+			const char *name)
+{
+	struct bpf_map *map;
+
+	map = bpf_object__find_map_by_name(obj, name);
+	if (!map) {
+		printf("%s:FAIL:map '%s' not found\n", test, name);
+		error_cnt++;
+		return -1;
+	}
+	return bpf_map__fd(map);
+}
+
 static void test_pkt_access(void)
 {
 	const char *file = "./test_pkt_access.o";
@@ -125,6 +140,48 @@ static void test_pkt_access(void)
 	bpf_object__close(obj);
 }
 
+static void test_xdp(void)
+{
+	struct vip key4 = {.protocol = 6, .family = AF_INET};
+	struct vip key6 = {.protocol = 6, .family = AF_INET6};
+	struct iptnl_info value4 = {.family = AF_INET};
+	struct iptnl_info value6 = {.family = AF_INET6};
+	const char *file = "./test_xdp.o";
+	struct bpf_object *obj;
+	char buf[128];
+	struct ipv6hdr *iph6 = (void *)buf + sizeof(struct ethhdr);
+	struct iphdr *iph = (void *)buf + sizeof(struct ethhdr);
+	__u32 duration, retval, size;
+	int err, prog_fd, map_fd;
+
+	err = bpf_prog_load(file, BPF_PROG_TYPE_XDP, &obj, &prog_fd);
+	if (err)
+		return;
+
+	map_fd = bpf_find_map(__func__, obj, "vip2tnl");
+	if (map_fd < 0)
+		goto out;
+	bpf_map_update_elem(map_fd, &key4, &value4, 0);
+	bpf_map_update_elem(map_fd, &key6, &value6, 0);
+
+	err = bpf_prog_test_run(prog_fd, 1, &pkt_v4, sizeof(pkt_v4),
+				buf, &size, &retval, &duration);
+
+	CHECK(err || errno || retval != XDP_TX || size != 74 ||
+	      iph->protocol != IPPROTO_IPIP, "ipv4",
+	      "err %d errno %d retval %d size %d\n",
+	      err, errno, retval, size);
+
+	err = bpf_prog_test_run(prog_fd, 1, &pkt_v6, sizeof(pkt_v6),
+				buf, &size, &retval, &duration);
+	CHECK(err || errno || retval != XDP_TX || size != 114 ||
+	      iph6->nexthdr != IPPROTO_IPV6, "ipv6",
+	      "err %d errno %d retval %d size %d\n",
+	      err, errno, retval, size);
+out:
+	bpf_object__close(obj);
+}
+
 int main(void)
 {
 	struct rlimit rinf = { RLIM_INFINITY, RLIM_INFINITY };
@@ -132,6 +189,7 @@ int main(void)
 	setrlimit(RLIMIT_MEMLOCK, &rinf);
 
 	test_pkt_access();
+	test_xdp();
 
 	printf("Summary: %d PASSED, %d FAILED\n", pass_cnt, error_cnt);
 	return 0;
diff --git a/tools/testing/selftests/bpf/test_xdp.c b/tools/testing/selftests/bpf/test_xdp.c
new file mode 100644
index 000000000000..9a33b038cb31
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_xdp.c
@@ -0,0 +1,236 @@
+/* Copyright (c) 2016,2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stddef.h>
+#include <string.h>
+#include <linux/bpf.h>
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/in.h>
+#include <linux/udp.h>
+#include <linux/tcp.h>
+#include <linux/pkt_cls.h>
+#include <sys/socket.h>
+#include "bpf_helpers.h"
+#include "test_iptunnel_common.h"
+
+#define htons __builtin_bswap16
+#define ntohs __builtin_bswap16
+int _version SEC("version") = 1;
+
+struct bpf_map_def SEC("maps") rxcnt = {
+	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
+	.key_size = sizeof(__u32),
+	.value_size = sizeof(__u64),
+	.max_entries = 256,
+};
+
+struct bpf_map_def SEC("maps") vip2tnl = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(struct vip),
+	.value_size = sizeof(struct iptnl_info),
+	.max_entries = MAX_IPTNL_ENTRIES,
+};
+
+static __always_inline void count_tx(__u32 protocol)
+{
+	__u64 *rxcnt_count;
+
+	rxcnt_count = bpf_map_lookup_elem(&rxcnt, &protocol);
+	if (rxcnt_count)
+		*rxcnt_count += 1;
+}
+
+static __always_inline int get_dport(void *trans_data, void *data_end,
+				     __u8 protocol)
+{
+	struct tcphdr *th;
+	struct udphdr *uh;
+
+	switch (protocol) {
+	case IPPROTO_TCP:
+		th = (struct tcphdr *)trans_data;
+		if (th + 1 > data_end)
+			return -1;
+		return th->dest;
+	case IPPROTO_UDP:
+		uh = (struct udphdr *)trans_data;
+		if (uh + 1 > data_end)
+			return -1;
+		return uh->dest;
+	default:
+		return 0;
+	}
+}
+
+static __always_inline void set_ethhdr(struct ethhdr *new_eth,
+				       const struct ethhdr *old_eth,
+				       const struct iptnl_info *tnl,
+				       __be16 h_proto)
+{
+	memcpy(new_eth->h_source, old_eth->h_dest, sizeof(new_eth->h_source));
+	memcpy(new_eth->h_dest, tnl->dmac, sizeof(new_eth->h_dest));
+	new_eth->h_proto = h_proto;
+}
+
+static __always_inline int handle_ipv4(struct xdp_md *xdp)
+{
+	void *data_end = (void *)(long)xdp->data_end;
+	void *data = (void *)(long)xdp->data;
+	struct iptnl_info *tnl;
+	struct ethhdr *new_eth;
+	struct ethhdr *old_eth;
+	struct iphdr *iph = data + sizeof(struct ethhdr);
+	__u16 *next_iph;
+	__u16 payload_len;
+	struct vip vip = {};
+	int dport;
+	__u32 csum = 0;
+	int i;
+
+	if (iph + 1 > data_end)
+		return XDP_DROP;
+
+	dport = get_dport(iph + 1, data_end, iph->protocol);
+	if (dport == -1)
+		return XDP_DROP;
+
+	vip.protocol = iph->protocol;
+	vip.family = AF_INET;
+	vip.daddr.v4 = iph->daddr;
+	vip.dport = dport;
+	payload_len = ntohs(iph->tot_len);
+
+	tnl = bpf_map_lookup_elem(&vip2tnl, &vip);
+	/* It only does v4-in-v4 */
+	if (!tnl || tnl->family != AF_INET)
+		return XDP_PASS;
+
+	if (bpf_xdp_adjust_head(xdp, 0 - (int)sizeof(struct iphdr)))
+		return XDP_DROP;
+
+	data = (void *)(long)xdp->data;
+	data_end = (void *)(long)xdp->data_end;
+
+	new_eth = data;
+	iph = data + sizeof(*new_eth);
+	old_eth = data + sizeof(*iph);
+
+	if (new_eth + 1 > data_end ||
+	    old_eth + 1 > data_end ||
+	    iph + 1 > data_end)
+		return XDP_DROP;
+
+	set_ethhdr(new_eth, old_eth, tnl, htons(ETH_P_IP));
+
+	iph->version = 4;
+	iph->ihl = sizeof(*iph) >> 2;
+	iph->frag_off =	0;
+	iph->protocol = IPPROTO_IPIP;
+	iph->check = 0;
+	iph->tos = 0;
+	iph->tot_len = htons(payload_len + sizeof(*iph));
+	iph->daddr = tnl->daddr.v4;
+	iph->saddr = tnl->saddr.v4;
+	iph->ttl = 8;
+
+	next_iph = (__u16 *)iph;
+#pragma clang loop unroll(full)
+	for (i = 0; i < sizeof(*iph) >> 1; i++)
+		csum += *next_iph++;
+
+	iph->check = ~((csum & 0xffff) + (csum >> 16));
+
+	count_tx(vip.protocol);
+
+	return XDP_TX;
+}
+
+static __always_inline int handle_ipv6(struct xdp_md *xdp)
+{
+	void *data_end = (void *)(long)xdp->data_end;
+	void *data = (void *)(long)xdp->data;
+	struct iptnl_info *tnl;
+	struct ethhdr *new_eth;
+	struct ethhdr *old_eth;
+	struct ipv6hdr *ip6h = data + sizeof(struct ethhdr);
+	__u16 payload_len;
+	struct vip vip = {};
+	int dport;
+
+	if (ip6h + 1 > data_end)
+		return XDP_DROP;
+
+	dport = get_dport(ip6h + 1, data_end, ip6h->nexthdr);
+	if (dport == -1)
+		return XDP_DROP;
+
+	vip.protocol = ip6h->nexthdr;
+	vip.family = AF_INET6;
+	memcpy(vip.daddr.v6, ip6h->daddr.s6_addr32, sizeof(vip.daddr));
+	vip.dport = dport;
+	payload_len = ip6h->payload_len;
+
+	tnl = bpf_map_lookup_elem(&vip2tnl, &vip);
+	/* It only does v6-in-v6 */
+	if (!tnl || tnl->family != AF_INET6)
+		return XDP_PASS;
+
+	if (bpf_xdp_adjust_head(xdp, 0 - (int)sizeof(struct ipv6hdr)))
+		return XDP_DROP;
+
+	data = (void *)(long)xdp->data;
+	data_end = (void *)(long)xdp->data_end;
+
+	new_eth = data;
+	ip6h = data + sizeof(*new_eth);
+	old_eth = data + sizeof(*ip6h);
+
+	if (new_eth + 1 > data_end || old_eth + 1 > data_end ||
+	    ip6h + 1 > data_end)
+		return XDP_DROP;
+
+	set_ethhdr(new_eth, old_eth, tnl, htons(ETH_P_IPV6));
+
+	ip6h->version = 6;
+	ip6h->priority = 0;
+	memset(ip6h->flow_lbl, 0, sizeof(ip6h->flow_lbl));
+	ip6h->payload_len = htons(ntohs(payload_len) + sizeof(*ip6h));
+	ip6h->nexthdr = IPPROTO_IPV6;
+	ip6h->hop_limit = 8;
+	memcpy(ip6h->saddr.s6_addr32, tnl->saddr.v6, sizeof(tnl->saddr.v6));
+	memcpy(ip6h->daddr.s6_addr32, tnl->daddr.v6, sizeof(tnl->daddr.v6));
+
+	count_tx(vip.protocol);
+
+	return XDP_TX;
+}
+
+SEC("xdp_tx_iptunnel")
+int _xdp_tx_iptunnel(struct xdp_md *xdp)
+{
+	void *data_end = (void *)(long)xdp->data_end;
+	void *data = (void *)(long)xdp->data;
+	struct ethhdr *eth = data;
+	__u16 h_proto;
+
+	if (eth + 1 > data_end)
+		return XDP_DROP;
+
+	h_proto = eth->h_proto;
+
+	if (h_proto == htons(ETH_P_IP))
+		return handle_ipv4(xdp);
+	else if (h_proto == htons(ETH_P_IPV6))
+
+		return handle_ipv6(xdp);
+	else
+		return XDP_DROP;
+}
+
+char _license[] SEC("license") = "GPL";
-- 
2.9.3
