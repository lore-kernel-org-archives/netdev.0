From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: inet_hash_connect: source port allocation
Date: Mon, 29 Nov 2010 11:38:58 -0800
Message-ID: <20101129113858.23fc6f1e@nehalam>
References: <4CF3DD02.90906@oracle.com>
	<1291051560.3435.1198.camel@edumazet-laptop>
	<4CF3F114.2070108@oracle.com>
	<1291056363.3435.1338.camel@edumazet-laptop>
	<1291057655.3435.1363.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Haxby <john.haxby@oracle.com>, NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54871 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751975Ab0K2TjB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 14:39:01 -0500
In-Reply-To: <1291057655.3435.1363.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Nov 2010 20:07:35 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 29 novembre 2010 =E0 19:46 +0100, Eric Dumazet a =E9crit :
> > Le lundi 29 novembre 2010 =E0 18:29 +0000, John Haxby a =E9crit :
> >=20
> > > Sorry,  I think I phrased my question badly.
> > >=20
> > > inet_csk_get_port() starts its search for a free port with
> > >=20
> > >      smallest_rover =3D rover =3D net_random() % remaining + low;
> > >=20
> > > whereas __inet_hash_connect() basically misses out that call to=20
> > > net_random() so you get a predictable port number.
> > >=20
> > > Is there any good reason why that is the case?
> > >=20
> >=20
> > It seems random select was done at bind() time only in commit
> > 6df716340da3a6f ([TCP/DCCP]: Randomize port selection)
> >=20
> > It probably should be done in autobind too.
> >=20
> >=20
>=20
> I'll test following patch :
>=20
> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> index 1b344f3..65c3702 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -466,20 +466,18 @@ int __inet_hash_connect(struct inet_timewait_de=
ath_row *death_row,
>  	int twrefcnt =3D 1;
> =20
>  	if (!snum) {
> -		int i, remaining, low, high, port;
> -		static u32 hint;
> -		u32 offset =3D hint + port_offset;
> +		int remaining, low, high, port;
>  		struct hlist_node *node;
>  		struct inet_timewait_sock *tw =3D NULL;
> =20
>  		inet_get_local_port_range(&low, &high);
>  		remaining =3D (high - low) + 1;
> +		port =3D net_random() % remaining + low;
> =20
>  		local_bh_disable();
> -		for (i =3D 1; i <=3D remaining; i++) {
> -			port =3D low + (i + offset) % remaining;
> +		do {
>  			if (inet_is_reserved_local_port(port))
> -				continue;
> +				goto next_nolock;
>  			head =3D &hinfo->bhash[inet_bhashfn(net, port,
>  					hinfo->bhash_size)];
>  			spin_lock(&head->lock);
> @@ -510,16 +508,17 @@ int __inet_hash_connect(struct inet_timewait_de=
ath_row *death_row,
>  			tb->fastreuse =3D -1;
>  			goto ok;
> =20
> -		next_port:
> +next_port:
>  			spin_unlock(&head->lock);
> -		}
> +next_nolock:
> +			if (++port > high)
> +				port =3D low;
> +		} while (--remaining > 0);
>  		local_bh_enable();
> =20
>  		return -EADDRNOTAVAIL;
> =20
>  ok:
> -		hint +=3D i;
> -
>  		/* Head lock still held and bh's disabled */
>  		inet_bind_hash(sk, tb, port);
>  		if (sk_unhashed(sk)) {
>=20

The original algorithm works better than uses if the port space is smal=
l
and being reused rapidly. Because the hint in the old algorithm is sequ=
ential ports
get used up sequentially.

You should look a the port randomization RFC. The earlier versions of t=
he
RFC were better before the BSD guys started putting in their non-scalab=
le
algorithms :-)


--=20
