From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 2/3] ss: Unify inet sockets output
Date: Sun, 18 Jan 2015 22:43:34 +0200
Message-ID: <1421613815-6635-3-git-send-email-vadim4j@gmail.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:54181 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbbARUyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 15:54:13 -0500
Received: by mail-we0-f179.google.com with SMTP id q59so4747058wes.10
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 12:54:12 -0800 (PST)
In-Reply-To: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 355 +++++++++++++++++++++++++-------------------------------------
 1 file changed, 144 insertions(+), 211 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index c5995ab..40439b3 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -708,6 +708,7 @@ struct tcpstat
 	int		refcnt;
 	unsigned long long sk;
 	int		rto, ato, qack, cwnd, ssthresh;
+	unsigned int	iface;
 };
 
 static const char *tmr_name[] = {
@@ -746,12 +747,6 @@ static const char *print_ms_timer(int timeout)
 	return buf;
 }
 
-static const char *print_hz_timer(int timeout)
-{
-	int hz = get_user_hz();
-	return print_ms_timer(((timeout*1000) + hz-1)/hz);
-}
-
 struct scache
 {
 	struct scache *next;
@@ -1441,55 +1436,124 @@ out:
 	return res;
 }
 
-static int tcp_show_line(char *line, const struct filter *f, int family)
+static char *proto_name(int protocol)
+{
+	switch (protocol) {
+	case IPPROTO_UDP:
+		return "udp";
+	case IPPROTO_TCP:
+		return "tcp";
+	case IPPROTO_DCCP:
+		return "dccp";
+	}
+
+	return "???";
+}
+
+static void inet_stats_print(struct tcpstat *s, int protocol)
+{
+	char *buf = NULL;
+
+	if (netid_width)
+		printf("%-*s ", netid_width, proto_name(protocol));
+	if (state_width)
+		printf("%-*s ", state_width, sstate_name[s->state]);
+
+	printf("%-6d %-6d ", s->rq, s->wq);
+
+	formatted_print(&s->local, s->lport, s->iface);
+	formatted_print(&s->remote, s->rport, 0);
+
+	if (show_options) {
+		if (s->timer) {
+			if (s->timer > 4)
+				s->timer = 5;
+			printf(" timer:(%s,%s,%d)",
+			       tmr_name[s->timer],
+			       print_ms_timer(s->timeout),
+			       s->retrs);
+		}
+	}
+
+	if (show_proc_ctx || show_sock_ctx) {
+		if (find_entry(s->ino, &buf,
+				(show_proc_ctx & show_sock_ctx) ?
+				PROC_SOCK_CTX : PROC_CTX) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
+	} else if (show_users) {
+		if (find_entry(s->ino, &buf, USERS) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
+	}
+}
+
+static int proc_parse_inet_addr(char *loc, char *rem, int family, struct tcpstat *s)
+{
+	s->local.family = s->remote.family = family;
+	if (family == AF_INET) {
+		sscanf(loc, "%x:%x", s->local.data, (unsigned*)&s->lport);
+		sscanf(rem, "%x:%x", s->remote.data, (unsigned*)&s->rport);
+		s->local.bytelen = s->remote.bytelen = 4;
+		return 0;
+	} else {
+		sscanf(loc, "%08x%08x%08x%08x:%x",
+		       s->local.data,
+		       s->local.data + 1,
+		       s->local.data + 2,
+		       s->local.data + 3,
+		       &s->lport);
+		sscanf(rem, "%08x%08x%08x%08x:%x",
+		       s->remote.data,
+		       s->remote.data + 1,
+		       s->remote.data + 2,
+		       s->remote.data + 3,
+		       &s->rport);
+		s->local.bytelen = s->remote.bytelen = 16;
+		return 0;
+	}
+	return -1;
+}
+
+static int proc_inet_split_line(char *line, char **loc, char **rem, char **data)
 {
-	struct tcpstat s;
-	char *loc, *rem, *data;
-	char opt[256];
-	int n;
 	char *p;
 
 	if ((p = strchr(line, ':')) == NULL)
 		return -1;
-	loc = p+2;
 
-	if ((p = strchr(loc, ':')) == NULL)
+	*loc = p+2;
+	if ((p = strchr(*loc, ':')) == NULL)
 		return -1;
-	p[5] = 0;
-	rem = p+6;
 
-	if ((p = strchr(rem, ':')) == NULL)
+	p[5] = 0;
+	*rem = p+6;
+	if ((p = strchr(*rem, ':')) == NULL)
 		return -1;
+
 	p[5] = 0;
-	data = p+6;
+	*data = p+6;
+	return 0;
+}
 
-	do {
-		int state = (data[1] >= 'A') ? (data[1] - 'A' + 10) : (data[1] - '0');
+static int tcp_show_line(char *line, const struct filter *f, int family)
+{
+	struct tcpstat s = {};
+	char *loc, *rem, *data;
+	char opt[256];
+	int n;
+	int hz = get_user_hz();
 
-		if (!(f->states & (1<<state)))
-			return 0;
-	} while (0);
+	if (proc_inet_split_line(line, &loc, &rem, &data))
+		return -1;
 
-	s.local.family = s.remote.family = family;
-	if (family == AF_INET) {
-		sscanf(loc, "%x:%x", s.local.data, (unsigned*)&s.lport);
-		sscanf(rem, "%x:%x", s.remote.data, (unsigned*)&s.rport);
-		s.local.bytelen = s.remote.bytelen = 4;
-	} else {
-		sscanf(loc, "%08x%08x%08x%08x:%x",
-		       s.local.data,
-		       s.local.data+1,
-		       s.local.data+2,
-		       s.local.data+3,
-		       &s.lport);
-		sscanf(rem, "%08x%08x%08x%08x:%x",
-		       s.remote.data,
-		       s.remote.data+1,
-		       s.remote.data+2,
-		       s.remote.data+3,
-		       &s.rport);
-		s.local.bytelen = s.remote.bytelen = 16;
-	}
+	int state = (data[1] >= 'A') ? (data[1] - 'A' + 10) : (data[1] - '0');
+	if (!(f->states & (1 << state)))
+		return 0;
+
+	proc_parse_inet_addr(loc, rem, family, &s);
 
 	if (f->f && run_ssfilter(f->f, &s) == 0)
 		return 0;
@@ -1511,66 +1575,36 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 		s.ato = s.qack = 0;
 	}
 
-	if (netid_width)
-		printf("%-*s ", netid_width, "tcp");
-	if (state_width)
-		printf("%-*s ", state_width, sstate_name[s.state]);
-
-	printf("%-6d %-6d ", s.rq, s.wq);
+	s.retrs = s.timer != 1 ? s.probes : s.retrs;
+	s.timeout = (s.timeout * 1000 + hz - 1) / hz;
 
-	formatted_print(&s.local, s.lport, 0);
-	formatted_print(&s.remote, s.rport, 0);
+	inet_stats_print(&s, IPPROTO_TCP);
 
-	if (show_options) {
-		if (s.timer) {
-			if (s.timer > 4)
-				s.timer = 5;
-			printf(" timer:(%s,%s,%d)",
-			       tmr_name[s.timer],
-			       print_hz_timer(s.timeout),
-			       s.timer != 1 ? s.probes : s.retrs);
-		}
+	if (show_details) {
+		if (s.uid)
+			printf(" uid:%u", (unsigned)s.uid);
+		printf(" ino:%u", s.ino);
+		printf(" sk:%llx", s.sk);
+		if (opt[0])
+			printf(" opt:\"%s\"", opt);
 	}
+
 	if (show_tcpinfo) {
-		int hz = get_user_hz();
-		if (s.rto && s.rto != 3*hz)
-			printf(" rto:%g", (double)s.rto/hz);
+		if (s.rto && s.rto != 3 * hz)
+			printf(" rto:%g", (double)s.rto / hz);
 		if (s.ato)
-			printf(" ato:%g", (double)s.ato/hz);
+			printf(" ato:%g", (double)s.ato / hz);
 		if (s.cwnd != 2)
 			printf(" cwnd:%d", s.cwnd);
 		if (s.ssthresh != -1)
 			printf(" ssthresh:%d", s.ssthresh);
-		if (s.qack/2)
-			printf(" qack:%d", s.qack/2);
-		if (s.qack&1)
+		if (s.qack / 2)
+			printf(" qack:%d", s.qack / 2);
+		if (s.qack & 1)
 			printf(" bidir");
 	}
-	char *buf = NULL;
-	if (show_proc_ctx || show_sock_ctx) {
-		if (find_entry(s.ino, &buf,
-				(show_proc_ctx & show_sock_ctx) ?
-				PROC_SOCK_CTX : PROC_CTX) > 0) {
-			printf(" users:(%s)", buf);
-			free(buf);
-		}
-	} else if (show_users) {
-		if (find_entry(s.ino, &buf, USERS) > 0) {
-			printf(" users:(%s)", buf);
-			free(buf);
-		}
-	}
 
-	if (show_details) {
-		if (s.uid)
-			printf(" uid:%u", (unsigned)s.uid);
-		printf(" ino:%u", s.ino);
-		printf(" sk:%llx", s.sk);
-		if (opt[0])
-			printf(" opt:\"%s\"", opt);
-	}
 	printf("\n");
-
 	return 0;
 }
 
@@ -1779,25 +1813,11 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 	}
 }
 
-static char *proto_name(int protocol)
-{
-	switch (protocol) {
-	case IPPROTO_UDP:
-		return "udp";
-	case IPPROTO_TCP:
-		return "tcp";
-	case IPPROTO_DCCP:
-		return "dccp";
-	}
-
-	return "???";
-}
-
 static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 {
 	struct rtattr * tb[INET_DIAG_MAX+1];
 	struct inet_diag_msg *r = NLMSG_DATA(nlh);
-	struct tcpstat s;
+	struct tcpstat s = {};
 
 	parse_rtattr(tb, INET_DIAG_MAX, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
@@ -1806,52 +1826,28 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 	s.local.family = s.remote.family = r->idiag_family;
 	s.lport = ntohs(r->id.idiag_sport);
 	s.rport = ntohs(r->id.idiag_dport);
+	s.wq = r->idiag_wqueue;
+	s.rq = r->idiag_rqueue;
+	s.timer = r->idiag_timer;
+	s.timeout = r->idiag_expires;
+	s.retrs = r->idiag_retrans;
+	s.ino = r->idiag_inode;
+	s.uid = r->idiag_uid;
+	s.iface = r->id.idiag_if;
+
 	if (s.local.family == AF_INET) {
 		s.local.bytelen = s.remote.bytelen = 4;
 	} else {
 		s.local.bytelen = s.remote.bytelen = 16;
 	}
+
 	memcpy(s.local.data, r->id.idiag_src, s.local.bytelen);
 	memcpy(s.remote.data, r->id.idiag_dst, s.local.bytelen);
 
 	if (f && f->f && run_ssfilter(f->f, &s) == 0)
 		return 0;
 
-	if (netid_width)
-		printf("%-*s ", netid_width, proto_name(protocol));
-	if (state_width)
-		printf("%-*s ", state_width, sstate_name[s.state]);
-
-	printf("%-6d %-6d ", r->idiag_rqueue, r->idiag_wqueue);
-
-	formatted_print(&s.local, s.lport, r->id.idiag_if);
-	formatted_print(&s.remote, s.rport, 0);
-
-	if (show_options) {
-		if (r->idiag_timer) {
-			if (r->idiag_timer > 4)
-				r->idiag_timer = 5;
-			printf(" timer:(%s,%s,%d)",
-			       tmr_name[r->idiag_timer],
-			       print_ms_timer(r->idiag_expires),
-			       r->idiag_retrans);
-		}
-	}
-	char *buf = NULL;
-
-	if (show_proc_ctx || show_sock_ctx) {
-		if (find_entry(r->idiag_inode, &buf,
-				(show_proc_ctx & show_sock_ctx) ?
-				PROC_SOCK_CTX : PROC_CTX) > 0) {
-			printf(" users:(%s)", buf);
-			free(buf);
-		}
-	} else if (show_users) {
-		if (find_entry(r->idiag_inode, &buf, USERS) > 0) {
-			printf(" users:(%s)", buf);
-			free(buf);
-		}
-	}
+	inet_stats_print(&s, protocol);
 
 	if (show_details) {
 		if (r->idiag_uid)
@@ -1867,13 +1863,13 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 			printf(" %c-%c", mask & 1 ? '-' : '<', mask & 2 ? '-' : '>');
 		}
 	}
+
 	if (show_mem || show_tcpinfo) {
 		printf("\n\t");
 		tcp_show_info(nlh, r, tb);
 	}
 
 	printf("\n");
-
 	return 0;
 }
 
@@ -2194,53 +2190,19 @@ outerr:
 
 static int dgram_show_line(char *line, const struct filter *f, int family)
 {
-	struct tcpstat s;
+	struct tcpstat s = {};
 	char *loc, *rem, *data;
 	char opt[256];
 	int n;
-	char *p;
-
-	if ((p = strchr(line, ':')) == NULL)
-		return -1;
-	loc = p+2;
-
-	if ((p = strchr(loc, ':')) == NULL)
-		return -1;
-	p[5] = 0;
-	rem = p+6;
 
-	if ((p = strchr(rem, ':')) == NULL)
+	if (proc_inet_split_line(line, &loc, &rem, &data))
 		return -1;
-	p[5] = 0;
-	data = p+6;
-
-	do {
-		int state = (data[1] >= 'A') ? (data[1] - 'A' + 10) : (data[1] - '0');
 
-		if (!(f->states & (1<<state)))
-			return 0;
-	} while (0);
+	int state = (data[1] >= 'A') ? (data[1] - 'A' + 10) : (data[1] - '0');
+	if (!(f->states & (1 << state)))
+		return 0;
 
-	s.local.family = s.remote.family = family;
-	if (family == AF_INET) {
-		sscanf(loc, "%x:%x", s.local.data, (unsigned*)&s.lport);
-		sscanf(rem, "%x:%x", s.remote.data, (unsigned*)&s.rport);
-		s.local.bytelen = s.remote.bytelen = 4;
-	} else {
-		sscanf(loc, "%08x%08x%08x%08x:%x",
-		       s.local.data,
-		       s.local.data+1,
-		       s.local.data+2,
-		       s.local.data+3,
-		       &s.lport);
-		sscanf(rem, "%08x%08x%08x%08x:%x",
-		       s.remote.data,
-		       s.remote.data+1,
-		       s.remote.data+2,
-		       s.remote.data+3,
-		       &s.rport);
-		s.local.bytelen = s.remote.bytelen = 16;
-	}
+	proc_parse_inet_addr(loc, rem, family, &s);
 
 	if (f->f && run_ssfilter(f->f, &s) == 0)
 		return 0;
@@ -2254,31 +2216,7 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 	if (n < 9)
 		opt[0] = 0;
 
-	if (netid_width)
-		printf("%-*s ", netid_width, dg_proto);
-	if (state_width)
-		printf("%-*s ", state_width, sstate_name[s.state]);
-
-	printf("%-6d %-6d ", s.rq, s.wq);
-
-	formatted_print(&s.local, s.lport, 0);
-	formatted_print(&s.remote, s.rport, 0);
-
-	char *buf = NULL;
-
-	if (show_proc_ctx || show_sock_ctx) {
-		if (find_entry(s.ino, &buf,
-				(show_proc_ctx & show_sock_ctx) ?
-				PROC_SOCK_CTX : PROC_CTX) > 0) {
-			printf(" users:(%s)", buf);
-			free(buf);
-		}
-	} else if (show_users) {
-		if (find_entry(s.ino, &buf, USERS) > 0) {
-			printf(" users:(%s)", buf);
-			free(buf);
-		}
-	}
+	inet_stats_print(&s, IPPROTO_UDP);
 
 	if (show_details) {
 		if (s.uid)
@@ -2288,12 +2226,11 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 		if (opt[0])
 			printf(" opt:\"%s\"", opt);
 	}
-	printf("\n");
 
+	printf("\n");
 	return 0;
 }
 
-
 static int udp_show(struct filter *f)
 {
 	FILE *fp = NULL;
@@ -2362,7 +2299,6 @@ outerr:
 	} while (0);
 }
 
-
 struct unixstat
 {
 	struct unixstat *next;
@@ -2376,12 +2312,9 @@ struct unixstat
 	char *name;
 };
 
-
-
 int unix_state_map[] = { SS_CLOSE, SS_SYN_SENT,
 			 SS_ESTABLISHED, SS_CLOSING };
 
-
 #define MAX_UNIX_REMEMBER (1024*1024/sizeof(struct unixstat))
 
 static void unix_list_free(struct unixstat *list)
-- 
2.1.3
