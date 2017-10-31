From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 2/2] samples/bpf: add a test for bpf_override_return
Date: Tue, 31 Oct 2017 11:45:57 -0400
Message-ID: <1509464757-2222-3-git-send-email-josef@toxicpanda.com>
References: <1509464757-2222-1-git-send-email-josef@toxicpanda.com>
Cc: Josef Bacik <jbacik@fb.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ast@kernel.org, kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509464757-2222-1-git-send-email-josef@toxicpanda.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josef Bacik <jbacik@fb.com>

This adds a basic test for bpf_override_return to verify it works.  We
override the main function for mounting a btrfs fs so it'll return
-ENOMEM and then make sure that trying to mount a btrfs fs will fail.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 samples/bpf/Makefile                      |  4 ++++
 samples/bpf/test_override_return.sh       | 15 +++++++++++++++
 samples/bpf/tracex7_kern.c                | 16 ++++++++++++++++
 samples/bpf/tracex7_user.c                | 28 ++++++++++++++++++++++++++++
 tools/include/uapi/linux/bpf.h            |  7 ++++++-
 tools/testing/selftests/bpf/bpf_helpers.h |  3 ++-
 6 files changed, 71 insertions(+), 2 deletions(-)
 create mode 100755 samples/bpf/test_override_return.sh
 create mode 100644 samples/bpf/tracex7_kern.c
 create mode 100644 samples/bpf/tracex7_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index ea2b9e6135f3..83d06bc1f710 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -14,6 +14,7 @@ hostprogs-y += tracex3
 hostprogs-y += tracex4
 hostprogs-y += tracex5
 hostprogs-y += tracex6
+hostprogs-y += tracex7
 hostprogs-y += test_probe_write_user
 hostprogs-y += trace_output
 hostprogs-y += lathist
@@ -58,6 +59,7 @@ tracex3-objs := bpf_load.o $(LIBBPF) tracex3_user.o
 tracex4-objs := bpf_load.o $(LIBBPF) tracex4_user.o
 tracex5-objs := bpf_load.o $(LIBBPF) tracex5_user.o
 tracex6-objs := bpf_load.o $(LIBBPF) tracex6_user.o
+tracex7-objs := bpf_load.o $(LIBBPF) tracex7_user.o
 load_sock_ops-objs := bpf_load.o $(LIBBPF) load_sock_ops.o
 test_probe_write_user-objs := bpf_load.o $(LIBBPF) test_probe_write_user_user.o
 trace_output-objs := bpf_load.o $(LIBBPF) trace_output_user.o
@@ -100,6 +102,7 @@ always += tracex3_kern.o
 always += tracex4_kern.o
 always += tracex5_kern.o
 always += tracex6_kern.o
+always += tracex7_kern.o
 always += sock_flags_kern.o
 always += test_probe_write_user_kern.o
 always += trace_output_kern.o
@@ -153,6 +156,7 @@ HOSTLOADLIBES_tracex3 += -lelf
 HOSTLOADLIBES_tracex4 += -lelf -lrt
 HOSTLOADLIBES_tracex5 += -lelf
 HOSTLOADLIBES_tracex6 += -lelf
+HOSTLOADLIBES_tracex7 += -lelf
 HOSTLOADLIBES_test_cgrp2_sock2 += -lelf
 HOSTLOADLIBES_load_sock_ops += -lelf
 HOSTLOADLIBES_test_probe_write_user += -lelf
diff --git a/samples/bpf/test_override_return.sh b/samples/bpf/test_override_return.sh
new file mode 100755
index 000000000000..e68b9ee6814b
--- /dev/null
+++ b/samples/bpf/test_override_return.sh
@@ -0,0 +1,15 @@
+#!/bin/bash
+
+rm -f testfile.img
+dd if=/dev/zero of=testfile.img bs=1M seek=1000 count=1
+DEVICE=$(losetup --show -f testfile.img)
+mkfs.btrfs -f $DEVICE
+mkdir tmpmnt
+./tracex7 $DEVICE
+if [ $? -eq 0 ]
+then
+	echo "SUCCESS!"
+else
+	echo "FAILED!"
+fi
+losetup -d $DEVICE
diff --git a/samples/bpf/tracex7_kern.c b/samples/bpf/tracex7_kern.c
new file mode 100644
index 000000000000..1ab308a43e0f
--- /dev/null
+++ b/samples/bpf/tracex7_kern.c
@@ -0,0 +1,16 @@
+#include <uapi/linux/ptrace.h>
+#include <uapi/linux/bpf.h>
+#include <linux/version.h>
+#include "bpf_helpers.h"
+
+SEC("kprobe/open_ctree")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	unsigned long rc = -12;
+
+	bpf_override_return(ctx, rc);
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/tracex7_user.c b/samples/bpf/tracex7_user.c
new file mode 100644
index 000000000000..8a52ac492e8b
--- /dev/null
+++ b/samples/bpf/tracex7_user.c
@@ -0,0 +1,28 @@
+#define _GNU_SOURCE
+
+#include <stdio.h>
+#include <linux/bpf.h>
+#include <unistd.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+int main(int argc, char **argv)
+{
+	FILE *f;
+	char filename[256];
+	char command[256];
+	int ret;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	snprintf(command, 256, "mount %s tmpmnt/", argv[1]);
+	f = popen(command, "r");
+	ret = pclose(f);
+
+	return ret ? 0 : 1;
+}
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 4a4b6e78c977..3756dde69834 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -673,6 +673,10 @@ union bpf_attr {
  *     @buf: buf to fill
  *     @buf_size: size of the buf
  *     Return : 0 on success or negative error code
+ *
+ * int bpf_override_return(pt_regs, rc)
+ *	@pt_regs: pointer to struct pt_regs
+ *	@rc: the return value to set
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -732,7 +736,8 @@ union bpf_attr {
 	FN(xdp_adjust_meta),		\
 	FN(perf_event_read_value),	\
 	FN(perf_prog_read_value),	\
-	FN(getsockopt),
+	FN(getsockopt),			\
+	FN(override_return),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/tools/testing/selftests/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
index abfa4c5c8527..086733298d5e 100644
--- a/tools/testing/selftests/bpf/bpf_helpers.h
+++ b/tools/testing/selftests/bpf/bpf_helpers.h
@@ -81,7 +81,8 @@ static int (*bpf_perf_event_read_value)(void *map, unsigned long long flags,
 static int (*bpf_perf_prog_read_value)(void *ctx, void *buf,
 				       unsigned int buf_size) =
 	(void *) BPF_FUNC_perf_prog_read_value;
-
+static int (*bpf_override_return)(void *ctx, unsigned long rc) =
+	(void *) BPF_FUNC_override_return;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
-- 
2.7.5
