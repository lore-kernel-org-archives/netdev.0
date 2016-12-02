From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next 1/2] samples, bpf: Refactor
 test_current_task_under_cgroup - separate out helpers
Date: Fri, 2 Dec 2016 02:42:18 -0800
Message-ID: <20161202104217.GA9231@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@zonque.org, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35908 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933914AbcLBKmV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 05:42:21 -0500
Received: by mail-io0-f171.google.com with SMTP id m5so336499260ioe.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 02:42:21 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies test_current_task_under_cgroup_user. The test has
several helpers around creating a temporary environment for cgroup
testing, and moving the current task around cgroups. This set of
helpers can then be used in other tests.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 samples/bpf/Makefile                              |   2 +-
 samples/bpf/cgroup_helpers.c                      | 177 ++++++++++++++++++++++
 samples/bpf/cgroup_helpers.h                      |  16 ++
 samples/bpf/test_current_task_under_cgroup_user.c | 108 +++----------
 4 files changed, 218 insertions(+), 85 deletions(-)
 create mode 100644 samples/bpf/cgroup_helpers.c
 create mode 100644 samples/bpf/cgroup_helpers.h

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 22b6407e..3c805af 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -54,7 +54,7 @@ test_cgrp2_attach-objs := libbpf.o test_cgrp2_attach.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
-test_current_task_under_cgroup-objs := bpf_load.o libbpf.o \
+test_current_task_under_cgroup-objs := bpf_load.o libbpf.o cgroup_helpers.o \
 				       test_current_task_under_cgroup_user.o
 trace_event-objs := bpf_load.o libbpf.o trace_event_user.o
 sampleip-objs := bpf_load.o libbpf.o sampleip_user.o
diff --git a/samples/bpf/cgroup_helpers.c b/samples/bpf/cgroup_helpers.c
new file mode 100644
index 0000000..9d1be94
--- /dev/null
+++ b/samples/bpf/cgroup_helpers.c
@@ -0,0 +1,177 @@
+#define _GNU_SOURCE
+#include <sched.h>
+#include <sys/mount.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <linux/limits.h>
+#include <stdio.h>
+#include <linux/sched.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <ftw.h>
+
+
+#include "cgroup_helpers.h"
+
+/*
+ * To avoid relying on the system setup, when setup_cgroup_env is called
+ * we create a new mount namespace, and cgroup namespace. The cgroup2
+ * root is mounted at CGROUP_MOUNT_PATH
+ *
+ * Unfortunately, most people don't have cgroupv2 enabled at this point in time.
+ * It's easier to create our own mount namespace and manage it ourselves.
+ *
+ * We assume /mnt exists.
+ */
+
+#define WALK_FD_LIMIT			16
+#define CGROUP_MOUNT_PATH		"/mnt"
+#define CGROUP_WORK_DIR			"/cgroup-test-work-dir"
+#define format_cgroup_path(buf, path) \
+	snprintf(buf, sizeof(buf), "%s%s%s", CGROUP_MOUNT_PATH, \
+		 CGROUP_WORK_DIR, path)
+
+/**
+ * setup_cgroup_environment() - Setup the cgroup environment
+ *
+ * After calling this function, cleanup_cgroup_environment should be called
+ * once testing is complete.
+ *
+ * This function will print an error to stderr and return 1 if it is unable
+ * to setup the cgroup environment. If setup is successful, 0 is returned.
+ */
+int setup_cgroup_environment(void)
+{
+	char cgroup_workdir[PATH_MAX + 1];
+
+	format_cgroup_path(cgroup_workdir, "");
+
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
+	/* Cleanup existing failed runs, now that the environment is setup */
+	cleanup_cgroup_environment();
+
+	if (mkdir(cgroup_workdir, 0777) && errno != EEXIST) {
+		log_err("mkdir cgroup work dir");
+		return 1;
+	}
+
+	return 0;
+}
+
+static int nftwfunc(const char *filename, const struct stat *statptr,
+		    int fileflags, struct FTW *pfwt)
+{
+	if ((fileflags & FTW_D) && rmdir(filename))
+		log_err("Removing cgroup: %s", filename);
+	return 0;
+}
+
+
+static int join_cgroup_from_top(char *cgroup_path)
+{
+	char cgroup_procs_path[PATH_MAX + 1];
+	pid_t pid = getpid();
+	int fd, rc = 0;
+
+	snprintf(cgroup_procs_path, sizeof(cgroup_procs_path),
+		 "%s/cgroup.procs", cgroup_path);
+
+	fd = open(cgroup_procs_path, O_WRONLY);
+	if (fd < 0) {
+		log_err("Opening Cgroup Procs: %s", cgroup_procs_path);
+		return 1;
+	}
+
+	if (dprintf(fd, "%d\n", pid) < 0) {
+		log_err("Joining Cgroup");
+		rc = 1;
+	}
+
+	close(fd);
+	return rc;
+}
+
+/**
+ * join_cgroup() - Join a cgroup
+ * @path: The cgroup path, relative to the workdir, to join
+ *
+ * This function expects a cgroup to already be created, relative to the cgroup
+ * work dir, and it joins it. For example, passing "/my-cgroup" as the path
+ * would actually put the calling process into the cgroup
+ * "/cgroup-test-work-dir/my-cgroup"
+ *
+ * On success, it returns 0, otherwise on failure it returns 1.
+ */
+int join_cgroup(char *path)
+{
+	char cgroup_path[PATH_MAX + 1];
+
+	format_cgroup_path(cgroup_path, path);
+	return join_cgroup_from_top(cgroup_path);
+}
+
+/**
+ * cleanup_cgroup_environment() - Cleanup Cgroup Testing Environment
+ *
+ * This is an idempotent function to delete all temporary cgroups that
+ * have been created during the test, including the cgroup testing work
+ * directory.
+ *
+ * At call time, it moves the calling process to the root cgroup, and then
+ * runs the deletion process. It is idempotent, and should not fail, unless
+ * a process is lingering.
+ *
+ * On failure, it will print an error to stderr, and try to continue.
+ */
+void cleanup_cgroup_environment(void)
+{
+	char cgroup_workdir[PATH_MAX + 1];
+
+	format_cgroup_path(cgroup_workdir, "");
+	join_cgroup_from_top(CGROUP_MOUNT_PATH);
+	nftw(cgroup_workdir, nftwfunc, WALK_FD_LIMIT, FTW_DEPTH | FTW_MOUNT);
+}
+
+/**
+ * create_and_get_cgroup() - Create a cgroup, relative to workdir, and get the FD
+ * @path: The cgroup path, relative to the workdir, to join
+ *
+ * This function creates a cgroup under the top level workdir and returns the
+ * file descriptor. It is idempotent.
+ *
+ * On success, it returns the file descriptor. On failure it returns 0.
+ * If there is a failure, it prints the error to stderr.
+ */
+int create_and_get_cgroup(char *path)
+{
+	char cgroup_path[PATH_MAX + 1];
+	int fd;
+
+	format_cgroup_path(cgroup_path, path);
+	if (mkdir(cgroup_path, 0777) && errno != EEXIST) {
+		log_err("mkdiring cgroup");
+		return 0;
+	}
+
+	fd = open(cgroup_path, O_RDONLY);
+	if (fd < 0) {
+		log_err("Opening Cgroup");
+		return 0;
+	}
+
+	return fd;
+}
diff --git a/samples/bpf/cgroup_helpers.h b/samples/bpf/cgroup_helpers.h
new file mode 100644
index 0000000..78c5520
--- /dev/null
+++ b/samples/bpf/cgroup_helpers.h
@@ -0,0 +1,16 @@
+#ifndef __CGROUP_HELPERS_H
+#define __CGROUP_HELPERS_H
+#include <errno.h>
+#include <string.h>
+
+#define clean_errno() (errno == 0 ? "None" : strerror(errno))
+#define log_err(MSG, ...) fprintf(stderr, "(%s:%d: errno: %s) " MSG "\n", \
+	__FILE__, __LINE__, clean_errno(), ##__VA_ARGS__)
+
+
+int create_and_get_cgroup(char *path);
+int join_cgroup(char *path);
+int setup_cgroup_environment(void);
+void cleanup_cgroup_environment(void);
+
+#endif
diff --git a/samples/bpf/test_current_task_under_cgroup_user.c b/samples/bpf/test_current_task_under_cgroup_user.c
index 30b0bce..95aaaa8 100644
--- a/samples/bpf/test_current_task_under_cgroup_user.c
+++ b/samples/bpf/test_current_task_under_cgroup_user.c
@@ -11,50 +11,16 @@
 #include <unistd.h>
 #include "libbpf.h"
 #include "bpf_load.h"
-#include <string.h>
-#include <fcntl.h>
-#include <errno.h>
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
+#define CGROUP_PATH		"/my-cgroup"
 
 int main(int argc, char **argv)
 {
-	char filename[256];
-	int cg2, idx = 0;
 	pid_t remote_pid, local_pid = getpid();
+	int cg2, idx = 0, rc = 0;
+	char filename[256];
 
 	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
 	if (load_bpf_file(filename)) {
@@ -62,47 +28,22 @@ int main(int argc, char **argv)
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
-		return 1;
-	}
-
-	if (mount("none", CGROUP_MOUNT_PATH, "cgroup2", 0, NULL)) {
-		log_err("mount cgroup2");
-		return 1;
-	}
+	if (setup_cgroup_environment())
+		goto err;
 
-	if (mkdir(CGROUP_PATH, 0777) && errno != EEXIST) {
-		log_err("mkdir cgroup");
-		return 1;
-	}
+	cg2 = create_and_get_cgroup(CGROUP_PATH);
 
-	cg2 = open(CGROUP_PATH, O_RDONLY);
-	if (cg2 < 0) {
-		log_err("opening target cgroup");
-		goto cleanup_cgroup_err;
-	}
+	if (!cg2)
+		goto err;
 
 	if (bpf_update_elem(map_fd[0], &idx, &cg2, BPF_ANY)) {
 		log_err("Adding target cgroup to map");
-		goto cleanup_cgroup_err;
-	}
-	if (join_cgroup("/mnt/my-cgroup")) {
-		log_err("Leaving target cgroup");
-		goto cleanup_cgroup_err;
+		goto err;
 	}
 
+	if (join_cgroup(CGROUP_PATH))
+		goto err;
+
 	/*
 	 * The installed helper program catched the sync call, and should
 	 * write it to the map.
@@ -115,12 +56,12 @@ int main(int argc, char **argv)
 		fprintf(stderr,
 			"BPF Helper didn't write correct PID to map, but: %d\n",
 			remote_pid);
-		goto leave_cgroup_err;
+		goto err;
 	}
 
 	/* Verify the negative scenario; leave the cgroup */
-	if (join_cgroup(CGROUP_MOUNT_PATH))
-		goto leave_cgroup_err;
+	if (join_cgroup("/"))
+		goto err;
 
 	remote_pid = 0;
 	bpf_update_elem(map_fd[1], &idx, &remote_pid, BPF_ANY);
@@ -130,16 +71,15 @@ int main(int argc, char **argv)
 
 	if (local_pid == remote_pid) {
 		fprintf(stderr, "BPF cgroup negative test did not work\n");
-		goto cleanup_cgroup_err;
+		goto err;
 	}
 
-	rmdir(CGROUP_PATH);
-	return 0;
+	goto out;
+err:
+	rc = 1;
 
-	/* Error condition, cleanup */
-leave_cgroup_err:
-	join_cgroup(CGROUP_MOUNT_PATH);
-cleanup_cgroup_err:
-	rmdir(CGROUP_PATH);
-	return 1;
+out:
+	close(cg2);
+	cleanup_cgroup_environment();
+	return rc;
 }
-- 
2.7.4
