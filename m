From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Thu, 22 Apr 2010 10:32:11 +0800
Message-ID: <20100422023211.GA7109@gondor.apana.org.au>
References: <20100420174401.GB1334@midget.suse.cz> <20100421213429.GA2799@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:45664 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754106Ab0DVCcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 22:32:22 -0400
Content-Disposition: inline
In-Reply-To: <20100421213429.GA2799@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 11:34:29PM +0200, Jiri Bohac wrote:
> Hi,
> 
> On Tue, Apr 20, 2010 at 07:44:01PM +0200, Jiri Bohac wrote:
> > What is the reason __ipv6_ifa_notify() calls dst_free() when
> > ip6_del_rt() fails? I don't see a way ip6_del_rt() could fail
> > with the dst still needing to be freed.
> 
> checked again and I still think that if ip6_del_rt() fails,
> ifp->rt must have been freed already. Anybody with a
> counterexample?

I agree with your diagnosis and the two duplicate NDISC messages
scenario sounds plausible.

Anyway, I think the root of the issue is the fact that NDISC is
calling addrconf_dad_failure with no locking whatsoever.  The
latter is not idempotent so some form of locking is needed.

This bug appears to have been around since the very start.

I'll dig deeper to see where we might be able to add some locks.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
