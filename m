From: David Miller <davem@davemloft.net>
Subject: Re: [patch] make PACKET_STATISTICS getsockopt report consistently
 between ring and non-ring
Date: Mon, 03 Oct 2011 14:18:41 -0400 (EDT)
Message-ID: <20111003.141841.1153259366783440647.davem@davemloft.net>
References: <4E8628C4.2070504@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932394Ab1JCSSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 14:18:45 -0400
In-Reply-To: <4E8628C4.2070504@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Fri, 30 Sep 2011 16:38:28 -0400

> This is a minor change.
> 
> Up until kernel 2.6.32, getsockopt(fd, SOL_PACKET, PACKET_STATISTICS,
> ...) would return total and dropped packets since its last invocation. The
> introduction of socket queue overflow reporting [1] changed drop
> rate calculation in the normal packet socket path, but not when using a
> packet ring. As a result, the getsockopt now returns different statistics
> depending on the reception method used. With a ring, it still returns the
> count since the last call, as counts are incremented in tpacket_rcv and
> reset in getsockopt. Without a ring, it returns 0 if no drops occurred
> since the last getsockopt and the total drops over the lifespan of
> the socket otherwise. The culprit is this line in packet_rcv, executed
> on a drop:
> 
> drop_n_acct:
>         po->stats.tp_drops = atomic_inc_return(&sk->sk_drops);
> 
> As it shows, the new drop number it taken from the socket drop counter,
> which is not reset at getsockopt. I put together a small example
> that demonstrates the issue [2]. It runs for 10 seconds and overflows
> the queue/ring on every odd second. The reported drop rates are:
> ring: 16, 0, 16, 0, 16, ...
> non-ring: 0, 15, 0, 30, 0, 46, 0, 60, 0 , 74.
> 
> Note how the even ring counts monotonically increase. Because the
> getsockopt adds tp_drops to tp_packets, total counts are similarly
> reported cumulatively. Long story short, reinstating the original code, as
> the below patch does, fixes the issue at the cost of additional per-packet
> cycles. Another solution that does not introduce per-packet overhead
> is be to keep the current data path, record the value of sk_drops at
> getsockopt() at call N in a new field in struct packetsock and subtract
> that when reporting at call N+1. I'll be happy to code that, instead,
> it's just more messy.
> 
> [1] http://patchwork.ozlabs.org/patch/35665/
> [2] http://kernel.googlecode.com/files/test-packetsock-getstatistics.c
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks a lot for fixing this bug.
