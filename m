From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Broken commit: [NETFILTER]: ipt_REJECT: remove largely duplicate route_reverse function
Date: Wed, 29 Nov 2006 17:51:46 +1100
Message-ID: <20061129065146.GA20681@gondor.apana.org.au>
References: <20061128.204440.39160464.davem@davemloft.net> <E1GpHVB-0005CB-00@gondolin.me.apana.org.au> <20061128.210416.59658806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, khc@pm.waw.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:15121 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S935214AbWK2GwR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 01:52:17 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061128.210416.59658806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 28, 2006 at 09:04:16PM -0800, David Miller wrote:
>
> > Definitely.  I'm not sure whether 48 is enough even for recursive
> > tunnels.  This should really just be a hint.  It's OK to spend a
> > bit of time reallocating skb's if it's too small, but it's not OK
> > to die.
> 
> The recursive tunnel case is handled by the PMTU reductions
> in the route, isn't it?

Oh I wasn't suggesting that the current code is broken.

I'm just emphasising that LL_MAX_HEADER is by no means the *maximum*
header size in a Linux system.  Anybody should be able to load a
new NIC module with a hard header size exceeding what LL_MAX_HEADER
is and the system should still function (albeit slower since every
packet sent down that device has to be reallocated).

In particular, nested tunnels is one such device which anybody can
construct without writing a kernel module.

As to getting rid of those ifdefs, here is one idea.  We keep a
read-mostly global variable that represents the actual current
maximum LL header size.  Everytime a new device appears (or if
its hard header size changes) we update this variable if needed.

Hmm, we don't actually update the hard header size should the
underlying device change for tunnels.  Good thing the tunnels
only use that as a hint and reallocate if necessary :)

This is not optimal in that it never decreases, but it's certainly
better than a compile-time constant (e.g., people using distribution
kernels don't necessarily use tunnels).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
