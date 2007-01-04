From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Thu, 4 Jan 2007 19:29:30 +1100
Message-ID: <20070104082930.GB7006@gondor.apana.org.au>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104080351.GA1740@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, greearb@candelatech.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1933 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932325AbXADI3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 03:29:45 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
Content-Disposition: inline
In-Reply-To: <20070104080351.GA1740@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 04, 2007 at 09:03:51AM +0100, Jarek Poplawski wrote:
> 
> I doubt this is the right solution. It certainly
> could fix this particular situation but my main
> point was packets shouldn't get into kernel
> receive queues with skb->dev not IFF_UP.

I think you misunderstood.  The device certainly is IFF_UP.  What
happens is that the multicast spin locks are set up too late:

        /* Account for reference dev->ip_ptr */
        in_dev_hold(in_dev);
        rcu_assign_pointer(dev->ip_ptr, in_dev);

As soon as we set ip_ptr incoming packets can cause the multicast
locks to be taken.

#ifdef CONFIG_SYSCTL
        devinet_sysctl_register(in_dev, &in_dev->cnf);
#endif

In fact the back trace shows that we get a packet during the
sysctl registration.

        ip_mc_init_dev(in_dev);

However, the spin locks are not setup until this point.  This is
exactly what David's patch fixes.

        if (dev->flags & IFF_UP)
                ip_mc_up(in_dev);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
