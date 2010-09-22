From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/6] netfilter: fix a race in nf_ct_ext_create()
Date: Wed, 22 Sep 2010 09:23:40 +0200
Message-ID: <1285140220.6378.211.camel@edumazet-laptop>
References: <1285139854-11827-1-git-send-email-kaber@trash.net>
	 <1285139854-11827-5-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1285139854-11827-5-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 22 septembre 2010 =C3=A0 09:17 +0200, kaber@trash.net a =C3=
=A9crit :
> From: Eric Dumazet <Eric Dumazet>
>=20

strange email address ;)

> As soon as rcu_read_unlock() is called, there is no guarantee current
> thread can safely derefence t pointer, rcu protected.
>=20
> Fix is to copy t->alloc_size in a temporary variable.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> ---
>  net/netfilter/nf_conntrack_extend.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_c=
onntrack_extend.c
> index 7dcf7a4..8d9e4c9 100644
> --- a/net/netfilter/nf_conntrack_extend.c
> +++ b/net/netfilter/nf_conntrack_extend.c
> @@ -48,15 +48,17 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_=
ct_ext_id id, gfp_t gfp)
>  {
>  	unsigned int off, len;
>  	struct nf_ct_ext_type *t;
> +	size_t alloc_size;
> =20
>  	rcu_read_lock();
>  	t =3D rcu_dereference(nf_ct_ext_types[id]);
>  	BUG_ON(t =3D=3D NULL);
>  	off =3D ALIGN(sizeof(struct nf_ct_ext), t->align);
>  	len =3D off + t->len;
> +	alloc_size =3D t->alloc_size;
>  	rcu_read_unlock();
> =20
> -	*ext =3D kzalloc(t->alloc_size, gfp);
> +	*ext =3D kzalloc(alloc_size, gfp);
>  	if (!*ext)
>  		return NULL;
> =20


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
