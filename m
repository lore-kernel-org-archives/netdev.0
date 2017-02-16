From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 3/4] ip vrf: Handle VRF nesting in namespace
Date: Thu, 16 Feb 2017 08:58:57 -0800
Message-ID: <1487264338-17588-4-git-send-email-dsa@cumulusnetworks.com>
References: <1487264338-17588-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34063 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932338AbdBPQ7R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 11:59:17 -0500
Received: by mail-pf0-f173.google.com with SMTP id e4so6844968pfg.1
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 08:59:06 -0800 (PST)
In-Reply-To: <1487264338-17588-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since cgroups are not namespace aware, the directory heirarchy used by
ip vrf should account for network namespaces. In this case, change the
path from CGRP/BASE/vrf/NAME to CGRP/BASE/NETNS/vrf/NAME where CGRP is
the cgroup2 mount path, BASE in any base heirarchy inherited before VRF
is applied and NAME is the VRF name.

The intent is as follows: a user logs into the box into some namespace
with a name known to iproute2. Some other policy may have put the
process into a BASE heirarchy. From there the user executes a task in
a VRF and in doing so the task heirarchy becomes CGRP/BASE/NETNS/vrf/NAME.
The namespace level is omitted for the default namespace.

Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipvrf.c | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 55 insertions(+), 8 deletions(-)

diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index 8d61d0718c66..cb7f9fa6d1db 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -134,8 +134,8 @@ static void read_cgroup_pids(const char *base_path, char *name)
 	close(fd);
 }
 
-/* recurse path looking for PATH/vrf/NAME */
-static int recurse_dir(char *base_path, char *name)
+/* recurse path looking for PATH[/NETNS]/vrf/NAME */
+static int recurse_dir(char *base_path, char *name, const char *netns)
 {
 	char path[PATH_MAX];
 	struct dirent *de;
@@ -152,7 +152,15 @@ static int recurse_dir(char *base_path, char *name)
 			continue;
 
 		if (!strcmp(de->d_name, "vrf")) {
-			read_cgroup_pids(base_path, name);
+			const char *pdir = strrchr(base_path, '/');
+
+			/* found a 'vrf' directory. if it is for the given
+			 * namespace then dump the cgroup pids
+			 */
+			if (*netns == '\0' ||
+			    (pdir && !strcmp(pdir+1, netns)))
+				read_cgroup_pids(base_path, name);
+
 			continue;
 		}
 
@@ -165,7 +173,7 @@ static int recurse_dir(char *base_path, char *name)
 			continue;
 
 		if (S_ISDIR(fstat.st_mode)) {
-			rc = recurse_dir(path, name);
+			rc = recurse_dir(path, name, netns);
 			if (rc != 0)
 				goto out;
 		}
@@ -178,10 +186,25 @@ static int recurse_dir(char *base_path, char *name)
 	return rc;
 }
 
+static int ipvrf_get_netns(char *netns, int len)
+{
+	if (netns_identify_pid("self", netns, len-3)) {
+		fprintf(stderr, "Failed to get name of network namespace: %s\n",
+			strerror(errno));
+		return -1;
+	}
+
+	if (*netns != '\0')
+		strcat(netns, "-ns");
+
+	return 0;
+}
+
 static int ipvrf_pids(int argc, char **argv)
 {
 	char *mnt, *vrf;
-	int ret;
+	char netns[256];
+	int ret = -1;
 
 	if (argc != 1) {
 		fprintf(stderr, "Invalid arguments\n");
@@ -194,8 +217,12 @@ static int ipvrf_pids(int argc, char **argv)
 	if (!mnt)
 		return -1;
 
-	ret = recurse_dir(mnt, vrf);
+	if (ipvrf_get_netns(netns, sizeof(netns)) < 0)
+		goto out;
+
+	ret = recurse_dir(mnt, vrf, netns);
 
+out:
 	free(mnt);
 
 	return ret;
@@ -316,7 +343,7 @@ static int vrf_path(char *vpath, size_t len)
 static int vrf_switch(const char *name)
 {
 	char path[PATH_MAX], *mnt, pid[16];
-	char vpath[PATH_MAX];
+	char vpath[PATH_MAX], netns[256];
 	int ifindex = 0;
 	int rc = -1, len, fd = -1;
 
@@ -332,17 +359,37 @@ static int vrf_switch(const char *name)
 	if (!mnt)
 		return -1;
 
+	/* -1 on length to add '/' to the end */
+	if (ipvrf_get_netns(netns, sizeof(netns) - 1) < 0)
+		return -1;
+
 	if (vrf_path(vpath, sizeof(vpath)) < 0) {
 		fprintf(stderr, "Failed to get base cgroup path: %s\n",
 			strerror(errno));
 		return -1;
 	}
 
+	/* if path already ends in netns then don't add it again */
+	if (*netns != '\0') {
+		char *pdir = strrchr(vpath, '/');
+
+		if (!pdir)
+			pdir = vpath;
+		else
+			pdir++;
+
+		if (strcmp(pdir, netns) == 0)
+			*pdir = '\0';
+
+		strcat(netns, "/");
+	}
+
 	/* path to cgroup; make sure buffer has room to cat "/cgroup.procs"
 	 * to the end of the path
 	 */
 	len = snprintf(path, sizeof(path) - sizeof(CGRP_PROC_FILE),
-		       "%s%s/vrf/%s", mnt, vpath, ifindex ? name : "");
+		       "%s%s/%svrf/%s",
+		       mnt, vpath, netns, ifindex ? name : "");
 	if (len > sizeof(path) - sizeof(CGRP_PROC_FILE)) {
 		fprintf(stderr, "Invalid path to cgroup2 mount\n");
 		goto out;
-- 
2.1.4
