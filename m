From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] Add support for rt_protos.d
Date: Mon,  9 Jan 2017 15:43:09 -0800
Message-ID: <1484005389-29381-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34050 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031819AbdAIXnP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 18:43:15 -0500
Received: by mail-pf0-f176.google.com with SMTP id 127so35558631pfg.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 15:43:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for reading proto id/name mappings from rt_protos.d
directory. Allows users to have custom protocol values converted
to human friendly names.

Each file under rt_protos.d has the 'id name' format used by
rt_protos. Only .conf files are read and parsed.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 etc/iproute2/rt_protos.d/README |  3 +++
 lib/rt_names.c                  | 27 +++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)
 create mode 100644 etc/iproute2/rt_protos.d/README

diff --git a/etc/iproute2/rt_protos.d/README b/etc/iproute2/rt_protos.d/README
new file mode 100644
index 000000000000..723509ce56b6
--- /dev/null
+++ b/etc/iproute2/rt_protos.d/README
@@ -0,0 +1,3 @@
+Each file in this directory is an rt_protos configuration file. iproute2
+commands scan this directory processing all files that end in '.conf'.
+
diff --git a/lib/rt_names.c b/lib/rt_names.c
index c66cb1e439e3..7553288eeb18 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -142,9 +142,36 @@ static int rtnl_rtprot_init;
 
 static void rtnl_rtprot_initialize(void)
 {
+	struct dirent *de;
+	DIR *d;
+
 	rtnl_rtprot_init = 1;
 	rtnl_tab_initialize(CONFDIR "/rt_protos",
 			    rtnl_rtprot_tab, 256);
+
+	d = opendir(CONFDIR "/rt_protos.d");
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
+		snprintf(path, sizeof(path), CONFDIR "/rt_protos.d/%s",
+			 de->d_name);
+		rtnl_tab_initialize(path, rtnl_rtprot_tab, 256);
+	}
+	closedir(d);
 }
 
 const char *rtnl_rtprot_n2a(int id, char *buf, int len)
-- 
2.1.4
