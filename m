From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] common code for generating tcp_info
Date: Fri, 4 Jun 2004 15:37:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040604153749.5d8a13b9@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There are two places tcp_diag (netlink) and getsockopt, both with almost
the same code to generate tcp_info from the current socket state.

Patch agains 2.6.7-rc2

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	2004-06-04 15:35:55 -07:00
+++ b/net/ipv4/tcp.c	2004-06-04 15:35:55 -07:00
@@ -2498,56 +2498,11 @@
 		break;
 	case TCP_INFO: {
 		struct tcp_info info;
-		u32 now = tcp_time_stamp;
 
 		if (get_user(len, optlen))
 			return -EFAULT;
-		info.tcpi_state = sk->sk_state;
-		info.tcpi_ca_state = tp->ca_state;
-		info.tcpi_retransmits = tp->retransmits;
-		info.tcpi_probes = tp->probes_out;
-		info.tcpi_backoff = tp->backoff;
-		info.tcpi_options = 0;
-		if (tp->tstamp_ok)
-			info.tcpi_options |= TCPI_OPT_TIMESTAMPS;
-		if (tp->sack_ok)
-			info.tcpi_options |= TCPI_OPT_SACK;
-		if (tp->wscale_ok) {
-			info.tcpi_options |= TCPI_OPT_WSCALE;
-			info.tcpi_snd_wscale = tp->snd_wscale;
-			info.tcpi_rcv_wscale = tp->rcv_wscale;
-		} else {
-			info.tcpi_snd_wscale = 0;
-			info.tcpi_rcv_wscale = 0;
-		}
-		if (tp->ecn_flags & TCP_ECN_OK)
-			info.tcpi_options |= TCPI_OPT_ECN;
 
-		info.tcpi_rto = (1000000 * tp->rto) / HZ;
-		info.tcpi_ato = (1000000 * tp->ack.ato) / HZ;
-		info.tcpi_snd_mss = tp->mss_cache_std;
-		info.tcpi_rcv_mss = tp->ack.rcv_mss;
-
-		info.tcpi_unacked = tp->packets_out;
-		info.tcpi_sacked = tp->sacked_out;
-		info.tcpi_lost = tp->lost_out;
-		info.tcpi_retrans = tp->retrans_out;
-		info.tcpi_fackets = tp->fackets_out;
-
-		info.tcpi_last_data_sent = ((now - tp->lsndtime) * 1000) / HZ;
-		info.tcpi_last_ack_sent = 0;
-		info.tcpi_last_data_recv = ((now -
-					     tp->ack.lrcvtime) * 1000) / HZ;
-		info.tcpi_last_ack_recv = ((now - tp->rcv_tstamp) * 1000) / HZ;
-
-		info.tcpi_pmtu = tp->pmtu_cookie;
-		info.tcpi_rcv_ssthresh = tp->rcv_ssthresh;
-		info.tcpi_rtt = ((1000000 * tp->srtt) / HZ) >> 3;
-		info.tcpi_rttvar = ((1000000 * tp->mdev) / HZ) >> 2;
-		info.tcpi_snd_ssthresh = tp->snd_ssthresh;
-		info.tcpi_snd_cwnd = tp->snd_cwnd;
-		info.tcpi_advmss = tp->advmss;
-		info.tcpi_reordering = tp->reordering;
+		tcp_get_info(sk, &info);
 
 		len = min_t(unsigned int, len, sizeof(info));
 		if (put_user(len, optlen))
diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	2004-06-04 15:35:55 -07:00
+++ b/net/ipv4/tcp_diag.c	2004-06-04 15:35:55 -07:00
@@ -41,6 +41,58 @@
    rta->rta_len = rtalen;                   \
    RTA_DATA(rta); })
 
+/* Return information about state of tcp endpoint in API format. */
+void tcp_get_info(struct sock *sk, struct tcp_info *info)
+{
+	struct tcp_opt *tp = tcp_sk(sk);
+	u32 now = tcp_time_stamp;
+
+	memset(info, 0, sizeof(*info));
+
+	info->tcpi_state = sk->sk_state;
+	info->tcpi_ca_state = tp->ca_state;
+	info->tcpi_retransmits = tp->retransmits;
+	info->tcpi_probes = tp->probes_out;
+	info->tcpi_backoff = tp->backoff;
+
+	if (tp->tstamp_ok)
+		info->tcpi_options |= TCPI_OPT_TIMESTAMPS;
+	if (tp->sack_ok)
+		info->tcpi_options |= TCPI_OPT_SACK;
+	if (tp->wscale_ok) {
+		info->tcpi_options |= TCPI_OPT_WSCALE;
+		info->tcpi_snd_wscale = tp->snd_wscale;
+		info->tcpi_rcv_wscale = tp->rcv_wscale;
+	} 
+
+	if (tp->ecn_flags&TCP_ECN_OK)
+		info->tcpi_options |= TCPI_OPT_ECN;
+
+	info->tcpi_rto = (1000000*tp->rto)/HZ;
+	info->tcpi_ato = (1000000*tp->ack.ato)/HZ;
+	info->tcpi_snd_mss = tp->mss_cache;
+	info->tcpi_rcv_mss = tp->ack.rcv_mss;
+
+	info->tcpi_unacked = tp->packets_out;
+	info->tcpi_sacked = tp->sacked_out;
+	info->tcpi_lost = tp->lost_out;
+	info->tcpi_retrans = tp->retrans_out;
+	info->tcpi_fackets = tp->fackets_out;
+
+	info->tcpi_last_data_sent = ((now - tp->lsndtime)*1000)/HZ;
+	info->tcpi_last_data_recv = ((now - tp->ack.lrcvtime)*1000)/HZ;
+	info->tcpi_last_ack_recv = ((now - tp->rcv_tstamp)*1000)/HZ;
+
+	info->tcpi_pmtu = tp->pmtu_cookie;
+	info->tcpi_rcv_ssthresh = tp->rcv_ssthresh;
+	info->tcpi_rtt = ((1000000*tp->srtt)/HZ)>>3;
+	info->tcpi_rttvar = ((1000000*tp->mdev)/HZ)>>2;
+	info->tcpi_snd_ssthresh = tp->snd_ssthresh;
+	info->tcpi_snd_cwnd = tp->snd_cwnd;
+	info->tcpi_advmss = tp->advmss;
+	info->tcpi_reordering = tp->reordering;
+}
+
 static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
 			int ext, u32 pid, u32 seq)
 {
@@ -150,55 +202,8 @@
 		minfo->tcpdiag_tmem = atomic_read(&sk->sk_wmem_alloc);
 	}
 
-	if (info) {
-		u32 now = tcp_time_stamp;
-
-		info->tcpi_state = sk->sk_state;
-		info->tcpi_ca_state = tp->ca_state;
-		info->tcpi_retransmits = tp->retransmits;
-		info->tcpi_probes = tp->probes_out;
-		info->tcpi_backoff = tp->backoff;
-		info->tcpi_options = 0;
-		if (tp->tstamp_ok)
-			info->tcpi_options |= TCPI_OPT_TIMESTAMPS;
-		if (tp->sack_ok)
-			info->tcpi_options |= TCPI_OPT_SACK;
-		if (tp->wscale_ok) {
-			info->tcpi_options |= TCPI_OPT_WSCALE;
-			info->tcpi_snd_wscale = tp->snd_wscale;
-			info->tcpi_rcv_wscale = tp->rcv_wscale;
-		} else {
-			info->tcpi_snd_wscale = 0;
-			info->tcpi_rcv_wscale = 0;
-		}
-		if (tp->ecn_flags&TCP_ECN_OK)
-			info->tcpi_options |= TCPI_OPT_ECN;
-
-		info->tcpi_rto = (1000000*tp->rto)/HZ;
-		info->tcpi_ato = (1000000*tp->ack.ato)/HZ;
-		info->tcpi_snd_mss = tp->mss_cache;
-		info->tcpi_rcv_mss = tp->ack.rcv_mss;
-
-		info->tcpi_unacked = tp->packets_out;
-		info->tcpi_sacked = tp->sacked_out;
-		info->tcpi_lost = tp->lost_out;
-		info->tcpi_retrans = tp->retrans_out;
-		info->tcpi_fackets = tp->fackets_out;
-
-		info->tcpi_last_data_sent = ((now - tp->lsndtime)*1000)/HZ;
-		info->tcpi_last_ack_sent = 0;
-		info->tcpi_last_data_recv = ((now - tp->ack.lrcvtime)*1000)/HZ;
-		info->tcpi_last_ack_recv = ((now - tp->rcv_tstamp)*1000)/HZ;
-
-		info->tcpi_pmtu = tp->pmtu_cookie;
-		info->tcpi_rcv_ssthresh = tp->rcv_ssthresh;
-		info->tcpi_rtt = ((1000000*tp->srtt)/HZ)>>3;
-		info->tcpi_rttvar = ((1000000*tp->mdev)/HZ)>>2;
-		info->tcpi_snd_ssthresh = tp->snd_ssthresh;
-		info->tcpi_snd_cwnd = tp->snd_cwnd;
-		info->tcpi_advmss = tp->advmss;
-		info->tcpi_reordering = tp->reordering;
-	}
+	if (info) 
+		tcp_get_info(sk, info);
 
 	if (vinfo) {
 		vinfo->tcpv_enabled = tp->vegas.doing_vegas_now;
