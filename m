From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v10 06/12] Add sample for adding simple drop program to link
Date: Tue, 19 Jul 2016 12:16:51 -0700
Message-ID: <1468955817-10604-7-git-send-email-bblanco@plumgrid.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
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
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35853 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbcGSTRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 15:17:31 -0400
Received: by mail-pa0-f52.google.com with SMTP id pp5so9713469pac.3
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 12:17:30 -0700 (PDT)
In-Reply-To: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a sample program that only drops packets at the BPF_PROG_TYPE_XDP_RX
hook of a link. With the drop-only program, observed single core rate is
~20Mpps.

Other tests were run, for instance without the dropcnt increment or
without reading from the packet header, the packet rate was mostly
unchanged.

$ perf record -a samples/bpf/xdp1 $(</sys/class/net/eth0/ifindex)
proto 17:   20403027 drops/s

./pktgen_sample03_burst_single_flow.sh -i $DEV -d $IP -m $MAC -t 4
Running... ctrl^C to stop
Device: eth4@0
Result: OK: 11791017(c11788327+d2689) usec, 59622913 (60byte,0frags)
  5056638pps 2427Mb/sec (2427186240bps) errors: 0
Device: eth4@1
Result: OK: 11791012(c11787906+d3106) usec, 60526944 (60byte,0frags)
  5133311pps 2463Mb/sec (2463989280bps) errors: 0
Device: eth4@2
Result: OK: 11791019(c11788249+d2769) usec, 59868091 (60byte,0frags)
  5077431pps 2437Mb/sec (2437166880bps) errors: 0
Device: eth4@3
Result: OK: 11795039(c11792403+d2636) usec, 59483181 (60byte,0frags)
  5043067pps 2420Mb/sec (2420672160bps) errors: 0

perf report --no-children:
 26.05%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_process_rx_cq
 17.84%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_alloc_frags
  5.52%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_free_frag
  4.90%  swapper      [kernel.vmlinux]  [k] poll_idle
  4.14%  ksoftirqd/0  [kernel.vmlinux]  [k] get_page_from_freelist
  2.78%  ksoftirqd/0  [kernel.vmlinux]  [k] __free_pages_ok
  2.57%  ksoftirqd/0  [kernel.vmlinux]  [k] bpf_map_lookup_elem
  2.51%  swapper      [mlx4_en]         [k] mlx4_en_process_rx_cq
  1.94%  ksoftirqd/0  [kernel.vmlinux]  [k] percpu_array_map_lookup_elem
  1.45%  swapper      [mlx4_en]         [k] mlx4_en_alloc_frags
  1.35%  ksoftirqd/0  [kernel.vmlinux]  [k] free_one_page
  1.33%  swapper      [kernel.vmlinux]  [k] intel_idle
  1.04%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c5c5
  0.96%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c58d
  0.93%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c6ee
  0.92%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c6b9
  0.89%  ksoftirqd/0  [kernel.vmlinux]  [k] __alloc_pages_nodemask
  0.83%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c686
  0.83%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c5d5
  0.78%  ksoftirqd/0  [mlx4_en]         [k] mlx4_alloc_pages.isra.23
  0.77%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c5b4
  0.77%  ksoftirqd/0  [kernel.vmlinux]  [k] net_rx_action

machine specs:
 receiver - Intel E5-1630 v3 @ 3.70GHz
 sender - Intel E5645 @ 2.40GHz
 Mellanox ConnectX-3 @40G

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 samples/bpf/Makefile    |   4 ++
 samples/bpf/bpf_load.c  |   8 +++
 samples/bpf/xdp1_kern.c |  93 +++++++++++++++++++++++++
 samples/bpf/xdp1_user.c | 181 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 286 insertions(+)
 create mode 100644 samples/bpf/xdp1_kern.c
 create mode 100644 samples/bpf/xdp1_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index a98b780..0e4ab3a 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -21,6 +21,7 @@ hostprogs-y += spintest
 hostprogs-y += map_perf_test
 hostprogs-y += test_overhead
 hostprogs-y += test_cgrp2_array_pin
+hostprogs-y += xdp1
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -42,6 +43,7 @@ spintest-objs := bpf_load.o libbpf.o spintest_user.o
 map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
 test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
 test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
+xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -64,6 +66,7 @@ always += test_overhead_tp_kern.o
 always += test_overhead_kprobe_kern.o
 always += parse_varlen.o parse_simple.o parse_ldabs.o
 always += test_cgrp2_tc_kern.o
+always += xdp1_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -84,6 +87,7 @@ HOSTLOADLIBES_offwaketime += -lelf
 HOSTLOADLIBES_spintest += -lelf
 HOSTLOADLIBES_map_perf_test += -lelf -lrt
 HOSTLOADLIBES_test_overhead += -lelf -lrt
+HOSTLOADLIBES_xdp1 += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 022af71..0cfda23 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -50,6 +50,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_kprobe = strncmp(event, "kprobe/", 7) == 0;
 	bool is_kretprobe = strncmp(event, "kretprobe/", 10) == 0;
 	bool is_tracepoint = strncmp(event, "tracepoint/", 11) == 0;
+	bool is_xdp = strncmp(event, "xdp", 3) == 0;
 	enum bpf_prog_type prog_type;
 	char buf[256];
 	int fd, efd, err, id;
@@ -66,6 +67,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		prog_type = BPF_PROG_TYPE_KPROBE;
 	} else if (is_tracepoint) {
 		prog_type = BPF_PROG_TYPE_TRACEPOINT;
+	} else if (is_xdp) {
+		prog_type = BPF_PROG_TYPE_XDP;
 	} else {
 		printf("Unknown event '%s'\n", event);
 		return -1;
@@ -79,6 +82,9 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
+	if (is_xdp)
+		return 0;
+
 	if (is_socket) {
 		event += 6;
 		if (*event != '/')
@@ -319,6 +325,7 @@ int load_bpf_file(char *path)
 			if (memcmp(shname_prog, "kprobe/", 7) == 0 ||
 			    memcmp(shname_prog, "kretprobe/", 10) == 0 ||
 			    memcmp(shname_prog, "tracepoint/", 11) == 0 ||
+			    memcmp(shname_prog, "xdp", 3) == 0 ||
 			    memcmp(shname_prog, "socket", 6) == 0)
 				load_and_attach(shname_prog, insns, data_prog->d_size);
 		}
@@ -336,6 +343,7 @@ int load_bpf_file(char *path)
 		if (memcmp(shname, "kprobe/", 7) == 0 ||
 		    memcmp(shname, "kretprobe/", 10) == 0 ||
 		    memcmp(shname, "tracepoint/", 11) == 0 ||
+		    memcmp(shname, "xdp", 3) == 0 ||
 		    memcmp(shname, "socket", 6) == 0)
 			load_and_attach(shname, data->d_buf, data->d_size);
 	}
diff --git a/samples/bpf/xdp1_kern.c b/samples/bpf/xdp1_kern.c
new file mode 100644
index 0000000..e7dd8ac
--- /dev/null
+++ b/samples/bpf/xdp1_kern.c
@@ -0,0 +1,93 @@
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
+	return rc;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/xdp1_user.c b/samples/bpf/xdp1_user.c
new file mode 100644
index 0000000..a5e109e
--- /dev/null
+++ b/samples/bpf/xdp1_user.c
@@ -0,0 +1,181 @@
+/* Copyright (c) 2016 PLUMgrid
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/bpf.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+#include <assert.h>
+#include <errno.h>
+#include <signal.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/socket.h>
+#include <unistd.h>
+#include "bpf_load.h"
+#include "libbpf.h"
+
+static int set_link_xdp_fd(int ifindex, int fd)
+{
+	struct sockaddr_nl sa;
+	int sock, seq = 0, len, ret = -1;
+	char buf[4096];
+	struct nlattr *nla, *nla_xdp;
+	struct {
+		struct nlmsghdr  nh;
+		struct ifinfomsg ifinfo;
+		char             attrbuf[64];
+	} req;
+	struct nlmsghdr *nh;
+	struct nlmsgerr *err;
+
+	memset(&sa, 0, sizeof(sa));
+	sa.nl_family = AF_NETLINK;
+
+	sock = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
+	if (sock < 0) {
+		printf("open netlink socket: %s\n", strerror(errno));
+		return -1;
+	}
+
+	if (bind(sock, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
+		printf("bind to netlink: %s\n", strerror(errno));
+		goto cleanup;
+	}
+
+	memset(&req, 0, sizeof(req));
+	req.nh.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	req.nh.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
+	req.nh.nlmsg_type = RTM_SETLINK;
+	req.nh.nlmsg_pid = 0;
+	req.nh.nlmsg_seq = ++seq;
+	req.ifinfo.ifi_family = AF_UNSPEC;
+	req.ifinfo.ifi_index = ifindex;
+	nla = (struct nlattr *)(((char *)&req)
+				+ NLMSG_ALIGN(req.nh.nlmsg_len));
+	nla->nla_type = NLA_F_NESTED | 43/*IFLA_XDP*/;
+
+	nla_xdp = (struct nlattr *)((char *)nla + NLA_HDRLEN);
+	nla_xdp->nla_type = 1/*IFLA_XDP_FD*/;
+	nla_xdp->nla_len = NLA_HDRLEN + sizeof(int);
+	memcpy((char *)nla_xdp + NLA_HDRLEN, &fd, sizeof(fd));
+	nla->nla_len = NLA_HDRLEN + nla_xdp->nla_len;
+
+	req.nh.nlmsg_len += NLA_ALIGN(nla->nla_len);
+
+	if (send(sock, &req, req.nh.nlmsg_len, 0) < 0) {
+		printf("send to netlink: %s\n", strerror(errno));
+		goto cleanup;
+	}
+
+	len = recv(sock, buf, sizeof(buf), 0);
+	if (len < 0) {
+		printf("recv from netlink: %s\n", strerror(errno));
+		goto cleanup;
+	}
+
+	for (nh = (struct nlmsghdr *)buf; NLMSG_OK(nh, len);
+	     nh = NLMSG_NEXT(nh, len)) {
+		if (nh->nlmsg_pid != getpid()) {
+			printf("Wrong pid %d, expected %d\n",
+			       nh->nlmsg_pid, getpid());
+			goto cleanup;
+		}
+		if (nh->nlmsg_seq != seq) {
+			printf("Wrong seq %d, expected %d\n",
+			       nh->nlmsg_seq, seq);
+			goto cleanup;
+		}
+		switch (nh->nlmsg_type) {
+		case NLMSG_ERROR:
+			err = (struct nlmsgerr *)NLMSG_DATA(nh);
+			if (!err->error)
+				continue;
+			printf("nlmsg error %s\n", strerror(-err->error));
+			goto cleanup;
+		case NLMSG_DONE:
+			break;
+		}
+	}
+
+	ret = 0;
+
+cleanup:
+	close(sock);
+	return ret;
+}
+
+static int ifindex;
+
+static void int_exit(int sig)
+{
+	set_link_xdp_fd(ifindex, -1);
+	exit(0);
+}
+
+/* simple per-protocol drop counter
+ */
+static void poll_stats(int interval)
+{
+	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	const unsigned int nr_keys = 256;
+	__u64 values[nr_cpus], prev[nr_keys][nr_cpus];
+	__u32 key;
+	int i;
+
+	memset(prev, 0, sizeof(prev));
+
+	while (1) {
+		sleep(interval);
+
+		for (key = 0; key < nr_keys; key++) {
+			__u64 sum = 0;
+
+			assert(bpf_lookup_elem(map_fd[0], &key, values) == 0);
+			for (i = 0; i < nr_cpus; i++)
+				sum += (values[i] - prev[key][i]);
+			if (sum)
+				printf("proto %u: %10llu pkt/s\n",
+				       key, sum / interval);
+			memcpy(prev[key], values, sizeof(values));
+		}
+	}
+}
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (ac != 2) {
+		printf("usage: %s IFINDEX\n", argv[0]);
+		return 1;
+	}
+
+	ifindex = strtoul(argv[1], NULL, 0);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	if (!prog_fd[0]) {
+		printf("load_bpf_file: %s\n", strerror(errno));
+		return 1;
+	}
+
+	signal(SIGINT, int_exit);
+
+	if (set_link_xdp_fd(ifindex, prog_fd[0]) < 0) {
+		printf("link set xdp fd failed\n");
+		return 1;
+	}
+
+	poll_stats(2);
+
+	return 0;
+}
-- 
2.8.2
