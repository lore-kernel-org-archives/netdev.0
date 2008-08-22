From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 20:07:08 +1000
Message-ID: <20080822100708.GA14345@gondor.apana.org.au>
References: <20080821185857.GA2665@ami.dom.local> <20080821222330.GE14521@gondor.apana.org.au> <20080822084931.GB2645@ff.dom.local> <20080822.015513.194132430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50623 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753832AbYHVKHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 06:07:16 -0400
Content-Disposition: inline
In-Reply-To: <20080822.015513.194132430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 01:55:13AM -0700, David Miller wrote:
>
> > > We've got at least the RX and TX queues.  That makes two locks and
> > > two lists.
> > 
> > RX currently doesn't add anything to the list.
> 
> That's correct, currently ingress qdiscs only support a hierarchy of
> single root and that's it.

We seem to be talking about different things.

Yes the ingress hierachy has a single root, i.e., it's a tree.  But
that has nothing to do with what I was talking about.  I'm talking
about the list at dev->rx_queue.qdisc_sleeping->list which is
certainly not guaranteed to be empty.

If you look at qdisc_create you'll find that every time we create
a non-root ingress qdisc we add it to that list (we have to,
otherwise qdisc_lookup doesn't work at all for ingress qdiscs).
So when somebody on the TX side does a qdisc_lookup they may be
walking the RX list without any protection.  Similarly, if somebody
on the ingress side does qdisc_lookup they may walk the TX lists
without protection.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
