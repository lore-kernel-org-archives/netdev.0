From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 2/4] ip netns: refactor netns_identify
Date: Thu, 16 Feb 2017 08:58:56 -0800
Message-ID: <1487264338-17588-3-git-send-email-dsa@cumulusnetworks.com>
References: <1487264338-17588-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36056 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932491AbdBPQ7G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 11:59:06 -0500
Received: by mail-pg0-f51.google.com with SMTP id v184so7651139pgv.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 08:59:05 -0800 (PST)
In-Reply-To: <1487264338-17588-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move guts of netns_identify into a standalone function that returns
the netns name in a given buffer.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ip_common.h |  1 +
 ip/ipnetns.c   | 47 +++++++++++++++++++++++++++++++----------------
 2 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index ab6a83431fd6..e8642a184f39 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -59,6 +59,7 @@ int do_ipnetconf(int argc, char **argv);
 int do_iptoken(int argc, char **argv);
 int do_ipvrf(int argc, char **argv);
 void vrf_reset(void);
+int netns_identify_pid(const char *pidstr, char *name, int len);
 
 int iplink_get(unsigned int flags, char *name, __u32 filt_mask);
 
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 8201b94a1620..0b0378ab6560 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -468,28 +468,15 @@ static int netns_pids(int argc, char **argv)
 
 }
 
-static int netns_identify(int argc, char **argv)
+int netns_identify_pid(const char *pidstr, char *name, int len)
 {
-	const char *pidstr;
 	char net_path[PATH_MAX];
 	int netns;
 	struct stat netst;
 	DIR *dir;
 	struct dirent *entry;
 
-	if (argc < 1) {
-		pidstr = "self";
-	} else if (argc > 1) {
-		fprintf(stderr, "extra arguments specified\n");
-		return -1;
-	} else {
-		pidstr = argv[0];
-		if (!is_pid(pidstr)) {
-			fprintf(stderr, "Specified string '%s' is not a pid\n",
-					pidstr);
-			return -1;
-		}
-	}
+	name[0] = '\0';
 
 	snprintf(net_path, sizeof(net_path), "/proc/%s/ns/net", pidstr);
 	netns = open(net_path, O_RDONLY);
@@ -531,7 +518,8 @@ static int netns_identify(int argc, char **argv)
 
 		if ((st.st_dev == netst.st_dev) &&
 		    (st.st_ino == netst.st_ino)) {
-			printf("%s\n", entry->d_name);
+			strncpy(name, entry->d_name, len - 1);
+			name[len - 1] = '\0';
 		}
 	}
 	closedir(dir);
@@ -539,6 +527,33 @@ static int netns_identify(int argc, char **argv)
 
 }
 
+static int netns_identify(int argc, char **argv)
+{
+	const char *pidstr;
+	char name[256];
+	int rc;
+
+	if (argc < 1) {
+		pidstr = "self";
+	} else if (argc > 1) {
+		fprintf(stderr, "extra arguments specified\n");
+		return -1;
+	} else {
+		pidstr = argv[0];
+		if (!is_pid(pidstr)) {
+			fprintf(stderr, "Specified string '%s' is not a pid\n",
+					pidstr);
+			return -1;
+		}
+	}
+
+	rc = netns_identify_pid(pidstr, name, sizeof(name));
+	if (!rc)
+		printf("%s\n", name);
+
+	return rc;
+}
+
 static int on_netns_del(char *nsname, void *arg)
 {
 	char netns_path[PATH_MAX];
-- 
2.1.4
