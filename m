From: Sven Anders <anders@anduras.de>
Subject: Possible bug in bonding driver (with VLAN in ALB mode)
Date: Tue, 21 Oct 2008 19:18:35 +0200
Message-ID: <48FE0EEB.7050503@anduras.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF73B6744E97044846F216687"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metropolitan.anduras.de ([80.237.200.159]:46896 "EHLO
	metropolitan.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538AbYJURkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 13:40:00 -0400
Received: from popper.anduras.local (p5491FE9E.dip.t-dialin.net [84.145.254.158])
	(Authenticated sender: anduras@anduras.priv)
	by metropolitan.anduras.de (Postfix) with ESMTP id 916291E556E
	for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 19:18:39 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by popper.anduras.local (Postfix) with ESMTP id 125066842
	for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 19:18:39 +0200 (CEST)
Received: from popper.anduras.local ([127.0.0.1])
	by localhost (popper.anduras.local [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 04629-03 for <netdev@vger.kernel.org>;
	Tue, 21 Oct 2008 19:18:38 +0200 (CEST)
Received: from [10.10.20.100] (applecar.anduras.local [10.10.20.100])
	by popper.anduras.local (Postfix) with ESMTP id 951CA6830
	for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 19:18:38 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF73B6744E97044846F216687
Content-Type: multipart/mixed;
 boundary="------------040705060901060904020906"

This is a multi-part message in MIME format.
--------------040705060901060904020906
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hello!

We possible found an error in the bonding driver, but we are
not sure. Maybe some can help us here and possibly find time
to test it themself.

We have the following problem using Bonding and VLAN with ALB-Mode:

Shortly after initiating "iperf" traffic from each of the client
to each other client, all traffic collapses to one line. This is
expected behaviour of the ALB algorithmus, but we did not expect
this traffic to stay there!

We would expect the traffic to be rebalanced between the bonding
slaves, but it never happens.

We analysed it down to the ARP replies the bonding interface should
receive.
After an ARP request was sent (by the router) in the "rlb_arp_xmit()",
the "rlb_choose_channel()" function is called and reserves a
(placeholder) entry in the hash table. According to the comment this
entry will be updated later by the corresponding ARP reply.
Shortly afterwards we see an ARP reply package on the VLAN interface.
But it is never processed by "rlb_arp_recv()", because this function
only receives arp packages from bond0 and so the entry is never
updated.

Now the question:
 We are not sure, if this is an error in the bonding driver.

 Maybe we are doing something wrong?
 Do we need to set some special /proc/sys/... values or
 have to configure some driver special?

 (And yes we want ALB, not LACP or anything other...!)

Here are some details about our network:
                                            +-----------+
                                       +----+  Client 1 |
 +----------+        +----------+------+    +-----------+     +----------=
-+
 |          +--------+          +-----------------------------+  Client 2=
 |
 |  Router  +--------+  Switch  |                             +----------=
-+
 |          +--------+          |                             +----------=
-+
 |          +--------+          +-----------------------------+  Client 3=
 |
 +----------+        +----------+------+    +-----------+     +----------=
-+
                                       +----+  Client 4 |
                                            +-----------+

Router:

  eth0
  eth1
  eth2
  eth3
  bond0    (Slaves: eth0, eth1, eth2, eth3)
  bond0.11  (VLAN 11) IP: 10.0.1.250/24
  bond0.12  (VLAN 12) IP: 10.0.2.250/24
  bond0.13  (VLAN 13) IP: 10.0.3.250/24
  bond0.14  (VLAN 14) IP: 10.0.4.250/24

  Routing for each subnet is enabled.

Switch (HP ProCurve):
  4 wires to router (one for each physical interface, eth0-3)
        each VLAN tagged (with 11,12,13,14)
  1 wire to each client, untagged VLANs

Client1:
  Network 10.0.1.1/24 GW: 10.0.1.250/24

Client2:
  Network 10.0.2.1/24 GW: 10.0.2.250/24

Client 3:
  ...

Software/Hardware:
 Linux: 2.6.26.2
  Network driver: e1000e (0.4.1.7-NAPI)
 Switch: HP ProCurve 5406zl

Bonding configuration:

 Ethernet Channel Bonding Driver: v3.2.5 (March 21, 2008)
 Bonding Mode: adaptive load balancing
 Primary Slave: None
 Currently Active Slave: eth11
 MII Status: up
 MII Polling Interval (ms): 100
 Up Delay (ms): 100
 Down Delay (ms): 100

Cheers
 Sven Anders

--=20
 Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campaign=

                                                 /\ Support plain text e-=
mail
 ANDURAS service solutions AG
 Innstra=DFe 71 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 5=
0-55

Rechtsform: Aktiengesellschaft - Sitz: Passau - Amtsgericht Passau HRB 60=
32
Mitglieder des Vorstands: Sven Anders, Marcus Junker
Vorsitzender des Aufsichtsrats: Mark Peters

--------------040705060901060904020906
Content-Type: text/x-vcard; charset=utf-8;
 name="anders.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="anders.vcf"

begin:vcard
fn:Sven Anders
n:Anders;Sven
org:ANDURAS AG;Research and Development
adr;quoted-printable:;;Innstra=3DC3=3D9Fe 71;Passau;Bavaria;94036;Germany=

email;internet:anders@anduras.de
title:Dipl. Inf.
tel;work:++49 (0)851 / 490 50 -0
tel;fax:++49 (0)851 / 590 50 - 55
x-mozilla-html:FALSE
url:http://www.anduras.de
version:2.1
end:vcard


--------------040705060901060904020906--

--------------enigF73B6744E97044846F216687
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFI/g7u5lKZ7Feg4EcRAs5GAJ9pZl6UJ15WXjQdxPek8KuYPFc0zQCeNnSF
59QLz1Ig+s564SRBsv9FO/g=
=SlPQ
-----END PGP SIGNATURE-----

--------------enigF73B6744E97044846F216687--
