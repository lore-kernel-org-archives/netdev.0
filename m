From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 1/7] ss: Split tcpstap struct to sockstat & tcpstat
Date: Fri, 13 Feb 2015 22:13:58 +0200
Message-ID: <1423858444-10158-2-git-send-email-vadim4j@gmail.com>
References: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:36776 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbbBMUZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 15:25:12 -0500
Received: by labgq15 with SMTP id gq15so18747457lab.3
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 12:25:10 -0800 (PST)
In-Reply-To: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 154 +++++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 86 insertions(+), 68 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 0a6a65e..7e11fc0 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -690,16 +690,7 @@ static const char *sstate_namel[] = {
 	[SS_CLOSING] = "closing",
 };
 
-struct dctcpstat
-{
-	unsigned int	ce_state;
-	unsigned int	alpha;
-	unsigned int	ab_ecn;
-	unsigned int	ab_tot;
-	bool		enabled;
-};
-
-struct tcpstat
+struct sockstat
 {
 	inet_prefix	    local;
 	inet_prefix	    remote;
@@ -712,6 +703,20 @@ struct tcpstat
 	int		    refcnt;
 	unsigned int	    iface;
 	unsigned long long  sk;
+};
+
+struct dctcpstat
+{
+	unsigned int	ce_state;
+	unsigned int	alpha;
+	unsigned int	ab_ecn;
+	unsigned int	ab_tot;
+	bool		enabled;
+};
+
+struct tcpstat
+{
+	struct sockstat	    ss;
 	int		    timer;
 	int		    timeout;
 	int		    probes;
@@ -999,7 +1004,7 @@ static int unix_match(const inet_prefix *a, const inet_prefix *p)
 	return !fnmatch(pattern, addr, 0);
 }
 
-static int run_ssfilter(struct ssfilter *f, struct tcpstat *s)
+static int run_ssfilter(struct ssfilter *f, struct sockstat *s)
 {
 	switch (f->type) {
 		case SSF_S_AUTO:
@@ -1484,7 +1489,7 @@ static char *proto_name(int protocol)
 	return "???";
 }
 
-static void inet_stats_print(struct tcpstat *s, int protocol)
+static void inet_stats_print(struct sockstat *s, int protocol)
 {
 	char *buf = NULL;
 
@@ -1498,17 +1503,6 @@ static void inet_stats_print(struct tcpstat *s, int protocol)
 	formatted_print(&s->local, s->lport, s->iface);
 	formatted_print(&s->remote, s->rport, 0);
 
-	if (show_options) {
-		if (s->timer) {
-			if (s->timer > 4)
-				s->timer = 5;
-			printf(" timer:(%s,%s,%d)",
-			       tmr_name[s->timer],
-			       print_ms_timer(s->timeout),
-			       s->retrans);
-		}
-	}
-
 	if (show_proc_ctx || show_sock_ctx) {
 		if (find_entry(s->ino, &buf,
 				(show_proc_ctx & show_sock_ctx) ?
@@ -1524,7 +1518,8 @@ static void inet_stats_print(struct tcpstat *s, int protocol)
 	}
 }
 
-static int proc_parse_inet_addr(char *loc, char *rem, int family, struct tcpstat *s)
+static int proc_parse_inet_addr(char *loc, char *rem, int family, struct
+		sockstat *s)
 {
 	s->local.family = s->remote.family = family;
 	if (family == AF_INET) {
@@ -1655,7 +1650,7 @@ static void tcp_stats_print(struct tcpstat *s)
 		printf(" retrans:%u/%u", s->retrans, s->retrans_total);
 	if (s->lost)
 		printf(" lost:%u", s->lost);
-	if (s->sacked && s->state != SS_LISTEN)
+	if (s->sacked && s->ss.state != SS_LISTEN)
 		printf(" sacked:%u", s->sacked);
 	if (s->fackets)
 		printf(" fackets:%u", s->fackets);
@@ -1667,6 +1662,18 @@ static void tcp_stats_print(struct tcpstat *s)
 		printf(" rcv_space:%d", s->rcv_space);
 }
 
+static void tcp_timer_print(struct tcpstat *s)
+{
+	if (s->timer) {
+		if (s->timer > 4)
+			s->timer = 5;
+		printf(" timer:(%s,%s,%d)",
+				tmr_name[s->timer],
+				print_ms_timer(s->timeout),
+				s->retrans);
+	}
+}
+
 static int tcp_show_line(char *line, const struct filter *f, int family)
 {
 	int rto = 0, ato = 0;
@@ -1683,17 +1690,17 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 	if (!(f->states & (1 << state)))
 		return 0;
 
-	proc_parse_inet_addr(loc, rem, family, &s);
+	proc_parse_inet_addr(loc, rem, family, &s.ss);
 
-	if (f->f && run_ssfilter(f->f, &s) == 0)
+	if (f->f && run_ssfilter(f->f, &s.ss) == 0)
 		return 0;
 
 	opt[0] = 0;
 	n = sscanf(data, "%x %x:%x %x:%x %x %d %d %u %d %llx %d %d %d %d %d %[^\n]\n",
-		   &s.state, &s.wq, &s.rq,
-		   &s.timer, &s.timeout, &s.retrans, &s.uid, &s.probes, &s.ino,
-		   &s.refcnt, &s.sk, &rto, &ato, &s.qack,
-		   &s.cwnd, &s.ssthresh, opt);
+		   &s.ss.state, &s.ss.wq, &s.ss.rq,
+		   &s.timer, &s.timeout, &s.retrans, &s.ss.uid, &s.probes,
+		   &s.ss.ino, &s.ss.refcnt, &s.ss.sk, &rto, &ato, &s.qack, &s.cwnd,
+		   &s.ssthresh, opt);
 
 	if (n < 17)
 		opt[0] = 0;
@@ -1713,13 +1720,16 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 	s.ssthresh  = s.ssthresh == -1 ? 0 : s.ssthresh;
 	s.rto	    = s.rto != 3 * hz  ? s.rto / hz : 0;
 
-	inet_stats_print(&s, IPPROTO_TCP);
+	inet_stats_print(&s.ss, IPPROTO_TCP);
+
+	if (show_options)
+		tcp_timer_print(&s);
 
 	if (show_details) {
-		if (s.uid)
-			printf(" uid:%u", (unsigned)s.uid);
-		printf(" ino:%u", s.ino);
-		printf(" sk:%llx", s.sk);
+		if (s.ss.uid)
+			printf(" uid:%u", (unsigned)s.ss.uid);
+		printf(" ino:%u", s.ss.ino);
+		printf(" sk:%llx", s.ss.sk);
 		if (opt[0])
 			printf(" opt:\"%s\"", opt);
 	}
@@ -1804,6 +1814,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 	double rtt = 0;
 	struct tcpstat s = {};
 
+	s.ss.state = r->idiag_state;
+
 	print_skmeminfo(tb, INET_DIAG_SKMEMINFO);
 
 	if (tb[INET_DIAG_INFO]) {
@@ -1913,7 +1925,7 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 {
 	struct rtattr * tb[INET_DIAG_MAX+1];
 	struct inet_diag_msg *r = NLMSG_DATA(nlh);
-	struct tcpstat s = {};
+	struct sockstat s = {};
 
 	parse_rtattr(tb, INET_DIAG_MAX, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
@@ -1924,9 +1936,6 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 	s.rport = ntohs(r->id.idiag_dport);
 	s.wq = r->idiag_wqueue;
 	s.rq = r->idiag_rqueue;
-	s.timer = r->idiag_timer;
-	s.timeout = r->idiag_expires;
-	s.retrans = r->idiag_retrans;
 	s.ino = r->idiag_inode;
 	s.uid = r->idiag_uid;
 	s.iface = r->id.idiag_if;
@@ -1945,6 +1954,15 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 
 	inet_stats_print(&s, protocol);
 
+	if (show_options) {
+		struct tcpstat t = {};
+
+		t.timer = r->idiag_timer;
+		t.timeout = r->idiag_expires;
+		t.retrans = r->idiag_retrans;
+		tcp_timer_print(&t);
+	}
+
 	if (show_details) {
 		if (r->idiag_uid)
 			printf(" uid:%u", (unsigned)r->idiag_uid);
@@ -2286,7 +2304,7 @@ outerr:
 
 static int dgram_show_line(char *line, const struct filter *f, int family)
 {
-	struct tcpstat s = {};
+	struct sockstat s = {};
 	char *loc, *rem, *data;
 	char opt[256];
 	int n;
@@ -2483,15 +2501,15 @@ static void unix_stats_print(struct unixstat *list, struct filter *f)
 		}
 
 		if (f->f) {
-			struct tcpstat tst;
-			tst.local.family = AF_UNIX;
-			tst.remote.family = AF_UNIX;
-			memcpy(tst.local.data, &s->name, sizeof(s->name));
+			struct sockstat st;
+			st.local.family = AF_UNIX;
+			st.remote.family = AF_UNIX;
+			memcpy(st.local.data, &s->name, sizeof(s->name));
 			if (strcmp(peer, "*") == 0)
-				memset(tst.remote.data, 0, sizeof(peer));
+				memset(st.remote.data, 0, sizeof(peer));
 			else
-				memcpy(tst.remote.data, &peer, sizeof(peer));
-			if (run_ssfilter(f->f, &tst) == 0)
+				memcpy(st.remote.data, &peer, sizeof(peer));
+			if (run_ssfilter(f->f, &st) == 0)
 				continue;
 		}
 
@@ -2716,14 +2734,14 @@ static int packet_stats_print(struct pktstat *s, const struct filter *f)
 	char *buf = NULL;
 
 	if (f->f) {
-		struct tcpstat tst;
-		tst.local.family = AF_PACKET;
-		tst.remote.family = AF_PACKET;
-		tst.rport = 0;
-		tst.lport = s->iface;
-		tst.local.data[0] = s->prot;
-		tst.remote.data[0] = 0;
-		if (run_ssfilter(f->f, &tst) == 0)
+		struct sockstat st;
+		st.local.family = AF_PACKET;
+		st.remote.family = AF_PACKET;
+		st.rport = 0;
+		st.lport = s->iface;
+		st.local.data[0] = s->prot;
+		st.remote.data[0] = 0;
+		if (run_ssfilter(f->f, &st) == 0)
 			return 1;
 	}
 
@@ -2899,14 +2917,14 @@ static void netlink_show_one(struct filter *f,
 	SPRINT_BUF(prot_name);
 
 	if (f->f) {
-		struct tcpstat tst;
-		tst.local.family = AF_NETLINK;
-		tst.remote.family = AF_NETLINK;
-		tst.rport = -1;
-		tst.lport = pid;
-		tst.local.data[0] = prot;
-		tst.remote.data[0] = 0;
-		if (run_ssfilter(f->f, &tst) == 0)
+		struct sockstat st;
+		st.local.family = AF_NETLINK;
+		st.remote.family = AF_NETLINK;
+		st.rport = -1;
+		st.lport = pid;
+		st.local.data[0] = prot;
+		st.remote.data[0] = 0;
+		if (run_ssfilter(f->f, &st) == 0)
 			return;
 	}
 
@@ -3117,7 +3135,7 @@ static int get_snmp_int(char *proto, char *key, int *result)
 
 /* Get stats from sockstat */
 
-struct sockstat
+struct ssummary
 {
 	int socks;
 	int tcp_mem;
@@ -3136,7 +3154,7 @@ struct sockstat
 	int frag6_mem;
 };
 
-static void get_sockstat_line(char *line, struct sockstat *s)
+static void get_sockstat_line(char *line, struct ssummary *s)
 {
 	char id[256], rem[256];
 
@@ -3165,7 +3183,7 @@ static void get_sockstat_line(char *line, struct sockstat *s)
 		       &s->tcp_orphans, &s->tcp_tws, &s->tcp_total, &s->tcp_mem);
 }
 
-static int get_sockstat(struct sockstat *s)
+static int get_sockstat(struct ssummary *s)
 {
 	char buf[256];
 	FILE *fp;
@@ -3189,7 +3207,7 @@ static int get_sockstat(struct sockstat *s)
 
 static int print_summary(void)
 {
-	struct sockstat s;
+	struct ssummary s;
 	struct snmpstat sn;
 
 	if (get_sockstat(&s) < 0)
-- 
2.2.2
