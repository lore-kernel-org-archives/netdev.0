From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH iproute2] ss: display interface name as zone index when needed
Date: Mon, 10 Feb 2014 09:20:33 +0100
Message-ID: <1392020433-27554-1-git-send-email-fx.lebail@yahoo.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp04.smtpout.orange.fr ([80.12.242.126]:60420 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbaBJIr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 03:47:59 -0500
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
 misc/ss.c |   29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 764ffe2..8799cfc 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -41,6 +41,8 @@
 #include <linux/packet_diag.h>
 #include <linux/netlink_diag.h>
 
+extern char *if_indextoname(unsigned int ifindex, char *ifname);
+
 int resolve_hosts = 0;
 int resolve_services = 1;
 int preferred_family = AF_UNSPEC;
@@ -640,7 +642,7 @@ static const char *resolve_service(int port)
 	return buf;
 }
 
-static void formatted_print(const inet_prefix *a, int port)
+static void formatted_print(const inet_prefix *a, int port, unsigned int ifindex)
 {
 	char buf[1024];
 	const char *ap = buf;
@@ -663,7 +665,18 @@ static void formatted_print(const inet_prefix *a, int port)
 		else
 			est_len = addr_width + ((est_len-addr_width+3)/4)*4;
 	}
-	printf("%*s:%-*s ", est_len, ap, serv_width, resolve_service(port));
+	if (ifindex) {
+		char ifname[IFNAMSIZ];
+		int len;
+		const char *ind = if_indextoname(ifindex, ifname);
+
+		if (!ind)
+			snprintf(ifname, sizeof(ifname), "%u", ifindex);
+		len = strlen(ifname) + 1;  /* +1 for percent char */
+		printf("%*s%%%s:%-*s ", est_len - len, ap, ifname, serv_width,
+		       resolve_service(port));
+	} else
+		printf("%*s:%-*s ", est_len, ap, serv_width, resolve_service(port));
 }
 
 struct aafilter
@@ -1254,8 +1267,8 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 
 	printf("%-6d %-6d ", s.rq, s.wq);
 
-	formatted_print(&s.local, s.lport);
-	formatted_print(&s.remote, s.rport);
+	formatted_print(&s.local, s.lport, 0);
+	formatted_print(&s.remote, s.rport, 0);
 
 	if (show_options) {
 		if (s.timer) {
@@ -1493,8 +1506,8 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 
 	printf("%-6d %-6d ", r->idiag_rqueue, r->idiag_wqueue);
 
-	formatted_print(&s.local, s.lport);
-	formatted_print(&s.remote, s.rport);
+	formatted_print(&s.local, s.lport, r->id.idiag_if);
+	formatted_print(&s.remote, s.rport, 0);
 
 	if (show_options) {
 		if (r->idiag_timer) {
@@ -1992,8 +2005,8 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 
 	printf("%-6d %-6d ", s.rq, s.wq);
 
-	formatted_print(&s.local, s.lport);
-	formatted_print(&s.remote, s.rport);
+	formatted_print(&s.local, s.lport, 0);
+	formatted_print(&s.remote, s.rport, 0);
 
 	if (show_users) {
 		char ubuf[4096];
