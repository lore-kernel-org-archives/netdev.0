From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: Packet capture and Bonding asymmetries
Date: Fri, 11 Jun 2010 13:18:38 +0100
Message-ID: <20100611121838.GC11110@cel.leo>
References: <20100609212704.GY11110@cel.leo>
 <17501.1276123951@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="stFzI3XAseUQ09UW"
To: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:51865 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751935Ab0FKMSk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 08:18:40 -0400
Content-Disposition: inline
In-Reply-To: <17501.1276123951@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--stFzI3XAseUQ09UW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 09, 2010 at 03:52:31PM -0700, Jay Vosburgh wrote:
> 	For your own private testing, you could add a call to
> __netif_nit_deliver in netif_receive_skb prior to this part:
>=20
>         master =3D ACCESS_ONCE(orig_dev->master);
>         if (master) {
>                 if (skb_bond_should_drop(skb, master))
>                         null_or_orig =3D orig_dev; /* deliver only exact =
match */
>                 else
>                         skb->dev =3D master;
>         }
>=20
> 	This will give you multiple captures of the same packet, as is
> seen for transmit (i.e., one on the slave, one on the bond).  For
> non-bonding devices, tcpdump will see each packet twice on the same
> device, so it's not really suitable for general use.

As per my last post, I've just tested the following patch and found it
to work just fine:

# pktdump -f "icmp" -n
[13:04:30] RX(eth0): ICMP| 192.168.56.1->192.168.56.6 echo-request seq=3D1
[13:04:30] RX(bond0): ICMP| 192.168.56.1->192.168.56.6 echo-request seq=3D1
[13:04:30] TX(bond0): ICMP| 192.168.56.6->192.168.56.1 echo-reply seq=3D1
[13:04:30] TX(eth0): ICMP| 192.168.56.6->192.168.56.1 echo-reply seq=3D1

I'll resubmit the patch properly for latest kernel version; this being
2.6.31.12 doesn't apply cleanly to upstream:

-----

--- linux-2.6.31.12-router/net/core/dev.c       2010-01-18 18:30:45.0000000=
00 +0000
+++ linux-2.6.31.12-router_leobonding/net/core/dev.c    2010-06-11 12:39:43=
=2E000000000 +0100
@@ -2265,6 +2265,7 @@
        null_or_orig =3D NULL;
        orig_dev =3D skb->dev;
        if (orig_dev->master) {
+               netif_nit_deliver(skb);
                if (skb_bond_should_drop(skb))
                        null_or_orig =3D orig_dev; /* deliver only exact ma=
tch */
                else

-----

This patch quite deliberately includes packets arriving from non-active
bonding slaves, because the intention of tcpdump, pktdump, et.al., is to
see "close to the wire"; a view of what's happening down that physical
ethernet cable.

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--stFzI3XAseUQ09UW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMEimdvLS2TC8cBo0RAm9WAKDP+H38PB7jLI9DDQrxkxdgsd3fvwCghD9M
YokyIjmY9Z5EJIJy4GWRqUo=
=JZq5
-----END PGP SIGNATURE-----

--stFzI3XAseUQ09UW--
