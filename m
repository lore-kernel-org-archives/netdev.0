From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 6/7] samples/bpf: add 'pointer to packet' tests
Date: Thu, 5 May 2016 19:49:14 -0700
Message-ID: <1462502955-1731797-7-git-send-email-ast@fb.com>
References: <1462502955-1731797-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33079 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756383AbcEFCtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 22:49:19 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u462jlHi027669
	for <netdev@vger.kernel.org>; Thu, 5 May 2016 19:49:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22rh7ugj8s-3
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 05 May 2016 19:49:17 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1fa8ec20133511e69fe30002c9dfb610-afee4c50 for <netdev@vger.kernel.org>;	Thu,
 05 May 2016 19:49:16 -0700
In-Reply-To: <1462502955-1731797-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

parse_simple.c - packet parser exapmle with single length check that
filters out udp packets for port 9

parse_varlen.c - variable length parser that understand multiple vlan headers,
ipip, ipip6 and ip options to filter out udp or tcp packets on port 9.
The packet is parsed layer by layer with multitple length checks.

parse_ldabs.c - classic style of packet parsing using LD_ABS instruction.
Same functionality as parse_simple.

simple = 24.1Mpps per core
varlen = 22.7Mpps
ldabs  = 21.4Mpps

Parser with LD_ABS instructions is slower than full direct access parser
which does more packet accesses and checks.

These examples demonstrate the choice bpf program authors can make between
flexibility of the parser vs speed.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile        |   2 +
 samples/bpf/parse_ldabs.c   |  41 ++++++++++++
 samples/bpf/parse_simple.c  |  48 ++++++++++++++
 samples/bpf/parse_varlen.c  | 153 ++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/test_cls_bpf.sh |  37 +++++++++++
 5 files changed, 281 insertions(+)
 create mode 100644 samples/bpf/parse_ldabs.c
 create mode 100644 samples/bpf/parse_simple.c
 create mode 100644 samples/bpf/parse_varlen.c
 create mode 100755 samples/bpf/test_cls_bpf.sh

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 66897e61232c..0bf2478cb7df 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -60,6 +60,7 @@ always += spintest_kern.o
 always += map_perf_test_kern.o
 always += test_overhead_tp_kern.o
 always += test_overhead_kprobe_kern.o
+always += parse_varlen.o parse_simple.o parse_ldabs.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -120,4 +121,5 @@ $(src)/*.c: verify_target_bpf
 $(obj)/%.o: $(src)/%.c
 	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
 		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
+		-Wno-compare-distinct-pointer-types \
 		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
diff --git a/samples/bpf/parse_ldabs.c b/samples/bpf/parse_ldabs.c
new file mode 100644
index 000000000000..d17550198d06
--- /dev/null
+++ b/samples/bpf/parse_ldabs.c
@@ -0,0 +1,41 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/in.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+#define DEFAULT_PKTGEN_UDP_PORT	9
+#define IP_MF			0x2000
+#define IP_OFFSET		0x1FFF
+
+static inline int ip_is_fragment(struct __sk_buff *ctx, __u64 nhoff)
+{
+	return load_half(ctx, nhoff + offsetof(struct iphdr, frag_off))
+		& (IP_MF | IP_OFFSET);
+}
+
+SEC("ldabs")
+int handle_ingress(struct __sk_buff *skb)
+{
+	__u64 troff = ETH_HLEN + sizeof(struct iphdr);
+
+	if (load_half(skb, offsetof(struct ethhdr, h_proto)) != ETH_P_IP)
+		return 0;
+	if (load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol)) != IPPROTO_UDP ||
+	    load_byte(skb, ETH_HLEN) != 0x45)
+		return 0;
+	if (ip_is_fragment(skb, ETH_HLEN))
+		return 0;
+	if (load_half(skb, troff + offsetof(struct udphdr, dest)) == DEFAULT_PKTGEN_UDP_PORT)
+		return TC_ACT_SHOT;
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/parse_simple.c b/samples/bpf/parse_simple.c
new file mode 100644
index 000000000000..cf2511c33905
--- /dev/null
+++ b/samples/bpf/parse_simple.c
@@ -0,0 +1,48 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/in.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <uapi/linux/bpf.h>
+#include <net/ip.h>
+#include "bpf_helpers.h"
+
+#define DEFAULT_PKTGEN_UDP_PORT 9
+
+/* copy of 'struct ethhdr' without __packed */
+struct eth_hdr {
+	unsigned char   h_dest[ETH_ALEN];
+	unsigned char   h_source[ETH_ALEN];
+	unsigned short  h_proto;
+};
+
+SEC("simple")
+int handle_ingress(struct __sk_buff *skb)
+{
+	void *data = (void *)(long)skb->data;
+	struct eth_hdr *eth = data;
+	struct iphdr *iph = data + sizeof(*eth);
+	struct udphdr *udp = data + sizeof(*eth) + sizeof(*iph);
+	void *data_end = (void *)(long)skb->data_end;
+
+	/* single length check */
+	if (data + sizeof(*eth) + sizeof(*iph) + sizeof(*udp) > data_end)
+		return 0;
+
+	if (eth->h_proto != htons(ETH_P_IP))
+		return 0;
+	if (iph->protocol != IPPROTO_UDP || iph->ihl != 5)
+		return 0;
+	if (ip_is_fragment(iph))
+		return 0;
+	if (udp->dest == htons(DEFAULT_PKTGEN_UDP_PORT))
+		return TC_ACT_SHOT;
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/parse_varlen.c b/samples/bpf/parse_varlen.c
new file mode 100644
index 000000000000..edab34dce79b
--- /dev/null
+++ b/samples/bpf/parse_varlen.c
@@ -0,0 +1,153 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/if_ether.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/in.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <uapi/linux/bpf.h>
+#include <net/ip.h>
+#include "bpf_helpers.h"
+
+#define DEFAULT_PKTGEN_UDP_PORT 9
+#define DEBUG 0
+
+static int tcp(void *data, uint64_t tp_off, void *data_end)
+{
+	struct tcphdr *tcp = data + tp_off;
+
+	if (tcp + 1 > data_end)
+		return 0;
+	if (tcp->dest == htons(80) || tcp->source == htons(80))
+		return TC_ACT_SHOT;
+	return 0;
+}
+
+static int udp(void *data, uint64_t tp_off, void *data_end)
+{
+	struct udphdr *udp = data + tp_off;
+
+	if (udp + 1 > data_end)
+		return 0;
+	if (udp->dest == htons(DEFAULT_PKTGEN_UDP_PORT) ||
+	    udp->source == htons(DEFAULT_PKTGEN_UDP_PORT)) {
+		if (DEBUG) {
+			char fmt[] = "udp port 9 indeed\n";
+
+			bpf_trace_printk(fmt, sizeof(fmt));
+		}
+		return TC_ACT_SHOT;
+	}
+	return 0;
+}
+
+static int parse_ipv4(void *data, uint64_t nh_off, void *data_end)
+{
+	struct iphdr *iph;
+	uint64_t ihl_len;
+
+	iph = data + nh_off;
+	if (iph + 1 > data_end)
+		return 0;
+
+	if (ip_is_fragment(iph))
+		return 0;
+	ihl_len = iph->ihl * 4;
+
+	if (iph->protocol == IPPROTO_IPIP) {
+		iph = data + nh_off + ihl_len;
+		if (iph + 1 > data_end)
+			return 0;
+		ihl_len += iph->ihl * 4;
+	}
+
+	if (iph->protocol == IPPROTO_TCP)
+		return tcp(data, nh_off + ihl_len, data_end);
+	else if (iph->protocol == IPPROTO_UDP)
+		return udp(data, nh_off + ihl_len, data_end);
+	return 0;
+}
+
+static int parse_ipv6(void *data, uint64_t nh_off, void *data_end)
+{
+	struct ipv6hdr *ip6h;
+	struct iphdr *iph;
+	uint64_t ihl_len = sizeof(struct ipv6hdr);
+	uint64_t nexthdr;
+
+	ip6h = data + nh_off;
+	if (ip6h + 1 > data_end)
+		return 0;
+
+	nexthdr = ip6h->nexthdr;
+
+	if (nexthdr == IPPROTO_IPIP) {
+		iph = data + nh_off + ihl_len;
+		if (iph + 1 > data_end)
+			return 0;
+		ihl_len += iph->ihl * 4;
+		nexthdr = iph->protocol;
+	} else if (nexthdr == IPPROTO_IPV6) {
+		ip6h = data + nh_off + ihl_len;
+		if (ip6h + 1 > data_end)
+			return 0;
+		ihl_len += sizeof(struct ipv6hdr);
+		nexthdr = ip6h->nexthdr;
+	}
+
+	if (nexthdr == IPPROTO_TCP)
+		return tcp(data, nh_off + ihl_len, data_end);
+	else if (nexthdr == IPPROTO_UDP)
+		return udp(data, nh_off + ihl_len, data_end);
+	return 0;
+}
+
+struct vlan_hdr {
+	uint16_t h_vlan_TCI;
+	uint16_t h_vlan_encapsulated_proto;
+};
+
+SEC("varlen")
+int handle_ingress(struct __sk_buff *skb)
+{
+	void *data = (void *)(long)skb->data;
+	struct ethhdr *eth = data;
+	void *data_end = (void *)(long)skb->data_end;
+	uint64_t h_proto, nh_off;
+
+	nh_off = sizeof(*eth);
+	if (data + nh_off > data_end)
+		return 0;
+
+	h_proto = eth->h_proto;
+
+	if (h_proto == ETH_P_8021Q || h_proto == ETH_P_8021AD) {
+		struct vlan_hdr *vhdr;
+
+		vhdr = data + nh_off;
+		nh_off += sizeof(struct vlan_hdr);
+		if (data + nh_off > data_end)
+			return 0;
+		h_proto = vhdr->h_vlan_encapsulated_proto;
+	}
+	if (h_proto == ETH_P_8021Q || h_proto == ETH_P_8021AD) {
+		struct vlan_hdr *vhdr;
+
+		vhdr = data + nh_off;
+		nh_off += sizeof(struct vlan_hdr);
+		if (data + nh_off > data_end)
+			return 0;
+		h_proto = vhdr->h_vlan_encapsulated_proto;
+	}
+	if (h_proto == htons(ETH_P_IP))
+		return parse_ipv4(data, nh_off, data_end);
+	else if (h_proto == htons(ETH_P_IPV6))
+		return parse_ipv6(data, nh_off, data_end);
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/test_cls_bpf.sh b/samples/bpf/test_cls_bpf.sh
new file mode 100755
index 000000000000..0365d5ee512c
--- /dev/null
+++ b/samples/bpf/test_cls_bpf.sh
@@ -0,0 +1,37 @@
+#!/bin/bash
+
+function pktgen {
+    ../pktgen/pktgen_bench_xmit_mode_netif_receive.sh -i $IFC -s 64 \
+        -m 90:e2:ba:ff:ff:ff -d 192.168.0.1 -t 4
+    local dropped=`tc -s qdisc show dev $IFC | tail -3 | awk '/drop/{print $7}'`
+    if [ "$dropped" == "0," ]; then
+        echo "FAIL"
+    else
+        echo "Successfully filtered " $dropped " packets"
+    fi
+}
+
+function test {
+    echo -n "Loading bpf program '$2'... "
+    tc qdisc add dev $IFC clsact
+    tc filter add dev $IFC ingress bpf da obj $1 sec $2
+    local status=$?
+    if [ $status -ne 0 ]; then
+        echo "FAIL"
+    else
+        echo "ok"
+	pktgen
+    fi
+    tc qdisc del dev $IFC clsact
+}
+
+IFC=test_veth
+
+ip link add name $IFC type veth peer name pair_$IFC
+ip link set $IFC up
+ip link set pair_$IFC up
+
+test ./parse_simple.o simple
+test ./parse_varlen.o varlen
+test ./parse_ldabs.o ldabs
+ip link del dev $IFC
-- 
2.8.0
