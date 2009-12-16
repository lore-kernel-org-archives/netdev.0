From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Wed, 16 Dec 2009 12:37:26 +0200
Message-ID: <20091216103726.GB28541@redhat.com>
References: <1260312605.19229.8.camel@w-sridhar.beaverton.ibm.com> <20091215144252.GA7465@gondor.apana.org.au> <20091215233226.GA27129@redhat.com> <200912161507.53805.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11001 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348AbZLPKkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2009 05:40:19 -0500
Content-Disposition: inline
In-Reply-To: <200912161507.53805.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 03:07:53PM +1030, Rusty Russell wrote:
> On Wed, 16 Dec 2009 10:02:27 am Michael S. Tsirkin wrote:
> > Right. Hmm. So for this to work we'll need to
> > 1. Free skb upon interrupt instead of
> >    waiting for the next xmit call
> > 2. Add API to query free ring capacity
> > 
> > Rusty, sounds like a good plan?
> 
> Well, the query stuff is not too bad, but I can't completely convince myself
> it's race-free.  We don't want to do locking.

We do not want to lock TX? For performance?
It might not be a problem: interrupts only start
to be enabled when we are running out of space on TX,
so this is a kind of slow path anyway now.

If necessary, we can also only do this range check
if netif_tx_queue_stopped.

> A NAPI-style solution seems cleaner, and I'm testing that now.

Hmm, as you say separately, this might not be 2.6.32 material though.
Maybe a simply capacity check will be safe enough for 2.6.32.

> > We could also extend host to delay interrupt
> > until there is sufficient TX capacity
> > but of course we also need to support
> > old hosts as well.
> 
> Xen does this, and I rejected it in favor of simple enable/disable
> flags in the original virtio design.  It was probably wrong: while the
> guest can enable on a "few remaining" heuristic, it's going to have
> latency.  The host can do a more timely decision.
> 
> There's nothing stopping the Host from doing this heuristic today, of
> course: the DISABLE flag is advisory only.

Heh, but this might hurt performance on guests that do
assume it's used correctly. A new feature might be cleaner?

>  But let's check the limitations
> of the guest-enable approach first?

Sure.

> Thanks,
> Rusty.
