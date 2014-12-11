From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v3] ip: Simplify executing ip cmd within network ns
Date: Fri, 12 Dec 2014 00:32:51 +0200
Message-ID: <1418337171-2792-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:39205 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933541AbaLKWmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 17:42:46 -0500
Received: by mail-la0-f45.google.com with SMTP id gq15so5124823lab.4
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 14:42:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added new '-netns' option to simplify executing following cmd:

    ip netns exec NETNS ip OPTIONS COMMAND OBJECT

    to

    ip -n[etns] NETNS OPTIONS COMMAND OBJECT

e.g.:

    ip -net vnet0 link add br0 type bridge
    ip -n vnet0 link

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
Changes v2 -> v3
    Switching to netns w/o execvp: suggested by Jiri Pirko
                                                Jiri Benc

So I moved switching netns to lib/utils.c, looks
not very good for me, but it allows easy reuse this
netns_switch func for other utils in the future (tc, bridge, ...).

May be it would be better to have separated lib/netns.c module and
include/netns.h header ?

Changes v1 -> v2
    use -n[etns] option name:      suggested by Nicolas Dichtel
    changed man ip.8 page

 include/utils.h |  27 +++++++++++++++
 ip/ip.c         |   4 +++
 ip/ipnetns.c    | 105 ++------------------------------------------------------
 lib/Makefile    |   4 +++
 lib/utils.c     |  88 +++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip.8   |  23 ++++++++++++-
 6 files changed, 147 insertions(+), 104 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index eef9c42..1fd012c 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -159,4 +159,31 @@ struct iplink_req;
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev,
 		int *group, int *index);
+
+#define NETNS_RUN_DIR "/var/run/netns"
+#define NETNS_ETC_DIR "/etc/netns"
+
+#ifndef CLONE_NEWNET
+#define CLONE_NEWNET 0x40000000	/* New network namespace (lo, device, names sockets, etc) */
+#endif
+
+#ifndef MNT_DETACH
+#define MNT_DETACH	0x00000002	/* Just detach from the tree */
+#endif /* MNT_DETACH */
+
+/* sys/mount.h may be out too old to have these */
+#ifndef MS_REC
+#define MS_REC		16384
+#endif
+
+#ifndef MS_SLAVE
+#define MS_SLAVE	(1 << 19)
+#endif
+
+#ifndef MS_SHARED
+#define MS_SHARED	(1 << 20)
+#endif
+
+extern int netns_switch(char *netns);
+
 #endif /* __UTILS_H__ */
diff --git a/ip/ip.c b/ip/ip.c
index 5f759d5..5da10bf 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -262,6 +262,10 @@ int main(int argc, char **argv)
 			rcvbuf = size;
 		} else if (matches(opt, "-help") == 0) {
 			usage();
+		} else if (matches(opt, "-netns") == 0) {
+			NEXT_ARG();
+			if (netns_switch(argv[1]))
+				exit(-1);
 		} else {
 			fprintf(stderr, "Option \"%s\" is unknown, try \"ip -help\".\n", opt);
 			exit(-1);
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 1c8aa02..dd183e1 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -18,42 +18,6 @@
 #include "utils.h"
 #include "ip_common.h"
 
-#define NETNS_RUN_DIR "/var/run/netns"
-#define NETNS_ETC_DIR "/etc/netns"
-
-#ifndef CLONE_NEWNET
-#define CLONE_NEWNET 0x40000000	/* New network namespace (lo, device, names sockets, etc) */
-#endif
-
-#ifndef MNT_DETACH
-#define MNT_DETACH	0x00000002	/* Just detach from the tree */
-#endif /* MNT_DETACH */
-
-/* sys/mount.h may be out too old to have these */
-#ifndef MS_REC
-#define MS_REC		16384
-#endif
-
-#ifndef MS_SLAVE
-#define MS_SLAVE	(1 << 19)
-#endif
-
-#ifndef MS_SHARED
-#define MS_SHARED	(1 << 20)
-#endif
-
-#ifndef HAVE_SETNS
-static int setns(int fd, int nstype)
-{
-#ifdef __NR_setns
-	return syscall(__NR_setns, fd, nstype);
-#else
-	errno = ENOSYS;
-	return -1;
-#endif
-}
-#endif /* HAVE_SETNS */
-
 static int usage(void)
 {
 	fprintf(stderr, "Usage: ip netns list\n");
@@ -101,42 +65,12 @@ static int netns_list(int argc, char **argv)
 	return 0;
 }
 
-static void bind_etc(const char *name)
-{
-	char etc_netns_path[MAXPATHLEN];
-	char netns_name[MAXPATHLEN];
-	char etc_name[MAXPATHLEN];
-	struct dirent *entry;
-	DIR *dir;
-
-	snprintf(etc_netns_path, sizeof(etc_netns_path), "%s/%s", NETNS_ETC_DIR, name);
-	dir = opendir(etc_netns_path);
-	if (!dir)
-		return;
-
-	while ((entry = readdir(dir)) != NULL) {
-		if (strcmp(entry->d_name, ".") == 0)
-			continue;
-		if (strcmp(entry->d_name, "..") == 0)
-			continue;
-		snprintf(netns_name, sizeof(netns_name), "%s/%s", etc_netns_path, entry->d_name);
-		snprintf(etc_name, sizeof(etc_name), "/etc/%s", entry->d_name);
-		if (mount(netns_name, etc_name, "none", MS_BIND, NULL) < 0) {
-			fprintf(stderr, "Bind %s -> %s failed: %s\n",
-				netns_name, etc_name, strerror(errno));
-		}
-	}
-	closedir(dir);
-}
-
 static int netns_exec(int argc, char **argv)
 {
 	/* Setup the proper environment for apps that are not netns
 	 * aware, and execute a program in that environment.
 	 */
-	const char *name, *cmd;
-	char net_path[MAXPATHLEN];
-	int netns;
+	const char *cmd;
 
 	if (argc < 1) {
 		fprintf(stderr, "No netns name specified\n");
@@ -146,45 +80,10 @@ static int netns_exec(int argc, char **argv)
 		fprintf(stderr, "No command specified\n");
 		return -1;
 	}
-
-	name = argv[0];
 	cmd = argv[1];
-	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
-	netns = open(net_path, O_RDONLY | O_CLOEXEC);
-	if (netns < 0) {
-		fprintf(stderr, "Cannot open network namespace \"%s\": %s\n",
-			name, strerror(errno));
-		return -1;
-	}
-
-	if (setns(netns, CLONE_NEWNET) < 0) {
-		fprintf(stderr, "setting the network namespace \"%s\" failed: %s\n",
-			name, strerror(errno));
-		return -1;
-	}
 
-	if (unshare(CLONE_NEWNS) < 0) {
-		fprintf(stderr, "unshare failed: %s\n", strerror(errno));
-		return -1;
-	}
-	/* Don't let any mounts propagate back to the parent */
-	if (mount("", "/", "none", MS_SLAVE | MS_REC, NULL)) {
-		fprintf(stderr, "\"mount --make-rslave /\" failed: %s\n",
-			strerror(errno));
+	if (netns_switch(argv[0]))
 		return -1;
-	}
-	/* Mount a version of /sys that describes the network namespace */
-	if (umount2("/sys", MNT_DETACH) < 0) {
-		fprintf(stderr, "umount of /sys failed: %s\n", strerror(errno));
-		return -1;
-	}
-	if (mount(name, "/sys", "sysfs", 0, NULL) < 0) {
-		fprintf(stderr, "mount of /sys failed: %s\n",strerror(errno));
-		return -1;
-	}
-
-	/* Setup bind mounts for config files in /etc */
-	bind_etc(name);
 
 	fflush(stdout);
 
diff --git a/lib/Makefile b/lib/Makefile
index a42b885..f7cbc8d 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -1,5 +1,9 @@
 include ../Config
 
+ifeq ($(IP_CONFIG_SETNS),y)
+	CFLAGS += -DHAVE_SETNS
+endif
+
 CFLAGS += -fPIC
 
 UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o
diff --git a/lib/utils.c b/lib/utils.c
index 987377b..ff14881 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -27,7 +27,11 @@
 #include <linux/param.h>
 #include <time.h>
 #include <sys/time.h>
+#include <sys/mount.h>
+#include <sys/types.h>
 #include <errno.h>
+#include <sched.h>
+#include <dirent.h>
 
 
 #include "utils.h"
@@ -856,3 +860,87 @@ int inet_get_addr(const char *src, __u32 *dst, struct in6_addr *dst6)
 	else
 		return inet_pton(AF_INET, src, dst);
 }
+
+#ifndef HAVE_SETNS
+static int setns(int fd, int nstype)
+{
+#ifdef __NR_setns
+	return syscall(__NR_setns, fd, nstype);
+#else
+	errno = ENOSYS;
+	return -1;
+#endif
+}
+#endif /* HAVE_SETNS */
+
+static void bind_etc(const char *name)
+{
+	char etc_netns_path[MAXPATHLEN];
+	char netns_name[MAXPATHLEN];
+	char etc_name[MAXPATHLEN];
+	struct dirent *entry;
+	DIR *dir;
+
+	snprintf(etc_netns_path, sizeof(etc_netns_path), "%s/%s", NETNS_ETC_DIR, name);
+	dir = opendir(etc_netns_path);
+	if (!dir)
+		return;
+
+	while ((entry = readdir(dir)) != NULL) {
+		if (strcmp(entry->d_name, ".") == 0)
+			continue;
+		if (strcmp(entry->d_name, "..") == 0)
+			continue;
+		snprintf(netns_name, sizeof(netns_name), "%s/%s", etc_netns_path, entry->d_name);
+		snprintf(etc_name, sizeof(etc_name), "/etc/%s", entry->d_name);
+		if (mount(netns_name, etc_name, "none", MS_BIND, NULL) < 0) {
+			fprintf(stderr, "Bind %s -> %s failed: %s\n",
+				netns_name, etc_name, strerror(errno));
+		}
+	}
+	closedir(dir);
+}
+
+int netns_switch(char *name)
+{
+	char net_path[MAXPATHLEN];
+	int netns;
+
+	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
+	netns = open(net_path, O_RDONLY | O_CLOEXEC);
+	if (netns < 0) {
+		fprintf(stderr, "Cannot open network namespace \"%s\": %s\n",
+			name, strerror(errno));
+		return -1;
+	}
+
+	if (setns(netns, CLONE_NEWNET) < 0) {
+		fprintf(stderr, "setting the network namespace \"%s\" failed: %s\n",
+			name, strerror(errno));
+		return -1;
+	}
+
+	if (unshare(CLONE_NEWNS) < 0) {
+		fprintf(stderr, "unshare failed: %s\n", strerror(errno));
+		return -1;
+	}
+	/* Don't let any mounts propagate back to the parent */
+	if (mount("", "/", "none", MS_SLAVE | MS_REC, NULL)) {
+		fprintf(stderr, "\"mount --make-rslave /\" failed: %s\n",
+			strerror(errno));
+		return -1;
+	}
+	/* Mount a version of /sys that describes the network namespace */
+	if (umount2("/sys", MNT_DETACH) < 0) {
+		fprintf(stderr, "umount of /sys failed: %s\n", strerror(errno));
+		return -1;
+	}
+	if (mount(name, "/sys", "sysfs", 0, NULL) < 0) {
+		fprintf(stderr, "mount of /sys failed: %s\n",strerror(errno));
+		return -1;
+	}
+
+	/* Setup bind mounts for config files in /etc */
+	bind_etc(name);
+	return 0;
+}
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 2d42e98..0fb759d 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -31,7 +31,8 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 \fB\-r\fR[\fIesolve\fR] |
 \fB\-f\fR[\fIamily\fR] {
 .BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
-\fB\-o\fR[\fIneline\fR] }
+\fB\-o\fR[\fIneline\fR] |
+\fB\-n\fR[\fIetns\fR] }
 
 
 .SH OPTIONS
@@ -134,6 +135,26 @@ the output.
 use the system's name resolver to print DNS names instead of
 host addresses.
 
+.TP
+.BR "\-n" , " \-net" , " \-netns " <NETNS>
+switches
+.B ip
+to the specified network namespace
+.IR NETNS .
+Actually it just simplifies executing of:
+
+.B ip netns exec
+.IR NETNS
+.B ip
+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+
+to
+
+.B ip
+.RI "-n[etns] " NETNS " [ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+
 .SH IP - COMMAND SYNTAX
 
 .SS
-- 
2.1.3
