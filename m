From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] ip vrf: Add command name next to pid
Date: Wed, 12 Apr 2017 18:54:12 -0700
Message-ID: <1492048452-9052-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34631 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755863AbdDMByn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 21:54:43 -0400
Received: by mail-pf0-f178.google.com with SMTP id c198so21604360pfc.1
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 18:54:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'ip vrf pids' is used to list processes bound to a vrf, but it only
shows the pid leaving a lot of work for the user. Add the command
name to the output. With this patch you get the more user friendly:

    $ ip vrf pids mgmt
     1121  ntpd
     1418  gdm-session-wor
     1488  gnome-session
     1491  dbus-launch
     1492  dbus-daemon
     1565  sshd
     ...

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/utils.h |  1 +
 ip/ipvrf.c      | 24 ++++++++++++++----------
 lib/fs.c        | 42 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 57 insertions(+), 10 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 22369e0b4e03..d66784674633 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -260,5 +260,6 @@ int get_real_family(int rtm_type, int rtm_family);
 int cmd_exec(const char *cmd, char **argv, bool do_fork);
 int make_path(const char *path, mode_t mode);
 char *find_cgroup2_mount(void);
+int get_comm(char *pid, char *comm, int len);
 
 #endif /* __UTILS_H__ */
diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index 5e204a9ebbb1..6d4bd6206cc8 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -111,27 +111,31 @@ static void read_cgroup_pids(const char *base_path, char *name)
 {
 	char path[PATH_MAX];
 	char buf[4096];
-	ssize_t n;
-	int fd;
+	FILE *fp;
 
 	if (snprintf(path, sizeof(path), "%s/vrf/%s%s",
 		     base_path, name, CGRP_PROC_FILE) >= sizeof(path))
 		return;
 
-	fd = open(path, O_RDONLY);
-	if (fd < 0)
+	fp = fopen(path, "r");
+	if (!fp)
 		return; /* no cgroup file, nothing to show */
 
 	/* dump contents (pids) of cgroup.procs */
-	while (1) {
-		n = read(fd, buf, sizeof(buf) - 1);
-		if (n <= 0)
-			break;
+	while (fgets(buf, sizeof(buf), fp)) {
+		char *nl, comm[32];
 
-		printf("%s", buf);
+		nl = strchr(buf, '\n');
+		if (nl)
+			*nl = '\0';
+
+		if (get_comm(buf, comm, sizeof(comm)))
+			strcpy(comm, "<terminated?>");
+
+		printf("%5s  %s\n", buf, comm);
 	}
 
-	close(fd);
+	fclose(fp);
 }
 
 /* recurse path looking for PATH[/NETNS]/vrf/NAME */
diff --git a/lib/fs.c b/lib/fs.c
index 12a4657a0bc9..81298f0ad91a 100644
--- a/lib/fs.c
+++ b/lib/fs.c
@@ -14,6 +14,7 @@
 #include <sys/stat.h>
 #include <sys/socket.h>
 #include <sys/mount.h>
+#include <ctype.h>
 #include <fcntl.h>
 #include <stdio.h>
 #include <stdlib.h>
@@ -149,3 +150,44 @@ int make_path(const char *path, mode_t mode)
 
 	return rc;
 }
+
+int get_comm(char *pid, char *comm, int len)
+{
+	char path[PATH_MAX];
+	char line[128];
+	FILE *fp;
+
+	if (snprintf(path, sizeof(path),
+		     "/proc/%s/status", pid) >= sizeof(path)) {
+		return -1;
+	}
+
+	fp = fopen(path, "r");
+	if (!fp)
+		return -1;
+
+	comm[0] = '\0';
+	while (fgets(line, sizeof(line), fp)) {
+		char *nl, *name;
+
+		name = strstr(line, "Name:");
+		if (!name)
+			continue;
+
+		name += 5;
+		while (isspace(*name))
+			name++;
+
+		nl = strchr(name, '\n');
+		if (nl)
+			*nl = '\0';
+
+		strncpy(comm, name, len - 1);
+		comm[len - 1] = '\0';
+		break;
+	}
+
+	fclose(fp);
+
+	return 0;
+}
-- 
2.1.4
