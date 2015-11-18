From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] Add support for rt_tables.d
Date: Wed, 18 Nov 2015 11:03:20 -0800
Message-ID: <1447873400-15337-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33835 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbbKRTD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 14:03:27 -0500
Received: by padhx2 with SMTP id hx2so53272027pad.1
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 11:03:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for reading table id/name mappings from rt_tables.d
directory.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 lib/rt_names.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index e87c65dad39e..d835ff9c7ee0 100644
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
@@ -348,6 +351,21 @@ static void rtnl_rttable_initialize(void)
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
+
+		if (*de->d_name == '.')
+			continue;
+
+		snprintf(path, sizeof(path), CONFDIR "/rt_tables.d/%s", de->d_name);
+		rtnl_hash_initialize(path, rtnl_rttable_hash, 256);
+	}
+	closedir(d);
 }
 
 const char * rtnl_rttable_n2a(__u32 id, char *buf, int len)
-- 
1.9.1
