From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#708995: iptables firewall is dropping GRO'd packets
Date: Tue, 21 May 2013 01:28:43 +0100
Message-ID: <1369096123.3469.127.camel@deadeye.wl.decadent.org.uk>
References: <20130520044850.31127.24148.reportbug@shadbolt.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-c0NvjAPxwRqUn9cWJ6Ia"
Cc: 708995@bugs.debian.org
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34541 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751648Ab3EUA2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 20:28:51 -0400
In-Reply-To: <20130520044850.31127.24148.reportbug@shadbolt.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-c0NvjAPxwRqUn9cWJ6Ia
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I'm seeing packet loss when forwarding from a LAN to PPP, whenever GRO
kicks in on the LAN interface.

On Mon, 2013-05-20 at 05:48 +0100, Ben Hutchings wrote:
[...]
> The Windows system is connected to the LAN interface (int0).  Turning
> off GRO on this interface works around the problem.  But since GRO is
> on by default, it clearly ought to work properly with iptables.
>=20
> I'll try to work out where the drops are occurring, but the
> perf net_dropmonitor script is also broken...
[...]

I've fixed that script and now I can see that it's not iptables but
tbf_enqueue() that is dropping the GRO'd packets.  I do traffic-shaping
on the PPP link like this:

tc qdisc replace dev ppp0 root tbf rate 420kbit latency 50ms burst 1540

The local TCP will never generate an skb larger than the burst size
because it knows the PPP interface can't do GSO or TSO.  And the wifi
network doesn't seem to be fast enough for GRO to have much of an
effect.  But a peer on the wired network can trigger GRO and this
produces an skb that exceeds the burst size.

Is this a bug in sch_tbf, or should I accept it as a limitation?  It
seems like it should do GSO on entry to the queue if necessary.

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.

--=-c0NvjAPxwRqUn9cWJ6Ia
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUZq/u+e/yOyVhhEJAQroWw/7B5ZPOALcwjsF86DxCmH/6gmAABz83ojl
MvIS2fdIXJ/uRIQEAhd9BMLR9ijACTiGg0hpeGCUQNS3TDD2ASQvG467S4LxPtWY
y0hKR+DdujKaHLE88jpjUerqh80o2VRcoFgaA0n7UvOW/z47dwWp1688xBbB4Yqw
2CnD7ZmxdsRwrIgZDBUDa0oPCqYbORurrCf69ZEELnkOVbaiM/trjjLpFSJppDLV
fS07NVguhV4q383S3CxpyGCPbxZMquAZwaoe/sUbL6ggZaGbrrypFJIEDPKtl+GU
JL/1920PXh2TRuDZJBW4TpsENsbdCPf/fnuD4cUrm6KY2UkgZbUYnXv5Gz5CLDoL
QJ26lKproCJFxKghtFY8a6ncdzNXDYFynMG+NOnkdma1xI7SLRfHEjy84j99uoKS
qYTB/CGv2vVtKf++gguFZ2hPWMH02euk/8lYGgGr6mdOOFF46yJ3W+8JOOjRp94d
cuWHXFOhM7qQW4PMzmjJUCfiBlDUY5O95gSy715jZATubAnYPP0JhEQXKYKbGmNa
iOgoP3GU/i1zmIU5b8e1xRewmbEKg9Dw403uts9Ev3KlxE/9xhCD1M5V5GEbWB7v
3puOIVJzwGAk0wCCeH7nUF6fIgIbWcS4TspyqvAWStmGyMWHwm2OwbvRPv61GHwk
GT6sexrDeRo=
=f4cH
-----END PGP SIGNATURE-----

--=-c0NvjAPxwRqUn9cWJ6Ia--
