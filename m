From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 6/6] net: Add chvrf command
Date: Mon,  6 Jul 2015 09:03:20 -0600
Message-ID: <1436195001-4818-7-git-send-email-dsa@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:35278 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099AbbGFPDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:03:42 -0400
Received: by iecuq6 with SMTP id uq6so115029772iec.2
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 08:03:41 -0700 (PDT)
In-Reply-To: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Example of how to use the default bind to interface option for tasks and
correlate with VRF devices.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 tools/net/Makefile |   6 +-
 tools/net/chvrf.c  | 225 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 229 insertions(+), 2 deletions(-)
 create mode 100644 tools/net/chvrf.c

diff --git a/tools/net/Makefile b/tools/net/Makefile
index ee577ea03ba5..c13f11f5637a 100644
--- a/tools/net/Makefile
+++ b/tools/net/Makefile
@@ -10,7 +10,7 @@ YACC = bison
 %.lex.c: %.l
 	$(LEX) -o $@ $<
 
-all : bpf_jit_disasm bpf_dbg bpf_asm
+all : bpf_jit_disasm bpf_dbg bpf_asm chvrf
 
 bpf_jit_disasm : CFLAGS = -Wall -O2 -DPACKAGE='bpf_jit_disasm'
 bpf_jit_disasm : LDLIBS = -lopcodes -lbfd -ldl
@@ -25,8 +25,10 @@ bpf_asm : LDLIBS =
 bpf_asm : bpf_asm.o bpf_exp.yacc.o bpf_exp.lex.o
 bpf_exp.lex.o : bpf_exp.yacc.c
 
+chvrf : CFLAGS = -Wall -O2
+
 clean :
-	rm -rf *.o bpf_jit_disasm bpf_dbg bpf_asm bpf_exp.yacc.* bpf_exp.lex.*
+	rm -rf *.o bpf_jit_disasm bpf_dbg bpf_asm bpf_exp.yacc.* bpf_exp.lex.* chvrf
 
 install :
 	install bpf_jit_disasm $(prefix)/bin/bpf_jit_disasm
diff --git a/tools/net/chvrf.c b/tools/net/chvrf.c
new file mode 100644
index 000000000000..71cc925fd101
--- /dev/null
+++ b/tools/net/chvrf.c
@@ -0,0 +1,225 @@
+/*
+ * chvrf.c - Example of how to use the default bind-to-device option for
+ *           tasks and correlate to VRFs via the VRF device.
+ *
+ * Copyright (c) 2015 Cumulus Networks
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#include <sys/ioctl.h>
+#include <sys/prctl.h>
+#include <sys/socket.h>
+#include <signal.h>
+#include <string.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <netinet/in.h>
+#include <net/if.h> /* for struct ifreq  */
+#include <libgen.h>
+#include <errno.h>
+
+#ifndef PR_SET_SK_BIND_DEV_IF
+#define PR_SET_SK_BIND_DEV_IF   47
+#endif
+#ifndef PR_GET_SK_BIND_DEV_IF
+#define PR_GET_SK_BIND_DEV_IF   48
+#endif
+
+static int vrf_to_device(int vrf)
+{
+	struct ifreq ifdata;
+	int sd, rc;
+
+	memset(&ifdata, 0, sizeof(ifdata));
+	snprintf(ifdata.ifr_name, sizeof(ifdata.ifr_name) - 1, "vrf%d", vrf);
+
+	sd = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
+	if (sd < 0) {
+		perror("socket failed");
+		return -1;
+	}
+
+	/* Get the index for the specified interface */
+	rc = ioctl(sd, SIOCGIFINDEX, (char *)&ifdata);
+	close(sd);
+	if (rc != 0) {
+		perror("ioctl(SIOCGIFINDEX) failed");
+		return -1;
+	}
+
+	return ifdata.ifr_ifindex;
+}
+
+static int device_to_vrf(int idx)
+{
+	struct ifreq ifdata;
+	int sd, vrf, rc;
+
+	memset(&ifdata, 0, sizeof(ifdata));
+	ifdata.ifr_ifindex = idx;
+
+	sd = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
+	if (sd < 0) {
+		perror("socket failed");
+		return -1;
+	}
+
+	/* Get the index for the specified interface */
+	rc = ioctl(sd, SIOCGIFNAME, (char *)&ifdata);
+	close(sd);
+	if (rc != 0) {
+		perror("ioctl(SIOCGIFNAME) failed");
+		return -1;
+	}
+
+	if (sscanf(ifdata.ifr_name, "vrf%d", &vrf) != 1) {
+		fprintf(stderr, "Unexpected device name (%s)\n", ifdata.ifr_name);
+		vrf = -1;
+	}
+
+	return vrf;
+}
+
+static int set_vrf(int vrf)
+{
+	int idx;
+	long err;
+
+	/* convert vrf to device index */
+	idx = vrf_to_device(vrf);
+	if (idx < 0) {
+		fprintf(stderr, "Failed to get device index for vrf %d\n", vrf);
+		return -1;
+	}
+
+	/* set default device bind */
+	err = prctl(PR_SET_SK_BIND_DEV_IF, idx);
+	if (err < 0) {
+		fprintf(stderr, "prctl failed to device index: %d\n", errno);
+		return -1;
+	}
+
+	return 0;
+}
+
+/* get vrf context for given process id */
+static int get_vrf(pid_t pid)
+{
+	int vrf;
+	long err;
+
+	/* lookup device index pid is tied to */
+	err = prctl(PR_GET_SK_BIND_DEV_IF, pid);
+	if (err < 0) {
+		fprintf(stderr, "prctl failed: %d\n", errno);
+		return -1;
+	}
+
+	if (err == 0)
+		return 0;
+
+	/* convert device index to vrf id */
+	vrf = device_to_vrf((int)err);
+	if (vrf < 0) {
+		fprintf(stderr, "Failed to get device index for vrf %d\n", vrf);
+		return -1;
+	}
+
+	return vrf;
+}
+
+static int run_vrf(char **argv, int vrf)
+{
+	char *cmd;
+
+	if (set_vrf(vrf) != 0) {
+		fprintf(stderr, "Failed to set vrf context\n");
+		return 1;
+	}
+
+	cmd = strdup(argv[0]);
+	if (!cmd) {
+		fprintf(stderr, "Failed to set command\n");
+		return 1;
+	}
+	argv[0] = basename(argv[0]);
+	if (execvp(cmd, argv) < 0)
+		perror("Failed to exec command\n");
+
+	return 1;
+}
+
+static int show_vrf(pid_t pid)
+{
+	int vrf = get_vrf(pid);
+
+	switch (vrf) {
+	case -1:
+		fprintf(stderr, "Failed to get vrf context for pid %d\n", pid);
+		if (kill(pid, 0) < 0) {
+			if (errno == ESRCH)
+				fprintf(stderr, "No process with given pid\n");
+		}
+		break;
+	case 0:
+		printf("Process %d is not running in a VRF context\n", pid);
+		break;
+	default:
+		printf("Process %d is running in VRF %d\n", pid, vrf);
+	}
+	return vrf < 0 ? 1 : 0;
+}
+
+static void usage(char *_prog)
+{
+	const char *prog = basename(_prog);
+
+	fprintf(stderr, "usage:\n");
+	fprintf(stderr, "\nShow VRF context for given pid\n");
+	fprintf(stderr, "\t%s -p pid\n", prog);
+	fprintf(stderr, "\nRun command in given VRF context\n");
+	fprintf(stderr, "\t%s -v vrf <command>\n", prog);
+}
+
+int main(int argc, char *argv[])
+{
+	int rc;
+	pid_t pid = 0;
+	int vrf = 0;
+
+	extern char *optarg;
+	extern int optind;
+
+	while ((rc = getopt(argc, argv, "+:p:v:")) != -1) {
+		switch (rc) {
+		case 'p':
+			pid = atoi(optarg);
+			break;
+		case 'v':
+			vrf = atoi(optarg);
+			break;
+		default:
+			usage(argv[0]);
+			return 1;
+		}
+	}
+
+	if ((pid && vrf) || (!pid && !vrf)) {
+		usage(argv[0]);
+		return 1;
+	}
+
+	if (pid)
+		return show_vrf(pid);
+
+	if (optind == argc) {
+		usage(argv[0]);
+		return 1;
+	}
+
+	return run_vrf(&argv[optind], vrf);
+}
-- 
2.3.2 (Apple Git-55)
