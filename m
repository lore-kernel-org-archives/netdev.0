From: nhorman@redhat.com
Subject: Re: [Patch] sctp: add receive buffer accounting to sctp (fwd)
Date: Fri, 11 Mar 2005 10:48:36 -0500
Message-ID: <20050311154836.GC19052@hmsendeavour.rdu.redhat.com>
References: <Pine.LNX.4.61.0503030027590.8076@localhost.localdomain> <20050309211632.6f70fe41.davem@davemloft.net> <20050310120803.GA6341@hmsendeavour.rdu.redhat.com> <20050310154342.GG6341@hmsendeavour.rdu.redhat.com> <20050310183856.08cb5f7b.davem@davemloft.net> <20050311125724.GB18122@hmsendeavour.rdu.redhat.com> <Pine.LNX.4.61.0503111947470.6007@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
Cc: nhorman@redhat.com, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
To: Sridhar Samudrala <sri@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0503111947470.6007@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 11, 2005 at 07:58:50PM +0530, Sridhar Samudrala wrote:
> Neil,
>=20
> I guess you may not have tried to compile SCTP with this patch.=20
> 2.4 struct sock members do not have sk_ prefix.
> So you need to replace sk_rmem_alloc and sk_rcvbuf with rmem_alloc and
> rcvbuf.
>=20
No, I compiled the kernel, I just forgot to enable CONFIG_IP_SCTP.  I must =
have
booted to a 2.6 kernel on my dev box by accident when I ran the tests.  I'm=
 a
dummy, sorry :).  I'll repost the patch (after I veryify that I build and t=
est
the actual code).

Regards,=20
Neil


> Thanks
> Sridhar
>=20
> On Fri, 11 Mar 2005 nhorman@redhat.com wrote:
>=20
> >On Thu, Mar 10, 2005 at 06:38:56PM -0800, David S. Miller wrote:
> >>On Thu, 10 Mar 2005 10:43:42 -0500
> >>nhorman@redhat.com wrote:
> >>
> >>>Repost of my ealier rcvbuf patch.  No changes, but rediffed to apply=
=20
> >>>cleanly to
> >>>the head of the bitkeeper tree.  Passes all lksctp regression tests
> >>
> >>Applied, thanks Neil.
> >
> >You're quite welcome.  Heres the 2.4 version of the same patch that you
> >requested.  Applies clean against the bitkeeper head.
> >
> >Signed-off-by: Neil Horman <nhorman@redhat.com>
> >
> >[nhorman@hmsendeavour kernel]$ diffstat linux-2.4-sctp.rcvbuf.patch
> >input.c |   21 +++++++++++++++++++++
> >1 files changed, 21 insertions(+)
> >
> >
> >--- linux-2.4-sctp/net/sctp/input.c.orig	2005-03-10=20
> >13:36:49.000000000 -0500
> >+++ linux-2.4-sctp/net/sctp/input.c	2005-03-10 13:51:25.000000000 -0500
> >@@ -100,6 +100,21 @@
> >	return 0;
> >}
> >
> >+/* The free routine for skbuffs that sctp receives */
> >+static void sctp_rfree(struct sk_buff *skb)
> >+{
> >+	atomic_sub(sizeof(struct sctp_chunk),&skb->sk->sk_rmem_alloc);
> >+	sock_rfree(skb);
> >+}
> >+
> >+/* The ownership wrapper routine to do receive buffer accounting */
> >+static void sctp_rcv_set_owner_r(struct sk_buff *skb, struct sock *sk)
> >+{
> >+	skb_set_owner_r(skb,sk);
> >+	skb->destructor =3D sctp_rfree;
> >+	atomic_add(sizeof(struct sctp_chunk),&sk->sk_rmem_alloc);
> >+}
> >+
> >/*
> > * This is the routine which IP calls when receiving an SCTP packet.
> > */
> >@@ -183,6 +198,10 @@
> >	rcvr =3D asoc ? &asoc->base : &ep->base;
> >	sk =3D rcvr->sk;
> >
> >+	if ((sk) && (atomic_read(&sk->sk_rmem_alloc) >=3D sk->sk_rcvbuf))
> >+		goto discard_release;
> >+
> >+
> >	if (!ipsec_sk_policy(sk, skb))
> >		goto discard_release;
> >
> >@@ -197,6 +216,8 @@
> >		goto discard_release;
> >	}
> >
> >+	sctp_rcv_set_owner_r(skb,sk);
> >+
> >	/* Remember what endpoint is to handle this packet. */
> >	chunk->rcvr =3D rcvr;
> >
> >
>=20
> --=20

--=20
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/

--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFCMb3TM+bEoZKnT6ERApscAJ0Qzbdd7+CDOM5Bcc8MgyEBDL8gRQCcCqfE
/wBHfr9ZB1UgFhThIuoIwQs=
=lL2g
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--
