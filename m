From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH v11 13/17] Add mp(mediate passthru) device.
Date: Wed, 29 Sep 2010 21:38:42 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D792EC64F8154@shsmsx502.ccr.corp.intel.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
	 <2c954a831e2d9a93437aaf06386cd3a5af6b73b9.1285385607.git.xiaohui.xin@intel.com>
 <1285622613.2263.550.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285622613.2263.550.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>Sent: Tuesday, September 28, 2010 5:24 AM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>jdike@linux.intel.com
>Subject: Re: [PATCH v11 13/17] Add mp(mediate passthru) device.
>
>On Sat, 2010-09-25 at 12:27 +0800, xiaohui.xin@intel.com wrote:
>> From: Xin Xiaohui <xiaohui.xin@intel.com>
>>
>> The patch add mp(mediate passthru) device, which now
>> based on vhost-net backend driver and provides proto_ops
>> to send/receive guest buffers data from/to guest vitio-net
>> driver.
>>
>> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
>> Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
>> Reviewed-by: Jeff Dike <jdike@linux.intel.com>
>> ---
>>  drivers/vhost/mpassthru.c | 1407
>+++++++++++++++++++++++++++++++++++++++++++++
>>  1 files changed, 1407 insertions(+), 0 deletions(-)
>>  create mode 100644 drivers/vhost/mpassthru.c
>>
>> diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
>> new file mode 100644
>> index 0000000..d86d94c
>> --- /dev/null
>> +++ b/drivers/vhost/mpassthru.c
>[...]
>> +/* #define MPASSTHRU_DEBUG 1 */
>> +
>> +#ifdef MPASSTHRU_DEBUG
>> +static int debug;
>> +
>> +#define DBG  if (mp->debug) printk
>> +#define DBG1 if (debug == 2) printk
>
>This is unsafe; consider this usage:
>
>	if (foo)
>		DBG("bar\n");
>	else
>		baz();
>
>You should use the standard pr_debug() or dev_dbg() instead.
>
Ok. Move to pr_debug().

>[...]
>> +struct page_ctor {
>> +       struct list_head        readq;
>> +       int                     wq_len;
>> +       int                     rq_len;
>> +       spinlock_t              read_lock;
>
>Only one queue?!
>
This readq is for mp device to store the rx guest buffers coming from vhost.
For tx side, we don't need that, since tx buffers are sent out to device immediately.

>I would have appreciated some introductory comments on these structures.
>I still don't have any sort of clear picture of how this is all supposed
>to work.
>
Basically, struct page_info{} is used to store each info of the guest buffers
and some of vhost ring descriptor info according to this buffers.
struct page_ctor{} is used to manipulate multiple struct page_info{}.
Each device can do zero-copy is according one struct page_ctor{}.

Anyway, I will comments on fields of these structures.

>[...]
>> +/* The main function to allocate external buffers */
>> +static struct skb_ext_page *page_ctor(struct mpassthru_port *port,
>> +		struct sk_buff *skb, int npages)
>> +{
>> +	int i;
>> +	unsigned long flags;
>> +	struct page_ctor *ctor;
>> +	struct page_info *info = NULL;
>> +
>> +	ctor = container_of(port, struct page_ctor, port);
>> +
>> +	spin_lock_irqsave(&ctor->read_lock, flags);
>> +	if (!list_empty(&ctor->readq)) {
>> +		info = list_first_entry(&ctor->readq, struct page_info, list);
>> +		list_del(&info->list);
>> +		ctor->rq_len--;
>> +	}
>> +	spin_unlock_irqrestore(&ctor->read_lock, flags);
>> +	if (!info)
>> +		return NULL;
>> +
>> +	for (i = 0; i < info->pnum; i++)
>> +		get_page(info->pages[i]);
>> +	info->skb = skb;
>> +	return &info->ext_page;
>> +}
>
>Why isn't the npages parameter used?
>

Sorry, somehow forgot that, currently it only allocates one page a time,
we want to use npages to see if we break the limit.

>[...]
>> +static void relinquish_resource(struct page_ctor *ctor)
>> +{
>> +	if (!(ctor->dev->flags & IFF_UP) &&
>> +			!(ctor->wq_len + ctor->rq_len))
>> +		printk(KERN_INFO "relinquish_resource\n");
>> +}
>
>Looks like something's missing here.
>

This function is for debug, and so on the rq_len stuff, I'll remove them later.

>> +static void mp_ki_dtor(struct kiocb *iocb)
>> +{
>> +	struct page_info *info = (struct page_info *)(iocb->private);
>> +	int i;
>> +
>> +	if (info->flags == INFO_READ) {
>> +		for (i = 0; i < info->pnum; i++) {
>> +			if (info->pages[i]) {
>> +				set_page_dirty_lock(info->pages[i]);
>> +				put_page(info->pages[i]);
>> +			}
>> +		}
>> +		mp_hash_delete(info->ctor, info);
>> +		if (info->skb) {
>> +			info->skb->destructor = NULL;
>> +			kfree_skb(info->skb);
>> +		}
>> +		info->ctor->rq_len--;
>
>Doesn't rq_len represent the number of buffers queued between the guest
>and the driver?  It is already decremented in page_ctor() so it seems
>like it gets decremented twice for each buffer.  Also don't you need to
>hold the read_lock when updating rq_len?
>
>> +	} else
>> +		info->ctor->wq_len--;
>
>Maybe you should define rq_len and wq_len both as atomic_t.
>
>[...]
>> +static void __mp_detach(struct mp_struct *mp)
>> +{
>> +	mp->mfile = NULL;
>> +
>> +	mp_dev_change_flags(mp->dev, mp->dev->flags & ~IFF_UP);
>> +	page_ctor_detach(mp);
>> +	mp_dev_change_flags(mp->dev, mp->dev->flags | IFF_UP);
>
>This is racy; you should hold rtnl_lock over all these changes.
>
That's true. Though mp_dev_change_flags() did use rtnl_lock.
But page_ctor_detach() change mp_port from dev structure too.....

>[...]
>> +typedef u32 key_mp_t;
>> +static inline key_mp_t mp_hash(struct page *page, int buckets)
>> +{
>> +	key_mp_t k;
>> +
>> +	k = ((((unsigned long)page << 32UL) >> 32UL) / 0x38) % buckets ;
>> +	return k;
>> +}
>
>This is never going to work on a 32-bit machine, and what is the purpose
>of the magic number 0x38?
>

The 0x38 is the size of struct page, I should use sizeof(struct page).
Let me try to fit it on 32-bit machine.

>Try using hash_ptr() from <linux/hash.h>.
>

I tried that before, but performance is much worse than what I did,
nearly 1G bandwidth less.

>> +static struct page_info *mp_hash_delete(struct page_ctor *ctor,
>> +					struct page_info *info)
>> +{
>> +	key_mp_t key = mp_hash(info->pages[0], HASH_BUCKETS);
>> +	struct page_info *tmp = NULL;
>> +	int i;
>> +
>> +	tmp = ctor->hash_table[key];
>> +	while (tmp) {
>> +		if (tmp == info) {
>> +			if (!tmp->prev) {
>> +				ctor->hash_table[key] = tmp->next;
>> +				if (tmp->next)
>> +					tmp->next->prev = NULL;
>> +			} else {
>> +				tmp->prev->next = tmp->next;
>> +				if (tmp->next)
>> +					tmp->next->prev = tmp->prev;
>> +			}
>> +			return tmp;
>> +		}
>> +		tmp = tmp->next;
>> +	}
>> +	return tmp;
>> +}
>> +
>> +static struct page_info *mp_hash_lookup(struct page_ctor *ctor,
>> +					struct page *page)
>> +{
>> +	key_mp_t key = mp_hash(page, HASH_BUCKETS);
>> +	struct page_info *tmp = NULL;
>> +
>> +	int i;
>> +	tmp = ctor->hash_table[key];
>> +	while (tmp) {
>> +		for (i = 0; i < tmp->pnum; i++) {
>> +			if (tmp->pages[i] == page)
>> +				return tmp;
>> +		}
>> +		tmp = tmp->next;
>> +	}
>> +	return tmp;
>> +}
>
>How are thse serialised?
>
This hash function is only used for rx side. And both insert and delete
are called in mp_recvmsg, which is locked by vq->mutex.

>> +/* The main function to transform the guest user space address
>> + * to host kernel address via get_user_pages(). Thus the hardware
>> + * can do DMA directly to the external buffer address.
>> + */
>> +static struct page_info *alloc_page_info(struct page_ctor *ctor,
>> +		struct kiocb *iocb, struct iovec *iov,
>> +		int count, struct frag *frags,
>> +		int npages, int total)
>> +{
>> +	int rc;
>> +	int i, j, n = 0;
>> +	int len;
>> +	unsigned long base, lock_limit;
>> +	struct page_info *info = NULL;
>> +
>> +	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
>> +	lock_limit >>= PAGE_SHIFT;
>> +
>> +	if (ctor->lock_pages + count > lock_limit && npages) {
>> +		printk(KERN_INFO "exceed the locked memory rlimit.");
>> +		return NULL;
>> +	}
>
>What if the process is locking pages with mlock() as well?  Doesn't this
>allow it to lock twice as many pages as it should be able to?
>
>> +	info = kmem_cache_alloc(ext_page_info_cache, GFP_KERNEL);
>> +
>> +	if (!info)
>> +		return NULL;
>> +	info->skb = NULL;
>> +	info->next = info->prev = NULL;
>> +
>> +	for (i = j = 0; i < count; i++) {
>> +		base = (unsigned long)iov[i].iov_base;
>> +		len = iov[i].iov_len;
>> +
>> +		if (!len)
>> +			continue;
>> +		n = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
>> +
>> +		rc = get_user_pages_fast(base, n, npages ? 1 : 0,
>> +				&info->pages[j]);
>> +		if (rc != n)
>> +			goto failed;
>> +
>> +		while (n--) {
>> +			frags[j].offset = base & ~PAGE_MASK;
>> +			frags[j].size = min_t(int, len,
>> +					PAGE_SIZE - frags[j].offset);
>> +			len -= frags[j].size;
>> +			base += frags[j].size;
>> +			j++;
>> +		}
>> +	}
>> +
>> +#ifdef CONFIG_HIGHMEM
>> +	if (npages && !(dev->features & NETIF_F_HIGHDMA)) {
>> +		for (i = 0; i < j; i++) {
>> +			if (PageHighMem(info->pages[i]))
>> +				goto failed;
>> +		}
>> +	}
>> +#endif
>
>Shouldn't you try to allocate lowmem pages explicitly, rather than
>failing at this point?
>
>[...]
>> +static int mp_recvmsg(struct kiocb *iocb, struct socket *sock,
>> +		struct msghdr *m, size_t total_len,
>> +		int flags)
>> +{
>> +	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
>> +	struct page_ctor *ctor;
>> +	struct iovec *iov = m->msg_iov;
>> +	int count = m->msg_iovlen;
>> +	int npages, payload;
>> +	struct page_info *info;
>> +	struct frag frags[MAX_SKB_FRAGS];
>> +	unsigned long base;
>> +	int i, len;
>> +	unsigned long flag;
>> +
>> +	if (!(flags & MSG_DONTWAIT))
>> +		return -EINVAL;
>> +
>> +	ctor = mp->ctor;
>> +	if (!ctor)
>> +		return -EINVAL;
>> +
>> +	/* Error detections in case invalid external buffer */
>> +	if (count > 2 && iov[1].iov_len < ctor->port.hdr_len &&
>> +			mp->dev->features & NETIF_F_SG) {
>> +		return -EINVAL;
>> +	}
>> +
>> +	npages = ctor->port.npages;
>> +	payload = ctor->port.data_len;
>> +
>> +	/* If KVM guest virtio-net FE driver use SG feature */
>> +	if (count > 2) {
>> +		for (i = 2; i < count; i++) {
>> +			base = (unsigned long)iov[i].iov_base & ~PAGE_MASK;
>> +			len = iov[i].iov_len;
>> +			if (npages == 1)
>> +				len = min_t(int, len, PAGE_SIZE - base);
>> +			else if (base)
>> +				break;
>> +			payload -= len;
>> +			if (payload <= 0)
>> +				goto proceed;
>> +			if (npages == 1 || (len & ~PAGE_MASK))
>> +				break;
>> +		}
>> +	}
>> +
>> +	if ((((unsigned long)iov[1].iov_base & ~PAGE_MASK)
>> +				- NET_SKB_PAD - NET_IP_ALIGN) >= 0)
>> +		goto proceed;
>> +
>> +	return -EINVAL;
>> +
>> +proceed:
>> +	/* skip the virtnet head */
>> +	if (count > 1) {
>> +		iov++;
>> +		count--;
>> +	}
>> +
>> +	if (!ctor->lock_pages || !ctor->rq_len) {
>> +		set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
>> +				iocb->ki_user_data * 4096 * 2,
>> +				iocb->ki_user_data * 4096 * 2);
>> +	}
>> +
>> +	/* Translate address to kernel */
>> +	info = alloc_page_info(ctor, iocb, iov, count, frags, npages, 0);
>> +	if (!info)
>> +		return -ENOMEM;
>
>I'm not convinced that the checks above this ensure that there will be
><= MAX_SKB_FRAGS fragments.
>
It doesn't need to check about that, because for SG feature guest virtio-net
driver never submit multiple buffers for one skb. The drivers never knows
which frags belongs to which skb. The fragements are collected by multiple
buffers with numbers which a receiving skb is exactly needed.

>[...]
>> +static int mp_chr_open(struct inode *inode, struct file * file)
>> +{
>> +	struct mp_file *mfile;
>> +	cycle_kernel_lock();
>
>Seriously?
>
>[...]
>> +static ssize_t mp_chr_aio_write(struct kiocb *iocb, const struct iovec *iov,
>> +				unsigned long count, loff_t pos)
>> +{
>> +	struct file *file = iocb->ki_filp;
>> +	struct mp_struct *mp = mp_get(file->private_data);
>> +	struct sock *sk = mp->socket.sk;
>> +	struct sk_buff *skb;
>> +	int len, err;
>> +	ssize_t result = 0;
>> +
>> +	if (!mp)
>> +		return -EBADFD;
>> +
>> +	/* currently, async is not supported.
>> +	 * but we may support real async aio from user application,
>> +	 * maybe qemu virtio-net backend.
>> +	 */
>> +	if (!is_sync_kiocb(iocb))
>> +		return -EFAULT;
>> +
>> +	len = iov_length(iov, count);
>> +
>> +	if (unlikely(len) < ETH_HLEN)
>> +		return -EINVAL;
>
>The first close-paren is in the wrong place.
>

Thanks.
It should be : if(unlikely(len < ETH_HLEN)).

>> +	skb = sock_alloc_send_skb(sk, len + NET_IP_ALIGN,
>> +				  file->f_flags & O_NONBLOCK, &err);
>> +
>> +	if (!skb)
>> +		return -EFAULT;
>
>Why EFAULT?

Then -ENOMEM maybe much better.

>
>> +	skb_reserve(skb, NET_IP_ALIGN);
>> +	skb_put(skb, len);
>> +
>> +	if (skb_copy_datagram_from_iovec(skb, 0, iov, 0, len)) {
>> +		kfree_skb(skb);
>> +		return -EAGAIN;
>> +	}
>> +
>> +	skb->protocol = eth_type_trans(skb, mp->dev);
>
>Why are you calling eth_type_trans() on transmit?
>
>[...]
>> +static int mp_device_event(struct notifier_block *unused,
>> +		unsigned long event, void *ptr)
>> +{
>> +	struct net_device *dev = ptr;
>> +	struct mpassthru_port *port;
>> +	struct mp_struct *mp = NULL;
>> +	struct socket *sock = NULL;
>> +	struct sock *sk;
>> +
>> +	port = dev->mp_port;
>> +	if (port == NULL)
>> +		return NOTIFY_DONE;
>> +
>> +	switch (event) {
>> +	case NETDEV_UNREGISTER:
>> +		sock = dev->mp_port->sock;
>> +		mp = container_of(sock->sk, struct mp_sock, sk)->mp;
>> +		do_unbind(mp->mfile);
>[...]
>
>This can deadlock - netdev notifiers are called under the RTNL lock and
>do_unbind() acquires the mp_mutex, whereas in other places they are
>acquired in the opposite order.
>

Let me think how to avoid this.

>Ben.
>
>--
>Ben Hutchings, Senior Software Engineer, Solarflare Communications
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
