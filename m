From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 09:56:53 +0300
Message-ID: <48D89335.3080804@iki.fi>
References: <48D63E3A.90301@iki.fi> <48D66677.2040309@iki.fi> <20080922114256.GA27055@gondor.apana.org.au> <48D7971A.5050107@iki.fi> <20080922235012.GA23658@gondor.apana.org.au> <48D8763E.4030607@iki.fi> <20080923045951.GA26048@gondor.apana.org.au> <48D87BDA.8040804@iki.fi> <20080923052239.GA26233@gondor.apana.org.au> <48D88BCC.5030806@iki.fi> <20080923064707.GA26836@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:1514 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbYIWG47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 02:56:59 -0400
Received: by nf-out-0910.google.com with SMTP id d3so652325nfc.21
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 23:56:56 -0700 (PDT)
In-Reply-To: <20080923064707.GA26836@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Sep 23, 2008 at 09:25:16AM +0300, Timo Ter=E4s wrote:
>> Something like this. I just compile tested, so I'm not sure if it
>> actually works.
>=20
> It is quite clever :)

Thanks :)

And actually, we can make _delete() do normal list_del() and not hold
the next pointer if there are no running dumps. This is the common
case anyway. Then there would be no penalty at all.

>> The corresponding put is in _destroy(). Added it as a final thing
>> to do so hopefully compiler optimizes tail recursion to iteration.
>> (Seemed to do that in my case.)
>=20
> Yeah we should open code this to be absolutely sure that we don't
> get killed by a stupid compiler.

Right. The patch was just to show the idea. Will do a proper patch
with this and the above mentioned optimization if you think we
should change to this until we get really cool lockless dumping.

> However, I think this is still open to the same problem that my
> patch had, i.e., if a dumper goes to sleep during the dump we may
> prevent entries from being freed indefinitely.  Yes your idea
> is better in that we may only withhold say a fraction (depending
> on the order of deletion it could be anywhere from none to every
> entry) of the entries instead of all of them, but fundamentally
> the same issue is still there.
>=20
> Considering the fact that dumps require root privileges I'm not
> convinced as of yet that this is worth it.

You are right. It can keep memory allocated. And in worst case
you end up keeping all the deleted entries (entries are deleted
in the order they appear in all list). But I would not be to
worried about it either.

> Hmm, could we perhaps go back to your original scheme of keeping
> everything on the list and see if we can use RCU to make it lockless
> instead?

That would be ideal of course.

- Timo

