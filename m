From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Wed, 12 Oct 2016 11:05:06 +0200
Message-ID: <1476263106.5271.23.camel@sipsolutions.net>
References: <20161010150358.GA514@swordfish>
         <20161010153050.GA836@swordfish> (sfid-20161010_173147_270639_33210BFD)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        linux-next@vger.kernel.org,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:42173 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932284AbcJLJFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Oct 2016 05:05:25 -0400
In-Reply-To: <20161010153050.GA836@swordfish> (sfid-20161010_173147_270639_33210BFD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sorry - I meant to look into this yesterday but forgot.

> Andy, can this be related to CONFIG_VMAP_STACK?

I think it is.

> > current -git kills my system. 

Can you elaborate on how exactly it kills your system?

> > adding
> > 
> > 	if (!virt_addr_valid(&aad[2])) {
> > 		WARN_ON(1);
> > 		return -EINVAL;
> > 	}

That's pretty obviously false with VMAP_STACK, since the caller
(ieee80211_crypto_ccmp_decrypt) puts the aad on the stack. b_0 is also
on the stack, but maybe that doesn't matter.

Herbert, do you know what could cause this, and how we should fix it?

We can't really afford to do an allocation here, and we don't have
space in the skb (not even in skb->cb at that point), so if we really
have no way to continue using the stack we'd ... not sure, use a per-
CPU buffer perhaps.
We need 32 bytes for aad and 16 bytes for b_0, if that also can't be on
the stack any more.

johannes
