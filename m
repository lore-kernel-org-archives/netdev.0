From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Sun, 5 Jan 2014 00:38:40 +0100
Message-ID: <20140104233840.GD25828@order.stressinduktion.org>
References: <20131219144816.33310@gmx.com> <alpine.LFD.2.11.1401042143330.1598@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39520 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579AbaADXil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 18:38:41 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1401042143330.1598@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 04, 2014 at 09:55:51PM +0200, Julian Anastasov wrote:
>=20
> 	Hello,
>=20
> On Thu, 19 Dec 2013, Bob Falken wrote:
>=20
> > Hello, I have an issue after kernel 2.6.37 and above.
> > If i roll back to kernel 2.6.36.4 everything is fine.
> > if recive more than=C2=A04294967295 multicast packets, the kernel d=
oes not register the multicast packets. and multicast routing does not =
functioning.
>=20
> ...
>=20
> > I think there might be a variable in the kernel that get overflown.=
 though i cannot be sure as im not a programmer.=20
> >=20
> > Let me know if you need more debug information.
> >=20
> > Please help.=C2=A0=20
>=20
> 	As Hannes guessed, may be it is really the missing
> flags =3D FIB_LOOKUP_NOREF in ipmr_fib_lookup() when calling
> fib_rules_lookup(), we have an atomic_inc_not_zero() there that
> can stop to work after 4G lookups when rule's refcnt reaches 0.
> As result, fib_rules_lookup() can start to return -ESRCH.

I guess we should just try. I somehow forgot to look after that. Thanks
for reminding, Julian.

Bob, can you try with this patch again?

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 421a249..b9b3472 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -157,9 +157,12 @@ static struct mr_table *ipmr_get_table(struct net =
*net, u32 id)
 static int ipmr_fib_lookup(struct net *net, struct flowi4 *flp4,
 			   struct mr_table **mrt)
 {
-	struct ipmr_result res;
-	struct fib_lookup_arg arg =3D { .result =3D &res, };
 	int err;
+	struct ipmr_result res;
+	struct fib_lookup_arg arg =3D {
+		.result =3D &res,
+		.flags =3D FIB_LOOKUP_NOREF,
+	};
=20
 	err =3D fib_rules_lookup(net->ipv4.mr_rules_ops,
 			       flowi4_to_flowi(flp4), 0, &arg);
