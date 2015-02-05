From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 28/29] iproute2: vrf: Add vrf subcommand
Date: Wed,  4 Feb 2015 18:34:29 -0700
Message-ID: <1423100070-31848-29-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:48737 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756380AbbBEBgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:17 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so35416494iga.1
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:17 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vrf subcommand with exec option to run a process in a specific VRF
context. Similar to ip netns subcommand.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 ip/Makefile    |   2 +-
 ip/ip.c        |   3 +-
 ip/ip_common.h |   1 +
 ip/ipvrf.c     | 109 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 113 insertions(+), 2 deletions(-)
 create mode 100644 ip/ipvrf.c

diff --git a/ip/Makefile b/ip/Makefile
index 2c742f305fef..4d44906802bd 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -1,4 +1,4 @@
-IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
+IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o ipvrf.o \
     rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o iptoken.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
diff --git a/ip/ip.c b/ip/ip.c
index 850a001756af..80d90a409541 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -48,7 +48,7 @@ static void usage(void)
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm |\n"
-"                   netns | l2tp | fou | tcp_metrics | token | netconf }\n"
+"                   netns | vrf | l2tp | fou | tcp_metrics | token | netconf }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -h[uman-readable] | -iec |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |\n"
@@ -93,6 +93,7 @@ static const struct cmd {
 	{ "mroute",	do_multiroute },
 	{ "mrule",	do_multirule },
 	{ "netns",	do_netns },
+	{ "vrf",	do_vrf },
 	{ "netconf",	do_ipnetconf },
 	{ "help",	do_help },
 	{ 0 }
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 89a495ea1074..499f9f34cd36 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -49,6 +49,7 @@ extern int do_multiaddr(int argc, char **argv);
 extern int do_multiroute(int argc, char **argv);
 extern int do_multirule(int argc, char **argv);
 extern int do_netns(int argc, char **argv);
+extern int do_vrf(int argc, char **argv);
 extern int do_xfrm(int argc, char **argv);
 extern int do_ipl2tp(int argc, char **argv);
 extern int do_ipfou(int argc, char **argv);
diff --git a/ip/ipvrf.c b/ip/ipvrf.c
new file mode 100644
index 000000000000..df9b2e76b309
--- /dev/null
+++ b/ip/ipvrf.c
@@ -0,0 +1,109 @@
+#define _ATFILE_SOURCE
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/wait.h>
+#include <sys/inotify.h>
+#include <sys/mount.h>
+#include <sys/param.h>
+#include <sys/syscall.h>
+#include <stdio.h>
+#include <string.h>
+#include <sched.h>
+#include <fcntl.h>
+#include <dirent.h>
+#include <errno.h>
+#include <unistd.h>
+#include <ctype.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+static int usage(void)
+{
+	fprintf(stderr, "Usage: ip vrf exec ID cmd ...\n");
+	exit(-1);
+}
+
+static int vrf_exec(int argc, char **argv)
+{
+	const char *cmd, *id;
+	char vrf_path[MAXPATHLEN];
+	int fd;
+
+	if (argc < 1) {
+		fprintf(stderr, "No vrf id specified\n");
+		return -1;
+	}
+	if (argc < 2) {
+		fprintf(stderr, "No command specified\n");
+		return -1;
+	}
+
+	id = argv[0];
+	cmd = argv[1];
+	snprintf(vrf_path, sizeof(vrf_path), "/proc/%d/vrf", getpid());
+	fd = open(vrf_path, O_WRONLY);
+	if (fd < 0) {
+		fprintf(stderr, "Cannot open vrf file: %s\n",
+			strerror(errno));
+		return -1;
+	}
+	if (write(fd, id, strlen(id)) < 0) {
+		fprintf(stderr, "Failed to set vrf id: %s\n",
+			strerror(errno));
+		close(fd);
+		return -1;
+	}
+	close(fd);
+
+	fflush(stdout);
+
+	if (batch_mode) {
+		int status;
+		pid_t pid;
+
+		pid = fork();
+		if (pid < 0) {
+			perror("fork");
+			exit(1);
+		}
+
+		if (pid != 0) {
+			/* Parent  */
+			if (waitpid(pid, &status, 0) < 0) {
+				perror("waitpid");
+				exit(1);
+			}
+
+			if (WIFEXITED(status)) {
+				/* ip must return the status of the child,
+				 * but do_cmd() will add a minus to this,
+				 * so let's add another one here to cancel it.
+				 */
+				return -WEXITSTATUS(status);
+			}
+
+			exit(1);
+		}
+	}
+
+	if (execvp(cmd, argv + 1)  < 0)
+		fprintf(stderr, "exec of \"%s\" failed: %s\n",
+			cmd, strerror(errno));
+	_exit(1);
+}
+
+int do_vrf(int argc, char **argv)
+{
+	if (*argv == NULL)
+		return usage();
+
+	if (matches(*argv, "help") == 0)
+		return usage();
+
+	if (matches(*argv, "exec") == 0)
+		return vrf_exec(argc-1, argv+1);
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip vrf help\".\n", *argv);
+	exit(-1);
+}
-- 
1.9.3 (Apple Git-50)
