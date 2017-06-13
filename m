From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH net-next 02/15] bpf: program to load socketops BPF programs
Date: Tue, 13 Jun 2017 10:59:51 -0700
Message-ID: <20170613180004.3008403-3-brakmo@fb.com>
References: <20170613180004.3008403-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59091 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752337AbdFMSAJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 14:00:09 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DHwIFe029739
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:09 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b2m4kga3c-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:09 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 22fb5fc8506211e794d00002c9dfb610-5c3378f0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 11:00:08 -0700
In-Reply-To: <20170613180004.3008403-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The program tcp_bpf can be used to remove current global sockops program
and to load/replace sockops BPF programs. There is also an option to
print the bpf trace buffer (for debugging purposes).

USAGE:
  ./tcp_bpf [-r] [-l] [<pname>]
WHERE:
  -r      remove current loaded socketops BPF program
          not needed if loading a new program
  -l      print BPF trace buffer. Used when loading a new program
  <pname> name of BPF sockeops program to load
          if <pname> does not end in ".o", then "_kern.o" is appended
          example: using tcp_rto will load tcp_rto_kern.o

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 samples/bpf/Makefile  |  3 ++
 samples/bpf/tcp_bpf.c | 81 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 84 insertions(+)
 create mode 100644 samples/bpf/tcp_bpf.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 6c7468e..b13436c 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -36,6 +36,7 @@ hostprogs-y += lwt_len_hist
 hostprogs-y += xdp_tx_iptunnel
 hostprogs-y += test_map_in_map
 hostprogs-y += per_socket_stats_example
+hostprogs-y += tcp_bpf
 
 # Libbpf dependencies
 LIBBPF := ../../tools/lib/bpf/bpf.o
@@ -52,6 +53,7 @@ tracex3-objs := bpf_load.o $(LIBBPF) tracex3_user.o
 tracex4-objs := bpf_load.o $(LIBBPF) tracex4_user.o
 tracex5-objs := bpf_load.o $(LIBBPF) tracex5_user.o
 tracex6-objs := bpf_load.o $(LIBBPF) tracex6_user.o
+tcp_bpf-objs := bpf_load.o $(LIBBPF) tcp_bpf.o
 test_probe_write_user-objs := bpf_load.o $(LIBBPF) test_probe_write_user_user.o
 trace_output-objs := bpf_load.o $(LIBBPF) trace_output_user.o
 lathist-objs := bpf_load.o $(LIBBPF) lathist_user.o
@@ -130,6 +132,7 @@ HOSTLOADLIBES_tracex4 += -lelf -lrt
 HOSTLOADLIBES_tracex5 += -lelf
 HOSTLOADLIBES_tracex6 += -lelf
 HOSTLOADLIBES_test_cgrp2_sock2 += -lelf
+HOSTLOADLIBES_tcp_bpf += -lelf
 HOSTLOADLIBES_test_probe_write_user += -lelf
 HOSTLOADLIBES_trace_output += -lelf -lrt
 HOSTLOADLIBES_lathist += -lelf
diff --git a/samples/bpf/tcp_bpf.c b/samples/bpf/tcp_bpf.c
new file mode 100644
index 0000000..41d2124
--- /dev/null
+++ b/samples/bpf/tcp_bpf.c
@@ -0,0 +1,81 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+#include <unistd.h>
+#include <linux/unistd.h>
+
+static void usage(char *pname)
+{
+	printf("USAGE:\n  %s [-r] [-l] <pname>\n", pname);
+	printf("WHERE:\n");
+	printf("  -r      remove current loaded socketops BPF program\n");
+	printf("          not needed if loading a new program\n");
+	printf("  -l      print out BPF log buffer\n");
+	printf("  <pname> name of BPF sockeops program to load\n");
+	printf("          if <pname> does not end in \".o\", then \"_kern.o\" "
+	       "is appended\n");
+	printf("          example: using tcp1 will load tcp1_kern.o\n");
+	printf("\n");
+	exit(1);
+}
+
+int main(int argc, char **argv)
+{
+	char fn[500];
+	int k, logFlag = 0;
+	int error = -1;
+	union bpf_attr attr;
+
+	if (argc <= 1)
+		usage(argv[0]);
+	for (k = 1; k < argc; k++) {
+		if (!strcmp(argv[k], "-r")) {
+			/* A fd of zero is used as signal to remove the
+			 * current SOCKET_OPS program
+			 */
+			attr.bpf_fd = 0;
+			syscall(__NR_bpf, BPF_PROG_LOAD_SOCKET_OPS, &attr,
+				sizeof(attr));
+		} else if (!strcmp(argv[k], "-l")) {
+			logFlag = 1;
+		} else if (!strcmp(argv[k], "-h")) {
+			usage(argv[0]);
+		} else if (argv[k][0] == '-') {
+			printf("Error, unknown flag: %s\n", argv[k]);
+			exit(2);
+		} else if (strlen(argv[k]) > 450) {
+			printf("Error, program name too long %d\n",
+			       (int) strlen(argv[k]));
+			exit(3);
+		} else {
+			if (!strcmp(argv[k]+strlen(argv[k])-2, ".o"))
+				strcpy(fn, argv[k]);
+			else
+				sprintf(fn, "%s_kern.o", argv[k]);
+			if (logFlag)
+				printf("loading bpf file:%s\n", fn);
+			if (load_bpf_file(fn)) {
+				printf("%s", bpf_log_buf);
+				return 1;
+			}
+			if (logFlag) {
+				printf("TCP BPF Loaded %s\n", fn);
+				printf("%s\n", bpf_log_buf);
+			}
+			attr.bpf_fd = prog_fd[0];
+			error = syscall(__NR_bpf, BPF_PROG_LOAD_SOCKET_OPS,
+					&attr, sizeof(attr));
+			if (error) {
+				printf("ERROR: syscall(BPF_PROG_SOCKET_OPS: %d\n",
+				       error);
+				return 2;
+			}
+			if (logFlag)
+				read_trace_pipe();
+		}
+	}
+	return 0;
+}
-- 
2.9.3
