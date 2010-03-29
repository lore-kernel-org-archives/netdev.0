From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 17:09:27 +0800
Message-ID: <20100329090927.GA22899@gondor.apana.org.au>
References: <1269509091-6440-1-git-send-email-timo.teras@iki.fi> <1269509091-6440-2-git-send-email-timo.teras@iki.fi> <20100325.122611.267401605.davem@davemloft.net> <20100329084018.GA22547@gondor.apana.org.au> <4BB06C36.9060105@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:60287 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751647Ab0C2JJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 05:09:35 -0400
Content-Disposition: inline
In-Reply-To: <4BB06C36.9060105@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 12:00:38PM +0300, Timo Ter=E4s wrote:
>
>> Timo, what was the reason for getting rid of the synchronous
>> flush again?
>
> No, just having the flush call is not enough to guarantee
> liveliness. The flushing happens in delayed work, and the flows
> might be in use before the flush has been finished or even
> started.
>
> I was also hoping to move the "delayed" deletion part to
> flow cache core so the code would be shared with policies and
> bundles.
>
> As stated before, we don't really need lock for the 'dead' check.
> It's only written once, and actually read without lock in some
> other places too. And all the other places that do take the lock,
> release it right away making the resulting dead check result
> "old" anyway.=20

No that's not the point.

The lock is not there to protect reading ->dead, which is atomic
anyway.

It's there to guarantee that you don't increment the ref count
on a dead policy.

=46or the flow cache we didn't need this because the policy code
would flush the cache synchronously so we can always grab a ref
count safely as long as BH is still off.

So if you leave the flow cache flushing as is, then we should
still be able to do the it without holding the lock, or checking
for deadness.

> Looks to me that the whole policy locking is not up-to-date
> anymore. Apparently the only place that actually needs it is
> the migration code (which just happens to be broke anyway since
> bundle creation does not take read lock). But it could be
> relatively easily changed to replace policy with new
> templates... and the whole policy stuff converted to RCU.

I wouldn't be surprised that the migration code is buggy.  But
that's orthogonal to your patch.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
