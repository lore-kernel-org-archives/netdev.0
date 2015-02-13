From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 5/7] ss: Unify details info output:ino,uid,sk
Date: Fri, 13 Feb 2015 22:14:02 +0200
Message-ID: <1423858444-10158-6-git-send-email-vadim4j@gmail.com>
References: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:43337 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbbBMUZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 15:25:17 -0500
Received: by labms9 with SMTP id ms9so12754558lab.10
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 12:25:15 -0800 (PST)
In-Reply-To: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 78 ++++++++++++++++++++++++++++-----------------------------------
 1 file changed, 35 insertions(+), 43 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 305ab38..905cec9 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -672,6 +672,11 @@ static inline char *sock_addr_get_str(const inet_prefix *prefix)
     return tmp;
 }
 
+static unsigned long cookie_sk_get(uint32_t *cookie)
+{
+	return (((unsigned long)cookie[1] << 31) << 1) | cookie[0];
+}
+
 static const char *sstate_name[] = {
 	"UNKNOWN",
 	[SS_ESTABLISHED] = "ESTAB",
@@ -775,6 +780,15 @@ static void sock_state_print(struct sockstat *s, const char *sock_name)
 	printf("%-6d %-6d ", s->rq, s->wq);
 }
 
+static void sock_details_print(struct sockstat *s)
+{
+	if (s->uid)
+		printf(" uid:%u", s->uid);
+
+	printf(" ino:%u", s->ino);
+	printf(" sk:%llx", s->sk);
+}
+
 static const char *tmr_name[] = {
 	"off",
 	"on",
@@ -1745,10 +1759,7 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 		tcp_timer_print(&s);
 
 	if (show_details) {
-		if (s.ss.uid)
-			printf(" uid:%u", (unsigned)s.ss.uid);
-		printf(" ino:%u", s.ss.ino);
-		printf(" sk:%llx", s.ss.sk);
+		sock_details_print(&s.ss);
 		if (opt[0])
 			printf(" opt:\"%s\"", opt);
 	}
@@ -1949,15 +1960,16 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 	parse_rtattr(tb, INET_DIAG_MAX, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
-	s.state = r->idiag_state;
-	s.local.family = s.remote.family = r->idiag_family;
-	s.lport = ntohs(r->id.idiag_sport);
-	s.rport = ntohs(r->id.idiag_dport);
-	s.wq = r->idiag_wqueue;
-	s.rq = r->idiag_rqueue;
-	s.ino = r->idiag_inode;
-	s.uid = r->idiag_uid;
-	s.iface = r->id.idiag_if;
+	s.state		= r->idiag_state;
+	s.local.family  = s.remote.family = r->idiag_family;
+	s.lport		= ntohs(r->id.idiag_sport);
+	s.rport		= ntohs(r->id.idiag_dport);
+	s.wq		= r->idiag_wqueue;
+	s.rq		= r->idiag_rqueue;
+	s.ino		= r->idiag_inode;
+	s.uid		= r->idiag_uid;
+	s.iface		= r->id.idiag_if;
+	s.sk		= cookie_sk_get(&r->id.idiag_cookie[0]);
 
 	if (s.local.family == AF_INET) {
 		s.local.bytelen = s.remote.bytelen = 4;
@@ -1983,13 +1995,7 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 	}
 
 	if (show_details) {
-		if (r->idiag_uid)
-			printf(" uid:%u", (unsigned)r->idiag_uid);
-		printf(" ino:%u", r->idiag_inode);
-		printf(" sk:");
-		if (r->id.idiag_cookie[1] != 0)
-			printf("%08x", r->id.idiag_cookie[1]);
-		printf("%08x", r->id.idiag_cookie[0]);
+		sock_details_print(&s);
 		if (tb[INET_DIAG_SHUTDOWN]) {
 			unsigned char mask;
 			mask = *(__u8 *)RTA_DATA(tb[INET_DIAG_SHUTDOWN]);
@@ -2351,14 +2357,8 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 
 	inet_stats_print(&s, IPPROTO_UDP);
 
-	if (show_details) {
-		if (s.uid)
-			printf(" uid=%u", (unsigned)s.uid);
-		printf(" ino=%u", s.ino);
-		printf(" sk=%llx", s.sk);
-		if (opt[0])
-			printf(" opt:\"%s\"", opt);
-	}
+	if (show_details && opt[0])
+		printf(" opt:\"%s\"", opt);
 
 	printf("\n");
 	return 0;
@@ -2774,6 +2774,9 @@ static int packet_stats_print(struct sockstat *s, const struct filter *f)
 		}
 	}
 
+	if (show_details)
+		sock_details_print(s);
+
 	return 0;
 }
 
@@ -2796,6 +2799,7 @@ static int packet_show_sock(const struct sockaddr_nl *addr,
 	stat.prot   = r->pdiag_num;
 	stat.ino    = r->pdiag_ino;
 	stat.state  = SS_CLOSE;
+	stat.sk	    = cookie_sk_get(&r->pdiag_cookie[0]);
 
 	if (tb[PACKET_DIAG_MEMINFO]) {
 		__u32 *skmeminfo = RTA_DATA(tb[PACKET_DIAG_MEMINFO]);
@@ -2807,21 +2811,12 @@ static int packet_show_sock(const struct sockaddr_nl *addr,
 		stat.lport = stat.iface = pinfo->pdi_index;
 	}
 
+	if (tb[PACKET_DIAG_UID])
+		stat.uid = *(__u32 *)RTA_DATA(tb[PACKET_DIAG_UID]);
+
 	if (packet_stats_print(&stat, f))
 		return 0;
 
-	if (show_details) {
-		__u32 uid = 0;
-
-		if (tb[PACKET_DIAG_UID])
-			uid = *(__u32 *)RTA_DATA(tb[PACKET_DIAG_UID]);
-
-		printf(" ino=%u uid=%u sk=", r->pdiag_ino, uid);
-		if (r->pdiag_cookie[1] != 0)
-			printf("%08x", r->pdiag_cookie[1]);
-		printf("%08x", r->pdiag_cookie[0]);
-	}
-
 	if (show_bpf && tb[PACKET_DIAG_FILTER]) {
 		struct sock_filter *fil =
 		       RTA_DATA(tb[PACKET_DIAG_FILTER]);
@@ -2878,9 +2873,6 @@ static int packet_show_line(char *buf, const struct filter *f, int fam)
 	if (packet_stats_print(&stat, f))
 		return 0;
 
-	if (show_details) {
-		printf(" ino=%u uid=%u sk=%llx", ino, uid, sk);
-	}
 	printf("\n");
 	return 0;
 }
-- 
2.2.2
