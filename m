From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Inconsistent lock  state and possible irq lock inversion dependency
 detected in ax25.ko
Date: Wed, 05 Dec 2007 00:17:47 +0100
Message-ID: <4755E01B.9010307@gmail.com>
References: <20071003185413.GA16242@martell.zuzino.mipt.ru> <4744AD8B.2000908@ccr.jussieu.fr> <4752ED3D.2060204@ccr.jussieu.fr> <47532B60.8030205@o2.pl> <4755D42C.9000107@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@o2.pl>, ralf@linux-mips.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:60138 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbXLDXOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 18:14:01 -0500
Received: by ug-out-1314.google.com with SMTP id z38so206196ugc
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2007 15:13:58 -0800 (PST)
In-Reply-To: <4755D42C.9000107@ccr.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bernard Pidoux wrote, On 12/04/2007 11:26 PM:

> Jarek Poplawski wrote:
>> Bernard Pidoux wrote, On 12/02/2007 06:37 PM:
>>
>>> Hi,
>>>
>>> Many thanks for your patch for ~/net/ax25/ax25_subr.c
>>>
>>> Introduction of local_bh_disable() ... local_bh_enable()
>>>
>>> cured the inconsistent lock state related to AX25 connect timeout.
>>>
>>> I have now a stable monoprocessor system running AX25 and ROSE netw=
ork=20
>>> packet switching application FPAC, whether kernel is compiled with =
or=20
>>> without hack option.
>>>
>>> There is no more problem during normal operations.
>>>
>>> This was achieved, thanks to your AX25 patch and the patch from Ale=
xey=20
>>> Dobriyan for rose module.
>>>
>>> I also patched rose module in order to get packet routing more=20
>>> efficient, taking into account the "restarted" flag that is raised =
when=20
>>> a neighbour node is already connected.
>>>
>>> To summarize the present situation on my Linux machine, I built a p=
atch=20
>>> against kernel 2.6.23.9.
>>>
>>> I would appreciate if you could make it included into a next kernel=
 release.
>> ...=20
>>
>> Bernard, I'm very glad I could be a little helpful, but I'm not sure=
 of
>> your intentions: my patch proposal is rather trivial interpretation =
of
>> lockdep's report; I haven't studied AX25 enough even to be sure ther=
e is
>> a real lockup possible in this place. Since this change looks not ve=
ry
>> costly and quite safe, I can 'take a risk' to sign this off after yo=
ur
>> testing. But anything more is beyond my 'range'.
>>
>> So, since you've spent quite a lot of time on this all, maybe it wou=
ld
>> be simpler if you've tried the same with the current kernel, and res=
ent
>> "proper" (not gzipped and with changelog) patch or patches. Then, I =
hope,
>> Ralf, as the maintainer, will make the rest.
>>
>> Regards,
>> Jarek P.
>>
>>
>=20
> As required I send again in clear text the summary of ax25 and rose=20
> patch against 2.6.23.9.
> As I said, the kernel stability, after applying these patch, is behin=
d us.
> I did not observe any warning nor lockup after a few days of AX25=20
> intensive use.
> Also rose module is handling routing of frames much more efficiently.
>=20
> This will considerably help us to focus on application programs now.
> I am now concentrating my efforts on ROSE/FPAC and Linux FBB code=20
> adjustement.
>=20
> Thanks to you all for your help.
>=20
> 73 de Bernard, f6bvp
>=20
>=20
>=20


Bernard, I think you've forgotten at least about some distinct
changelog and signed-off-by?

Jarek P.
---

ax25_subr.c part:
Acked-by: Jarek Poplawski <jarkao2@gmail.com>

> ---------------------------------------------------------------------=
---
>=20
> diff -pruN a/include/net/rose.h b/include/net/rose.h
> --- a/include/net/rose.h	2007-10-12 18:43:44.000000000 +0200
> +++ b/include/net/rose.h	2007-12-01 23:56:57.000000000 +0100
> @@ -202,6 +202,7 @@ extern struct net_device *rose_dev_first
>  extern struct net_device *rose_dev_get(rose_address *);
>  extern struct rose_route *rose_route_free_lci(unsigned int, struct r=
ose_neigh *);
>  extern struct rose_neigh *rose_get_neigh(rose_address *, unsigned ch=
ar *, unsigned char *);
> +extern struct rose_neigh *__rose_get_neigh(rose_address *, unsigned =
char *, unsigned char *);
>  extern int  rose_rt_ioctl(unsigned int, void __user *);
>  extern void rose_link_failed(ax25_cb *, int);
>  extern int  rose_route_frame(struct sk_buff *, ax25_cb *);
> diff -pruN a/net/ax25/ax25_subr.c b/net/ax25/ax25_subr.c
> --- a/net/ax25/ax25_subr.c	2007-10-12 18:43:44.000000000 +0200
> +++ b/net/ax25/ax25_subr.c	2007-12-01 23:32:01.000000000 +0100
> @@ -279,6 +279,7 @@ void ax25_disconnect(ax25_cb *ax25, int=20
>  	ax25_link_failed(ax25, reason);
> =20
>  	if (ax25->sk !=3D NULL) {
> +		local_bh_disable();
>  		bh_lock_sock(ax25->sk);
>  		ax25->sk->sk_state     =3D TCP_CLOSE;
>  		ax25->sk->sk_err       =3D reason;
> @@ -288,5 +289,6 @@ void ax25_disconnect(ax25_cb *ax25, int=20
>  			sock_set_flag(ax25->sk, SOCK_DEAD);
>  		}
>  		bh_unlock_sock(ax25->sk);
> +		local_bh_enable();=20
>  	}
>  }
> diff -pruN a/net/rose/af_rose.c b/net/rose/af_rose.c
> --- a/net/rose/af_rose.c	2007-10-12 18:43:44.000000000 +0200
> +++ b/net/rose/af_rose.c	2007-12-02 10:06:31.000000000 +0100
> @@ -62,7 +62,7 @@ int sysctl_rose_window_size            =20
>  static HLIST_HEAD(rose_list);
>  static DEFINE_SPINLOCK(rose_list_lock);
> =20
> -static struct proto_ops rose_proto_ops;
> +static const struct proto_ops rose_proto_ops;
> =20
>  ax25_address rose_callsign;
> =20
> @@ -741,7 +741,7 @@ static int rose_connect(struct socket *s
>  	sk->sk_state   =3D TCP_CLOSE;
>  	sock->state =3D SS_UNCONNECTED;
> =20
> -	rose->neighbour =3D rose_get_neigh(&addr->srose_addr, &cause,
> +	rose->neighbour =3D __rose_get_neigh(&addr->srose_addr, &cause,
>  					 &diagnostic);
>  	if (!rose->neighbour)
>  		return -ENETUNREACH;
> @@ -773,7 +773,6 @@ static int rose_connect(struct socket *s
> =20
>  		rose_insert_socket(sk);		/* Finish the bind */
>  	}
> -rose_try_next_neigh:
>  	rose->dest_addr   =3D addr->srose_addr;
>  	rose->dest_call   =3D addr->srose_call;
>  	rose->rand        =3D ((long)rose & 0xFFFF) + rose->lci;
> @@ -835,12 +834,6 @@ rose_try_next_neigh:
>  	}
> =20
>  	if (sk->sk_state !=3D TCP_ESTABLISHED) {
> -	/* Try next neighbour */
> -		rose->neighbour =3D rose_get_neigh(&addr->srose_addr, &cause, &dia=
gnostic);
> -		if (rose->neighbour)
> -			goto rose_try_next_neigh;
> -
> -		/* No more neighbours */
>  		sock->state =3D SS_UNCONNECTED;
>  		err =3D sock_error(sk);	/* Always set at this point */
>  		goto out_release;
> @@ -1481,7 +1474,7 @@ static struct net_proto_family rose_fami
>  	.owner		=3D	THIS_MODULE,
>  };
> =20
> -static struct proto_ops rose_proto_ops =3D {
> +static const struct proto_ops rose_proto_ops =3D {
>  	.family		=3D	PF_ROSE,
>  	.owner		=3D	THIS_MODULE,
>  	.release	=3D	rose_release,
> Les fichiers linux-2.6.23.9-orig/net/rose/rose.ko et linux-2.6.23.9/n=
et/rose/rose.ko sont diff=C3=A9rents.
> diff -pruN a/net/rose/rose_route.c b/net/rose/rose_route.c
> --- a/net/rose/rose_route.c	2007-10-12 18:43:44.000000000 +0200
> +++ b/net/rose/rose_route.c	2007-12-02 00:15:24.000000000 +0100
> @@ -664,25 +664,22 @@ struct rose_route *rose_route_free_lci(u
>  /*
>   *	Find a neighbour given a ROSE address.
>   */
> -struct rose_neigh *rose_get_neigh(rose_address *addr, unsigned char =
*cause,
> +struct rose_neigh *__rose_get_neigh(rose_address *addr, unsigned cha=
r *cause,
>  	unsigned char *diagnostic)
>  {
> -	struct rose_neigh *res =3D NULL;
>  	struct rose_node *node;
>  	int failed =3D 0;
>  	int i;
> =20
> -	spin_lock_bh(&rose_node_list_lock);
>  	for (node =3D rose_node_list; node !=3D NULL; node =3D node->next) =
{
>  		if (rosecmpm(addr, &node->address, node->mask) =3D=3D 0) {
>  			for (i =3D 0; i < node->count; i++) {
> -				if (!rose_ftimer_running(node->neighbour[i])) {
> -					res =3D node->neighbour[i];
> -					goto out;
> -				} else
> -					failed =3D 1;
> +				if (node->neighbour[i]->restarted)
> +					return node->neighbour[i];
> +				if (!rose_ftimer_running(node->neighbour[i]))		=09
> +					return node->neighbour[i];
> +				failed =3D 1;
>  			}
> -			break;
>  		}
>  	}
> =20
> @@ -694,7 +691,16 @@ struct rose_neigh *rose_get_neigh(rose_a
>  		*diagnostic =3D 0;
>  	}
> =20
> -out:
> +	return NULL;
> +}
> +
> +struct rose_neigh *rose_get_neigh(rose_address *addr, unsigned char =
*cause,
> +	unsigned char *diagnostic)
> +{
> +	struct rose_neigh *res;
> +
> +	spin_lock_bh(&rose_node_list_lock);
> +	res =3D __rose_get_neigh(addr, cause, diagnostic);
>  	spin_unlock_bh(&rose_node_list_lock);
> =20
>  	return res;
> @@ -1019,7 +1025,7 @@ int rose_route_frame(struct sk_buff *skb
>  		rose_route =3D rose_route->next;
>  	}
> =20
> -	if ((new_neigh =3D rose_get_neigh(dest_addr, &cause, &diagnostic)) =
=3D=3D NULL) {
> +	if ((new_neigh =3D __rose_get_neigh(dest_addr, &cause, &diagnostic)=
) =3D=3D NULL) {
>  		rose_transmit_clear_request(rose_neigh, lci, cause, diagnostic);
>  		goto out;
>  	}
>=20


