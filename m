From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Thu, 15 Oct 2009 14:41:34 +0200
Message-ID: <20091015124134.GB1073@1wt.eu>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli> <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50254 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758206AbZJOMmT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 08:42:19 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0910151120340.2879@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Julian,

On Thu, Oct 15, 2009 at 11:47:51AM +0300, Julian Anastasov wrote:
(...)
> 	If one changes TCP_DEFER_ACCEPT to create socket it
> will save wakeups but not resources. I'm wondering if the
> behavior should be changed at all. For me the options are two:
> 
> a) you want to save resources: use TCP_DEFER_ACCEPT. To help
> proxies use large values for TCP_SYNCNT and TCP_DEFER_ACCEPT.
> 
> b) you can live with wakeups and many sockets: do not use
> TCP_DEFER_ACCEPT. Suitable for servers using short timeouts
> for first request.

and c) you want to avoid wakeups as much as possible and you'd like
to drop just one empty ACK packet, so that as soon as you accept a
an HTTP connection, you can read the request without polling at all.

Right now I'm able to process a complete HTTP request without
registering the any FD in epoll *at all* for most requests if the first
two ACKs are close enough and the server responds quickly. This saves a
substantial amount of CPU cycles. Epoll is fast, but calling epoll_ctl()
100000 times a second still has a measurable cost. Doing an accept() on
an empty connection implies this cost. Waiting for data always saves this
cost, but causes the undesirable side effects that have been reported.
Waiting for data just a few milliseconds is enough to save this cost
99.99% of the time, just as skipping the first empty packet.

Since you're saying that updating the value is wrong when it's used as
a flag, would a patch to implement a specific option for this usage be
accepted ?  Either by passing a negative value to TCP_DEFER_ACCEPT, or
by using another flag ?

Thanks,
Willy

