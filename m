From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH iproute2 v2] ss: display interface name as zone index when needed
Date: Tue, 11 Feb 2014 10:06:23 +0100
Message-ID: <1392109583-25025-1-git-send-email-fx.lebail@yahoo.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Bernd Eckenfels <ecki@lina.inka.de>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp04.smtpout.orange.fr ([80.12.242.126]:51414 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbaBKJfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 04:35:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change enable the ss command to display the interface name as zone index
for local addresses when needed.

For this enhanced display *_diag stuff is needed.

It is based on a first version by Bernd Eckenfels.

example:
Netid  State   Recv-Q Send-Q                 Local Address:Port    Peer Address:Port
udp    UNCONN  0      0      fe80::20c:29ff:fe1f:7406%eth1:9999              :::*
udp    UNCONN  0      0                                 :::domain            :::*
tcp    LISTEN  0      3                                 :::domain            :::*
tcp    LISTEN  0      5      fe80::20c:29ff:fe1f:7410%eth2:99                :::*

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
v2: Consideration of Stephen's comment (thanks!):
    Use ll_index_to_name() instead of if_indextoname(). 

 misc/ss.c |   23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 37dcc11..ce6a0a8 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -640,7 +640,7 @@ static const char *resolve_service(int port)
 	return buf;
 }
 
-static void formatted_print(const inet_prefix *a, int port)
+static void formatted_print(const inet_prefix *a, int port, unsigned int ifindex)
 {
 	char buf[1024];
 	const char *ap = buf;
@@ -663,7 +663,14 @@ static void formatted_print(const inet_prefix *a, int port)
 		else
 			est_len = addr_width + ((est_len-addr_width+3)/4)*4;
 	}
-	printf("%*s:%-*s ", est_len, ap, serv_width, resolve_service(port));
+	if (ifindex) {
+		const char *ifname = ll_index_to_name(ifindex);
+		const int len = strlen(ifname) + 1;  /* +1 for percent char */
+
+		printf("%*s%%%s:%-*s ", est_len - len, ap, ifname, serv_width,
+		       resolve_service(port));
+	} else
+		printf("%*s:%-*s ", est_len, ap, serv_width, resolve_service(port));
 }
 
 struct aafilter
@@ -1254,8 +1261,8 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 
 	printf("%-6d %-6d ", s.rq, s.wq);
 
-	formatted_print(&s.local, s.lport);
-	formatted_print(&s.remote, s.rport);
+	formatted_print(&s.local, s.lport, 0);
+	formatted_print(&s.remote, s.rport, 0);
 
 	if (show_options) {
 		if (s.timer) {
@@ -1507,8 +1514,8 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 
 	printf("%-6d %-6d ", r->idiag_rqueue, r->idiag_wqueue);
 
-	formatted_print(&s.local, s.lport);
-	formatted_print(&s.remote, s.rport);
+	formatted_print(&s.local, s.lport, r->id.idiag_if);
+	formatted_print(&s.remote, s.rport, 0);
 
 	if (show_options) {
 		if (r->idiag_timer) {
@@ -2006,8 +2013,8 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 
 	printf("%-6d %-6d ", s.rq, s.wq);
 
-	formatted_print(&s.local, s.lport);
-	formatted_print(&s.remote, s.rport);
+	formatted_print(&s.local, s.lport, 0);
+	formatted_print(&s.remote, s.rport, 0);
 
 	if (show_users) {
 		char ubuf[4096];
