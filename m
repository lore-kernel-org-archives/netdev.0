From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 3/3] samples: bpf: add userspace example for modifying sk_bound_dev_if
Date: Mon, 28 Nov 2016 20:38:49 -0800
Message-ID: <1480394329-24847-4-git-send-email-dsa@cumulusnetworks.com>
References: <1480394329-24847-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35298 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752196AbcK2Ei7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 23:38:59 -0500
Received: by mail-pg0-f48.google.com with SMTP id p66so64867505pga.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 20:38:58 -0800 (PST)
In-Reply-To: <1480394329-24847-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a simple program to demonstrate the ability to attach a bpf program
to a cgroup that sets sk_bound_dev_if for AF_INET{6} sockets when they
are created.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v4
- added test_cgrp2_sock.sh for an automated test

v3
- revert to BPF_PROG_TYPE_CGROUP_SOCK prog type

v2
- removed bpf_sock_store_u32 references
- changed BPF_CGROUP_INET_SOCK_CREATE to BPF_CGROUP_INET_SOCK
- remove BPF_PROG_TYPE_CGROUP_SOCK prog type and add prog_subtype

 samples/bpf/Makefile           |  2 +
 samples/bpf/test_cgrp2_sock.c  | 83 ++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/test_cgrp2_sock.sh | 48 ++++++++++++++++++++++++
 3 files changed, 133 insertions(+)
 create mode 100644 samples/bpf/test_cgrp2_sock.c
 create mode 100755 samples/bpf/test_cgrp2_sock.sh

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 22b6407efa4f..3a404dd4bb46 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -23,6 +23,7 @@ hostprogs-y += map_perf_test
 hostprogs-y += test_overhead
 hostprogs-y += test_cgrp2_array_pin
 hostprogs-y += test_cgrp2_attach
+hostprogs-y += test_cgrp2_sock
 hostprogs-y += xdp1
 hostprogs-y += xdp2
 hostprogs-y += test_current_task_under_cgroup
@@ -51,6 +52,7 @@ map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
 test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
 test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
 test_cgrp2_attach-objs := libbpf.o test_cgrp2_attach.o
+test_cgrp2_sock-objs := libbpf.o test_cgrp2_sock.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
new file mode 100644
index 000000000000..2831e5f41f86
--- /dev/null
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -0,0 +1,83 @@
+/* eBPF example program:
+ *
+ * - Loads eBPF program
+ *
+ *   The eBPF program sets the sk_bound_dev_if index in new AF_INET{6}
+ *   sockets opened by processes in the cgroup.
+ *
+ * - Attaches the new program to a cgroup using BPF_PROG_ATTACH
+ */
+
+#define _GNU_SOURCE
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <stddef.h>
+#include <string.h>
+#include <unistd.h>
+#include <assert.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <linux/bpf.h>
+
+#include "libbpf.h"
+
+static int prog_load(int idx)
+{
+	struct bpf_insn prog[] = {
+		BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+		BPF_MOV64_IMM(BPF_REG_3, idx),
+		BPF_MOV64_IMM(BPF_REG_2, offsetof(struct bpf_sock, bound_dev_if)),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3, offsetof(struct bpf_sock, bound_dev_if)),
+		BPF_MOV64_IMM(BPF_REG_0, 1), /* r0 = verdict */
+		BPF_EXIT_INSN(),
+	};
+
+	return bpf_prog_load(BPF_PROG_TYPE_CGROUP_SOCK, prog, sizeof(prog),
+			     "GPL", 0);
+}
+
+static int usage(const char *argv0)
+{
+	printf("Usage: %s cg-path device-index\n", argv0);
+	return EXIT_FAILURE;
+}
+
+int main(int argc, char **argv)
+{
+	int cg_fd, prog_fd, ret;
+	int idx = 0;
+
+	if (argc < 2)
+		return usage(argv[0]);
+
+	idx = atoi(argv[2]);
+	if (!idx) {
+		printf("Invalid device index\n");
+		return EXIT_FAILURE;
+	}
+
+	cg_fd = open(argv[1], O_DIRECTORY | O_RDONLY);
+	if (cg_fd < 0) {
+		printf("Failed to open cgroup path: '%s'\n", strerror(errno));
+		return EXIT_FAILURE;
+	}
+
+	prog_fd = prog_load(idx);
+	printf("Output from kernel verifier:\n%s\n-------\n", bpf_log_buf);
+
+	if (prog_fd < 0) {
+		printf("Failed to load prog: '%s'\n", strerror(errno));
+		return EXIT_FAILURE;
+	}
+
+	ret = bpf_prog_detach(cg_fd, BPF_CGROUP_INET_SOCK);
+	ret = bpf_prog_attach(prog_fd, cg_fd, BPF_CGROUP_INET_SOCK);
+	if (ret < 0) {
+		printf("Failed to attach prog to cgroup: '%s'\n",
+		       strerror(errno));
+		return EXIT_FAILURE;
+	}
+
+	return EXIT_SUCCESS;
+}
diff --git a/samples/bpf/test_cgrp2_sock.sh b/samples/bpf/test_cgrp2_sock.sh
new file mode 100755
index 000000000000..35ce9e1566d8
--- /dev/null
+++ b/samples/bpf/test_cgrp2_sock.sh
@@ -0,0 +1,48 @@
+#!/bin/bash
+
+function config_device {
+	ip netns add at_ns0
+	ip link add veth0 type veth peer name veth0b
+	ip link set veth0b up
+	ip link set veth0 netns at_ns0
+	ip netns exec at_ns0 ip addr add 172.16.1.100/24 dev veth0
+	ip netns exec at_ns0 ip addr add 2401:db00::1/64 dev veth0 nodad
+	ip netns exec at_ns0 ip link set dev veth0 up
+	ip link add foo type vrf table 1234
+	ip link set foo up
+	ip addr add 172.16.1.101/24 dev veth0b
+	ip addr add 2401:db00::2/64 dev veth0b nodad
+	ip link set veth0b master foo
+}
+
+function attach_bpf {
+	idx=$(ip -o li sh dev foo | awk -F':' '{print $1}')
+	rm -rf /tmp/cgroupv2
+	mkdir -p /tmp/cgroupv2
+	mount -t cgroup2 none /tmp/cgroupv2
+	mkdir -p /tmp/cgroupv2/foo
+	test_cgrp2_sock /tmp/cgroupv2/foo $idx
+	echo $$ >> /tmp/cgroupv2/foo/cgroup.procs
+}
+
+function cleanup {
+	set +ex
+	ip netns delete at_ns0
+	ip link del veth0
+	ip link del foo
+	umount /tmp/cgroupv2
+	rm -rf /tmp/cgroupv2
+	set -ex
+}
+
+function do_test {
+	ping -c1 -w1 172.16.1.100
+	ping6 -c1 -w1 2401:db00::1
+}
+
+cleanup 2>/dev/null
+config_device
+attach_bpf
+do_test
+cleanup
+echo "*** PASS ***"
-- 
2.1.4
