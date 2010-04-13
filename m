From: Michal Svoboda <michal.svoboda@agents.felk.cvut.cz>
Subject: SO_REUSEADDR with UDP (again)
Date: Tue, 13 Apr 2010 11:34:08 +0200
Message-ID: <20100413093408.GA16595@myhost.felk.cvut.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6c2NcOVqGQ03X4Wi"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.felk.cvut.cz ([147.32.80.7]:54005 "EHLO
	relay.felk.cvut.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567Ab0DMKKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:10:55 -0400
Received: from labe.felk.cvut.cz (labe.felk.cvut.cz [147.32.85.34])
	by relay.felk.cvut.cz (8.14.3/8.14.3) with ESMTP id o3D9Y8R4049436
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 11:34:08 +0200 (CEST)
	(envelope-from michal.svoboda@agents.felk.cvut.cz)
Received: from [147.32.84.251] (mas16.felk.cvut.cz [147.32.84.166])
	by labe.felk.cvut.cz (8.13.8/8.13.8) with ESMTP id o3D9XriT064725
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 11:33:53 +0200 (CEST)
	(envelope-from michal.svoboda@agents.felk.cvut.cz)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hello,

(redirected here from LKML)

I found SO_REUSEADDR on UDP sockets to behave somewhat nasty. If you
create a UDP socket with that flag and bind it to a port, then anyone
doing the same later will "steal" your packets, ie.

1. process A binds to port 12345 with SO_REUSEADDR, packets to that port
   go to process A
2. process B binds to port 12345 with SO_REUSEADDR, packets to that port
   now go to process B
3. A dies, fires up again, packets go back to A
4. A dies, does not fire up, packets go to B, as if they were stacked

And this works even if A and B are owned by different users, thus anyone
can "steal" packets from anyone as long as they use SO_REUSEADDR.
However, in most programs that's the default.

Furthermore, one can lock-out a particular source from being "stolen" by
using connect() to that source, ie.

1. process A binds to port 12345 with SO_REUSEADDR, gets the packets
2. B does the same, gets the packets, but also connect()s to the source
   of the packets
3. A can now restart or try to bind again, but does not get the packets
   (from that source)

(I haven't tested the case if A also issues a connect() even if it does
not receive packets.)

All of this seems confusing to me, and the fact that users can steal
packets from each other seems like a mild security risk. I've found some
discussions about this from circa 2002, but the above cases were not
mentioned. So - a problem or not?


Michal Svoboda





--6c2NcOVqGQ03X4Wi
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvEOpAACgkQg/fU9pp1uX4EeACfV3DjmLuwDKCR+sUGSe8S849F
d+gAnjDhSMaJ0kzOY+/ctQrv1iv+ATnb
=Diqn
-----END PGP SIGNATURE-----

--6c2NcOVqGQ03X4Wi--
