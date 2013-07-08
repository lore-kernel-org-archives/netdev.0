From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 v2] ipbatch: fix use of 'ip netns exec'
Date: Mon,  8 Jul 2013 11:44:20 +0200
Message-ID: <1373276660-14088-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20130705141639.56b47e7e@samsung-9>
Cc: netdev@vger.kernel.org, junwei.zhang@6wind.com,
	bhutchings@solarflare.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:45303 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab3GHJoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 05:44:25 -0400
In-Reply-To: <20130705141639.56b47e7e@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: JunweiZhang <junwei.zhang@6wind.com>

execvp() does not return when the command succeed, hence all commands in the
batch file after the line 'ip netns exec' are not executed.

Let's fork before calling execvp().

Example:
$ cat test.batch
netns add netns1
netns exec netns1 ip l
netns
$ ip -b test.batch
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: sit0: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT
    link/sit 0.0.0.0 brd 0.0.0.0

All command after 'netns exec' are never executed.

With the patch:
$ ip -b test.batch
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: sit0: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT
    link/sit 0.0.0.0 brd 0.0.0.0
netns1

Now, existing netns are displayed.

Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: keep exit status of the child
    add an example in the commit log

 ip/ipnetns.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index fa2b681..9f401ca 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -138,6 +138,7 @@ static int netns_exec(int argc, char **argv)
 	const char *name, *cmd;
 	char net_path[MAXPATHLEN];
 	int netns;
+	int pid, status;
 
 	if (argc < 1) {
 		fprintf(stderr, "No netns name specified\n");
@@ -185,10 +186,23 @@ static int netns_exec(int argc, char **argv)
 	/* Setup bind mounts for config files in /etc */
 	bind_etc(name);
 
-	if (execvp(cmd, argv + 1)  < 0)
-		fprintf(stderr, "exec of \"%s\" failed: %s\n",
-			cmd, strerror(errno));
-	return EXIT_FAILURE;
+	pid = fork();
+	if (pid < 0)
+		return EXIT_FAILURE;
+	else if (pid > 0)
+		waitpid(pid, &status, 0);
+	else {
+		/* Child */
+		if (execvp(cmd, argv + 1)  < 0)
+			fprintf(stderr, "exec of \"%s\" failed: %s\n",
+				cmd, strerror(errno));
+		return EXIT_FAILURE;
+	}
+	/* ip must returns the status of the child, but do_cmd() will add a
+	 * minus to this returned value, so let's add another one here to
+	 * cancel it.
+	 */
+	return -WEXITSTATUS(status);
 }
 
 static int is_pid(const char *str)
-- 
1.8.2.1
