From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP] Move tcp_get_info out of tcp_diag
Date: Tue, 26 Oct 2004 14:57:01 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026045701.GA10365@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Dxnq1zWXvFF0Q93v"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

In my recent foray into tcp_diag I discovered some ugly looking ifdef's
on CONFIG_IPV6 that'll break when IPv6 is built as a module.  In order
to fix it, we need to allow tcp_diag to be built as a module.

So here is a start.  This patch move tcp_get_info from tcp_diag.c into
the site of the other caller, tcp.c.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/tcp.c 1.81 vs edited =====
--- 1.81/net/ipv4/tcp.c	2004-10-04 07:26:12 +10:00
+++ edited/net/ipv4/tcp.c	2004-10-26 14:46:13 +10:00
@@ -2095,6 +2095,63 @@
 	return err;
 }
 
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
+	info->tcpi_rto = jiffies_to_usecs(tp->rto);
+	info->tcpi_ato = jiffies_to_usecs(tp->ack.ato);
+	info->tcpi_snd_mss = tp->mss_cache_std;
+	info->tcpi_rcv_mss = tp->ack.rcv_mss;
+
+	info->tcpi_unacked = tcp_get_pcount(&tp->packets_out);
+	info->tcpi_sacked = tcp_get_pcount(&tp->sacked_out);
+	info->tcpi_lost = tcp_get_pcount(&tp->lost_out);
+	info->tcpi_retrans = tcp_get_pcount(&tp->retrans_out);
+	info->tcpi_fackets = tcp_get_pcount(&tp->fackets_out);
+
+	info->tcpi_last_data_sent = jiffies_to_msecs(now - tp->lsndtime);
+	info->tcpi_last_data_recv = jiffies_to_msecs(now - tp->ack.lrcvtime);
+	info->tcpi_last_ack_recv = jiffies_to_msecs(now - tp->rcv_tstamp);
+
+	info->tcpi_pmtu = tp->pmtu_cookie;
+	info->tcpi_rcv_ssthresh = tp->rcv_ssthresh;
+	info->tcpi_rtt = jiffies_to_usecs(tp->srtt)>>3;
+	info->tcpi_rttvar = jiffies_to_usecs(tp->mdev)>>2;
+	info->tcpi_snd_ssthresh = tp->snd_ssthresh;
+	info->tcpi_snd_cwnd = tp->snd_cwnd;
+	info->tcpi_advmss = tp->advmss;
+	info->tcpi_reordering = tp->reordering;
+
+	info->tcpi_rcv_rtt = jiffies_to_usecs(tp->rcv_rtt_est.rtt)>>3;
+	info->tcpi_rcv_space = tp->rcvq_space.space;
+
+	info->tcpi_total_retrans = tp->total_retrans;
+}
+
 int tcp_getsockopt(struct sock *sk, int level, int optname, char __user *optval,
 		   int __user *optlen)
 {
===== net/ipv4/tcp_diag.c 1.23 vs edited =====
--- 1.23/net/ipv4/tcp_diag.c	2004-10-21 14:20:29 +10:00
+++ edited/net/ipv4/tcp_diag.c	2004-10-26 14:45:51 +10:00
@@ -52,63 +52,6 @@
    rta->rta_len = rtalen;                   \
    RTA_DATA(rta); })
 
-/* Return information about state of tcp endpoint in API format. */
-void tcp_get_info(struct sock *sk, struct tcp_info *info)
-{
-	struct tcp_opt *tp = tcp_sk(sk);
-	u32 now = tcp_time_stamp;
-
-	memset(info, 0, sizeof(*info));
-
-	info->tcpi_state = sk->sk_state;
-	info->tcpi_ca_state = tp->ca_state;
-	info->tcpi_retransmits = tp->retransmits;
-	info->tcpi_probes = tp->probes_out;
-	info->tcpi_backoff = tp->backoff;
-
-	if (tp->tstamp_ok)
-		info->tcpi_options |= TCPI_OPT_TIMESTAMPS;
-	if (tp->sack_ok)
-		info->tcpi_options |= TCPI_OPT_SACK;
-	if (tp->wscale_ok) {
-		info->tcpi_options |= TCPI_OPT_WSCALE;
-		info->tcpi_snd_wscale = tp->snd_wscale;
-		info->tcpi_rcv_wscale = tp->rcv_wscale;
-	} 
-
-	if (tp->ecn_flags&TCP_ECN_OK)
-		info->tcpi_options |= TCPI_OPT_ECN;
-
-	info->tcpi_rto = jiffies_to_usecs(tp->rto);
-	info->tcpi_ato = jiffies_to_usecs(tp->ack.ato);
-	info->tcpi_snd_mss = tp->mss_cache_std;
-	info->tcpi_rcv_mss = tp->ack.rcv_mss;
-
-	info->tcpi_unacked = tcp_get_pcount(&tp->packets_out);
-	info->tcpi_sacked = tcp_get_pcount(&tp->sacked_out);
-	info->tcpi_lost = tcp_get_pcount(&tp->lost_out);
-	info->tcpi_retrans = tcp_get_pcount(&tp->retrans_out);
-	info->tcpi_fackets = tcp_get_pcount(&tp->fackets_out);
-
-	info->tcpi_last_data_sent = jiffies_to_msecs(now - tp->lsndtime);
-	info->tcpi_last_data_recv = jiffies_to_msecs(now - tp->ack.lrcvtime);
-	info->tcpi_last_ack_recv = jiffies_to_msecs(now - tp->rcv_tstamp);
-
-	info->tcpi_pmtu = tp->pmtu_cookie;
-	info->tcpi_rcv_ssthresh = tp->rcv_ssthresh;
-	info->tcpi_rtt = jiffies_to_usecs(tp->srtt)>>3;
-	info->tcpi_rttvar = jiffies_to_usecs(tp->mdev)>>2;
-	info->tcpi_snd_ssthresh = tp->snd_ssthresh;
-	info->tcpi_snd_cwnd = tp->snd_cwnd;
-	info->tcpi_advmss = tp->advmss;
-	info->tcpi_reordering = tp->reordering;
-
-	info->tcpi_rcv_rtt = jiffies_to_usecs(tp->rcv_rtt_est.rtt)>>3;
-	info->tcpi_rcv_space = tp->rcvq_space.space;
-
-	info->tcpi_total_retrans = tp->total_retrans;
-}
-
 static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
 			int ext, u32 pid, u32 seq)
 {

--Dxnq1zWXvFF0Q93v--
