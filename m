From: Florian Zumbiehl <florz@florz.de>
Subject: Re: [RESEND][PATCH 1/3] PPPoE: improved hashing routine
Date: Tue, 31 Jul 2007 10:07:19 +0200
Message-ID: <20070731080719.GA12071@florz.florz.dyndns.org>
References: <20070729060423.GA27573@florz.florz.dyndns.org> <20070730.174721.17862949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mostrows@earthlink.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [77.10.169.56] ([77.10.169.56]:47284 "EHLO
	rain.florz.dyndns.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbXGaI4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 04:56:14 -0400
Content-Disposition: inline
In-Reply-To: <20070730.174721.17862949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > -static int hash_item(unsigned long sid, unsigned char *addr)
> > +#if 8%PPPOE_HASH_BITS
> > +#error 8 must be a multiple of PPPOE_HASH_BITS
> > +#endif
> 
> Since PPPOE_HASH_BITS is "4" I would think this check will break the
> build. :-)

Erm, I thought that 8 was 4*2, but maybe I didn't quite understand that
natural numbers business ;-)

> Anyways, I looked at this myself and half of the problem comes from
> the fact that "sid" is passed around as an "unsigned long" throughout
> this entire file yet the thing is just a "__u16".
> 
> So the first thing to fix is to use __u16 consistently for sid values.
> Then the sid hash looks obviously wrong and is easy to fix.
> 
> Then you end up with a hash_item() that simply looks like:
> 
> static unsigned int hash_item(__u16 sid, unsigned char *addr)
> {
> 	unsigned int hash;
> 
> 	hash = (((unsigned int)addr[0] << 24) |
> 		((unsigned int)addr[1] << 16) |
> 		((unsigned int)addr[2] <<  8) |
> 		((unsigned int)addr[3] <<  0));
> 
> 	hash ^= (((unsigned int)addr[4] << 8) |
> 		 ((unsigned int)addr[5] << 0));
> 
> 	hash ^= sid;
> 
> 	return ((hash ^ (hash >> 8) ^ (hash >> 16)) &
> 		(PPPOE_HASH_SIZE - 1));
> }
> 
> which is what I've checked into my tree.

Erm, I'd say this not only produces different results than the old
version, but it also produces "wrong" results, in that it ignores quite
a bit of the data that's supposed to be hashed. If I didn't overlook
something, it only considers addr&0x0f0f0f0f0f00 and sid&0x0f0f, given
the right endianness of addr and that PPPOE_HASH_SIZE stays 16.

Florian
