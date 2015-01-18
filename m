From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2 3/3] ip netns: Delete all netns
Date: Sun, 18 Jan 2015 16:10:19 +0200
Message-ID: <1421590219-19365-4-git-send-email-vadim4j@gmail.com>
References: <1421590219-19365-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:59801 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbbAROU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 09:20:58 -0500
Received: by mail-wi0-f180.google.com with SMTP id bs8so11679325wib.1
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 06:20:57 -0800 (PST)
In-Reply-To: <1421590219-19365-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Allow delete all namespace names by:

    $ ip -all netns del

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipnetns.c        | 26 ++++++++++++++++----------
 man/man8/ip-netns.8 | 12 ++++++++++--
 2 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 59a9321..e4038ea 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -23,7 +23,7 @@ static int usage(void)
 {
 	fprintf(stderr, "Usage: ip netns list\n");
 	fprintf(stderr, "       ip netns add NAME\n");
-	fprintf(stderr, "       ip netns delete NAME\n");
+	fprintf(stderr, "       ip [-all] netns delete [NAME]\n");
 	fprintf(stderr, "       ip netns identify [PID]\n");
 	fprintf(stderr, "       ip netns pids NAME\n");
 	fprintf(stderr, "       ip [-all] netns exec [NAME] cmd ...\n");
@@ -259,18 +259,11 @@ static int netns_identify(int argc, char **argv)
 
 }
 
-static int netns_delete(int argc, char **argv)
+static int on_netns_del(char *nsname, void *arg)
 {
-	const char *name;
 	char netns_path[MAXPATHLEN];
 
-	if (argc < 1) {
-		fprintf(stderr, "No netns name specified\n");
-		return -1;
-	}
-
-	name = argv[0];
-	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
+	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, nsname);
 	umount2(netns_path, MNT_DETACH);
 	if (unlink(netns_path) < 0) {
 		fprintf(stderr, "Cannot remove namespace file \"%s\": %s\n",
@@ -280,6 +273,19 @@ static int netns_delete(int argc, char **argv)
 	return 0;
 }
 
+static int netns_delete(int argc, char **argv)
+{
+	if (argc < 1 && !do_all) {
+		fprintf(stderr, "No netns name specified\n");
+		return -1;
+	}
+
+	if (do_all)
+		return netns_foreach(on_netns_del, NULL);
+
+	return on_netns_del(argv[0], NULL);
+}
+
 static int create_netns_dir(void)
 {
 	/* Create the base netns directory if it doesn't exist */
diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index 7b9571e..8e6999c 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -16,10 +16,14 @@ ip-netns \- process network namespace management
 .BR "ip netns" " { " list " } "
 
 .ti -8
-.BR "ip netns" " { " add " | " delete " } "
+.B ip netns add
 .I NETNSNAME
 
 .ti -8
+.B ip [-all] netns del
+.RI "[ " NETNSNAME " ]"
+
+.ti -8
 .BR "ip netns identify"
 .RI "[ " PID " ]"
 
@@ -76,7 +80,7 @@ If NAME is available in /var/run/netns/ this command creates a new
 network namespace and assigns NAME.
 
 .TP
-.B ip netns delete NAME - delete the name of a network namespace
+.B ip [-all] netns delete [ NAME ] - delete the name of a network namespace(s)
 .sp
 If NAME is present in /var/run/netns it is umounted and the mount
 point is removed.  If this is the last user of the network namespace the
@@ -84,6 +88,10 @@ network namespace will be freed, otherwise the network namespace
 persists until it has no more users.  ip netns delete may fail if
 the mount point is in use in another mount namespace.
 
+If
+.B -all
+option was specified then all the network namespace names will be removed.
+
 .TP
 .B ip netns identify [PID] - Report network namespaces names for process
 .sp
-- 
2.1.3
