From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Sun, 18 Jan 2015 22:43:35 +0200
Message-ID: <1421613815-6635-4-git-send-email-vadim4j@gmail.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:40698 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbbARUyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 15:54:14 -0500
Received: by mail-we0-f173.google.com with SMTP id q58so28296921wes.4
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 12:54:13 -0800 (PST)
In-Reply-To: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 362 +++++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 231 insertions(+), 131 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 40439b3..73097b2 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -691,24 +691,59 @@ static const char *sstate_namel[] = {
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
-	unsigned int	iface;
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
@@ -1471,7 +1506,7 @@ static void inet_stats_print(struct tcpstat *s, int protocol)
 			printf(" timer:(%s,%s,%d)",
 			       tmr_name[s->timer],
 			       print_ms_timer(s->timeout),
-			       s->retrs);
+			       s->retrans);
 		}
 	}
 
@@ -1538,8 +1573,107 @@ static int proc_inet_split_line(char *line, char **loc, char **rem, char **data)
 	return 0;
 }
 
+static char *sprint_bandw(char *buf, double bw)
+{
+	return sprint_num(buf, bw, false);
+}
+
+static char *sprint_bytes(char *buf, uint64_t bytes)
+{
+	if (!show_human) {
+		sprintf(buf, "%"PRIu64, bytes);
+		return buf;
+	}
+
+	return sprint_num(buf, bytes, false);
+}
+
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
+		printf(" send %sbps", sprint_bandw(b1, s->send_bps));
+	if (s->lastsnd)
+		printf(" lastsnd:%u", s->lastsnd);
+	if (s->lastrcv)
+		printf(" lastrcv:%u", s->lastrcv);
+	if (s->lastack)
+		printf(" lastack:%u", s->lastack);
+
+	if (s->pacing_rate) {
+		printf(" pacing_rate %sbps", sprint_bandw(b1, s->pacing_rate));
+		if (s->pacing_rate_max)
+				printf("/%sbps", sprint_bandw(b1,
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
 static int tcp_show_line(char *line, const struct filter *f, int family)
 {
+	int rto = 0, ato = 0;
 	struct tcpstat s = {};
 	char *loc, *rem, *data;
 	char opt[256];
@@ -1561,22 +1695,27 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
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
 
-	s.retrs = s.timer != 1 ? s.probes : s.retrs;
-	s.timeout = (s.timeout * 1000 + hz - 1) / hz;
+	s.retrans   = s.timer != 1 ? s.probes : s.retrans;
+	s.timeout   = (s.timeout * 1000 + hz - 1) / hz;
+	s.ato	    = (double)ato / hz;
+	s.qack	   /= 2;
+	s.rto	    = (double)rto;
+	s.ssthresh  = s.ssthresh == -1 ? 0 : s.ssthresh;
+	s.rto	    = s.rto != 3 * hz  ? s.rto / hz : 0;
 
 	inet_stats_print(&s, IPPROTO_TCP);
 
@@ -1589,20 +1728,8 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 			printf(" opt:\"%s\"", opt);
 	}
 
-	if (show_tcpinfo) {
-		if (s.rto && s.rto != 3 * hz)
-			printf(" rto:%g", (double)s.rto / hz);
-		if (s.ato)
-			printf(" ato:%g", (double)s.ato / hz);
-		if (s.cwnd != 2)
-			printf(" cwnd:%d", s.cwnd);
-		if (s.ssthresh != -1)
-			printf(" ssthresh:%d", s.ssthresh);
-		if (s.qack / 2)
-			printf(" qack:%d", s.qack / 2);
-		if (s.qack & 1)
-			printf(" bidir");
-	}
+	if (show_tcpinfo)
+		tcp_stats_print(&s);
 
 	printf("\n");
 	return 0;
@@ -1634,21 +1761,6 @@ outerr:
 	return ferror(fp) ? -1 : 0;
 }
 
-static char *sprint_bandw(char *buf, double bw)
-{
-	return sprint_num(buf, bw, false);
-}
-
-static char *sprint_bytes(char *buf, uint64_t bytes)
-{
-	if (!show_human) {
-		sprintf(buf, "%"PRIu64, bytes);
-		return buf;
-	}
-
-	return sprint_num(buf, bytes, false);
-}
-
 static void print_skmeminfo(struct rtattr *tb[], int attrtype)
 {
 	char buf[64];
@@ -1688,11 +1800,13 @@ static void print_skmeminfo(struct rtattr *tb[], int attrtype)
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
 
@@ -1709,39 +1823,49 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
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
@@ -1749,67 +1873,43 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
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
-			       sprint_bandw(b1, (double) info->tcpi_snd_cwnd *
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
-				sprint_bandw(b1, info->tcpi_pacing_rate * 8.));
+				info->tcpi_pacing_rate != ~0ULL) {
+			s.pacing_rate = info->tcpi_pacing_rate * 8.;
 
 			if (info->tcpi_max_pacing_rate &&
-			    info->tcpi_max_pacing_rate != ~0ULL)
-				printf("/%sbps",
-					sprint_bandw(b1, info->tcpi_max_pacing_rate * 8.));
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
+					info->tcpi_max_pacing_rate != ~0ULL)
+				s.pacing_rate_max = info->tcpi_max_pacing_rate * 8.;
+		}
+		tcp_stats_print(&s);
+		if (s.dctcp)
+			free(s.dctcp);
+		if (s.cong_alg)
+			free(s.cong_alg);
 	}
 }
 
@@ -1830,7 +1930,7 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 	s.rq = r->idiag_rqueue;
 	s.timer = r->idiag_timer;
 	s.timeout = r->idiag_expires;
-	s.retrs = r->idiag_retrans;
+	s.retrans = r->idiag_retrans;
 	s.ino = r->idiag_inode;
 	s.uid = r->idiag_uid;
 	s.iface = r->id.idiag_if;
-- 
2.1.3
