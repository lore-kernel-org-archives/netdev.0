From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2 1/3] lib: Exec func on each netns
Date: Sun, 18 Jan 2015 16:10:17 +0200
Message-ID: <1421590219-19365-2-git-send-email-vadim4j@gmail.com>
References: <1421590219-19365-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:61349 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbbAROUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 09:20:55 -0500
Received: by mail-we0-f179.google.com with SMTP id q59so3787395wes.10
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 06:20:54 -0800 (PST)
In-Reply-To: <1421590219-19365-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added possibility to run some func on each netns.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/namespace.h |  6 ++++++
 include/utils.h     |  4 ++++
 lib/namespace.c     | 22 ++++++++++++++++++++++
 lib/utils.c         | 28 ++++++++++++++++++++++++++++
 4 files changed, 60 insertions(+)

diff --git a/include/namespace.h b/include/namespace.h
index b8c5cad..26898b0 100644
--- a/include/namespace.h
+++ b/include/namespace.h
@@ -43,5 +43,11 @@ static int setns(int fd, int nstype)
 
 extern int netns_switch(char *netns);
 extern int netns_get_fd(const char *netns);
+extern int netns_foreach(int (*func)(char *nsname, void *arg), void *arg);
+
+struct netns_func {
+	int (*func)(char *nsname, void *arg);
+	void *arg;
+};
 
 #endif /* __NAMESPACE_H__ */
diff --git a/include/utils.h b/include/utils.h
index e1fe7cf..a8817d3 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -5,6 +5,7 @@
 #include <asm/types.h>
 #include <resolv.h>
 #include <stdlib.h>
+#include <stdbool.h>
 
 #include "libnetlink.h"
 #include "ll_map.h"
@@ -162,4 +163,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev,
 		int *group, int *index);
 
+extern int do_each_netns(int (*func)(char *nsname, void *arg), void *arg,
+		bool show_label);
+
 #endif /* __UTILS_H__ */
diff --git a/lib/namespace.c b/lib/namespace.c
index 65c1e3d..c03a103 100644
--- a/lib/namespace.c
+++ b/lib/namespace.c
@@ -99,3 +99,25 @@ int netns_get_fd(const char *name)
 	}
 	return open(path, O_RDONLY);
 }
+
+int netns_foreach(int (*func)(char *nsname, void *arg), void *arg)
+{
+	DIR *dir;
+	struct dirent *entry;
+
+	dir = opendir(NETNS_RUN_DIR);
+	if (!dir)
+		return -1;
+
+	while ((entry = readdir(dir)) != NULL) {
+		if (strcmp(entry->d_name, ".") == 0)
+			continue;
+		if (strcmp(entry->d_name, "..") == 0)
+			continue;
+		if (func(entry->d_name, arg))
+			break;
+	}
+
+	closedir(dir);
+	return 0;
+}
diff --git a/lib/utils.c b/lib/utils.c
index f65ceaa..efebe18 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -31,6 +31,7 @@
 
 
 #include "utils.h"
+#include "namespace.h"
 
 int timestamp_short = 0;
 
@@ -878,3 +879,30 @@ void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n)
 	tstr[strlen(tstr)-1] = 0;
 	fprintf(fp, "Timestamp: %s %lu us\n", tstr, usecs);
 }
+
+static int on_netns(char *nsname, void *arg)
+{
+	struct netns_func *f = arg;
+
+	if (netns_switch(nsname))
+		return -1;
+
+	return f->func(nsname, f->arg);
+}
+
+static int on_netns_label(char *nsname, void *arg)
+{
+	printf("\nnetns: %s\n", nsname);
+	return on_netns(nsname, arg);
+}
+
+int do_each_netns(int (*func)(char *nsname, void *arg), void *arg,
+		bool show_label)
+{
+	struct netns_func nsf = { .func = func, .arg = arg };
+
+	if (show_label)
+		return netns_foreach(on_netns_label, &nsf);
+
+	return netns_foreach(on_netns, &nsf);
+}
-- 
2.1.3
