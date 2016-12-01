From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v7 net-next 6/6] samples/bpf: add userspace example for prohibiting sockets
Date: Thu,  1 Dec 2016 08:48:08 -0800
Message-ID: <1480610888-31082-7-git-send-email-dsa@cumulusnetworks.com>
References: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:32794 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760313AbcLAQsV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:48:21 -0500
Received: by mail-pg0-f41.google.com with SMTP id 3so96814429pgd.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:48:21 -0800 (PST)
In-Reply-To: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add examples preventing a process in a cgroup from opening a socket
based family, protocol and type.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v7
- fix header file includes to use symbolic names in sock_flags_kern.c

v6
- new patch for version 6

 samples/bpf/Makefile            |  4 ++
 samples/bpf/sock_flags_kern.c   | 44 ++++++++++++++++++++++
 samples/bpf/test_cgrp2_sock2.c  | 66 +++++++++++++++++++++++++++++++++
 samples/bpf/test_cgrp2_sock2.sh | 81 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 195 insertions(+)
 create mode 100644 samples/bpf/sock_flags_kern.c
 create mode 100644 samples/bpf/test_cgrp2_sock2.c
 create mode 100755 samples/bpf/test_cgrp2_sock2.sh

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index a335b218198e..8df12f9429dc 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -24,6 +24,7 @@ hostprogs-y += test_overhead
 hostprogs-y += test_cgrp2_array_pin
 hostprogs-y += test_cgrp2_attach
 hostprogs-y += test_cgrp2_sock
+hostprogs-y += test_cgrp2_sock2
 hostprogs-y += xdp1
 hostprogs-y += xdp2
 hostprogs-y += test_current_task_under_cgroup
@@ -53,6 +54,7 @@ test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
 test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
 test_cgrp2_attach-objs := libbpf.o test_cgrp2_attach.o
 test_cgrp2_sock-objs := libbpf.o test_cgrp2_sock.o
+test_cgrp2_sock2-objs := bpf_load.o libbpf.o test_cgrp2_sock2.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
@@ -73,6 +75,7 @@ always += tracex3_kern.o
 always += tracex4_kern.o
 always += tracex5_kern.o
 always += tracex6_kern.o
+always += sock_flags_kern.o
 always += test_probe_write_user_kern.o
 always += trace_output_kern.o
 always += tcbpf1_kern.o
@@ -106,6 +109,7 @@ HOSTLOADLIBES_tracex3 += -lelf
 HOSTLOADLIBES_tracex4 += -lelf -lrt
 HOSTLOADLIBES_tracex5 += -lelf
 HOSTLOADLIBES_tracex6 += -lelf
+HOSTLOADLIBES_test_cgrp2_sock2 += -lelf
 HOSTLOADLIBES_test_probe_write_user += -lelf
 HOSTLOADLIBES_trace_output += -lelf -lrt
 HOSTLOADLIBES_lathist += -lelf
diff --git a/samples/bpf/sock_flags_kern.c b/samples/bpf/sock_flags_kern.c
new file mode 100644
index 000000000000..533dd11a6baa
--- /dev/null
+++ b/samples/bpf/sock_flags_kern.c
@@ -0,0 +1,44 @@
+#include <uapi/linux/bpf.h>
+#include <linux/socket.h>
+#include <linux/net.h>
+#include <uapi/linux/in.h>
+#include <uapi/linux/in6.h>
+#include "bpf_helpers.h"
+
+SEC("cgroup/sock1")
+int bpf_prog1(struct bpf_sock *sk)
+{
+	char fmt[] = "socket: family %d type %d protocol %d\n";
+
+	bpf_trace_printk(fmt, sizeof(fmt), sk->family, sk->type, sk->protocol);
+
+	/* block PF_INET6, SOCK_RAW, IPPROTO_ICMPV6 sockets
+	 * ie., make ping6 fail
+	 */
+	if (sk->family == PF_INET6 &&
+	    sk->type == SOCK_RAW   &&
+	    sk->protocol == IPPROTO_ICMPV6)
+		return 0;
+
+	return 1;
+}
+
+SEC("cgroup/sock2")
+int bpf_prog2(struct bpf_sock *sk)
+{
+	char fmt[] = "socket: family %d type %d protocol %d\n";
+
+	bpf_trace_printk(fmt, sizeof(fmt), sk->family, sk->type, sk->protocol);
+
+	/* block PF_INET, SOCK_RAW, IPPROTO_ICMP sockets
+	 * ie., make ping fail
+	 */
+	if (sk->family == PF_INET &&
+	    sk->type == SOCK_RAW  &&
+	    sk->protocol == IPPROTO_ICMP)
+		return 0;
+
+	return 1;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/test_cgrp2_sock2.c b/samples/bpf/test_cgrp2_sock2.c
new file mode 100644
index 000000000000..455ef0d06e93
--- /dev/null
+++ b/samples/bpf/test_cgrp2_sock2.c
@@ -0,0 +1,66 @@
+/* eBPF example program:
+ *
+ * - Loads eBPF program
+ *
+ *   The eBPF program loads a filter from file and attaches the
+ *   program to a cgroup using BPF_PROG_ATTACH
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
+#include <net/if.h>
+#include <linux/bpf.h>
+
+#include "libbpf.h"
+#include "bpf_load.h"
+
+static int usage(const char *argv0)
+{
+	printf("Usage: %s cg-path filter-path [filter-id]\n", argv0);
+	return EXIT_FAILURE;
+}
+
+int main(int argc, char **argv)
+{
+	int cg_fd, ret, filter_id = 0;
+
+	if (argc < 3)
+		return usage(argv[0]);
+
+	cg_fd = open(argv[1], O_DIRECTORY | O_RDONLY);
+	if (cg_fd < 0) {
+		printf("Failed to open cgroup path: '%s'\n", strerror(errno));
+		return EXIT_FAILURE;
+	}
+
+	if (load_bpf_file(argv[2]))
+		return EXIT_FAILURE;
+
+	printf("Output from kernel verifier:\n%s\n-------\n", bpf_log_buf);
+
+	if (argc > 3)
+		filter_id = atoi(argv[3]);
+
+	if (filter_id > prog_cnt) {
+		printf("Invalid program id; program not found in file\n");
+		return EXIT_FAILURE;
+	}
+
+	ret = bpf_prog_attach(prog_fd[filter_id], cg_fd,
+			      BPF_CGROUP_INET_SOCK_CREATE);
+	if (ret < 0) {
+		printf("Failed to attach prog to cgroup: '%s'\n",
+		       strerror(errno));
+		return EXIT_FAILURE;
+	}
+
+	return EXIT_SUCCESS;
+}
diff --git a/samples/bpf/test_cgrp2_sock2.sh b/samples/bpf/test_cgrp2_sock2.sh
new file mode 100755
index 000000000000..891f12a0e26f
--- /dev/null
+++ b/samples/bpf/test_cgrp2_sock2.sh
@@ -0,0 +1,81 @@
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
+	ip addr add 172.16.1.101/24 dev veth0b
+	ip addr add 2401:db00::2/64 dev veth0b nodad
+}
+
+function config_cgroup {
+	rm -rf /tmp/cgroupv2
+	mkdir -p /tmp/cgroupv2
+	mount -t cgroup2 none /tmp/cgroupv2
+	mkdir -p /tmp/cgroupv2/foo
+	echo $$ >> /tmp/cgroupv2/foo/cgroup.procs
+}
+
+
+function attach_bpf {
+	test_cgrp2_sock2 /tmp/cgroupv2/foo sock_flags_kern.o $1
+	[ $? -ne 0 ] && exit 1
+}
+
+function cleanup {
+	ip link del veth0b
+	ip netns delete at_ns0
+	umount /tmp/cgroupv2
+	rm -rf /tmp/cgroupv2
+}
+
+cleanup 2>/dev/null
+
+set -e
+config_device
+config_cgroup
+set +e
+
+#
+# Test 1 - fail ping6
+#
+attach_bpf 0
+ping -c1 -w1 172.16.1.100
+if [ $? -ne 0 ]; then
+	echo "ping failed when it should succeed"
+	cleanup
+	exit 1
+fi
+
+ping6 -c1 -w1 2401:db00::1
+if [ $? -eq 0 ]; then
+	echo "ping6 succeeded when it should not"
+	cleanup
+	exit 1
+fi
+
+#
+# Test 2 - fail ping
+#
+attach_bpf 1
+ping6 -c1 -w1 2401:db00::1
+if [ $? -ne 0 ]; then
+	echo "ping6 failed when it should succeed"
+	cleanup
+	exit 1
+fi
+
+ping -c1 -w1 172.16.1.100
+if [ $? -eq 0 ]; then
+	echo "ping succeeded when it should not"
+	cleanup
+	exit 1
+fi
+
+cleanup
+echo
+echo "*** PASS ***"
-- 
2.1.4
