From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 18:26:39 +0800
Message-ID: <20100329102639.GA23414@gondor.apana.org.au>
References: <1269509091-6440-1-git-send-email-timo.teras@iki.fi> <1269509091-6440-2-git-send-email-timo.teras@iki.fi> <20100325.122611.267401605.davem@davemloft.net> <20100329084018.GA22547@gondor.apana.org.au> <4BB06C36.9060105@iki.fi> <20100329090927.GA22899@gondor.apana.org.au> <4BB07BF6.6000505@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:52039 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754775Ab0C2K0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 06:26:47 -0400
Content-Disposition: inline
In-Reply-To: <4BB07BF6.6000505@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 01:07:50PM +0300, Timo Ter=E4s wrote:
>
>> For the flow cache we didn't need this because the policy code
>> would flush the cache synchronously so we can always grab a ref
>> count safely as long as BH is still off.
>
> The old code could return policy object that was killed. It

Which is fine.  I'd rather have that than this new behaviour
which adds a lock.  We don't delete policies all the time, so
optimising for that case and pessimising the normal case is wrong!

> The reason for policy GC calling flush was there for two
> reasons:
> - purging the stale entries
> - making sure that refcount of policy won't go to zero after
>  releasing flow cache's reference (because the flow cache
>  did only atomic_dec but did not call destructor)
>
> Both issues are handled otherwise in the patch. By refreshing
> stale entries immediately. Or calling virtual destructor when
> the object gets deleted. Thus the slow flushing is not needed
> as often now.

Let's step back one second.  It's best to not accumulate unrelated
changes in one patch.  So is there a reason why you must remove
the synchronous flow cache flushing from the policy destruction
path? If not please move that into a different patch.

> We can still drop the locking, as ->dead can be made atomic_t.

No it doesn't need to be atomic, reading an int is always atomic.

> Checking ->dead improves cache's speed to react to policy object
> changes. And the virtual ->get is especially needed for bundles
> as they can get stale a lot more often.

I really see no point to optimising for such an unlikely case
but as long as you kill the locks I guess I'm not too bothered.

> Yeah. Just a note that the road map to RCU policies is trivial
> and fixes some races in locking currently.

Please do one change at a time.  Let's just focus on the original
issue of the bundle linked list for now.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
