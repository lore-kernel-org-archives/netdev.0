From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2 2/3] ip netns: Allow exec on each netns
Date: Sun, 18 Jan 2015 16:10:18 +0200
Message-ID: <1421590219-19365-3-git-send-email-vadim4j@gmail.com>
References: <1421590219-19365-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:58316 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbbARO0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 09:26:37 -0500
Received: by mail-we0-f170.google.com with SMTP id x3so875749wes.1
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 06:26:36 -0800 (PST)
In-Reply-To: <1421590219-19365-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

This change allows to exec some cmd on each
named netns (except default) by specifying '-all' option:

    # ip -all netns exec ip link

Each command executes synchronously.

Exit status is not considered, so there might be a case
that some CMD can fail on some netns but success on the other.

EXAMPLES:

1) Show link info on all netns:

$ ip -all netns exec ip link

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

$ ip -all netns exec ip link set dev tap0 up

netns: test_net

netns: home0

netns: lan0

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/utils.h     |  1 +
 ip/ip.c             |  5 +++-
 ip/ipnetns.c        | 72 ++++++++++++++++++++++++++++++++---------------------
 man/man8/ip-netns.8 | 16 +++++++++---
 man/man8/ip.8       |  7 +++++-
 5 files changed, 67 insertions(+), 34 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index a8817d3..3da2283 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -24,6 +24,7 @@ extern int timestamp_short;
 extern char * _SL_;
 extern int max_flush_loops;
 extern int batch_mode;
+extern bool do_all;
 
 #ifndef IPPROTO_ESP
 #define IPPROTO_ESP	50
diff --git a/ip/ip.c b/ip/ip.c
index 850a001..da16b15 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -36,6 +36,7 @@ char * _SL_ = NULL;
 int force = 0;
 int max_flush_loops = 10;
 int batch_mode = 0;
+bool do_all = false;
 
 struct rtnl_handle rth = { .fd = -1 };
 
@@ -55,7 +56,7 @@ static void usage(void)
 "                    -4 | -6 | -I | -D | -B | -0 |\n"
 "                    -l[oops] { maximum-addr-flush-attempts } |\n"
 "                    -o[neline] | -t[imestamp] | -ts[hort] | -b[atch] [filename] |\n"
-"                    -rc[vbuf] [size] | -n[etns] name }\n");
+"                    -rc[vbuf] [size] | -n[etns] name | -a[ll] }\n");
 	exit(-1);
 }
 
@@ -270,6 +271,8 @@ int main(int argc, char **argv)
 			NEXT_ARG();
 			if (netns_switch(argv[1]))
 				exit(-1);
+		} else if (matches(opt, "-all") == 0) {
+			do_all = true;
 		} else {
 			fprintf(stderr, "Option \"%s\" is unknown, try \"ip -help\".\n", opt);
 			exit(-1);
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 123318e..59a9321 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -26,7 +26,7 @@ static int usage(void)
 	fprintf(stderr, "       ip netns delete NAME\n");
 	fprintf(stderr, "       ip netns identify [PID]\n");
 	fprintf(stderr, "       ip netns pids NAME\n");
-	fprintf(stderr, "       ip netns exec NAME cmd ...\n");
+	fprintf(stderr, "       ip [-all] netns exec [NAME] cmd ...\n");
 	fprintf(stderr, "       ip netns monitor\n");
 	exit(-1);
 }
@@ -51,29 +51,10 @@ static int netns_list(int argc, char **argv)
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
 
@@ -91,23 +72,56 @@ static int netns_exec(int argc, char **argv)
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
+	cmd_exec(argv[1], argv + 1, true);
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
+	if (argc < 1 && !do_all) {
+		fprintf(stderr, "No netns name specified\n");
+		return -1;
+	}
+	if ((argc < 2 && !do_all) || (argc < 1 && do_all)) {
+		fprintf(stderr, "No command specified\n");
+		return -1;
+	}
+
+	if (do_all)
+		return do_each_netns(on_netns_exec, --argv, 1);
+
+	if (netns_switch(argv[0]))
+		return -1;
+
+	/* ip must return the status of the child,
+	 * but do_cmd() will add a minus to this,
+	 * so let's add another one here to cancel it.
+	 */
+	cmd = argv[1];
+	return -cmd_exec(cmd, argv + 1, !!batch_mode);
+}
+
 static int is_pid(const char *str)
 {
 	int ch;
diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index 74343ed..7b9571e 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -28,8 +28,8 @@ ip-netns \- process network namespace management
 .I NETNSNAME
 
 .ti -8
-.BR "ip netns exec "
-.I NETNSNAME command ...
+.BR "ip [-all] netns exec "
+.RI "[ " NETNSNAME " ] " command ...
 
 .ti -8
 .BR "ip netns monitor"
@@ -98,7 +98,7 @@ This command walks through proc and finds all of the process who have
 the named network namespace as their primary network namespace.
 
 .TP
-.B ip netns exec NAME cmd ... - Run cmd in the named network namespace
+.B ip [-all] netns exec [ NAME ] cmd ... - Run cmd in the named network namespace
 .sp
 This command allows applications that are network namespace unaware
 to be run in something other than the default network namespace with
@@ -107,6 +107,16 @@ in the customary global locations.  A network namespace and bind mounts
 are used to move files from their network namespace specific location
 to their default locations without affecting other processes.
 
+If
+.B -all
+option was specified then
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
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 0bae59e..016e8c6 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -32,7 +32,8 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 \fB\-f\fR[\fIamily\fR] {
 .BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
 \fB\-o\fR[\fIneline\fR] |
-\fB\-n\fR[\fIetns\fR] name }
+\fB\-n\fR[\fIetns\fR] name |
+\fB\-a\fR[\fIll\fR] }
 
 
 .SH OPTIONS
@@ -155,6 +156,10 @@ to
 .RI "-n[etns] " NETNS " [ " OPTIONS " ] " OBJECT " { " COMMAND " | "
 .BR help " }"
 
+.TP
+.BR "\-a" , " \-all"
+executes specified command over all objects, it depends if command supports this option.
+
 .SH IP - COMMAND SYNTAX
 
 .SS
-- 
2.1.3
