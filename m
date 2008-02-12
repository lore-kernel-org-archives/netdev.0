From: "Jann Traschewski" <jann@gmx.de>
Subject: Re: [PATCH][AX25] ax25_route: make ax25_route_lock BH safe
Date: Tue, 12 Feb 2008 09:43:26 +0100
Message-ID: <000201c86d53$569297e0$453c822c@dg8ngn>
References: <000d01c86c8b$fd9e67d0$453c822c@dg8ngn> <20080211124251.GB3597@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Bernard Pidoux F6BVP'" <f6bvp@free.fr>,
	"'Ralf Baechle DL5RB'" <ralf@linux-mips.org>,
	<netdev@vger.kernel.org>
To: "'Jarek Poplawski'" <jarkao2@gmail.com>,
	"'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:38978 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750874AbYBLInc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 03:43:32 -0500
In-Reply-To: <20080211124251.GB3597@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applied on 2.6.24.2 and up without any problems/warnings since 12 hours=
=2E
Thanks,
Jann

> -----Urspr=FCngliche Nachricht-----
> Von: Jarek Poplawski [mailto:jarkao2@gmail.com]=20
> Gesendet: Montag, 11. Februar 2008 13:43
> An: David Miller
> Cc: Jann Traschewski; Bernard Pidoux F6BVP; Ralf Baechle=20
> DL5RB; netdev@vger.kernel.org
> Betreff: [PATCH][AX25] ax25_route: make ax25_route_lock BH safe
>=20
>=20
> Subject: [AX25] ax25_route: make ax25_route_lock BH safe
>=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > [ INFO: inconsistent lock state ]
> > 2.6.24-dg8ngn-p02 #1
> > ---------------------------------
> > inconsistent {softirq-on-W} -> {in-softirq-R} usage.
> > linuxnet/3046 [HC0[0]:SC1[2]:HE1:SE0] takes:
> >  (ax25_route_lock){--.+}, at: [<f8a0cfb7>] ax25_get_route+0x18/0xb7=
=20
> > [ax25] {softirq-on-W} state was registered at:
> ...
>=20
> This lockdep report shows that ax25_route_lock is taken for=20
> reading in softirq context, and for writing in process=20
> context with BHs enabled.
> So, to make this safe, all write_locks in ax25_route.c are=20
> changed to _bh versions.
>=20
>=20
> Reported-by: Jann Traschewski <jann@gmx.de>,
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>=20
> ---
>=20
> diff -Nurp 2.6.24-mm1-/net/ax25/ax25_route.c=20
> 2.6.24-mm1+/net/ax25/ax25_route.c
> --- 2.6.24-mm1-/net/ax25/ax25_route.c	2008-02-05=20
> 07:45:38.000000000 +0000
> +++ 2.6.24-mm1+/net/ax25/ax25_route.c	2008-02-11=20
> 11:58:47.000000000 +0000
> @@ -45,7 +45,7 @@ void ax25_rt_device_down(struct net_devi  {
>  	ax25_route *s, *t, *ax25_rt;
> =20
> -	write_lock(&ax25_route_lock);
> +	write_lock_bh(&ax25_route_lock);
>  	ax25_rt =3D ax25_route_list;
>  	while (ax25_rt !=3D NULL) {
>  		s       =3D ax25_rt;
> @@ -68,7 +68,7 @@ void ax25_rt_device_down(struct net_devi
>  			}
>  		}
>  	}
> -	write_unlock(&ax25_route_lock);
> +	write_unlock_bh(&ax25_route_lock);
>  }
> =20
>  static int __must_check ax25_rt_add(struct=20
> ax25_routes_struct *route) @@ -82,7 +82,7 @@ static int=20
> __must_check ax25_rt_add(stru
>  	if (route->digi_count > AX25_MAX_DIGIS)
>  		return -EINVAL;
> =20
> -	write_lock(&ax25_route_lock);
> +	write_lock_bh(&ax25_route_lock);
> =20
>  	ax25_rt =3D ax25_route_list;
>  	while (ax25_rt !=3D NULL) {
> @@ -92,7 +92,7 @@ static int __must_check ax25_rt_add(stru
>  			ax25_rt->digipeat =3D NULL;
>  			if (route->digi_count !=3D 0) {
>  				if ((ax25_rt->digipeat =3D=20
> kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) =3D=3D NULL) {
> -					write_unlock(&ax25_route_lock);
> +				=09
> write_unlock_bh(&ax25_route_lock);
>  					return -ENOMEM;
>  				}
>  				ax25_rt->digipeat->lastrepeat =3D=20
> -1; @@ -102,14 +102,14 @@ static int __must_check ax25_rt_add(stru
>  				=09
> ax25_rt->digipeat->calls[i]    =3D route->digi_addr[i];
>  				}
>  			}
> -			write_unlock(&ax25_route_lock);
> +			write_unlock_bh(&ax25_route_lock);
>  			return 0;
>  		}
>  		ax25_rt =3D ax25_rt->next;
>  	}
> =20
>  	if ((ax25_rt =3D kmalloc(sizeof(ax25_route), GFP_ATOMIC))=20
> =3D=3D NULL) {
> -		write_unlock(&ax25_route_lock);
> +		write_unlock_bh(&ax25_route_lock);
>  		return -ENOMEM;
>  	}
> =20
> @@ -120,7 +120,7 @@ static int __must_check ax25_rt_add(stru
>  	ax25_rt->ip_mode      =3D ' ';
>  	if (route->digi_count !=3D 0) {
>  		if ((ax25_rt->digipeat =3D=20
> kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) =3D=3D NULL) {
> -			write_unlock(&ax25_route_lock);
> +			write_unlock_bh(&ax25_route_lock);
>  			kfree(ax25_rt);
>  			return -ENOMEM;
>  		}
> @@ -133,7 +133,7 @@ static int __must_check ax25_rt_add(stru
>  	}
>  	ax25_rt->next   =3D ax25_route_list;
>  	ax25_route_list =3D ax25_rt;
> -	write_unlock(&ax25_route_lock);
> +	write_unlock_bh(&ax25_route_lock);
> =20
>  	return 0;
>  }
> @@ -152,7 +152,7 @@ static int ax25_rt_del(struct ax25_route
>  	if ((ax25_dev =3D ax25_addr_ax25dev(&route->port_addr)) =3D=3D NULL=
)
>  		return -EINVAL;
> =20
> -	write_lock(&ax25_route_lock);
> +	write_lock_bh(&ax25_route_lock);
> =20
>  	ax25_rt =3D ax25_route_list;
>  	while (ax25_rt !=3D NULL) {
> @@ -174,7 +174,7 @@ static int ax25_rt_del(struct ax25_route
>  			}
>  		}
>  	}
> -	write_unlock(&ax25_route_lock);
> +	write_unlock_bh(&ax25_route_lock);
> =20
>  	return 0;
>  }
> @@ -188,7 +188,7 @@ static int ax25_rt_opt(struct ax25_route
>  	if ((ax25_dev =3D=20
> ax25_addr_ax25dev(&rt_option->port_addr)) =3D=3D NULL)
>  		return -EINVAL;
> =20
> -	write_lock(&ax25_route_lock);
> +	write_lock_bh(&ax25_route_lock);
> =20
>  	ax25_rt =3D ax25_route_list;
>  	while (ax25_rt !=3D NULL) {
> @@ -216,7 +216,7 @@ static int ax25_rt_opt(struct ax25_route
>  	}
> =20
>  out:
> -	write_unlock(&ax25_route_lock);
> +	write_unlock_bh(&ax25_route_lock);
>  	return err;
>  }
> =20
> @@ -492,7 +492,7 @@ void __exit ax25_rt_free(void)  {
>  	ax25_route *s, *ax25_rt =3D ax25_route_list;
> =20
> -	write_lock(&ax25_route_lock);
> +	write_lock_bh(&ax25_route_lock);
>  	while (ax25_rt !=3D NULL) {
>  		s       =3D ax25_rt;
>  		ax25_rt =3D ax25_rt->next;
> @@ -500,5 +500,5 @@ void __exit ax25_rt_free(void)
>  		kfree(s->digipeat);
>  		kfree(s);
>  	}
> -	write_unlock(&ax25_route_lock);
> +	write_unlock_bh(&ax25_route_lock);
>  }

