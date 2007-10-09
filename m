From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Tue, 9 Oct 2007 12:00:38 +0800
Message-ID: <20071009040037.GA15981@gondor.apana.org.au>
References: <20070917.190133.79431533.davem@davemloft.net> <1190083728.4237.59.camel@localhost> <1190208832.4259.6.camel@localhost> <20070919.090937.32177545.davem@davemloft.net> <1190255605.4818.25.camel@localhost> <1190256183.4818.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1302 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750722AbXJIEAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 00:00:54 -0400
Content-Disposition: inline
In-Reply-To: <1190256183.4818.28.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 10:43:03PM -0400, jamal wrote:
>
> [NET_SCHED] explict hold dev tx lock
> 
> For N cpus, with full throttle traffic on all N CPUs, funneling traffic
> to the same ethernet device, the devices queue lock is contended by all
> N CPUs constantly. The TX lock is only contended by a max of 2 CPUS.
> In the current mode of operation, after all the work of entering the
> dequeue region, we may endup aborting the path if we are unable to get
> the tx lock and go back to contend for the queue lock. As N goes up,
> this gets worse.
> 
> The changes in this patch result in a small increase in performance
> with a 4CPU (2xdual-core) with no irq binding. Both e1000 and tg3
> showed similar behavior;

OK, after waking up a bit more I now have another question :)

Both of the drivers you've tested here are special.  Firstly
e1000 is lockless so there is no contention here at all.  On
the other hand tg3 doesn't take the TX lock on the clean-up
path unless the queue has been stopped.

In other words both drivers only take the TX lock on xmit so
this patch makes very little difference to them.

What I'm worried about is would we see worse behaviour with
drivers that do all their TX clean-up with the TX lock held
(which would cause qdisc_restart to spin while this is happening)?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
