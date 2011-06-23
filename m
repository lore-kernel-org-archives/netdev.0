From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: unintended ipv4 broadcast policy change
Date: Thu, 23 Jun 2011 08:41:34 +0800
Message-ID: <20110623004134.GA22314@gondor.apana.org.au>
References: <20110622.163935.2248705300315908767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40292 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758008Ab1FWAlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 20:41:37 -0400
Content-Disposition: inline
In-Reply-To: <20110622.163935.2248705300315908767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2011 at 04:39:35PM -0700, David Miller wrote:
> 
> The context is that I'm looking into cleaning up up the mess we have
> wrt. DHCP listening on packet sockets and (in some cases) seeing every
> packet that hits the system.
> 
> Anyways, back in 2007 this commit was made:
> 
> commit 8030f54499925d073a88c09f30d5d844fb1b3190
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Thu Feb 22 01:53:47 2007 +0900
> 
>     [IPV4] devinet: Register inetdev earlier.

It appears that the intention was to allow sysctl control prior
to device open.

> So now every net device registered has inetdev_init() called on it.
> 
> This has a subtle policy side effect that has some interesting
> implications.  The route input slow path has this check:
> 
> 	/* IP on this device is disabled. */
> 
> 	if (!in_dev)
> 		goto out;
> 
> But now this will never, ever, be true.

If we ever wanted to disable IPv4 we could always add a sysctl
for that, just like IPv6.

> Which means that previously we would not accept even broadcast
> or multicast packets on an interface that hasn't had at least
> one IP address configured.
>
> Now we will.

This indeed is an unintended side-effect.

> I think we have a hard decision to make.  One option is to
> fix the input routing check, by changing it to test if the
> ipv4 address list is empty.
> 
> The second option is to remove the check entirely and keep the
> new behavior.

We could also add a disable_ipv4 sysctl and then replace this
check in the routing code with a disable_ipv4 check at the very
top of the IPv4 receive path, just like IPv6.

> This subtle new behavior is interesting because it means that
> a DHCP client could be implemented entirely with plain UDP
> sockets.

Yes this is indeed possible.  However, for compatibility purposes
I'm not sure whether we can safely rely on this new behaviour.
Maybe if we add the disable_ipv4 sysctl we can use it to signal
the presence of this new behaviour.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
