From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
	driver v2
Date: Thu, 27 Nov 2008 11:54:40 +0100
Message-ID: <1227783281.3809.78.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-QPUIlCCZ/QPQtdu2tkkx"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59972 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757111AbYK0Kzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 05:55:31 -0500
In-Reply-To: <cover.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-QPUIlCCZ/QPQtdu2tkkx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

Thanks for this work. I don't personally have much of an interest in
wimax, so I don't really care what you do, so take things I have said
and will say with a grain of salt. It's not my intention to say "you've
done it all wrong", but more to offer observations on how these things
were done in wifi and how it went all wrong there, requiring a complete
rewrite recently.

Conceptually, I think wimax is now at a point where wifi was many years
ago with the first wireless drivers: everything was full-mac, wext
ioctls were written to go directly to the driver. Then ipw2x00 came
along, more functionality was moved to the host (yes, you say this won't
happen with wimax, but I think it will, eventually, if wimax gets to be
popular enough. never say never), and wext got more messy. Wext even was
defining actual operations, as undefined as they often were, you're not
even doing that.

> * The WiMAX kernel stack
>=20
> The (kernel) WiMAX stack is (as of now) very basic; it conforms a
> "control plane", in a similar fashion to cfg80211.=20

I don't think you can say it's like cfg80211, cfg80211 in fact does a
lot more than the wimax "stack", it can validate parameters for example,
and provides actual operations (key operations, peer operations,
scanning [soon], ...) rather than just a transport to the driver. As
I've said on the relevant patch, I'd love to see the wimax stack take
more of that direction.

> We still don't know what's going to be a good abstraction layer
> because so far, we have only see one WiMAX device for which we could
> implement support.=20

I don't see that as much of a problem. Many of the commands you have
defined for the i2400m driver are very generic, for example:
 * I2400M_MT_GET_SCAN_RESULT
 * I2400M_MT_SET_SCAN_PARAM (why are those not part of the SCAN command btw=
?)
 * I2400M_MT_CMD_SCAN
 * I2400M_MT_CMD_CONNECT
 * I2400M_MT_CMD_DISCONNECT
 * I2400M_MT_GET_LINK_STATUS
 * I2400M_MT_GET_STATISTICS
 * I2400M_MT_GET_STATE
 * I2400M_MT_SET_INIT_CONFIG
 * I2400M_MT_CMD_INIT
 * I2400M_MT_CMD_ENTER_POWERSAVE
 * all the *EAP* seem applicable to devices that don't offload all of
   that to the host, and those devices that do will just need new, more
   lower level, primitives, compare for example the wext WPA stuff which
   handles both the PS3 wifi that does this in the "hardware" and normal
   wireless hw that leaves it to wpa supplicant
 * (and more)

They will surely apply to any wimax device, or to a soft wimax stack if
that should ever happen. And for those commands that don't, it's easy to
see whether or not a device supports them and use different, possibly
more generic, ones; say a device doesn't support scanning, it'll surely
support connecting if you know the network already.

Conceptually, I'm not sure you should call the wimax stack a "stack" at
all, so far it seems more like a "transport" that really should be part
of the driver. It's not defining any *wimax* commands, but it's only
defining the transport for those *driver-specific* commands.

This is the biggest issue I see here. I don't see how the stack helps
anyone implement a driver for a new device. Sure, they won't have to
come up with a new transport, write less lines of generic netlink code,
but ultimately that's not the hard part, the hard part is getting the
relevant operations right etc.

> So the current abstraction layer provides a low-level WiMAX API with
> means for resetting, monitoring state changes, controlling rfkill and
> sending messages to the driver (in a driver specific format) back and
> forth (more on this below). The documentation in include/net/wimax.h
> provides more information.

This really means you're putting the actual "driver", the piece that
does the hardware abstraction, into userspace. And in a binary daemon
even, afaict. This was quickly shot down with ipw3945/4965, not sure why
nobody has cared here so far. Maybe because you're actually planning to
open source that part.

> The driver for the 2400m sits below the stack, providing the back end
> operations to drive control (reset, rfkill, message passing) and
> feeding it state change information. On the other side, the 2400m
> driver connects to netdev, where it emulates an ethernet device (*1).

Couldn't the stack provide more functionality here? Somewhere else you
speak of using ethernet vs. rawip, couldn't the stack do that
translation, possibly even allowing both rawip and ethernet to coexist,
or be switchable at runtime if you have a working dhcp client?

johannes

--=-QPUIlCCZ/QPQtdu2tkkx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLnxtAAoJEKVg1VMiehFYH+QP/AjvJrf/XhR2hH9+tziGcND8
R3Qy20YKCKQMc//siyaLUecjvW6imnyaFekyO7uslVaOGo+NiI3wjekuXUPBxxpZ
fxXbmKYBpN/DYGOMwieDycOeee3FfRzIXYsbI6B2xknjXIPybh0+dV4ctj+zRaoN
n2gvKK5MURIUj42EOzL/J2YA/K5tYpA9dWLg0yabvjvdt4o52T3Dr7mVLZa95hq5
EvZlPBA7ZYeB/UvAt+4UDppA2VbJwMmzmB3IqHA46pBwqgzZw2AnuP2ccZe+qCUA
9ls8Xt5nmHYjuGIl6rd8DSTRgL25H1YHJm16smFgT8T+uCzSfOedSkNb9I+sK+6l
hnHZtKs3rbVq55zPS5FuIU1v7T2Nk0H5e2ihSK/JTRYcUqluMjOncDGAlqO23k0M
IEzw62+hfGsmMSawS8DhjcTsdq5DZXIfYUox2fhkAqJTy29GibGbbxp/PL4hANax
J/YGe6C+SgR1hPHHMMcUU4KxUfP7tkqACIusuiSr4guBVI+sN9jHLY5edpRfWG4Q
URKbAD+Sj49AMBKTarPHfLwRn2qAGv8GIcabsOLsthgktrkcq5cQy9bqbJmkfsoy
6RW4/9bYXLUJXnyIRo1xzXyxTMKQoLzEEKaUH69/7FvhhTOJmLj6ilKFPHCaCgyj
D2ZSdUU4xzpzFXrH/Hc1
=5jZI
-----END PGP SIGNATURE-----

--=-QPUIlCCZ/QPQtdu2tkkx--

