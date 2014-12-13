From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 v4] ip: Simplify executing ip cmd within network
 ns
Date: Sat, 13 Dec 2014 09:29:36 +0100
Message-ID: <20141213082936.GA1849@nanopsycho.orion>
References: <1418422507-6635-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:42768 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965934AbaLMI3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2014 03:29:39 -0500
Received: by mail-wi0-f180.google.com with SMTP id n3so4628859wiv.13
        for <netdev@vger.kernel.org>; Sat, 13 Dec 2014 00:29:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1418422507-6635-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 12, 2014 at 11:15:07PM CET, vadim4j@gmail.com wrote:
>From: Vadim Kochan <vadim4j@gmail.com>
>
>Added new '-netns' option to simplify executing following cmd:
>
>    ip netns exec NETNS ip OPTIONS COMMAND OBJECT
>
>    to
>
>    ip -n[etns] NETNS OPTIONS COMMAND OBJECT
>
>e.g.:
>
>    ip -net vnet0 link add br0 type bridge
>    ip -n vnet0 link
>
>Signed-off-by: Vadim Kochan <vadim4j@gmail.com>


This looks good. I'm still missing support in tc, bridge, etc. I think
it would be great to do this in the same patch/patchset.


>---
> include/namespace.h |  46 +++++++++++++++++++++++
> ip/ip.c             |   5 +++
> ip/ipnetns.c        | 106 ++--------------------------------------------------
> lib/Makefile        |   6 ++-
> lib/namespace.c     |  86 ++++++++++++++++++++++++++++++++++++++++++
> man/man8/ip.8       |  23 +++++++++++-
> 6 files changed, 167 insertions(+), 105 deletions(-)
> create mode 100644 include/namespace.h
> create mode 100644 lib/namespace.c
>
>diff --git a/include/namespace.h b/include/namespace.h
>new file mode 100644
>index 0000000..2f13e65
>--- /dev/null
>+++ b/include/namespace.h
>@@ -0,0 +1,46 @@
>+#ifndef __NAMESPACE_H__
>+#define __NAMESPACE_H__ 1
>+
>+#include <sched.h>
>+#include <sys/mount.h>
>+#include <errno.h>
>+
>+#define NETNS_RUN_DIR "/var/run/netns"
>+#define NETNS_ETC_DIR "/etc/netns"
>+
>+#ifndef CLONE_NEWNET
>+#define CLONE_NEWNET 0x40000000	/* New network namespace (lo, device, names sockets, etc) */
>+#endif
>+
>+#ifndef MNT_DETACH
>+#define MNT_DETACH	0x00000002	/* Just detach from the tree */
>+#endif /* MNT_DETACH */
>+
>+/* sys/mount.h may be out too old to have these */
>+#ifndef MS_REC
>+#define MS_REC		16384
>+#endif
>+
>+#ifndef MS_SLAVE
>+#define MS_SLAVE	(1 << 19)
>+#endif
>+
>+#ifndef MS_SHARED
>+#define MS_SHARED	(1 << 20)
>+#endif
>+
>+#ifndef HAVE_SETNS
>+static int setns(int fd, int nstype)
>+{
>+#ifdef __NR_setns
>+	return syscall(__NR_setns, fd, nstype);
>+#else
>+	errno = ENOSYS;
>+	return -1;
>+#endif
>+}
>+#endif /* HAVE_SETNS */
>+
>+extern int netns_switch(char *netns);
>+
>+#endif /* __NAMESPACE_H__ */
>diff --git a/ip/ip.c b/ip/ip.c
>index 5f759d5..d6c9123 100644
>--- a/ip/ip.c
>+++ b/ip/ip.c
>@@ -22,6 +22,7 @@
> #include "SNAPSHOT.h"
> #include "utils.h"
> #include "ip_common.h"
>+#include "namespace.h"
> 
> int preferred_family = AF_UNSPEC;
> int human_readable = 0;
>@@ -262,6 +263,10 @@ int main(int argc, char **argv)
> 			rcvbuf = size;
> 		} else if (matches(opt, "-help") == 0) {
> 			usage();
>+		} else if (matches(opt, "-netns") == 0) {
>+			NEXT_ARG();
>+			if (netns_switch(argv[1]))
>+				exit(-1);
> 		} else {
> 			fprintf(stderr, "Option \"%s\" is unknown, try \"ip -help\".\n", opt);
> 			exit(-1);
>diff --git a/ip/ipnetns.c b/ip/ipnetns.c
>index 1c8aa02..519d518 100644
>--- a/ip/ipnetns.c
>+++ b/ip/ipnetns.c
>@@ -17,42 +17,7 @@
> 
> #include "utils.h"
> #include "ip_common.h"
>-
>-#define NETNS_RUN_DIR "/var/run/netns"
>-#define NETNS_ETC_DIR "/etc/netns"
>-
>-#ifndef CLONE_NEWNET
>-#define CLONE_NEWNET 0x40000000	/* New network namespace (lo, device, names sockets, etc) */
>-#endif
>-
>-#ifndef MNT_DETACH
>-#define MNT_DETACH	0x00000002	/* Just detach from the tree */
>-#endif /* MNT_DETACH */
>-
>-/* sys/mount.h may be out too old to have these */
>-#ifndef MS_REC
>-#define MS_REC		16384
>-#endif
>-
>-#ifndef MS_SLAVE
>-#define MS_SLAVE	(1 << 19)
>-#endif
>-
>-#ifndef MS_SHARED
>-#define MS_SHARED	(1 << 20)
>-#endif
>-
>-#ifndef HAVE_SETNS
>-static int setns(int fd, int nstype)
>-{
>-#ifdef __NR_setns
>-	return syscall(__NR_setns, fd, nstype);
>-#else
>-	errno = ENOSYS;
>-	return -1;
>-#endif
>-}
>-#endif /* HAVE_SETNS */
>+#include "namespace.h"
> 
> static int usage(void)
> {
>@@ -101,42 +66,12 @@ static int netns_list(int argc, char **argv)
> 	return 0;
> }
> 
>-static void bind_etc(const char *name)
>-{
>-	char etc_netns_path[MAXPATHLEN];
>-	char netns_name[MAXPATHLEN];
>-	char etc_name[MAXPATHLEN];
>-	struct dirent *entry;
>-	DIR *dir;
>-
>-	snprintf(etc_netns_path, sizeof(etc_netns_path), "%s/%s", NETNS_ETC_DIR, name);
>-	dir = opendir(etc_netns_path);
>-	if (!dir)
>-		return;
>-
>-	while ((entry = readdir(dir)) != NULL) {
>-		if (strcmp(entry->d_name, ".") == 0)
>-			continue;
>-		if (strcmp(entry->d_name, "..") == 0)
>-			continue;
>-		snprintf(netns_name, sizeof(netns_name), "%s/%s", etc_netns_path, entry->d_name);
>-		snprintf(etc_name, sizeof(etc_name), "/etc/%s", entry->d_name);
>-		if (mount(netns_name, etc_name, "none", MS_BIND, NULL) < 0) {
>-			fprintf(stderr, "Bind %s -> %s failed: %s\n",
>-				netns_name, etc_name, strerror(errno));
>-		}
>-	}
>-	closedir(dir);
>-}
>-
> static int netns_exec(int argc, char **argv)
> {
> 	/* Setup the proper environment for apps that are not netns
> 	 * aware, and execute a program in that environment.
> 	 */
>-	const char *name, *cmd;
>-	char net_path[MAXPATHLEN];
>-	int netns;
>+	const char *cmd;
> 
> 	if (argc < 1) {
> 		fprintf(stderr, "No netns name specified\n");
>@@ -146,45 +81,10 @@ static int netns_exec(int argc, char **argv)
> 		fprintf(stderr, "No command specified\n");
> 		return -1;
> 	}
>-
>-	name = argv[0];
> 	cmd = argv[1];
>-	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
>-	netns = open(net_path, O_RDONLY | O_CLOEXEC);
>-	if (netns < 0) {
>-		fprintf(stderr, "Cannot open network namespace \"%s\": %s\n",
>-			name, strerror(errno));
>-		return -1;
>-	}
>-
>-	if (setns(netns, CLONE_NEWNET) < 0) {
>-		fprintf(stderr, "setting the network namespace \"%s\" failed: %s\n",
>-			name, strerror(errno));
>-		return -1;
>-	}
> 
>-	if (unshare(CLONE_NEWNS) < 0) {
>-		fprintf(stderr, "unshare failed: %s\n", strerror(errno));
>-		return -1;
>-	}
>-	/* Don't let any mounts propagate back to the parent */
>-	if (mount("", "/", "none", MS_SLAVE | MS_REC, NULL)) {
>-		fprintf(stderr, "\"mount --make-rslave /\" failed: %s\n",
>-			strerror(errno));
>+	if (netns_switch(argv[0]))
> 		return -1;
>-	}
>-	/* Mount a version of /sys that describes the network namespace */
>-	if (umount2("/sys", MNT_DETACH) < 0) {
>-		fprintf(stderr, "umount of /sys failed: %s\n", strerror(errno));
>-		return -1;
>-	}
>-	if (mount(name, "/sys", "sysfs", 0, NULL) < 0) {
>-		fprintf(stderr, "mount of /sys failed: %s\n",strerror(errno));
>-		return -1;
>-	}
>-
>-	/* Setup bind mounts for config files in /etc */
>-	bind_etc(name);
> 
> 	fflush(stdout);
> 
>diff --git a/lib/Makefile b/lib/Makefile
>index a42b885..66f89f1 100644
>--- a/lib/Makefile
>+++ b/lib/Makefile
>@@ -1,8 +1,12 @@
> include ../Config
> 
>+ifeq ($(IP_CONFIG_SETNS),y)
>+	CFLAGS += -DHAVE_SETNS
>+endif
>+
> CFLAGS += -fPIC
> 
>-UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o
>+UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o namespace.o
> 
> NLOBJ=libgenl.o ll_map.o libnetlink.o
> 
>diff --git a/lib/namespace.c b/lib/namespace.c
>new file mode 100644
>index 0000000..1554ce0
>--- /dev/null
>+++ b/lib/namespace.c
>@@ -0,0 +1,86 @@
>+/*
>+ * namespace.c
>+ *
>+ *		This program is free software; you can redistribute it and/or
>+ *		modify it under the terms of the GNU General Public License
>+ *		as published by the Free Software Foundation; either version
>+ *		2 of the License, or (at your option) any later version.
>+ */
>+
>+#include <fcntl.h>
>+#include <dirent.h>
>+
>+#include "utils.h"
>+#include "namespace.h"
>+
>+static void bind_etc(const char *name)
>+{
>+	char etc_netns_path[MAXPATHLEN];
>+	char netns_name[MAXPATHLEN];
>+	char etc_name[MAXPATHLEN];
>+	struct dirent *entry;
>+	DIR *dir;
>+
>+	snprintf(etc_netns_path, sizeof(etc_netns_path), "%s/%s", NETNS_ETC_DIR, name);
>+	dir = opendir(etc_netns_path);
>+	if (!dir)
>+		return;
>+
>+	while ((entry = readdir(dir)) != NULL) {
>+		if (strcmp(entry->d_name, ".") == 0)
>+			continue;
>+		if (strcmp(entry->d_name, "..") == 0)
>+			continue;
>+		snprintf(netns_name, sizeof(netns_name), "%s/%s", etc_netns_path, entry->d_name);
>+		snprintf(etc_name, sizeof(etc_name), "/etc/%s", entry->d_name);
>+		if (mount(netns_name, etc_name, "none", MS_BIND, NULL) < 0) {
>+			fprintf(stderr, "Bind %s -> %s failed: %s\n",
>+				netns_name, etc_name, strerror(errno));
>+		}
>+	}
>+	closedir(dir);
>+}
>+
>+int netns_switch(char *name)
>+{
>+	char net_path[MAXPATHLEN];
>+	int netns;
>+
>+	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
>+	netns = open(net_path, O_RDONLY | O_CLOEXEC);
>+	if (netns < 0) {
>+		fprintf(stderr, "Cannot open network namespace \"%s\": %s\n",
>+			name, strerror(errno));
>+		return -1;
>+	}
>+
>+	if (setns(netns, CLONE_NEWNET) < 0) {
>+		fprintf(stderr, "setting the network namespace \"%s\" failed: %s\n",
>+			name, strerror(errno));
>+		return -1;
>+	}
>+
>+	if (unshare(CLONE_NEWNS) < 0) {
>+		fprintf(stderr, "unshare failed: %s\n", strerror(errno));
>+		return -1;
>+	}
>+	/* Don't let any mounts propagate back to the parent */
>+	if (mount("", "/", "none", MS_SLAVE | MS_REC, NULL)) {
>+		fprintf(stderr, "\"mount --make-rslave /\" failed: %s\n",
>+			strerror(errno));
>+		return -1;
>+	}
>+	/* Mount a version of /sys that describes the network namespace */
>+	if (umount2("/sys", MNT_DETACH) < 0) {
>+		fprintf(stderr, "umount of /sys failed: %s\n", strerror(errno));
>+		return -1;
>+	}
>+	if (mount(name, "/sys", "sysfs", 0, NULL) < 0) {
>+		fprintf(stderr, "mount of /sys failed: %s\n",strerror(errno));
>+		return -1;
>+	}
>+
>+	/* Setup bind mounts for config files in /etc */
>+	bind_etc(name);
>+	return 0;
>+}
>diff --git a/man/man8/ip.8 b/man/man8/ip.8
>index 2d42e98..0fb759d 100644
>--- a/man/man8/ip.8
>+++ b/man/man8/ip.8
>@@ -31,7 +31,8 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
> \fB\-r\fR[\fIesolve\fR] |
> \fB\-f\fR[\fIamily\fR] {
> .BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
>-\fB\-o\fR[\fIneline\fR] }
>+\fB\-o\fR[\fIneline\fR] |
>+\fB\-n\fR[\fIetns\fR] }
> 
> 
> .SH OPTIONS
>@@ -134,6 +135,26 @@ the output.
> use the system's name resolver to print DNS names instead of
> host addresses.
> 
>+.TP
>+.BR "\-n" , " \-net" , " \-netns " <NETNS>
>+switches
>+.B ip
>+to the specified network namespace
>+.IR NETNS .
>+Actually it just simplifies executing of:
>+
>+.B ip netns exec
>+.IR NETNS
>+.B ip
>+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
>+.BR help " }"
>+
>+to
>+
>+.B ip
>+.RI "-n[etns] " NETNS " [ " OPTIONS " ] " OBJECT " { " COMMAND " | "
>+.BR help " }"
>+
> .SH IP - COMMAND SYNTAX
> 
> .SS
>-- 
>2.1.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
