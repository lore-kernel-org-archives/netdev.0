From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next] samples/bpf: add option for native and skb mode for redirect apps
Date: Mon, 17 Jul 2017 16:14:19 -0400
Message-ID: <1500322459-3743-1-git-send-email-andy@greyhouse.net>
Cc: John Fastabend <john.fastabend@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35362 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751325AbdGQUOr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 16:14:47 -0400
Received: by mail-qk0-f195.google.com with SMTP id z22so54896qka.2
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 13:14:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When testing with a driver that has both native and generic redirect support:

$ sudo ./samples/bpf/xdp_redirect -N 5 6
input: 5 output: 6
ifindex 6:    4961879 pkt/s
ifindex 6:    6391319 pkt/s
ifindex 6:    6419468 pkt/s

$ sudo ./samples/bpf/xdp_redirect -S 5 6
input: 5 output: 6
ifindex 6:    1845435 pkt/s
ifindex 6:    3882850 pkt/s
ifindex 6:    3893974 pkt/s

$ sudo ./samples/bpf/xdp_redirect_map -N 5 6
input: 5 output: 6
map[0] (vports) = 4, map[1] (map) = 5, map[2] (count) = 0
ifindex 6:    2207374 pkt/s
ifindex 6:    6212869 pkt/s
ifindex 6:    6286515 pkt/s

$ sudo ./samples/bpf/xdp_redirect_map -S 5 6
input: 5 output: 6
map[0] (vports) = 4, map[1] (map) = 5, map[2] (count) = 0
ifindex 6:    5052528 pkt/s
ifindex 6:    5736631 pkt/s
ifindex 6:    5739962 pkt/s

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---
 samples/bpf/xdp_redirect_map_user.c | 50 ++++++++++++++++++++++++++++++-------
 samples/bpf/xdp_redirect_user.c     | 50 ++++++++++++++++++++++++++++++-------
 2 files changed, 82 insertions(+), 18 deletions(-)

diff --git a/samples/bpf/xdp_redirect_map_user.c b/samples/bpf/xdp_redirect_map_user.c
index 0b8009a..a1ad00f 100644
--- a/samples/bpf/xdp_redirect_map_user.c
+++ b/samples/bpf/xdp_redirect_map_user.c
@@ -10,6 +10,7 @@
  * General Public License for more details.
  */
 #include <linux/bpf.h>
+#include <linux/if_link.h>
 #include <assert.h>
 #include <errno.h>
 #include <signal.h>
@@ -17,6 +18,7 @@
 #include <stdlib.h>
 #include <string.h>
 #include <unistd.h>
+#include <libgen.h>
 
 #include "bpf_load.h"
 #include "bpf_util.h"
@@ -25,9 +27,11 @@
 static int ifindex_in;
 static int ifindex_out;
 
+static __u32 xdp_flags;
+
 static void int_exit(int sig)
 {
-	set_link_xdp_fd(ifindex_in, -1, 0);
+	set_link_xdp_fd(ifindex_in, -1, xdp_flags);
 	exit(0);
 }
 
@@ -56,20 +60,47 @@ static void poll_stats(int interval, int ifindex)
 	}
 }
 
-int main(int ac, char **argv)
+static void usage(const char *prog)
 {
-	char filename[256];
-	int ret, key = 0;
+	fprintf(stderr,
+		"usage: %s [OPTS] IFINDEX_IN IFINDEX_OUT\n\n"
+		"OPTS:\n"
+		"    -S    use skb-mode\n"
+		"    -N    enforce native mode\n",
+		prog);
+}
 
-	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
 
-	if (ac != 3) {
+int main(int argc, char **argv)
+{
+	const char *optstr = "SN";
+	char filename[256];
+	int ret, opt, key = 0;
+
+	while ((opt = getopt(argc, argv, optstr)) != -1) {
+		switch (opt) {
+		case 'S':
+			xdp_flags |= XDP_FLAGS_SKB_MODE;
+			break;
+		case 'N':
+			xdp_flags |= XDP_FLAGS_DRV_MODE;
+			break;
+		default:
+			usage(basename(argv[0]));
+			return 1;
+		}
+	}
+
+	if (optind == argc) {
 		printf("usage: %s IFINDEX_IN IFINDEX_OUT\n", argv[0]);
 		return 1;
 	}
 
-	ifindex_in = strtoul(argv[1], NULL, 0);
-	ifindex_out = strtoul(argv[2], NULL, 0);
+	ifindex_in = strtoul(argv[optind], NULL, 0);
+	ifindex_out = strtoul(argv[optind + 1], NULL, 0);
+	printf("input: %d output: %d\n", ifindex_in, ifindex_out);
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
 
 	if (load_bpf_file(filename)) {
 		printf("%s", bpf_log_buf);
@@ -82,8 +113,9 @@ int main(int ac, char **argv)
 	}
 
 	signal(SIGINT, int_exit);
+	signal(SIGTERM, int_exit);
 
-	if (set_link_xdp_fd(ifindex_in, prog_fd[0], 0) < 0) {
+	if (set_link_xdp_fd(ifindex_in, prog_fd[0], xdp_flags) < 0) {
 		printf("link set xdp fd failed\n");
 		return 1;
 	}
diff --git a/samples/bpf/xdp_redirect_user.c b/samples/bpf/xdp_redirect_user.c
index 761a91d..f705a19 100644
--- a/samples/bpf/xdp_redirect_user.c
+++ b/samples/bpf/xdp_redirect_user.c
@@ -10,6 +10,7 @@
  * General Public License for more details.
  */
 #include <linux/bpf.h>
+#include <linux/if_link.h>
 #include <assert.h>
 #include <errno.h>
 #include <signal.h>
@@ -17,6 +18,7 @@
 #include <stdlib.h>
 #include <string.h>
 #include <unistd.h>
+#include <libgen.h>
 
 #include "bpf_load.h"
 #include "bpf_util.h"
@@ -25,9 +27,11 @@
 static int ifindex_in;
 static int ifindex_out;
 
+static __u32 xdp_flags;
+
 static void int_exit(int sig)
 {
-	set_link_xdp_fd(ifindex_in, -1, 0);
+	set_link_xdp_fd(ifindex_in, -1, xdp_flags);
 	exit(0);
 }
 
@@ -56,20 +60,47 @@ static void poll_stats(int interval, int ifindex)
 	}
 }
 
-int main(int ac, char **argv)
+static void usage(const char *prog)
 {
-	char filename[256];
-	int ret, key = 0;
+	fprintf(stderr,
+		"usage: %s [OPTS] IFINDEX_IN IFINDEX_OUT\n\n"
+		"OPTS:\n"
+		"    -S    use skb-mode\n"
+		"    -N    enforce native mode\n",
+		prog);
+}
 
-	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
 
-	if (ac != 3) {
+int main(int argc, char **argv)
+{
+	const char *optstr = "SN";
+	char filename[256];
+	int ret, opt, key = 0;
+
+	while ((opt = getopt(argc, argv, optstr)) != -1) {
+		switch (opt) {
+		case 'S':
+			xdp_flags |= XDP_FLAGS_SKB_MODE;
+			break;
+		case 'N':
+			xdp_flags |= XDP_FLAGS_DRV_MODE;
+			break;
+		default:
+			usage(basename(argv[0]));
+			return 1;
+		}
+	}
+
+	if (optind == argc) {
 		printf("usage: %s IFINDEX_IN IFINDEX_OUT\n", argv[0]);
 		return 1;
 	}
 
-	ifindex_in = strtoul(argv[1], NULL, 0);
-	ifindex_out = strtoul(argv[2], NULL, 0);
+	ifindex_in = strtoul(argv[optind], NULL, 0);
+	ifindex_out = strtoul(argv[optind + 1], NULL, 0);
+	printf("input: %d output: %d\n", ifindex_in, ifindex_out);
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
 
 	if (load_bpf_file(filename)) {
 		printf("%s", bpf_log_buf);
@@ -82,8 +113,9 @@ int main(int ac, char **argv)
 	}
 
 	signal(SIGINT, int_exit);
+	signal(SIGTERM, int_exit);
 
-	if (set_link_xdp_fd(ifindex_in, prog_fd[0], 0) < 0) {
+	if (set_link_xdp_fd(ifindex_in, prog_fd[0], xdp_flags) < 0) {
 		printf("link set xdp fd failed\n");
 		return 1;
 	}
-- 
2.7.4
