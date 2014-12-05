From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 REGRESSIONS v3] ss: Fix layout/output issues introduced by regression
Date: Fri,  5 Dec 2014 19:19:11 +0200
Message-ID: <1417799951-25143-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:62955 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbaLER26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 12:28:58 -0500
Received: by mail-lb0-f173.google.com with SMTP id z12so908023lbi.32
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 09:28:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following issues which was introduced by me in commits:

    #1 (2dc854854b7f1b) ss: Fixed broken output for Netlink 'Peer Address:Port' column
    ISSUE: Broken layout when all sockets are printed out

    #2 (eef43b5052afb7) ss: Identify more netlink protocol names
    ISSUE: Protocol id is not printed if 'numbers only' output was specified (-n)

Also aligned the width of the local/peer ports to be more wider.

I tested with a lot of option combinations (I may miss some test cases),
but layout seems to me better than the previous released version of iproute2/ss.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 28 +++++++++-------------------
 1 file changed, 9 insertions(+), 19 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index a99294d..c9733a7 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -101,8 +101,6 @@ int state_width;
 int addrp_width;
 int addr_width;
 int serv_width;
-int paddr_width;
-int pserv_width;
 int screen_width;
 
 static const char *TCP_PROTO = "tcp";
@@ -2912,10 +2910,11 @@ static void netlink_show_one(struct filter *f,
 		printf("%-*s ", state_width, "UNCONN");
 	printf("%-6d %-6d ", rq, wq);
 
-	if (resolve_services)
-	{
+	if (resolve_services) {
 		printf("%*s:", addr_width, nl_proto_n2a(prot, prot_name,
 					sizeof(prot_name)));
+	} else {
+		printf("%*d:", addr_width, prot);
 	}
 
 	if (pid == -1) {
@@ -2947,10 +2946,10 @@ static void netlink_show_one(struct filter *f,
 
 	if (state == NETLINK_CONNECTED) {
 		printf("%*d:%-*d",
-		       paddr_width, dst_group, pserv_width, dst_pid);
+		       addr_width, dst_group, serv_width, dst_pid);
 	} else {
 		printf("%*s*%-*s",
-		       paddr_width, "", pserv_width, "");
+		       addr_width, "", serv_width, "");
 	}
 
 	char *pid_context = NULL;
@@ -3684,22 +3683,13 @@ int main(int argc, char *argv[])
 		printf("%-*s ", state_width, "State");
 	printf("%-6s %-6s ", "Recv-Q", "Send-Q");
 
-	paddr_width = addr_width;
-	pserv_width = serv_width;
-
-	/* Netlink service column can be resolved as process name/pid thus it
-	 * can be much wider than address column which is just a
-	 * protocol name/id.
-	 */
-	if (current_filter.dbs & (1<<NETLINK_DB)) {
-		serv_width = addr_width - 10;
-		paddr_width = 13;
-		pserv_width = 13;
-	}
+	/* Make enough space for the local/remote port field */
+	addr_width -= 13;
+	serv_width += 13;
 
 	printf("%*s:%-*s %*s:%-*s\n",
 	       addr_width, "Local Address", serv_width, "Port",
-	       paddr_width, "Peer Address", pserv_width, "Port");
+	       addr_width, "Peer Address", serv_width, "Port");
 
 	fflush(stdout);
 
-- 
2.1.3
