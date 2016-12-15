From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 2/4] ip vrf: Refactor ipvrf_identify
Date: Thu, 15 Dec 2016 12:07:00 -0800
Message-ID: <1481832422-10267-3-git-send-email-dsa@cumulusnetworks.com>
References: <1481832422-10267-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35751 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754517AbcLOUHK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 15:07:10 -0500
Received: by mail-pg0-f53.google.com with SMTP id p66so23346591pga.2
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 12:07:10 -0800 (PST)
In-Reply-To: <1481832422-10267-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split ipvrf_identify into arg processing and a function that does the
actual cgroup file parsing. The latter function is used in a follow
on patch.

In the process, convert the reading of the cgroups file to use fopen
and fgets just in case the file ever grows beyond 4k. Move printing
of any error message and the vrf name to the caller of the new
vrf_identify.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipvrf.c | 69 +++++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 39 insertions(+), 30 deletions(-)

diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index 44ad7e07024a..a2669f339691 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -40,14 +40,43 @@ static void usage(void)
 	exit(-1);
 }
 
-static int ipvrf_identify(int argc, char **argv)
+static int vrf_identify(pid_t pid, char *name, size_t len)
 {
 	char path[PATH_MAX];
 	char buf[4096];
 	char *vrf, *end;
-	int fd, rc = -1;
+	FILE *fp;
+
+	snprintf(path, sizeof(path), "/proc/%d/cgroup", pid);
+	fp = fopen(path, "r");
+	if (!fp)
+		return -1;
+
+	memset(name, 0, len);
+
+	while (fgets(buf, sizeof(buf), fp)) {
+		vrf = strstr(buf, "::/vrf/");
+		if (vrf) {
+			vrf += 7;  /* skip past "::/vrf/" */
+			end = strchr(vrf, '\n');
+			if (end)
+				*end = '\0';
+
+			strncpy(name, vrf, len - 1);
+			break;
+		}
+	}
+
+	fclose(fp);
+
+	return 0;
+}
+
+static int ipvrf_identify(int argc, char **argv)
+{
+	char vrf[32];
+	int rc;
 	unsigned int pid;
-	ssize_t n;
 
 	if (argc < 1)
 		pid = getpid();
@@ -56,35 +85,15 @@ static int ipvrf_identify(int argc, char **argv)
 	else if (get_unsigned(&pid, argv[0], 10))
 		invarg("Invalid pid\n", argv[0]);
 
-	snprintf(path, sizeof(path), "/proc/%d/cgroup", pid);
-	fd = open(path, O_RDONLY);
-	if (fd < 0) {
-		fprintf(stderr,
-			"Failed to open cgroups file: %s\n", strerror(errno));
-		return -1;
-	}
-
-	n = read(fd, buf, sizeof(buf) - 1);
-	if (n < 0) {
-		fprintf(stderr,
-			"Failed to read cgroups file: %s\n", strerror(errno));
-		goto out;
-	}
-	buf[n] = '\0';
-	vrf = strstr(buf, "::/vrf/");
-	if (vrf) {
-		vrf += 7;  /* skip past "::/vrf/" */
-		end = strchr(vrf, '\n');
-		if (end)
-			*end = '\0';
-
-		printf("%s\n", vrf);
+	rc = vrf_identify(pid, vrf, sizeof(vrf));
+	if (!rc) {
+		if (vrf[0] != '\0')
+			printf("%s\n", vrf);
+	} else {
+		fprintf(stderr, "Failed to lookup vrf association: %s\n",
+			strerror(errno));
 	}
 
-	rc = 0;
-out:
-	close(fd);
-
 	return rc;
 }
 
-- 
2.1.4
