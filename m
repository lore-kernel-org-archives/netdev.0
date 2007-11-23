From: Johannes Berg <johannes@sipsolutions.net>
Subject: wireless vs. alignment requirements
Date: Fri, 23 Nov 2007 21:33:21 +0100
Message-ID: <1195850001.4149.165.camel@johannes.berg>
References: <20071123000922.C44009D4A1F@zog.reactivated.net>
	 (sfid-20071123_002828_208061_C7872499)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vIq45vcuYAlwqPGWFLH4"
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:56516 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbXKWUdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 15:33:31 -0500
In-Reply-To: <20071123000922.C44009D4A1F@zog.reactivated.net> (sfid-20071123_002828_208061_C7872499)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vIq45vcuYAlwqPGWFLH4
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> David Miller found a problem in a wireless driver where I was using
> compare_ether_addr() on potentially unaligned data. Document that
> compare_ether_addr() is not safe for use everywhere, and add an equivalen=
t
> function that works regardless of alignment.

FWIW, as I've said in the other thread I cannot believe this to be true
since the IP header is required to be aligned anyway. So *iff* this
really was a problem then we'd have much more problems and better fixed
the alignment of the received USB urb in zd1211rw.

Let me explain... This is going to take a bit of text...

Marking optional fields with < > for better readability, you have this
802.11 header layout (including byte sizes):

| FC (2) | durid (2) | A1 (6) | A2 (6) | A3 (6) | seq (2)
...	< optional A4 (6) > < optional qos (2) >
...	< optional HT (4) > < optional mesh (4 or 16) >
(NOTE: not sure about the order of the last two, this will probably
depend on the order in which 11n/11s are accepted! logically I would
expect the order as I wrote it)

(which makes it 24, 26, 30 or 32 bytes long plus the optional 11n/11s
additions which are multiples of four)

After that comes the data which may contain a SNAP header or such and
then the rest. The SNAP header is six bytes plus two byte ethertype, or
there could be a bridge tunnel header with six bytes plus two byte
ethertype, or it could be missing completely, in all of these cases it's
evenly divisible by four.

Now, the IP stack actually assumes that its header is four-byte aligned
(see comment at NET_IP_ALIGN, although it is not said explicitly that
the alignment requirement for an IP header is four) so that is actually
something for the hardware/firmware (!) to do, for example Broadcom
firmware will insert two bytes padding before the PLCP header (6 bytes,
sitting before the 802.11 header) if either the QoS field or A4 was
present (and the header length thus wasn't a multiple of four). Atheros
hardware will insert two bytes padding after the QoS field in the same
cases (IIRC).

Of course, you need to consider the RX header that sits before the
802.11 stuff. Broadcom's is 30 bytes, but if you add the six byte PLCP
header you have 36 bytes which is divisible by four. In the QoS XOR A4
case they add two bytes which makes it 38 with two bytes to spare for
4-byte alignment which are eaten up by the QoS/A4 field.

I don't know about any other hardware but considering that things work
as well as they do I'd think they do similar things.

Hence, going back to the 802.11 header and the IP header alignment
requirement, if we get the IP header alignment requirement right now I
cannot possibly see any way we would use compare_ether_addr() on an
address that is not at least two-byte aligned as required.

Whew. Or so I think.

johannes

--=-vIq45vcuYAlwqPGWFLH4
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIUAwUAR0c5EKVg1VMiehFYAQJrrw/4sM6Sq7R2RZXWP+Y0+QsVwgbC+W7cnT66
QX4HdcM8smvWvmkss33MAqNXWEzqci3OwwVW776q8ysVo5NHUoFCwUBAfxR2Mf4D
K61vwXvFNwuI54JqRLL1W1WCzmD6wMykJUJohfdVkS0jF62ZGAgqjslDQ87O8qYh
GMofp2TaPJrVXkDtqlxyo+orSyIjxLXNEzSjUDzseYz0Zi0UdBQiK1oGFslpgwPa
BJ9Od/2O3V8fApNFYRODJ7urORWVPqvn1yVpgUamHMhUT3QIt1r/2IQ0GKsirB03
KkuPom6/mN6HUSBq03O640dLxYTms+6JOBzmX82itdmROExAgf3YH5HyD1owp6w5
Ywc8NV/XwoVxiMJdTdkarMht4TVVTUoTWVifRpNFwcDPnK/J2oivX6hTgsuNL/yR
szdnV+MZ9+Bb3G6w6/YerHgbHHPklJAe13+euyrvaa3bUOGJ5PlmX9NxVM71B3La
D2VhBJCQhpgHFjBc+WOdPPtwonMO2cZSJFMLZRh/xNqxr8GSQsZnoN1GTV5+ds8w
NB4UDxtZwHjc3e0ZPkUtGPITC+wYiADvpKIIalpySe3169lG4Gawq/9idD7rJApv
Rfztj90/gWKaHpdcHeiaxhUv8MVctFSZ3y70XzYWal5tHxssvuKrtESDnHwXOWxl
zmGd/DCHBg==
=CMxw
-----END PGP SIGNATURE-----

--=-vIq45vcuYAlwqPGWFLH4--

