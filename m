From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Subject: [PATCH] net/ipv6: Use GFP_ATOMIC when a lock is held
Date: Sun, 30 May 2010 22:11:28 +0200
Message-ID: <1275250288.2472.21.camel@edumazet-laptop>
References: <Pine.LNX.4.64.1005302147310.19253@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38254 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab0E3ULe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 16:11:34 -0400
In-Reply-To: <Pine.LNX.4.64.1005302147310.19253@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 30 mai 2010 =C3=A0 21:48 +0200, Julia Lawall a =C3=A9crit :
> From: Julia Lawall <julia@diku.dk>
>=20
> A spin lock is taken near the beginning of the enclosing function.
>=20
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
>=20
> // <smpl>
> @@
> @@
>=20
> spin_lock(...)
> ... when !=3D spin_unlock(...)
> -GFP_KERNEL
> +GFP_ATOMIC
> // </smpl>
>=20
> Signed-off-by: Julia Lawall <julia@diku.dk>
>=20
> ---
>  net/ipv6/sit.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff -u -p a/net/ipv6/sit.c b/net/ipv6/sit.c
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -358,7 +358,7 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t
>  		goto out;
>  	}
> =20
> -	p =3D kzalloc(sizeof(struct ip_tunnel_prl_entry), GFP_KERNEL);
> +	p =3D kzalloc(sizeof(struct ip_tunnel_prl_entry), GFP_ATOMIC);
>  	if (!p) {
>  		err =3D -ENOBUFS;
>  		goto out;

Nice catch, but what about allocating this outside of the locked
section ?

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e51e650..ff3dd84 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -340,6 +340,10 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct i=
p_tunnel_prl *a, int chg)
 	if (a->addr =3D=3D htonl(INADDR_ANY))
 		return -EINVAL;
=20
+	p =3D kzalloc(sizeof(struct ip_tunnel_prl_entry), GFP_KERNEL);
+	if (!p)
+		return -ENOBUFS;
+
 	spin_lock(&ipip6_prl_lock);
=20
 	for (p =3D t->prl; p; p =3D p->next) {
@@ -358,19 +362,16 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct =
ip_tunnel_prl *a, int chg)
 		goto out;
 	}
=20
-	p =3D kzalloc(sizeof(struct ip_tunnel_prl_entry), GFP_KERNEL);
-	if (!p) {
-		err =3D -ENOBUFS;
-		goto out;
-	}
=20
 	p->next =3D t->prl;
 	p->addr =3D a->addr;
 	p->flags =3D a->flags;
 	t->prl_count++;
 	rcu_assign_pointer(t->prl, p);
+	p =3D NULL;
 out:
 	spin_unlock(&ipip6_prl_lock);
+	kfree(p);
 	return err;
 }
=20


