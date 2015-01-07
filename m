From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 1/3] lib: Exec func on each netns
Date: Wed,  7 Jan 2015 13:04:20 +0200
Message-ID: <1420628662-9930-2-git-send-email-vadim4j@gmail.com>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:61202 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbbAGLOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 06:14:48 -0500
Received: by mail-lb0-f180.google.com with SMTP id l4so876704lbv.11
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 03:14:45 -0800 (PST)
In-Reply-To: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added possibility to run some func on each netns.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/namespace.h |  6 ++++++
 include/utils.h     |  5 +++++
 lib/namespace.c     | 22 ++++++++++++++++++++++
 lib/utils.c         | 28 ++++++++++++++++++++++++++++
 4 files changed, 61 insertions(+)

diff --git a/include/namespace.h b/include/namespace.h
index 2f13e65..1a7e066 100644
--- a/include/namespace.h
+++ b/include/namespace.h
@@ -42,5 +42,11 @@ static int setns(int fd, int nstype)
 #endif /* HAVE_SETNS */
 
 extern int netns_switch(char *netns);
+extern int netns_foreach(int (*func)(char *nsname, void *arg), void *arg);
+
+struct netns_func {
+	int (*func)(char *nsname, void *arg);
+	void *arg;
+};
 
 #endif /* __NAMESPACE_H__ */
diff --git a/include/utils.h b/include/utils.h
index eecbc39..3196561 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -5,6 +5,7 @@
 #include <asm/types.h>
 #include <resolv.h>
 #include <stdlib.h>
+#include <stdbool.h>
 
 #include "libnetlink.h"
 #include "ll_map.h"
@@ -160,4 +161,8 @@ struct iplink_req;
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev,
 		int *group, int *index);
+
+extern int do_each_netns(int (*func)(char *nsname, void *arg), void *arg,
+		bool show_label);
+
 #endif /* __UTILS_H__ */
diff --git a/lib/namespace.c b/lib/namespace.c
index 1554ce0..a0f7c6d 100644
--- a/lib/namespace.c
+++ b/lib/namespace.c
@@ -84,3 +84,25 @@ int netns_switch(char *name)
 	bind_etc(name);
 	return 0;
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
index 64915f3..e3ca11b 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -31,6 +31,7 @@
 
 
 #include "utils.h"
+#include "namespace.h"
 
 int timestamp_short = 0;
 
@@ -868,3 +869,30 @@ int inet_get_addr(const char *src, __u32 *dst, struct in6_addr *dst6)
 	else
 		return inet_pton(AF_INET, src, dst);
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
