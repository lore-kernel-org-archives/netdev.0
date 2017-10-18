From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ss: Distinguish between IPv4 and IPv6 wildcard sockets
Date: Wed, 18 Oct 2017 19:58:13 +0200
Message-ID: <20171018175813.5387-1-phil@nwl.cc>
References: <20171016194958.669625db@xeon-e3>
Cc: netdev@vger.kernel.org, Humberto Alves <hjalves@live.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47576 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750914AbdJRR61 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 13:58:27 -0400
In-Reply-To: <20171016194958.669625db@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit aba9c23a6e1cb ("ss: enclose IPv6 address in brackets") unified
display of wildcard sockets in IPv4 and IPv6 to print the unspecified
address as '*'. Users then complained that they can't distinguish
between address families anymore, so change this again to what Stephen
Hemminger suggested:

| *:80    << both IPV6 and IPV4
| [::]:80 << IPV6_ONLY
| 0.0.0.0:80  << IPV4_ONLY

Note that on older kernels which don't support INET_DIAG_SKV6ONLY
attribute, pure IPv6 sockets will still show as '*'.

Cc: Humberto Alves <hjalves@live.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 36 +++++++++++++++++-------------------
 1 file changed, 17 insertions(+), 19 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 09bff8a7e2d28..e37aba6022eb4 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1041,7 +1041,8 @@ do_numeric:
 	return buf;
 }
 
-static void inet_addr_print(const inet_prefix *a, int port, unsigned int ifindex)
+static void inet_addr_print(const inet_prefix *a, int port,
+			    unsigned int ifindex, bool v6only)
 {
 	char buf[1024];
 	const char *ap = buf;
@@ -1049,14 +1050,10 @@ static void inet_addr_print(const inet_prefix *a, int port, unsigned int ifindex
 	const char *ifname = NULL;
 
 	if (a->family == AF_INET) {
-		if (a->data[0] == 0) {
-			buf[0] = '*';
-			buf[1] = 0;
-		} else {
-			ap = format_host(AF_INET, 4, a->data);
-		}
+		ap = format_host(AF_INET, 4, a->data);
 	} else {
-		if (!memcmp(a->data, &in6addr_any, sizeof(in6addr_any))) {
+		if (!v6only &&
+		    !memcmp(a->data, &in6addr_any, sizeof(in6addr_any))) {
 			buf[0] = '*';
 			buf[1] = 0;
 		} else {
@@ -1728,12 +1725,12 @@ static void proc_ctx_print(struct sockstat *s)
 	}
 }
 
-static void inet_stats_print(struct sockstat *s)
+static void inet_stats_print(struct sockstat *s, bool v6only)
 {
 	sock_state_print(s);
 
-	inet_addr_print(&s->local, s->lport, s->iface);
-	inet_addr_print(&s->remote, s->rport, 0);
+	inet_addr_print(&s->local, s->lport, s->iface, v6only);
+	inet_addr_print(&s->remote, s->rport, 0, v6only);
 
 	proc_ctx_print(s);
 }
@@ -2065,7 +2062,7 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 	s.rto	    = s.rto != 3 * hz  ? s.rto / hz : 0;
 	s.ss.type   = IPPROTO_TCP;
 
-	inet_stats_print(&s.ss);
+	inet_stats_print(&s.ss, false);
 
 	if (show_options)
 		tcp_timer_print(&s);
@@ -2411,6 +2408,7 @@ static int inet_show_sock(struct nlmsghdr *nlh,
 {
 	struct rtattr *tb[INET_DIAG_MAX+1];
 	struct inet_diag_msg *r = NLMSG_DATA(nlh);
+	unsigned char v6only = 0;
 
 	parse_rtattr(tb, INET_DIAG_MAX, (struct rtattr *)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
@@ -2418,7 +2416,10 @@ static int inet_show_sock(struct nlmsghdr *nlh,
 	if (tb[INET_DIAG_PROTOCOL])
 		s->type = rta_getattr_u8(tb[INET_DIAG_PROTOCOL]);
 
-	inet_stats_print(s);
+	if (s->local.family == AF_INET6 && tb[INET_DIAG_SKV6ONLY])
+		v6only = rta_getattr_u8(tb[INET_DIAG_SKV6ONLY]);
+
+	inet_stats_print(s, v6only);
 
 	if (show_options) {
 		struct tcpstat t = {};
@@ -2434,12 +2435,9 @@ static int inet_show_sock(struct nlmsghdr *nlh,
 
 	if (show_details) {
 		sock_details_print(s);
-		if (s->local.family == AF_INET6 && tb[INET_DIAG_SKV6ONLY]) {
-			unsigned char v6only;
-
-			v6only = rta_getattr_u8(tb[INET_DIAG_SKV6ONLY]);
+		if (s->local.family == AF_INET6 && tb[INET_DIAG_SKV6ONLY])
 			printf(" v6only:%u", v6only);
-		}
+
 		if (tb[INET_DIAG_SHUTDOWN]) {
 			unsigned char mask;
 
@@ -2910,7 +2908,7 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 		opt[0] = 0;
 
 	s.type = dg_proto == UDP_PROTO ? IPPROTO_UDP : 0;
-	inet_stats_print(&s);
+	inet_stats_print(&s, false);
 
 	if (show_details && opt[0])
 		printf(" opt:\"%s\"", opt);
-- 
2.13.1
