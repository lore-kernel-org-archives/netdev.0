From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] tcp: cleanup of cwnd initialization in
 tcp_init_metrics()
Date: Thu, 23 Dec 2010 10:23:38 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012231022430.16569@pobox.suse.cz>
References: <alpine.LNX.2.00.1012221938030.16569@pobox.suse.cz>  <1293092671.2679.44.camel@edumazet-laptop>  <alpine.LNX.2.00.1012231002310.16569@pobox.suse.cz> <1293095663.7789.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vojtech Pavlik <vojtech@suse.cz>,
	=?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293095663.7789.3.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Dec 2010, Eric Dumazet wrote:

> > > > Commit 86bcebafc5e7f5 ("tcp: fix >2 iw selection") fixed a case when 
> > > > congestion window initialization has been mistakenly omitted by 
> > > > introducing cwnd label and putting backwards jump from the end of the 
> > > > function.
> > > > 
> > > > This makes the code unnecessarily tricky to read and understand on a first 
> > > > sight.
> > > > 
> > > > Shuffle the code around a little bit to make it more obvious.
> > > 
> > > Well in fine you have
> > > 
> > > 	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tstamp)
> > > 		goto reset;
> > > 	goto out;
> > > reset:
> > > 
> > > Is that really more obvious ? ;)
> > 
> > To me it seems much more obvious than goto from the very end of the 
> > function somewhere into the middle and returning from there, but 
> > definitely a matter of personal taste.
> > 
> 
> You dont understand what I said. Please read again.
> 
> To me I prefer you _finish_ the cleanup so that we have :
> 
> 	if (some condition) {
> reset:
> 	}
> 
> out:
> 
> You remove two "goto" in the process.
> 
> Is that clear now ?

Right, that's even better. Updated patch below.


From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] tcp: cleanup of cwnd initialization in tcp_init_metrics()

Commit 86bcebafc5e7f5 ("tcp: fix >2 iw selection") fixed a case
when congestion window initialization has been mistakenly omitted
by introducing cwnd label and putting backwards goto from the
end of the function.

This makes the code unnecessarily tricky to read and understand
on a first sight.

Shuffle the code around a little bit to make it more obvious.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 net/ipv4/tcp_input.c |   29 ++++++++++++-----------------
 1 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6d8ab1c..3d1e015 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -912,25 +912,20 @@ static void tcp_init_metrics(struct sock *sk)
 		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
 	}
 	tcp_set_rto(sk);
-	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tstamp)
-		goto reset;
-
-cwnd:
-	tp->snd_cwnd = tcp_init_cwnd(tp, dst);
-	tp->snd_cwnd_stamp = tcp_time_stamp;
-	return;
-
+	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tstamp) {
 reset:
-	/* Play conservative. If timestamps are not
-	 * supported, TCP will fail to recalculate correct
-	 * rtt, if initial rto is too small. FORGET ALL AND RESET!
-	 */
-	if (!tp->rx_opt.saw_tstamp && tp->srtt) {
-		tp->srtt = 0;
-		tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_INIT;
-		inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
+		/* Play conservative. If timestamps are not
+		 * supported, TCP will fail to recalculate correct
+		 * rtt, if initial rto is too small. FORGET ALL AND RESET!
+		 */
+		if (!tp->rx_opt.saw_tstamp && tp->srtt) {
+			tp->srtt = 0;
+			tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_INIT;
+			inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
+		}
 	}
-	goto cwnd;
+	tp->snd_cwnd = tcp_init_cwnd(tp, dst);
+	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
 static void tcp_update_reordering(struct sock *sk, const int metric,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
