From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/2] samples/bpf: fix SKB_MODE flag to be a 32-bit
 unsigned int
Date: Mon, 01 May 2017 11:26:15 +0200
Message-ID: <149363077553.17600.5609466598508053296.stgit@firesoul>
References: <149363073213.17600.4480290736818479957.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: dsa@cumulusnetworks.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59226 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S376629AbdEAJ0R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 05:26:17 -0400
In-Reply-To: <149363073213.17600.4480290736818479957.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel side of XDP_FLAGS_SKB_MODE is unsigned, and the rtnetlink
IFLA_XDP_FLAGS is defined as NLA_U32. Thus, userspace programs under
samples/bpf/ should use the correct type.

Fixes: 3993f2cb983b ("samples/bpf: Add support for SKB_MODE to xdp1 and xdp_tx_iptunnel")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/bpf_load.c             |    3 ++-
 samples/bpf/bpf_load.h             |    2 +-
 samples/bpf/xdp1_user.c            |    8 ++++----
 samples/bpf/xdp_tx_iptunnel_user.c |    8 ++++----
 4 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 0ec0dea3c41e..4221dc359453 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -14,6 +14,7 @@
 #include <linux/perf_event.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
+#include <linux/types.h>
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/syscall.h>
@@ -585,7 +586,7 @@ struct ksym *ksym_search(long key)
 	return &syms[0];
 }
 
-int set_link_xdp_fd(int ifindex, int fd, int flags)
+int set_link_xdp_fd(int ifindex, int fd, __u32 flags)
 {
 	struct sockaddr_nl sa;
 	int sock, seq = 0, len, ret = -1;
diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index 6bfd75ec6a16..05822f83173a 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -47,5 +47,5 @@ struct ksym {
 
 int load_kallsyms(void);
 struct ksym *ksym_search(long key);
-int set_link_xdp_fd(int ifindex, int fd, int flags);
+int set_link_xdp_fd(int ifindex, int fd, __u32 flags);
 #endif
diff --git a/samples/bpf/xdp1_user.c b/samples/bpf/xdp1_user.c
index deb05e630d84..378850c70eb8 100644
--- a/samples/bpf/xdp1_user.c
+++ b/samples/bpf/xdp1_user.c
@@ -20,11 +20,11 @@
 #include "libbpf.h"
 
 static int ifindex;
-static int flags;
+static __u32 xdp_flags;
 
 static void int_exit(int sig)
 {
-	set_link_xdp_fd(ifindex, -1, flags);
+	set_link_xdp_fd(ifindex, -1, xdp_flags);
 	exit(0);
 }
 
@@ -75,7 +75,7 @@ int main(int argc, char **argv)
 	while ((opt = getopt(argc, argv, optstr)) != -1) {
 		switch (opt) {
 		case 'S':
-			flags |= XDP_FLAGS_SKB_MODE;
+			xdp_flags |= XDP_FLAGS_SKB_MODE;
 			break;
 		default:
 			usage(basename(argv[0]));
@@ -103,7 +103,7 @@ int main(int argc, char **argv)
 
 	signal(SIGINT, int_exit);
 
-	if (set_link_xdp_fd(ifindex, prog_fd[0], flags) < 0) {
+	if (set_link_xdp_fd(ifindex, prog_fd[0], xdp_flags) < 0) {
 		printf("link set xdp fd failed\n");
 		return 1;
 	}
diff --git a/samples/bpf/xdp_tx_iptunnel_user.c b/samples/bpf/xdp_tx_iptunnel_user.c
index cb2bda7b5346..880dd4aebfa4 100644
--- a/samples/bpf/xdp_tx_iptunnel_user.c
+++ b/samples/bpf/xdp_tx_iptunnel_user.c
@@ -142,8 +142,8 @@ int main(int argc, char **argv)
 	struct iptnl_info tnl = {};
 	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 	struct vip vip = {};
+	__u32 xdp_flags = 0;
 	char filename[256];
-	int flags = 0;
 	int opt;
 	int i;
 
@@ -204,7 +204,7 @@ int main(int argc, char **argv)
 			kill_after_s = atoi(optarg);
 			break;
 		case 'S':
-			flags |= XDP_FLAGS_SKB_MODE;
+			xdp_flags |= XDP_FLAGS_SKB_MODE;
 			break;
 		default:
 			usage(argv[0]);
@@ -248,14 +248,14 @@ int main(int argc, char **argv)
 		}
 	}
 
-	if (set_link_xdp_fd(ifindex, prog_fd[0], flags) < 0) {
+	if (set_link_xdp_fd(ifindex, prog_fd[0], xdp_flags) < 0) {
 		printf("link set xdp fd failed\n");
 		return 1;
 	}
 
 	poll_stats(kill_after_s);
 
-	set_link_xdp_fd(ifindex, -1, flags);
+	set_link_xdp_fd(ifindex, -1, xdp_flags);
 
 	return 0;
 }
