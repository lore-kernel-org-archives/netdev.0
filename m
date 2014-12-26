From: Shahar Lev <shahar@stratoscale.com>
Subject: [PATCH] ipnetns: fix exec for netns not in NETNS_RUN_DIR
Date: Fri, 26 Dec 2014 18:27:12 +0200
Message-ID: <1419611232-14206-1-git-send-email-shahar@stratoscale.com>
Cc: netdev@vger.kernel.org, Shahar Lev <shahar@stratoscale.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:34928 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbaLZQ1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 11:27:25 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so14664619wgh.34
        for <netdev@vger.kernel.org>; Fri, 26 Dec 2014 08:27:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enabling "ip netns exec" to be run with a net namespace
specified by a file path rather than a filename under /var/run/nets.

Signed-off-by: Shahar Lev <shahar@stratoscale.com>
---
 ip/ipnetns.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 1c8aa02..5310d0c 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -66,7 +66,7 @@ static int usage(void)
 	exit(-1);
 }
 
-int get_netns_fd(const char *name)
+static int get_netns_fd_flags(const char *name, int flags)
 {
 	char pathbuf[MAXPATHLEN];
 	const char *path, *ptr;
@@ -78,7 +78,12 @@ int get_netns_fd(const char *name)
 			NETNS_RUN_DIR, name );
 		path = pathbuf;
 	}
-	return open(path, O_RDONLY);
+	return open(path, flags);
+}
+
+int get_netns_fd(const char *name)
+{
+	return get_netns_fd_flags(name, O_RDONLY);
 }
 
 static int netns_list(int argc, char **argv)
@@ -135,7 +140,6 @@ static int netns_exec(int argc, char **argv)
 	 * aware, and execute a program in that environment.
 	 */
 	const char *name, *cmd;
-	char net_path[MAXPATHLEN];
 	int netns;
 
 	if (argc < 1) {
@@ -149,8 +153,7 @@ static int netns_exec(int argc, char **argv)
 
 	name = argv[0];
 	cmd = argv[1];
-	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
-	netns = open(net_path, O_RDONLY | O_CLOEXEC);
+	netns = get_netns_fd_flags(name, O_RDONLY | O_CLOEXEC);
 	if (netns < 0) {
 		fprintf(stderr, "Cannot open network namespace \"%s\": %s\n",
 			name, strerror(errno));
-- 
1.8.3.1
