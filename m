From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v8 11/11] bpf: add sample for xdp forwarding and rewrite
Date: Tue, 12 Jul 2016 00:51:34 -0700
Message-ID: <1468309894-26258-12-git-send-email-bblanco@plumgrid.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36122 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbcGLHwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 03:52:43 -0400
Received: by mail-pa0-f53.google.com with SMTP id hu1so4077383pad.3
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 00:52:43 -0700 (PDT)
In-Reply-To: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a sample that rewrites and forwards packets out on the same
interface. Observed single core forwarding performance of ~10Mpps.

Since the mlx4 driver under test recycles every single packet page, the
perf output shows almost exclusively just the ring management and bpf
program work. Slowdowns are likely occurring due to cache misses.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 samples/bpf/Makefile    |   5 +++
 samples/bpf/xdp2_kern.c | 114 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 119 insertions(+)
 create mode 100644 samples/bpf/xdp2_kern.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 0e4ab3a..d2d2b35 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -22,6 +22,7 @@ hostprogs-y += map_perf_test
 hostprogs-y += test_overhead
 hostprogs-y += test_cgrp2_array_pin
 hostprogs-y += xdp1
+hostprogs-y += xdp2
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -44,6 +45,8 @@ map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
 test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
 test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
+# reuse xdp1 source intentionally
+xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -67,6 +70,7 @@ always += test_overhead_kprobe_kern.o
 always += parse_varlen.o parse_simple.o parse_ldabs.o
 always += test_cgrp2_tc_kern.o
 always += xdp1_kern.o
+always += xdp2_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -88,6 +92,7 @@ HOSTLOADLIBES_spintest += -lelf
 HOSTLOADLIBES_map_perf_test += -lelf -lrt
 HOSTLOADLIBES_test_overhead += -lelf -lrt
 HOSTLOADLIBES_xdp1 += -lelf
+HOSTLOADLIBES_xdp2 += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/xdp2_kern.c b/samples/bpf/xdp2_kern.c
new file mode 100644
index 0000000..38fe7e1
--- /dev/null
+++ b/samples/bpf/xdp2_kern.c
@@ -0,0 +1,114 @@
+/* Copyright (c) 2016 PLUMgrid
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#define KBUILD_MODNAME "foo"
+#include <uapi/linux/bpf.h>
+#include <linux/in.h>
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+#include <linux/if_vlan.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include "bpf_helpers.h"
+
+struct bpf_map_def SEC("maps") dropcnt = {
+	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = 256,
+};
+
+static void swap_src_dst_mac(void *data)
+{
+	unsigned short *p = data;
+	unsigned short dst[3];
+
+	dst[0] = p[0];
+	dst[1] = p[1];
+	dst[2] = p[2];
+	p[0] = p[3];
+	p[1] = p[4];
+	p[2] = p[5];
+	p[3] = dst[0];
+	p[4] = dst[1];
+	p[5] = dst[2];
+}
+
+static int parse_ipv4(void *data, u64 nh_off, void *data_end)
+{
+	struct iphdr *iph = data + nh_off;
+
+	if (iph + 1 > data_end)
+		return 0;
+	return iph->protocol;
+}
+
+static int parse_ipv6(void *data, u64 nh_off, void *data_end)
+{
+	struct ipv6hdr *ip6h = data + nh_off;
+
+	if (ip6h + 1 > data_end)
+		return 0;
+	return ip6h->nexthdr;
+}
+
+SEC("xdp1")
+int xdp_prog1(struct xdp_md *ctx)
+{
+	void *data_end = (void *)(long)ctx->data_end;
+	void *data = (void *)(long)ctx->data;
+	struct ethhdr *eth = data;
+	int rc = XDP_DROP;
+	long *value;
+	u16 h_proto;
+	u64 nh_off;
+	u32 index;
+
+	nh_off = sizeof(*eth);
+	if (data + nh_off > data_end)
+		return rc;
+
+	h_proto = eth->h_proto;
+
+	if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)) {
+		struct vlan_hdr *vhdr;
+
+		vhdr = data + nh_off;
+		nh_off += sizeof(struct vlan_hdr);
+		if (data + nh_off > data_end)
+			return rc;
+		h_proto = vhdr->h_vlan_encapsulated_proto;
+	}
+	if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)) {
+		struct vlan_hdr *vhdr;
+
+		vhdr = data + nh_off;
+		nh_off += sizeof(struct vlan_hdr);
+		if (data + nh_off > data_end)
+			return rc;
+		h_proto = vhdr->h_vlan_encapsulated_proto;
+	}
+
+	if (h_proto == htons(ETH_P_IP))
+		index = parse_ipv4(data, nh_off, data_end);
+	else if (h_proto == htons(ETH_P_IPV6))
+		index = parse_ipv6(data, nh_off, data_end);
+	else
+		index = 0;
+
+	value = bpf_map_lookup_elem(&dropcnt, &index);
+	if (value)
+		*value += 1;
+
+	if (index == 17) {
+		swap_src_dst_mac(data);
+		rc = XDP_TX;
+	}
+
+	return rc;
+}
+
+char _license[] SEC("license") = "GPL";
-- 
2.8.2
