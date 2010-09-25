From: David Miller <davem@davemloft.net>
Subject: Re: IPsec: Why do pfkey_getspi and xfrm_alloc_userspi call
Date: Fri, 24 Sep 2010 20:57:47 -0700 (PDT)
Message-ID: <20100924.205747.35037043.davem@davemloft.net>
References: <4C8E19A0.6000501@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christophe.gouault@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52211
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755238Ab0IYD51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 23:57:27 -0400
In-Reply-To: <4C8E19A0.6000501@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Gouault <christophe.gouault@6wind.com>
Date: Mon, 13 Sep 2010 14:31:28 +0200

> I guess the larval state found by xfrm_get_acq_byseq must have the
> same parameters as those provided in the message (mode, reqid, proto,
> daddr, saddr, family). Contrary to what one might think, the call to
> xfrm_get_acq_byseq is more costly than the call to xfrm_find_acq,
> because the later uses a hash table.

Whether any such requirement exists, we certainly have never enforced
something like that.

I tried to look for guidance in some other PFKEYV2 implementations,
but those I looked at (OpenBSD for example) are even more permissive
than we are.

For example, OpenBSD doesn't validate the incoming sequence number at
all as far as making sure it matches the one emitted for the acquire
message.

In fact it's approach to handling this sequence number is completely
different from ours.  It treats it truly as a unique 32-bit cookie
which is used entirely by the user.  When an acquire is emitted, it
does not create an ipsec database entry, instead it waits until the
GETSPI happens (see reserve_spi()).

This lack of consistency for enforcement and validation amongst
implementations makes it really difficult to say what might or might
not be safe to do here.

> Shouldn't we extend the xfrm_get_acq function so that it accepts an
> optional seq parameter? We would replace the first call to
> xfrm_find_acq_byseq by:
> 
>    x = xfrm_find_acq(mode, reqid, proto, xdaddr, xsaddr, 0, family, seq);
> 
> and the if no entry is found, we would call:
> 
>    x = xfrm_find_acq(mode, reqid, proto, xdaddr, xsaddr, 1, family, 0);
> 
> We would take benefit of the hash table, instead of looking up through
> the whole SAD as does xfrm_get_acq_byseq.

Even with all of the above, I do think this suggestion of your's is
reasonable.

But please, this function has too many arguments already, find a way
to do it without adding new ones.

