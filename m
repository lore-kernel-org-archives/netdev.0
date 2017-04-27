From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] samples/bpf: Add support for SKB_MODE to xdp1 and xdp_tx_iptunnel
Date: Thu, 27 Apr 2017 09:11:13 -0700
Message-ID: <1493309473-27384-1-git-send-email-dsa@cumulusnetworks.com>
Cc: ast@fb.com, daniel@iogearbox.net,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34042 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755467AbdD0QLV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 12:11:21 -0400
Received: by mail-pf0-f181.google.com with SMTP id c198so31289296pfc.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 09:11:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add option to xdp1 and xdp_tx_iptunnel to insert xdp program in
SKB_MODE:
 - update set_link_xdp_fd to take a flags argument that is added to the
   RTM_SETLINK message

 - Add -S option to xdp1 and xdp_tx_iptunnel user code. When passed in
   XDP_FLAGS_SKB_MODE is set in the flags arg passed to set_link_xdp_fd

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 samples/bpf/bpf_load.c             | 19 +++++++++++++++---
 samples/bpf/bpf_load.h             |  2 +-
 samples/bpf/xdp1_user.c            | 40 ++++++++++++++++++++++++++++++--------
 samples/bpf/xdp_tx_iptunnel_user.c | 13 +++++++++----
 4 files changed, 58 insertions(+), 16 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 0d449d8032d1..d4433a47e6c3 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -563,7 +563,7 @@ struct ksym *ksym_search(long key)
 	return &syms[0];
 }
 
-int set_link_xdp_fd(int ifindex, int fd)
+int set_link_xdp_fd(int ifindex, int fd, int flags)
 {
 	struct sockaddr_nl sa;
 	int sock, seq = 0, len, ret = -1;
@@ -599,15 +599,28 @@ int set_link_xdp_fd(int ifindex, int fd)
 	req.nh.nlmsg_seq = ++seq;
 	req.ifinfo.ifi_family = AF_UNSPEC;
 	req.ifinfo.ifi_index = ifindex;
+
+	/* started nested attribute for XDP */
 	nla = (struct nlattr *)(((char *)&req)
 				+ NLMSG_ALIGN(req.nh.nlmsg_len));
 	nla->nla_type = NLA_F_NESTED | 43/*IFLA_XDP*/;
+	nla->nla_len = NLA_HDRLEN;
 
-	nla_xdp = (struct nlattr *)((char *)nla + NLA_HDRLEN);
+	/* add XDP fd */
+	nla_xdp = (struct nlattr *)((char *)nla + nla->nla_len);
 	nla_xdp->nla_type = 1/*IFLA_XDP_FD*/;
 	nla_xdp->nla_len = NLA_HDRLEN + sizeof(int);
 	memcpy((char *)nla_xdp + NLA_HDRLEN, &fd, sizeof(fd));
-	nla->nla_len = NLA_HDRLEN + nla_xdp->nla_len;
+	nla->nla_len += nla_xdp->nla_len;
+
+	/* if user passed in any flags, add those too */
+	if (flags) {
+		nla_xdp = (struct nlattr *)((char *)nla + nla->nla_len);
+		nla_xdp->nla_type = 3/*IFLA_XDP_FLAGS*/;
+		nla_xdp->nla_len = NLA_HDRLEN + sizeof(flags);
+		memcpy((char *)nla_xdp + NLA_HDRLEN, &flags, sizeof(flags));
+		nla->nla_len += nla_xdp->nla_len;
+	}
 
 	req.nh.nlmsg_len += NLA_ALIGN(nla->nla_len);
 
diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index 68f6b2d22507..6bfd75ec6a16 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -47,5 +47,5 @@ struct ksym {
 
 int load_kallsyms(void);
 struct ksym *ksym_search(long key);
-int set_link_xdp_fd(int ifindex, int fd);
+int set_link_xdp_fd(int ifindex, int fd, int flags);
 #endif
diff --git a/samples/bpf/xdp1_user.c b/samples/bpf/xdp1_user.c
index d2be65d1fd86..deb05e630d84 100644
--- a/samples/bpf/xdp1_user.c
+++ b/samples/bpf/xdp1_user.c
@@ -5,6 +5,7 @@
  * License as published by the Free Software Foundation.
  */
 #include <linux/bpf.h>
+#include <linux/if_link.h>
 #include <assert.h>
 #include <errno.h>
 #include <signal.h>
@@ -12,16 +13,18 @@
 #include <stdlib.h>
 #include <string.h>
 #include <unistd.h>
+#include <libgen.h>
 
 #include "bpf_load.h"
 #include "bpf_util.h"
 #include "libbpf.h"
 
 static int ifindex;
+static int flags;
 
 static void int_exit(int sig)
 {
-	set_link_xdp_fd(ifindex, -1);
+	set_link_xdp_fd(ifindex, -1, flags);
 	exit(0);
 }
 
@@ -54,18 +57,39 @@ static void poll_stats(int interval)
 	}
 }
 
-int main(int ac, char **argv)
+static void usage(const char *prog)
 {
-	char filename[256];
+	fprintf(stderr,
+		"usage: %s [OPTS] IFINDEX\n\n"
+		"OPTS:\n"
+		"    -S    use skb-mode\n",
+		prog);
+}
 
-	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+int main(int argc, char **argv)
+{
+	const char *optstr = "S";
+	char filename[256];
+	int opt;
+
+	while ((opt = getopt(argc, argv, optstr)) != -1) {
+		switch (opt) {
+		case 'S':
+			flags |= XDP_FLAGS_SKB_MODE;
+			break;
+		default:
+			usage(basename(argv[0]));
+			return 1;
+		}
+	}
 
-	if (ac != 2) {
-		printf("usage: %s IFINDEX\n", argv[0]);
+	if (optind == argc) {
+		usage(basename(argv[0]));
 		return 1;
 	}
+	ifindex = strtoul(argv[optind], NULL, 0);
 
-	ifindex = strtoul(argv[1], NULL, 0);
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
 
 	if (load_bpf_file(filename)) {
 		printf("%s", bpf_log_buf);
@@ -79,7 +103,7 @@ int main(int ac, char **argv)
 
 	signal(SIGINT, int_exit);
 
-	if (set_link_xdp_fd(ifindex, prog_fd[0]) < 0) {
+	if (set_link_xdp_fd(ifindex, prog_fd[0], flags) < 0) {
 		printf("link set xdp fd failed\n");
 		return 1;
 	}
diff --git a/samples/bpf/xdp_tx_iptunnel_user.c b/samples/bpf/xdp_tx_iptunnel_user.c
index 70e192fc61aa..cb2bda7b5346 100644
--- a/samples/bpf/xdp_tx_iptunnel_user.c
+++ b/samples/bpf/xdp_tx_iptunnel_user.c
@@ -5,6 +5,7 @@
  * License as published by the Free Software Foundation.
  */
 #include <linux/bpf.h>
+#include <linux/if_link.h>
 #include <assert.h>
 #include <errno.h>
 #include <signal.h>
@@ -28,7 +29,7 @@ static int ifindex = -1;
 static void int_exit(int sig)
 {
 	if (ifindex > -1)
-		set_link_xdp_fd(ifindex, -1);
+		set_link_xdp_fd(ifindex, -1, 0);
 	exit(0);
 }
 
@@ -136,12 +137,13 @@ int main(int argc, char **argv)
 {
 	unsigned char opt_flags[256] = {};
 	unsigned int kill_after_s = 0;
-	const char *optstr = "i:a:p:s:d:m:T:P:h";
+	const char *optstr = "i:a:p:s:d:m:T:P:Sh";
 	int min_port = 0, max_port = 0;
 	struct iptnl_info tnl = {};
 	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 	struct vip vip = {};
 	char filename[256];
+	int flags = 0;
 	int opt;
 	int i;
 
@@ -201,6 +203,9 @@ int main(int argc, char **argv)
 		case 'T':
 			kill_after_s = atoi(optarg);
 			break;
+		case 'S':
+			flags |= XDP_FLAGS_SKB_MODE;
+			break;
 		default:
 			usage(argv[0]);
 			return 1;
@@ -243,14 +248,14 @@ int main(int argc, char **argv)
 		}
 	}
 
-	if (set_link_xdp_fd(ifindex, prog_fd[0]) < 0) {
+	if (set_link_xdp_fd(ifindex, prog_fd[0], flags) < 0) {
 		printf("link set xdp fd failed\n");
 		return 1;
 	}
 
 	poll_stats(kill_after_s);
 
-	set_link_xdp_fd(ifindex, -1);
+	set_link_xdp_fd(ifindex, -1, flags);
 
 	return 0;
 }
-- 
2.1.4
