From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH 2.6] Re: xfrm_user.c doesn't use NLMSG_F_MULTI
Date: Fri, 15 Oct 2004 21:14:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015191444.GM17516@obroa-skai.de.gnumonks.org>
References: <20041013080705.GB3387@obroa-skai.de.gnumonks.org> <E1CI2I2-0001sI-00@gondolin.me.apana.org.au> <20041014105757.GB12694@obroa-skai.de.gnumonks.org> <20041014110742.GA7910@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zHDeOHGDnzKksZSU"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20041014110742.GA7910@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--zHDeOHGDnzKksZSU
Content-Type: multipart/mixed; boundary="kaF1vgn83Aa7CiXN"
Content-Disposition: inline


--kaF1vgn83Aa7CiXN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 14, 2004 at 09:07:42PM +1000, Herbert Xu wrote:
> On Thu, Oct 14, 2004 at 12:57:57PM +0200, Harald Welte wrote:
> >=20
> > Ok, would you like to receive a patch that fixes the xfrm netlink
> > interface to be more compatible with the netlink manpage and what
> > rtnetlink does?
>=20
> I have no objections at all :)
>=20
> While you're at it please fix the other netlink users as well, e.g.,
> tcp_diag.

I did a short grep for netlink_dump and the only two places where
F_MULTI wasn't used was tcp_diag.c and xfrm_user.c.  Please let me know
if you know any other cases.

Pleae find a proposed patch attached to this email.  I didn't have the
means to test it at this point, though.. but it's pretty
straightforward.  Please consider applying it...

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--kaF1vgn83Aa7CiXN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="2.6.9-rc3-bk9-netlink_f_multi.patch"
Content-Transfer-Encoding: quoted-printable

Fix xfrm_user.c and tcp_diag.c netlink dump:  We have to set NLM_F_MULTI.

Signed-off-by: Harald Welte <laforge@gnumonks.org>

--- linux-2.6.9-rc3-bk9-test/net/ipv4/tcp_diag.c	2004-10-10 14:01:47.000000=
000 +0200
+++ linux-2.6.9-rc3-bk9-test-xfrm_netlink/net/ipv4/tcp_diag.c	2004-10-15 21=
:02:19.000000000 +0200
@@ -97,7 +97,7 @@
 }
=20
 static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
-			int ext, u32 pid, u32 seq)
+			int ext, u32 pid, u32 seq, u16 nlmsg_flags)
 {
 	struct inet_opt *inet =3D inet_sk(sk);
 	struct tcp_opt *tp =3D tcp_sk(sk);
@@ -224,6 +224,7 @@
 	}
=20
 	nlh->nlmsg_len =3D skb->tail - b;
+	nlh->nlmsg_flags =3D nlmsg_flags;
 	return skb->len;
=20
 nlmsg_failure:
@@ -280,7 +281,7 @@
=20
 	if (tcpdiag_fill(rep, sk, req->tcpdiag_ext,
 			 NETLINK_CB(in_skb).pid,
-			 nlh->nlmsg_seq) <=3D 0)
+			 nlh->nlmsg_seq, 0) <=3D 0)
 		BUG();
=20
 	err =3D netlink_unicast(tcpnl, rep, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
@@ -506,7 +507,8 @@
 					goto next_listen;
 				if (tcpdiag_fill(skb, sk, r->tcpdiag_ext,
 						 NETLINK_CB(cb->skb).pid,
-						 cb->nlh->nlmsg_seq) <=3D 0) {
+						 cb->nlh->nlmsg_seq,
+						 NLM_F_MULTI) <=3D 0) {
 					tcp_listen_unlock();
 					goto done;
 				}
@@ -550,7 +552,8 @@
 				goto next_normal;
 			if (tcpdiag_fill(skb, sk, r->tcpdiag_ext,
 					 NETLINK_CB(cb->skb).pid,
-					 cb->nlh->nlmsg_seq) <=3D 0) {
+					 cb->nlh->nlmsg_seq,
+					 NLM_F_MULTI) <=3D 0) {
 				read_unlock_bh(&head->lock);
 				goto done;
 			}
@@ -575,7 +578,8 @@
 					goto next_dying;
 				if (tcpdiag_fill(skb, sk, r->tcpdiag_ext,
 						 NETLINK_CB(cb->skb).pid,
-						 cb->nlh->nlmsg_seq) <=3D 0) {
+						 cb->nlh->nlmsg_seq,
+						 NLM_F_MULTI) <=3D 0) {
 					read_unlock_bh(&head->lock);
 					goto done;
 				}
diff -Nru linux-2.6.9-rc3-bk9-test/net/xfrm/xfrm_user.c linux-2.6.9-rc3-bk9=
-test-xfrm_netlink/net/xfrm/xfrm_user.c
--- linux-2.6.9-rc3-bk9-test/net/xfrm/xfrm_user.c	2004-10-10 14:01:03.00000=
0000 +0200
+++ linux-2.6.9-rc3-bk9-test-xfrm_netlink/net/xfrm/xfrm_user.c	2004-10-15 2=
0:55:58.000000000 +0200
@@ -351,7 +351,10 @@
 	nlh =3D NLMSG_PUT(skb, NETLINK_CB(in_skb).pid,
 			sp->nlmsg_seq,
 			XFRM_MSG_NEWSA, sizeof(*p));
-	nlh->nlmsg_flags =3D 0;
+	if (count !=3D 0)
+		nlh->nlmsg_flags =3D NLM_F_MULTI;
+	else
+		nlh->nlmsg_flags =3D 0;
=20
 	p =3D NLMSG_DATA(nlh);
 	copy_to_user_state(x, p);

--kaF1vgn83Aa7CiXN--

--zHDeOHGDnzKksZSU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBcCGjXaXGVTD0i/8RAnLCAJ9u3iP1+zFmTwDUoyj+sQR8UvBJvgCfebGt
VmxCtQJbqLZsmebm6GFEWCU=
=mxtt
-----END PGP SIGNATURE-----

--zHDeOHGDnzKksZSU--
