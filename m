From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 4/4] bpf: Add samples for LWT-BPF
Date: Sun, 30 Oct 2016 12:58:05 +0100
Message-ID: <943e6947ceb48ef797636fa37cfe08b630377626.1477827877.git.tgraf@suug.ch>
References: <cover.1477827877.git.tgraf@suug.ch>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        tom@herbertland.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:50762 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753776AbcJ3L6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 07:58:21 -0400
In-Reply-To: <cover.1477827877.git.tgraf@suug.ch>
In-Reply-To: <cover.1477827877.git.tgraf@suug.ch>
References: <cover.1477827877.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a set of samples demonstrating the use of lwt-bpf combined
with a shell script which allows running the samples in the form of
a basic selftest.

The samples include:
 - Allowing all packets
 - Dropping all packets
 - Printing context information
 - Access packet data
 - IPv4 daddr rewrite in dst_output()
 - L2 MAC header push + redirect in lwt xmit

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 samples/bpf/bpf_helpers.h   |   4 +
 samples/bpf/lwt_bpf.c       | 210 +++++++++++++++++++++++++++
 samples/bpf/test_lwt_bpf.sh | 337 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 551 insertions(+)
 create mode 100644 samples/bpf/lwt_bpf.c
 create mode 100755 samples/bpf/test_lwt_bpf.sh

diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 90f44bd..f34e417 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -80,6 +80,8 @@ struct bpf_map_def {
 	unsigned int map_flags;
 };
 
+static int (*bpf_skb_load_bytes)(void *ctx, int off, void *to, int len) =
+	(void *) BPF_FUNC_skb_load_bytes;
 static int (*bpf_skb_store_bytes)(void *ctx, int off, void *from, int len, int flags) =
 	(void *) BPF_FUNC_skb_store_bytes;
 static int (*bpf_l3_csum_replace)(void *ctx, int off, int from, int to, int flags) =
@@ -88,6 +90,8 @@ static int (*bpf_l4_csum_replace)(void *ctx, int off, int from, int to, int flag
 	(void *) BPF_FUNC_l4_csum_replace;
 static int (*bpf_skb_under_cgroup)(void *ctx, void *map, int index) =
 	(void *) BPF_FUNC_skb_under_cgroup;
+static int (*bpf_skb_push)(void *, int len, int flags) =
+	(void *) BPF_FUNC_skb_push;
 
 #if defined(__x86_64__)
 
diff --git a/samples/bpf/lwt_bpf.c b/samples/bpf/lwt_bpf.c
new file mode 100644
index 0000000..05be6ac
--- /dev/null
+++ b/samples/bpf/lwt_bpf.c
@@ -0,0 +1,210 @@
+/* Copyright (c) 2016 Thomas Graf <tgraf@tgraf.ch>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+
+#include <stdint.h>
+#include <stddef.h>
+#include <linux/bpf.h>
+#include <linux/ip.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/icmpv6.h>
+#include <linux/if_ether.h>
+#include "bpf_helpers.h"
+#include <string.h>
+
+# define printk(fmt, ...)						\
+		({							\
+			char ____fmt[] = fmt;				\
+			bpf_trace_printk(____fmt, sizeof(____fmt),	\
+				     ##__VA_ARGS__);			\
+		})
+
+#define CB_MAGIC 1234
+
+/* Let all packets pass */
+SEC("nop")
+int do_nop(struct __sk_buff *skb)
+{
+	return BPF_OK;
+}
+
+/* Print some context information per packet to tracing buffer.
+ */
+SEC("ctx_test")
+int do_ctx_test(struct __sk_buff *skb)
+{
+	skb->cb[0] = CB_MAGIC;
+	printk("len %d hash %d protocol %d\n", skb->len, skb->hash,
+	       skb->protocol);
+	printk("cb %d ingress_ifindex %d ifindex %d\n", skb->cb[0],
+	       skb->ingress_ifindex, skb->ifindex);
+
+	return BPF_OK;
+}
+
+/* Print content of skb->cb[] to tracing buffer */
+SEC("print_cb")
+int do_print_cb(struct __sk_buff *skb)
+{
+	printk("cb0: %x cb1: %x cb2: %x\n", skb->cb[0], skb->cb[1],
+	       skb->cb[2]);
+	printk("cb3: %x cb4: %x\n", skb->cb[3], skb->cb[4]);
+
+	return BPF_OK;
+}
+
+/* Print source and destination IPv4 address to tracing buffer */
+SEC("data_test")
+int do_data_test(struct __sk_buff *skb)
+{
+	void *data = (void *)(long)skb->data;
+	void *data_end = (void *)(long)skb->data_end;
+	struct iphdr *iph = data;
+
+	if (data + sizeof(*iph) > data_end) {
+		printk("packet truncated\n");
+		return BPF_DROP;
+	}
+
+	printk("src: %x dst: %x\n", iph->saddr, iph->daddr);
+
+	return BPF_OK;
+}
+
+#define IP_CSUM_OFF offsetof(struct iphdr, check)
+#define IP_DST_OFF offsetof(struct iphdr, daddr)
+#define IP_SRC_OFF offsetof(struct iphdr, saddr)
+#define IP_PROTO_OFF offsetof(struct iphdr, protocol)
+#define TCP_CSUM_OFF offsetof(struct tcphdr, check)
+#define UDP_CSUM_OFF offsetof(struct udphdr, check)
+#define IS_PSEUDO 0x10
+
+static inline int rewrite(struct __sk_buff *skb, uint32_t old_ip,
+			  uint32_t new_ip, int rw_daddr)
+{
+	int ret, off = 0, flags = IS_PSEUDO;
+	uint8_t proto;
+
+	ret = bpf_skb_load_bytes(skb, IP_PROTO_OFF, &proto, 1);
+	if (ret < 0) {
+		printk("bpf_l4_csum_replace failed: %d\n", ret);
+		return BPF_DROP;
+	}
+
+	switch (proto) {
+	case IPPROTO_TCP:
+		off = TCP_CSUM_OFF;
+		break;
+
+	case IPPROTO_UDP:
+		off = UDP_CSUM_OFF;
+		flags |= BPF_F_MARK_MANGLED_0;
+		break;
+
+	case IPPROTO_ICMPV6:
+		off = offsetof(struct icmp6hdr, icmp6_cksum);
+		break;
+	}
+
+	if (off) {
+		ret = bpf_l4_csum_replace(skb, off, old_ip, new_ip,
+					  flags | sizeof(new_ip));
+		if (ret < 0) {
+			printk("bpf_l4_csum_replace failed: %d\n");
+			return BPF_DROP;
+		}
+	}
+
+	ret = bpf_l3_csum_replace(skb, IP_CSUM_OFF, old_ip, new_ip, sizeof(new_ip));
+	if (ret < 0) {
+		printk("bpf_l3_csum_replace failed: %d\n", ret);
+		return BPF_DROP;
+	}
+
+	if (rw_daddr)
+		ret = bpf_skb_store_bytes(skb, IP_DST_OFF, &new_ip, sizeof(new_ip), 0);
+	else
+		ret = bpf_skb_store_bytes(skb, IP_SRC_OFF, &new_ip, sizeof(new_ip), 0);
+
+	if (ret < 0) {
+		printk("bpf_skb_store_bytes() failed: %d\n", ret);
+		return BPF_DROP;
+	}
+
+	return BPF_OK;
+}
+
+/* Rewrite IPv4 destination address from 192.168.254.2 to 192.168.254.3 */
+SEC("rw_out")
+int do_rw_out(struct __sk_buff *skb)
+{
+	uint32_t old_ip, new_ip = 0x3fea8c0;
+	int ret;
+
+	ret = bpf_skb_load_bytes(skb, IP_DST_OFF, &old_ip, 4);
+	if (ret < 0) {
+		printk("bpf_skb_load_bytes failed: %d\n", ret);
+		return BPF_DROP;
+	}
+
+	if (old_ip == 0x2fea8c0) {
+		printk("out: rewriting from %x to %x\n", old_ip, new_ip);
+		return rewrite(skb, old_ip, new_ip, 1);
+	}
+
+	return BPF_OK;
+}
+
+SEC("redirect")
+int do_redirect(struct __sk_buff *skb)
+{
+	uint64_t smac = SRC_MAC, dmac = DST_MAC;
+	int ret, ifindex = DST_IFINDEX;
+	struct ethhdr ehdr;
+
+	ret = bpf_skb_push(skb, 14, 0);
+	if (ret < 0) {
+		printk("skb_push() failed: %d\n", ret);
+	}
+
+	ehdr.h_proto = __constant_htons(ETH_P_IP);
+	memcpy(&ehdr.h_source, &smac, 6);
+	memcpy(&ehdr.h_dest, &dmac, 6);
+
+	ret = bpf_skb_store_bytes(skb, 0, &ehdr, sizeof(ehdr), 0);
+	if (ret < 0) {
+		printk("skb_store_bytes() failed: %d\n", ret);
+		return BPF_DROP;
+	}
+
+	ret = bpf_redirect(ifindex, 0);
+	if (ret < 0) {
+		printk("bpf_redirect() failed: %d\n", ret);
+		return BPF_DROP;
+	}
+
+	printk("redirected to %d\n", ifindex);
+
+	return BPF_REDIRECT;
+}
+
+/* Drop all packets */
+SEC("drop_all")
+int do_drop_all(struct __sk_buff *skb)
+{
+	printk("dropping with: %d\n", BPF_DROP);
+	return BPF_DROP;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/test_lwt_bpf.sh b/samples/bpf/test_lwt_bpf.sh
new file mode 100755
index 0000000..ea4921a
--- /dev/null
+++ b/samples/bpf/test_lwt_bpf.sh
@@ -0,0 +1,337 @@
+#!/bin/bash
+
+# Uncomment to see generated bytecode
+#VERBOSE=verbose
+
+NS=lwt_ns
+VETH0=tst_lwt0
+VETH1=tst_lwt1
+IP4_1="192.168.254.1"
+IP4_2="192.168.254.2"
+IP4_3="192.168.254.3"
+IP4_4="192.168.254.4"
+
+TRACE_ROOT=/sys/kernel/debug/tracing
+
+function hton_mac()
+{
+	MAC="${1//:/}"
+	echo "0x${MAC:10:2}${MAC:8:2}${MAC:6:2}${MAC:4:2}${MAC:2:2}${MAC:0:2}"
+}
+
+function lookup_mac()
+{
+	set +x
+	if [ ! -z "$2" ]; then
+		MAC=$(ip netns exec $2 ip link show $1 | grep ether | awk '{print $2}')
+	else
+		MAC=$(ip link show $1 | grep ether | awk '{print $2}')
+	fi
+	echo $(hton_mac $MAC)
+	set -x
+}
+
+function cleanup {
+        set +ex
+        rm lwt_bpf.o 2> /dev/null
+        ip link del $VETH0 2> /dev/null
+        ip netns delete $NS 2> /dev/null
+        set -ex
+}
+
+function setup_veth {
+        ip netns add $NS
+
+        ip link add $VETH0 type veth peer name $VETH1
+
+        ip link set dev $VETH0 up
+        ip addr add ${IP4_1}/24 dev $VETH0
+
+        ip link set $VETH1 netns $NS
+        ip netns exec $NS ip link set dev $VETH1 up
+        ip netns exec $NS ip addr add ${IP4_2}/24 dev $VETH1
+        ip netns exec $NS ip addr add ${IP4_3}/32 dev $VETH1
+
+        echo 1 > ${TRACE_ROOT}/tracing_on
+}
+
+function get_trace {
+	set +x
+        cat ${TRACE_ROOT}/trace | grep -v '^#'
+	set -x
+}
+
+function install_prog {
+	ip route del ${IP4_2}/32 dev $VETH0 2> /dev/null || true
+	ip route del table local local ${IP4_4}/32 dev lo 2> /dev/null || true
+	cp /dev/null ${TRACE_ROOT}/trace
+
+	OPTS="encap bpf $1 obj lwt_bpf.o section $2 $VERBOSE"
+
+	if [ "$1" == "in" ];  then
+		ip route add table local local ${IP4_4}/32 $OPTS dev lo
+	else
+		ip route add ${IP4_2}/32 $OPTS dev $VETH0
+	fi
+}
+
+function remove_prog {
+	if [ "$1" == "in" ];  then
+		ip route del table local local ${IP4_4}/32 dev lo
+	else
+		ip route del ${IP4_2}/32 dev $VETH0
+	fi
+}
+
+function filter_trace {
+	# Add newline to allow starting EXPECT= variables on newline
+	NL=$'\n'
+	echo "${NL}$*" | sed -e 's/^.*: : //g'
+}
+
+function expect_fail {
+	set +x
+	echo "FAIL:"
+	echo "Expected: $1"
+	echo "Got: $2"
+	set -x
+	exit 1
+}
+
+function match_trace {
+	set +x
+	RET=0
+	TRACE=$1
+	EXPECT=$2
+	GOT="$(filter_trace "$TRACE")"
+
+	[ "$GOT" != "$EXPECT" ] && {
+		expect_fail "$EXPECT" "$GOT"
+		RET=1
+	}
+	set -x
+	return $RET
+}
+
+function test_start {
+	set +x
+	echo "----------------------------------------------------------------"
+	echo "Starting test: $*"
+	echo "----------------------------------------------------------------"
+	set -x
+}
+
+function failure {
+	get_trace
+	echo "FAIL: $*"
+	exit 1
+}
+
+function test_ctx_xmit {
+	test_start "test_ctx on lwt xmit"
+	install_prog xmit ctx_test
+	ping -c 3 $IP4_2 || {
+		failure "test_ctx xmit: packets are dropped"
+	}
+	match_trace "$(get_trace)" "
+len 84 hash 0 protocol 8
+cb 1234 ingress_ifindex 0 ifindex $DST_IFINDEX
+len 84 hash 0 protocol 8
+cb 1234 ingress_ifindex 0 ifindex $DST_IFINDEX
+len 84 hash 0 protocol 8
+cb 1234 ingress_ifindex 0 ifindex $DST_IFINDEX" || exit 1
+	remove_prog xmit
+}
+
+function test_ctx_out {
+	test_start "test_ctx on lwt out"
+	install_prog out ctx_test
+	ping -c 3 $IP4_2 || {
+		failure "test_ctx out: packets are dropped"
+	}
+	match_trace "$(get_trace)" "
+len 84 hash 0 protocol 0
+cb 1234 ingress_ifindex 0 ifindex 0
+len 84 hash 0 protocol 0
+cb 1234 ingress_ifindex 0 ifindex 0
+len 84 hash 0 protocol 0
+cb 1234 ingress_ifindex 0 ifindex 0" || exit 1
+	remove_prog out
+}
+
+function test_ctx_in {
+	test_start "test_ctx on lwt in"
+	install_prog in ctx_test
+	ping -c 3 $IP4_4 || {
+		failure "test_ctx out: packets are dropped"
+	}
+	# We will both request & reply packets as the packets will
+	# be from $IP4_4 => $IP4_4
+	match_trace "$(get_trace)" "
+len 84 hash 0 protocol 8
+cb 1234 ingress_ifindex 1 ifindex 1
+len 84 hash 0 protocol 8
+cb 1234 ingress_ifindex 1 ifindex 1
+len 84 hash 0 protocol 8
+cb 1234 ingress_ifindex 1 ifindex 1
+len 84 hash 0 protocol 8
+cb 1234 ingress_ifindex 1 ifindex 1
+len 84 hash 0 protocol 8
+cb 1234 ingress_ifindex 1 ifindex 1
+len 84 hash 0 protocol 8
+cb 1234 ingress_ifindex 1 ifindex 1" || exit 1
+	remove_prog in
+}
+
+function test_data {
+	test_start "test_data on lwt $1"
+	install_prog $1 data_test
+	ping -c 3 $IP4_2 || {
+		failure "test_data ${1}: packets are dropped"
+	}
+	match_trace "$(get_trace)" "
+src: 1fea8c0 dst: 2fea8c0
+src: 1fea8c0 dst: 2fea8c0
+src: 1fea8c0 dst: 2fea8c0" || exit 1
+	remove_prog $1
+}
+
+function test_data_in {
+	test_start "test_data on lwt in"
+	install_prog in data_test
+	ping -c 3 $IP4_4 || {
+		failure "test_data in: packets are dropped"
+	}
+	# We will both request & reply packets as the packets will
+	# be from $IP4_4 => $IP4_4
+	match_trace "$(get_trace)" "
+src: 4fea8c0 dst: 4fea8c0
+src: 4fea8c0 dst: 4fea8c0
+src: 4fea8c0 dst: 4fea8c0
+src: 4fea8c0 dst: 4fea8c0
+src: 4fea8c0 dst: 4fea8c0
+src: 4fea8c0 dst: 4fea8c0" || exit 1
+	remove_prog in
+}
+
+function test_cb {
+	test_start "test_cb on lwt $1"
+	install_prog $1 print_cb
+	ping -c 3 $IP4_2 || {
+		failure "test_cb ${1}: packets are dropped"
+	}
+	match_trace "$(get_trace)" "
+cb0: 0 cb1: 0 cb2: 0
+cb3: 0 cb4: 0
+cb0: 0 cb1: 0 cb2: 0
+cb3: 0 cb4: 0
+cb0: 0 cb1: 0 cb2: 0
+cb3: 0 cb4: 0" || exit 1
+	remove_prog $1
+}
+
+function test_cb_in {
+	test_start "test_cb on lwt in"
+	install_prog in print_cb
+	ping -c 3 $IP4_4 || {
+		failure "test_cb in: packets are dropped"
+	}
+	# We will both request & reply packets as the packets will
+	# be from $IP4_4 => $IP4_4
+	match_trace "$(get_trace)" "
+cb0: 0 cb1: 0 cb2: 0
+cb3: 0 cb4: 0
+cb0: 0 cb1: 0 cb2: 0
+cb3: 0 cb4: 0
+cb0: 0 cb1: 0 cb2: 0
+cb3: 0 cb4: 0
+cb0: 0 cb1: 0 cb2: 0
+cb3: 0 cb4: 0
+cb0: 0 cb1: 0 cb2: 0
+cb3: 0 cb4: 0
+cb0: 0 cb1: 0 cb2: 0
+cb3: 0 cb4: 0" || exit 1
+	remove_prog in
+}
+
+function test_drop_all {
+	test_start "test_drop_all on lwt $1"
+	install_prog $1 drop_all
+	ping -c 3 $IP4_2 && {
+		failure "test_drop_all ${1}: Unexpected success of ping"
+	}
+	match_trace "$(get_trace)" "
+dropping with: 2
+dropping with: 2
+dropping with: 2" || exit 1
+	remove_prog $1
+}
+
+function test_drop_all_in {
+	test_start "test_drop_all on lwt in"
+	install_prog in drop_all
+	ping -c 3 $IP4_4 && {
+		failure "test_drop_all in: Unexpected success of ping"
+	}
+	match_trace "$(get_trace)" "
+dropping with: 2
+dropping with: 2
+dropping with: 2" || exit 1
+	remove_prog in
+}
+
+function test_redirect_xmit {
+	test_start "test_redirect on lwt xmit"
+	install_prog xmit redirect
+	ping -c 3 $IP4_2 || {
+		failure "Redirected packets appear to be dropped"
+	}
+	match_trace "$(get_trace)" "
+redirected to $DST_IFINDEX
+redirected to $DST_IFINDEX
+redirected to $DST_IFINDEX" || exit 1
+	remove_prog xmit
+}
+
+function test_rw_out {
+	test_start "test_rw on lwt out"
+	install_prog out rw_out
+	ping -c 3 $IP4_2 || {
+		failure "FAIL: Redirected packets appear to be dropped"
+	}
+	match_trace "$(get_trace)" "
+redirected to $DST_IFINDEX
+redirected to $DST_IFINDEX
+redirected to $DST_IFINDEX" || exit 1
+	remove_prog out
+}
+
+cleanup
+setup_veth
+
+DST_MAC=$(lookup_mac $VETH1 $NS)
+SRC_MAC=$(lookup_mac $VETH0)
+DST_IFINDEX=$(cat /sys/class/net/$VETH0/ifindex)
+
+CLANG_OPTS="-O2 -target bpf -I ../include/"
+CLANG_OPTS+=" -DSRC_MAC=$SRC_MAC -DDST_MAC=$DST_MAC -DDST_IFINDEX=$DST_IFINDEX"
+clang $CLANG_OPTS -c lwt_bpf.c -o lwt_bpf.o
+
+test_ctx_xmit
+test_ctx_out
+test_ctx_in
+test_data "xmit"
+test_data "out"
+test_data_in
+test_cb "xmit"
+test_cb "out"
+test_cb_in
+test_drop_all "xmit"
+test_drop_all "out"
+test_drop_all_in
+test_redirect_xmit
+test_rw_out
+
+cleanup
+echo 0 > ${TRACE_ROOT}/tracing_on
+exit 0
-- 
2.7.4
