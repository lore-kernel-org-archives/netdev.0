From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2 1/4] lib: Add netns_switch func for change network namespace
Date: Wed, 24 Dec 2014 23:04:08 +0200
Message-ID: <1419455051-23397-2-git-send-email-vadim4j@gmail.com>
References: <1419455051-23397-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>, Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:58009 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584AbaLXVOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 16:14:22 -0500
Received: by mail-la0-f43.google.com with SMTP id s18so7431728lam.30
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 13:14:20 -0800 (PST)
In-Reply-To: <1419455051-23397-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

New netns_switch func moved to the lib/namespace.c from ip/ipnetns.c
so it can be used from the other tools for fast switching
network namespace.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/namespace.h |  46 +++++++++++++++++++++++
 ip/ipnetns.c        | 106 ++--------------------------------------------------
 lib/Makefile        |   6 ++-
 lib/namespace.c     |  86 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 140 insertions(+), 104 deletions(-)
 create mode 100644 include/namespace.h
 create mode 100644 lib/namespace.c

diff --git a/include/namespace.h b/include/namespace.h
new file mode 100644
index 0000000..2f13e65
--- /dev/null
+++ b/include/namespace.h
@@ -0,0 +1,46 @@
+#ifndef __NAMESPACE_H__
+#define __NAMESPACE_H__ 1
+
+#include <sched.h>
+#include <sys/mount.h>
+#include <errno.h>
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
+extern int netns_switch(char *netns);
+
+#endif /* __NAMESPACE_H__ */
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 1c8aa02..519d518 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -17,42 +17,7 @@
 
 #include "utils.h"
 #include "ip_common.h"
-
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
+#include "namespace.h"
 
 static int usage(void)
 {
@@ -101,42 +66,12 @@ static int netns_list(int argc, char **argv)
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
@@ -146,45 +81,10 @@ static int netns_exec(int argc, char **argv)
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
index a42b885..66f89f1 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -1,8 +1,12 @@
 include ../Config
 
+ifeq ($(IP_CONFIG_SETNS),y)
+	CFLAGS += -DHAVE_SETNS
+endif
+
 CFLAGS += -fPIC
 
-UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o
+UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o namespace.o
 
 NLOBJ=libgenl.o ll_map.o libnetlink.o
 
diff --git a/lib/namespace.c b/lib/namespace.c
new file mode 100644
index 0000000..1554ce0
--- /dev/null
+++ b/lib/namespace.c
@@ -0,0 +1,86 @@
+/*
+ * namespace.c
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ */
+
+#include <fcntl.h>
+#include <dirent.h>
+
+#include "utils.h"
+#include "namespace.h"
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
-- 
2.1.3
