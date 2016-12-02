From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next 2/2] samples, bpf: Add automated test for cgroup
 filter attachments
Date: Fri, 2 Dec 2016 02:42:32 -0800
Message-ID: <20161202104230.GA9237@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@zonque.org, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36082 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933923AbcLBKme (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 05:42:34 -0500
Received: by mail-io0-f182.google.com with SMTP id m5so336506943ioe.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 02:42:34 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the sample program test_cgrp2_attach2. This program is
similar to test_cgrp2_attach, but it performs automated testing of the
cgroupv2 BPF attached filters. It runs the following checks:
* Simple filter attachment
* Application of filters to child cgroups
* Overriding filters on child cgroups
	* Checking that this still works when the parent filter is removed

The filters that are used here are simply allow all / deny all filters, so
it isn't checking the actual functionality of the filters, but rather
the behaviour  around detachment / attachment. If net_cls is enabled,
this test will fail.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 samples/bpf/Makefile             |   2 +
 samples/bpf/test_cgrp2_attach2.c | 132 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 134 insertions(+)
 create mode 100644 samples/bpf/test_cgrp2_attach2.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 3c805af..8892d7c 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -23,6 +23,7 @@ hostprogs-y += map_perf_test
 hostprogs-y += test_overhead
 hostprogs-y += test_cgrp2_array_pin
 hostprogs-y += test_cgrp2_attach
+hostprogs-y += test_cgrp2_attach2
 hostprogs-y += xdp1
 hostprogs-y += xdp2
 hostprogs-y += test_current_task_under_cgroup
@@ -51,6 +52,7 @@ map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
 test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
 test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
 test_cgrp2_attach-objs := libbpf.o test_cgrp2_attach.o
+test_cgrp2_attach2-objs := libbpf.o test_cgrp2_attach2.o cgroup_helpers.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
diff --git a/samples/bpf/test_cgrp2_attach2.c b/samples/bpf/test_cgrp2_attach2.c
new file mode 100644
index 0000000..ddfac42
--- /dev/null
+++ b/samples/bpf/test_cgrp2_attach2.c
@@ -0,0 +1,132 @@
+/* eBPF example program:
+ *
+ * - Creates arraymap in kernel with 4 bytes keys and 8 byte values
+ *
+ * - Loads eBPF program
+ *
+ *   The eBPF program accesses the map passed in to store two pieces of
+ *   information. The number of invocations of the program, which maps
+ *   to the number of packets received, is stored to key 0. Key 1 is
+ *   incremented on each iteration by the number of bytes stored in
+ *   the skb.
+ *
+ * - Attaches the new program to a cgroup using BPF_PROG_ATTACH
+ *
+ * - Every second, reads map[0] and map[1] to see how many bytes and
+ *   packets were seen on any socket of tasks in the given cgroup.
+ */
+
+#define _GNU_SOURCE
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <assert.h>
+#include <unistd.h>
+
+#include <linux/bpf.h>
+
+#include "libbpf.h"
+#include "cgroup_helpers.h"
+
+#define FOO		"/foo"
+#define BAR		"/foo/bar/"
+#define PING_CMD	"ping -c1 -w1 127.0.0.1"
+
+static int prog_load(int verdict)
+{
+	int ret;
+	struct bpf_insn prog[] = {
+		BPF_MOV64_IMM(BPF_REG_0, verdict), /* r0 = verdict */
+		BPF_EXIT_INSN(),
+	};
+
+	ret = bpf_prog_load(BPF_PROG_TYPE_CGROUP_SKB,
+			     prog, sizeof(prog), "GPL", 0);
+
+	if (ret < 0) {
+		log_err("Loading program");
+		printf("Output from verifier:\n%s\n-------\n", bpf_log_buf);
+		return 0;
+	}
+	return ret;
+}
+
+
+int main(int argc, char **argv)
+{
+	int drop_prog, allow_prog, foo = 0, bar = 0, rc = 0;
+
+	allow_prog = prog_load(1);
+	if (!allow_prog)
+		goto err;
+
+	drop_prog = prog_load(0);
+	if (!drop_prog)
+		goto err;
+
+	if (setup_cgroup_environment())
+		goto err;
+
+	/* Create cgroup /foo, get fd, and join it */
+	foo = create_and_get_cgroup(FOO);
+	if (!foo)
+		goto err;
+
+	if (join_cgroup(FOO))
+		goto err;
+
+	if (bpf_prog_attach(drop_prog, foo, BPF_CGROUP_INET_EGRESS)) {
+		log_err("Attaching prog to /foo");
+		goto err;
+	}
+
+	assert(system(PING_CMD) != 0);
+
+	/* Create cgroup /foo/bar, get fd, and join it */
+	bar = create_and_get_cgroup(BAR);
+	if (!bar)
+		goto err;
+
+	if (join_cgroup(BAR))
+		goto err;
+
+	assert(system(PING_CMD) != 0);
+
+	if (bpf_prog_attach(allow_prog, bar, BPF_CGROUP_INET_EGRESS)) {
+		log_err("Attaching prog to /foo/bar");
+		goto err;
+	}
+
+	assert(system(PING_CMD) == 0);
+
+
+	if (bpf_prog_detach(bar, BPF_CGROUP_INET_EGRESS)) {
+		log_err("Detaching program from /foo/bar");
+		goto err;
+	}
+
+	assert(system(PING_CMD) != 0);
+
+	if (bpf_prog_attach(allow_prog, bar, BPF_CGROUP_INET_EGRESS)) {
+		log_err("Attaching prog to /foo/bar");
+		goto err;
+	}
+
+	if (bpf_prog_detach(foo, BPF_CGROUP_INET_EGRESS)) {
+		log_err("Detaching program from /foo");
+		goto err;
+	}
+
+	assert(system(PING_CMD) == 0);
+
+	goto out;
+
+err:
+	rc = 1;
+
+out:
+	close(foo);
+	close(bar);
+	cleanup_cgroup_environment();
+	return rc;
+}
-- 
2.7.4
