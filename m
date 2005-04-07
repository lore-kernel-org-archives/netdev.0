From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH] Too aggressive cwnd backoff
Date: Thu, 7 Apr 2005 19:41:46 +0300
Message-ID: <20050407164146.GA6479@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The cwnd backoff is down in two places and drops the cwnd to one quarter
instead of to one half.

On congestion events we reset tp->ssthresh to the result of
tcp_recalc_ssthresh. This cuts the cwnd by half for (New)Reno or to
a convoluted calculation for BIC.

Later we will call tcp_cwnd_down for each ack and reduce the cwnd by one
for every two acks.

However, in tcp_cwnd_down we will not stop reducing the cwnd until we
get to limit which is set to tp->ssthresh/2.

The provided patch will set limit to tp->ssthresh. This was the original
behaviour in some older version of Linux.

The patch is against 2.6.11

Signed-Off-By: Baruch Even <baruch@ev-en.org>

 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: 2.6.11-perf/net/ipv4/tcp_input.c
===================================================================
--- 2.6.11-perf.orig/net/ipv4/tcp_input.c
+++ 2.6.11-perf/net/ipv4/tcp_input.c
@@ -1621,7 +1621,7 @@ static void tcp_cwnd_down(struct tcp_soc
 	 */
 
 	if (!(limit = tcp_westwood_bw_rttmin(tp)))
-		limit = tp->snd_ssthresh/2;
+		limit = tp->snd_ssthresh;
 
 	tp->snd_cwnd_cnt = decr&1;
 	decr >>= 1;
