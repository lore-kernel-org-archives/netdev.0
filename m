From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Packet capture and Bonding asymmetries
Date: Wed, 9 Jun 2010 22:27:04 +0100
Message-ID: <20100609212704.GY11110@cel.leo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Wn0J+vu9+NMIXK57"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:57933 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752125Ab0FIV1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 17:27:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Wn0J+vu9+NMIXK57
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

We use ethernet bonding to bond eth0 + eth1 into bond0, in an
active/standby failover pair. Given this is for redundancy, we put the
two physical ethernet links into different switches that follow
different paths in the data centre.

Given this topology, it can be really useful to know which physical
interface packets are received on. It seems the bonding driver doesn't
make this happen:

  # uname -r
  2.6.31.12

  # head -1 /proc/net/bonding/bond0=20
  Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

  # pktdump -f icmp
  [15:27:12] RX(bond0): ICMP| 192.168.57.6->192.168.57.1 echo-request seq=
=3D1
  [15:27:12] TX(bond0): ICMP| 192.168.57.1->192.168.57.6 echo-reply seq=3D1
  [15:27:12] TX(eth0): ICMP| 192.168.57.1->192.168.57.6 echo-reply seq=3D1

I.e. when we transmit we see both the virtual bond0 interface and the
physical eth0 doing so; but when we receive only the virtual bond0
appears to do so.

I believe this should be fixable with a one-line patch; just adding a
call to netif_nit_deliver(skb) from within the bonding driver... though
just offhand I'm unable to find exactly the line where packets received
on slaves gets passed up to the master. :)

Can anyone advise on the sensibility or otherwise of this plan? I really
would like the behaviour where I can see how packets are received - is
this a good plan to acheive it?

I may sometime have a hack at writing a patch for this anyway, presuming
no major objections...

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--Wn0J+vu9+NMIXK57
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMEAcovLS2TC8cBo0RAtUBAJ9nNbb6greft9Z+xmF2OfmuQ1dU4QCfTFya
PrwoQqSc7E25GUgon6A96ak=
=UzJX
-----END PGP SIGNATURE-----

--Wn0J+vu9+NMIXK57--
