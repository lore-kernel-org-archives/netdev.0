From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip netns: Identify netns for the current process
Date: Fri,  7 Nov 2014 18:25:30 +0200
Message-ID: <1415377530-25568-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:57656 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaKGQer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 11:34:47 -0500
Received: by mail-wi0-f173.google.com with SMTP id n3so5103355wiv.12
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 08:34:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As 'ip' util will share the same netns from the caller
process then we can just look at /proc/self/.. to show
the netns of the current process by:

    ip netns id

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipnetns.c        | 22 ++++++++++------------
 man/man8/ip-netns.8 |  7 ++++---
 2 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 90a496f..1c8aa02 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -59,7 +59,7 @@ static int usage(void)
 	fprintf(stderr, "Usage: ip netns list\n");
 	fprintf(stderr, "       ip netns add NAME\n");
 	fprintf(stderr, "       ip netns delete NAME\n");
-	fprintf(stderr, "       ip netns identify PID\n");
+	fprintf(stderr, "       ip netns identify [PID]\n");
 	fprintf(stderr, "       ip netns pids NAME\n");
 	fprintf(stderr, "       ip netns exec NAME cmd ...\n");
 	fprintf(stderr, "       ip netns monitor\n");
@@ -299,19 +299,17 @@ static int netns_identify(int argc, char **argv)
 	struct dirent *entry;
 
 	if (argc < 1) {
-		fprintf(stderr, "No pid specified\n");
-		return -1;
-	}
-	if (argc > 1) {
+		pidstr = "self";
+	} else if (argc > 1) {
 		fprintf(stderr, "extra arguments specified\n");
 		return -1;
-	}
-	pidstr = argv[0];
-
-	if (!is_pid(pidstr)) {
-		fprintf(stderr, "Specified string '%s' is not a pid\n",
-			pidstr);
-		return -1;
+	} else {
+		pidstr = argv[0];
+		if (!is_pid(pidstr)) {
+			fprintf(stderr, "Specified string '%s' is not a pid\n",
+					pidstr);
+			return -1;
+		}
 	}
 
 	snprintf(net_path, sizeof(net_path), "/proc/%s/ns/net", pidstr);
diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index 6aa6e93..74343ed 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -21,7 +21,7 @@ ip-netns \- process network namespace management
 
 .ti -8
 .BR "ip netns identify"
-.I PID
+.RI "[ " PID " ]"
 
 .ti -8
 .BR "ip netns pids"
@@ -85,10 +85,11 @@ persists until it has no more users.  ip netns delete may fail if
 the mount point is in use in another mount namespace.
 
 .TP
-.B ip netns identify PID - Report network namespaces names for process
+.B ip netns identify [PID] - Report network namespaces names for process
 .sp
 This command walks through /var/run/netns and finds all the network
-namespace names for network namespace of the specified process.
+namespace names for network namespace of the specified process, if PID is
+not specified then the current process will be used.
 
 .TP
 .B ip netns pids NAME - Report processes in the named network namespace
-- 
2.1.3
