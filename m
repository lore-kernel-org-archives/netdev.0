From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND][PATCH 1/3] PPPoE: improved hashing routine
Date: Mon, 30 Jul 2007 17:47:21 -0700 (PDT)
Message-ID: <20070730.174721.17862949.davem@davemloft.net>
References: <20070729060423.GA27573@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@earthlink.net, netdev@vger.kernel.org
To: florz@florz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33307
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756805AbXGaArW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 20:47:22 -0400
In-Reply-To: <20070729060423.GA27573@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@florz.de>
Date: Sun, 29 Jul 2007 08:04:23 +0200

> Hi,
> 
> I'm not sure whether this is really worth it, but it looked so
> extremely inefficient that I couldn't resist - so let's hope providers
> will keep PPPoE around for a while, at least until terabit dsl ;-)
> 
> The new code produces the same results as the old version and is
> ~ 3 to 6 times faster for 4-bit hashes on the CPUs I tested.
> 
> Florian
> 
> ---------------------------------------------------------------------------
> Signed-off-by: Florian Zumbiehl <florz@florz.de>
> 
> diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
> index 9e51fcc..954328c 100644
> --- a/drivers/net/pppoe.c
> +++ b/drivers/net/pppoe.c
> @@ -108,19 +108,24 @@ static inline int cmp_addr(struct pppoe_addr *a, unsigned long sid, char *addr)
>  		(memcmp(a->remote,addr,ETH_ALEN) == 0));
>  }
>  
> -static int hash_item(unsigned long sid, unsigned char *addr)
> +#if 8%PPPOE_HASH_BITS
> +#error 8 must be a multiple of PPPOE_HASH_BITS
> +#endif

Since PPPOE_HASH_BITS is "4" I would think this check will break the
build. :-)

Anyways, I looked at this myself and half of the problem comes from
the fact that "sid" is passed around as an "unsigned long" throughout
this entire file yet the thing is just a "__u16".

So the first thing to fix is to use __u16 consistently for sid values.
Then the sid hash looks obviously wrong and is easy to fix.

Then you end up with a hash_item() that simply looks like:

static unsigned int hash_item(__u16 sid, unsigned char *addr)
{
	unsigned int hash;

	hash = (((unsigned int)addr[0] << 24) |
		((unsigned int)addr[1] << 16) |
		((unsigned int)addr[2] <<  8) |
		((unsigned int)addr[3] <<  0));

	hash ^= (((unsigned int)addr[4] << 8) |
		 ((unsigned int)addr[5] << 0));

	hash ^= sid;

	return ((hash ^ (hash >> 8) ^ (hash >> 16)) &
		(PPPOE_HASH_SIZE - 1));
}

which is what I've checked into my tree.

Thanks!
