From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 18:55:04 +1000
Message-ID: <20080819085504.GB29038@gondor.apana.org.au>
References: <20080818.210701.80578862.davem@davemloft.net> <20080819064609.GA4376@ff.dom.local> <20080819072316.GA4878@gondor.apana.org.au> <20080819073558.GD4376@ff.dom.local> <20080819074606.GA5261@gondor.apana.org.au> <20080819075623.GE4376@ff.dom.local> <20080819080557.GA17977@gondor.apana.org.au> <20080819081713.GF4376@ff.dom.local> <20080819082355.GA28869@gondor.apana.org.au> <20080819083909.GG4376@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35142 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752675AbYHSIzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:55:09 -0400
Content-Disposition: inline
In-Reply-To: <20080819083909.GG4376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 08:39:09AM +0000, Jarek Poplawski wrote:
>
> > Well I can't vouch for every single qdisc in the tree.  However,
> > what I can say is that as long as they respect the rules I outlined
> > earlier with regards to holding the root qdisc lock when deleting
> > or using children, then they'll work as expected.
> > 
> > You're definitely welcome to audit the qdiscs to make sure that
> > they are obeying the rules.
> 
> That's my point - is there really a reason do this change without such
> an audit if we are not forced at the moment? (I'd remind this way of
> doing things was entirely legal according to comments.) I doubt, I'm
> the right person for auditing this but as I said I'll have a look,
> especially when there will be lack of those fascinating oopses and
> warnings around.

No you misunderstood my point.  I wasn't saying that I'm not confident
that our qdiscs obey the rules, but rather that if any of them didn't,
then they're buggy and should be fixed.

In fact we're not really adding anything new here, the qdiscs were
not accessed under RCU uniformly.  If you go back in the tree prior
to the multi-qdisc stuff, you'll find that only dev_queue_xmit works
under RCU.  qdisc_restart does not and therefore deferring the
destruction to RCU is pointless anyway.

So in fact we've already been relying on the fact that by the time
qdisc_destroy comes about nobody on the read side (i.e., the packet
transmission path) should have a reference to it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
