From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] struct file cleanup : the very large file_ra_state is
 now allocated only on demand.
Date: Thu, 18 Aug 2005 09:14:47 +0200
Message-ID: <43043567.3040204@cosmosbay.com>
References: <20050817215357.GU3996@wotan.suse.de>	<4303D90E.2030103@cosmosbay.com>	<20050818010524.GW3996@wotan.suse.de> <20050817.194315.111196480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ak@suse.de, bcrl@linux.intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750852AbVHRHPA@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050817.194315.111196480.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :
> From: Andi Kleen <ak@suse.de>
> Date: Thu, 18 Aug 2005 03:05:25 +0200
>=20
>=20
>>I would just set the ra pointer to a single global structure if the
>>allocation fails. Then you can avoid all the other checks. It will
>>slow down things and trash some state, but not fail and nobody
>>should expect good performance after out of memory anyways. The only
>>check still needed would be on freeing.
>=20
>=20
> I would think twice about that due to repeatability concerns.  Yes, w=
e
> should care less when memory is so low, but if we can avoid this kind
> of scenerio easily we should.
>=20
> Having said that, I would like to recommend looking into a scheme
> where the path leading to the filp allocation states whether the
> read-ahead bits are needed or not.  This has two benefits:
>=20
> 1) Repeatability, and error signalling at the correct place
>    should the memory allocation fail.
>=20
> 2) We can avoid the pointer dereference overhead.  The read-ahead
>    state is always at (filp + 1).  Macro'ized or static inline
>    function'ized interfaces for this access can make it look
>    clean and perhaps even implement debugging of the case where
>    we try to get at the read-ahead state for a non-read-ahead
>    filp.
>=20
> I do really think that would be a better approach.  A quick glance
> shows that it should be easy to propagate the "need_read_ahead"
> state, just by passing a boolean to get_unused_fd() via
> sock_map_fd().

Thanks David and Andi

Hum... get_unused_fd() allocates a file descriptor, not a 'struct file =
*'
Maybe you meant get_empty_filp(void), that we might change to get_empty=
_filp(int need_read_ahead)

After reading your suggestions, I understand we still need two slabs.
One (filp_cachep) without the readahead data, the other one (filp_ra_ca=
chep) with it.

static inline struct file_ra_state *get_ra_state(struct file *f)
{
#ifdef CONFIG_DEBUG_READAHEAD
	BUG_ON(filp_ra_cachep !=3D GET_PAGE_CACHE(virt_to_page(f)));
#endif
	return (struct file_ra_state *)(f+1);
}


struct file *get_empty_filp(int need_read_ahead)
{
	struct file *f;
	...
	f =3D kmem_cache_alloc(need_read_ahead ? filp_ra_cachep : filp_cachep,=
 GFP_KERNEL);
	if (f =3D=3D NULL)
		goto fail;
	memset(f, 0, need_read_ahead ? sizeof(struct file) : sizeof(struct fil=
e) + sizeof(struct file_ra_state));
	...
}

file_free() then call kfree() that should find the right kmem_cache_t *

static inline void file_free(struct file *f)
{
	kfree(f);
}


I will provide a new version of the patch in a later mail

Eric
