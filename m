From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v3 net-next 4/7] samples/bpf: Add detach option to test_cgrp2_sock
Date: Thu, 31 Aug 2017 15:05:47 -0700
Message-ID: <1504217150-16151-5-git-send-email-dsahern@gmail.com>
References: <1504217150-16151-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36323 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751409AbdHaWGM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 18:06:12 -0400
Received: by mail-pf0-f196.google.com with SMTP id k3so530106pfc.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 15:06:12 -0700 (PDT)
In-Reply-To: <1504217150-16151-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add option to detach programs from a cgroup.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 samples/bpf/test_cgrp2_sock.c | 50 ++++++++++++++++++++++++++++++-------------
 1 file changed, 35 insertions(+), 15 deletions(-)

diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
index 681abbe6c85e..15396761c5cc 100644
--- a/samples/bpf/test_cgrp2_sock.c
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -114,7 +114,12 @@ static int prog_load(__u32 idx, __u32 mark, __u32 prio)
 
 static int usage(const char *argv0)
 {
-	printf("Usage: %s -b bind-to-dev -m mark -p prio cg-path\n", argv0);
+	printf("Usage:\n");
+	printf("  Attach a program\n");
+	printf("  %s -b bind-to-dev -m mark -p prio cg-path\n", argv0);
+	printf("\n");
+	printf("  Detach a program\n");
+	printf("  %s -d cg-path\n", argv0);
 	return EXIT_FAILURE;
 }
 
@@ -123,10 +128,14 @@ int main(int argc, char **argv)
 	__u32 idx = 0, mark = 0, prio = 0;
 	const char *cgrp_path = NULL;
 	int cg_fd, prog_fd, ret;
+	int do_attach = 1;
 	int rc;
 
-	while ((rc = getopt(argc, argv, "b:m:p:")) != -1) {
+	while ((rc = getopt(argc, argv, "db:m:p:")) != -1) {
 		switch (rc) {
+		case 'd':
+			do_attach = 0;
+			break;
 		case 'b':
 			idx = if_nametoindex(optarg);
 			if (!idx) {
@@ -157,7 +166,7 @@ int main(int argc, char **argv)
 		return EXIT_FAILURE;
 	}
 
-	if (!idx && !mark && !prio) {
+	if (do_attach && !idx && !mark && !prio) {
 		fprintf(stderr,
 			"One of device, mark or priority must be given\n");
 		return EXIT_FAILURE;
@@ -169,20 +178,31 @@ int main(int argc, char **argv)
 		return EXIT_FAILURE;
 	}
 
-	prog_fd = prog_load(idx, mark, prio);
-	if (prog_fd < 0) {
-		printf("Failed to load prog: '%s'\n", strerror(errno));
-		printf("Output from kernel verifier:\n%s\n-------\n",
-		       bpf_log_buf);
-		return EXIT_FAILURE;
-	}
+	if (do_attach) {
+		prog_fd = prog_load(idx, mark, prio);
+		if (prog_fd < 0) {
+			printf("Failed to load prog: '%s'\n", strerror(errno));
+			printf("Output from kernel verifier:\n%s\n-------\n",
+			       bpf_log_buf);
+			return EXIT_FAILURE;
+		}
 
-	ret = bpf_prog_attach(prog_fd, cg_fd, BPF_CGROUP_INET_SOCK_CREATE, 0);
-	if (ret < 0) {
-		printf("Failed to attach prog to cgroup: '%s'\n",
-		       strerror(errno));
-		return EXIT_FAILURE;
+		ret = bpf_prog_attach(prog_fd, cg_fd,
+				      BPF_CGROUP_INET_SOCK_CREATE, 0);
+		if (ret < 0) {
+			printf("Failed to attach prog to cgroup: '%s'\n",
+			       strerror(errno));
+			return EXIT_FAILURE;
+		}
+	} else {
+		ret = bpf_prog_detach(cg_fd, BPF_CGROUP_INET_SOCK_CREATE);
+		if (ret < 0) {
+			printf("Failed to detach prog from cgroup: '%s'\n",
+			       strerror(errno));
+			return EXIT_FAILURE;
+		}
 	}
 
+	close(cg_fd);
 	return EXIT_SUCCESS;
 }
-- 
2.1.4
