From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/3) tcp - diagnostics enhancement for westwood
Date: Mon, 27 Sep 2004 11:21:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927112118.4c376303@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Enhancement to tcp diagnostics used by ss command.
* use jiffies_to_usecs/msec instead of hardcode math
* report bandwidth for Westwood

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	2004-09-27 10:27:00 -07:00
+++ b/net/ipv4/tcp_diag.c	2004-09-27 10:27:00 -07:00
@@ -41,6 +41,12 @@
    rta->rta_len = rtalen;                   \
    RTA_DATA(rta); })
 
+static inline unsigned int jiffies_to_usecs(const unsigned long j)
+{
+	return 1000*jiffies_to_msecs(j);
+}
+
+
 /* Return information about state of tcp endpoint in API format. */
 void tcp_get_info(struct sock *sk, struct tcp_info *info)
 {
@@ -68,8 +74,8 @@
 	if (tp->ecn_flags&TCP_ECN_OK)
 		info->tcpi_options |= TCPI_OPT_ECN;
 
-	info->tcpi_rto = (1000000*tp->rto)/HZ;
-	info->tcpi_ato = (1000000*tp->ack.ato)/HZ;
+	info->tcpi_rto = jiffies_to_usecs(tp->rto);
+	info->tcpi_ato = jiffies_to_usecs(tp->ack.ato);
 	info->tcpi_snd_mss = tp->mss_cache_std;
 	info->tcpi_rcv_mss = tp->ack.rcv_mss;
 
@@ -79,20 +85,20 @@
 	info->tcpi_retrans = tcp_get_pcount(&tp->retrans_out);
 	info->tcpi_fackets = tcp_get_pcount(&tp->fackets_out);
 
-	info->tcpi_last_data_sent = ((now - tp->lsndtime)*1000)/HZ;
-	info->tcpi_last_data_recv = ((now - tp->ack.lrcvtime)*1000)/HZ;
-	info->tcpi_last_ack_recv = ((now - tp->rcv_tstamp)*1000)/HZ;
+	info->tcpi_last_data_sent = jiffies_to_msecs(now - tp->lsndtime);
+	info->tcpi_last_data_recv = jiffies_to_msecs(now - tp->ack.lrcvtime);
+	info->tcpi_last_ack_recv = jiffies_to_msecs(now - tp->rcv_tstamp);
 
 	info->tcpi_pmtu = tp->pmtu_cookie;
 	info->tcpi_rcv_ssthresh = tp->rcv_ssthresh;
-	info->tcpi_rtt = ((1000000*tp->srtt)/HZ)>>3;
-	info->tcpi_rttvar = ((1000000*tp->mdev)/HZ)>>2;
+	info->tcpi_rtt = jiffies_to_usecs(tp->srtt)>>3;
+	info->tcpi_rttvar = jiffies_to_usecs(tp->mdev)>>2;
 	info->tcpi_snd_ssthresh = tp->snd_ssthresh;
 	info->tcpi_snd_cwnd = tp->snd_cwnd;
 	info->tcpi_advmss = tp->advmss;
 	info->tcpi_reordering = tp->reordering;
 
-	info->tcpi_rcv_rtt = ((1000000*tp->rcv_rtt_est.rtt)/HZ)>>3;
+	info->tcpi_rcv_rtt = jiffies_to_usecs(tp->rcv_rtt_est.rtt)>>3;
 	info->tcpi_rcv_space = tp->rcvq_space.space;
 }
 
@@ -116,7 +122,8 @@
 		if (ext & (1<<(TCPDIAG_INFO-1)))
 			info = TCPDIAG_PUT(skb, TCPDIAG_INFO, sizeof(*info));
 		
-		if (tcp_is_vegas(tp) && (ext & (1<<(TCPDIAG_VEGASINFO-1))))
+		if ((tcp_is_westwood(tp) || tcp_is_vegas(tp))
+		    && (ext & (1<<(TCPDIAG_VEGASINFO-1))))
 			vinfo = TCPDIAG_PUT(skb, TCPDIAG_VEGASINFO, sizeof(*vinfo));
 	}
 	r->tcpdiag_family = sk->sk_family;
@@ -209,10 +216,17 @@
 		tcp_get_info(sk, info);
 
 	if (vinfo) {
-		vinfo->tcpv_enabled = tp->vegas.doing_vegas_now;
-		vinfo->tcpv_rttcnt = tp->vegas.cntRTT;
-		vinfo->tcpv_rtt = tp->vegas.baseRTT;
-		vinfo->tcpv_minrtt = tp->vegas.minRTT;
+		if (tcp_is_vegas(tp)) {
+			vinfo->tcpv_enabled = tp->vegas.doing_vegas_now;
+			vinfo->tcpv_rttcnt = tp->vegas.cntRTT;
+			vinfo->tcpv_rtt = jiffies_to_usecs(tp->vegas.baseRTT);
+			vinfo->tcpv_minrtt = jiffies_to_usecs(tp->vegas.minRTT);
+		} else {
+			vinfo->tcpv_enabled = 0;
+			vinfo->tcpv_rttcnt = 0;
+			vinfo->tcpv_rtt = jiffies_to_usecs(tp->westwood.rtt);
+			vinfo->tcpv_minrtt = jiffies_to_usecs(tp->westwood.rtt_min);
+		}
 	}
 
 	nlh->nlmsg_len = skb->tail - b;
