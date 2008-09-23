From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 07:53:18 +0300
Message-ID: <48D8763E.4030607@iki.fi>
References: <48BE329C.2010209@iki.fi> <20080902.234723.163403187.davem@davemloft.net> <20080905115506.GA26179@gondor.apana.org.au> <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <48D63E3A.90301@iki.fi> <48D66677.2040309@iki.fi> <20080922114256.GA27055@gondor.apana.org.au> <48D7971A.5050107@iki.fi> <20080922235012.GA23658@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:63646 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbYIWExZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 00:53:25 -0400
Received: by nf-out-0910.google.com with SMTP id d3so642048nfc.21
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 21:53:23 -0700 (PDT)
In-Reply-To: <20080922235012.GA23658@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Sep 22, 2008 at 04:01:14PM +0300, Timo Ter=E4s wrote:
>>> Unfortunately it's not that simple since we'll be in the same
>>> bind if the entry after the next entry gets deleted as well as
>>> the next entry.
>> Well, I was thinking that we hold the next pointer. And when
>> continuing the dump, we can first skip all entries that are marked
>> as dead (each next pointer is valid since each of the next pointers
>> are held once). When we find the first valid entry to dump we
>> _put() the originally held entry. That would recursively _put() all
>> the next entries which were held.
>=20
> No that doesn't work.  Let's say we store the entry X in walk->state,
> and we hold X as well as X->next.  Now X, X->next, and X->next->next
> get deleted from the list.  What'll happen is that X and X->next
> will stick around but X->next->next will be freed.  So when we
> resume from X we'll dump X and X->next correctly, but then hit
> X->next->next and be in the same shithole.

I think it would work. Here's the scenarios:
We hold X as dumping is interrupted there. X->next points statically to
some non-deleted entry and is held.

Now, if X->next gets deleted, it's marked dead and X->next->next is hel=
d
too. Thus when there is multiple deleted entries in chain, the whole
chain is held recursively/iteratively. When walking is continued on X
the first thing we do is skip all dead entries from X, after that we
put X and that would trigger put() for all X->next:s which were held
iteratively.

If X->next is not deleted, and X->next->next gets deleted, the X->next
list structure is updated correctly by list_del_rcu and the entry can
be actually freed even if the walking didn't iterate that entry (it
would be skipped anyway as it's marked dead on deletion).

So the idea was to hold X->next from deletion function, not from
the walking function. That would be, we always hold deleted->next when
there are ongoing walks. And on final _put() we _put() the ->next
entry.

I think that would work.

- Timo
