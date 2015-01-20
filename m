From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH 2/2] ss: Unify inet sockets output
Date: Tue, 20 Jan 2015 16:14:24 +0200
Message-ID: <1421763264-8954-3-git-send-email-vadim4j@gmail.com>
References: <1421763264-8954-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:62774 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbbATOZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:25:10 -0500
Received: by mail-we0-f169.google.com with SMTP id p10so14233117wes.0
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 06:25:09 -0800 (PST)
In-Reply-To: <1421763264-8954-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 677 ++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 355 insertions(+), 322 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 3764f3a..ef1fc9d 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -689,23 +689,59 @@ static const char *sstate_namel[] = {
 	[SS_CLOSING] = "closing",
 };
 
+struct dctcpstat
+{
+	unsigned int	ce_state;
+	unsigned int	alpha;
+	unsigned int	ab_ecn;
+	unsigned int	ab_tot;
+	bool		enabled;
+};
+
 struct tcpstat
 {
-	inet_prefix	local;
-	inet_prefix	remote;
-	int		lport;
-	int		rport;
-	int		state;
-	int		rq, wq;
-	int		timer;
-	int		timeout;
-	int		retrs;
-	unsigned	ino;
-	int		probes;
-	unsigned	uid;
-	int		refcnt;
-	unsigned long long sk;
-	int		rto, ato, qack, cwnd, ssthresh;
+	inet_prefix	    local;
+	inet_prefix	    remote;
+	int		    lport;
+	int		    rport;
+	int		    state;
+	int		    rq, wq;
+	unsigned	    ino;
+	unsigned	    uid;
+	int		    refcnt;
+	unsigned int	    iface;
+	unsigned long long  sk;
+	int		    timer;
+	int		    timeout;
+	int		    probes;
+	char		    *cong_alg;
+	double		    rto, ato, rtt, rttvar;
+	int		    qack, cwnd, ssthresh, backoff;
+	double		    send_bps;
+	int		    snd_wscale;
+	int		    rcv_wscale;
+	int		    mss;
+	unsigned int	    lastsnd;
+	unsigned int	    lastrcv;
+	unsigned int	    lastack;
+	double		    pacing_rate;
+	double		    pacing_rate_max;
+	unsigned int	    unacked;
+	unsigned int	    retrans;
+	unsigned int	    retrans_total;
+	unsigned int	    lost;
+	unsigned int	    sacked;
+	unsigned int	    fackets;
+	unsigned int	    reordering;
+	double		    rcv_rtt;
+	int		    rcv_space;
+	bool		    has_ts_opt;
+	bool		    has_sack_opt;
+	bool		    has_ecn_opt;
+	bool		    has_ecnseen_opt;
+	bool		    has_fastopen_opt;
+	bool		    has_wscale_opt;
+	struct dctcpstat    *dctcp;
 };
 
 static const char *tmr_name[] = {
@@ -744,12 +780,6 @@ static const char *print_ms_timer(int timeout)
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
@@ -1439,55 +1469,220 @@ out:
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
+			       s->retrans);
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
+static char *sprint_bw(char *buf, double bw)
+{
+	if (bw > 1000000.)
+		sprintf(buf,"%.1fM", bw / 1000000.);
+	else if (bw > 1000.)
+		sprintf(buf,"%.1fK", bw / 1000.);
+	else
+		sprintf(buf, "%g", bw);
 
-		if (!(f->states & (1<<state)))
-			return 0;
-	} while (0);
+	return buf;
+}
 
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
+static void tcp_stats_print(struct tcpstat *s)
+{
+	char b1[64];
+
+	if (s->has_ts_opt)
+		printf(" ts");
+	if (s->has_sack_opt)
+		printf(" sack");
+	if (s->has_ecn_opt)
+		printf(" ecn");
+	if (s->has_ecnseen_opt)
+		printf(" ecnseen");
+	if (s->has_fastopen_opt)
+		printf(" fastopen");
+	if (s->cong_alg)
+		printf(" %s", s->cong_alg);
+	if (s->has_wscale_opt)
+		printf(" wscale:%d,%d", s->snd_wscale, s->rcv_wscale);
+	if (s->rto)
+		printf(" rto:%g", s->rto);
+	if (s->backoff)
+		printf(" backoff:%u", s->backoff);
+	if (s->rtt)
+		printf(" rtt:%g/%g", s->rtt, s->rttvar);
+	if (s->ato)
+		printf(" ato:%g", s->ato);
+
+	if (s->qack)
+		printf(" qack:%d", s->qack);
+	if (s->qack & 1)
+		printf(" bidir");
+
+	if (s->mss)
+		printf(" mss:%d", s->mss);
+	if (s->cwnd && s->cwnd != 2)
+		printf(" cwnd:%d", s->cwnd);
+	if (s->ssthresh)
+		printf(" ssthresh:%d", s->ssthresh);
+
+	if (s->dctcp && s->dctcp->enabled) {
+		struct dctcpstat *dctcp = s->dctcp;
+
+		printf(" ce_state %u alpha %u ab_ecn %u ab_tot %u",
+				dctcp->ce_state, dctcp->alpha, dctcp->ab_ecn,
+				dctcp->ab_tot);
+	} else if (s->dctcp) {
+		printf(" fallback_mode");
+	}
+
+	if (s->send_bps)
+		printf(" send %sbps", sprint_bw(b1, s->send_bps));
+	if (s->lastsnd)
+		printf(" lastsnd:%u", s->lastsnd);
+	if (s->lastrcv)
+		printf(" lastrcv:%u", s->lastrcv);
+	if (s->lastack)
+		printf(" lastack:%u", s->lastack);
+
+	if (s->pacing_rate) {
+		printf(" pacing_rate %sbps", sprint_bw(b1, s->pacing_rate));
+		if (s->pacing_rate_max)
+				printf("/%sbps", sprint_bw(b1,
+							s->pacing_rate_max));
+	}
+
+	if (s->unacked)
+		printf(" unacked:%u", s->unacked);
+	if (s->retrans || s->retrans_total)
+		printf(" retrans:%u/%u", s->retrans, s->retrans_total);
+	if (s->lost)
+		printf(" lost:%u", s->lost);
+	if (s->sacked && s->state != SS_LISTEN)
+		printf(" sacked:%u", s->sacked);
+	if (s->fackets)
+		printf(" fackets:%u", s->fackets);
+	if (s->reordering != 3)
+		printf(" reordering:%d", s->reordering);
+	if (s->rcv_rtt)
+		printf(" rcv_rtt:%g", s->rcv_rtt);
+	if (s->rcv_space)
+		printf(" rcv_space:%d", s->rcv_space);
+}
+
+static int tcp_show_line(char *line, const struct filter *f, int family)
+{
+	int rto = 0, ato = 0;
+	struct tcpstat s = {};
+	char *loc, *rem, *data;
+	char opt[256];
+	int n;
+	int hz = get_user_hz();
+
+	if (proc_inet_split_line(line, &loc, &rem, &data))
+		return -1;
+
+	int state = (data[1] >= 'A') ? (data[1] - 'A' + 10) : (data[1] - '0');
+	if (!(f->states & (1 << state)))
+		return 0;
+
+	proc_parse_inet_addr(loc, rem, family, &s);
 
 	if (f->f && run_ssfilter(f->f, &s) == 0)
 		return 0;
@@ -1495,69 +1690,29 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 	opt[0] = 0;
 	n = sscanf(data, "%x %x:%x %x:%x %x %d %d %u %d %llx %d %d %d %d %d %[^\n]\n",
 		   &s.state, &s.wq, &s.rq,
-		   &s.timer, &s.timeout, &s.retrs, &s.uid, &s.probes, &s.ino,
-		   &s.refcnt, &s.sk, &s.rto, &s.ato, &s.qack,
+		   &s.timer, &s.timeout, &s.retrans, &s.uid, &s.probes, &s.ino,
+		   &s.refcnt, &s.sk, &rto, &ato, &s.qack,
 		   &s.cwnd, &s.ssthresh, opt);
 
 	if (n < 17)
 		opt[0] = 0;
 
 	if (n < 12) {
-		s.rto = 0;
+		rto = 0;
 		s.cwnd = 2;
 		s.ssthresh = -1;
-		s.ato = s.qack = 0;
+		ato = s.qack = 0;
 	}
 
-	if (netid_width)
-		printf("%-*s ", netid_width, "tcp");
-	if (state_width)
-		printf("%-*s ", state_width, sstate_name[s.state]);
+	s.retrans   = s.timer != 1 ? s.probes : s.retrans;
+	s.timeout   = (s.timeout * 1000 + hz - 1) / hz;
+	s.ato	    = (double)ato / hz;
+	s.qack	   /= 2;
+	s.rto	    = (double)rto;
+	s.ssthresh  = s.ssthresh == -1 ? 0 : s.ssthresh;
+	s.rto	    = s.rto != 3 * hz  ? s.rto / hz : 0;
 
-	printf("%-6d %-6d ", s.rq, s.wq);
-
-	formatted_print(&s.local, s.lport, 0);
-	formatted_print(&s.remote, s.rport, 0);
-
-	if (show_options) {
-		if (s.timer) {
-			if (s.timer > 4)
-				s.timer = 5;
-			printf(" timer:(%s,%s,%d)",
-			       tmr_name[s.timer],
-			       print_hz_timer(s.timeout),
-			       s.timer != 1 ? s.probes : s.retrs);
-		}
-	}
-	if (show_tcpinfo) {
-		int hz = get_user_hz();
-		if (s.rto && s.rto != 3*hz)
-			printf(" rto:%g", (double)s.rto/hz);
-		if (s.ato)
-			printf(" ato:%g", (double)s.ato/hz);
-		if (s.cwnd != 2)
-			printf(" cwnd:%d", s.cwnd);
-		if (s.ssthresh != -1)
-			printf(" ssthresh:%d", s.ssthresh);
-		if (s.qack/2)
-			printf(" qack:%d", s.qack/2);
-		if (s.qack&1)
-			printf(" bidir");
-	}
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
+	inet_stats_print(&s, IPPROTO_TCP);
 
 	if (show_details) {
 		if (s.uid)
@@ -1567,8 +1722,11 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 		if (opt[0])
 			printf(" opt:\"%s\"", opt);
 	}
-	printf("\n");
 
+	if (show_tcpinfo)
+		tcp_stats_print(&s);
+
+	printf("\n");
 	return 0;
 }
 
@@ -1598,18 +1756,6 @@ outerr:
 	return ferror(fp) ? -1 : 0;
 }
 
-static char *sprint_bw(char *buf, double bw)
-{
-	if (bw > 1000000.)
-		sprintf(buf,"%.1fM", bw / 1000000.);
-	else if (bw > 1000.)
-		sprintf(buf,"%.1fK", bw / 1000.);
-	else
-		sprintf(buf, "%g", bw);
-
-	return buf;
-}
-
 static void print_skmeminfo(struct rtattr *tb[], int attrtype)
 {
 	const __u32 *skmeminfo;
@@ -1649,11 +1795,13 @@ static void print_skmeminfo(struct rtattr *tb[], int attrtype)
 	printf(")");
 }
 
+#define TCPI_HAS_OPT(info, opt) !!(info->tcpi_options & (opt))
+
 static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		struct rtattr *tb[])
 {
-	char b1[64];
 	double rtt = 0;
+	struct tcpstat s = {};
 
 	print_skmeminfo(tb, INET_DIAG_SKMEMINFO);
 
@@ -1670,39 +1818,49 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 			info = RTA_DATA(tb[INET_DIAG_INFO]);
 
 		if (show_options) {
-			if (info->tcpi_options & TCPI_OPT_TIMESTAMPS)
-				printf(" ts");
-			if (info->tcpi_options & TCPI_OPT_SACK)
-				printf(" sack");
-			if (info->tcpi_options & TCPI_OPT_ECN)
-				printf(" ecn");
-			if (info->tcpi_options & TCPI_OPT_ECN_SEEN)
-				printf(" ecnseen");
-			if (info->tcpi_options & TCPI_OPT_SYN_DATA)
-				printf(" fastopen");
-		}
-
-		if (tb[INET_DIAG_CONG])
-			printf(" %s", rta_getattr_str(tb[INET_DIAG_CONG]));
-
-		if (info->tcpi_options & TCPI_OPT_WSCALE)
-			printf(" wscale:%d,%d", info->tcpi_snd_wscale,
-			       info->tcpi_rcv_wscale);
+			s.has_ts_opt	   = TCPI_HAS_OPT(info, TCPI_OPT_TIMESTAMPS);
+			s.has_sack_opt	   = TCPI_HAS_OPT(info, TCPI_OPT_SACK);
+			s.has_ecn_opt	   = TCPI_HAS_OPT(info, TCPI_OPT_ECN);
+			s.has_ecnseen_opt  = TCPI_HAS_OPT(info, TCPI_OPT_ECN_SEEN);
+			s.has_fastopen_opt = TCPI_HAS_OPT(info, TCPI_OPT_SYN_DATA);
+		}
+
+		if (tb[INET_DIAG_CONG]) {
+			const char *cong_attr = rta_getattr_str(tb[INET_DIAG_CONG]);
+			s.cong_alg = malloc(strlen(cong_attr + 1));
+			strcpy(s.cong_alg, cong_attr);
+		}
+
+		if (TCPI_HAS_OPT(info, TCPI_OPT_WSCALE)) {
+			s.has_wscale_opt  = true;
+			s.snd_wscale	  = info->tcpi_snd_wscale;
+			s.rcv_wscale	  = info->tcpi_rcv_wscale;
+		}
+
 		if (info->tcpi_rto && info->tcpi_rto != 3000000)
-			printf(" rto:%g", (double)info->tcpi_rto/1000);
-		if (info->tcpi_backoff)
-			printf(" backoff:%u", info->tcpi_backoff);
-		if (info->tcpi_rtt)
-			printf(" rtt:%g/%g", (double)info->tcpi_rtt/1000,
-			       (double)info->tcpi_rttvar/1000);
-		if (info->tcpi_ato)
-			printf(" ato:%g", (double)info->tcpi_ato/1000);
-		if (info->tcpi_snd_mss)
-			printf(" mss:%d", info->tcpi_snd_mss);
-		if (info->tcpi_snd_cwnd != 2)
-			printf(" cwnd:%d", info->tcpi_snd_cwnd);
+			s.rto = (double)info->tcpi_rto / 1000;
+
+		s.backoff	 = info->tcpi_backoff;
+		s.rtt		 = (double)info->tcpi_rtt / 1000;
+		s.rttvar	 = (double)info->tcpi_rttvar / 1000;
+		s.ato		 = (double)info->tcpi_rttvar / 1000;
+		s.mss		 = info->tcpi_snd_mss;
+		s.rcv_space	 = info->tcpi_rcv_space;
+		s.rcv_rtt	 = (double)info->tcpi_rcv_rtt / 1000;
+		s.lastsnd	 = info->tcpi_last_data_sent;
+		s.lastrcv	 = info->tcpi_last_data_recv;
+		s.lastack	 = info->tcpi_last_ack_recv;
+		s.unacked	 = info->tcpi_unacked;
+		s.retrans	 = info->tcpi_retrans;
+		s.retrans_total  = info->tcpi_total_retrans;
+		s.lost		 = info->tcpi_lost;
+		s.sacked	 = info->tcpi_sacked;
+		s.reordering	 = info->tcpi_reordering;
+		s.rcv_space	 = info->tcpi_rcv_space;
+		s.cwnd		 = info->tcpi_snd_cwnd;
+
 		if (info->tcpi_snd_ssthresh < 0xFFFF)
-			printf(" ssthresh:%d", info->tcpi_snd_ssthresh);
+			s.ssthresh = info->tcpi_snd_ssthresh;
 
 		rtt = (double) info->tcpi_rtt;
 		if (tb[INET_DIAG_VEGASINFO]) {
@@ -1710,89 +1868,51 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 				= RTA_DATA(tb[INET_DIAG_VEGASINFO]);
 
 			if (vinfo->tcpv_enabled &&
-			    vinfo->tcpv_rtt && vinfo->tcpv_rtt != 0x7fffffff)
+					vinfo->tcpv_rtt && vinfo->tcpv_rtt != 0x7fffffff)
 				rtt =  vinfo->tcpv_rtt;
 		}
 
 		if (tb[INET_DIAG_DCTCPINFO]) {
+			struct dctcpstat *dctcp = malloc(sizeof(struct
+						dctcpstat));
+
 			const struct tcp_dctcp_info *dinfo
 				= RTA_DATA(tb[INET_DIAG_DCTCPINFO]);
 
-			if (dinfo->dctcp_enabled) {
-				printf(" ce_state %u alpha %u ab_ecn %u ab_tot %u",
-				       dinfo->dctcp_ce_state, dinfo->dctcp_alpha,
-				       dinfo->dctcp_ab_ecn, dinfo->dctcp_ab_tot);
-			} else {
-				printf(" fallback_mode");
-			}
+			dctcp->enabled	= !!dinfo->dctcp_enabled;
+			dctcp->ce_state = dinfo->dctcp_ce_state;
+			dctcp->alpha	= dinfo->dctcp_alpha;
+			dctcp->ab_ecn	= dinfo->dctcp_ab_ecn;
+			dctcp->ab_tot	= dinfo->dctcp_ab_tot;
+			s.dctcp		= dctcp;
 		}
 
 		if (rtt > 0 && info->tcpi_snd_mss && info->tcpi_snd_cwnd) {
-			printf(" send %sbps",
-			       sprint_bw(b1, (double) info->tcpi_snd_cwnd *
-					 (double) info->tcpi_snd_mss * 8000000.
-					 / rtt));
+			s.send_bps = (double) info->tcpi_snd_cwnd *
+				(double)info->tcpi_snd_mss * 8000000. / rtt;
 		}
 
-		if (info->tcpi_last_data_sent)
-			printf(" lastsnd:%u", info->tcpi_last_data_sent);
-
-		if (info->tcpi_last_data_recv)
-			printf(" lastrcv:%u", info->tcpi_last_data_recv);
-
-		if (info->tcpi_last_ack_recv)
-			printf(" lastack:%u", info->tcpi_last_ack_recv);
-
 		if (info->tcpi_pacing_rate &&
-		    info->tcpi_pacing_rate != ~0ULL) {
-			printf(" pacing_rate %sbps",
-				sprint_bw(b1, info->tcpi_pacing_rate * 8.));
+				info->tcpi_pacing_rate != ~0ULL) {
+			s.pacing_rate = info->tcpi_pacing_rate * 8.;
 
 			if (info->tcpi_max_pacing_rate &&
-			    info->tcpi_max_pacing_rate != ~0ULL)
-				printf("/%sbps",
-					sprint_bw(b1, info->tcpi_max_pacing_rate * 8.));
-		}
-		if (info->tcpi_unacked)
-			printf(" unacked:%u", info->tcpi_unacked);
-		if (info->tcpi_retrans || info->tcpi_total_retrans)
-			printf(" retrans:%u/%u", info->tcpi_retrans,
-			       info->tcpi_total_retrans);
-		if (info->tcpi_lost)
-			printf(" lost:%u", info->tcpi_lost);
-		if (info->tcpi_sacked && r->idiag_state != SS_LISTEN)
-			printf(" sacked:%u", info->tcpi_sacked);
-		if (info->tcpi_fackets)
-			printf(" fackets:%u", info->tcpi_fackets);
-		if (info->tcpi_reordering != 3)
-			printf(" reordering:%d", info->tcpi_reordering);
-		if (info->tcpi_rcv_rtt)
-			printf(" rcv_rtt:%g", (double) info->tcpi_rcv_rtt/1000);
-		if (info->tcpi_rcv_space)
-			printf(" rcv_space:%d", info->tcpi_rcv_space);
-
-	}
-}
-
-static char *proto_name(int protocol)
-{
-	switch (protocol) {
-	case IPPROTO_UDP:
-		return "udp";
-	case IPPROTO_TCP:
-		return "tcp";
-	case IPPROTO_DCCP:
-		return "dccp";
+					info->tcpi_max_pacing_rate != ~0ULL)
+				s.pacing_rate_max = info->tcpi_max_pacing_rate * 8.;
+		}
+		tcp_stats_print(&s);
+		if (s.dctcp)
+			free(s.dctcp);
+		if (s.cong_alg)
+			free(s.cong_alg);
 	}
-
-	return "???";
 }
 
 static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 {
 	struct rtattr * tb[INET_DIAG_MAX+1];
 	struct inet_diag_msg *r = NLMSG_DATA(nlh);
-	struct tcpstat s;
+	struct tcpstat s = {};
 
 	parse_rtattr(tb, INET_DIAG_MAX, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
@@ -1801,52 +1921,28 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 	s.local.family = s.remote.family = r->idiag_family;
 	s.lport = ntohs(r->id.idiag_sport);
 	s.rport = ntohs(r->id.idiag_dport);
+	s.wq = r->idiag_wqueue;
+	s.rq = r->idiag_rqueue;
+	s.timer = r->idiag_timer;
+	s.timeout = r->idiag_expires;
+	s.retrans = r->idiag_retrans;
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
@@ -1862,13 +1958,13 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
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
 
@@ -2189,53 +2285,19 @@ outerr:
 
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
 
-	if ((p = strchr(loc, ':')) == NULL)
+	if (proc_inet_split_line(line, &loc, &rem, &data))
 		return -1;
-	p[5] = 0;
-	rem = p+6;
-
-	if ((p = strchr(rem, ':')) == NULL)
-		return -1;
-	p[5] = 0;
-	data = p+6;
 
-	do {
-		int state = (data[1] >= 'A') ? (data[1] - 'A' + 10) : (data[1] - '0');
+	int state = (data[1] >= 'A') ? (data[1] - 'A' + 10) : (data[1] - '0');
+	if (!(f->states & (1 << state)))
+		return 0;
 
-		if (!(f->states & (1<<state)))
-			return 0;
-	} while (0);
-
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
@@ -2249,31 +2311,7 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
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
@@ -2283,12 +2321,11 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
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
@@ -2357,7 +2394,6 @@ outerr:
 	} while (0);
 }
 
-
 struct unixstat
 {
 	struct unixstat *next;
@@ -2371,12 +2407,9 @@ struct unixstat
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
