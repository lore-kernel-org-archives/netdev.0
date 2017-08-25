From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 6/8] samples/bpf: Add option to dump socket settings
Date: Fri, 25 Aug 2017 12:05:39 -0700
Message-ID: <1503687941-626-7-git-send-email-dsahern@gmail.com>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35663 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758131AbdHYTF4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 15:05:56 -0400
Received: by mail-pg0-f66.google.com with SMTP id r133so904751pgr.2
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 12:05:56 -0700 (PDT)
In-Reply-To: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add option to dump socket settings. Will be used in the next patch
to verify bpf programs are correctly setting mark, priority and
device based on the cgroup attachment for the program run.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 samples/bpf/test_cgrp2_sock.c | 75 +++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 73 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
index a1ef7b8bd3f9..eabf530a5223 100644
--- a/samples/bpf/test_cgrp2_sock.c
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -112,6 +112,70 @@ static int prog_load(__u32 idx, __u32 mark, __u32 prio)
 	return ret;
 }
 
+static int get_bind_to_device(int sd, char *name, size_t len)
+{
+	socklen_t optlen = len;
+	int rc;
+
+	name[0] = '\0';
+	rc = getsockopt(sd, SOL_SOCKET, SO_BINDTODEVICE, name, &optlen);
+	if (rc < 0)
+		perror("setsockopt(SO_BINDTODEVICE)");
+
+	return rc;
+}
+
+static unsigned int get_somark(int sd)
+{
+	unsigned int mark = 0;
+	socklen_t optlen = sizeof(mark);
+	int rc;
+
+	rc = getsockopt(sd, SOL_SOCKET, SO_MARK, &mark, &optlen);
+	if (rc < 0)
+		perror("getsockopt(SO_MARK)");
+
+	return mark;
+}
+
+static unsigned int get_priority(int sd)
+{
+	unsigned int prio = 0;
+	socklen_t optlen = sizeof(prio);
+	int rc;
+
+	rc = getsockopt(sd, SOL_SOCKET, SO_PRIORITY, &prio, &optlen);
+	if (rc < 0)
+		perror("getsockopt(SO_PRIORITY)");
+
+	return prio;
+}
+
+static int show_sockopts(int family)
+{
+	unsigned int mark, prio;
+	char name[16];
+	int sd;
+
+	sd = socket(family, SOCK_DGRAM, 17);
+	if (sd < 0) {
+		perror("socket");
+		return 1;
+	}
+
+	if (get_bind_to_device(sd, name, sizeof(name)) < 0)
+		return 1;
+
+	mark = get_somark(sd);
+	prio = get_priority(sd);
+
+	close(sd);
+
+	printf("sd %d: dev %s, mark %u, priority %u\n", sd, name, mark, prio);
+
+	return 0;
+}
+
 static int usage(const char *argv0)
 {
 	printf("Usage:\n");
@@ -120,6 +184,9 @@ static int usage(const char *argv0)
 	printf("\n");
 	printf("  Detach a program\n");
 	printf("  %s -d cg-path\n", argv0);
+	printf("\n");
+	printf("  Show inherited socket settings (mark, priority, and device)\n");
+	printf("  %s [-6]\n", argv0);
 	return EXIT_FAILURE;
 }
 
@@ -129,10 +196,11 @@ int main(int argc, char **argv)
 	__u32 idx = 0, mark = 0, prio = 0;
 	const char *cgrp_path = NULL;
 	int cg_fd, prog_fd, ret;
+	int family = PF_INET;
 	int do_attach = 1;
 	int rc;
 
-	while ((rc = getopt(argc, argv, "db:m:p:r")) != -1) {
+	while ((rc = getopt(argc, argv, "db:m:p:r6")) != -1) {
 		switch (rc) {
 		case 'd':
 			do_attach = 0;
@@ -156,13 +224,16 @@ int main(int argc, char **argv)
 		case 'r':
 			attach_flags |= BPF_F_RECURSIVE;
 			break;
+		case '6':
+			family = PF_INET6;
+			break;
 		default:
 			return usage(argv[0]);
 		}
 	}
 
 	if (optind == argc)
-		return usage(argv[0]);
+		return show_sockopts(family);
 
 	cgrp_path = argv[optind];
 	if (!cgrp_path) {
-- 
2.1.4
