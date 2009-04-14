From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: initial congestion window for connections in the listen queue
Date: Tue, 14 Apr 2009 11:37:08 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0904141118260.10088@wrl-59.cs.helsinki.fi>
References: <200904132346.15783.opurdila@ixiacom.com>
 <20090413.142653.267913010.davem@davemloft.net>
 <Pine.LNX.4.64.0904140051100.9234@wrl-59.cs.helsinki.fi>
 <20090413.145829.97306950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1923818589-1239698228=:10088"
Cc: opurdila@ixiacom.com, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42067 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbZDNIhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 04:37:10 -0400
In-Reply-To: <20090413.145829.97306950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1923818589-1239698228=:10088
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 13 Apr 2009, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 14 Apr 2009 00:54:40 +0300 (EEST)
> 
> > A long-standing feature in tcp_init_metrics() is such that any of its goto 
> > reset prevents call to tcp_init_cwnd(). I never remembered to fix that.
> 
> Grumble, we definitely need to fix that!
> 
> I suspect I added that problem, because tcp_init_metrics() at one
> point couldn't cope with a NULL dst.

I suppose you meant tcp_init_cwnd() here, otherwise this doesn't make much 
sense to me?

> But that is no longer the
> case so I'm pretty sure we can unconditionally go:
> 
> 	tp->snd_cwnd = tcp_init_cwnd(tp, dst);
> 	tp->snd_cwnd_stamp = tcp_time_stamp;
> 
> in the 'reset' path too, right?

At least it compiles... :-) ...I don't see any problems either.

> But note thata even if this reset path is taken, we should still have
> at least the default ->snd_cwnd value of 2.

Right, it wasn't be uninitialized as we get that 2 from elsewhere.

A patch below.

-- 
[PATCH] tcp: fix >2 iw selection

A long-standing feature in tcp_init_metrics() is such that
any of its goto reset prevents call to tcp_init_cwnd().

Compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4872524..00ba37b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -928,6 +928,8 @@ static void tcp_init_metrics(struct sock *sk)
 	tcp_set_rto(sk);
 	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tstamp)
 		goto reset;
+
+cwnd:
 	tp->snd_cwnd = tcp_init_cwnd(tp, dst);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 	return;
@@ -942,6 +944,7 @@ reset:
 		tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_INIT;
 		inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
 	}
+	goto cwnd;
 }
 
 static void tcp_update_reordering(struct sock *sk, const int metric,
-- 
1.5.2.2

---696208474-1923818589-1239698228=:10088--
