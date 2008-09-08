From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours:
 ip6_dst_lookup_tail NULL crash
Date: Mon, 08 Sep 2008 13:15:47 -0700 (PDT)
Message-ID: <20080908.131547.26037628.davem@davemloft.net>
References: <20080831111304.d57b9f5a.akpm@linux-foundation.org>
	<20080907181109.GA2466@2ka.mipt.ru>
	<200809072119.50307.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johnpol@2ka.mipt.ru, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: rdenis@simphalempin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33890
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752814AbYIHUPx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 16:15:53 -0400
In-Reply-To: <200809072119.50307.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <rdenis@simphalempin.com>
Date: Sun, 7 Sep 2008 21:19:49 +0300

> Le dimanche 7 septembre 2008 21:11:09 Evgeniy Polyakov, vous avez =E9=
crit=A0:
> > Since dst entry is allowed not to have neighbour entry, flush it ju=
st
> > like with incomplete one. This drops performance of your applicatio=
n
> > with more than 1024 neighbours to 1024 messages, to fix it you shou=
ld
> > tune ipv6 routing parameters (gc intervals, gc threshold, maximum n=
umber
> > of entries and so on). There may be another problem with perfomance
> > though, at least I was able to bump it 10 times with different sett=
ings,
> > but still two times smaller than with 4k neighbours.
>=20
> That looks like a trivial local DoS against the IPv6 stack though?
>=20
> Especially in the case that the interface has IFF_NOARP, that seems l=
ike a=20
> weird limitation. Oh well...

It's less of a DoS than the NULL pointer deref we get now, isn't it? :-=
)

But I don't like this patch for several reasons:

1) Slapping on a NULL check in response to a OOPS at that exact
   location is usually a very big red flag, and deserves high scrutiny
   instead of blind acceptance.

2) Looking at the indentation of this DAD code block (it's all one tab
   too much) it's obviously a very shitty cut and paste job.  If the
   coding style was too difficult to get right, what does this say
   about that change that brought the code here, semantically? :-/

   This means we should figure out how this code got to this place,
   and what kind of invariants existed at the old location that might
   make this dst->neighbour dereference valid, and what implications
   there are for the fact that it can now be NULL.

Really, we really need to understand much more deeply this situation.
