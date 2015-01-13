From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] netns: Rename & move get_netns_fd to lib
Date: Tue, 13 Jan 2015 22:08:44 +0200
Message-ID: <1421179724-4448-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:42630 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbbAMUTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 15:19:15 -0500
Received: by mail-la0-f42.google.com with SMTP id gd6so4705087lab.1
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 12:19:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Renamed get_netns_fd -> netns_get_fd and moved to
lib/namespace.c

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/namespace.h |  1 +
 ip/ip_common.h      |  1 -
 ip/iplink.c         |  3 ++-
 ip/ipnetns.c        | 15 ---------------
 lib/namespace.c     | 15 +++++++++++++++
 5 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/include/namespace.h b/include/namespace.h
index 2f13e65..b8c5cad 100644
--- a/include/namespace.h
+++ b/include/namespace.h
@@ -42,5 +42,6 @@ static int setns(int fd, int nstype)
 #endif /* HAVE_SETNS */
 
 extern int netns_switch(char *netns);
+extern int netns_get_fd(const char *netns);
 
 #endif /* __NAMESPACE_H__ */
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 75bfb82..89a495e 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -87,7 +87,6 @@ struct link_util
 
 struct link_util *get_link_kind(const char *kind);
 struct link_util *get_link_slave_kind(const char *slave_kind);
-int get_netns_fd(const char *name);
 
 #ifndef	INFINITY_LIFE_TIME
 #define     INFINITY_LIFE_TIME      0xFFFFFFFFU
diff --git a/ip/iplink.c b/ip/iplink.c
index 2709173..c93d1dc 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -32,6 +32,7 @@
 #include "rt_names.h"
 #include "utils.h"
 #include "ip_common.h"
+#include "namespace.h"
 
 #define IPLINK_IOCTL_COMPAT	1
 #ifndef LIBDIR
@@ -440,7 +441,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			NEXT_ARG();
 			if (netns != -1)
 				duparg("netns", *argv);
-			if ((netns = get_netns_fd(*argv)) >= 0)
+			if ((netns = netns_get_fd(*argv)) >= 0)
 				addattr_l(&req->n, sizeof(*req), IFLA_NET_NS_FD, &netns, 4);
 			else if (get_integer(&netns, *argv, 0) == 0)
 				addattr_l(&req->n, sizeof(*req), IFLA_NET_NS_PID, &netns, 4);
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 519d518..123318e 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -31,21 +31,6 @@ static int usage(void)
 	exit(-1);
 }
 
-int get_netns_fd(const char *name)
-{
-	char pathbuf[MAXPATHLEN];
-	const char *path, *ptr;
-
-	path = name;
-	ptr = strchr(name, '/');
-	if (!ptr) {
-		snprintf(pathbuf, sizeof(pathbuf), "%s/%s",
-			NETNS_RUN_DIR, name );
-		path = pathbuf;
-	}
-	return open(path, O_RDONLY);
-}
-
 static int netns_list(int argc, char **argv)
 {
 	struct dirent *entry;
diff --git a/lib/namespace.c b/lib/namespace.c
index 1554ce0..65c1e3d 100644
--- a/lib/namespace.c
+++ b/lib/namespace.c
@@ -84,3 +84,18 @@ int netns_switch(char *name)
 	bind_etc(name);
 	return 0;
 }
+
+int netns_get_fd(const char *name)
+{
+	char pathbuf[MAXPATHLEN];
+	const char *path, *ptr;
+
+	path = name;
+	ptr = strchr(name, '/');
+	if (!ptr) {
+		snprintf(pathbuf, sizeof(pathbuf), "%s/%s",
+			NETNS_RUN_DIR, name );
+		path = pathbuf;
+	}
+	return open(path, O_RDONLY);
+}
-- 
2.1.3
