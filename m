From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_input() and ->seq oddities
Date: Mon, 4 Feb 2008 09:00:27 +1100
Message-ID: <20080203220027.GA11641@gondor.apana.org.au>
References: <20080202211635.GF9375@cs181133002.pp.htv.fi> <20080202222226.GB31388@gondor.apana.org.au> <20080202235827.GP27894@ZenIV.linux.org.uk> <20080203002019.GA32295@gondor.apana.org.au> <20080203003718.GQ27894@ZenIV.linux.org.uk> <20080203030516.GA5685@gondor.apana.org.au> <20080203110444.GR27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59903 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750808AbYBCWAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 17:00:34 -0500
Content-Disposition: inline
In-Reply-To: <20080203110444.GR27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 03, 2008 at 11:04:44AM +0000, Al Viro wrote:
>
> So what you are saying is
> 	* callers of xfrm_input_resume() are in callbacks that couldn't
> have been set other than from esp_input()/esp6_input()
> 	* these two could have only been called via ->type->input()
> 	* ->type->input() is called from xfrm_input(), immediately after
> having set ->seq.input, *or* from xfrm6_input_addr().  The former is safe.
> 	* xfrm6_input_addr() calls ->type->input() of object it gets from
> xfrm_state_lookup_byaddr().  The protocol number passed to the latter comes
> from xfrm6_input_addr() argument.
> 	* the protocol numbers given to xfrm6_input_addr() by its callers
> are IPPROTO_DSTOPTS and IPPROTO_ROUTING resp; ->input() instances in their
> xfrm_type do *not* set callbacks that could lead to xfrm_input_resume(),
> so we are safe.

This doesn't look so bad if you take out the xfrm6_input_addr call.
And you can't blame that one on me :)

The xfrm6_input_addr function is really a parallel universe which has
nothing to do with IPsec.  It's used by Mobile IPv6 just because it
happened to fit in the same schema.

In other words, IPsec transforms such as ESP cannot be called from
xfrm6_input_addr and as such async resumption never occurs with
xfrm6_input_addr.

> IMO that at least deserves a comment near xfrm_input()...

Sure.  There is already a comment about encap_type < 0 in there, but
I think you'll probably be able to explain it much better than I can
looking in from the outside so if you have a patch... :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
