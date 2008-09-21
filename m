From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Sun, 21 Sep 2008 03:18:29 -0700 (PDT)
Message-ID: <20080921.031829.86500526.davem@davemloft.net>
References: <20080920234843.GA2531@ami.dom.local>
	<20080920.223538.130375517.davem@davemloft.net>
	<20080921095705.GA2551@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47944
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751383AbYIUKSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 06:18:41 -0400
In-Reply-To: <20080921095705.GA2551@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 21 Sep 2008 11:57:06 +0200

> On Sat, Sep 20, 2008 at 10:35:38PM -0700, David Miller wrote:
> > That _never_ happens in any sane driver.  That case is for buggy
> > devices that do not maintain their TX queue state properly.  And
> > in fact it's a case for which I advocate we just drop the packet
> > instead of requeueing.  :-)
> 
> OK, then let's do it! Why I can't see this in your new patch?

I'm trying to address one thing at a time.  I really want to
also encourage an audit of the drivers that trigger that condition,
and I fear if I put the packet drop in there it might not happen :)

> BTW, since this problem is strongly conected with the requeuing
> policy, I wonder why you seemingly lost interest in this. I tried to
> advocate for your simple, one level requeuing, but also Herbert's
> peek, and Alexander's early detection, after some polish(!), should
> make this initial test meaningless.

Yes, thanks for reminding me about the the multiq qdisc head of line
blocking thing.

I really don't like the requeue/peek patches, because they resulted in
so much code duplication in the CBQ and other classful qdiscs.

Alexander's patch has similar code duplication issues.

Since I've seen the code duplication happen twice, I begin to suspect
we're attacking the implementation (not the idea) from the wrong
angle.

It might make review easier if we first attack the classful qdiscs and
restructure their internal implementation into seperate "pick" and a
"remove" operations.  Of course, initially it'll just be that
->dequeue is implemented as pick+remove.

On a similar note I think all of the ->requeue() uses can die
trivially except for the netem usage.

> > and I am still very much convinced that
> > this was the original regression cause that made me put that TXQ
> > state test back into qdisc_run().
> 
> I doubt this: I've just looked at this Andrew Gallatin's report, and
> there is really a lot of net_tx_action, __netif_schedule, and guess
> what: pfifo_fast_requeue in this oprofile...

I see.
