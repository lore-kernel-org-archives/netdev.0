From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [14/14] vcompound: Avoid vmalloc for ehash_locks
Date: Fri, 21 Mar 2008 08:02:11 +0100
Message-ID: <47E35D73.6060703@cosmosbay.com>
References: <20080321061703.921169367@sgi.com> <20080321061727.491610308@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604003av.neufgp.fr ([84.96.92.124]:58656
	"EHLO neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753507AbYCUHCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 03:02:30 -0400
In-Reply-To: <20080321061727.491610308@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> Avoid the use of vmalloc for the ehash locks.
>=20
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>=20
> ---
>  include/net/inet_hashtables.h |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>=20
> Index: linux-2.6.25-rc5-mm1/include/net/inet_hashtables.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.25-rc5-mm1.orig/include/net/inet_hashtables.h	2008-03-2=
0 22:21:02.680501729 -0700
> +++ linux-2.6.25-rc5-mm1/include/net/inet_hashtables.h	2008-03-20 22:=
22:15.416565317 -0700
> @@ -164,7 +164,8 @@ static inline int inet_ehash_locks_alloc
>  	if (sizeof(rwlock_t) !=3D 0) {
>  #ifdef CONFIG_NUMA
>  		if (size * sizeof(rwlock_t) > PAGE_SIZE)
> -			hashinfo->ehash_locks =3D vmalloc(size * sizeof(rwlock_t));
> +			hashinfo->ehash_locks =3D __alloc_vcompound(GFP_KERNEL,
> +				get_order(size * sizeof(rwlock_t)));
>  		else
>  #endif
>  		hashinfo->ehash_locks =3D	kmalloc(size * sizeof(rwlock_t),
> @@ -185,7 +186,7 @@ static inline void inet_ehash_locks_free
>  		unsigned int size =3D (hashinfo->ehash_locks_mask + 1) *
>  							sizeof(rwlock_t);
>  		if (size > PAGE_SIZE)
> -			vfree(hashinfo->ehash_locks);
> +			__free_vcompound(hashinfo->ehash_locks);
>  		else
>  #endif
>  		kfree(hashinfo->ehash_locks);
>=20

But, isnt it defeating the purpose of this *particular* vmalloc() use ?

CONFIG_NUMA and vmalloc() at boot time means :

Try to distribute the pages on several nodes.

Memory pressure on ehash_locks[] is so high we definitly want to spread=
 it.

(for similar uses of vmalloc(), see also hashdist=3D1 )

Also, please CC netdev for network patches :)

Thank you

