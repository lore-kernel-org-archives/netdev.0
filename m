From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [DCCP]: Fix sock_orphan dead lock
Date: Thu, 4 May 2006 12:16:44 -0300
Message-ID: <39e6f6c70605040816l2d39ee75ya39230311b760c6e@mail.gmail.com>
References: <20060427123404.GA20489@gondor.apana.org.au>
	 <20060429111507.GA3077@gondor.apana.org.au>
	 <20060429131320.GA4145@gondor.apana.org.au>
	 <20060503.233223.24747225.davem@davemloft.net>
	 <20060504071750.GA17180@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>, mingo@elte.hu,
	arjan@infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:5003 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S964802AbWEDPQs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 11:16:48 -0400
Received: by ug-out-1314.google.com with SMTP id m3so366937ugc
        for <netdev@vger.kernel.org>; Thu, 04 May 2006 08:16:46 -0700 (PDT)
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060504071750.GA17180@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/4/06, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Wed, May 03, 2006 at 11:32:23PM -0700, David S. Miller wrote:
> >
> > Ok, it took me a while to review this one as verifying such
> > a set of changes is always tricky, but looks good!
>
> Thanks.  It took me quite a while to assure myself that it was OK
> as well :)
>
> Anyway, the same issue affects DCCP (and SCTP too probably).  Here
> is a patch that does the same thing for DCCP.
>
> [DCCP]: Fix sock_orphan dead lock
>
> Calling sock_orphan inside bh_lock_sock in dccp_close can lead to dead
> locks.  For example, the inet_diag code holds sk_callback_lock without
> disabling BH.  If an inbound packet arrives during that admittedly tiny
> window, it will cause a dead lock on bh_lock_sock.  Another possible
> path would be through sock_wfree if the network device driver frees the
> tx skb in process context with BH enabled.
>
> We can fix this by moving sock_orphan out of bh_lock_sock.
>
> The tricky bit is to work out when we need to destroy the socket
> ourselves and when it has already been destroyed by someone else.
>
> By moving sock_orphan before the release_sock we can solve this
> problem.  This is because as long as we own the socket lock its
> state cannot change.
>
> So we simply record the socket state before the release_sock
> and then check the state again after we regain the socket lock.
> If the socket state has transitioned to DCCP_CLOSED in the time being,
> we know that the socket has been destroyed.  Otherwise the socket is
> still ours to keep.
>
> This problem was discoverd by Ingo Molnar using his lock validator.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks Herbert,

Acked-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

- Arnaldo
