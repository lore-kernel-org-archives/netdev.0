From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next 5/8] Add filesystem APIs to lib
Date: Sun, 11 Dec 2016 16:53:12 -0800
Message-ID: <1481503995-24825-6-git-send-email-dsa@cumulusnetworks.com>
References: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34942 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754033AbcLLAx0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 19:53:26 -0500
Received: by mail-pf0-f182.google.com with SMTP id i88so9775321pfk.2
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 16:53:25 -0800 (PST)
In-Reply-To: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add make_path to recursively call mkdir as needed to create a given
path with the given mode.

Add find_cgroup2_mount to lookup path where cgroup2 is mounted. If it
is not already mounted, cgroup2 is mounted under /var/run/cgroup2 for
use by iproute2.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/utils.h |   2 +
 lib/Makefile    |   2 +-
 lib/fs.c        | 143 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 146 insertions(+), 1 deletion(-)
 create mode 100644 lib/fs.c

diff --git a/include/utils.h b/include/utils.h
index ac4517a3bde1..dc1d6b9607dd 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -257,5 +257,7 @@ int get_guid(__u64 *guid, const char *arg);
 int get_real_family(int rtm_type, int rtm_family);
 
 int cmd_exec(const char *cmd, char **argv, bool do_fork);
+int make_path(const char *path, mode_t mode);
+char *find_cgroup2_mount(void);
 
 #endif /* __UTILS_H__ */
diff --git a/lib/Makefile b/lib/Makefile
index 749073261c49..0c57662b4f8f 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -8,7 +8,7 @@ CFLAGS += -fPIC
 
 UTILOBJ = utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o \
 	inet_proto.o namespace.o json_writer.o \
-	names.o color.o bpf.o exec.o
+	names.o color.o bpf.o exec.o fs.o
 
 NLOBJ=libgenl.o ll_map.o libnetlink.o
 
diff --git a/lib/fs.c b/lib/fs.c
new file mode 100644
index 000000000000..39cc96dccca9
--- /dev/null
+++ b/lib/fs.c
@@ -0,0 +1,143 @@
+/*
+ * fs.c         filesystem APIs
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	David Ahern <dsa@cumulusnetworks.com>
+ *
+ */
+
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/socket.h>
+#include <sys/mount.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+#include <errno.h>
+#include <limits.h>
+
+#include "utils.h"
+
+#define CGROUP2_FS_NAME "cgroup2"
+
+/* if not already mounted cgroup2 is mounted here for iproute2's use */
+#define MNT_CGRP2_PATH  "/var/run/cgroup2"
+
+/* return mount path of first occurrence of given fstype */
+static char *find_fs_mount(const char *fs_to_find)
+{
+	char path[4096];
+	char fstype[128];    /* max length of any filesystem name */
+	char *mnt = NULL;
+	FILE *fp;
+
+	fp = fopen("/proc/mounts", "r");
+	if (!fp) {
+		fprintf(stderr,
+			"Failed to open mounts file: %s\n", strerror(errno));
+		return NULL;
+	}
+
+	while (fscanf(fp, "%*s %4096s %127s %*s %*d %*d\n",
+		      path, fstype) == 2) {
+		if (strcmp(fstype, fs_to_find) == 0) {
+			mnt = strdup(path);
+			break;
+		}
+	}
+
+	fclose(fp);
+
+	return mnt;
+}
+
+/* caller needs to free string returned */
+char *find_cgroup2_mount(void)
+{
+	char *mnt = find_fs_mount(CGROUP2_FS_NAME);
+
+	if (mnt)
+		return mnt;
+
+	mnt = strdup(MNT_CGRP2_PATH);
+	if (!mnt) {
+		fprintf(stderr, "Failed to allocate memory for cgroup2 path\n");
+		return NULL;
+
+	}
+
+	if (make_path(mnt, 0755)) {
+		fprintf(stderr, "Failed to setup vrf cgroup2 directory\n");
+		free(mnt);
+		return NULL;
+	}
+
+	if (mount("none", mnt, CGROUP2_FS_NAME, 0, NULL)) {
+		/* EBUSY means already mounted */
+		if (errno != EBUSY) {
+			fprintf(stderr,
+				"Failed to mount cgroup2. Are CGROUPS enabled in your kernel?\n");
+			free(mnt);
+			return NULL;
+		}
+	}
+	return mnt;
+}
+
+int make_path(const char *path, mode_t mode)
+{
+	char *dir, *delim;
+	struct stat sbuf;
+	int rc = -1;
+
+	delim = dir = strdup(path);
+	if (dir == NULL) {
+		fprintf(stderr, "strdup failed copying path");
+		return -1;
+	}
+
+	/* skip '/' -- it had better exist */
+	if (*delim == '/')
+		delim++;
+
+	while (1) {
+		delim = strchr(delim, '/');
+		if (delim)
+			*delim = '\0';
+
+		if (stat(dir, &sbuf) != 0) {
+			if (errno != ENOENT) {
+				fprintf(stderr,
+					"stat failed for %s: %s\n",
+					dir, strerror(errno));
+				goto out;
+			}
+
+			if (mkdir(dir, mode) != 0) {
+				fprintf(stderr,
+					"mkdir failed for %s: %s",
+					dir, strerror(errno));
+				goto out;
+			}
+		}
+
+		if (delim == NULL)
+			break;
+
+		*delim = '/';
+		delim++;
+		if (*delim == '\0')
+			break;
+	}
+	rc = 0;
+out:
+	free(dir);
+
+	return rc;
+}
-- 
2.1.4
