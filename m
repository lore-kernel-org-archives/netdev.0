From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v5 02/16] bpf: program to load and attach sock_ops BPF progs
Date: Fri, 30 Jun 2017 13:06:52 -0700
Message-ID: <20170630200706.4183158-3-brakmo@fb.com>
References: <20170630200706.4183158-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        "Alexei Starovoitov" <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39790 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752687AbdF3UHR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 16:07:17 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5UK4p5T022735
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:12 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2bdvpp84x8-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 13:07:12 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 b2f4e43a5dcf11e7ac9909cabd64a484-9b5358f0 for <netdev@vger.kernel.org>;        Fri,
 30 Jun 2017 13:07:10 -0700
In-Reply-To: <20170630200706.4183158-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The program load_sock_ops can be used to load sock_ops bpf programs and
to attach it to an existing (v2) cgroup. It can also be used to detach
sock_ops programs.

Examples:
    load_sock_ops [-l] <cg-path> <prog filename>
	Load and attaches a sock_ops program at the specified cgroup.
	If "-l" is used, the program will continue to run to output the
	BPF log buffer.
	If the specified filename does not end in ".o", it appends
	"_kern.o" to the name.

    load_sock_ops -r <cg-path>
	Detaches the currently attached sock_ops program from the
	specified cgroup.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 samples/bpf/Makefile        |  3 ++
 samples/bpf/load_sock_ops.c | 97 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 100 insertions(+)
 create mode 100644 samples/bpf/load_sock_ops.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index e7ec9b8..015589b 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -36,6 +36,7 @@ hostprogs-y += lwt_len_hist
 hostprogs-y += xdp_tx_iptunnel
 hostprogs-y += test_map_in_map
 hostprogs-y += per_socket_stats_example
+hostprogs-y += load_sock_ops
 
 # Libbpf dependencies
 LIBBPF := ../../tools/lib/bpf/bpf.o
@@ -52,6 +53,7 @@ tracex3-objs := bpf_load.o $(LIBBPF) tracex3_user.o
 tracex4-objs := bpf_load.o $(LIBBPF) tracex4_user.o
 tracex5-objs := bpf_load.o $(LIBBPF) tracex5_user.o
 tracex6-objs := bpf_load.o $(LIBBPF) tracex6_user.o
+load_sock_ops-objs := bpf_load.o $(LIBBPF) load_sock_ops.o
 test_probe_write_user-objs := bpf_load.o $(LIBBPF) test_probe_write_user_user.o
 trace_output-objs := bpf_load.o $(LIBBPF) trace_output_user.o
 lathist-objs := bpf_load.o $(LIBBPF) lathist_user.o
@@ -130,6 +132,7 @@ HOSTLOADLIBES_tracex4 += -lelf -lrt
 HOSTLOADLIBES_tracex5 += -lelf
 HOSTLOADLIBES_tracex6 += -lelf
 HOSTLOADLIBES_test_cgrp2_sock2 += -lelf
+HOSTLOADLIBES_load_sock_ops += -lelf
 HOSTLOADLIBES_test_probe_write_user += -lelf
 HOSTLOADLIBES_trace_output += -lelf -lrt
 HOSTLOADLIBES_lathist += -lelf
diff --git a/samples/bpf/load_sock_ops.c b/samples/bpf/load_sock_ops.c
new file mode 100644
index 0000000..e5da6cf
--- /dev/null
+++ b/samples/bpf/load_sock_ops.c
@@ -0,0 +1,97 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+#include <unistd.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <linux/unistd.h>
+
+static void usage(char *pname)
+{
+	printf("USAGE:\n  %s [-l] <cg-path> <prog filename>\n", pname);
+	printf("\tLoad and attach a sock_ops program to the specified "
+	       "cgroup\n");
+	printf("\tIf \"-l\" is used, the program will continue to run\n");
+	printf("\tprinting the BPF log buffer\n");
+	printf("\tIf the specified filename does not end in \".o\", it\n");
+	printf("\tappends \"_kern.o\" to the name\n");
+	printf("\n");
+	printf("  %s -r <cg-path>\n", pname);
+	printf("\tDetaches the currently attached sock_ops program\n");
+	printf("\tfrom the specified cgroup\n");
+	printf("\n");
+	exit(1);
+}
+
+int main(int argc, char **argv)
+{
+	int logFlag = 0;
+	int error = 0;
+	char *cg_path;
+	char fn[500];
+	char *prog;
+	int cg_fd;
+
+	if (argc < 3)
+		usage(argv[0]);
+
+	if (!strcmp(argv[1], "-r")) {
+		cg_path = argv[2];
+		cg_fd = open(cg_path, O_DIRECTORY, O_RDONLY);
+		error = bpf_prog_detach(cg_fd, BPF_CGROUP_SOCK_OPS);
+		if (error) {
+			printf("ERROR: bpf_prog_detach: %d (%s)\n",
+			       error, strerror(errno));
+			return 2;
+		}
+		return 0;
+	} else if (!strcmp(argv[1], "-h")) {
+		usage(argv[0]);
+	} else if (!strcmp(argv[1], "-l")) {
+		logFlag = 1;
+		if (argc < 4)
+			usage(argv[0]);
+	}
+
+	prog = argv[argc - 1];
+	cg_path = argv[argc - 2];
+	if (strlen(prog) > 480) {
+		fprintf(stderr, "ERROR: program name too long (> 480 chars)\n");
+		return 3;
+	}
+	cg_fd = open(cg_path, O_DIRECTORY, O_RDONLY);
+
+	if (!strcmp(prog + strlen(prog)-2, ".o"))
+		strcpy(fn, prog);
+	else
+		sprintf(fn, "%s_kern.o", prog);
+	if (logFlag)
+		printf("loading bpf file:%s\n", fn);
+	if (load_bpf_file(fn)) {
+		printf("ERROR: load_bpf_file failed for: %s\n", fn);
+		printf("%s", bpf_log_buf);
+		return 4;
+	}
+	if (logFlag)
+		printf("TCP BPF Loaded %s\n", fn);
+
+	error = bpf_prog_attach(prog_fd[0], cg_fd, BPF_CGROUP_SOCK_OPS, 0);
+	if (error) {
+		printf("ERROR: bpf_prog_attach: %d (%s)\n",
+		       error, strerror(errno));
+		return 5;
+	} else if (logFlag) {
+		read_trace_pipe();
+	}
+
+	return error;
+}
-- 
2.9.3
