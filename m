From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 3 Aug 2010 15:11:10 +0100
Message-ID: <20100803141110.GT11110@cel.leo>
References: <20100803070426.GN11110@cel.leo>
 <20100803.001809.25133218.davem@davemloft.net>
 <87mxt3etut.fsf@basil.nowhere.org>
 <20100803.060754.26959298.davem@davemloft.net>
 <20100803140539.GE31096@basil.fritz.box>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vSGBLC0MgRtV7sTP"
Cc: David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:33555 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756470Ab0HCOLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 10:11:12 -0400
Content-Disposition: inline
In-Reply-To: <20100803140539.GE31096@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vSGBLC0MgRtV7sTP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 03, 2010 at 04:05:39PM +0200, Andi Kleen wrote:
> Well you could generalize it, like "SKIP headers where length=20
> is at offset X and type at offset Y"=20

Except that doesn't work for IPv6.

Some IPv6 headers are implied-length; their length never appears in the
packet. You have to "just know".

Some IPv6 headers store their length somewhere in the header body.
Different headers use different offsets within the body.

Some IPv6 headers do not make their length known on the wire -at all-,
such as IPsec's AH. Only the IPsec endpoints know how long this header
is.

This is what makes IPv6 -really- difficult to actually parse like this.

Ignoring even for a moment the impossible ones (IPsec's AH and ESP), the
rest of the headers end up becoming a giant lookup table, analogous to:

  switch(hdrtype)
  {
     case 1:
       length =3D someconst; break;
     case 2:
       length =3D someotherconst; break;
     case 3:
       length =3D b[someoffset]; break;
     ...
  }


This is why I wanted a LOOP instruction, the above switch code could
then be written -once- in BPF and LOOP'ed over to find the required
header. Instead, that loop must be statically unrolled some number of
times into an n-times-longer program script of less-than-equivalent
power. E.g. tcpdump/libpcap unrolls it a statically-configured 6 times,
meaning if the packet is particularly large, and the header comes 7th,
you'll never see it. My LOOP idea would mean the code is run once for
every header in the packet, regardless how many there were.

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--vSGBLC0MgRtV7sTP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMWCN+vLS2TC8cBo0RAiuyAKCfSumcJbLDJN453ocbCnowsbyjJACg+Uwj
sDaZLODMHU3zgw/XAJoAoJ0=
=7T2w
-----END PGP SIGNATURE-----

--vSGBLC0MgRtV7sTP--
