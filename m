From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v3 4/4] bpf: Add tests and samples for LWT-BPF
Date: Tue, 29 Nov 2016 14:21:23 +0100
Message-ID: <25a6f8d0d56175bb27a05c18eb54bc3bc5c09fa1.1480424542.git.tgraf@suug.ch>
References: <cover.1480424542.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com,
        roopa@cumulusnetworks.com, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38932 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757467AbcK2NVi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 08:21:38 -0500
In-Reply-To: <cover.1480424542.git.tgraf@suug.ch>
In-Reply-To: <cover.1480424542.git.tgraf@suug.ch>
References: <cover.1480424542.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a series of test to verify the functionality of attaching
BPF programs at LWT hooks.

Also adds a sample which collects a histogram of packet sizes which
pass through an LWT hook.

$ ./lwt_len_hist.sh
Starting netserver with host 'IN(6)ADDR_ANY' port '12865' and family AF_UNSPEC
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.253.2 () port 0 AF_INET : demo
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    39857.69
       1 -> 1        : 0        |                                      |
       2 -> 3        : 0        |                                      |
       4 -> 7        : 0        |                                      |
       8 -> 15       : 0        |                                      |
      16 -> 31       : 0        |                                      |
      32 -> 63       : 22       |                                      |
      64 -> 127      : 98       |                                      |
     128 -> 255      : 213      |                                      |
     256 -> 511      : 1444251  |********                              |
     512 -> 1023     : 660610   |***                                   |
    1024 -> 2047     : 535241   |**                                    |
    2048 -> 4095     : 19       |                                      |
    4096 -> 8191     : 180      |                                      |
    8192 -> 16383    : 5578023  |************************************* |
   16384 -> 32767    : 632099   |***                                   |
   32768 -> 65535    : 6575     |                                      |

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 samples/bpf/Makefile            |   4 +
 samples/bpf/bpf_helpers.h       |   4 +
 samples/bpf/lwt_len_hist.sh     |  37 ++++
 samples/bpf/lwt_len_hist_kern.c |  82 +++++++++
 samples/bpf/lwt_len_hist_user.c |  76 ++++++++
 samples/bpf/test_lwt_bpf.c      | 247 ++++++++++++++++++++++++++
 samples/bpf/test_lwt_bpf.sh     | 385 ++++++++++++++++++++++++++++++++++++++++
 7 files changed, 835 insertions(+)
 create mode 100755 samples/bpf/lwt_len_hist.sh
 create mode 100644 samples/bpf/lwt_len_hist_kern.c
 create mode 100644 samples/bpf/lwt_len_hist_user.c
 create mode 100644 samples/bpf/test_lwt_bpf.c
 create mode 100755 samples/bpf/test_lwt_bpf.sh

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 22b6407e..3161f82 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -29,6 +29,7 @@ hostprogs-y += test_current_task_under_cgroup
 hostprogs-y += trace_event
 hostprogs-y += sampleip
 hostprogs-y += tc_l2_redirect
+hostprogs-y += lwt_len_hist
 
 test_lru_dist-objs := test_lru_dist.o libbpf.o
 sock_example-objs := sock_example.o libbpf.o
@@ -59,6 +60,7 @@ test_current_task_under_cgroup-objs := bpf_load.o libbpf.o \
 trace_event-objs := bpf_load.o libbpf.o trace_event_user.o
 sampleip-objs := bpf_load.o libbpf.o sampleip_user.o
 tc_l2_redirect-objs := bpf_load.o libbpf.o tc_l2_redirect_user.o
+lwt_len_hist-objs := bpf_load.o libbpf.o lwt_len_hist_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -89,6 +91,7 @@ always += xdp2_kern.o
 always += test_current_task_under_cgroup_kern.o
 always += trace_event_kern.o
 always += sampleip_kern.o
+always += lwt_len_hist_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(objtree)/tools/testing/selftests/bpf/
@@ -117,6 +120,7 @@ HOSTLOADLIBES_test_current_task_under_cgroup += -lelf
 HOSTLOADLIBES_trace_event += -lelf
 HOSTLOADLIBES_sampleip += -lelf
 HOSTLOADLIBES_tc_l2_redirect += -l elf
+HOSTLOADLIBES_lwt_len_hist += -l elf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
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
 
diff --git a/samples/bpf/lwt_len_hist.sh b/samples/bpf/lwt_len_hist.sh
new file mode 100755
index 0000000..3a8ee52
--- /dev/null
+++ b/samples/bpf/lwt_len_hist.sh
@@ -0,0 +1,37 @@
+#!/bin/bash
+
+NS1=lwt_ns1
+VETH0=tst_lwt1a
+VETH1=tst_lwt1b
+
+TRACE_ROOT=/sys/kernel/debug/tracing
+
+function cleanup {
+        ip route del 192.168.253.2/32 dev $VETH0 2> /dev/null
+        ip link del $VETH0 2> /dev/null
+        ip link del $VETH1 2> /dev/null
+	ip netns exec $NS1 killall netserver
+        ip netns delete $NS1 2> /dev/null
+}
+
+cleanup
+
+ip netns add $NS1
+ip link add $VETH0 type veth peer name $VETH1
+ip link set dev $VETH0 up
+ip addr add 192.168.253.1/24 dev $VETH0
+ip link set $VETH1 netns $NS1
+ip netns exec $NS1 ip link set dev $VETH1 up
+ip netns exec $NS1 ip addr add 192.168.253.2/24 dev $VETH1
+ip netns exec $NS1 netserver
+
+echo 1 > ${TRACE_ROOT}/tracing_on
+cp /dev/null ${TRACE_ROOT}/trace
+ip route add 192.168.253.2/32 encap bpf out obj lwt_len_hist_kern.o section len_hist dev $VETH0
+netperf -H 192.168.253.2 -t TCP_STREAM
+cat ${TRACE_ROOT}/trace | grep -v '^#'
+./lwt_len_hist
+cleanup
+echo 0 > ${TRACE_ROOT}/tracing_on
+
+exit 0
diff --git a/samples/bpf/lwt_len_hist_kern.c b/samples/bpf/lwt_len_hist_kern.c
new file mode 100644
index 0000000..df75383
--- /dev/null
+++ b/samples/bpf/lwt_len_hist_kern.c
@@ -0,0 +1,82 @@
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
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/ip.h>
+#include <uapi/linux/in.h>
+#include "bpf_helpers.h"
+
+# define printk(fmt, ...)						\
+		({							\
+			char ____fmt[] = fmt;				\
+			bpf_trace_printk(____fmt, sizeof(____fmt),	\
+				     ##__VA_ARGS__);			\
+		})
+
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
+struct bpf_elf_map SEC("maps") lwt_len_hist_map = {
+	.type = BPF_MAP_TYPE_PERCPU_HASH,
+	.size_key = sizeof(__u64),
+	.size_value = sizeof(__u64),
+	.pinning = 2,
+	.max_elem = 1024,
+};
+
+static unsigned int log2(unsigned int v)
+{
+	unsigned int r;
+	unsigned int shift;
+
+	r = (v > 0xFFFF) << 4; v >>= r;
+	shift = (v > 0xFF) << 3; v >>= shift; r |= shift;
+	shift = (v > 0xF) << 2; v >>= shift; r |= shift;
+	shift = (v > 0x3) << 1; v >>= shift; r |= shift;
+	r |= (v >> 1);
+	return r;
+}
+
+static unsigned int log2l(unsigned long v)
+{
+	unsigned int hi = v >> 32;
+	if (hi)
+		return log2(hi) + 32;
+	else
+		return log2(v);
+}
+
+SEC("len_hist")
+int do_len_hist(struct __sk_buff *skb)
+{
+	__u64 *value, key, init_val = 1;
+
+	key = log2l(skb->len);
+
+	value = bpf_map_lookup_elem(&lwt_len_hist_map, &key);
+	if (value)
+		__sync_fetch_and_add(value, 1);
+	else
+		bpf_map_update_elem(&lwt_len_hist_map, &key, &init_val, BPF_ANY);
+
+	return BPF_OK;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/lwt_len_hist_user.c b/samples/bpf/lwt_len_hist_user.c
new file mode 100644
index 0000000..05d783f
--- /dev/null
+++ b/samples/bpf/lwt_len_hist_user.c
@@ -0,0 +1,76 @@
+#include <linux/unistd.h>
+#include <linux/bpf.h>
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <string.h>
+#include <errno.h>
+#include <arpa/inet.h>
+
+#include "libbpf.h"
+#include "bpf_util.h"
+
+#define MAX_INDEX 64
+#define MAX_STARS 38
+
+static void stars(char *str, long val, long max, int width)
+{
+	int i;
+
+	for (i = 0; i < (width * val / max) - 1 && i < width - 1; i++)
+		str[i] = '*';
+	if (val > max)
+		str[i - 1] = '+';
+	str[i] = '\0';
+}
+
+int main(int argc, char **argv)
+{
+	unsigned int nr_cpus = bpf_num_possible_cpus();
+	const char *map_filename = "/sys/fs/bpf/tc/globals/lwt_len_hist_map";
+	uint64_t values[nr_cpus], sum, max_value = 0, data[MAX_INDEX] = {};
+	uint64_t key = 0, next_key, max_key = 0;
+	char starstr[MAX_STARS];
+	int i, map_fd;
+
+	map_fd = bpf_obj_get(map_filename);
+	if (map_fd < 0) {
+		fprintf(stderr, "bpf_obj_get(%s): %s(%d)\n",
+			map_filename, strerror(errno), errno);
+		return -1;
+	}
+
+	while (bpf_get_next_key(map_fd, &key, &next_key) == 0) {
+		if (next_key >= MAX_INDEX) {
+			fprintf(stderr, "Key %lu out of bounds\n", next_key);
+			continue;
+		}
+
+		bpf_lookup_elem(map_fd, &next_key, values);
+
+		sum = 0;
+		for (i = 0; i < nr_cpus; i++)
+			sum += values[i];
+
+		data[next_key] = sum;
+		if (sum && next_key > max_key)
+			max_key = next_key;
+
+		if (sum > max_value)
+			max_value = sum;
+
+		key = next_key;
+	}
+
+	for (i = 1; i <= max_key + 1; i++) {
+		stars(starstr, data[i - 1], max_value, MAX_STARS);
+		printf("%8ld -> %-8ld : %-8ld |%-*s|\n",
+		       (1l << i) >> 1, (1l << i) - 1, data[i - 1],
+		       MAX_STARS, starstr);
+	}
+
+	close(map_fd);
+
+	return 0;
+}
diff --git a/samples/bpf/test_lwt_bpf.c b/samples/bpf/test_lwt_bpf.c
new file mode 100644
index 0000000..9c1773e
--- /dev/null
+++ b/samples/bpf/test_lwt_bpf.c
@@ -0,0 +1,247 @@
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
+/* Test: Pass all packets through */
+SEC("nop")
+int do_nop(struct __sk_buff *skb)
+{
+	return BPF_OK;
+}
+
+/* Test: Verify context information can be accessed */
+SEC("test_ctx")
+int do_test_ctx(struct __sk_buff *skb)
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
+/* Test: Ensure skb->cb[] buffer is cleared */
+SEC("test_cb")
+int do_test_cb(struct __sk_buff *skb)
+{
+	printk("cb0: %x cb1: %x cb2: %x\n", skb->cb[0], skb->cb[1],
+	       skb->cb[2]);
+	printk("cb3: %x cb4: %x\n", skb->cb[3], skb->cb[4]);
+
+	return BPF_OK;
+}
+
+/* Test: Verify skb data can be read */
+SEC("test_data")
+int do_test_data(struct __sk_buff *skb)
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
+/* Test: Verify skb data can be modified */
+SEC("test_rewrite")
+int do_test_rewrite(struct __sk_buff *skb)
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
+static inline int __do_push_ll_and_redirect(struct __sk_buff *skb)
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
+	return BPF_REDIRECT;
+}
+
+SEC("push_ll_and_redirect_silent")
+int do_push_ll_and_redirect_silent(struct __sk_buff *skb)
+{
+	return __do_push_ll_and_redirect(skb);
+}
+
+SEC("push_ll_and_redirect")
+int do_push_ll_and_redirect(struct __sk_buff *skb)
+{
+	int ret, ifindex = DST_IFINDEX;
+
+	ret = __do_push_ll_and_redirect(skb);
+	if (ret >= 0)
+		printk("redirected to %d\n", ifindex);
+
+	return ret;
+}
+
+SEC("fill_garbage")
+int do_fill_garbage(struct __sk_buff *skb)
+{
+	uint64_t f = 0xFFFFFFFFFFFFFFFF;
+
+	bpf_skb_store_bytes(skb, 0, &f, sizeof(f), 0);
+	bpf_skb_store_bytes(skb, 8, &f, sizeof(f), 0);
+	bpf_skb_store_bytes(skb, 16, &f, sizeof(f), 0);
+	bpf_skb_store_bytes(skb, 24, &f, sizeof(f), 0);
+	bpf_skb_store_bytes(skb, 32, &f, sizeof(f), 0);
+	bpf_skb_store_bytes(skb, 40, &f, sizeof(f), 0);
+	bpf_skb_store_bytes(skb, 48, &f, sizeof(f), 0);
+	bpf_skb_store_bytes(skb, 56, &f, sizeof(f), 0);
+	bpf_skb_store_bytes(skb, 64, &f, sizeof(f), 0);
+	bpf_skb_store_bytes(skb, 72, &f, sizeof(f), 0);
+	bpf_skb_store_bytes(skb, 80, &f, sizeof(f), 0);
+	bpf_skb_store_bytes(skb, 88, &f, sizeof(f), 0);
+
+	printk("Set initial 96 bytes of header to FF\n");
+
+	return BPF_OK;
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
index 0000000..d016961
--- /dev/null
+++ b/samples/bpf/test_lwt_bpf.sh
@@ -0,0 +1,385 @@
+#!/bin/bash
+
+# Uncomment to see generated bytecode
+#VERBOSE=verbose
+
+NS1=lwt_ns1
+NS2=lwt_ns2
+VETH0=tst_lwt1a
+VETH1=tst_lwt1b
+VETH2=tst_lwt2a
+VETH3=tst_lwt2b
+IPVETH0="192.168.254.1"
+IPVETH1="192.168.254.2"
+IPVETH1b="192.168.254.3"
+
+IPVETH2="192.168.111.1"
+IPVETH3="192.168.111.2"
+
+IP_LOCAL="192.168.99.1"
+
+TRACE_ROOT=/sys/kernel/debug/tracing
+
+function lookup_mac()
+{
+	set +x
+	if [ ! -z "$2" ]; then
+		MAC=$(ip netns exec $2 ip link show $1 | grep ether | awk '{print $2}')
+	else
+		MAC=$(ip link show $1 | grep ether | awk '{print $2}')
+	fi
+	MAC="${MAC//:/}"
+	echo "0x${MAC:10:2}${MAC:8:2}${MAC:6:2}${MAC:4:2}${MAC:2:2}${MAC:0:2}"
+	set -x
+}
+
+function cleanup {
+        set +ex
+        rm test_lwt_bpf.o 2> /dev/null
+        ip link del $VETH0 2> /dev/null
+        ip link del $VETH1 2> /dev/null
+        ip link del $VETH2 2> /dev/null
+        ip link del $VETH3 2> /dev/null
+	ip netns exec $NS1 killall netserver
+        ip netns delete $NS1 2> /dev/null
+        ip netns delete $NS2 2> /dev/null
+        set -ex
+}
+
+function setup_one_veth {
+        ip netns add $1
+        ip link add $2 type veth peer name $3
+        ip link set dev $2 up
+        ip addr add $4/24 dev $2
+        ip link set $3 netns $1
+        ip netns exec $1 ip link set dev $3 up
+        ip netns exec $1 ip addr add $5/24 dev $3
+
+	if [ "$6" ]; then
+		ip netns exec $1 ip addr add $6/32 dev $3
+	fi
+}
+
+function get_trace {
+	set +x
+        cat ${TRACE_ROOT}/trace | grep -v '^#'
+	set -x
+}
+
+function cleanup_routes {
+	ip route del ${IPVETH1}/32 dev $VETH0 2> /dev/null || true
+	ip route del table local local ${IP_LOCAL}/32 dev lo 2> /dev/null || true
+}
+
+function install_test {
+	cleanup_routes
+	cp /dev/null ${TRACE_ROOT}/trace
+
+	OPTS="encap bpf headroom 14 $1 obj test_lwt_bpf.o section $2 $VERBOSE"
+
+	if [ "$1" == "in" ];  then
+		ip route add table local local ${IP_LOCAL}/32 $OPTS dev lo
+	else
+		ip route add ${IPVETH1}/32 $OPTS dev $VETH0
+	fi
+}
+
+function remove_prog {
+	if [ "$1" == "in" ];  then
+		ip route del table local local ${IP_LOCAL}/32 dev lo
+	else
+		ip route del ${IPVETH1}/32 dev $VETH0
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
+	install_test xmit test_ctx
+	ping -c 3 $IPVETH1 || {
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
+	install_test out test_ctx
+	ping -c 3 $IPVETH1 || {
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
+	install_test in test_ctx
+	ping -c 3 $IP_LOCAL || {
+		failure "test_ctx out: packets are dropped"
+	}
+	# We will both request & reply packets as the packets will
+	# be from $IP_LOCAL => $IP_LOCAL
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
+	install_test $1 test_data
+	ping -c 3 $IPVETH1 || {
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
+	install_test in test_data
+	ping -c 3 $IP_LOCAL || {
+		failure "test_data in: packets are dropped"
+	}
+	# We will both request & reply packets as the packets will
+	# be from $IP_LOCAL => $IP_LOCAL
+	match_trace "$(get_trace)" "
+src: 163a8c0 dst: 163a8c0
+src: 163a8c0 dst: 163a8c0
+src: 163a8c0 dst: 163a8c0
+src: 163a8c0 dst: 163a8c0
+src: 163a8c0 dst: 163a8c0
+src: 163a8c0 dst: 163a8c0" || exit 1
+	remove_prog in
+}
+
+function test_cb {
+	test_start "test_cb on lwt $1"
+	install_test $1 test_cb
+	ping -c 3 $IPVETH1 || {
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
+	install_test in test_cb
+	ping -c 3 $IP_LOCAL || {
+		failure "test_cb in: packets are dropped"
+	}
+	# We will both request & reply packets as the packets will
+	# be from $IP_LOCAL => $IP_LOCAL
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
+	install_test $1 drop_all
+	ping -c 3 $IPVETH1 && {
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
+	install_test in drop_all
+	ping -c 3 $IP_LOCAL && {
+		failure "test_drop_all in: Unexpected success of ping"
+	}
+	match_trace "$(get_trace)" "
+dropping with: 2
+dropping with: 2
+dropping with: 2" || exit 1
+	remove_prog in
+}
+
+function test_push_ll_and_redirect {
+	test_start "test_push_ll_and_redirect on lwt xmit"
+	install_test xmit push_ll_and_redirect
+	ping -c 3 $IPVETH1 || {
+		failure "Redirected packets appear to be dropped"
+	}
+	match_trace "$(get_trace)" "
+redirected to $DST_IFINDEX
+redirected to $DST_IFINDEX
+redirected to $DST_IFINDEX" || exit 1
+	remove_prog xmit
+}
+
+function test_rewrite {
+	test_start "test_rewrite on lwt xmit"
+	install_test xmit test_rewrite
+	ping -c 3 $IPVETH1 || {
+		failure "Rewritten packets appear to be dropped"
+	}
+	match_trace "$(get_trace)" "
+out: rewriting from 2fea8c0 to 3fea8c0
+out: rewriting from 2fea8c0 to 3fea8c0
+out: rewriting from 2fea8c0 to 3fea8c0" || exit 1
+	remove_prog out
+}
+
+function test_fill_garbage {
+	test_start "test_fill_garbage on lwt xmit"
+	install_test xmit fill_garbage
+	ping -c 3 $IPVETH1 && {
+		failure "test_drop_all ${1}: Unexpected success of ping"
+	}
+	match_trace "$(get_trace)" "
+Set initial 96 bytes of header to FF
+Set initial 96 bytes of header to FF
+Set initial 96 bytes of header to FF" || exit 1
+	remove_prog xmit
+}
+
+function test_netperf_nop {
+	test_start "test_netperf_nop on lwt xmit"
+	install_test xmit nop
+	netperf -H $IPVETH1 -t TCP_STREAM || {
+		failure "packets appear to be dropped"
+	}
+	match_trace "$(get_trace)" ""|| exit 1
+	remove_prog xmit
+}
+
+function test_netperf_redirect {
+	test_start "test_netperf_redirect on lwt xmit"
+	install_test xmit push_ll_and_redirect_silent
+	netperf -H $IPVETH1 -t TCP_STREAM || {
+		failure "Rewritten packets appear to be dropped"
+	}
+	match_trace "$(get_trace)" ""|| exit 1
+	remove_prog xmit
+}
+
+cleanup
+setup_one_veth $NS1 $VETH0 $VETH1 $IPVETH0 $IPVETH1 $IPVETH1b
+setup_one_veth $NS2 $VETH2 $VETH3 $IPVETH2 $IPVETH3
+ip netns exec $NS1 netserver
+echo 1 > ${TRACE_ROOT}/tracing_on
+
+DST_MAC=$(lookup_mac $VETH1 $NS1)
+SRC_MAC=$(lookup_mac $VETH0)
+DST_IFINDEX=$(cat /sys/class/net/$VETH0/ifindex)
+
+CLANG_OPTS="-O2 -target bpf -I ../include/"
+CLANG_OPTS+=" -DSRC_MAC=$SRC_MAC -DDST_MAC=$DST_MAC -DDST_IFINDEX=$DST_IFINDEX"
+clang $CLANG_OPTS -c test_lwt_bpf.c -o test_lwt_bpf.o
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
+test_rewrite
+test_push_ll_and_redirect
+test_fill_garbage
+test_netperf_nop
+test_netperf_redirect
+
+cleanup
+echo 0 > ${TRACE_ROOT}/tracing_on
+exit 0
-- 
2.7.4
