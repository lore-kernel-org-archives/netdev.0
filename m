From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Hung task when calling clone() due to netfilter/slab
Date: Tue, 17 Jan 2012 16:20:30 +0100
Message-ID: <1326813630.2259.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326558605.19951.7.camel@lappy>
	  <1326561043.5287.24.camel@edumazet-laptop>
	 <1326632384.11711.3.camel@lappy> <1326648305.5287.78.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1201170910130.4800@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sasha Levin <levinsasha928@gmail.com>,
	Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>,
	Pekka Enberg <penberg@kernel.org>,
	Matt Mackall <mpm@selenic.com>, kaber@trash.net,
	pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1201170910130.4800@router.home>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 17 janvier 2012 =C3=A0 09:12 -0600, Christoph Lameter a =C3=A9=
crit :
> On Sun, 15 Jan 2012, Eric Dumazet wrote:
>=20
> > As soon as the slub_lock is released, another thread can come and f=
ind
> > the new kmem_cache.
>=20
> Slabs are not looked up by name. A pointer to kmem_cache is passed to=
 slab
> functions and that pointer is returned from kmem_cache_create(). The =
risk
> is someone traversing the kmem_cach list which is only done from with=
in slub.
>=20
>=20
> Subject: slub: Do not hold slub_lock when calling sysfs_slab_add()
>=20
> sysfs_slab_add() calls various sysfs functions that actually may
> end up in userspace doing all sorts of things.
>=20
> Release the slub_lock after adding the kmem_cache structure to the li=
st.
> At that point the address of the kmem_cache is not known so we are
> guaranteed exlusive access to the following modifications to the
> kmem_cache structure.
>=20
> If the sysfs_slab_add fails then reacquire the slub_lock to
> remove the kmem_cache structure from the list.
>=20
> Signed-off-by: Christoph Lameter <cl@linux.com>
>=20
> ---
>  mm/slub.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>=20
> Index: linux-2.6/mm/slub.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/slub.c	2012-01-17 03:07:11.140010438 -0600
> +++ linux-2.6/mm/slub.c	2012-01-17 03:07:19.532010264 -0600
> @@ -3929,13 +3929,15 @@ struct kmem_cache *kmem_cache_create(con
>  		if (kmem_cache_open(s, n,
>  				size, align, flags, ctor)) {
>  			list_add(&s->list, &slab_caches);
> +			up_write(&slub_lock);
>  			if (sysfs_slab_add(s)) {
> +				down_write(&slub_lock);
>  				list_del(&s->list);
> +				up_write(&slub_lock);
>  				kfree(n);
>  				kfree(s);
>  				goto err;
>  			}
> -			up_write(&slub_lock);
>  			return s;
>  		}
>  		kfree(n);



Buggy patch, since "goto err;" is going to up_write(&slub_lock) again.

Also Christoph, you forgot to add the very much needed :

Reported-by: Sasha Levin <levinsasha928@gmail.com>



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
