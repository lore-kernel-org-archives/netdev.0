From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC: 2.6.25 patch] ipv4/fib_hash.c: fix NULL dereference
Date: Wed, 20 Feb 2008 00:06:14 +0100
Message-ID: <47BB60E6.6030506@cosmosbay.com>
References: <20080219224951.GP31955@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:41158
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755749AbYBSXGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 18:06:20 -0500
In-Reply-To: <20080219224951.GP31955@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk a =C3=A9crit :
> Unless I miss a guaranteed relation between between "f" and=20
> "new_fa->fa_info" this patch is required for fixing a NULL dereferenc=
e
> introduced by commit a6501e080c318f8d4467679d17807f42b3a33cd5 and=20
> spotted by the Coverity checker.
>=20
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>=20
> ---
>=20
>  net/ipv4/fib_hash.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>=20
> --- linux-2.6/net/ipv4/fib_hash.c.old	2008-02-19 23:23:14.000000000 +=
0200
> +++ linux-2.6/net/ipv4/fib_hash.c	2008-02-19 23:38:28.000000000 +0200
> @@ -367,17 +367,18 @@ static struct fib_node *fib_find_node(st
>  	}
> =20
>  	return NULL;
>  }
> =20
>  static int fn_hash_insert(struct fib_table *tb, struct fib_config *c=
fg)
>  {
>  	struct fn_hash *table =3D (struct fn_hash *) tb->tb_data;
> -	struct fib_node *new_f, *f;
> +	struct fib_node *new_f =3D NULL;
> +	struct fib_node *f;
>  	struct fib_alias *fa, *new_fa;
>  	struct fn_zone *fz;
>  	struct fib_info *fi;
>  	u8 tos =3D cfg->fc_tos;
>  	__be32 key;
>  	int err;
> =20
>  	if (cfg->fc_dst_len > 32)
> @@ -491,33 +492,32 @@ static int fn_hash_insert(struct fib_tab
>  	}
> =20
>  	err =3D -ENOENT;
>  	if (!(cfg->fc_nlflags & NLM_F_CREATE))
>  		goto out;
> =20
>  	err =3D -ENOBUFS;
> =20
> -	new_f =3D NULL;
>  	if (!f) {
>  		new_f =3D kmem_cache_zalloc(fn_hash_kmem, GFP_KERNEL);
>  		if (new_f =3D=3D NULL)
>  			goto out;
> =20
>  		INIT_HLIST_NODE(&new_f->fn_hash);
>  		INIT_LIST_HEAD(&new_f->fn_alias);
>  		new_f->fn_key =3D key;
>  		f =3D new_f;
>  	}
> =20
>  	new_fa =3D &f->fn_embedded_alias;
>  	if (new_fa->fa_info !=3D NULL) {
>  		new_fa =3D kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
>  		if (new_fa =3D=3D NULL)
> -			goto out_free_new_f;
> +			goto out;
>  	}
>  	new_fa->fa_info =3D fi;
>  	new_fa->fa_tos =3D tos;
>  	new_fa->fa_type =3D cfg->fc_type;
>  	new_fa->fa_scope =3D cfg->fc_scope;
>  	new_fa->fa_state =3D 0;
> =20
>  	/*
> @@ -535,19 +535,19 @@ static int fn_hash_insert(struct fib_tab
>  	if (new_f)
>  		fz->fz_nent++;
>  	rt_cache_flush(-1);
> =20
>  	rtmsg_fib(RTM_NEWROUTE, key, new_fa, cfg->fc_dst_len, tb->tb_id,
>  		  &cfg->fc_nlinfo, 0);
>  	return 0;
> =20
> -out_free_new_f:
> -	kmem_cache_free(fn_hash_kmem, new_f);
>  out:
> +	if (new_f)
> +		kmem_cache_free(fn_hash_kmem, new_f);
>  	fib_release_info(fi);
>  	return err;
>  }
> =20
> =20
>  static int fn_hash_delete(struct fib_table *tb, struct fib_config *c=
fg)
>  {
>  	struct fn_hash *table =3D (struct fn_hash*)tb->tb_data;
>=20

Hum, you are right, kmem_cache_free() doesnt allow a NULL object, like =
kfree()=20
does.


