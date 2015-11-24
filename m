From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2] Add support for rt_tables.d
Date: Tue, 24 Nov 2015 13:20:01 -0800
Message-ID: <1448400001-19897-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33233 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119AbbKXVUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 16:20:11 -0500
Received: by pabfh17 with SMTP id fh17so34699543pab.0
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 13:20:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for reading table id/name mappings from rt_tables.d
directory.

Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- comments from Stephen
  - only process files ending in '.conf'
  - add README file to etc/iproute2/rt_tables.d

 etc/iproute2/rt_tables.d/README |  3 +++
 lib/rt_names.c                  | 26 ++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)
 create mode 100644 etc/iproute2/rt_tables.d/README

diff --git a/etc/iproute2/rt_tables.d/README b/etc/iproute2/rt_tables.d/README
new file mode 100644
index 000000000000..79386f89cc14
--- /dev/null
+++ b/etc/iproute2/rt_tables.d/README
@@ -0,0 +1,3 @@
+Each file in this directory is an rt_tables configuration file. iproute2
+commands scan this directory processing all files that end in '.conf'.
+
diff --git a/lib/rt_names.c b/lib/rt_names.c
index e87c65dad39e..f68e91d6d046 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -17,6 +17,7 @@
 #include <string.h>
 #include <sys/time.h>
 #include <sys/socket.h>
+#include <dirent.h>
 
 #include <asm/types.h>
 #include <linux/rtnetlink.h>
@@ -339,6 +340,8 @@ static int rtnl_rttable_init;
 
 static void rtnl_rttable_initialize(void)
 {
+	struct dirent *de;
+	DIR *d;
 	int i;
 
 	rtnl_rttable_init = 1;
@@ -348,6 +351,29 @@ static void rtnl_rttable_initialize(void)
 	}
 	rtnl_hash_initialize(CONFDIR "/rt_tables",
 			     rtnl_rttable_hash, 256);
+
+	d = opendir(CONFDIR "/rt_tables.d");
+	if (!d)
+		return;
+
+	while ((de = readdir(d)) != NULL) {
+		char path[PATH_MAX];
+		size_t len;
+
+		if (*de->d_name == '.')
+			continue;
+
+		/* only consider filenames ending in '.conf' */
+		len = strlen(de->d_name);
+		if (len <= 5)
+			continue;
+		if (strcmp(de->d_name + len - 5, ".conf"))
+			continue;
+
+		snprintf(path, sizeof(path), CONFDIR "/rt_tables.d/%s", de->d_name);
+		rtnl_hash_initialize(path, rtnl_rttable_hash, 256);
+	}
+	closedir(d);
 }
 
 const char * rtnl_rttable_n2a(__u32 id, char *buf, int len)
-- 
2.1.4
