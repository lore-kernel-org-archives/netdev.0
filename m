From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Thu, 21 Aug 2008 08:27:21 +0000
Message-ID: <20080821082721.GA3135@ff.dom.local>
References: <20080821061024.GA721@gondor.apana.org.au> <20080821064941.GA2764@ff.dom.local> <20080821071634.GA1269@gondor.apana.org.au> <20080821.005250.117238212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:37531 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbYHUI12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 04:27:28 -0400
Received: by fk-out-0910.google.com with SMTP id 18so560802fkq.5
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 01:27:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821.005250.117238212.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 12:52:50AM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 21 Aug 2008 17:16:34 +1000
> 
> > Actually, why do we even keep a netdev_queue pointer in a qdisc?
> > A given qdisc can be used by multiple queues (which is why the
> > lock was moved into the qdisc in the first place).
> > 
> > How about keeping a pointer directly to the root qdisc plus a
> > pointer to the netdev (which seems to be the only other use for
> > qdisc->dev_queue)? That way there won't be any confusion as to
> > whether we want the sleeping or non-sleeping qdisc.

Probably it's too early in the morning, so I would prefer to see some
code... It seems exchanging the qdisc to &noop_qdisc needs such a
direct root dev_queue access, e.g. we want to get in dev_queue_xmit()
&noop_qdisc as fast as possible during deactivation. On the other hand
we need to check for __QDISC_STATE_DEACTIVATED to know the state of
a "real" qdisc.

BTW, it looks like currently we do this wrong: if it's really
dectivated we're checking &noop_qdisc for this...

> 
> Not a bad idea at all.
> 
> The reason it's there is a left-over from earlier designs of my
> multiqueue stuff, I thought we'd always multiplex the qdiscs to be
> per-queue.  But once Patrick showed me we couldn't do that, we now
> have shared qdiscs.
> 
> If I get a chance I'll work on this.  But to be honest given
> Linus's temperment right now we're only going to be able to
> merge one-liners to fix these kinds of problems and anything
> more serious is going to be for net-next-2.6 only.

I think definitely some changes are needed here for the future,
but of course no need to experiment with our stable -rc now.

Jarek P.
