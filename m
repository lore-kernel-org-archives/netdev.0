From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 02 Sep 2008 23:47:23 -0700 (PDT)
Message-ID: <20080902.234723.163403187.davem@davemloft.net>
References: <48BE2E63.8000707@iki.fi>
	<20080902.233538.200370430.davem@davemloft.net>
	<48BE329C.2010209@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52942
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751457AbYICGra convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 02:47:30 -0400
In-Reply-To: <48BE329C.2010209@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 03 Sep 2008 09:45:48 +0300

> David Miller wrote:
> > Once there are no list references, there cannot be any other refere=
nces.
> > So in fact it seems to me that unlinking when the xfrm_state is rem=
oved
> > from those other lists makes perfect sense.
> >=20
> > If __xfrm_state_delete sets the state to DEAD, and you skip xfrm_st=
ate
> > objects marked DEAD, why does the ->all list reference have to surv=
ive
> > past __xfrm_state_delete()?
> >=20
> > It seems the perfect place to do the ->all removal.
>=20
> 1. xfrm_state_walk() called, it returns but holds an entry since
>    the walking was interrupted temporarily (e.g. full netlink buffer)=
=2E
>=20
> 2. xfrm_state_delete() called to the entry that xfrm_state_walk()
>    is keeping a pointer to and it is unlinked.
>=20
> 3. xfrm_state_walk() called again, it tries to resume list walking
>    but whoops, the entry was unlinked and kaboom.

Get creative, use a key of some sort to continue the walk, that's what
other netlink'ish subsystems use.

> Yes, but the dumping code produced crap. It could dump same entry
> multiple times, miss entries and was dog slow. With it there was
> no possibility to keep userland in sync with kernel SPD/SAD because
> entries were lost.

I'd rather see an entry twice in a dump than have my IPSEC gateway
lockup, or run slower because we take a lock twice as often as
necessary during object destruction.
