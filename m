From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 02 Sep 2008 23:35:38 -0700 (PDT)
Message-ID: <20080902.233538.200370430.davem@davemloft.net>
References: <20080903055041.GA8547@gondor.apana.org.au>
	<20080902.231420.255718595.davem@davemloft.net>
	<48BE2E63.8000707@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51920
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754093AbYICGfp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 02:35:45 -0400
In-Reply-To: <48BE2E63.8000707@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 03 Sep 2008 09:27:47 +0300

> Well, it's just another list keeping a reference like ->bydst,
> ->bysrc and ->byspi. The actual amount of external references is
> still correct (the walking code calls _hold() when it returns while
> keeping an external pointer).

->bydst, ->bysrc, and ->byspi are counted as a single external
reference because:

1) They are controlled as a group

2) Doing 3 atomic operations is more expensive than one

I know because I did that conversion from 3 refcount operations down
to 1 and I timed it with stress tests, which showed that it made a
huge performance difference for the control path of our IPSEC stack.

> The difference is that node should not be unlinked from ->all until
> all other references are gone. For other lists the unlinking can be
> done earlier since they are used only for lookups.

Once there are no list references, there cannot be any other references=
=2E
So in fact it seems to me that unlinking when the xfrm_state is removed
from those other lists makes perfect sense.

If __xfrm_state_delete sets the state to DEAD, and you skip xfrm_state
objects marked DEAD, why does the ->all list reference have to survive
past __xfrm_state_delete()?

It seems the perfect place to do the ->all removal.

> Any good other ways to enumerate to list entries while allowing
> to keep a temporary "iterator"? The previous method was crap too.

At least the old stuff was self-consistent and only needed one central
lock grab to destoy an object.
