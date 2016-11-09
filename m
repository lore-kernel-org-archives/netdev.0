From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 2/2] bpf: Add test for bpf_redirect to ipip/ip6tnl
Date: Wed, 9 Nov 2016 15:36:34 -0800
Message-ID: <1478734594-337666-3-git-send-email-kafai@fb.com>
References: <1478734594-337666-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:42665 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753466AbcKIXhD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 18:37:03 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA9NZX4l003512
        for <netdev@vger.kernel.org>; Wed, 9 Nov 2016 15:37:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 26md7ur686-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 15:37:02 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 6978542ea6d511e6a77824be0593f280-2abe4a50 for <netdev@vger.kernel.org>;        Wed,
 09 Nov 2016 15:37:01 -0800
In-Reply-To: <1478734594-337666-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The test creates two netns, ns1 and ns2.  The host (the default netns)
has an ipip or ip6tnl dev configured for tunneling traffic to the ns2.

    ping VIPS from ns1 <----> host <--tunnel--> ns2 (VIPs at loopback)

The test is to have ns1 pinging VIPs configured at the loopback
interface in ns2.

The VIPs are 10.10.1.102 and 2401:face::66 (which are configured
at lo@ns2). [Note: 0x66 => 102].

At ns1, the VIPs are routed _via_ the host.

At the host, bpf programs are installed at the veth to redirect packets
from a veth to the ipip/ip6tnl.  The test is configured in a way so
that both ingress and egress can be tested.

At ns2, the ipip/ip6tnl dev is configured with the local and remote address
specified.  The return path is routed to the dev ipip/ip6tnl.

During egress test, the host also locally tests pinging the VIPs to ensure
that bpf_redirect at egress also works for the direct egress (i.e. not
forwarding from dev ve1 to ve2).

Acked-by: Alexei Starovoitov <ast@fb.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 samples/bpf/Makefile              |   4 +
 samples/bpf/tc_l2_redirect.sh     | 173 ++++++++++++++++++++++++++++
 samples/bpf/tc_l2_redirect_kern.c | 236 ++++++++++++++++++++++++++++++++++++++
 samples/bpf/tc_l2_redirect_user.c |  73 ++++++++++++
 4 files changed, 486 insertions(+)
 create mode 100755 samples/bpf/tc_l2_redirect.sh
 create mode 100644 samples/bpf/tc_l2_redirect_kern.c
 create mode 100644 samples/bpf/tc_l2_redirect_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 12b7304..72c5867 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -27,6 +27,7 @@ hostprogs-y += xdp2
 hostprogs-y += test_current_task_under_cgroup
 hostprogs-y += trace_event
 hostprogs-y += sampleip
+hostprogs-y += tc_l2_redirect
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -56,6 +57,7 @@ test_current_task_under_cgroup-objs := bpf_load.o libbpf.o \
 				       test_current_task_under_cgroup_user.o
 trace_event-objs := bpf_load.o libbpf.o trace_event_user.o
 sampleip-objs := bpf_load.o libbpf.o sampleip_user.o
+tc_l2_redirect-objs := bpf_load.o libbpf.o tc_l2_redirect_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -72,6 +74,7 @@ always += test_probe_write_user_kern.o
 always += trace_output_kern.o
 always += tcbpf1_kern.o
 always += tcbpf2_kern.o
+always += tc_l2_redirect_kern.o
 always += lathist_kern.o
 always += offwaketime_kern.o
 always += spintest_kern.o
@@ -111,6 +114,7 @@ HOSTLOADLIBES_xdp2 += -lelf
 HOSTLOADLIBES_test_current_task_under_cgroup += -lelf
 HOSTLOADLIBES_trace_event += -lelf
 HOSTLOADLIBES_sampleip += -lelf
+HOSTLOADLIBES_tc_l2_redirect += -l elf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/tc_l2_redirect.sh b/samples/bpf/tc_l2_redirect.sh
new file mode 100755
index 0000000..b0e1f09
--- /dev/null
+++ b/samples/bpf/tc_l2_redirect.sh
@@ -0,0 +1,173 @@
+#!/bin/bash
+
+[[ -z $TC ]] && TC='tc'
+[[ -z $IP ]] && IP='ip'
+
+REDIRECT_USER='./tc_l2_redirect'
+REDIRECT_BPF='./tc_l2_redirect_kern.o'
+
+RP_FILTER=$(< /proc/sys/net/ipv4/conf/all/rp_filter)
+IPV6_FORWARDING=$(< /proc/sys/net/ipv6/conf/all/forwarding)
+
+function config_common {
+	local tun_type=$1
+
+	$IP netns add ns1
+	$IP netns add ns2
+	$IP link add ve1 type veth peer name vens1
+	$IP link add ve2 type veth peer name vens2
+	$IP link set dev ve1 up
+	$IP link set dev ve2 up
+	$IP link set dev ve1 mtu 1500
+	$IP link set dev ve2 mtu 1500
+	$IP link set dev vens1 netns ns1
+	$IP link set dev vens2 netns ns2
+
+	$IP -n ns1 link set dev lo up
+	$IP -n ns1 link set dev vens1 up
+	$IP -n ns1 addr add 10.1.1.101/24 dev vens1
+	$IP -n ns1 addr add 2401:db01::65/64 dev vens1 nodad
+	$IP -n ns1 route add default via 10.1.1.1 dev vens1
+	$IP -n ns1 route add default via 2401:db01::1 dev vens1
+
+	$IP -n ns2 link set dev lo up
+	$IP -n ns2 link set dev vens2 up
+	$IP -n ns2 addr add 10.2.1.102/24 dev vens2
+	$IP -n ns2 addr add 2401:db02::66/64 dev vens2 nodad
+	$IP -n ns2 addr add 10.10.1.102 dev lo
+	$IP -n ns2 addr add 2401:face::66/64 dev lo nodad
+	$IP -n ns2 link add ipt2 type ipip local 10.2.1.102 remote 10.2.1.1
+	$IP -n ns2 link add ip6t2 type ip6tnl mode any local 2401:db02::66 remote 2401:db02::1
+	$IP -n ns2 link set dev ipt2 up
+	$IP -n ns2 link set dev ip6t2 up
+	$IP netns exec ns2 $TC qdisc add dev vens2 clsact
+	$IP netns exec ns2 $TC filter add dev vens2 ingress bpf da obj $REDIRECT_BPF sec drop_non_tun_vip
+	if [[ $tun_type == "ipip" ]]; then
+		$IP -n ns2 route add 10.1.1.0/24 dev ipt2
+		$IP netns exec ns2 sysctl -q -w net.ipv4.conf.all.rp_filter=0
+		$IP netns exec ns2 sysctl -q -w net.ipv4.conf.ipt2.rp_filter=0
+	else
+		$IP -n ns2 route add 10.1.1.0/24 dev ip6t2
+		$IP -n ns2 route add 2401:db01::/64 dev ip6t2
+		$IP netns exec ns2 sysctl -q -w net.ipv4.conf.all.rp_filter=0
+		$IP netns exec ns2 sysctl -q -w net.ipv4.conf.ip6t2.rp_filter=0
+	fi
+
+	$IP addr add 10.1.1.1/24 dev ve1
+	$IP addr add 2401:db01::1/64 dev ve1 nodad
+	$IP addr add 10.2.1.1/24 dev ve2
+	$IP addr add 2401:db02::1/64 dev ve2 nodad
+
+	$TC qdisc add dev ve2 clsact
+	$TC filter add dev ve2 ingress bpf da obj $REDIRECT_BPF sec l2_to_iptun_ingress_forward
+
+	sysctl -q -w net.ipv4.conf.all.rp_filter=0
+	sysctl -q -w net.ipv6.conf.all.forwarding=1
+}
+
+function cleanup {
+	set +e
+	[[ -z $DEBUG ]] || set +x
+	$IP netns delete ns1 >& /dev/null
+	$IP netns delete ns2 >& /dev/null
+	$IP link del ve1 >& /dev/null
+	$IP link del ve2 >& /dev/null
+	$IP link del ipt >& /dev/null
+	$IP link del ip6t >& /dev/null
+	sysctl -q -w net.ipv4.conf.all.rp_filter=$RP_FILTER
+	sysctl -q -w net.ipv6.conf.all.forwarding=$IPV6_FORWARDING
+	rm -f /sys/fs/bpf/tc/globals/tun_iface
+	[[ -z $DEBUG ]] || set -x
+	set -e
+}
+
+function l2_to_ipip {
+	echo -n "l2_to_ipip $1: "
+
+	local dir=$1
+
+	config_common ipip
+
+	$IP link add ipt type ipip external
+	$IP link set dev ipt up
+	sysctl -q -w net.ipv4.conf.ipt.rp_filter=0
+	sysctl -q -w net.ipv4.conf.ipt.forwarding=1
+
+	if [[ $dir == "egress" ]]; then
+		$IP route add 10.10.1.0/24 via 10.2.1.102 dev ve2
+		$TC filter add dev ve2 egress bpf da obj $REDIRECT_BPF sec l2_to_iptun_ingress_redirect
+		sysctl -q -w net.ipv4.conf.ve1.forwarding=1
+	else
+		$TC qdisc add dev ve1 clsact
+		$TC filter add dev ve1 ingress bpf da obj $REDIRECT_BPF sec l2_to_iptun_ingress_redirect
+	fi
+
+	$REDIRECT_USER -U /sys/fs/bpf/tc/globals/tun_iface -i $(< /sys/class/net/ipt/ifindex)
+
+	$IP netns exec ns1 ping -c1 10.10.1.102 >& /dev/null
+
+	if [[ $dir == "egress" ]]; then
+		# test direct egress to ve2 (i.e. not forwarding from
+		# ve1 to ve2).
+		ping -c1 10.10.1.102 >& /dev/null
+	fi
+
+	cleanup
+
+	echo "OK"
+}
+
+function l2_to_ip6tnl {
+	echo -n "l2_to_ip6tnl $1: "
+
+	local dir=$1
+
+	config_common ip6tnl
+
+	$IP link add ip6t type ip6tnl mode any external
+	$IP link set dev ip6t up
+	sysctl -q -w net.ipv4.conf.ip6t.rp_filter=0
+	sysctl -q -w net.ipv4.conf.ip6t.forwarding=1
+
+	if [[ $dir == "egress" ]]; then
+		$IP route add 10.10.1.0/24 via 10.2.1.102 dev ve2
+		$IP route add 2401:face::/64 via 2401:db02::66 dev ve2
+		$TC filter add dev ve2 egress bpf da obj $REDIRECT_BPF sec l2_to_ip6tun_ingress_redirect
+		sysctl -q -w net.ipv4.conf.ve1.forwarding=1
+	else
+		$TC qdisc add dev ve1 clsact
+		$TC filter add dev ve1 ingress bpf da obj $REDIRECT_BPF sec l2_to_ip6tun_ingress_redirect
+	fi
+
+	$REDIRECT_USER -U /sys/fs/bpf/tc/globals/tun_iface -i $(< /sys/class/net/ip6t/ifindex)
+
+	$IP netns exec ns1 ping -c1 10.10.1.102 >& /dev/null
+	$IP netns exec ns1 ping -6 -c1 2401:face::66 >& /dev/null
+
+	if [[ $dir == "egress" ]]; then
+		# test direct egress to ve2 (i.e. not forwarding from
+		# ve1 to ve2).
+		ping -c1 10.10.1.102 >& /dev/null
+		ping -6 -c1 2401:face::66 >& /dev/null
+	fi
+
+	cleanup
+
+	echo "OK"
+}
+
+cleanup
+test_names="l2_to_ipip l2_to_ip6tnl"
+test_dirs="ingress egress"
+if [[ $# -ge 2 ]]; then
+	test_names=$1
+	test_dirs=$2
+elif [[ $# -ge 1 ]]; then
+    	test_names=$1
+fi
+
+for t in $test_names; do
+	for d in $test_dirs; do
+		$t $d
+	done
+done
diff --git a/samples/bpf/tc_l2_redirect_kern.c b/samples/bpf/tc_l2_redirect_kern.c
new file mode 100644
index 0000000..92a4472
--- /dev/null
+++ b/samples/bpf/tc_l2_redirect_kern.c
@@ -0,0 +1,236 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/if_packet.h>
+#include <uapi/linux/ip.h>
+#include <uapi/linux/ipv6.h>
+#include <uapi/linux/in.h>
+#include <uapi/linux/tcp.h>
+#include <uapi/linux/filter.h>
+#include <uapi/linux/pkt_cls.h>
+#include <net/ipv6.h>
+#include "bpf_helpers.h"
+
+#define _htonl __builtin_bswap32
+
+#define PIN_GLOBAL_NS		2
+struct bpf_elf_map {
+	__u32 type;
+	__u32 size_key;
+	__u32 size_value;
+	__u32 max_elem;
+	__u32 flags;
+	__u32 id;
+	__u32 pinning;
+};
+
+/* copy of 'struct ethhdr' without __packed */
+struct eth_hdr {
+	unsigned char   h_dest[ETH_ALEN];
+	unsigned char   h_source[ETH_ALEN];
+	unsigned short  h_proto;
+};
+
+struct bpf_elf_map SEC("maps") tun_iface = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.size_key = sizeof(int),
+	.size_value = sizeof(int),
+	.pinning = PIN_GLOBAL_NS,
+	.max_elem = 1,
+};
+
+static __always_inline bool is_vip_addr(__be16 eth_proto, __be32 daddr)
+{
+	if (eth_proto == htons(ETH_P_IP))
+		return (_htonl(0xffffff00) & daddr) == _htonl(0x0a0a0100);
+	else if (eth_proto == htons(ETH_P_IPV6))
+		return (daddr == _htonl(0x2401face));
+
+	return false;
+}
+
+SEC("l2_to_iptun_ingress_forward")
+int _l2_to_iptun_ingress_forward(struct __sk_buff *skb)
+{
+	struct bpf_tunnel_key tkey = {};
+	void *data = (void *)(long)skb->data;
+	struct eth_hdr *eth = data;
+	void *data_end = (void *)(long)skb->data_end;
+	int key = 0, *ifindex;
+
+	int ret;
+
+	if (data + sizeof(*eth) > data_end)
+		return TC_ACT_OK;
+
+	ifindex = bpf_map_lookup_elem(&tun_iface, &key);
+	if (!ifindex)
+		return TC_ACT_OK;
+
+	if (eth->h_proto == htons(ETH_P_IP)) {
+		char fmt4[] = "ingress forward to ifindex:%d daddr4:%x\n";
+		struct iphdr *iph = data + sizeof(*eth);
+
+		if (data + sizeof(*eth) + sizeof(*iph) > data_end)
+			return TC_ACT_OK;
+
+		if (iph->protocol != IPPROTO_IPIP)
+			return TC_ACT_OK;
+
+		bpf_trace_printk(fmt4, sizeof(fmt4), *ifindex,
+				 _htonl(iph->daddr));
+		return bpf_redirect(*ifindex, BPF_F_INGRESS);
+	} else if (eth->h_proto == htons(ETH_P_IPV6)) {
+		char fmt6[] = "ingress forward to ifindex:%d daddr6:%x::%x\n";
+		struct ipv6hdr *ip6h = data + sizeof(*eth);
+
+		if (data + sizeof(*eth) + sizeof(*ip6h) > data_end)
+			return TC_ACT_OK;
+
+		if (ip6h->nexthdr != IPPROTO_IPIP &&
+		    ip6h->nexthdr != IPPROTO_IPV6)
+			return TC_ACT_OK;
+
+		bpf_trace_printk(fmt6, sizeof(fmt6), *ifindex,
+				 _htonl(ip6h->daddr.s6_addr32[0]),
+				 _htonl(ip6h->daddr.s6_addr32[3]));
+		return bpf_redirect(*ifindex, BPF_F_INGRESS);
+	}
+
+	return TC_ACT_OK;
+}
+
+SEC("l2_to_iptun_ingress_redirect")
+int _l2_to_iptun_ingress_redirect(struct __sk_buff *skb)
+{
+	struct bpf_tunnel_key tkey = {};
+	void *data = (void *)(long)skb->data;
+	struct eth_hdr *eth = data;
+	void *data_end = (void *)(long)skb->data_end;
+	int key = 0, *ifindex;
+
+	int ret;
+
+	if (data + sizeof(*eth) > data_end)
+		return TC_ACT_OK;
+
+	ifindex = bpf_map_lookup_elem(&tun_iface, &key);
+	if (!ifindex)
+		return TC_ACT_OK;
+
+	if (eth->h_proto == htons(ETH_P_IP)) {
+		char fmt4[] = "e/ingress redirect daddr4:%x to ifindex:%d\n";
+		struct iphdr *iph = data + sizeof(*eth);
+		__be32 daddr = iph->daddr;
+
+		if (data + sizeof(*eth) + sizeof(*iph) > data_end)
+			return TC_ACT_OK;
+
+		if (!is_vip_addr(eth->h_proto, daddr))
+			return TC_ACT_OK;
+
+		bpf_trace_printk(fmt4, sizeof(fmt4), _htonl(daddr), *ifindex);
+	} else {
+		return TC_ACT_OK;
+	}
+
+	tkey.tunnel_id = 10000;
+	tkey.tunnel_ttl = 64;
+	tkey.remote_ipv4 = 0x0a020166; /* 10.2.1.102 */
+	bpf_skb_set_tunnel_key(skb, &tkey, sizeof(tkey), 0);
+	return bpf_redirect(*ifindex, 0);
+}
+
+SEC("l2_to_ip6tun_ingress_redirect")
+int _l2_to_ip6tun_ingress_redirect(struct __sk_buff *skb)
+{
+	struct bpf_tunnel_key tkey = {};
+	void *data = (void *)(long)skb->data;
+	struct eth_hdr *eth = data;
+	void *data_end = (void *)(long)skb->data_end;
+	int key = 0, *ifindex;
+
+	if (data + sizeof(*eth) > data_end)
+		return TC_ACT_OK;
+
+	ifindex = bpf_map_lookup_elem(&tun_iface, &key);
+	if (!ifindex)
+		return TC_ACT_OK;
+
+	if (eth->h_proto == htons(ETH_P_IP)) {
+		char fmt4[] = "e/ingress redirect daddr4:%x to ifindex:%d\n";
+		struct iphdr *iph = data + sizeof(*eth);
+
+		if (data + sizeof(*eth) + sizeof(*iph) > data_end)
+			return TC_ACT_OK;
+
+		if (!is_vip_addr(eth->h_proto, iph->daddr))
+			return TC_ACT_OK;
+
+		bpf_trace_printk(fmt4, sizeof(fmt4), _htonl(iph->daddr),
+				 *ifindex);
+	} else if (eth->h_proto == htons(ETH_P_IPV6)) {
+		char fmt6[] = "e/ingress redirect daddr6:%x to ifindex:%d\n";
+		struct ipv6hdr *ip6h = data + sizeof(*eth);
+
+		if (data + sizeof(*eth) + sizeof(*ip6h) > data_end)
+			return TC_ACT_OK;
+
+		if (!is_vip_addr(eth->h_proto, ip6h->daddr.s6_addr32[0]))
+			return TC_ACT_OK;
+
+		bpf_trace_printk(fmt6, sizeof(fmt6),
+				 _htonl(ip6h->daddr.s6_addr32[0]), *ifindex);
+	} else {
+		return TC_ACT_OK;
+	}
+
+	tkey.tunnel_id = 10000;
+	tkey.tunnel_ttl = 64;
+	/* 2401:db02:0:0:0:0:0:66 */
+	tkey.remote_ipv6[0] = _htonl(0x2401db02);
+	tkey.remote_ipv6[1] = 0;
+	tkey.remote_ipv6[2] = 0;
+	tkey.remote_ipv6[3] = _htonl(0x00000066);
+	bpf_skb_set_tunnel_key(skb, &tkey, sizeof(tkey), BPF_F_TUNINFO_IPV6);
+	return bpf_redirect(*ifindex, 0);
+}
+
+SEC("drop_non_tun_vip")
+int _drop_non_tun_vip(struct __sk_buff *skb)
+{
+	struct bpf_tunnel_key tkey = {};
+	void *data = (void *)(long)skb->data;
+	struct eth_hdr *eth = data;
+	void *data_end = (void *)(long)skb->data_end;
+
+	if (data + sizeof(*eth) > data_end)
+		return TC_ACT_OK;
+
+	if (eth->h_proto == htons(ETH_P_IP)) {
+		struct iphdr *iph = data + sizeof(*eth);
+
+		if (data + sizeof(*eth) + sizeof(*iph) > data_end)
+			return TC_ACT_OK;
+
+		if (is_vip_addr(eth->h_proto, iph->daddr))
+			return TC_ACT_SHOT;
+	} else if (eth->h_proto == htons(ETH_P_IPV6)) {
+		struct ipv6hdr *ip6h = data + sizeof(*eth);
+
+		if (data + sizeof(*eth) + sizeof(*ip6h) > data_end)
+			return TC_ACT_OK;
+
+		if (is_vip_addr(eth->h_proto, ip6h->daddr.s6_addr32[0]))
+			return TC_ACT_SHOT;
+	}
+
+	return TC_ACT_OK;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/tc_l2_redirect_user.c b/samples/bpf/tc_l2_redirect_user.c
new file mode 100644
index 0000000..4013c53
--- /dev/null
+++ b/samples/bpf/tc_l2_redirect_user.c
@@ -0,0 +1,73 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/unistd.h>
+#include <linux/bpf.h>
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <string.h>
+#include <errno.h>
+
+#include "libbpf.h"
+
+static void usage(void)
+{
+	printf("Usage: tc_l2_ipip_redirect [...]\n");
+	printf("       -U <file>   Update an already pinned BPF array\n");
+	printf("       -i <ifindex> Interface index\n");
+	printf("       -h          Display this help\n");
+}
+
+int main(int argc, char **argv)
+{
+	const char *pinned_file = NULL;
+	int ifindex = -1;
+	int array_key = 0;
+	int array_fd = -1;
+	int ret = -1;
+	int opt;
+
+	while ((opt = getopt(argc, argv, "F:U:i:")) != -1) {
+		switch (opt) {
+		/* General args */
+		case 'U':
+			pinned_file = optarg;
+			break;
+		case 'i':
+			ifindex = atoi(optarg);
+			break;
+		default:
+			usage();
+			goto out;
+		}
+	}
+
+	if (ifindex < 0 || !pinned_file) {
+		usage();
+		goto out;
+	}
+
+	array_fd = bpf_obj_get(pinned_file);
+	if (array_fd < 0) {
+		fprintf(stderr, "bpf_obj_get(%s): %s(%d)\n",
+			pinned_file, strerror(errno), errno);
+		goto out;
+	}
+
+	/* bpf_tunnel_key.remote_ipv4 expects host byte orders */
+	ret = bpf_update_elem(array_fd, &array_key, &ifindex, 0);
+	if (ret) {
+		perror("bpf_update_elem");
+		goto out;
+	}
+
+out:
+	if (array_fd != -1)
+		close(array_fd);
+	return ret;
+}
-- 
2.5.1
