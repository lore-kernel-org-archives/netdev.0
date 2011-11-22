From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: slub: Lockout validation scans during freeing of object
Date: Tue, 22 Nov 2011 18:21:24 +0100
Message-ID: <1321982484.18002.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1111221033350.28197@router.home>
	 <alpine.DEB.2.00.1111221040300.28197@router.home>
	 <alpine.DEB.2.00.1111221052130.28197@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Christian Kujau
 <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
  "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>,  "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <alpine.DEB.2.00.1111221052130.28197@router.home>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mardi 22 novembre 2011 =C3=A0 10:53 -0600, Christoph Lameter a =C3=A9c=
rit :
> A bit heavy handed locking but this should do the trick.
>=20
> Subject: slub: Lockout validation scans during freeing of object
>=20
> Slab validation can run right now while the slab free paths prepare
> the redzone fields etc around the objects in preparation of the
> actual freeing of the object. This can lead to false positives.
>=20
> Take the node lock unconditionally during free so that the validation
> can examine objects without them being disturbed by freeing operations.
>=20
> Signed-off-by: Christoph Lameter <cl@linux.com>
>=20
> ---
>  mm/slub.c |   12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
>=20
> Index: linux-2.6/mm/slub.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/slub.c	2011-11-22 10:42:19.000000000 -0600
> +++ linux-2.6/mm/slub.c	2011-11-22 10:44:34.000000000 -0600
> @@ -2391,8 +2391,15 @@ static void __slab_free(struct kmem_cach
>=20
>  	stat(s, FREE_SLOWPATH);
>=20
> -	if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
> -		return;
> +	if (kmem_cache_debug(s)) {
> +
> +		/* Lock out any concurrent validate_slab calls */
> +		n =3D get_node(s, page_to_nid(page));
> +		spin_lock_irqsave(&n->list_lock, flags);
> +
> +		if (!free_debug_processing(s, page, x, addr))
> +			goto out;
> +	}
>=20
>  	do {
>  		prior =3D page->freelist;
> @@ -2471,6 +2478,7 @@ static void __slab_free(struct kmem_cach
>  			stat(s, FREE_ADD_PARTIAL);
>  		}
>  	}
> +out:
>  	spin_unlock_irqrestore(&n->list_lock, flags);
>  	return;
>=20


This seems better, but I still have some warnings :

[  162.117574] SLUB: selinux_inode_security 136 slabs counted but counter=
=3D137
[  179.879907] SLUB: task_xstate 1 slabs counted but counter=3D2
[  179.881745] SLUB: vm_area_struct 47 slabs counted but counter=3D48
[  180.381964] SLUB: kmalloc-64 46 slabs counted but counter=3D47
[  192.366437] SLUB: vm_area_struct 82 slabs counted but counter=3D83
[  195.016732] SLUB: names_cache 3 slabs counted but counter=3D4
[  196.073166] SLUB: dentry 623 slabs counted but counter=3D624
[  196.093857] SLUB: names_cache 3 slabs counted but counter=3D4
[  196.631420] SLUB: names_cache 5 slabs counted but counter=3D6
[  198.760180] SLUB: kmalloc-16 30 slabs counted but counter=3D31
[  198.773492] SLUB: names_cache 5 slabs counted but counter=3D6
[  198.783637] SLUB: selinux_inode_security 403 slabs counted but counter=
=3D404
[  201.717932] SLUB: filp 53 slabs counted but counter=3D54
[  202.984756] SLUB: filp 40 slabs counted but counter=3D41
[  203.819525] SLUB: task_xstate 3 slabs counted but counter=3D4
[  205.699916] SLUB: cfq_io_context 1 slabs counted but counter=3D2
[  206.526646] SLUB: skbuff_head_cache 4 slabs counted but counter=3D5
[  208.431951] SLUB: names_cache 3 slabs counted but counter=3D4
[  210.672056] SLUB: vm_area_struct 88 slabs counted but counter=3D89
[  213.160055] SLUB: vm_area_struct 94 slabs counted but counter=3D95
[  215.604856] SLUB: cfq_queue 1 slabs counted but counter=3D2
[  217.872494] SLUB: filp 56 slabs counted but counter=3D57
[  220.184599] SLUB: names_cache 3 slabs counted but counter=3D4
[  221.783732] SLUB: anon_vma_chain 53 slabs counted but counter=3D54
[  221.816662] SLUB: kmalloc-16 66 slabs counted but counter=3D67
[  221.828582] SLUB: names_cache 3 slabs counted but counter=3D4
[  221.848231] SLUB: vm_area_struct 99 slabs counted but counter=3D100
[  224.125411] SLUB: kmalloc-16 30 slabs counted but counter=3D31
[  224.126313] SLUB: kmalloc-16 67 slabs counted but counter=3D68
[  224.138768] SLUB: names_cache 3 slabs counted but counter=3D4
[  224.921409] SLUB: anon_vma 36 slabs counted but counter=3D37
[  224.927833] SLUB: buffer_head 294 slabs counted but counter=3D295
[  226.473891] SLUB: kmalloc-16 67 slabs counted but counter=3D68
[  228.801716] SLUB: names_cache 5 slabs counted but counter=3D6
[  229.610225] SLUB: filp 47 slabs counted but counter=3D48
[  232.050811] SLUB: filp 53 slabs counted but counter=3D54
[  235.835888] SLUB: names_cache 3 slabs counted but counter=3D4
[  236.625318] SLUB: filp 48 slabs counted but counter=3D49
[  236.634563] SLUB: kmalloc-16 30 slabs counted but counter=3D31
[  236.635667] SLUB: kmalloc-16 67 slabs counted but counter=3D68
[  237.500016] SLUB: radix_tree_node 100 slabs counted but counter=3D101
[  238.248677] SLUB: filp 48 slabs counted but counter=3D49
[  239.097674] SLUB: filp 49 slabs counted but counter=3D50
[  239.975020] SLUB: names_cache 3 slabs counted but counter=3D4
[  241.569766] SLUB: vm_area_struct 102 slabs counted but counter=3D103
[  242.388502] SLUB: names_cache 5 slabs counted but counter=3D6
[  243.152519] SLUB: anon_vma_chain 56 slabs counted but counter=3D57
[  245.661970] SLUB: filp 49 slabs counted but counter=3D50
[  247.298004] SLUB: filp 48 slabs counted but counter=3D50
[  248.851148] SLUB: journal_handle 3 slabs counted but counter=3D4
[  249.674320] SLUB: names_cache 3 slabs counted but counter=3D4
[  250.414476] SLUB: bio-0 24 slabs counted but counter=3D25
[  250.461655] SLUB: kmalloc-96 49 slabs counted but counter=3D50
[  250.477188] SLUB: sgpool-16 0 slabs counted but counter=3D1
[  251.298554] SLUB: kmalloc-32 9 slabs counted but counter=3D10
[  252.096119] SLUB: names_cache 3 slabs counted but counter=3D4
[  256.179892] SLUB: filp 58 slabs counted but counter=3D59
[  256.188385] SLUB: kmalloc-16 30 slabs counted but counter=3D31
[  257.040508] SLUB: kmalloc-16 30 slabs counted but counter=3D31
[  258.704236] SLUB: buffer_head 502 slabs counted but counter=3D503
[  258.745777] SLUB: kmalloc-32 9 slabs counted but counter=3D10
[  258.752285] SLUB: names_cache 3 slabs counted but counter=3D4
[  260.412312] SLUB: filp 54 slabs counted but counter=3D56
[  261.213526] SLUB: filp 44 slabs counted but counter=3D45
[  262.846810] SLUB: kmalloc-16 31 slabs counted but counter=3D32
[  262.859062] SLUB: names_cache 5 slabs counted but counter=3D6
[  262.881728] SLUB: task_xstate 3 slabs counted but counter=3D4
[  263.672055] SLUB: filp 54 slabs counted but counter=3D55
[  266.191191] SLUB: kmalloc-16 30 slabs counted but counter=3D31
[  266.203799] SLUB: names_cache 5 slabs counted but counter=3D6
[  268.486964] SLUB: filp 52 slabs counted but counter=3D53
[  268.509446] SLUB: names_cache 5 slabs counted but counter=3D6
[  269.365745] SLUB: vm_area_struct 88 slabs counted but counter=3D89



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
