From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 05:52:35 -0700 (PDT)
Message-ID: <20090312.055235.56926675.davem@davemloft.net>
References: <200903121946.24847.rusty@rustcorp.com.au>
	<1236858219.14863.18.camel@localhost.localdomain>
	<1295ed070903120547q431b5b40n71b8d2e98719e18d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcbw@redhat.com, rusty@rustcorp.com.au, netdev@vger.kernel.org
To: pktoss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34169
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752637AbZCLMwt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 08:52:49 -0400
In-Reply-To: <1295ed070903120547q431b5b40n71b8d2e98719e18d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pantelis Koukousoulas <pktoss@gmail.com>
Date: Thu, 12 Mar 2009 14:47:09 +0200

> > The problem is that there's no "my carrier detection is accurate" f=
lag
> > for drivers. =A0Drivers that don't support carrier detection (say, =
my
> > Belkin PCMCIA NE2k card) always report "carrier on", but of course =
don't
> > support carrier detection. =A0So when NetworkManager looks at the d=
evice
> > and sees "hey, there's a carrier!" it will activate it, because a
> > carrier means the cable is plugged in or the PHY *thinks* a cable i=
s
> > plugged in.
> >
> > So NetworkManager checks whether the device supports ethtool get_li=
nk or
> > MII register carrier status in lieu of a general kernel driver flag=
 for
> > "I support carrier detection".
> >
> > Carrier is not on/off, it needs to be tristate, like on/off/unknown=
=2E =A0If
> > it was unknown, NM could make an intelligent decision about this wi=
thout
> > resorting to ethtool/MII checks. =A0But we don't have that.
>=20
> This looks like an independent problem imho, one of kernel<->userspac=
e
> API. The current 'defacto' way of finding out if detection is support=
ed or
> not (ethtool) seems to give the needed information even if somewhat u=
gly.
>=20
> The issue discussed here as I understand it is whether virtio should =
or
> should not support carrier status reporting. IMHO it should, since
> it is useful functionality and doesn't cost much.
>=20
> Dan, What is your opinion on that?

I think Dan is right.

If the driver doesn't provide an explicit carrier, there is no way to
know for sure that it is on of off.  If NetworkManager decides that
this means on, and it's really off, that isn't so nice.

And lots of very old drivers in the tree don't have a link indication
handler, so this is a very real issue.

Not adding a link state handler to virtio_net for pompous reasons like
some theoretical "clean design" claim is idiotic, and in the end bad
for users who are using existing versions of NetworkManager.

I also think the NetworkManager change is wrong, lack of link
indication support does not mean the link is always on, not by a
country mile.  Tell that to all the ancient ethernet drivers in
our tree.

If the link is always on, you should make that explicit by providing
a link state handler, and making sure it always returns true.
