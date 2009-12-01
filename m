From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] net: fix an array index overflow
Date: Tue, 01 Dec 2009 09:48:56 +0100
Message-ID: <4B14D878.1070802@gmail.com>
References: <20091201082901.4678.16688.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753917AbZLAItK@vger.kernel.org>
In-Reply-To: <20091201082901.4678.16688.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amerigo Wang a =E9crit :
> Don't use the address of an out-of-boundary element.
>=20
> Maybe this is not harmful at runtime, but it is still
> good to improve it.

Why ?

for (ptr =3D start; ptr < end; ptr++) {}

is valid, even if 'end' is 'outside of bounds'

It also works if start =3D=3D end.

>=20
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
>=20
> ---
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 57737b8..2669361 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1586,7 +1586,7 @@ static int __init inet_init(void)
>  #endif
> =20
>  	/* Register the socket-side information for inet_create. */
> -	for (r =3D &inetsw[0]; r < &inetsw[SOCK_MAX]; ++r)
> +	for (r =3D &inetsw[0]; r <=3D &inetsw[SOCK_MAX-1]; ++r)
>  		INIT_LIST_HEAD(r);
> =20
>  	for (q =3D inetsw_array; q < &inetsw_array[INETSW_ARRAY_LEN]; ++q)
> --

I wonder why you want to 'fix' this loop and let following loop unchang=
ed...

	for (q =3D inetsw_array; q < &inetsw_array[INETSW_ARRAY_LEN]; ++q)
		inet_register_protosw(q);

If this really hurts your eyes, why not using basic loops ?

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7d12c6a..476cda7 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1540,8 +1540,7 @@ static struct packet_type ip_packet_type __read_m=
ostly =3D {
 static int __init inet_init(void)
 {
 	struct sk_buff *dummy_skb;
-	struct inet_protosw *q;
-	struct list_head *r;
+	int i;
 	int rc =3D -EINVAL;
=20
 	BUILD_BUG_ON(sizeof(struct inet_skb_parm) > sizeof(dummy_skb->cb));
@@ -1584,11 +1583,11 @@ static int __init inet_init(void)
 #endif
=20
 	/* Register the socket-side information for inet_create. */
-	for (r =3D &inetsw[0]; r < &inetsw[SOCK_MAX]; ++r)
-		INIT_LIST_HEAD(r);
+	for (i =3D 0; i < SOCK_MAX; i++)
+		INIT_LIST_HEAD(&inetsw[i]);
=20
-	for (q =3D inetsw_array; q < &inetsw_array[INETSW_ARRAY_LEN]; ++q)
-		inet_register_protosw(q);
+	for (i =3D 0; i < INETSW_ARRAY_LEN; i++)
+		inet_register_protosw(&inetsw_array[i]);
=20
 	/*
 	 *	Set the ARP module up
