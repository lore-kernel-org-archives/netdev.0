From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 1/4] ip vrf: Handle vrf in a cgroup hierarchy
Date: Thu, 16 Feb 2017 08:58:55 -0800
Message-ID: <1487264338-17588-2-git-send-email-dsa@cumulusnetworks.com>
References: <1487264338-17588-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36856 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932338AbdBPQ7F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 11:59:05 -0500
Received: by mail-pf0-f179.google.com with SMTP id 189so6837545pfu.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 08:59:05 -0800 (PST)
In-Reply-To: <1487264338-17588-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for VRF in a pre-existing hierarchy. For example, if the
current process is running in CGRP/foo/bar, the 'ip vrf exec NAME CMD'
should run CMD in the cgroup CGRP/foo/bar/vrf/NAME.

When listing process ids in a VRF, search for the directory vrf/NAME
regardless of base path (foo/bar/vrf/NAME and vrf/NAME) are still
running against the same vrf NAME.

Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipvrf.c | 173 +++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 145 insertions(+), 28 deletions(-)

diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index 8bd99d6251f2..8d61d0718c66 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -21,6 +21,7 @@
 #include <stdlib.h>
 #include <unistd.h>
 #include <string.h>
+#include <dirent.h>
 #include <errno.h>
 #include <limits.h>
 
@@ -40,6 +41,10 @@ static void usage(void)
 	exit(-1);
 }
 
+/*
+ * parse process based cgroup file looking for PATH/vrf/NAME where
+ * NAME is the name of the vrf the process is associated with
+ */
 static int vrf_identify(pid_t pid, char *name, size_t len)
 {
 	char path[PATH_MAX];
@@ -55,9 +60,13 @@ static int vrf_identify(pid_t pid, char *name, size_t len)
 	memset(name, 0, len);
 
 	while (fgets(buf, sizeof(buf), fp)) {
-		vrf = strstr(buf, "::/vrf/");
+		/* want the controller-less cgroup */
+		if (strstr(buf, "::/") == NULL)
+			continue;
+
+		vrf = strstr(buf, "/vrf/");
 		if (vrf) {
-			vrf += 7;  /* skip past "::/vrf/" */
+			vrf += 5;  /* skip past "/vrf/" */
 			end = strchr(vrf, '\n');
 			if (end)
 				*end = '\0';
@@ -97,50 +106,101 @@ static int ipvrf_identify(int argc, char **argv)
 	return rc;
 }
 
-static int ipvrf_pids(int argc, char **argv)
+/* read PATH/vrf/NAME/cgroup.procs file */
+static void read_cgroup_pids(const char *base_path, char *name)
 {
 	char path[PATH_MAX];
 	char buf[4096];
-	char *mnt, *vrf;
-	int fd, rc = -1;
 	ssize_t n;
+	int fd;
 
-	if (argc != 1) {
-		fprintf(stderr, "Invalid arguments\n");
-		return -1;
-	}
-
-	vrf = argv[0];
-
-	mnt = find_cgroup2_mount();
-	if (!mnt)
-		return -1;
+	if (snprintf(path, sizeof(path), "%s/vrf/%s%s",
+		     base_path, name, CGRP_PROC_FILE) >= sizeof(path))
+		return;
 
-	snprintf(path, sizeof(path), "%s/vrf/%s%s", mnt, vrf, CGRP_PROC_FILE);
-	free(mnt);
 	fd = open(path, O_RDONLY);
 	if (fd < 0)
-		return 0; /* no cgroup file, nothing to show */
+		return; /* no cgroup file, nothing to show */
 
+	/* dump contents (pids) of cgroup.procs */
 	while (1) {
 		n = read(fd, buf, sizeof(buf) - 1);
-		if (n < 0) {
-			fprintf(stderr,
-				"Failed to read cgroups file: %s\n",
-				strerror(errno));
+		if (n <= 0)
 			break;
-		} else if (n == 0) {
-			rc = 0;
-			break;
-		}
+
 		printf("%s", buf);
 	}
 
 	close(fd);
+}
+
+/* recurse path looking for PATH/vrf/NAME */
+static int recurse_dir(char *base_path, char *name)
+{
+	char path[PATH_MAX];
+	struct dirent *de;
+	struct stat fstat;
+	int rc;
+	DIR *d;
+
+	d = opendir(base_path);
+	if (!d)
+		return -1;
+
+	while ((de = readdir(d)) != NULL) {
+		if (!strcmp(de->d_name, ".") || !strcmp(de->d_name, ".."))
+			continue;
+
+		if (!strcmp(de->d_name, "vrf")) {
+			read_cgroup_pids(base_path, name);
+			continue;
+		}
+
+		/* is this a subdir that needs to be walked */
+		if (snprintf(path, sizeof(path), "%s/%s",
+			     base_path, de->d_name) >= sizeof(path))
+			continue;
+
+		if (lstat(path, &fstat) < 0)
+			continue;
+
+		if (S_ISDIR(fstat.st_mode)) {
+			rc = recurse_dir(path, name);
+			if (rc != 0)
+				goto out;
+		}
+	}
+
+	rc = 0;
+out:
+	closedir(d);
 
 	return rc;
 }
 
+static int ipvrf_pids(int argc, char **argv)
+{
+	char *mnt, *vrf;
+	int ret;
+
+	if (argc != 1) {
+		fprintf(stderr, "Invalid arguments\n");
+		return -1;
+	}
+
+	vrf = argv[0];
+
+	mnt = find_cgroup2_mount();
+	if (!mnt)
+		return -1;
+
+	ret = recurse_dir(mnt, vrf);
+
+	free(mnt);
+
+	return ret;
+}
+
 /* load BPF program to set sk_bound_dev_if for sockets */
 static char bpf_log_buf[256*1024];
 
@@ -203,9 +263,60 @@ static int vrf_configure_cgroup(const char *path, int ifindex)
 	return rc;
 }
 
+/* get base path for controller-less cgroup for a process.
+ * path returned does not include /vrf/NAME if it exists
+ */
+static int vrf_path(char *vpath, size_t len)
+{
+	char path[PATH_MAX];
+	char buf[4096];
+	char *vrf;
+	FILE *fp;
+
+	snprintf(path, sizeof(path), "/proc/%d/cgroup", getpid());
+	fp = fopen(path, "r");
+	if (!fp)
+		return -1;
+
+	vpath[0] = '\0';
+
+	while (fgets(buf, sizeof(buf), fp)) {
+		char *start, *nl;
+
+		start = strstr(buf, "::/");
+		if (!start)
+			continue;
+
+		/* advance past '::' */
+		start += 2;
+
+		nl = strchr(start, '\n');
+		if (nl)
+			*nl = '\0';
+
+		vrf = strstr(start, "/vrf");
+		if (vrf)
+			*vrf = '\0';
+
+		strncpy(vpath, start, len - 1);
+		vpath[len - 1] = '\0';
+
+		/* if vrf path is just / then return nothing */
+		if (!strcmp(vpath, "/"))
+			vpath[0] = '\0';
+
+		break;
+	}
+
+	fclose(fp);
+
+	return 0;
+}
+
 static int vrf_switch(const char *name)
 {
 	char path[PATH_MAX], *mnt, pid[16];
+	char vpath[PATH_MAX];
 	int ifindex = 0;
 	int rc = -1, len, fd = -1;
 
@@ -221,11 +332,17 @@ static int vrf_switch(const char *name)
 	if (!mnt)
 		return -1;
 
+	if (vrf_path(vpath, sizeof(vpath)) < 0) {
+		fprintf(stderr, "Failed to get base cgroup path: %s\n",
+			strerror(errno));
+		return -1;
+	}
+
 	/* path to cgroup; make sure buffer has room to cat "/cgroup.procs"
 	 * to the end of the path
 	 */
-	len = snprintf(path, sizeof(path) - sizeof(CGRP_PROC_FILE), "%s/vrf/%s",
-		       mnt, ifindex ? name : "");
+	len = snprintf(path, sizeof(path) - sizeof(CGRP_PROC_FILE),
+		       "%s%s/vrf/%s", mnt, vpath, ifindex ? name : "");
 	if (len > sizeof(path) - sizeof(CGRP_PROC_FILE)) {
 		fprintf(stderr, "Invalid path to cgroup2 mount\n");
 		goto out;
-- 
2.1.4
