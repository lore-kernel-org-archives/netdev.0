From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 04/12] xdp: sample program for new bpf_redirect helper
Date: Fri, 07 Jul 2017 10:35:47 -0700
Message-ID: <20170707173546.9984.20842.stgit@john-Precision-Tower-5810>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, john.fastabend@gmail.com, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34969 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751438AbdGGRgO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 13:36:14 -0400
Received: by mail-pg0-f68.google.com with SMTP id d193so4808057pgc.2
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 10:36:09 -0700 (PDT)
In-Reply-To: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements a sample program for testing bpf_redirect. It reports
the number of packets redirected per second and as input takes the
ifindex of the device to run the xdp program on and the ifindex of the
interface to redirect packets to.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Tested-by: Andy Gospodarek <andy@greyhouse.net>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/Makefile            |    4 ++
 samples/bpf/xdp_redirect_kern.c |   81 +++++++++++++++++++++++++++++++
 samples/bpf/xdp_redirect_user.c |  102 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 187 insertions(+)
 create mode 100644 samples/bpf/xdp_redirect_kern.c
 create mode 100644 samples/bpf/xdp_redirect_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index e7ec9b8..99a5084 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -36,6 +36,7 @@ hostprogs-y += lwt_len_hist
 hostprogs-y += xdp_tx_iptunnel
 hostprogs-y += test_map_in_map
 hostprogs-y += per_socket_stats_example
+hostprogs-y += xdp_redirect
 
 # Libbpf dependencies
 LIBBPF := ../../tools/lib/bpf/bpf.o
@@ -76,6 +77,7 @@ lwt_len_hist-objs := bpf_load.o $(LIBBPF) lwt_len_hist_user.o
 xdp_tx_iptunnel-objs := bpf_load.o $(LIBBPF) xdp_tx_iptunnel_user.o
 test_map_in_map-objs := bpf_load.o $(LIBBPF) test_map_in_map_user.o
 per_socket_stats_example-objs := $(LIBBPF) cookie_uid_helper_example.o
+xdp_redirect-objs := bpf_load.o $(LIBBPF) xdp_redirect_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -111,6 +113,7 @@ always += lwt_len_hist_kern.o
 always += xdp_tx_iptunnel_kern.o
 always += test_map_in_map_kern.o
 always += cookie_uid_helper_example.o
+always += xdp_redirect_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
@@ -146,6 +149,7 @@ HOSTLOADLIBES_tc_l2_redirect += -l elf
 HOSTLOADLIBES_lwt_len_hist += -l elf
 HOSTLOADLIBES_xdp_tx_iptunnel += -lelf
 HOSTLOADLIBES_test_map_in_map += -lelf
+HOSTLOADLIBES_xdp_redirect += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/xdp_redirect_kern.c b/samples/bpf/xdp_redirect_kern.c
new file mode 100644
index 0000000..a34ad45
--- /dev/null
+++ b/samples/bpf/xdp_redirect_kern.c
@@ -0,0 +1,81 @@
+/* Copyright (c) 2016 John Fastabend <john.r.fastabend@intel.com>
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
+struct bpf_map_def SEC("maps") tx_port = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(int),
+	.value_size = sizeof(int),
+	.max_entries = 1,
+};
+
+struct bpf_map_def SEC("maps") rxcnt = {
+	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = 1,
+};
+
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
+SEC("xdp_redirect")
+int xdp_redirect_prog(struct xdp_md *ctx)
+{
+	void *data_end = (void *)(long)ctx->data_end;
+	void *data = (void *)(long)ctx->data;
+	struct ethhdr *eth = data;
+	int rc = XDP_DROP;
+	int *ifindex, port = 0;
+	long *value;
+	u32 key = 0;
+	u64 nh_off;
+
+	nh_off = sizeof(*eth);
+	if (data + nh_off > data_end)
+		return rc;
+
+	ifindex = bpf_map_lookup_elem(&tx_port, &port);
+	if (!ifindex)
+		return rc;
+
+	value = bpf_map_lookup_elem(&rxcnt, &key);
+	if (value)
+		*value += 1;
+
+	swap_src_dst_mac(data);
+	return bpf_redirect(*ifindex, 0);
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/xdp_redirect_user.c b/samples/bpf/xdp_redirect_user.c
new file mode 100644
index 0000000..761a91d
--- /dev/null
+++ b/samples/bpf/xdp_redirect_user.c
@@ -0,0 +1,102 @@
+/* Copyright (c) 2016 John Fastabend <john.r.fastabend@intel.com>
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
+#include <linux/bpf.h>
+#include <assert.h>
+#include <errno.h>
+#include <signal.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+
+#include "bpf_load.h"
+#include "bpf_util.h"
+#include "libbpf.h"
+
+static int ifindex_in;
+static int ifindex_out;
+
+static void int_exit(int sig)
+{
+	set_link_xdp_fd(ifindex_in, -1, 0);
+	exit(0);
+}
+
+/* simple per-protocol drop counter
+ */
+static void poll_stats(int interval, int ifindex)
+{
+	unsigned int nr_cpus = bpf_num_possible_cpus();
+	__u64 values[nr_cpus], prev[nr_cpus];
+
+	memset(prev, 0, sizeof(prev));
+
+	while (1) {
+		__u64 sum = 0;
+		__u32 key = 0;
+		int i;
+
+		sleep(interval);
+		assert(bpf_map_lookup_elem(map_fd[1], &key, values) == 0);
+		for (i = 0; i < nr_cpus; i++)
+			sum += (values[i] - prev[i]);
+		if (sum)
+			printf("ifindex %i: %10llu pkt/s\n",
+			       ifindex, sum / interval);
+		memcpy(prev, values, sizeof(values));
+	}
+}
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+	int ret, key = 0;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (ac != 3) {
+		printf("usage: %s IFINDEX_IN IFINDEX_OUT\n", argv[0]);
+		return 1;
+	}
+
+	ifindex_in = strtoul(argv[1], NULL, 0);
+	ifindex_out = strtoul(argv[2], NULL, 0);
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
+	if (set_link_xdp_fd(ifindex_in, prog_fd[0], 0) < 0) {
+		printf("link set xdp fd failed\n");
+		return 1;
+	}
+
+	/* bpf redirect port */
+	ret = bpf_map_update_elem(map_fd[0], &key, &ifindex_out, 0);
+	if (ret) {
+		perror("bpf_update_elem");
+		goto out;
+	}
+
+	poll_stats(2, ifindex_out);
+
+out:
+	return 0;
+}
