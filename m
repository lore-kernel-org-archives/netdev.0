From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next 6/7] samples/bpf: xdp_redirect load XDP dummy prog
 on TX device
Date: Tue, 29 Aug 2017 16:38:06 +0200
Message-ID: <150401748630.16384.478521489037692464.stgit@firesoul>
References: <150401743083.16384.15778781741742858567.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50328 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754556AbdH2OiK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 10:38:10 -0400
In-Reply-To: <150401743083.16384.15778781741742858567.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For supporting XDP_REDIRECT, a device driver must (obviously)
implement the "TX" function ndo_xdp_xmit().  An additional requirement
is you cannot TX out a device, unless it also have a xdp bpf program
attached. This dependency is caused by the driver code need to setup
XDP resources before it can ndo_xdp_xmit.

Update bpf samples xdp_redirect and xdp_redirect_map to automatically
attach a dummy XDP program to the configured ifindex_out device.  Use
the XDP flag XDP_FLAGS_UPDATE_IF_NOEXIST on the dummy load, to avoid
overriding an existing XDP prog on the device.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/xdp_redirect_kern.c     |   11 ++++++++++-
 samples/bpf/xdp_redirect_map_kern.c |   11 ++++++++++-
 samples/bpf/xdp_redirect_map_user.c |   22 +++++++++++++++-------
 samples/bpf/xdp_redirect_user.c     |   21 +++++++++++++++------
 4 files changed, 50 insertions(+), 15 deletions(-)

diff --git a/samples/bpf/xdp_redirect_kern.c b/samples/bpf/xdp_redirect_kern.c
index a34ad457a684..1c90288d0203 100644
--- a/samples/bpf/xdp_redirect_kern.c
+++ b/samples/bpf/xdp_redirect_kern.c
@@ -26,6 +26,9 @@ struct bpf_map_def SEC("maps") tx_port = {
 	.max_entries = 1,
 };
 
+/* Count RX packets, as XDP bpf_prog doesn't get direct TX-success
+ * feedback.  Redirect TX errors can be caught via a tracepoint.
+ */
 struct bpf_map_def SEC("maps") rxcnt = {
 	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
 	.key_size = sizeof(u32),
@@ -33,7 +36,6 @@ struct bpf_map_def SEC("maps") rxcnt = {
 	.max_entries = 1,
 };
 
-
 static void swap_src_dst_mac(void *data)
 {
 	unsigned short *p = data;
@@ -78,4 +80,11 @@ int xdp_redirect_prog(struct xdp_md *ctx)
 	return bpf_redirect(*ifindex, 0);
 }
 
+/* Redirect require an XDP bpf_prog loaded on the TX device */
+SEC("xdp_redirect_dummy")
+int xdp_redirect_dummy(struct xdp_md *ctx)
+{
+	return XDP_PASS;
+}
+
 char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/xdp_redirect_map_kern.c b/samples/bpf/xdp_redirect_map_kern.c
index 2faf196e17ea..79795d41ad0d 100644
--- a/samples/bpf/xdp_redirect_map_kern.c
+++ b/samples/bpf/xdp_redirect_map_kern.c
@@ -26,6 +26,9 @@ struct bpf_map_def SEC("maps") tx_port = {
 	.max_entries = 100,
 };
 
+/* Count RX packets, as XDP bpf_prog doesn't get direct TX-success
+ * feedback.  Redirect TX errors can be caught via a tracepoint.
+ */
 struct bpf_map_def SEC("maps") rxcnt = {
 	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
 	.key_size = sizeof(u32),
@@ -33,7 +36,6 @@ struct bpf_map_def SEC("maps") rxcnt = {
 	.max_entries = 1,
 };
 
-
 static void swap_src_dst_mac(void *data)
 {
 	unsigned short *p = data;
@@ -80,4 +82,11 @@ int xdp_redirect_map_prog(struct xdp_md *ctx)
 	return bpf_redirect_map(&tx_port, vport, 0);
 }
 
+/* Redirect require an XDP bpf_prog loaded on the TX device */
+SEC("xdp_redirect_dummy")
+int xdp_redirect_dummy(struct xdp_md *ctx)
+{
+	return XDP_PASS;
+}
+
 char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/xdp_redirect_map_user.c b/samples/bpf/xdp_redirect_map_user.c
index a1ad00fdaa8a..d4d86a273fba 100644
--- a/samples/bpf/xdp_redirect_map_user.c
+++ b/samples/bpf/xdp_redirect_map_user.c
@@ -16,6 +16,7 @@
 #include <signal.h>
 #include <stdio.h>
 #include <stdlib.h>
+#include <stdbool.h>
 #include <string.h>
 #include <unistd.h>
 #include <libgen.h>
@@ -26,17 +27,18 @@
 
 static int ifindex_in;
 static int ifindex_out;
+static bool ifindex_out_xdp_dummy_attached = true;
 
 static __u32 xdp_flags;
 
 static void int_exit(int sig)
 {
 	set_link_xdp_fd(ifindex_in, -1, xdp_flags);
+	if (ifindex_out_xdp_dummy_attached)
+		set_link_xdp_fd(ifindex_out, -1, xdp_flags);
 	exit(0);
 }
 
-/* simple per-protocol drop counter
- */
 static void poll_stats(int interval, int ifindex)
 {
 	unsigned int nr_cpus = bpf_num_possible_cpus();
@@ -70,7 +72,6 @@ static void usage(const char *prog)
 		prog);
 }
 
-
 int main(int argc, char **argv)
 {
 	const char *optstr = "SN";
@@ -112,14 +113,21 @@ int main(int argc, char **argv)
 		return 1;
 	}
 
-	signal(SIGINT, int_exit);
-	signal(SIGTERM, int_exit);
-
 	if (set_link_xdp_fd(ifindex_in, prog_fd[0], xdp_flags) < 0) {
-		printf("link set xdp fd failed\n");
+		printf("ERROR: link set xdp fd failed on %d\n", ifindex_in);
 		return 1;
 	}
 
+	/* Loading dummy XDP prog on out-device */
+	if (set_link_xdp_fd(ifindex_out, prog_fd[1],
+			    (xdp_flags | XDP_FLAGS_UPDATE_IF_NOEXIST)) < 0) {
+		printf("WARN: link set xdp fd failed on %d\n", ifindex_out);
+		ifindex_out_xdp_dummy_attached = false;
+	}
+
+	signal(SIGINT, int_exit);
+	signal(SIGTERM, int_exit);
+
 	printf("map[0] (vports) = %i, map[1] (map) = %i, map[2] (count) = %i\n",
 		map_fd[0], map_fd[1], map_fd[2]);
 
diff --git a/samples/bpf/xdp_redirect_user.c b/samples/bpf/xdp_redirect_user.c
index f705a1905d2d..4475d837bf2c 100644
--- a/samples/bpf/xdp_redirect_user.c
+++ b/samples/bpf/xdp_redirect_user.c
@@ -16,6 +16,7 @@
 #include <signal.h>
 #include <stdio.h>
 #include <stdlib.h>
+#include <stdbool.h>
 #include <string.h>
 #include <unistd.h>
 #include <libgen.h>
@@ -26,17 +27,18 @@
 
 static int ifindex_in;
 static int ifindex_out;
+static bool ifindex_out_xdp_dummy_attached = true;
 
 static __u32 xdp_flags;
 
 static void int_exit(int sig)
 {
 	set_link_xdp_fd(ifindex_in, -1, xdp_flags);
+	if (ifindex_out_xdp_dummy_attached)
+		set_link_xdp_fd(ifindex_out, -1, xdp_flags);
 	exit(0);
 }
 
-/* simple per-protocol drop counter
- */
 static void poll_stats(int interval, int ifindex)
 {
 	unsigned int nr_cpus = bpf_num_possible_cpus();
@@ -112,14 +114,21 @@ int main(int argc, char **argv)
 		return 1;
 	}
 
-	signal(SIGINT, int_exit);
-	signal(SIGTERM, int_exit);
-
 	if (set_link_xdp_fd(ifindex_in, prog_fd[0], xdp_flags) < 0) {
-		printf("link set xdp fd failed\n");
+		printf("ERROR: link set xdp fd failed on %d\n", ifindex_in);
 		return 1;
 	}
 
+	/* Loading dummy XDP prog on out-device */
+	if (set_link_xdp_fd(ifindex_out, prog_fd[1],
+			    (xdp_flags | XDP_FLAGS_UPDATE_IF_NOEXIST)) < 0) {
+		printf("WARN: link set xdp fd failed on %d\n", ifindex_out);
+		ifindex_out_xdp_dummy_attached = false;
+	}
+
+	signal(SIGINT, int_exit);
+	signal(SIGTERM, int_exit);
+
 	/* bpf redirect port */
 	ret = bpf_map_update_elem(map_fd[0], &key, &ifindex_out, 0);
 	if (ret) {
