From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] TCP limited slow start
Date: Fri, 2 Jun 2006 18:54:03 -0700
Message-ID: <20060602185403.1549e3c6@localhost.localdomain>
References: <20060602161312.3cb2ea66@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:22745 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932600AbWFCByn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 21:54:43 -0400
To: David Miller <davem@davemloft.net>, John Heffner <jheffner@psc.edu>
In-Reply-To: <20060602161312.3cb2ea66@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rolled my sleeve's up and gave this a try...

This is a implementation of Sally Floyd's Limited Slow Start
for Large Congestion Windows.

Summary from RFC:
   Limited Slow-Start introduces a parameter, "max_ssthresh", and
   modifies the slow-start mechanism for values of the congestion window
   where "cwnd" is greater than "max_ssthresh".  That is, during Slow-
   Start, when

      cwnd <= max_ssthresh,

   cwnd is increased by one MSS (MAXIMUM SEGMENT SIZE) for every
   arriving ACK (acknowledgement) during slow-start, as is always the
   case.  During Limited Slow-Start, when

      max_ssthresh < cwnd <= ssthresh,

   the invariant is maintained so that the congestion window is
   increased during slow-start by at most max_ssthresh/2 MSS per round-
   trip time.  This is done as follows:

      For each arriving ACK in slow-start:
        If (cwnd <= max_ssthresh)
           cwnd += MSS;
        else
           K = int(cwnd/(0.5 max_ssthresh));
           cwnd += int(MSS/K);

   Thus, during Limited Slow-Start the window is increased by 1/K MSS
   for each arriving ACK, for K = int(cwnd/(0.5 max_ssthresh)), instead
   of by 1 MSS as in standard slow-start [RFC2581].

---

 Documentation/networking/ip-sysctl.txt |    8 +++++-
 include/linux/sysctl.h                 |    1 +
 include/net/tcp.h                      |    1 +
 net/ipv4/sysctl_net_ipv4.c             |    8 ++++++
 net/ipv4/tcp_cong.c                    |   46 ++++++++++++++++++++------------
 net/ipv4/tcp_input.c                   |    1 +
 6 files changed, 47 insertions(+), 18 deletions(-)

0884f45c9f21c50dd9117b2fc02bf5436be3c3bf
diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f12007b..9869298 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -103,9 +103,15 @@ TCP variables: 
 
 tcp_abc - INTEGER
 	Controls Appropriate Byte Count defined in RFC3465. If set to
-	0 then does congestion avoid once per ack. 1 is conservative
+	0 then does congestion avoid once per ack. 1 (default) is conservative
 	value, and 2 is more agressive.
 
+tcp_limited_ssthresh - INTEGER
+	Controls the increase of the congestion window during slow start as
+	defined in RFC3742. The purpose is to slow the growth of the congestion
+	window on high delay networks where agressive growth can cause losses
+	of 1000's of packets. Default is 100 packets.
+
 tcp_syn_retries - INTEGER
 	Number of times initial SYNs for an active TCP connection attempt
 	will be retransmitted. Should not be higher than 255. Default value
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 76eaeff..a455165 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -403,6 +403,7 @@ enum
  	NET_TCP_MTU_PROBING=113,
 	NET_TCP_BASE_MSS=114,
 	NET_IPV4_TCP_WORKAROUND_SIGNED_WINDOWS=115,
+	NET_TCP_LIMITED_SSTHRESH=116,
 };
 
 enum {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 575636f..3a14861 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -225,6 +225,7 @@ extern int sysctl_tcp_abc;
 extern int sysctl_tcp_mtu_probing;
 extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
+extern int sysctl_tcp_limited_ssthresh;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 6b6c3ad..d1358d3 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -688,6 +688,14 @@ #endif
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{
+		.ctl_name	= NET_TCP_LIMITED_SSTHRESH,
+		.procname	= "tcp_max_ssthresh",
+		.data		= &sysctl_tcp_limited_ssthresh,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 857eefc..a27c792 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -180,25 +180,37 @@ int tcp_set_congestion_control(struct so
  */
 void tcp_slow_start(struct tcp_sock *tp)
 {
-	if (sysctl_tcp_abc) {
-		/* RFC3465: Slow Start
-		 * TCP sender SHOULD increase cwnd by the number of
-		 * previously unacknowledged bytes ACKed by each incoming
-		 * acknowledgment, provided the increase is not more than L
-		 */
-		if (tp->bytes_acked < tp->mss_cache)
-			return;
-
-		/* We MAY increase by 2 if discovered delayed ack */
-		if (sysctl_tcp_abc > 1 && tp->bytes_acked > 2*tp->mss_cache) {
-			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd++;
-		}
+	/* RFC3465: Apprpriate Byte Coute Slow Start
+	 * TCP sender SHOULD increase cwnd by the number of
+	 * previously unacknowledged bytes ACKed by each incoming
+	 * acknowledgment, provided the increase is not more than L
+	 */
+	if (sysctl_tcp_abc && tp->bytes_acked < tp->mss_cache)
+		return;
+
+	/* RFC3742: limited slow start
+	 * the window is increased by 1/K MSS for each arriving ACK, 
+	 * for K = int(cwnd/(0.5 max_ssthresh))
+	 */
+	if (sysctl_tcp_limited_ssthresh
+	    && tp->snd_cwnd > sysctl_tcp_limited_ssthresh) {
+		u32 k = max(tp->snd_cwnd / (sysctl_tcp_limited_ssthresh >> 1), 1U);
+ 		if (++tp->snd_cwnd_cnt >= k) {
+ 			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+ 				tp->snd_cwnd++;
+ 			tp->snd_cwnd_cnt = 0;
+ 		} 
+	} else {
+		/* ABC: We MAY increase by 2 if discovered delayed ack */
+		if (sysctl_tcp_abc > 1
+		    && tp->bytes_acked > 2*tp->mss_cache 
+		    && tp->snd_cwnd < tp->snd_cwnd_clamp)
+			tp->snd_cwnd++;
+
+		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+			tp->snd_cwnd++;
 	}
 	tp->bytes_acked = 0;
-
-	if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-		tp->snd_cwnd++;
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 718d0f2..80dd5e4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -90,6 +90,7 @@ int sysctl_tcp_nometrics_save;
 
 int sysctl_tcp_moderate_rcvbuf = 1;
 int sysctl_tcp_abc = 1;
+int sysctl_tcp_limited_ssthresh = 100;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
-- 
1.3.3

