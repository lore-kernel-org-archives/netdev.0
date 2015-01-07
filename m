From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 2/3] ip netns: Allow exec on each netns
Date: Wed,  7 Jan 2015 13:04:21 +0200
Message-ID: <1420628662-9930-3-git-send-email-vadim4j@gmail.com>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:42799 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbbAGLOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 06:14:50 -0500
Received: by mail-lb0-f169.google.com with SMTP id p9so888807lbv.0
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 03:14:48 -0800 (PST)
In-Reply-To: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

This change allows to exec some cmd on each
netns (except default) by specifying 'all' as netns name:

    # ip netns exec all ip link

Each command executes synchronously.

Exit status is not considered, so there might be a case
that some CMD can fail on some netns but success on the other.

EXAMPLES:

1) Show link info on all netns:

$ ip netns exec all ip link

netns: test_net
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
4: tap0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 500
    link/ether 1a:19:6f:25:eb:85 brd ff:ff:ff:ff:ff:ff

netns: home0
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
4: tap0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 500
    link/ether ea:1a:59:40:d3:29 brd ff:ff:ff:ff:ff:ff

netns: lan0
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
4: tap0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 500
    link/ether ce:49:d5:46:81:ea brd ff:ff:ff:ff:ff:ff

2) Set UP tap0 device for the all netns:

$ ip netns exec all ip link set dev tap0 up

netns: test_net

netns: home0

netns: lan0

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipnetns.c        | 72 ++++++++++++++++++++++++++++++++---------------------
 man/man8/ip-netns.8 | 14 +++++++++--
 2 files changed, 55 insertions(+), 31 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 519d518..b5a6f57 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -26,7 +26,7 @@ static int usage(void)
 	fprintf(stderr, "       ip netns delete NAME\n");
 	fprintf(stderr, "       ip netns identify [PID]\n");
 	fprintf(stderr, "       ip netns pids NAME\n");
-	fprintf(stderr, "       ip netns exec NAME cmd ...\n");
+	fprintf(stderr, "       ip netns exec { NAME | all } cmd ...\n");
 	fprintf(stderr, "       ip netns monitor\n");
 	exit(-1);
 }
@@ -66,29 +66,10 @@ static int netns_list(int argc, char **argv)
 	return 0;
 }
 
-static int netns_exec(int argc, char **argv)
+static int cmd_exec(const char *cmd, char **argv, bool do_fork)
 {
-	/* Setup the proper environment for apps that are not netns
-	 * aware, and execute a program in that environment.
-	 */
-	const char *cmd;
-
-	if (argc < 1) {
-		fprintf(stderr, "No netns name specified\n");
-		return -1;
-	}
-	if (argc < 2) {
-		fprintf(stderr, "No command specified\n");
-		return -1;
-	}
-	cmd = argv[1];
-
-	if (netns_switch(argv[0]))
-		return -1;
-
 	fflush(stdout);
-
-	if (batch_mode) {
+	if (do_fork) {
 		int status;
 		pid_t pid;
 
@@ -106,23 +87,56 @@ static int netns_exec(int argc, char **argv)
 			}
 
 			if (WIFEXITED(status)) {
-				/* ip must return the status of the child,
-				 * but do_cmd() will add a minus to this,
-				 * so let's add another one here to cancel it.
-				 */
-				return -WEXITSTATUS(status);
+				return WEXITSTATUS(status);
 			}
 
 			exit(1);
 		}
 	}
 
-	if (execvp(cmd, argv + 1)  < 0)
+	if (execvp(cmd, argv)  < 0)
 		fprintf(stderr, "exec of \"%s\" failed: %s\n",
-			cmd, strerror(errno));
+				cmd, strerror(errno));
 	_exit(1);
 }
 
+static int on_netns_exec(char *nsname, void *arg)
+{
+	char **argv = arg;
+	cmd_exec(argv[1], argv + 1, 1);
+	return 0;
+}
+
+static int netns_exec(int argc, char **argv)
+{
+	/* Setup the proper environment for apps that are not netns
+	 * aware, and execute a program in that environment.
+	 */
+	const char *cmd;
+
+	if (argc < 1) {
+		fprintf(stderr, "No netns name specified\n");
+		return -1;
+	}
+	if (argc < 2) {
+		fprintf(stderr, "No command specified\n");
+		return -1;
+	}
+	cmd = argv[1];
+
+	if (strcmp(argv[0], "all") == 0)
+		return do_each_netns(on_netns_exec, argv, 1);
+
+	if (netns_switch(argv[0]))
+		return -1;
+
+	/* ip must return the status of the child,
+	 * but do_cmd() will add a minus to this,
+	 * so let's add another one here to cancel it.
+	 */
+	return -cmd_exec(cmd, argv + 1, batch_mode);
+}
+
 static int is_pid(const char *str)
 {
 	int ch;
diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index 74343ed..70ea4f0 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -29,7 +29,7 @@ ip-netns \- process network namespace management
 
 .ti -8
 .BR "ip netns exec "
-.I NETNSNAME command ...
+.RI "{ " NETNSNAME " | " all " } " command ...
 
 .ti -8
 .BR "ip netns monitor"
@@ -98,7 +98,7 @@ This command walks through proc and finds all of the process who have
 the named network namespace as their primary network namespace.
 
 .TP
-.B ip netns exec NAME cmd ... - Run cmd in the named network namespace
+.B ip netns exec { NAME | all } cmd ... - Run cmd in the named network namespace
 .sp
 This command allows applications that are network namespace unaware
 to be run in something other than the default network namespace with
@@ -107,6 +107,16 @@ in the customary global locations.  A network namespace and bind mounts
 are used to move files from their network namespace specific location
 to their default locations without affecting other processes.
 
+If
+.B all
+was specified then
+.B cmd
+will be executed synchronously on the each named network namespace even if
+.B cmd
+fails on some of them. Network namespace name is printed on each
+.B cmd
+executing.
+
 .TP
 .B ip netns monitor - Report as network namespace names are added and deleted
 .sp
-- 
2.1.3
