From: Matthijs Kooijman <matthijs@stdin.nl>
Subject: dev->promiscuity can become negative in specific bridge + vlan
	configuration
Date: Mon, 31 Oct 2011 14:44:11 +0100
Message-ID: <20111031134411.GG14392@login.drsnuggles.stderr.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="glG7QM0/F4Gfd30i"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drsnuggles.stderr.nl ([94.142.244.14]:38458 "EHLO
	drsnuggles.stderr.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138Ab1JaOGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2011 10:06:50 -0400
Received: from login.drsnuggles.stderr.nl ([10.42.0.9] ident=mail)
	by mail.drsnuggles.stderr.nl with smtp (Exim 4.69)
	(envelope-from <matthijs@stdin.nl>)
	id 1RKs9r-00031w-7D
	for netdev@vger.kernel.org; Mon, 31 Oct 2011 14:44:12 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--glG7QM0/F4Gfd30i
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

(Please CC me, I'm not subscribed)

Hi folks,

while debugging an issue on a wireless access point running Linux, I
encountered an issue with the promiscuity of interfaces when combining
vlans and bridges. When configuring them in a specific order, the
dev->promiscuity can become negative and the IFF_PROMISC flag will be
wrong.

I've reproduced this on an old 2.6.26 kernel as well as an
3.1.0-rc10-ish kernel from misc.git.

When a VLAN device is configured to be promiscuous, the underlying
physical device must be promiscuous as well. This is achieved in two
ways:

1. When a vlan device is brought up and its IFF_PROMISC flag is set, the
   promiscuity of the underlying interface is increased. When a vlan
   device is brought down and its IFF_PROMISC flag is set, the
   promiscuity of the underlying interface is decreased. This happens in
   vlan_dev_open() and vlan_dev_stop().
2. When the IFF_PROMISC flag changes on the vlan device, the promiscuity
   value of the underlying device is increased or decreased, depending
   on the value of the flag. This happens in vlan_dev_change_rx_flags().

However, 2. also happens when the interface is not up, which is
incorrect AFAICS. If a VLAN interface, which is promiscuous, is first
brought down and then has its promiscious flag reset, the promiscuity of
the underlying physical interface will be decreased twice.

This problem can be demonstrated with the following commands. It should
happen on any hardware and all recent (andn not-so-recent) kernels,
AFAICS. I've added the relevant kernel output and some comments inline
below.

$ vconfig add eth0 10
Added VLAN with VID =3D=3D 10 to IF -:eth0:-
$ brctl addbr br0
$ ifconfig eth0.10 up
$ brctl addif br0 eth0.10
[14288.817391] device eth0.10 entered promiscuous mode
[14288.817397] device eth0 entered promiscuous mode
# eth0->promiscuity is now 1, as expected

$ ifconfig eth0.10 down
[14335.533019] device eth0 left promiscuous mode
# eth0->promiscuity is now 0, as expected

$ brctl delif br0 eth0.10
[14351.037666] device eth0.10 left promiscuous mode
# eth0->promiscuit is now -1!

$ brctl addif br0 eth0.10
[14383.549998] device eth0.10 entered promiscuous mode
# eth0->promiscuity is now 0, so eth0 is not entering promisciuous mode
# as it should

I've confirmed that the promiscuity actually gets set to -1 by some
added kernel prints on the 2.6.26 kernel, but the above behaviour is
also shown on the 3.1.0-rc10 kernel (which is consistent with
promiscuity diving below 0).

=46rom looking at the code, I assume the same story applies for the
IFF_ALLMULTI flag, but I've not tested this.


I'm working on a (simple) patch to fix this issue, by simply not
updating the promiscuity of the underlying interface if the vlan
interface is down. I'll reply to this message with the patch after I've
finished and tested it.

Gr.

Matthijs

--glG7QM0/F4Gfd30i
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk6upioACgkQz0nQ5oovr7ybiQCg4OG9CuNKJi81Gn6QAvaX7KRW
NmEAoLyTdyXRb+DKndyQj6+rvMG9gJOQ
=BUrD
-----END PGP SIGNATURE-----

--glG7QM0/F4Gfd30i--
