From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: Packet capture and Bonding asymmetries
Date: Thu, 10 Jun 2010 13:10:12 +0100
Message-ID: <20100610121012.GB11110@cel.leo>
References: <20100609212704.GY11110@cel.leo>
 <17501.1276123951@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LkL3iLkxWcC48rNm"
To: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:57566 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758993Ab0FJMKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 08:10:14 -0400
Content-Disposition: inline
In-Reply-To: <17501.1276123951@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LkL3iLkxWcC48rNm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 09, 2010 at 03:52:31PM -0700, Jay Vosburgh wrote:
> >I believe this should be fixable with a one-line patch; just adding a
> >call to netif_nit_deliver(skb) from within the bonding driver... though
> >just offhand I'm unable to find exactly the line where packets received
> >on slaves gets passed up to the master. :)
>=20
> 	This won't work, because bonding does not have a receive
> function in the usual sense.  Instead, the slaves do their normal
> receive logic, and then in __netif_receive_skb, packets are assigned to
> the bonding master if the device is a slave.

Ah; that would explain why I'm having trouble finding it then :)

> 	For your own private testing, you could add a call to
> __netif_nit_deliver in netif_receive_skb prior to this part:
<snip>

Rather than put it -before- that part, why not inside the if (master)
arm?

-----

diff -urp linux-2.6.33.2.orig/net/core/dev.c linux-2.6.33.2/net/core/dev.c
--- linux-2.6.33.2.orig/net/core/dev.c  2010-04-02 00:02:33.000000000 +0100
+++ linux-2.6.33.2/net/core/dev.c       2010-06-10 12:58:24.000000000 +0100
@@ -2443,6 +2443,7 @@ int netif_receive_skb(struct sk_buff *sk
        orig_dev =3D skb->dev;
        master =3D ACCESS_ONCE(orig_dev->master);
        if (master) {
+               netif_nit_deliver(skb);
                if (skb_bond_should_drop(skb, master))
                        null_or_orig =3D orig_dev; /* deliver only exact ma=
tch */
                else

-----

(This patch doesn't quite apply cleanly to latest source but if that
approach seems OK I'll rebuild it and submit properly)

> 	This will give you multiple captures of the same packet, as is
> seen for transmit (i.e., one on the slave, one on the bond).  For
> non-bonding devices, tcpdump will see each packet twice on the same
> device, so it's not really suitable for general use.

I was hoping for a proper permanent solution - often it would have been
useful to me, that eth0 appears to receive traffic properly to tcpdump
et.al., as well as transmitting.

> 	If merely knowing the traffic counts is sufficient, the slaves
> do count their received packets individually, so, e.g., ifconfig will
> show how many packets a particular slave has received, regardless of
> what bonding does with them.  The packet counts for the bonding device
> itself are merely a sum of all of its slaves.

I had noticed the counters, yes. That has been useful on occasions. But
at other times we've really wanted to be able to see the actual traffic.

> 	Also, generally speaking, IP protocol traffic that arrives on an
> inactive bonding slave is not delivered.  If you're using active-backup
> mode, and your traffic makes it through, it likely arrived on the active
> slave.

Useful though that is, sometimes it's the fact that traffic appears on a
non-active slave, which is interesting, and we'd like to see what
traffic that was.

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--LkL3iLkxWcC48rNm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMENYjvLS2TC8cBo0RAoBUAKDyHhU+FnZylYo7X9Mtot7uyVGRQwCg+0Hj
8pBj+BTXLJpY816HQ28MyCQ=
=xjjl
-----END PGP SIGNATURE-----

--LkL3iLkxWcC48rNm--
