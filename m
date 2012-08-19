From: Julian Anastasov <ja@ssi.bg>
Subject: Re: IPv4 BUG: held lock freed!
Date: Sun, 19 Aug 2012 19:51:41 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208191647340.1893@ja.ssi.bg>
References: <20120818021918.GA6499@localhost> <1345380682.5158.201.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	David Miller <davem@davemloft.net>,
	networking <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51698 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331Ab2HSQuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Aug 2012 12:50:16 -0400
In-Reply-To: <1345380682.5158.201.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 19 Aug 2012, Eric Dumazet wrote:

> Hmm, this looks like sk_reset_timer() is called on a socket, and timer
> triggers _before_ the sock_hold()
> 
> So the timer handler decrements sk_refcnt to 0 and calls sk_free()
> 
> Its probably a bug introduced (or uncovered) by commit 6f458dfb40 (tcp:
> improve latencies of timer triggered events)
> 
> I always found sk_reset_timer() a bit racy...
> 
> void sk_reset_timer(struct sock *sk, struct timer_list* timer,
>                     unsigned long expires)
> {
> 	if (!mod_timer(timer, expires))
> 		sock_hold(sk); // MIGHT BE TOO LATE
> }
> 
> Following should be safer...

	Above code is fine as long as caller holds reference.

	Your change for tcp_release_cb looks correct.

	Also, may be tcp_v4_mtu_reduced is missing a check
for TCP_CLOSE state? tcp_v6_mtu_reduced already has such
check.

> void sk_reset_timer(struct sock *sk, struct timer_list* timer,
>                     unsigned long expires)
> {

	This should not be needed:

> 	sock_hold(sk);
> 	if (mod_timer(timer, expires))
> 		sock_put(sk);
> }

Regards

--
Julian Anastasov <ja@ssi.bg>
