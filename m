From: Tom Parkin <tparkin@katalix.com>
Subject: Network namespace bugs in L2TP
Date: Wed, 12 Dec 2012 15:51:05 +0000
Message-ID: <20121212155105.GB2790@raven>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LKTjZJSUETSlgu2t"
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:48604 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854Ab2LLQAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 11:00:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LKTjZJSUETSlgu2t
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Eric,

I'm following up on this thread from later October in which you
pointed out some network namespace bugs in L2TP:

http://www.spinics.net/lists/netdev/msg214776.html

I use L2TP, and I'd like to help fix these bugs.  But I'm not very
conversant with network namespaces, and so I'm struggling to fully
appreciate the issues you pointed out previously.  Could you give me a
hand getting to grips with this?

So far I've tested L2TP within network namespaces, using both iproute2
to create sessions between two namespaces on the same host, and an
L2TP daemon running in a namespace to create sessions between two
hosts.  In both cases I've done a bit of trivial ping and iperf
testing using Ethernet pseudowires.

To make this work I've had to add a couple of trivial patches (see
below).

There are two things I'm uncertain about:

 1. Why do we need to change the namespace of the socket created in
    l2tp_tunnel_sock_create?  So far as I can tell, sock_create
    defaults to the namespace of the calling process.  Is the issue
    here that this code may run from a work queue or similar?

 2. You mentioned the need to keep track of sockets allocated within a
    namespace in order to be able to clean them up when the namespace
    is deleted.  Should we be keeping a list of sockets we create and
    then destroying them in the namespace pernet_ops exit function?

Thanks,
Tom

=46rom b9c095fdf32c895b79a5954020c4745fe5518141 Mon Sep 17 00:00:00 2001
=46rom: Tom Parkin <tparkin@katalix.com>
Date: Tue, 11 Dec 2012 13:03:48 +0000
Subject: [PATCH 1/2] l2tp: set netnsok flag for netlink messages

The L2TP netlink code can run in namespaces.  Set the netnsok flag in
genl_family to true to reflect that fact.
---
 net/l2tp/l2tp_netlink.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index bbba3a1..c1bab22 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -37,6 +37,7 @@ static struct genl_family l2tp_nl_family =3D {
 	.version	=3D L2TP_GENL_VERSION,
 	.hdrsize	=3D 0,
 	.maxattr	=3D L2TP_ATTR_MAX,
+	.netnsok	=3D true,
 };
=20
 /* Accessed under genl lock */
--=20
1.7.9.5

=46rom 13e9b0ddc48a16b384ffbf5ff64e6413cfa612f5 Mon Sep 17 00:00:00 2001
=46rom: Tom Parkin <tparkin@katalix.com>
Date: Wed, 12 Dec 2012 12:50:54 +0000
Subject: [PATCH 2/2] l2tp: prevent tunnel creation on netns mismatch

l2tp_tunnel_create is passed a pointer to the network namespace for the
tunnel, along with an optional file descriptor for the tunnel which may
be passed in from userspace via. netlink.

In the case where the file descriptor is defined, ensure that the namespace
associated with that socket matches the namespace explicitly passed to
l2tp_tunnel_create.
---
 net/l2tp/l2tp_core.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 1a9f372..f8d200b 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1528,6 +1528,13 @@ int l2tp_tunnel_create(struct net *net, int fd, int =
version, u32 tunnel_id, u32
 			       tunnel_id, fd, err);
 			goto err;
 		}
+
+		/* Reject namespace mismatches */
+		if (!net_eq(sock_net(sock->sk), net)) {
+			pr_err("tunl %hu: netns mismatch\n", tunnel_id);
+			err =3D -EBADF; /* TODO -- what value? */
+			goto err;
+		}
 	}
=20
 	sk =3D sock->sk;
--=20
1.7.9.5
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--LKTjZJSUETSlgu2t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJQyKfpAAoJEJSMBmUKuovQOG0H/1KXZN5y+J687Iguz1bLeVlc
hbyDbhsFREMV1UF3JM41MZsh3BfU/oYXgnOnSamGddC96t80y5PKyD0g/Ftnnuuh
dZoD63Xhy+9jadU2JeBTdJ9dI8Mpmw6qr+yi8Zr89A8x5F2WWo33SBV6gEjqnNR5
MQQIbHQYpKal5WyqfaYNeJRvEU1qd93AKinsUPkii+JqQvgN6u+CPIYF5sliCF1G
ggT2PSeXxhGvdrOF7+j482zfdBxSYWIC8J+uKpaw5mCJCEG8uHnr+AjrYZgjs9bp
NhM/p+zFjWz91F1FPbWBTC5PkDqMHhhgaCqKW8HWtvDZkzCl6xcFBb02imd3s4Y=
=dT7c
-----END PGP SIGNATURE-----

--LKTjZJSUETSlgu2t--
