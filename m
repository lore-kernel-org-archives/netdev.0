From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 net-next 5/5] samples: bpf: add userspace example for modifying sk_bound_dev_if
Date: Wed, 26 Oct 2016 17:58:42 -0700
Message-ID: <1477529922-4806-6-git-send-email-dsa@cumulusnetworks.com>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33486 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934884AbcJ0A6y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 20:58:54 -0400
Received: by mail-pf0-f169.google.com with SMTP id 197so6116776pfu.0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 17:58:54 -0700 (PDT)
In-Reply-To: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a simple program to demonstrate the ability to attach a bpf program
to a cgroup that sets sk_bound_dev_if for AF_INET{6} sockets when they
are created.

v2
- removed bpf_sock_store_u32 references
- changed BPF_CGROUP_INET_SOCK_CREATE to BPF_CGROUP_INET_SOCK
- remove BPF_PROG_TYPE_CGROUP_SOCK prog type and add prog_subtype

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 samples/bpf/Makefile          |  2 ++
 samples/bpf/test_cgrp2_sock.c | 84 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 86 insertions(+)
 create mode 100644 samples/bpf/test_cgrp2_sock.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 2624d5d7ce8b..ec4ef37a2dbc 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -22,6 +22,7 @@ hostprogs-y += map_perf_test
 hostprogs-y += test_overhead
 hostprogs-y += test_cgrp2_array_pin
 hostprogs-y += test_cgrp2_attach
+hostprogs-y += test_cgrp2_sock
 hostprogs-y += xdp1
 hostprogs-y += xdp2
 hostprogs-y += test_current_task_under_cgroup
@@ -48,6 +49,7 @@ map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
 test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
 test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
 test_cgrp2_attach-objs := libbpf.o test_cgrp2_attach.o
+test_cgrp2_sock-objs := libbpf.o test_cgrp2_sock.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
new file mode 100644
index 000000000000..9cc3307052e0
--- /dev/null
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -0,0 +1,84 @@
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
+	union bpf_prog_subtype prog_subtype = { .cgroup.sock = 1 };
+
+	return bpf_prog_load(BPF_PROG_TYPE_CGROUP, prog, sizeof(prog), "GPL",
+			     0, &prog_subtype);
+}
+
+static int usage(const char *argv0)
+{
+	printf("Usage: %s <cg-path> device-index\n", argv0);
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
-- 
2.1.4
