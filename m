From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage release.
Date: Mon, 13 Oct 2008 17:38:53 +0400
Message-ID: <20081013133850.GA13565@2ka.mipt.ru>
References: <20081006160034.GA611@2ka.mipt.ru> <20081012192419.fd8394c9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081012192419.fd8394c9.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew.

On Sun, Oct 12, 2008 at 07:24:19PM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> Please include diffstat with patches.

Ok, will do.

> checkpatch says
> 
> total: 83 errors, 52 warnings, 4023 lines checked
> 
> many of which indeed should be fixed.

There are two types of errors: long lines, which are actually comments
on the same line as structure members or a little bit more than 80;
and things like spaces and braces. All other errors should be already
fixed, but stuff like this: for (i = 0; i < 10; ++i) are not, since we
can argue forever if this is better than for (i=0; i<10; ++i) or 
int (* iterator) (struct dst_crypto_engine *e, vs
int (*iterator) (struct dst_crypto_engine *e,
:)
Also braces on the same line with the structure definition does not look
good imho, and it is reported as error by checkpatch. Also found two
previously missed trailing whitespaces, will fix them.

> OK, I was going to spend an hour reviewing this patch but the almost total
> lack of useful comments means that this would be largely a waste of your
> time and of mine.  I would need to read the implementation sufficiently
> closely to work out what it is setting out to do and I then would have to
> check whether it is doing it correctly.
> 
> Now I _could_ do that, although it would take a lot of time and the review
> would be less productive.  But it would mean that the code is still hard to
> understand and hence hard to maitain.  A much better outcome would be for
> you to properly document it.  That will result in more efficient review,
> more effective review and better code.
> 
> No?

How much time did you spend reviewin it without comments? :)

> So please.  Go through all the code and make it tell a story.  Ask yourself
> "how would I explain all this to a kernel developer who is sitting next to
> me".  It's important, and it's an important skill.

Ok, I will add comments. 
 
> The means by which the code's memory allocation is "bulletproof" should be
> fully described in changelog comments so that those who are working on this
> sort of thing can check your homework, please.

Client uses only single additional allocation per request (comapred to fair
number in device mapper for example) and it is made out of a memory
pool. Network itself adds more, but block layer is quite optimal.
Server works differently, since it has to have lots of pages to do IO,
but again control structures (bio for example) are allocated from the
memory pools. Besides that there are no additional allocations and
preallocated buffers or page pools (for crypto processing) are used.

> I assume all this code adds some sort of userspace<->kernel interface. 
> That should be documented in the kernel tree, so we can review it.

It uses existing netlink connector interface, structures are partially
documented though.

> It would be good to document the on-the-wire protocol.  That's an important
> thing.

Ok.

> > +++ b/drivers/block/dst/Kconfig
> > @@ -0,0 +1,14 @@
> > +config DST
> > +	tristate "Distributed storage"
> > +	depends on NET
> > +	select CONNECTOR
> > +	select LIBCRC32C
> > +	---help---
> > +	This driver allows to create a distributed storage block device.
> 
> depends on CRYPTO?
> 
> depends on BLOCK?
> 
> depends on SYSFS?

It depends on block by virtue of its config living in BLK_DEV submenu.
It depends on sysfs though. I thought it already selected blkcipher, but
apparently it does not, so dependency on crypto is also needed.

> > +#if defined CONFIG_DST_DEBUG
> > +	dprintk("%s: keysize: %u, key: ", __func__, ctl->hash_keysize);
> > +	for (err = 0; err < ctl->hash_keysize; ++err)
> > +		printk("%02x ", key[err]);
> > +	printk("\n");
> 
> lib/hexdump.c?

Yup, it can be used too.

> > +static int dst_crypto_pages_alloc(struct dst_crypto_engine *e, int num)
> > +{
> > +	int i;
> > +
> > +	e->pages = kmalloc(num * sizeof(struct page **), GFP_KERNEL);
> > +	if (!e->pages)
> > +		return -ENOMEM;
> > +
> > +	for (i=0; i<num; ++i) {
> > +		e->pages[i] = alloc_page(GFP_KERNEL);
> > +		if (!e->pages[i])
> > +			goto err_out_free_pages;
> > +	}
> 
> I wonder how many places in the kernel do the above.  A little library
> function might be good.

Matter of a taste I think. Do you really want this to be in
mm/mempolicy.c or around?

> > +static int dst_crypto_process(struct ablkcipher_request *req,
> > +		struct scatterlist *sg_dst, struct scatterlist *sg_src,
> > +		void *iv, int enc, unsigned long timeout)
> > +{
> > +	struct dst_crypto_completion c;
> 
> hm.  We have DECLARE_COMPLETION_ONSTACK (which is misnamed - it is a
> definition).  That was created for some lockdep friendliness.
> 
> I expect that your on-stack completion here suffers from whatever problem
> DECLARE_COMPLETION_ONSTACK solved.

Actually on-stack completions are everywhere, it is ok if they use
dynamic initialization with init_completion() and not
COMPLETION_INITIALIZER.

> > +static void *dst_crypto_thread_init(void *data)
> > +{
> > +	struct dst_node *n = data;
> > +	struct dst_crypto_engine *e;
> > +	int err = -ENOMEM;
> > +
> > +	e = kzalloc(sizeof(struct dst_crypto_engine), GFP_KERNEL);
> > +	if (!e)
> > +		goto err_out_exit;
> > +	e->src = kzalloc(sizeof(struct scatterlist) * 2 * n->max_pages,
> > +			GFP_KERNEL);
> 
> kcalloc()?

What's the difference? In saving one space and replacing another with
comma? I do not particulary care, but would like to know why it is
needed :)

> > +int dst_node_crypto_init(struct dst_node *n, struct dst_crypto_ctl *ctl)
> > +{
> > +	void *key = (ctl + 1);
> > +	int err = -ENOMEM, i;
> > +	char name[32];
> > +
> > +	if (ctl->hash_keysize) {
> > +		n->hash_key = kmalloc(ctl->hash_keysize, GFP_KERNEL);
> > +		if (!n->hash_key)
> > +			goto err_out_exit;
> > +		memcpy(n->hash_key, key, ctl->hash_keysize);
> > +	}
> > +
> > +	if (ctl->cipher_keysize) {
> > +		n->cipher_key = kmalloc(ctl->cipher_keysize, GFP_KERNEL);
> > +		if (!n->cipher_key)
> > +			goto err_out_free_hash;
> > +		memcpy(n->cipher_key, key, ctl->cipher_keysize);
> > +	}
> > +	memcpy(&n->crypto, ctl, sizeof(struct dst_crypto_ctl));
> > +
> > +	for (i=0; i<ctl->thread_num; ++i) {
> > +		snprintf(name, sizeof(name), "%s-crypto-%d", n->name, i);
> > +		/* Unique ids... */
> > +		err = thread_pool_add_worker(n->pool, name, i+10,
> > +			dst_crypto_thread_init, dst_crypto_thread_cleanup, n);
> > +		if (err)
> > +			goto err_out_free_threads;
> > +	}
> > +
> > +	return 0;
> > +
> > +err_out_free_threads:
> > +	while (--i >= 0)
> > +		thread_pool_del_worker_id(n->pool, i+10);
> 
> Honestly man, how could you possibly have done that +10 thing without
> adding a comment explaining to poor readers what the heck it does?

There is a comment above: Unique ids, zero is used by initial
thread, so I added +10 :) It is not actually used iirc, but produce a
nicer look in 'ps ax'.

> > +static int dst_crypto_process_sending(struct dst_crypto_engine *e,
> > +		struct bio *bio, u8 *hash)
> > +{
> > +	int err;
> > +
> > +	if (e->cipher) {
> > +		err = dst_crypt(e, bio);
> > +		if (err)
> > +			goto err_out_exit;
> > +	}
> > +
> > +	if (e->hash) {
> > +		err = dst_hash(e, bio, hash);
> > +		if (err)
> > +			goto err_out_exit;
> > +
> > +#if defined CONFIG_DST_DEBUG
> 
> We normally use #ifdef for the simple test.

Ok.

> > +static int dst_export_crypto_action(void *crypto_engine, void *schedule_data)
> > +{
> > +	struct dst_crypto_engine *e = crypto_engine;
> > +	struct bio *bio = schedule_data;
> > +	struct dst_export_priv *p = bio->bi_private;
> > +	int err;
> > +
> > +	dprintk("%s: e: %p, data: %p, bio: %llu/%u, dir: %lu.\n", __func__,
> > +		e, e->data, (u64)bio->bi_sector, bio->bi_size, bio_data_dir(bio));
> > +
> > +	e->enc = (bio_data_dir(bio) == READ);
> 
> Strange that something called "enc" is a boolean representing, umm whatever
> this represents.  Please document each field in the data structures.  THis
> realy helps.

It is encryption direction, it depends on IO direction and either it is
performed on server or client, so may be confusing...

> > +/*
> > + * DST sysfs tree for device called 'storage':
> > + *
> > + * /sys/bus/dst/devices/storage/
> > + * /sys/bus/dst/devices/storage/type : 192.168.4.80:1025
> > + * /sys/bus/dst/devices/storage/size : 800
> > + * /sys/bus/dst/devices/storage/name : storage
> > + */
> 
> Documentation/ABI/, I guess.

This is just a text info, do you really think it should be there?

> > +static struct bus_type dst_dev_bus_type = {
> > +	.name 		= "dst",
> > +	.match 		= &dst_dev_match,
> > +};
> > +
> > +static void dst_node_release(struct device *dev)
> > +{
> > +}
> 
> Is that an empty release function?  Does Documentation/kobject.txt apply? 
> (search for "mocked mercilessly").

Documentation lacks the case, when object is actually embedded into
another one, which has appropriate reference counters and does not need
kobject tree. So, before mocking one should think at least twice :)

> > +static void dst_node_set_size(struct dst_node *n)
> > +{
> > +	struct block_device *bdev;
> > +
> > +	set_capacity(n->disk, n->size >> 9);
> > +
> > +	bdev = bdget_disk(n->disk, 0);
> > +	if (bdev) {
> > +		mutex_lock(&bdev->bd_inode->i_mutex);
> > +		i_size_write(bdev->bd_inode, n->size);
> > +		mutex_unlock(&bdev->bd_inode->i_mutex);
> > +		bdput(bdev);
> > +	}
> > +}
> 
> Should it do something if bdget() failed?

First, it can not, since inode is being hold 'above' in the call stack,
second, even if it fails in the parallel universe, size just is not
updated and old one is used. Without this hunk run-time object size
changes will not be noticed by for example filesystem and
reading/writing will return EIO errors.

> > +/*
> > + * Block layer binding - disk is created when array is fully configured
> > + * by userspace request.
> > + */
> > +static int dst_node_create_disk(struct dst_node *n)
> > +{
> > +	int err = -ENOMEM;
> > +	u32 index = 0;
> > +
> > +	n->queue = blk_alloc_queue(GFP_KERNEL);
> > +	if (!n->queue)
> > +		goto err_out_exit;
> > +
> > +	n->queue->queuedata = n;
> > +	blk_queue_make_request(n->queue, dst_request);
> > +	blk_queue_max_phys_segments(n->queue, n->max_pages);
> > +	blk_queue_max_hw_segments(n->queue, n->max_pages);
> > +
> > +	err = -EINVAL;
> > +	n->disk = alloc_disk(1);
> > +	if (!n->disk)
> > +		goto err_out_free_queue;
> 
> This should return -ENOMEM.

Yup.

> > +	if (sock->ops->family == AF_INET) {
> > +		struct sockaddr_in *sin = (struct sockaddr_in *)&addr;
> > +		return sprintf(buf, "%u.%u.%u.%u:%d\n",
> > +			NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
> 
> hm, we still don't have a %p handler for ipv4 addresses.

:)

> > +static void dst_node_cleanup(struct dst_node *n)
> > +{
> > +	struct dst_state *st = n->state;
> > +
> > +	if (!st)
> > +		return;
> > +
> > +	if (n->queue) {
> > +		blk_cleanup_queue(n->queue);
> > +
> > +		mutex_lock(&dst_hash_lock);
> > +		idr_remove(&dst_index_idr, n->disk->first_minor);
> > +		mutex_unlock(&dst_hash_lock);
> > +
> > +		put_disk(n->disk);
> > +	}
> > +
> > +	if (n->bdev) {
> > +		sync_blockdev(n->bdev);
> > +		blkdev_put(n->bdev);
> > +	}
> > +
> > +	dst_state_lock(st);
> > +	st->need_exit = 1;
> > +	dst_state_exit_connected(st);
> > +	dst_state_unlock(st);
> > +
> > +	wake_up(&st->thread_wait);
> 
> Should we wait for them to all run and exit?

We will wait for threads in subsequent call to
thread_pool_destroy().

> > +static int dst_setup_export(struct dst_node *n, struct dst_ctl *ctl,
> > +		struct dst_export_ctl *le)
> > +{
> > +	int err;
> > +	dev_t dev = 0; /* gcc likes to scream here */
> > +
> > +	err = dst_lookup_device(le->device, &dev);
> > +	if (err)
> > +		return err;
> > +
> > +	n->bdev = open_by_devnum(dev, FMODE_READ|FMODE_WRITE);
> > +	if (!n->bdev)
> > +		return -ENODEV;
> > +
> > +	if (n->size != 0)
> > +		n->size = min_t(loff_t, n->bdev->bd_inode->i_size, n->size);
> > +	else
> > +		n->size = n->bdev->bd_inode->i_size;
> > +
> > +	err = dst_node_init_listened(n, le);
> > +	if (err)
> > +		goto err_out_cleanup;
> > +
> > +	return 0;
> > +
> > +err_out_cleanup:
> > +	sync_blockdev(n->bdev);
> 
> The sync_blockdev() is unexpected and needs a comment.

Copied from older code, when it was a call for release function, used
both by just this open path and after disk registration and appropriate
IO on it.

> > +	blkdev_put(n->bdev);
> > +	n->bdev = NULL;
> > +
> > +	return err;
> > +}
> > +
> >
> > ...
> >
> > +static int __init dst_hashtable_init(void)
> > +{
> > +	unsigned int i;
> > +
> > +	dst_hashtable = kzalloc(sizeof(struct list_head) * dst_hashtable_size,
> > +			GFP_KERNEL);
> 
> kcalloc()?

To save a space? Ok :)

> > +static int __init dst_sys_init(void)
> > +{
> > +	int err = -ENOMEM;
> > +	struct cb_id cn_dst_id = { CN_DST_IDX, CN_DST_VAL };
> 
> static?
>
> > +static void __exit dst_sys_exit(void)
> > +{
> > +	struct cb_id cn_dst_id = { CN_DST_IDX, CN_DST_VAL };
> 
> Static?
> 
> Share with the above copy?

It could be...
 
> > +	while (!err && !sock) {
> > +		revents = dst_state_poll(st);
> > +
> > +		if (!(revents & mask)) {
> > +			DEFINE_WAIT(wait);
> > +
> > +			for (;;) {
> > +				prepare_to_wait(&st->thread_wait,
> > +						&wait, TASK_INTERRUPTIBLE);
> > +				if (!n->trans_scan_timeout || st->need_exit)
> > +					break;
> > +
> > +				revents = dst_state_poll(st);
> > +
> > +				if (revents & mask)
> > +					break;
> > +
> > +				if (signal_pending(current))
> > +					break;
> > +
> > +				schedule_timeout(HZ);
> > +			}
> > +			finish_wait(&st->thread_wait, &wait);
> > +		}
> 
> See, this unexpected one-second-polling thing is unexpected and there is no
> way on God's green earth that I can tell from the implementation why it was
> added and what problem it is solving.

It is used to check polling and exit flags. One can not add simple
wakeup callbacks into network socket invalidation path, particulary
socket can be marked closed in bottom half, so no mutex locking there.
Actually I know, how network polling works and it can be accesed withuot
locks _there_, but still there are places, where it can not, so I
decided not to mess with different locks and just wakes once per timeout
and check the polling flags.

> > +static int dst_export_write_request(struct dst_state *st,
> > +		struct bio *bio, unsigned int total_size)
> > +{
> > +	unsigned int size;
> > +	struct page *page;
> > +	void *data;
> > +	int err;
> > +
> > +	while (total_size) {
> > +		err = -ENOMEM;
> > +		page = alloc_page(GFP_KERNEL);
> > +		if (!page)
> > +			goto err_out_exit;
> > +
> > +		data = kmap(page);
> 
> There is never a need to kmap a GFP_KERNEL page.
> 
> kmap() is slow and deadlocky.  kmap_atomic() is preferred.
> 
> > +		if (!data)
> > +			goto err_out_free_page;
> 
> kmap() cannot fail (see "deadlocky", above)

kmap_atomic() can not be used here, since receiving path may sleep.
This will not be a high mem, so no deadlocks.

> > +static void __inline__ dst_state_reset_nolock(struct dst_state *st)
> 
> s/__inline__/inline/g

Ok. Why not plain 'inline'?

> > --- /dev/null
> > +++ b/drivers/block/dst/thread_pool.c
> 
> I don't think that any of this thread pool code is specific to this driver?
> It shouldn't be.
> 
> It would be much much better to present and review this as a separate
> standalone patch creating lib/thread_pool.c

It is not driver-specific, but this means that DST project itself will
have to depend on something else which will not be accepted upstream in
a near future. I already have similar case for POHMELFS, where I just
carry couple of export patches for VFS functions, and thus is not able
to make it as external module.

lib/thread_pool.c is a good idea, but there will always be people who do
not like it, I already lerned this kernel lesson. Spending days and days
trying to create an ideal subsystem to match anyone's expectation about
perfect interafaces and features jsut does not work, and kernel gets the
patch from one, who is closer to the high end. I'm far from there, so
will wait for perfect interface from anyone else and then convert DST if
needed.

> > +static inline void dst_state_unlock(struct dst_state *st)
> > +{
> > +	BUG_ON(!mutex_is_locked(&st->state_lock));
> > +
> > +	mutex_unlock(&st->state_lock);
> > +}
> 
> surely lockdep or mutex debugging already warn about unlock of a not-locked
> mutex.
> 
> Casually adding debug stuff to an inlined function can cause rather a lot
> of bloat.

Yup, I will remove it.

> > +void dst_poll_exit(struct dst_state *st);
> > +int dst_poll_init(struct dst_state *st);
> > +
> >
> > ...
> >
> > +static inline void dst_bio_to_cmd(struct bio *bio, struct dst_cmd *cmd,
> > +		u32 command, u64 id)
> > +{
> > +	cmd->cmd = command;
> > +	cmd->flags = (bio->bi_flags << BIO_POOL_BITS) >> BIO_POOL_BITS;
> 
> hm, strange.  Appears to assume that no bits higher than those described by
> BIO_POOL_BITS will ever be used.  That's fragile.

There is a comment for those bits in export.c where they are used :)

/*
 * Server side is only interested in two low bits:
 * uptodate (set by itself actually) and rw
 * block
 */
bio->bi_flags |= cmd->flags & 3;

cmd->flags assignment actually clears bio pool bits, which are unused
(server side can allocate bio from different pool, so it obviously
should use own flags).

> > +static inline int dst_need_crypto(struct dst_node *n)
> > +{
> > +	struct dst_crypto_ctl *c = &n->crypto;
> > +	return (c->hash_algo[0] || c->cipher_algo[0]);
> 
> Using single | might generate better code (but it'd need a comment
> explaining that it's a deliberate trick).
> 
> Or not do it - just a thought.

Getting that I have to write really lots of comments for this project,
additional hunk will not hurt.

Thanks a lot for review, Andrew, I will work out issues you pointed and
send updated version soon.

-- 
	Evgeniy Polyakov
