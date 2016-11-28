From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next 1/1] samples: bpf: Refactor test_cgrp2_attach -- use
 getopt, and add mode
Date: Mon, 28 Nov 2016 14:52:42 -0800
Message-ID: <20161128225240.GA8761@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@zonque.org, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35375 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755440AbcK1Wwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 17:52:45 -0500
Received: by mail-io0-f173.google.com with SMTP id a124so258233463ioe.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 14:52:45 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies test_cgrp2_attach to use getopt so we can use standard
command line parsing.

It also adds an option to run the program in detach only mode. This does
not attach a new filter at the cgroup, but only runs the detach command.

Lastly, it changes the attach code to not detach and then attach. It relies
on the 'hotswap' behaviour of CGroup BPF programs to be able to change
in-place. If detach-then-attach behaviour needs to be tested, the example
can be run in detach only mode prior to attachment.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 samples/bpf/test_cgrp2_attach.c | 80 +++++++++++++++++++++++++----------------
 1 file changed, 50 insertions(+), 30 deletions(-)

diff --git a/samples/bpf/test_cgrp2_attach.c b/samples/bpf/test_cgrp2_attach.c
index 63ef208..a19484c 100644
--- a/samples/bpf/test_cgrp2_attach.c
+++ b/samples/bpf/test_cgrp2_attach.c
@@ -10,8 +10,6 @@
  *   incremented on each iteration by the number of bytes stored in
  *   the skb.
  *
- * - Detaches any eBPF program previously attached to the cgroup
- *
  * - Attaches the new program to a cgroup using BPF_PROG_ATTACH
  *
  * - Every second, reads map[0] and map[1] to see how many bytes and
@@ -75,35 +73,16 @@ static int prog_load(int map_fd, int verdict)
 
 static int usage(const char *argv0)
 {
-	printf("Usage: %s <cg-path> <egress|ingress> [drop]\n", argv0);
+	printf("Usage: %s [-d] [-D] <cg-path> <egress|ingress>\n", argv0);
+	printf("	-d	Drop Traffic\n");
+	printf("	-D	Detach filter, and exit\n");
 	return EXIT_FAILURE;
 }
 
-int main(int argc, char **argv)
+static int attach_filter(int cg_fd, int type, int verdict)
 {
-	int cg_fd, map_fd, prog_fd, key, ret;
+	int prog_fd, map_fd, ret, key;
 	long long pkt_cnt, byte_cnt;
-	enum bpf_attach_type type;
-	int verdict = 1;
-
-	if (argc < 3)
-		return usage(argv[0]);
-
-	if (strcmp(argv[2], "ingress") == 0)
-		type = BPF_CGROUP_INET_INGRESS;
-	else if (strcmp(argv[2], "egress") == 0)
-		type = BPF_CGROUP_INET_EGRESS;
-	else
-		return usage(argv[0]);
-
-	if (argc > 3 && strcmp(argv[3], "drop") == 0)
-		verdict = 0;
-
-	cg_fd = open(argv[1], O_DIRECTORY | O_RDONLY);
-	if (cg_fd < 0) {
-		printf("Failed to open cgroup path: '%s'\n", strerror(errno));
-		return EXIT_FAILURE;
-	}
 
 	map_fd = bpf_create_map(BPF_MAP_TYPE_ARRAY,
 				sizeof(key), sizeof(byte_cnt),
@@ -121,16 +100,12 @@ int main(int argc, char **argv)
 		return EXIT_FAILURE;
 	}
 
-	ret = bpf_prog_detach(cg_fd, type);
-	printf("bpf_prog_detach() returned '%s' (%d)\n", strerror(errno), errno);
-
 	ret = bpf_prog_attach(prog_fd, cg_fd, type);
 	if (ret < 0) {
 		printf("Failed to attach prog to cgroup: '%s'\n",
 		       strerror(errno));
 		return EXIT_FAILURE;
 	}
-
 	while (1) {
 		key = MAP_KEY_PACKETS;
 		assert(bpf_lookup_elem(map_fd, &key, &pkt_cnt) == 0);
@@ -145,3 +120,48 @@ int main(int argc, char **argv)
 
 	return EXIT_SUCCESS;
 }
+
+int main(int argc, char **argv)
+{
+	int detach_only = 0, verdict = 1;
+	enum bpf_attach_type type;
+	int opt, cg_fd, ret;
+
+	while ((opt = getopt(argc, argv, "Dd")) != -1) {
+		switch (opt) {
+		case 'd':
+			verdict = 0;
+			break;
+		case 'D':
+			detach_only = 1;
+			break;
+		default:
+			return usage(argv[0]);
+		}
+	}
+
+	if (argc - optind < 2)
+		return usage(argv[0]);
+
+	if (strcmp(argv[optind + 1], "ingress") == 0)
+		type = BPF_CGROUP_INET_INGRESS;
+	else if (strcmp(argv[optind + 1], "egress") == 0)
+		type = BPF_CGROUP_INET_EGRESS;
+	else
+		return usage(argv[0]);
+
+	cg_fd = open(argv[optind], O_DIRECTORY | O_RDONLY);
+	if (cg_fd < 0) {
+		printf("Failed to open cgroup path: '%s'\n", strerror(errno));
+		return EXIT_FAILURE;
+	}
+
+	if (detach_only) {
+		ret = bpf_prog_detach(cg_fd, type);
+		printf("bpf_prog_detach() returned '%s' (%d)\n",
+		       strerror(errno), errno);
+	} else
+		ret = attach_filter(cg_fd, type, verdict);
+
+	return ret;
+}
-- 
2.7.4
