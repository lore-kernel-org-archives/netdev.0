From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH 03/10] ss: removed obsolet fmt functions
Date: Mon, 10 Aug 2015 01:13:19 +0200
Message-ID: <1439162006-11421-4-git-send-email-matthias.tafelmeier@gmx.net>
References: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:65165 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588AbbHIXNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2015 19:13:49 -0400
In-Reply-To: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those functions are obsoleted since the new fmt handler mechanism
subsumes their tasks. Rendundancy would be contradictory to
the new mechanism.

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 misc/ss.c | 190 --------------------------------------------------------------
 1 file changed, 190 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 3d31b81..e241b2f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -647,43 +647,6 @@ static const char *sstate_namel[] = {
 	[SS_CLOSING] = "closing",
 };
 
-static void sock_state_print(struct sockstat *s, const char *sock_name)
-{
-	if (netid_width)
-		printf("%-*s ", netid_width, sock_name);
-	if (state_width)
-		printf("%-*s ", state_width, sstate_name[s->state]);
-
-	printf("%-6d %-6d ", s->rq, s->wq);
-}
-
-static void sock_details_print(struct sockstat *s)
-{
-	if (s->uid)
-		printf(" uid:%u", s->uid);
-
-	printf(" ino:%u", s->ino);
-	printf(" sk:%llx", s->sk);
-}
-
-static void sock_addr_print_width(int addr_len, const char *addr, char *delim,
-		int port_len, const char *port, const char *ifname)
-{
-	if (ifname) {
-		printf("%*s%%%s%s%-*s ", addr_len, addr, ifname, delim,
-				port_len, port);
-	}
-	else {
-		printf("%*s%s%-*s ", addr_len, addr, delim, port_len, port);
-	}
-}
-
-static void sock_addr_print(const char *addr, char *delim, const char *port,
-		const char *ifname)
-{
-	sock_addr_print_width(addr_width, addr, delim, serv_width, port, ifname);
-}
-
 static const char *tmr_name[] = {
 	"off",
 	"on",
@@ -693,33 +656,6 @@ static const char *tmr_name[] = {
 	"unknown"
 };
 
-static const char *print_ms_timer(int timeout)
-{
-	static char buf[64];
-	int secs, msecs, minutes;
-	if (timeout < 0)
-		timeout = 0;
-	secs = timeout/1000;
-	minutes = secs/60;
-	secs = secs%60;
-	msecs = timeout%1000;
-	buf[0] = 0;
-	if (minutes) {
-		msecs = 0;
-		snprintf(buf, sizeof(buf)-16, "%dmin", minutes);
-		if (minutes > 9)
-			secs = 0;
-	}
-	if (secs) {
-		if (secs > 9)
-			msecs = 0;
-		sprintf(buf+strlen(buf), "%d%s", secs, msecs ? "." : "sec");
-	}
-	if (msecs)
-		sprintf(buf+strlen(buf), "%03dms", msecs);
-	return buf;
-}
-
 struct scache *rlist;
 
 static void init_service_resolver(void)
@@ -1482,122 +1418,6 @@ static int proc_inet_split_line(char *line, char **loc, char **rem, char **data)
 	return 0;
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
-static void tcp_stats_print(struct tcpstat *s)
-{
-	char b1[64];
-
-	if (s->has_ts_opt)
-		printf(" ts");
-	if (s->has_sack_opt)
-		printf(" sack");
-	if (s->has_ecn_opt)
-		printf(" ecn");
-	if (s->has_ecnseen_opt)
-		printf(" ecnseen");
-	if (s->has_fastopen_opt)
-		printf(" fastopen");
-	if (s->cong_alg[0])
-		printf(" %s", s->cong_alg);
-	if (s->has_wscale_opt)
-		printf(" wscale:%d,%d", s->snd_wscale, s->rcv_wscale);
-	if (s->rto)
-		printf(" rto:%g", s->rto);
-	if (s->backoff)
-		printf(" backoff:%u", s->backoff);
-	if (s->rtt)
-		printf(" rtt:%g/%g", s->rtt, s->rttvar);
-	if (s->ato)
-		printf(" ato:%g", s->ato);
-
-	if (s->qack)
-		printf(" qack:%d", s->qack);
-	if (s->qack & 1)
-		printf(" bidir");
-
-	if (s->mss)
-		printf(" mss:%d", s->mss);
-	if (s->cwnd)
-		printf(" cwnd:%d", s->cwnd);
-	if (s->ssthresh)
-		printf(" ssthresh:%d", s->ssthresh);
-
-	if (s->bytes_acked)
-		printf(" bytes_acked:%llu", s->bytes_acked);
-	if (s->bytes_received)
-		printf(" bytes_received:%llu", s->bytes_received);
-	if (s->segs_out)
-		printf(" segs_out:%u", s->segs_out);
-	if (s->segs_in)
-		printf(" segs_in:%u", s->segs_in);
-
-	if (s->dctcp && s->dctcp->enabled) {
-		struct dctcpstat *dctcp = s->dctcp;
-
-		printf(" dctcp:(ce_state:%u,alpha:%u,ab_ecn:%u,ab_tot:%u)",
-				dctcp->ce_state, dctcp->alpha, dctcp->ab_ecn,
-				dctcp->ab_tot);
-	} else if (s->dctcp) {
-		printf(" dctcp:fallback_mode");
-	}
-
-	if (s->send_bps)
-		printf(" send %sbps", sprint_bw(b1, s->send_bps));
-	if (s->lastsnd)
-		printf(" lastsnd:%u", s->lastsnd);
-	if (s->lastrcv)
-		printf(" lastrcv:%u", s->lastrcv);
-	if (s->lastack)
-		printf(" lastack:%u", s->lastack);
-
-	if (s->pacing_rate) {
-		printf(" pacing_rate %sbps", sprint_bw(b1, s->pacing_rate));
-		if (s->pacing_rate_max)
-				printf("/%sbps", sprint_bw(b1,
-							s->pacing_rate_max));
-	}
-
-	if (s->unacked)
-		printf(" unacked:%u", s->unacked);
-	if (s->retrans || s->retrans_total)
-		printf(" retrans:%u/%u", s->retrans, s->retrans_total);
-	if (s->lost)
-		printf(" lost:%u", s->lost);
-	if (s->sacked && s->ss.state != SS_LISTEN)
-		printf(" sacked:%u", s->sacked);
-	if (s->fackets)
-		printf(" fackets:%u", s->fackets);
-	if (s->reordering != 3)
-		printf(" reordering:%d", s->reordering);
-	if (s->rcv_rtt)
-		printf(" rcv_rtt:%g", s->rcv_rtt);
-	if (s->rcv_space)
-		printf(" rcv_space:%d", s->rcv_space);
-}
-
-static void tcp_timer_print(struct tcpstat *s)
-{
-	if (s->timer) {
-		if (s->timer > 4)
-			s->timer = 5;
-		printf(" timer:(%s,%s,%d)",
-				tmr_name[s->timer],
-				print_ms_timer(s->timeout),
-				s->retrans);
-	}
-}
-
 static int tcp_show_line(char *line, const struct filter *f, int family)
 {
 	int rto = 0, ato = 0;
@@ -2692,16 +2512,6 @@ static int packet_stats_print(struct sockstat *s, const struct filter *f)
 	return 0;
 }
 
-static void packet_show_ring(struct packet_diag_ring *ring)
-{
-	printf("blk_size:%d", ring->pdr_block_size);
-	printf(",blk_nr:%d", ring->pdr_block_nr);
-	printf(",frm_size:%d", ring->pdr_frame_size);
-	printf(",frm_nr:%d", ring->pdr_frame_nr);
-	printf(",tmo:%d", ring->pdr_retire_tmo);
-	printf(",features:0x%x", ring->pdr_features);
-}
-
 static int packet_show_sock(const struct sockaddr_nl *addr,
 		struct nlmsghdr *nlh, void *arg)
 {
-- 
1.9.1
