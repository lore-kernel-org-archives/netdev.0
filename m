From: nhorman@redhat.com
Subject: Re: [Patch] sctp: add receive buffer accounting to sctp (fwd)
Date: Fri, 11 Mar 2005 07:57:24 -0500
Message-ID: <20050311125724.GB18122@hmsendeavour.rdu.redhat.com>
References: <Pine.LNX.4.61.0503030027590.8076@localhost.localdomain> <20050309211632.6f70fe41.davem@davemloft.net> <20050310120803.GA6341@hmsendeavour.rdu.redhat.com> <20050310154342.GG6341@hmsendeavour.rdu.redhat.com> <20050310183856.08cb5f7b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uZ3hkaAS1mZxFaxD"
Cc: nhorman@redhat.com, sri@us.ibm.com, netdev@oss.sgi.com,
        lksctp-developers@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050310183856.08cb5f7b.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--uZ3hkaAS1mZxFaxD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 10, 2005 at 06:38:56PM -0800, David S. Miller wrote:
> On Thu, 10 Mar 2005 10:43:42 -0500
> nhorman@redhat.com wrote:
>=20
> > Repost of my ealier rcvbuf patch.  No changes, but rediffed to apply cl=
eanly to
> > the head of the bitkeeper tree.  Passes all lksctp regression tests
>=20
> Applied, thanks Neil.

You're quite welcome.  Heres the 2.4 version of the same patch that you
requested.  Applies clean against the bitkeeper head.

Signed-off-by: Neil Horman <nhorman@redhat.com>

[nhorman@hmsendeavour kernel]$ diffstat linux-2.4-sctp.rcvbuf.patch=20
 input.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+)


--- linux-2.4-sctp/net/sctp/input.c.orig	2005-03-10 13:36:49.000000000 -0500
+++ linux-2.4-sctp/net/sctp/input.c	2005-03-10 13:51:25.000000000 -0500
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
@@ -183,6 +198,10 @@
 	rcvr =3D asoc ? &asoc->base : &ep->base;
 	sk =3D rcvr->sk;
=20
+	if ((sk) && (atomic_read(&sk->sk_rmem_alloc) >=3D sk->sk_rcvbuf))=20
+		goto discard_release;
+=20
+
 	if (!ipsec_sk_policy(sk, skb))
 		goto discard_release;
=20
@@ -197,6 +216,8 @@
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

--uZ3hkaAS1mZxFaxD
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFCMZWzM+bEoZKnT6ERAru2AJ9N1Fle7qQoSZtcSXaXZJ0c9UOFnACghdoe
BPoGpQWVuAI/Rimoo6zd/vo=
=WO73
-----END PGP SIGNATURE-----

--uZ3hkaAS1mZxFaxD--
