From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.6] fix NLM_F_MULTI in tcp_diag and xfrm_user (was Re: BTW)
Date: Wed, 27 Oct 2004 10:51:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027085141.GW18934@sunbeam.de.gnumonks.org>
References: <20041027074307.GT18934@sunbeam.de.gnumonks.org> <E1CMjAM-0002aJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gwj7ZfuSpvxprVSd"
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CMjAM-0002aJ-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gwj7ZfuSpvxprVSd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Sorry for submitting incomplete/stupid patches, but as indicated before,
I'm not familiar with that code at all.

> This doesn't set it for the tw sockets.  So just set it at the top
> of the function instead.

done

> Yuck.  Please put this into xfrm_dump_info.

done.

> And it would be good to fix the other dumper in this file (xfrm_dump_poli=
cy)
> as well.

done.


diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-bk7/net/ipv4/tcp_diag.c linux-2.6.9-bk7-netlink_f_multi/net/ipv4/tcp_d=
iag.c
--- linux-2.6.9-bk7/net/ipv4/tcp_diag.c	2004-10-22 18:18:52.000000000 +0200
+++ linux-2.6.9-bk7-netlink_f_multi/net/ipv4/tcp_diag.c	2004-10-27 10:46:21=
=2E677098691 +0200
@@ -108,7 +108,7 @@
 }
=20
 static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
-			int ext, u32 pid, u32 seq)
+			int ext, u32 pid, u32 seq, u16 nlmsg_flags)
 {
 	struct inet_opt *inet =3D inet_sk(sk);
 	struct tcp_opt *tp =3D tcp_sk(sk);
@@ -120,6 +120,7 @@
 	unsigned char	 *b =3D skb->tail;
=20
 	nlh =3D NLMSG_PUT(skb, pid, seq, TCPDIAG_GETSOCK, sizeof(*r));
+	nlh->nlmsg_flags =3D nlmsg_flags;
 	r =3D NLMSG_DATA(nlh);
 	if (sk->sk_state !=3D TCP_TIME_WAIT) {
 		if (ext & (1<<(TCPDIAG_MEMINFO-1)))
@@ -291,7 +292,7 @@
=20
 	if (tcpdiag_fill(rep, sk, req->tcpdiag_ext,
 			 NETLINK_CB(in_skb).pid,
-			 nlh->nlmsg_seq) <=3D 0)
+			 nlh->nlmsg_seq, 0) <=3D 0)
 		BUG();
=20
 	err =3D netlink_unicast(tcpnl, rep, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
@@ -497,7 +498,7 @@
 	}
=20
 	return tcpdiag_fill(skb, sk, r->tcpdiag_ext, NETLINK_CB(cb->skb).pid,
-			    cb->nlh->nlmsg_seq);
+			    cb->nlh->nlmsg_seq, NLM_F_MULTI);
 }
=20
 static int tcpdiag_fill_req(struct sk_buff *skb, struct sock *sk,
@@ -511,6 +512,7 @@
 	long tmo;
=20
 	nlh =3D NLMSG_PUT(skb, pid, seq, TCPDIAG_GETSOCK, sizeof(*r));
+	nlh->nlmsg_flags =3D NLM_F_MULTI;
 	r =3D NLMSG_DATA(nlh);
=20
 	r->tcpdiag_family =3D sk->sk_family;
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-bk7/net/xfrm/xfrm_user.c linux-2.6.9-bk7-netlink_f_multi/net/xfrm/xfrm=
_user.c
--- linux-2.6.9-bk7/net/xfrm/xfrm_user.c	2004-10-18 23:54:32.000000000 +0200
+++ linux-2.6.9-bk7-netlink_f_multi/net/xfrm/xfrm_user.c	2004-10-27 10:45:0=
9.780597181 +0200
@@ -332,6 +332,7 @@
 	struct sk_buff *in_skb;
 	struct sk_buff *out_skb;
 	u32 nlmsg_seq;
+	u16 nlmsg_flags;
 	int start_idx;
 	int this_idx;
 };
@@ -351,7 +352,7 @@
 	nlh =3D NLMSG_PUT(skb, NETLINK_CB(in_skb).pid,
 			sp->nlmsg_seq,
 			XFRM_MSG_NEWSA, sizeof(*p));
-	nlh->nlmsg_flags =3D 0;
+	nlh->nlmsg_flags =3D sp->nlmsg_flags;
=20
 	p =3D NLMSG_DATA(nlh);
 	copy_to_user_state(x, p);
@@ -386,6 +387,7 @@
 	info.in_skb =3D cb->skb;
 	info.out_skb =3D skb;
 	info.nlmsg_seq =3D cb->nlh->nlmsg_seq;
+	info.nlmsg_flags =3D NLM_F_MULTI;
 	info.this_idx =3D 0;
 	info.start_idx =3D cb->args[0];
 	(void) xfrm_state_walk(IPSEC_PROTO_ANY, dump_one_state, &info);
@@ -408,6 +410,7 @@
 	info.in_skb =3D in_skb;
 	info.out_skb =3D skb;
 	info.nlmsg_seq =3D seq;
+	info.nlmsg_flags =3D 0;
 	info.this_idx =3D info.start_idx =3D 0;
=20
 	if (dump_one_state(x, 0, &info)) {
@@ -743,7 +746,7 @@
 			sp->nlmsg_seq,
 			XFRM_MSG_NEWPOLICY, sizeof(*p));
 	p =3D NLMSG_DATA(nlh);
-	nlh->nlmsg_flags =3D 0;
+	nlh->nlmsg_flags =3D sp->nlmsg_flags;
=20
 	copy_to_user_policy(xp, p, dir);
 	if (copy_to_user_tmpl(xp, skb) < 0)
@@ -766,6 +769,7 @@
 	info.in_skb =3D cb->skb;
 	info.out_skb =3D skb;
 	info.nlmsg_seq =3D cb->nlh->nlmsg_seq;
+	info.nlmsg_flags =3D NLM_F_MULTI;
 	info.this_idx =3D 0;
 	info.start_idx =3D cb->args[0];
 	(void) xfrm_policy_walk(dump_one_policy, &info);
@@ -789,6 +793,7 @@
 	info.in_skb =3D in_skb;
 	info.out_skb =3D skb;
 	info.nlmsg_seq =3D seq;
+	info.nlmsg_flags =3D 0;
 	info.this_idx =3D info.start_idx =3D 0;
=20
 	if (dump_one_policy(xp, dir, 0, &info) < 0) {
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--gwj7ZfuSpvxprVSd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBf2GdXaXGVTD0i/8RAnTJAJ9TZBUfN+WZjRqFNbBw6G5JatYVQwCgpoaq
KxKAq290ZKeSvyF3IphTtRA=
=T/SS
-----END PGP SIGNATURE-----

--gwj7ZfuSpvxprVSd--
