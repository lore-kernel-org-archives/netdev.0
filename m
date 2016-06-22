From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 1/3] ss: Refactor inet_show_sock
Date: Tue, 21 Jun 2016 20:38:24 -0700
Message-ID: <1466566706-1511-2-git-send-email-dsa@cumulusnetworks.com>
References: <1466566706-1511-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34311 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbcFVDip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 23:38:45 -0400
Received: by mail-pa0-f53.google.com with SMTP id bz2so12402758pad.1
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 20:38:40 -0700 (PDT)
In-Reply-To: <1466566706-1511-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extract parsing of sockstat and filter from inet_show_sock.
While moving run_ssfilter into callers of inet_show_sock enable
userspace filtering before the kill.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 misc/ss.c | 68 ++++++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 43 insertions(+), 25 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 02be7e7407df..a22cfebadfa2 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2038,42 +2038,47 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 	}
 }
 
-static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
+static void parse_diag_msg(struct nlmsghdr *nlh, struct sockstat *s)
 {
 	struct rtattr *tb[INET_DIAG_MAX+1];
 	struct inet_diag_msg *r = NLMSG_DATA(nlh);
-	struct sockstat s = {};
 
 	parse_rtattr(tb, INET_DIAG_MAX, (struct rtattr *)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
-	s.state		= r->idiag_state;
-	s.local.family  = s.remote.family = r->idiag_family;
-	s.lport		= ntohs(r->id.idiag_sport);
-	s.rport		= ntohs(r->id.idiag_dport);
-	s.wq		= r->idiag_wqueue;
-	s.rq		= r->idiag_rqueue;
-	s.ino		= r->idiag_inode;
-	s.uid		= r->idiag_uid;
-	s.iface		= r->id.idiag_if;
-	s.sk		= cookie_sk_get(&r->id.idiag_cookie[0]);
-
-	if (s.local.family == AF_INET) {
-		s.local.bytelen = s.remote.bytelen = 4;
+	s->state	= r->idiag_state;
+	s->local.family	= s->remote.family = r->idiag_family;
+	s->lport	= ntohs(r->id.idiag_sport);
+	s->rport	= ntohs(r->id.idiag_dport);
+	s->wq		= r->idiag_wqueue;
+	s->rq		= r->idiag_rqueue;
+	s->ino		= r->idiag_inode;
+	s->uid		= r->idiag_uid;
+	s->iface	= r->id.idiag_if;
+	s->sk		= cookie_sk_get(&r->id.idiag_cookie[0]);
+
+	if (s->local.family == AF_INET) {
+		s->local.bytelen = s->remote.bytelen = 4;
 	} else {
-		s.local.bytelen = s.remote.bytelen = 16;
+		s->local.bytelen = s->remote.bytelen = 16;
 	}
 
-	memcpy(s.local.data, r->id.idiag_src, s.local.bytelen);
-	memcpy(s.remote.data, r->id.idiag_dst, s.local.bytelen);
+	memcpy(s->local.data, r->id.idiag_src, s->local.bytelen);
+	memcpy(s->remote.data, r->id.idiag_dst, s->local.bytelen);
+}
 
-	if (f && f->f && run_ssfilter(f->f, &s) == 0)
-		return 0;
+static int inet_show_sock(struct nlmsghdr *nlh, struct sockstat *s, int protocol)
+{
+	struct rtattr *tb[INET_DIAG_MAX+1];
+	struct inet_diag_msg *r = NLMSG_DATA(nlh);
+
+	parse_rtattr(tb, INET_DIAG_MAX, (struct rtattr *)(r+1),
+		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	if (tb[INET_DIAG_PROTOCOL])
 		protocol = *(__u8 *)RTA_DATA(tb[INET_DIAG_PROTOCOL]);
 
-	inet_stats_print(&s, protocol);
+	inet_stats_print(s, protocol);
 
 	if (show_options) {
 		struct tcpstat t = {};
@@ -2085,8 +2090,8 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 	}
 
 	if (show_details) {
-		sock_details_print(&s);
-		if (s.local.family == AF_INET6 && tb[INET_DIAG_SKV6ONLY]) {
+		sock_details_print(s);
+		if (s->local.family == AF_INET6 && tb[INET_DIAG_SKV6ONLY]) {
 			unsigned char v6only;
 
 			v6only = *(__u8 *)RTA_DATA(tb[INET_DIAG_SKV6ONLY]);
@@ -2268,9 +2273,16 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 	int err;
 	struct inet_diag_arg *diag_arg = arg;
 	struct inet_diag_msg *r = NLMSG_DATA(h);
+	struct sockstat s = {};
 
 	if (!(diag_arg->f->families & (1 << r->idiag_family)))
 		return 0;
+
+	parse_diag_msg(h, &s);
+
+	if (diag_arg->f->f && run_ssfilter(diag_arg->f->f, &s) == 0)
+		return 0;
+
 	if (diag_arg->f->kill && kill_inet_sock(h, arg) != 0) {
 		if (errno == EOPNOTSUPP || errno == ENOENT) {
 			/* Socket can't be closed, or is already closed. */
@@ -2280,7 +2292,7 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 			return -1;
 		}
 	}
-	if ((err = inet_show_sock(h, diag_arg->f, diag_arg->protocol)) < 0)
+	if ((err = inet_show_sock(h, &s, diag_arg->protocol)) < 0)
 		return err;
 
 	return 0;
@@ -2345,6 +2357,7 @@ static int tcp_show_netlink_file(struct filter *f)
 	while (1) {
 		int status, err;
 		struct nlmsghdr *h = (struct nlmsghdr *)buf;
+		struct sockstat s = {};
 
 		status = fread(buf, 1, sizeof(*h), fp);
 		if (status < 0) {
@@ -2383,7 +2396,12 @@ static int tcp_show_netlink_file(struct filter *f)
 			return -1;
 		}
 
-		err = inet_show_sock(h, f, IPPROTO_TCP);
+		parse_diag_msg(h, &s);
+
+		if (f && f->f && run_ssfilter(f->f, &s) == 0)
+			continue;
+
+		err = inet_show_sock(h, &s, IPPROTO_TCP);
 		if (err < 0)
 			return err;
 	}
-- 
2.1.4
