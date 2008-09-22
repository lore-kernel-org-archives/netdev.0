From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 07:50:12 +0800
Message-ID: <20080922235012.GA23658@gondor.apana.org.au>
References: <48BE329C.2010209@iki.fi> <20080902.234723.163403187.davem@davemloft.net> <20080905115506.GA26179@gondor.apana.org.au> <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <48D63E3A.90301@iki.fi> <48D66677.2040309@iki.fi> <20080922114256.GA27055@gondor.apana.org.au> <48D7971A.5050107@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34726 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754483AbYIVXuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 19:50:19 -0400
Content-Disposition: inline
In-Reply-To: <48D7971A.5050107@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2008 at 04:01:14PM +0300, Timo Ter=E4s wrote:
>
> > Unfortunately it's not that simple since we'll be in the same
> > bind if the entry after the next entry gets deleted as well as
> > the next entry.
>=20
> Well, I was thinking that we hold the next pointer. And when
> continuing the dump, we can first skip all entries that are marked
> as dead (each next pointer is valid since each of the next pointers
> are held once). When we find the first valid entry to dump we
> _put() the originally held entry. That would recursively _put() all
> the next entries which were held.

No that doesn't work.  Let's say we store the entry X in walk->state,
and we hold X as well as X->next.  Now X, X->next, and X->next->next
get deleted from the list.  What'll happen is that X and X->next
will stick around but X->next->next will be freed.  So when we
resume from X we'll dump X and X->next correctly, but then hit
X->next->next and be in the same shithole.

Really, the only way to do what you want here is to hold everything
from X to the very end of the list.  The problem with that is that
you can no longer drop the reference counts when we resume.

You can see why even if we only hold X and X->next.  Should X->next
be deleted from the list, when we resume from X we'll no longer be
able to drop the reference count on the original X->next since it
now points to a new entry.

> Not sure which one would be faster. I guess the holding of
> individual entries would be at least more memory efficient.

I think this is a lot more efficient than storing every single
entry from X to the end of the list :)

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
