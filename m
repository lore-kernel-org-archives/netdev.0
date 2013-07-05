From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] ipbatch: fix use of 'ip netns exec'
Date: Fri,  5 Jul 2013 18:05:45 +0200
Message-ID: <1373040345-11116-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, junwei.zhang@6wind.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38922 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757360Ab3GEQGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 12:06:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: JunweiZhang <junwei.zhang@6wind.com>

execvp() does not return when the command succeed, hence all commands in the
batch file after the line 'ip netns exec' are not executed.

Let's fork before calling execvp().

Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipnetns.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index fa2b681..a4a68a7 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -138,6 +138,7 @@ static int netns_exec(int argc, char **argv)
 	const char *name, *cmd;
 	char net_path[MAXPATHLEN];
 	int netns;
+	int pid, status;
 
 	if (argc < 1) {
 		fprintf(stderr, "No netns name specified\n");
@@ -185,10 +186,17 @@ static int netns_exec(int argc, char **argv)
 	/* Setup bind mounts for config files in /etc */
 	bind_etc(name);
 
-	if (execvp(cmd, argv + 1)  < 0)
+	pid = fork();
+	if (pid < 0)
+		return EXIT_FAILURE;
+	else if (pid > 0)
+		waitpid(pid, &status, 0);
+	else if (execvp(cmd, argv + 1)  < 0) {
 		fprintf(stderr, "exec of \"%s\" failed: %s\n",
 			cmd, strerror(errno));
-	return EXIT_FAILURE;
+		return EXIT_FAILURE;
+	}
+	return WIFEXITED(status) ? EXIT_SUCCESS : EXIT_FAILURE;
 }
 
 static int is_pid(const char *str)
-- 
1.8.2.1
