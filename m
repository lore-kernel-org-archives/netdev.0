From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 net-next] arp: flush arp cache on IFF_NOARP change
Date: Tue, 21 May 2013 19:54:14 +0100
Message-ID: <1369162454.2615.60.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130520.134633.448574202175922639.davem@davemloft.net>
	 <1369131824-6318-1-git-send-email-timo.teras@iki.fi>
	 <1369153519.2615.3.camel@bwh-desktop.uk.solarflarecom.com>
	 <20130521212930.01efd34e@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kaber@trash.net>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52644 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab3EUSyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 14:54:18 -0400
In-Reply-To: <20130521212930.01efd34e@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 21:29 +0300, Timo Teras wrote:
> On Tue, 21 May 2013 17:25:19 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
>=20
> > On Tue, 2013-05-21 at 13:23 +0300, Timo Ter=C3=A4s wrote:
> > > IFF_NOARP affects what kind of neighbor entries are created
> > > (nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
> > > cache to refresh all entries.
> > >=20
> > > Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> > > ---
> > > > This patch makes no sense at all.
> > > >=20
> > > > The state bit in ->priv_flags is a boolean stating whether the
> > > > notified should do something or not.
> > > >=20
> > > > But you're setting it to match what IFF_NOARP is.
> > > >
> > > > You should set it any time IFF_NOARP _changes_, and then clear
> > > > the bit when the notifier clears the neighbour entries.
> > >=20
> > > IFF_NOARP_CHANGED is set according to "changes =3D dev->flags ^
> > > old_flags;" which reflect the change. But I agree that the cleari=
ng
> > > out bit was misplaced. This is especially true as it seems
> > > NETDEV_CHANGE can be notified from another place too.
> > [...]
> >=20
> > None of the other persistent flags have a transient flag for change=
s;
> > why should IFF_NOARP?  Why not cache the IFF_NOARP state in the
> > in_device and then compare and update that in arp_netdev_event().
>=20
> This was the earlier suggestion I got, so I followed that. NOARP flag
> is also used in IPv6 side (quick look would indicate that ndisc code
> needs similar fix), so it would be useful to have this generally
> available.

Sorry, I missed that IFF_NOARP is not really just about ARP.

> Would it be worthwhile to consider adding "flags_changed" to struct
> net_device or some other mechanism add this info about all flags?

It's inelegant to put transient data associated with an event in a
persistent data structure.  On the other hand, having every user cache
the old state is pretty awful as well.

Really, netdev notifiers should be changed to accept a structure that
encapsulates the changes rather than just a pointer to the net_device.
But making such a change would be an enormous pain and error-prone
because notifier functions aren't type-safe.

As an interim solution, I think either the general priv_flags_changed o=
r
old_priv_flags would be preferable to defining extra transient flags.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
