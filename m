From: Sam Cannell <sam.cannell@catalyst.net.nz>
Subject: Generic receive offload with igb driver breaks IPv6
Date: Thu, 24 Jun 2010 12:24:34 +1200
Message-ID: <1277339074.23391.4.camel@spathi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-sf2nMNyZ0BTUql8nBwsH"
To: netdev@vger.kernel.org, e1000g-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bertrand.catalyst.net.nz ([202.78.240.40]:49870 "EHLO
	mail.catalyst.net.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753332Ab0FXA2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 20:28:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-sf2nMNyZ0BTUql8nBwsH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi,

We've recently been having some speed issues through one of our routers
(running Ubuntu's 2.6.32-22-server kernel)

It seems that fragmented TCPv6 packets entering the router through an
Intel 82575EB interface (igb driver) are reassembled by GRO.  The
resulting packet, being larger than 1500 bytes, is unable to be
forwarded out the outgoing interface.  The router sends back a 'packet
too big' error, which means nothing to the sender because as far as it's
concerned, every packet is smaller than the MTU.

This slows down HTTP across a 100mbps network to around 10kbps -- the
speeds return to normal when gro is disabled on the router's receiving
interface.



For instance:


[Capture from sender]
No.     Time        Source                Destination           Protocol
Info
      1 0.000000    2404:130:80:10::10
2404:130:0:1000:227:eff:fe0b:4918 TCP      [TCP segment of a reassembled
PDU]

Frame 1 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: Xensourc_65:30:fe (00:16:3e:65:30:fe), Dst:
Xensourc_f6:80:47 (00:16:3e:f6:80:47)
Internet Protocol Version 6
Transmission Control Protocol, Src Port: http (80), Dst Port: 51793
(51793), Seq: 1, Ack: 1, Len: 1428

No.     Time        Source                Destination           Protocol
Info
      2 0.000000    2404:130:80:10::10
2404:130:0:1000:227:eff:fe0b:4918 TCP      [TCP segment of a reassembled
PDU]

Frame 2 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: Xensourc_65:30:fe (00:16:3e:65:30:fe), Dst:
Xensourc_f6:80:47 (00:16:3e:f6:80:47)
Internet Protocol Version 6
Transmission Control Protocol, Src Port: http (80), Dst Port: 51793
(51793), Seq: 1429, Ack: 1, Len: 1428

No.     Time        Source                Destination           Protocol
Info
      3 0.000000    2404:130:0:10::1      2404:130:80:10::10    ICMPv6
Too big

Frame 3 (1294 bytes on wire, 1294 bytes captured)
Ethernet II, Src: Xensourc_f6:80:47 (00:16:3e:f6:80:47), Dst:
Xensourc_65:30:fe (00:16:3e:65:30:fe)
Internet Protocol Version 6
Internet Control Message Protocol v6



[Capture from router]
No.     Time        Source                Destination           Protocol
Info
      1 0.000000    2404:130:80:10::10
2404:130:0:1000:227:eff:fe0b:4918 TCP      [TCP segment of a reassembled
PDU]

Frame 1 (2942 bytes on wire, 2942 bytes captured)
Ethernet II, Src: Xensourc_f6:80:46 (00:16:3e:f6:80:46), Dst:
SunMicro_40:43:33 (00:21:28:40:43:33)
Internet Protocol Version 6
Transmission Control Protocol, Src Port: http (80), Dst Port: 51793
(51793), Seq: 1, Ack: 1, Len: 2856

No.     Time        Source                Destination           Protocol
Info
      2 0.000035    2404:130:0:10::1      2404:130:80:10::10    ICMPv6
Too big

Frame 2 (1294 bytes on wire, 1294 bytes captured)
Ethernet II, Src: SunMicro_40:43:33 (00:21:28:40:43:33), Dst:
Xensourc_f6:80:46 (00:16:3e:f6:80:46)
Internet Protocol Version 6
Internet Control Message Protocol v6



Any thoughts?  I've also posted this to both net-dev and e1000-devel as
I'm not sure whether it's driver-specific or something to do with gro
itself.

Thanks,

Sam

--=-sf2nMNyZ0BTUql8nBwsH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (SunOS)

iEYEABECAAYFAkwipbwACgkQcuIanIzWkBLznQCfeQEXlxPqLnVznVg2130xukFp
m7oAniQNHGXy/ebbujCdiUTE09P+8+3q
=LOz/
-----END PGP SIGNATURE-----

--=-sf2nMNyZ0BTUql8nBwsH--

