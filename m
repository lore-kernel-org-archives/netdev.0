From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][TCP] YeAH-TCP: limited slow start exported function
Date: Thu, 22 Feb 2007 00:32:39 -0800 (PST)
Message-ID: <20070222.003239.131918460.davem@davemloft.net>
References: <45D97DC9.1030305@gmail.com>
	<45DA0FD6.9020404@psc.edu>
	<20070222.002704.34758758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: angelo.castellani@gmail.com, netdev@vger.kernel.org,
	andrea.baiocchi@uniroma1.it, francesco@net.infocom.uniroma1.it
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38849
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751498AbXBVIck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 03:32:40 -0500
In-Reply-To: <20070222.002704.34758758.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 22 Feb 2007 00:27:04 -0800 (PST)

> I'll apply this, but could you please also when making suggestions
> like this provide the patch necessary to kill the function added for
> YeaH and the call site in the YeaH algorithm?

Here is how I'm resolving this:

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 2b4142b..5ee79f3 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -310,29 +310,6 @@ void tcp_slow_start(struct tcp_sock *tp)
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
 
-void tcp_limited_slow_start(struct tcp_sock *tp)
-{
-	/* RFC3742: limited slow start
-	 * the window is increased by 1/K MSS for each arriving ACK,
-	 * for K = int(cwnd/(0.5 max_ssthresh))
-	 */
-
-	const int max_ssthresh = 100;
-
-	if (max_ssthresh > 0 && tp->snd_cwnd > max_ssthresh) {
-		u32 k = max(tp->snd_cwnd / (max_ssthresh >> 1), 1U);
-		if (++tp->snd_cwnd_cnt >= k) {
-			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd++;
-			tp->snd_cwnd_cnt = 0;
-		}
-	} else {
-		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-			tp->snd_cwnd++;
-	}
-}
-EXPORT_SYMBOL_GPL(tcp_limited_slow_start);
-
 /*
  * TCP Reno congestion control
  * This is special case used for fallback as well.
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 2d971d1..815e020 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -104,7 +104,7 @@ static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack,
 		return;
 
 	if (tp->snd_cwnd <= tp->snd_ssthresh) {
-		tcp_limited_slow_start(tp);
+		tcp_slow_start(tp);
 	} else if (!yeah->doing_reno_now) {
 		/* Scalable */
 
