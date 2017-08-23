From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 4/8] bpf samples: Update sock test to allow setting mark and priority
Date: Tue, 22 Aug 2017 17:20:17 -0700
Message-ID: <1503447621-27997-5-git-send-email-dsahern@gmail.com>
References: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33650 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752830AbdHWAUc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 20:20:32 -0400
Received: by mail-pg0-f67.google.com with SMTP id u191so226976pgc.0
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 17:20:32 -0700 (PDT)
In-Reply-To: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update sock test to set mark and priority on socket create.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 samples/bpf/test_cgrp2_sock.c  | 129 ++++++++++++++++++++++++++++++++++++-----
 samples/bpf/test_cgrp2_sock.sh |   2 +-
 2 files changed, 116 insertions(+), 15 deletions(-)

diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
index c3cfb23e23b5..c2501c9508a7 100644
--- a/samples/bpf/test_cgrp2_sock.c
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -19,55 +19,156 @@
 #include <errno.h>
 #include <fcntl.h>
 #include <net/if.h>
+#include <inttypes.h>
 #include <linux/bpf.h>
 
 #include "libbpf.h"
 
 char bpf_log_buf[BPF_LOG_BUF_SIZE];
 
-static int prog_load(int idx)
+static int prog_load(__u32 idx, __u32 mark, __u32 prio)
 {
-	struct bpf_insn prog[] = {
+	/* save pointer to context */
+	struct bpf_insn prog_start[] = {
 		BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+	};
+	struct bpf_insn prog_end[] = {
+		BPF_MOV64_IMM(BPF_REG_0, 1), /* r0 = verdict */
+		BPF_EXIT_INSN(),
+	};
+
+	/* set sk_bound_dev_if on socket */
+	struct bpf_insn prog_dev[] = {
 		BPF_MOV64_IMM(BPF_REG_3, idx),
 		BPF_MOV64_IMM(BPF_REG_2, offsetof(struct bpf_sock, bound_dev_if)),
 		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3, offsetof(struct bpf_sock, bound_dev_if)),
-		BPF_MOV64_IMM(BPF_REG_0, 1), /* r0 = verdict */
-		BPF_EXIT_INSN(),
 	};
-	size_t insns_cnt = sizeof(prog) / sizeof(struct bpf_insn);
 
-	return bpf_load_program(BPF_PROG_TYPE_CGROUP_SOCK, prog, insns_cnt,
+	/* set mark on socket */
+	struct bpf_insn prog_mark[] = {
+		BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+		BPF_MOV64_IMM(BPF_REG_3, mark),
+		BPF_MOV64_IMM(BPF_REG_2, offsetof(struct bpf_sock, mark)),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3, offsetof(struct bpf_sock, mark)),
+	};
+
+	/* set priority on socket */
+	struct bpf_insn prog_prio[] = {
+		BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+		BPF_MOV64_IMM(BPF_REG_3, prio),
+		BPF_MOV64_IMM(BPF_REG_2, offsetof(struct bpf_sock, priority)),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3, offsetof(struct bpf_sock, priority)),
+	};
+
+	struct bpf_insn *prog;
+	size_t insns_cnt;
+	void *p;
+	int ret;
+
+	insns_cnt = sizeof(prog_start) + sizeof(prog_end);
+	if (idx)
+		insns_cnt += sizeof(prog_dev);
+
+	if (mark)
+		insns_cnt += sizeof(prog_mark);
+
+	if (prio)
+		insns_cnt += sizeof(prog_prio);
+
+	p = prog = malloc(insns_cnt);
+	if (!prog) {
+		fprintf(stderr, "Failed to allocate memory for instructions\n");
+		return EXIT_FAILURE;
+	}
+
+	memcpy(p, prog_start, sizeof(prog_start));
+	p += sizeof(prog_start);
+
+	if (idx) {
+		memcpy(p, prog_dev, sizeof(prog_dev));
+		p += sizeof(prog_dev);
+	}
+
+	if (mark) {
+		memcpy(p, prog_mark, sizeof(prog_mark));
+		p += sizeof(prog_mark);
+	}
+
+	if (prio) {
+		memcpy(p, prog_prio, sizeof(prog_prio));
+		p += sizeof(prog_prio);
+	}
+
+	memcpy(p, prog_end, sizeof(prog_end));
+	p += sizeof(prog_end);
+
+	insns_cnt /= sizeof(struct bpf_insn);
+
+	ret = bpf_load_program(BPF_PROG_TYPE_CGROUP_SOCK, prog, insns_cnt,
 				"GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE);
+
+	free(prog);
+
+	return ret;
 }
 
 static int usage(const char *argv0)
 {
-	printf("Usage: %s cg-path device-index\n", argv0);
+	printf("Usage: %s -b bind-to-dev -m mark -p prio cg-path\n", argv0);
 	return EXIT_FAILURE;
 }
 
 int main(int argc, char **argv)
 {
+	__u32 idx = 0, mark = 0, prio = 0;
+	const char *cgrp_path = NULL;
 	int cg_fd, prog_fd, ret;
-	unsigned int idx;
+	int rc;
+
+	while ((rc = getopt(argc, argv, "b:m:p:")) != -1) {
+		switch (rc) {
+		case 'b':
+			idx = if_nametoindex(optarg);
+			if (!idx) {
+				idx = strtoumax(optarg, NULL, 0);
+				if (!idx) {
+					printf("Invalid device name\n");
+					return EXIT_FAILURE;
+				}
+			}
+			break;
+		case 'm':
+			mark = strtoumax(optarg, NULL, 0);
+			break;
+		case 'p':
+			prio = strtoumax(optarg, NULL, 0);
+			break;
+		default:
+			return usage(argv[0]);
+		}
+	}
 
-	if (argc < 2)
+	if (optind == argc)
 		return usage(argv[0]);
 
-	idx = if_nametoindex(argv[2]);
-	if (!idx) {
-		printf("Invalid device name\n");
+	cgrp_path = argv[optind];
+	if (!cgrp_path) {
+		fprintf(stderr, "cgroup path not given\n");
+		return EXIT_FAILURE;
+	}
+
+	if (!idx && !mark && !prio) {
+		fprintf(stderr, "One of device, mark or priority must be given\n");
 		return EXIT_FAILURE;
 	}
 
-	cg_fd = open(argv[1], O_DIRECTORY | O_RDONLY);
+	cg_fd = open(cgrp_path, O_DIRECTORY | O_RDONLY);
 	if (cg_fd < 0) {
 		printf("Failed to open cgroup path: '%s'\n", strerror(errno));
 		return EXIT_FAILURE;
 	}
 
-	prog_fd = prog_load(idx);
+	prog_fd = prog_load(idx, mark, prio);
 	printf("Output from kernel verifier:\n%s\n-------\n", bpf_log_buf);
 
 	if (prog_fd < 0) {
diff --git a/samples/bpf/test_cgrp2_sock.sh b/samples/bpf/test_cgrp2_sock.sh
index 925fd467c7cc..1153c33e8964 100755
--- a/samples/bpf/test_cgrp2_sock.sh
+++ b/samples/bpf/test_cgrp2_sock.sh
@@ -20,7 +20,7 @@ function attach_bpf {
 	mkdir -p /tmp/cgroupv2
 	mount -t cgroup2 none /tmp/cgroupv2
 	mkdir -p /tmp/cgroupv2/foo
-	test_cgrp2_sock /tmp/cgroupv2/foo foo
+	test_cgrp2_sock -b foo /tmp/cgroupv2/foo
 	echo $$ >> /tmp/cgroupv2/foo/cgroup.procs
 }
 
-- 
2.1.4
