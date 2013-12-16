From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/3] xfrm: Increase the garbage collector threshold
Date: Mon, 16 Dec 2013 12:51:45 +0100
Message-ID: <20131216115145.GH31491@secunet.com>
References: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
 <1383294107-7509-3-git-send-email-steffen.klassert@secunet.com>
 <1386686323.22947.26.camel@sakura.staff.proxad.net>
 <20131213101203.GO31491@secunet.com>
 <1386951209.25449.61.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55495 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605Ab3LPLvr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 06:51:47 -0500
Content-Disposition: inline
In-Reply-To: <1386951209.25449.61.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 05:13:29PM +0100, Maxime Bizon wrote:
> 
> On Fri, 2013-12-13 at 11:12 +0100, Steffen Klassert wrote:
> 
> > Can you please be a bit more precise with your problem description?
> 
> yes sorry I wasn't clear.
> 
> I have a problem with an even simpler workload that the one using apache
> bench in the original bug report.
> 
> I am using ipsec transport mode between two hosts and just run this on
> one side:
> 
>   while :; do wget -O /dev/null http://remote_host/; done
> 
> I was surprised to see it fails after only 1024 requests (ENOBUF on
> connect), and how long I had to wait to be able to do new requests.
> 
> After debugging I saw that the xfrm gc was called but was not able to
> release anything.
> 
> after running "ip route flush cache", which forces all ipv4 dst entries
> to be released, suddenly the xfrm gc had something to free, and xfrm
> entry count went to zero.

Well, "ip route flush cache" bumps the rt_genid what marks all
routes as invalid. The xfrm garbage collector will notice this
on the next run and deletes all invalid cached routes.

Garbage collecting is different from flushing, it only removes
stale routes and keeps everything that was used recently. That's
the whole point of this caching, we cache recently used IPsec
routes to avoid a slow path lookup.

> 
> So if it is correct that once a ipv4 dst entry exists, the xfrm entry
> cannot be gc-ed, then we need to make sure we allow more xfrm entries to
> be allocated than ipv4 dst.

No, we don't cache plain ipv4 routes, we cache only IPsec routes.
The original ipv4 dst_entry is cached together with the xfrm dst_entry
as a xfrm bundle at the IPsec flow cache, so it does not make sense to
ensure something like that.
