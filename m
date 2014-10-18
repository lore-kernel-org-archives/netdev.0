From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Fixed broken output for Netlink 'Peer Address:Port' column
Date: Sat, 18 Oct 2014 20:46:29 +0300
Message-ID: <1413654389-8596-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:56896 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbaJRRzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 13:55:25 -0400
Received: by mail-la0-f46.google.com with SMTP id gi9so2139328lab.19
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 10:55:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When output the netlink sockets:

    ss -A netlink state close

the layout is a little broken with a shifted 'Peer Address:Port'
stars and empty new lines. Fixed by making the port field to be
wider for 'Local Address:Port' column.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 2420b51..0f89588 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -88,6 +88,8 @@ int state_width;
 int addrp_width;
 int addr_width;
 int serv_width;
+int paddr_width;
+int pserv_width;
 int screen_width;
 
 static const char *TCP_PROTO = "tcp";
@@ -3020,10 +3022,10 @@ static void netlink_show_one(struct filter *f,
 
 	if (state == NETLINK_CONNECTED) {
 		printf("%*d:%-*d",
-		       addr_width, dst_group, serv_width, dst_pid);
+		       paddr_width, dst_group, pserv_width, dst_pid);
 	} else {
 		printf("%*s*%-*s",
-		       addr_width, "", serv_width, "");
+		       paddr_width, "", pserv_width, "");
 	}
 
 	char *pid_context = NULL;
@@ -3769,9 +3771,22 @@ int main(int argc, char *argv[])
 		printf("%-*s ", state_width, "State");
 	printf("%-6s %-6s ", "Recv-Q", "Send-Q");
 
+	paddr_width = addr_width;
+	pserv_width = serv_width;
+
+	/* Netlink service column can be resolved as process name/pid thus it
+	 * can be much wider than address column which is just a
+	 * protocol name/id.
+	 */
+	if (current_filter.dbs & (1<<NETLINK_DB)) {
+		serv_width = addr_width - 10;
+		paddr_width = 13;
+		pserv_width = 13;
+	}
+
 	printf("%*s:%-*s %*s:%-*s\n",
 	       addr_width, "Local Address", serv_width, "Port",
-	       addr_width, "Peer Address", serv_width, "Port");
+	       paddr_width, "Peer Address", pserv_width, "Port");
 
 	fflush(stdout);
 
-- 
2.1.0
