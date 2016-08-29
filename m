From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next RFC v2 7/9] samples/bpf: Split out helper code from
 test_current_task_under_cgroup_user
Date: Mon, 29 Aug 2016 04:47:36 -0700
Message-ID: <20160829114734.GA20906@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org, linux-security-module@vger.kernel.org,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:36518 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932983AbcH2Lrj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:47:39 -0400
Received: by mail-it0-f41.google.com with SMTP id e63so97748621ith.1
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 04:47:38 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This splits out the cgroup helper code from
test_current_task_under_cgroup_user.c This code can be used to test any
program that needs to setup a cgroup v2 hierarchy temporarily, and put
itself into said hierarchy. It also includes some functions that make
moving around in the hierarchy a bit easier.

This patch is used in follow on samples.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 samples/bpf/Makefile                              |   2 +-
 samples/bpf/cgroup_helpers.c                      | 103 ++++++++++++++++++++++
 samples/bpf/cgroup_helpers.h                      |  15 ++++
 samples/bpf/test_current_task_under_cgroup_user.c |  72 +++------------
 4 files changed, 129 insertions(+), 63 deletions(-)
 create mode 100644 samples/bpf/cgroup_helpers.c
 create mode 100644 samples/bpf/cgroup_helpers.h

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index db3cb06..5d2c178 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -50,7 +50,7 @@ test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
-test_current_task_under_cgroup-objs := bpf_load.o libbpf.o \
+test_current_task_under_cgroup-objs := bpf_load.o libbpf.o cgroup_helpers.o \
 				       test_current_task_under_cgroup_user.o
 
 # Tell kbuild to always build the programs
diff --git a/samples/bpf/cgroup_helpers.c b/samples/bpf/cgroup_helpers.c
new file mode 100644
index 0000000..e465497
--- /dev/null
+++ b/samples/bpf/cgroup_helpers.c
@@ -0,0 +1,103 @@
+#define _GNU_SOURCE
+#include <errno.h>
+#include <fcntl.h>
+#include <sched.h>
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+#include <sys/mount.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include "cgroup_helpers.h"
+
+#define CGROUP_MOUNT_PATH "/mnt"
+
+int add_controller(char *controller)
+{
+	int fd, rc = 0;
+
+	fd = open("cgroup.subtree_control", O_WRONLY);
+	if (fd < 0) {
+		log_err("Unable to open subtree_control");
+		return 1;
+	}
+	if (dprintf(fd, "+%s\n", controller) < 0) {
+		log_err("Adding Controller");
+		rc = 1;
+	}
+	close(fd);
+	return rc;
+}
+
+int mkdirp(char *path)
+{
+	int rc;
+
+	rc = mkdir(path, 0777);
+	if (rc && errno == EEXIST)
+		return 0;
+	return rc;
+}
+
+/*
+ * This is to avoid interfering with existing cgroups. Unfortunately,
+ * most people don't have cgroupv2 enabled at this point in time.
+ * It's easier to create our own mount namespace and manage it
+ * ourselves. This function drops you into the top of that cgroup2
+ * mount point, so make sure you call load_bpf before calling this.
+ */
+int setup_cgroups(void)
+{
+	if (unshare(CLONE_NEWNS)) {
+		log_err("unshare");
+		return 1;
+	}
+
+	if (mount("none", "/", NULL, MS_REC | MS_PRIVATE, NULL)) {
+		log_err("mount fakeroot");
+		return 1;
+	}
+
+	if (mount("none", CGROUP_MOUNT_PATH, "cgroup2", 0, NULL)) {
+		log_err("mount cgroup2");
+		return 1;
+	}
+
+	if (chdir(CGROUP_MOUNT_PATH)) {
+		log_err("chdir");
+		return 1;
+	}
+
+	return 0;
+}
+
+int join_cgroup(char *path)
+{
+	char cgroup_path[1024];
+	pid_t pid = getpid();
+	int fd, rc = 0;
+
+	snprintf(cgroup_path, sizeof(cgroup_path), "%s/cgroup.procs", path);
+
+	fd = open(cgroup_path, O_WRONLY);
+	if (fd < 0) {
+		log_err("Opening Cgroup");
+		return 1;
+	}
+
+	if (dprintf(fd, "%d\n", pid) < 0) {
+		log_err("Joining Cgroup");
+		rc = 1;
+	}
+	close(fd);
+	return rc;
+}
+
+int reset_bpf_hook(int fd)
+{
+	if (dprintf(fd, "0\n") < 0) {
+		log_err("Unable to reset BPF hook");
+		return 1;
+	}
+	return 0;
+}
diff --git a/samples/bpf/cgroup_helpers.h b/samples/bpf/cgroup_helpers.h
new file mode 100644
index 0000000..f9f1bdf
--- /dev/null
+++ b/samples/bpf/cgroup_helpers.h
@@ -0,0 +1,15 @@
+#ifndef __CGROUP_HELPERS_H
+#define __CGROUP_HELPERS_H
+#include <string.h>
+
+#define clean_errno() (errno == 0 ? "None" : strerror(errno))
+#define log_err(MSG, ...) fprintf(stderr, "(%s:%d: errno: %s) " MSG "\n", \
+	__FILE__, __LINE__, clean_errno(), ##__VA_ARGS__)
+
+int mkdirp(char *path);
+int setup_cgroups(void);
+int join_cgroup(char *path);
+int reset_bpf_hook(int fd);
+int add_controller(char *controller);
+
+#endif
diff --git a/samples/bpf/test_current_task_under_cgroup_user.c b/samples/bpf/test_current_task_under_cgroup_user.c
index 30b0bce..752a254 100644
--- a/samples/bpf/test_current_task_under_cgroup_user.c
+++ b/samples/bpf/test_current_task_under_cgroup_user.c
@@ -11,44 +11,12 @@
 #include <unistd.h>
 #include "libbpf.h"
 #include "bpf_load.h"
-#include <string.h>
 #include <fcntl.h>
 #include <errno.h>
 #include <linux/bpf.h>
-#include <sched.h>
-#include <sys/mount.h>
-#include <sys/stat.h>
-#include <sys/types.h>
-#include <linux/limits.h>
+#include "cgroup_helpers.h"
 
-#define CGROUP_MOUNT_PATH	"/mnt"
-#define CGROUP_PATH		"/mnt/my-cgroup"
-
-#define clean_errno() (errno == 0 ? "None" : strerror(errno))
-#define log_err(MSG, ...) fprintf(stderr, "(%s:%d: errno: %s) " MSG "\n", \
-	__FILE__, __LINE__, clean_errno(), ##__VA_ARGS__)
-
-static int join_cgroup(char *path)
-{
-	int fd, rc = 0;
-	pid_t pid = getpid();
-	char cgroup_path[PATH_MAX + 1];
-
-	snprintf(cgroup_path, sizeof(cgroup_path), "%s/cgroup.procs", path);
-
-	fd = open(cgroup_path, O_WRONLY);
-	if (fd < 0) {
-		log_err("Opening Cgroup");
-		return 1;
-	}
-
-	if (dprintf(fd, "%d\n", pid) < 0) {
-		log_err("Joining Cgroup");
-		rc = 1;
-	}
-	close(fd);
-	return rc;
-}
+#define CGROUP_NAME "test_current_task_under"
 
 int main(int argc, char **argv)
 {
@@ -62,33 +30,13 @@ int main(int argc, char **argv)
 		return 1;
 	}
 
-	/*
-	 * This is to avoid interfering with existing cgroups. Unfortunately,
-	 * most people don't have cgroupv2 enabled at this point in time.
-	 * It's easier to create our own mount namespace and manage it
-	 * ourselves.
-	 */
-	if (unshare(CLONE_NEWNS)) {
-		log_err("unshare");
-		return 1;
-	}
-
-	if (mount("none", "/", NULL, MS_REC | MS_PRIVATE, NULL)) {
-		log_err("mount fakeroot");
+	if (setup_cgroups())
 		return 1;
-	}
 
-	if (mount("none", CGROUP_MOUNT_PATH, "cgroup2", 0, NULL)) {
-		log_err("mount cgroup2");
+	if (mkdirp(CGROUP_NAME))
 		return 1;
-	}
-
-	if (mkdir(CGROUP_PATH, 0777) && errno != EEXIST) {
-		log_err("mkdir cgroup");
-		return 1;
-	}
 
-	cg2 = open(CGROUP_PATH, O_RDONLY);
+	cg2 = open(CGROUP_NAME, O_RDONLY);
 	if (cg2 < 0) {
 		log_err("opening target cgroup");
 		goto cleanup_cgroup_err;
@@ -98,7 +46,7 @@ int main(int argc, char **argv)
 		log_err("Adding target cgroup to map");
 		goto cleanup_cgroup_err;
 	}
-	if (join_cgroup("/mnt/my-cgroup")) {
+	if (join_cgroup(CGROUP_NAME)) {
 		log_err("Leaving target cgroup");
 		goto cleanup_cgroup_err;
 	}
@@ -119,7 +67,7 @@ int main(int argc, char **argv)
 	}
 
 	/* Verify the negative scenario; leave the cgroup */
-	if (join_cgroup(CGROUP_MOUNT_PATH))
+	if (join_cgroup("."))
 		goto leave_cgroup_err;
 
 	remote_pid = 0;
@@ -133,13 +81,13 @@ int main(int argc, char **argv)
 		goto cleanup_cgroup_err;
 	}
 
-	rmdir(CGROUP_PATH);
+	rmdir(CGROUP_NAME);
 	return 0;
 
 	/* Error condition, cleanup */
 leave_cgroup_err:
-	join_cgroup(CGROUP_MOUNT_PATH);
+	join_cgroup(".");
 cleanup_cgroup_err:
-	rmdir(CGROUP_PATH);
+	rmdir(CGROUP_NAME);
 	return 1;
 }
-- 
2.7.4
