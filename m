From: nhorman@redhat.com
Subject: Re: [Patch] sctp: add receive buffer accounting to sctp (fwd)
Date: Thu, 10 Mar 2005 10:43:42 -0500
Message-ID: <20050310154342.GG6341@hmsendeavour.rdu.redhat.com>
References: <Pine.LNX.4.61.0503030027590.8076@localhost.localdomain> <20050309211632.6f70fe41.davem@davemloft.net> <20050310120803.GA6341@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ytoMbUMiTKPMT3hY"
Cc: "David S. Miller" <davem@davemloft.net>,
        Sridhar Samudrala <sri@us.ibm.com>, netdev@oss.sgi.com,
        lksctp-developers@lists.sourceforge.net
To: nhorman@redhat.com
Content-Disposition: inline
In-Reply-To: <20050310120803.GA6341@hmsendeavour.rdu.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ytoMbUMiTKPMT3hY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Repost of my ealier rcvbuf patch.  No changes, but rediffed to apply cleanl=
y to
the head of the bitkeeper tree.  Passes all lksctp regression tests

Signed-off-by: Neil Horman <nhorman@redhat.com>

 input.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+)


--- linux-2.6-sctp/net/sctp/input.c.orig	2005-03-10 07:11:46.000000000 -0500
+++ linux-2.6-sctp/net/sctp/input.c	2005-03-10 07:18:25.000000000 -0500
@@ -100,6 +100,21 @@
 	return 0;
 }
=20
+/* The free routine for skbuffs that sctp receives */
+static void sctp_rfree(struct sk_buff *skb)
+{
+	atomic_sub(sizeof(struct sctp_chunk),&skb->sk->sk_rmem_alloc);
+	sock_rfree(skb);
+}
+
+/* The ownership wrapper routine to do receive buffer accounting */
+static void sctp_rcv_set_owner_r(struct sk_buff *skb, struct sock *sk)
+{
+	skb_set_owner_r(skb,sk);
+	skb->destructor =3D sctp_rfree;
+	atomic_add(sizeof(struct sctp_chunk),&sk->sk_rmem_alloc);
+}
+
 /*
  * This is the routine which IP calls when receiving an SCTP packet.
  */
@@ -183,6 +198,11 @@
 	rcvr =3D asoc ? &asoc->base : &ep->base;
 	sk =3D rcvr->sk;
=20
+	if ((sk) && (atomic_read(&sk->sk_rmem_alloc) >=3D sk->sk_rcvbuf)) {
+		goto discard_release;
+	}
+
+
 	/* SCTP seems to always need a timestamp right now (FIXME) */
 	if (skb->stamp.tv_sec =3D=3D 0) {
 		do_gettimeofday(&skb->stamp);
@@ -203,6 +223,8 @@
 		goto discard_release;
 	}
=20
+	sctp_rcv_set_owner_r(skb,sk);
+
 	/* Remember what endpoint is to handle this packet. */
 	chunk->rcvr =3D rcvr;
=20
--=20
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/

--ytoMbUMiTKPMT3hY
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFCMGstM+bEoZKnT6ERAg+5AJ9ff0925s3t6tAfyjmH/A3/+Wo6NgCeLdNI
cIt64C2uCN2DN+LgUDdix9w=
=7M4K
-----END PGP SIGNATURE-----

--ytoMbUMiTKPMT3hY--
