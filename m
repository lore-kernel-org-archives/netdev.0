From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] A device for zero-copy based on KVM virtio-net.
Date: Wed, 10 Feb 2010 16:17:51 +0100
Message-ID: <1265815071.3047.96.camel@edumazet-laptop>
References: <1265802540-6122-1-git-send-email-xiaohui.xin@intel.com>
	 <1265802540-6122-2-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, mst@redhat.com,
	jdike@c2.user-mode-linux.org, Zhao Yu <yzhao81@gmail.com>
To: Xin Xiaohui <xiaohui.xin@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265802540-6122-2-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 10 f=C3=A9vrier 2010 =C3=A0 19:48 +0800, Xin Xiaohui a =C3=A9=
crit :
> Add a device to utilize the vhost-net backend driver for
> copy-less data transfer between guest FE and host NIC.
> It pins the guest user space to the host memory and
> provides proto_ops as sendmsg/recvmsg to vhost-net.
>=20
> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
> Signed-off-by: Zhao Yu <yzhao81@gmail.com>
> Sigend-off-by: Jeff Dike <jdike@c2.user-mode-linux.org>


> +static int page_ctor_attach(struct mp_struct *mp)
> +{
> +	int rc;
> +	struct page_ctor *ctor;
> +	struct net_device *dev =3D mp->dev;
> +
> +	rcu_read_lock();
> +	if (rcu_dereference(mp->ctor)) {
> +		rcu_read_unlock();
> +		return -EBUSY;
> +	}
> +	rcu_read_unlock();

Strange read locking here, for an obvious writer role.
What do you really want to do ?
If writer are serialized by mp_mutex, you dont need this
recu_read_lock()/rcu_read_unlock() stuff.

> +
> +	ctor =3D kzalloc(sizeof(*ctor), GFP_KERNEL);
> +	if (!ctor)
> +		return -ENOMEM;
> +	rc =3D netdev_page_ctor_prep(dev, &ctor->ctor);
> +	if (rc)
> +		goto fail;
> +
> +	ctor->cache =3D kmem_cache_create("skb_page_info",
> +			sizeof(struct page_info), 0,
> +			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);


SLAB_PANIC here means : crash whole system in case of error.
This is not what you want in a driver.

> +
> +	if (!ctor->cache)
> +		goto cache_fail;
> +
> +	INIT_LIST_HEAD(&ctor->readq);
> +	spin_lock_init(&ctor->read_lock);
> +
> +	ctor->w_len =3D 0;
> +	ctor->r_len =3D 0;
> +
> +	dev_hold(dev);
> +	ctor->dev =3D dev;
> +	ctor->ctor.ctor =3D page_ctor;
> +	ctor->ctor.sock =3D &mp->socket;
> +	atomic_set(&ctor->refcnt, 1);
> +
> +	rc =3D netdev_page_ctor_attach(dev, &ctor->ctor);
> +	if (rc)
> +		goto fail;
> +
> +	/* locked by mp_mutex */
> +	rcu_assign_pointer(mp->ctor, ctor);
> +
> +	/* XXX:Need we do set_offload here ? */
> +
> +	return 0;
> +
> +fail:
> +	kmem_cache_destroy(ctor->cache);
> +cache_fail:
> +	kfree(ctor);
> +	dev_put(dev);
> +
> +	return rc;
> +}
> +
> +
> +static inline void get_page_ctor(struct page_ctor *ctor)
> +{
> +       atomic_inc(&ctor->refcnt);
> +}
> +
> +static inline void put_page_ctor(struct page_ctor *ctor)
> +{
> +	if (atomic_dec_and_test(&ctor->refcnt))
> +		kfree(ctor);

Are you sure a RCU grace period is not needed before freeing ?


> +
> +static int page_ctor_detach(struct mp_struct *mp)
> +{
> +	struct page_ctor *ctor;
> +	struct page_info *info;
> +	int i;
> +
> +	rcu_read_lock();
> +	ctor =3D rcu_dereference(mp->ctor);
> +	rcu_read_unlock();

Strange locking again here


> +
> +	if (!ctor)
> +		return -ENODEV;
> +
> +	while ((info =3D info_dequeue(ctor))) {
> +		for (i =3D 0; i < info->pnum; i++)
> +			if (info->pages[i])
> +				put_page(info->pages[i]);
> +		kmem_cache_free(ctor->cache, info);
> +	}
> +	kmem_cache_destroy(ctor->cache);
> +	netdev_page_ctor_detach(ctor->dev);
> +	dev_put(ctor->dev);
> +
> +	/* locked by mp_mutex */
> +	rcu_assign_pointer(mp->ctor, NULL);
> +	synchronize_rcu();
> +
> +	put_page_ctor(ctor);
> +
> +	return 0;
> +}
> +
> +/* For small user space buffers transmit, we don't need to call
> + * get_user_pages().
> + */
> +static struct page_info *alloc_small_page_info(struct page_ctor *cto=
r,
> +		int total)
> +{
> +	struct page_info *info =3D kmem_cache_alloc(ctor->cache, GFP_KERNEL=
);
kmem_cache_zalloc() ?
> +
> +	if (!info)
> +		return NULL;
> +	memset(info, 0, sizeof(struct page_info));
> +	memset(info->pages, 0, sizeof(info->pages));

redundant memset() whole structure already cleared one line above

> +
> +	info->header =3D 0;
already cleared
> +	info->total =3D total;
> +	info->skb =3D NULL;
already cleared=20
>=20
> +	info->user.dtor =3D page_dtor;
> +	info->ctor =3D ctor;
> +	info->flags =3D INFO_WRITE;
> +	info->pnum =3D 0;
already cleared=20
>=20
> +	return info;
> +}
> +
> +/* The main function to transform the guest user space address
> + * to host kernel address via get_user_pages(). Thus the hardware
> + * can do DMA directly to the user space address.
> + */
> +static struct page_info *alloc_page_info(struct page_ctor *ctor,
> +			struct iovec *iov, int count, struct frag *frags,
> +			int npages, int total)
> +{
> +	int rc;
> +	int i, j, n =3D 0;
> +	int len;
> +	unsigned long base;
> +	struct page_info *info =3D kmem_cache_alloc(ctor->cache, GFP_KERNEL=
);
kmem_cache_zalloc() ?=20
>=20
> +
> +	if (!info)
> +		return NULL;
> +	memset(info, 0, sizeof(struct page_info));
kmem_cache_zalloc() ?
> +	memset(info->pages, 0, sizeof(info->pages));
already cleared=20
>=20
> +
> +	down_read(&current->mm->mmap_sem);
> +	for (i =3D j =3D 0; i < count; i++) {
> +		base =3D (unsigned long)iov[i].iov_base;
> +		len =3D iov[i].iov_len;
> +
> +		if (!len)
> +			continue;
> +		n =3D ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
> +
> +		rc =3D get_user_pages(current, current->mm, base, n,
> +				npages ? 1 : 0, 0, &info->pages[j], NULL);
> +		if (rc !=3D n) {
> +			up_read(&current->mm->mmap_sem);
> +			goto failed;
> +		}
> +
> +		while (n--) {
> +			frags[j].offset =3D base & ~PAGE_MASK;
> +			frags[j].size =3D min_t(int, len,
> +					PAGE_SIZE - frags[j].offset);
> +			len -=3D frags[j].size;
> +			base +=3D frags[j].size;
> +			j++;
> +		}
> +	}
> +	up_read(&current->mm->mmap_sem);
> +
> +#ifdef CONFIG_HIGHMEM
> +	if (npages && !(dev->features & NETIF_F_HIGHDMA)) {
> +		for (i =3D 0; i < j; i++) {
> +			if (PageHighMem(info->pages[i]))
> +				goto failed;
> +		}
> +	}
> +#endif
> +
> +	info->header =3D 0;
> +	info->total =3D total;
> +	info->skb =3D NULL;
> +	info->user.dtor =3D page_dtor;
> +	info->ctor =3D ctor;
> +	info->pnum =3D j;
> +
> +	if (!npages)
> +		info->flags =3D INFO_WRITE;
> +	if (info->flags =3D=3D INFO_READ) {
> +		info->user.start =3D (u8 *)(((unsigned long)
> +				(pfn_to_kaddr(page_to_pfn(info->pages[0]))) +
> +				frags[0].offset) - NET_IP_ALIGN - NET_SKB_PAD);
> +		info->user.size =3D iov[0].iov_len + NET_IP_ALIGN + NET_SKB_PAD;
> +	}
> +	return info;
> +
> +failed:
> +	for (i =3D 0; i < j; i++)
> +		put_page(info->pages[i]);
> +
> +	kmem_cache_free(ctor->cache, info);
> +
> +	return NULL;
> +}
> +
> +struct page_ctor *mp_rcu_get_ctor(struct page_ctor *ctor)
> +{
> +	struct page_ctor *_ctor =3D NULL;
> +
> +	rcu_read_lock();
> +	_ctor =3D rcu_dereference(ctor);
> +	rcu_read_unlock();
strange locking. After rcu_read_unlock() you have no guarantee _ctor
points to something not freed.
> +
> +	if (!_ctor) {
> +		DBG(KERN_INFO "Device %s cannot do mediate passthru.\n",
> +				ctor->dev->name);
> +		return NULL;
> +	}
> +	if (_ctor)
redundant test
> +		get_page_ctor(_ctor);
> +	return _ctor;
> +}
> +

I stopped my review at this point. Please check your RCU usages. It is
not sufficient to hold rcu read lock just to fetch the pointer, you als=
o
must hold the lock while using the object itself, or get a reference on
object before release RCU lock, to make sure object wont disappear unde=
r
you...

for example :

rcu_read_lock();
ptr =3D rcu_dereference(...);
if (ptr)
	atomic_inc(&ptr->refcnt);
rcu_read_unlock();
