From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH] ip netns: Create /var/run/netns dir when do 'ip netns monitor'
Date: Sun, 31 Aug 2014 22:45:29 +0300
Message-ID: <1409514329-11352-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:50676 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbaHaTxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2014 15:53:19 -0400
Received: by mail-lb0-f180.google.com with SMTP id w7so4838312lbi.25
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2014 12:53:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netns monitor fails when there is no /var/run/netns dir
which might be created later while monitoring.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipnetns.c | 28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 7f82908..90a496f 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -383,6 +383,20 @@ static int netns_delete(int argc, char **argv)
 	return 0;
 }
 
+static int create_netns_dir(void)
+{
+	/* Create the base netns directory if it doesn't exist */
+	if (mkdir(NETNS_RUN_DIR, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH)) {
+		if (errno != EEXIST) {
+			fprintf(stderr, "mkdir %s failed: %s\n",
+				NETNS_RUN_DIR, strerror(errno));
+			return -1;
+		}
+	}
+
+	return 0;
+}
+
 static int netns_add(int argc, char **argv)
 {
 	/* This function creates a new network namespace and
@@ -406,14 +420,8 @@ static int netns_add(int argc, char **argv)
 
 	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
 
-	/* Create the base netns directory if it doesn't exist */
-	if (mkdir(NETNS_RUN_DIR, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH)) {
-		if (errno != EEXIST) {
-			fprintf(stderr, "mkdir %s failed: %s\n",
-				NETNS_RUN_DIR, strerror(errno));
-			return -1;
-		}
-	}
+	if (create_netns_dir())
+		return -1;
 
 	/* Make it possible for network namespace mounts to propagate between
 	 * mount namespaces.  This makes it likely that a unmounting a network
@@ -476,6 +484,10 @@ static int netns_monitor(int argc, char **argv)
 			strerror(errno));
 		return -1;
 	}
+
+	if (create_netns_dir())
+		return -1;
+
 	if (inotify_add_watch(fd, NETNS_RUN_DIR, IN_CREATE | IN_DELETE) < 0) {
 		fprintf(stderr, "inotify_add_watch failed: %s\n",
 			strerror(errno));
-- 
2.1.0
