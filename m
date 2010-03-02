From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Tue, 2 Mar 2010 19:27:54 +0800
Message-ID: <20100302112754.GA1513@gondor.apana.org.au>
References: <1267017564.3973.790.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, yoshfuji@linux-ipv6.org,
	nakam@linux-ipv6.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45462 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750811Ab0CBL2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 06:28:20 -0500
Content-Disposition: inline
In-Reply-To: <1267017564.3973.790.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2010 at 08:19:24AM -0500, jamal wrote:
> 
> Apologies for the shotgun email but this has been perplexing me for
> sometime and i am worried the the patch i have is a band-aid (although
> it fixes the problem), so here's a long-winded description..

First of all I don't think patch fixes the root (or rather, roots)
of the problem.
 
> 1)In the connect() stage, in the slow path a route cache is
> created with the rth->fl.fl4_src of 0.0.0.0...
> ==> policy->bundles is empty, so we do a lookup, fail, create
> one.. (remember rth->fl.fl4_src of 0.0.0.0 at this stage and
> thats what we end storing in the bundle/xdst for later comparison
> instead of the skb's fl)

So this is root number 1.  When this stuff was first written this
case simply wasn't possible.  So I think the question we need to
ask here is can we get a valid address there at the connect stage?

After all, for non-IPsec connect(2)s, you do get a valid IP address.
So I don't see why the IPsec case should be different.

Creating a bundle with a zero source address is just a hack to
make connect(2) succeed immediately.  AFAICS getting a valid IP
address can also be done without waiting for the whole IPsec state
to be created.

Of course if anybody is still interested we could also revisit
the neighbouresque queueing idea.

> 2)ping sends a packet (does a sendmsg) 
> ==> xfrm_find_bundle() ends up comparing skb's->fl (non-zero
> fl->fl4_src) with what we stored from #1b. Fails.
> ==> we create a new bundle at attach the old one at the end of it.
> ...and now policy->bundles has two xdst entries

This is the way it's supposed to work.

> 3) Repeat #2, and now we have 3 xdsts in policy bundles

This is what I don't understand.  The code is supposed to look
at every bundle attached to the policy.  So why doesn't it find
the one we created at step #2?

In conclusion, I think we have two problems, with the second
one being the most immediate cause of your symptoms.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
