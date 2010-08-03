From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: RFC: New BPF 'LOOP' instruction
Date: Tue, 3 Aug 2010 14:34:43 +0100
Message-ID: <20100803133442.GQ11110@cel.leo>
References: <20100803070426.GN11110@cel.leo>
 <20100803.001809.25133218.davem@davemloft.net>
 <87mxt3etut.fsf@basil.nowhere.org>
 <20100803.060754.26959298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="8YpBv3tE2B8vKY6r"
Cc: andi@firstfloor.org
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:43088 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753991Ab0HCNeo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 09:34:44 -0400
Content-Disposition: inline
In-Reply-To: <20100803.060754.26959298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--8YpBv3tE2B8vKY6r
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 03, 2010 at 06:07:54AM -0700, David Miller wrote:
> > How about simply adding a "skip ipv6 extension headers until header type
> > X" opcode?
> >=20
> > I bet that would solve most of the problems here in practice.
>=20
> BPF really should not have protocol specific opcodes.

You mean like the LD MSH instruction, the "load a byte, mask by 0x0f then
shift up two bits" one that's specific to fetching an IPv4 header length?

Lets look at this another way around then. Ignore my LOOP instruction
idea.

Already -right now- BPF has the SKF_NET_OFF + SFK_AD_PROTO information.
Lets consider an Ethernet/IP/TCP packet we've received:

[Ethernet header | IP header | TCP header ....]
^                ^
|                |
|                +-- SKF_NET_OFF is here
+-- 0 is here

SKF_AD_PROTO =3D=3D 0x0800 (IPv4)


What if we added a new constant SKF_TRANS_OFF to store the start address
of the transport header, and a new SKF_AD storage area for the transport
protocol:

[Ethernet header | IP header | TCP header ....]
^                ^           ^
|                |           |
|                |           +--  SKF_TRANS_OFF is here
|                +-- SKF_NET_OFF is here
+-- 0 is here

SKF_AD_PROTO =3D=3D 0x0800 (IPv4)
SKF_AD_TRANSPROTO =3D=3D 6 (IPPROTO_TCP)


Now it's easy to see how IPv6 header processing fits into this. No
longer do we have to calculate the length of the IPv6 header, we can
just start off directly looking at the TCP header. I wanted TCP port 80;
no problem:

    LD BYTE[SKF_AD_PROTO]
    JEQ 0x0800, 1, #reject
    JEQ 0x86dd, 0, #reject
    LD BYTE[SKF_AD_TRANSPROTO]
    JEQ 6, 0, #reject
    LD BYTE[SKF_NET_OFF+0]
    JEQ 80, #accept, 0
    LD BYTE[SKF_NET_OFF+2]
    JEQ 80, 0, #reject
  accept:
    LD len
    RET A
  reject:
    RET 0

Hey presto; I've just accepted TCP src or dest port 80 on IPv4 or IPv6
without having any code to actually -parse- IPv4 or '6 headers.


Does this sound workable?

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--8YpBv3tE2B8vKY6r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMWBryvLS2TC8cBo0RAnKYAJwJN0QhJ8JcrdbygnYaKSB8MQwZcACgucnI
SleXpiKLva+HkX/q7oY/tF0=
=e074
-----END PGP SIGNATURE-----

--8YpBv3tE2B8vKY6r--
