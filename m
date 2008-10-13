From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Distributed storage release.
Date: Sun, 12 Oct 2008 19:24:19 -0700
Message-ID: <20081012192419.fd8394c9.akpm@linux-foundation.org>
References: <20081006160034.GA611@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20081006160034.GA611@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mon, 6 Oct 2008 20:00:35 +0400 Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Hi.
> 
> I am pleased to announce new distributed storage (DST) project release.
> 

Please include diffstat with patches.

 drivers/block/Kconfig           |    2 
 drivers/block/Makefile          |    2 
 drivers/block/dst/Kconfig       |   14 
 drivers/block/dst/Makefile      |    3 
 drivers/block/dst/crypto.c      |  680 ++++++++++++++++++++++++++++++
 drivers/block/dst/dcore.c       |  879 ++++++++++++++++++++++++++++++++++++++++
 drivers/block/dst/export.c      |  593 ++++++++++++++++++++++++++
 drivers/block/dst/state.c       |  784 +++++++++++++++++++++++++++++++++++
 drivers/block/dst/thread_pool.c |  306 +++++++++++++
 drivers/block/dst/trans.c       |  306 +++++++++++++
 include/linux/connector.h       |    4 
 include/linux/dst.h             |  438 +++++++++++++++++++
 12 files changed, 4008 insertions(+), 3 deletions(-)

checkpatch says

total: 83 errors, 52 warnings, 4023 lines checked

many of which indeed should be fixed.

<scans the patch>

OK, I was going to spend an hour reviewing this patch but the almost total
lack of useful comments means that this would be largely a waste of your
time and of mine.  I would need to read the implementation sufficiently
closely to work out what it is setting out to do and I then would have to
check whether it is doing it correctly.

Now I _could_ do that, although it would take a lot of time and the review
would be less productive.  But it would mean that the code is still hard to
understand and hence hard to maitain.  A much better outcome would be for
you to properly document it.  That will result in more efficient review,
more effective review and better code.

No?

So please.  Go through all the code and make it tell a story.  Ask yourself
"how would I explain all this to a kernel developer who is sitting next to
me".  It's important, and it's an important skill.



The means by which the code's memory allocation is "bulletproof" should be
fully described in changelog comments so that those who are working on this
sort of thing can check your homework, please.

I assume all this code adds some sort of userspace<->kernel interface. 
That should be documented in the kernel tree, so we can review it.

It would be good to document the on-the-wire protocol.  That's an important
thing.

> 

Some lightweight comments only:

> diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
> index 0d1d213..56a64fe 100644
> --- a/drivers/block/Kconfig
> +++ b/drivers/block/Kconfig
> @@ -433,4 +433,6 @@ config VIRTIO_BLK
>  	  This is the virtual block driver for virtio.  It can be used with
>            lguest or QEMU based VMMs (like KVM or Xen).  Say Y or M.
>  
> +source "drivers/block/dst/Kconfig"
> +
>  endif # BLK_DEV
> diff --git a/drivers/block/Makefile b/drivers/block/Makefile
> index 5e58430..26bcf8a 100644
> --- a/drivers/block/Makefile
> +++ b/drivers/block/Makefile
> @@ -31,3 +31,5 @@ obj-$(CONFIG_BLK_DEV_SX8)	+= sx8.o
>  obj-$(CONFIG_BLK_DEV_UB)	+= ub.o
>  
>  obj-$(CONFIG_XEN_BLKDEV_FRONTEND)	+= xen-blkfront.o
> +
> +obj-$(CONFIG_DST)	+= dst/
> diff --git a/drivers/block/dst/Kconfig b/drivers/block/dst/Kconfig
> new file mode 100644
> index 0000000..2f42f98
> --- /dev/null
> +++ b/drivers/block/dst/Kconfig
> @@ -0,0 +1,14 @@
> +config DST
> +	tristate "Distributed storage"
> +	depends on NET
> +	select CONNECTOR
> +	select LIBCRC32C
> +	---help---
> +	This driver allows to create a distributed storage block device.

depends on CRYPTO?

depends on BLOCK?

depends on SYSFS?

> +config DST_DEBUG
> +	bool "DST debug"
> +	depends on DST
> +	---help---
> +	This option will turn HEAVY debugging of the DST.
> +	Turn it on ONLY if you have to debug some really obscure problem.
> diff --git a/drivers/block/dst/Makefile b/drivers/block/dst/Makefile
> new file mode 100644
> index 0000000..3a8b0cf
> --- /dev/null
> +++ b/drivers/block/dst/Makefile
>
> ...
>
> +static struct crypto_hash *dst_init_hash(struct dst_crypto_ctl *ctl, u8 *key)
> +{
> +	int err;
> +	struct crypto_hash *hash;
> +
> +	hash = crypto_alloc_hash(ctl->hash_algo, 0, CRYPTO_ALG_ASYNC);
> +	if (IS_ERR(hash)) {
> +		err = PTR_ERR(hash);
> +		dprintk("%s: failed to allocate hash '%s', err: %d.\n",
> +				__func__, ctl->hash_algo, err);
> +		goto err_out_exit;
> +	}
> +
> +	ctl->crypto_attached_size = crypto_hash_digestsize(hash);
> +
> +#if defined CONFIG_DST_DEBUG
> +	dprintk("%s: keysize: %u, key: ", __func__, ctl->hash_keysize);
> +	for (err = 0; err < ctl->hash_keysize; ++err)
> +		printk("%02x ", key[err]);
> +	printk("\n");

lib/hexdump.c?

> +#endif
> +	if (!ctl->hash_keysize)
> +		return hash;
> +
> +	err = crypto_hash_setkey(hash, key, ctl->hash_keysize);
> +	if (err) {
> +		dprintk("%s: failed to set key for hash '%s', err: %d.\n",
> +				__func__, ctl->hash_algo, err);
> +		goto err_out_free;
> +	}
> +
> +	return hash;
> +
> +err_out_free:
> +	crypto_free_hash(hash);
> +err_out_exit:
> +	return ERR_PTR(err);
> +}
> +
>
> ...
>
> +static int dst_crypto_pages_alloc(struct dst_crypto_engine *e, int num)
> +{
> +	int i;
> +
> +	e->pages = kmalloc(num * sizeof(struct page **), GFP_KERNEL);
> +	if (!e->pages)
> +		return -ENOMEM;
> +
> +	for (i=0; i<num; ++i) {
> +		e->pages[i] = alloc_page(GFP_KERNEL);
> +		if (!e->pages[i])
> +			goto err_out_free_pages;
> +	}

I wonder how many places in the kernel do the above.  A little library
function might be good.

> +	e->page_num = num;
> +	return 0;
> +
> +err_out_free_pages:
> +	while (--i >= 0)
> +		__free_page(e->pages[i]);
> +
> +	kfree(e->pages);
> +	return -ENOMEM;
> +}
> +
>
> ...
>
> +static int dst_crypto_process(struct ablkcipher_request *req,
> +		struct scatterlist *sg_dst, struct scatterlist *sg_src,
> +		void *iv, int enc, unsigned long timeout)
> +{
> +	struct dst_crypto_completion c;

hm.  We have DECLARE_COMPLETION_ONSTACK (which is misnamed - it is a
definition).  That was created for some lockdep friendliness.

I expect that your on-stack completion here suffers from whatever problem
DECLARE_COMPLETION_ONSTACK solved.

> +	int err;
> +
> +	init_completion(&c.complete);
> +	c.error = -EINPROGRESS;
> +
> +	ablkcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
> +					dst_crypto_complete, &c);
> +
> +	ablkcipher_request_set_crypt(req, sg_src, sg_dst, sg_src->length, iv);
> +
> +	if (enc)
> +		err = crypto_ablkcipher_encrypt(req);
> +	else
> +		err = crypto_ablkcipher_decrypt(req);
> +
> +	switch (err) {
> +		case -EINPROGRESS:
> +		case -EBUSY:
> +			err = wait_for_completion_interruptible_timeout(&c.complete,
> +					timeout);
> +			if (!err)
> +				err = -ETIMEDOUT;
> +			else
> +				err = c.error;
> +			break;
> +		default:
> +			break;
> +	}
> +
> +	return err;
> +}
> +
>
> ...
>
> +static void *dst_crypto_thread_init(void *data)
> +{
> +	struct dst_node *n = data;
> +	struct dst_crypto_engine *e;
> +	int err = -ENOMEM;
> +
> +	e = kzalloc(sizeof(struct dst_crypto_engine), GFP_KERNEL);
> +	if (!e)
> +		goto err_out_exit;
> +	e->src = kzalloc(sizeof(struct scatterlist) * 2 * n->max_pages,
> +			GFP_KERNEL);

kcalloc()?

> +	if (!e->src)
> +		goto err_out_free;
> +
> +	e->dst = e->src + n->max_pages;
> +
> +	err = dst_crypto_engine_init(e, n);
> +	if (err)
> +		goto err_out_free_all;
> +
> +	return e;
> +
> +err_out_free_all:
> +	kfree(e->src);
> +err_out_free:
> +	kfree(e);
> +err_out_exit:
> +	return ERR_PTR(err);
> +}
> +
>
> ...
>
> +int dst_node_crypto_init(struct dst_node *n, struct dst_crypto_ctl *ctl)
> +{
> +	void *key = (ctl + 1);
> +	int err = -ENOMEM, i;
> +	char name[32];
> +
> +	if (ctl->hash_keysize) {
> +		n->hash_key = kmalloc(ctl->hash_keysize, GFP_KERNEL);
> +		if (!n->hash_key)
> +			goto err_out_exit;
> +		memcpy(n->hash_key, key, ctl->hash_keysize);
> +	}
> +
> +	if (ctl->cipher_keysize) {
> +		n->cipher_key = kmalloc(ctl->cipher_keysize, GFP_KERNEL);
> +		if (!n->cipher_key)
> +			goto err_out_free_hash;
> +		memcpy(n->cipher_key, key, ctl->cipher_keysize);
> +	}
> +	memcpy(&n->crypto, ctl, sizeof(struct dst_crypto_ctl));
> +
> +	for (i=0; i<ctl->thread_num; ++i) {
> +		snprintf(name, sizeof(name), "%s-crypto-%d", n->name, i);
> +		/* Unique ids... */
> +		err = thread_pool_add_worker(n->pool, name, i+10,
> +			dst_crypto_thread_init, dst_crypto_thread_cleanup, n);
> +		if (err)
> +			goto err_out_free_threads;
> +	}
> +
> +	return 0;
> +
> +err_out_free_threads:
> +	while (--i >= 0)
> +		thread_pool_del_worker_id(n->pool, i+10);

Honestly man, how could you possibly have done that +10 thing without
adding a comment explaining to poor readers what the heck it does?

> +	if (ctl->cipher_keysize)
> +		kfree(n->cipher_key);
> +	ctl->cipher_keysize = 0;
> +err_out_free_hash:
> +	if (ctl->hash_keysize)
> +		kfree(n->hash_key);
> +	ctl->hash_keysize = 0;
> +err_out_exit:
> +	return err;
> +}
> +
>
> ...
>
> +static int dst_crypto_process_sending(struct dst_crypto_engine *e,
> +		struct bio *bio, u8 *hash)
> +{
> +	int err;
> +
> +	if (e->cipher) {
> +		err = dst_crypt(e, bio);
> +		if (err)
> +			goto err_out_exit;
> +	}
> +
> +	if (e->hash) {
> +		err = dst_hash(e, bio, hash);
> +		if (err)
> +			goto err_out_exit;
> +
> +#if defined CONFIG_DST_DEBUG

We normally use #ifdef for the simple test.

> +		{
> +			unsigned int i;
> +
> +			//dst_dump_bio(bio);
> +
> +			printk("%s: bio: %llu/%u, rw: %lu, hash: ",
> +				__func__, (u64)bio->bi_sector,
> +				bio->bi_size, bio_data_dir(bio));
> +			for (i=0; i<crypto_hash_digestsize(e->hash); ++i)
> +					printk("%02x ", hash[i]);
> +			printk("\n");
> +		}
> +#endif
> +	}
> +
> +	return 0;
> +
> +err_out_exit:
> +	return err;
> +}
> +
>
> ...
>
> +static int dst_export_crypto_action(void *crypto_engine, void *schedule_data)
> +{
> +	struct dst_crypto_engine *e = crypto_engine;
> +	struct bio *bio = schedule_data;
> +	struct dst_export_priv *p = bio->bi_private;
> +	int err;
> +
> +	dprintk("%s: e: %p, data: %p, bio: %llu/%u, dir: %lu.\n", __func__,
> +		e, e->data, (u64)bio->bi_sector, bio->bi_size, bio_data_dir(bio));
> +
> +	e->enc = (bio_data_dir(bio) == READ);

Strange that something called "enc" is a boolean representing, umm whatever
this represents.  Please document each field in the data structures.  THis
realy helps.

> +	e->iv = p->cmd.id;
> +
> +	if (bio_data_dir(bio) == WRITE) {
> +		u8 *hash = e->data + e->size/2;
> +
> +		err = dst_crypto_process_receiving(e, bio, hash, p->cmd.hash);
> +		if (err)
> +			goto err_out_exit;
> +
> +		generic_make_request(bio);
> +	} else {
> +		err = dst_crypto_process_sending(e, bio, p->cmd.hash);
> +		if (err)
> +			goto err_out_exit;
> +
> +		if (e->hash) {
> +			p->cmd.csize = crypto_hash_digestsize(e->hash);
> +			p->cmd.size += p->cmd.csize;
> +		}
> +
> +		err = dst_export_send_bio(bio);
> +	}
> +	return 0;
> +
> +err_out_exit:
> +	bio_put(bio);
> +	return err;
> +}
> +
>
> ...
>
> +
> +/*
> + * DST sysfs tree for device called 'storage':
> + *
> + * /sys/bus/dst/devices/storage/
> + * /sys/bus/dst/devices/storage/type : 192.168.4.80:1025
> + * /sys/bus/dst/devices/storage/size : 800
> + * /sys/bus/dst/devices/storage/name : storage
> + */

Documentation/ABI/, I guess.

> +static int dst_dev_match(struct device *dev, struct device_driver *drv)
> +{
> +	return 1;
> +}
> +
> +static struct bus_type dst_dev_bus_type = {
> +	.name 		= "dst",
> +	.match 		= &dst_dev_match,
> +};
> +
> +static void dst_node_release(struct device *dev)
> +{
> +}

Is that an empty release function?  Does Documentation/kobject.txt apply? 
(search for "mocked mercilessly").

> +static struct device dst_node_dev = {
> +	.bus 		= &dst_dev_bus_type,
> +	.release 	= &dst_node_release
> +};
> +
> +static void dst_node_set_size(struct dst_node *n)
> +{
> +	struct block_device *bdev;
> +
> +	set_capacity(n->disk, n->size >> 9);
> +
> +	bdev = bdget_disk(n->disk, 0);
> +	if (bdev) {
> +		mutex_lock(&bdev->bd_inode->i_mutex);
> +		i_size_write(bdev->bd_inode, n->size);
> +		mutex_unlock(&bdev->bd_inode->i_mutex);
> +		bdput(bdev);
> +	}
> +}

Should it do something if bdget() failed?

> +/*
> + * Distributed storage request processing function.
> + */
> +static int dst_request(struct request_queue *q, struct bio *bio)
> +{
> +	struct dst_node *n = q->queuedata;
> +
> +	bio_get(bio);
> +
> +	return dst_process_bio(n, bio);
> +}
> +
>
> ...
>
> +/*
> + * Block layer binding - disk is created when array is fully configured
> + * by userspace request.
> + */
> +static int dst_node_create_disk(struct dst_node *n)
> +{
> +	int err = -ENOMEM;
> +	u32 index = 0;
> +
> +	n->queue = blk_alloc_queue(GFP_KERNEL);
> +	if (!n->queue)
> +		goto err_out_exit;
> +
> +	n->queue->queuedata = n;
> +	blk_queue_make_request(n->queue, dst_request);
> +	blk_queue_max_phys_segments(n->queue, n->max_pages);
> +	blk_queue_max_hw_segments(n->queue, n->max_pages);
> +
> +	err = -EINVAL;
> +	n->disk = alloc_disk(1);
> +	if (!n->disk)
> +		goto err_out_free_queue;

This should return -ENOMEM.

> +
> +	if (!(n->state->permissions & DST_PERM_WRITE)) {
> +		printk(KERN_INFO "DST node %s attached read-only.\n", n->name);
> +		set_disk_ro(n->disk, 1);
> +	}
> +
> +	err = -ENOMEM;
> +	if (!idr_pre_get(&dst_index_idr, GFP_KERNEL))
> +		goto err_out_put;
> +
> +	mutex_lock(&dst_hash_lock);
> +	err = idr_get_new(&dst_index_idr, NULL, &index);
> +	mutex_unlock(&dst_hash_lock);
> +	if (err)
> +		goto err_out_put;
> +
> +	n->disk->major = dst_major;
> +	n->disk->first_minor = index;
> +	n->disk->fops = &dst_blk_ops;
> +	n->disk->queue = n->queue;
> +	n->disk->private_data = n;
> +	snprintf(n->disk->disk_name, sizeof(n->disk->disk_name), "dst-%s", n->name);
> +
> +	return 0;
> +
> +err_out_put:
> +	put_disk(n->disk);
> +err_out_free_queue:
> +	blk_cleanup_queue(n->queue);
> +err_out_exit:
> +	return err;
> +}
> +
> +static ssize_t dst_show_size(struct device *dev,
> +		struct device_attribute *attr, char *buf)
> +{
> +	struct dst_node *n = container_of(dev, struct dst_node, device);
> +
> +	return sprintf(buf, "%llu\n", n->size);
> +}
> +
> +/*
> + * Shows type of the remote node - device major/minor number
> + * for local nodes and address (af_inet ipv4/ipv6 only) for remote nodes.
> + */
> +static ssize_t dst_show_type(struct device *dev,
> +		struct device_attribute *attr, char *buf)
> +{
> +	struct dst_node *n = container_of(dev, struct dst_node, device);
> +	struct sockaddr addr;
> +	struct socket *sock;
> +	int addrlen;
> +
> +	sock = n->state->socket;
> +	if (sock->ops->getname(sock, &addr, &addrlen, 2))
> +		return 0;
> +
> +	if (sock->ops->family == AF_INET) {
> +		struct sockaddr_in *sin = (struct sockaddr_in *)&addr;
> +		return sprintf(buf, "%u.%u.%u.%u:%d\n",
> +			NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));

hm, we still don't have a %p handler for ipv4 addresses.

> +	} else if (sock->ops->family == AF_INET6) {
> +		struct sockaddr_in6 *sin = (struct sockaddr_in6 *)&addr;
> +		return sprintf(buf,
> +			"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%d\n",
> +			NIP6(sin->sin6_addr), ntohs(sin->sin6_port));
> +	} else {
> +		int i, sz = PAGE_SIZE - 2; /* 0 symbol and '\n' below */
> +		int size;
> +		unsigned char *a = (unsigned char *)&addr;
> +		char *buf_orig = buf;
> +
> +		size = snprintf(buf, sz, "family: %d, addrlen: %u, addr: ",
> +				addr.sa_family, addrlen);
> +		sz -= size;
> +		buf += size;
> +
> +		for (i=0; i<addrlen; ++i) {
> +			if (sz < 3)
> +				break;
> +
> +			size = snprintf(buf, sz, "%02x ", a[i]);
> +			sz -= size;
> +			buf += size;
> +		}
> +		buf += sprintf(buf, "\n");
> +
> +		return buf - buf_orig;
> +	}
> +	return 0;
> +}
> +
> +static struct device_attribute dst_node_attrs[] = {
> +	__ATTR(size, 0444, dst_show_size, NULL),
> +	__ATTR(type, 0444, dst_show_type, NULL),
> +};
> +
>
> ...
>
> +static void dst_node_cleanup(struct dst_node *n)
> +{
> +	struct dst_state *st = n->state;
> +
> +	if (!st)
> +		return;
> +
> +	if (n->queue) {
> +		blk_cleanup_queue(n->queue);
> +
> +		mutex_lock(&dst_hash_lock);
> +		idr_remove(&dst_index_idr, n->disk->first_minor);
> +		mutex_unlock(&dst_hash_lock);
> +
> +		put_disk(n->disk);
> +	}
> +
> +	if (n->bdev) {
> +		sync_blockdev(n->bdev);
> +		blkdev_put(n->bdev);
> +	}
> +
> +	dst_state_lock(st);
> +	st->need_exit = 1;
> +	dst_state_exit_connected(st);
> +	dst_state_unlock(st);
> +
> +	wake_up(&st->thread_wait);

Should we wait for them to all run and exit?

> +	dst_state_put(st);
> +	n->state = NULL;
> +}
> +
>
> ...
>
> +static int dst_setup_export(struct dst_node *n, struct dst_ctl *ctl,
> +		struct dst_export_ctl *le)
> +{
> +	int err;
> +	dev_t dev = 0; /* gcc likes to scream here */
> +
> +	err = dst_lookup_device(le->device, &dev);
> +	if (err)
> +		return err;
> +
> +	n->bdev = open_by_devnum(dev, FMODE_READ|FMODE_WRITE);
> +	if (!n->bdev)
> +		return -ENODEV;
> +
> +	if (n->size != 0)
> +		n->size = min_t(loff_t, n->bdev->bd_inode->i_size, n->size);
> +	else
> +		n->size = n->bdev->bd_inode->i_size;
> +
> +	err = dst_node_init_listened(n, le);
> +	if (err)
> +		goto err_out_cleanup;
> +
> +	return 0;
> +
> +err_out_cleanup:
> +	sync_blockdev(n->bdev);

The sync_blockdev() is unexpected and needs a comment.

> +	blkdev_put(n->bdev);
> +	n->bdev = NULL;
> +
> +	return err;
> +}
> +
>
> ...
>
> +static int __init dst_hashtable_init(void)
> +{
> +	unsigned int i;
> +
> +	dst_hashtable = kzalloc(sizeof(struct list_head) * dst_hashtable_size,
> +			GFP_KERNEL);

kcalloc()?

> +	if (!dst_hashtable)
> +		return -ENOMEM;
> +
> +	for (i=0; i<dst_hashtable_size; ++i)
> +		INIT_LIST_HEAD(&dst_hashtable[i]);
> +
> +	return 0;
> +}
> +
> +static void dst_hashtable_exit(void)
> +{
> +	unsigned int i;
> +	struct dst_node *n, *tmp;
> +
> +	for (i=0; i<dst_hashtable_size; ++i) {
> +		list_for_each_entry_safe(n, tmp, &dst_hashtable[i], node_entry) {
> +			dst_node_remove_unload(n);
> +		}
> +	}
> +
> +	kfree(dst_hashtable);
> +}
> +
> +static int __init dst_sys_init(void)
> +{
> +	int err = -ENOMEM;
> +	struct cb_id cn_dst_id = { CN_DST_IDX, CN_DST_VAL };

static?

> +	err = dst_hashtable_init();
> +	if (err)
> +		goto err_out_exit;
> +
> +	err = dst_export_init();
> +	if (err)
> +		goto err_out_hashtable_exit;
> +
> +	err = register_blkdev(dst_major, DST_NAME);
> +	if (err < 0)
> +		goto err_out_export_exit;
> +	if (err)
> +		dst_major = err;
> +
> +	err = dst_sysfs_init();
> +	if (err)
> +		goto err_out_unregister;
> +
> +	err = cn_add_callback(&cn_dst_id, "DST", cn_dst_callback);
> +	if (err)
> +		goto err_out_sysfs_exit;
> +
> +	printk(KERN_INFO "Distributed storage, '%s' release.\n", dst_name);
> +
> +	return 0;
> +
> +err_out_sysfs_exit:
> +	dst_sysfs_exit();
> +err_out_unregister:
> +	unregister_blkdev(dst_major, DST_NAME);
> +err_out_export_exit:
> +	dst_export_exit();
> +err_out_hashtable_exit:
> +	dst_hashtable_exit();
> +err_out_exit:
> +	return err;
> +}
> +
> +static void __exit dst_sys_exit(void)
> +{
> +	struct cb_id cn_dst_id = { CN_DST_IDX, CN_DST_VAL };

Static?

Share with the above copy?

> +	cn_del_callback(&cn_dst_id);
> +	unregister_blkdev(dst_major, DST_NAME);
> +	dst_hashtable_exit();
> +	dst_sysfs_exit();
> +	dst_export_exit();
> +}
> +
>
> ...
>
> +static struct dst_state *dst_accept_client(struct dst_state *st)
> +{
> +	unsigned int revents = 0;
> +	unsigned int err_mask = POLLERR | POLLHUP | POLLRDHUP;
> +	unsigned int mask = err_mask | POLLIN;
> +	struct dst_node *n = st->node;
> +	int err = 0;
> +	struct socket *sock = NULL;
> +	struct dst_state *new;
> +
> +	while (!err && !sock) {
> +		revents = dst_state_poll(st);
> +
> +		if (!(revents & mask)) {
> +			DEFINE_WAIT(wait);
> +
> +			for (;;) {
> +				prepare_to_wait(&st->thread_wait,
> +						&wait, TASK_INTERRUPTIBLE);
> +				if (!n->trans_scan_timeout || st->need_exit)
> +					break;
> +
> +				revents = dst_state_poll(st);
> +
> +				if (revents & mask)
> +					break;
> +
> +				if (signal_pending(current))
> +					break;
> +
> +				schedule_timeout(HZ);
> +			}
> +			finish_wait(&st->thread_wait, &wait);
> +		}

See, this unexpected one-second-polling thing is unexpected and there is no
way on God's green earth that I can tell from the implementation why it was
added and what problem it is solving.

> +		err = -ECONNRESET;
> +		dst_state_lock(st);
> +
> +		dprintk("%s: st: %p, revents: %x [err: %d, in: %d].\n",
> +			__func__, st, revents, revents & err_mask,
> +			revents & POLLIN);
> +
> +		if (revents & err_mask) {
> +			printk("%s: revents: %x, socket: %p, err: %d.\n",
> +					__func__, revents, st->socket, err);
> +			err = -ECONNRESET;
> +		}
> +
> +		if (!n->trans_scan_timeout || st->need_exit)
> +			err = -ENODEV;
> +
> +		if (st->socket && (revents & POLLIN))
> +			err = kernel_accept(st->socket, &sock, 0);
> +
> +		dst_state_unlock(st);
> +	}
> +
> +	if (err)
> +		goto err_out_exit;
> +
> +	new = dst_state_alloc(st->node);
> +	if (!new) {
> +		err = -ENOMEM;
> +		goto err_out_release;
> +	}
> +	new->socket = sock;
> +
> +	new->ctl.addr.sa_data_len = sizeof(struct sockaddr);
> +	err = kernel_getpeername(sock, (struct sockaddr *)&new->ctl.addr,
> +			(int *)&new->ctl.addr.sa_data_len);
> +	if (err)
> +		goto err_out_put;
> +
> +	new->permissions = dst_check_permissions(st, new);
> +	if (new->permissions == 0) {
> +		err = -EPERM;
> +		dst_dump_addr(sock, (struct sockaddr *)&new->ctl.addr,
> +				"Client is not allowed to connect");
> +		goto err_out_put;
> +	}
> +
> +	err = dst_poll_init(new);
> +	if (err)
> +		goto err_out_put;
> +
> +	dst_dump_addr(sock, (struct sockaddr *)&new->ctl.addr,
> +			"Connected client");
> +
> +	return new;
> +
> +err_out_put:
> +	dst_state_put(new);
> +err_out_release:
> +	sock_release(sock);
> +err_out_exit:
> +	return ERR_PTR(err);
> +}
> +
>
> ...
>
> +static int dst_export_write_request(struct dst_state *st,
> +		struct bio *bio, unsigned int total_size)
> +{
> +	unsigned int size;
> +	struct page *page;
> +	void *data;
> +	int err;
> +
> +	while (total_size) {
> +		err = -ENOMEM;
> +		page = alloc_page(GFP_KERNEL);
> +		if (!page)
> +			goto err_out_exit;
> +
> +		data = kmap(page);

There is never a need to kmap a GFP_KERNEL page.

kmap() is slow and deadlocky.  kmap_atomic() is preferred.

> +		if (!data)
> +			goto err_out_free_page;

kmap() cannot fail (see "deadlocky", above)

> +		size = min_t(unsigned int, PAGE_SIZE, total_size);
> +
> +		err = dst_data_recv(st, data, size);
> +		if (err)
> +			goto err_out_unmap_page;
> +
> +		err = bio_add_page(bio, page, size, 0);
> +		if (err <= 0)
> +			goto err_out_unmap_page;
> +
> +		kunmap(page);
> +
> +		total_size -= size;
> +	}
> +
> +	return 0;
> +
> +err_out_unmap_page:
> +	kunmap(page);
> +err_out_free_page:
> +	__free_page(page);
> +err_out_exit:
> +	return err;
> +}
> +
>
> ...
>
> +static void __inline__ dst_state_reset_nolock(struct dst_state *st)

s/__inline__/inline/g

> +{
> +	dst_state_exit_connected(st);
> +	dst_state_init_connected(st);
> +}
> +
>
> ...
>
> --- /dev/null
> +++ b/drivers/block/dst/thread_pool.c

I don't think that any of this thread pool code is specific to this driver?
It shouldn't be.

It would be much much better to present and review this as a separate
standalone patch creating lib/thread_pool.c

>
> ...
>
> +static inline void dst_state_unlock(struct dst_state *st)
> +{
> +	BUG_ON(!mutex_is_locked(&st->state_lock));
> +
> +	mutex_unlock(&st->state_lock);
> +}

surely lockdep or mutex debugging already warn about unlock of a not-locked
mutex.

Casually adding debug stuff to an inlined function can cause rather a lot
of bloat.

> +void dst_poll_exit(struct dst_state *st);
> +int dst_poll_init(struct dst_state *st);
> +
>
> ...
>
> +static inline void dst_bio_to_cmd(struct bio *bio, struct dst_cmd *cmd,
> +		u32 command, u64 id)
> +{
> +	cmd->cmd = command;
> +	cmd->flags = (bio->bi_flags << BIO_POOL_BITS) >> BIO_POOL_BITS;

hm, strange.  Appears to assume that no bits higher than those described by
BIO_POOL_BITS will ever be used.  That's fragile.

> +	cmd->rw = bio->bi_rw;
> +	cmd->size = bio->bi_size;
> +	cmd->csize = 0;
> +	cmd->id = id;
> +	cmd->sector = bio->bi_sector;
> +};
> +
> +int dst_trans_send(struct dst_trans *t);
> +int dst_trans_crypto(struct dst_trans *t);
> +
> +int dst_node_crypto_init(struct dst_node *n, struct dst_crypto_ctl *ctl);
> +void dst_node_crypto_exit(struct dst_node *n);
> +
> +static inline int dst_need_crypto(struct dst_node *n)
> +{
> +	struct dst_crypto_ctl *c = &n->crypto;
> +	return (c->hash_algo[0] || c->cipher_algo[0]);

Using single | might generate better code (but it'd need a comment
explaining that it's a deliberate trick).

Or not do it - just a thought.

> +}
> +
>
> ...
>
