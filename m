From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Mon, 10 Aug 2009 21:51:18 +0200
Message-ID: <200908102151.18529.arnd@arndb.de>
References: <cover.1249930169.git.mst@redhat.com> <20090810185340.GC13924@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: virtualization@lists.linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752668AbZHJTv0@vger.kernel.org>
In-Reply-To: <20090810185340.GC13924@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 10 August 2009, Michael S. Tsirkin wrote:
> What it is: vhost net is a character device that can be used to reduce
> the number of system calls involved in virtio networking.
> Existing virtio net code is used in the guest without modification.

Very nice, I loved reading it. It's getting rather late in my time
zone, so this comments only on the network driver. I'll go through
the rest tomorrow.

> @@ -293,6 +293,7 @@ static int __devinit virtblk_probe(struct virtio_device *vdev)
>  		err = PTR_ERR(vblk->vq);
>  		goto out_free_vblk;
>  	}
> +	printk(KERN_ERR "vblk->vq = %p\n", vblk->vq);
>  
>  	vblk->pool = mempool_create_kmalloc_pool(1,sizeof(struct virtblk_req));
>  	if (!vblk->pool) {
> @@ -383,6 +384,8 @@ static int __devinit virtblk_probe(struct virtio_device *vdev)
>  	if (!err)
>  		blk_queue_logical_block_size(vblk->disk->queue, blk_size);
>  
> +	printk(KERN_ERR "virtio_config_val returned %d\n", err);
> +
>  	add_disk(vblk->disk);
>  	return 0;

I guess you meant to remove these before submitting.

> +static void handle_tx_kick(struct work_struct *work);
> +static void handle_rx_kick(struct work_struct *work);
> +static void handle_tx_net(struct work_struct *work);
> +static void handle_rx_net(struct work_struct *work);

[style] I think the code gets more readable if you reorder it
so that you don't need forward declarations for static functions.

> +static long vhost_net_reset_owner(struct vhost_net *n)
> +{
> +	struct socket *sock = NULL;
> +	long r;
> +	mutex_lock(&n->dev.mutex);
> +	r = vhost_dev_check_owner(&n->dev);
> +	if (r)
> +		goto done;
> +	sock = vhost_net_stop(n);
> +	r = vhost_dev_reset_owner(&n->dev);
> +done:
> +	mutex_unlock(&n->dev.mutex);
> +	if (sock)
> +		fput(sock->file);
> +	return r;
> +}

what is the difference between vhost_net_reset_owner(n)
and vhost_net_set_socket(n, -1)?

> +
> +static struct file_operations vhost_net_fops = {
> +	.owner          = THIS_MODULE,
> +	.release        = vhost_net_release,
> +	.unlocked_ioctl = vhost_net_ioctl,
> +	.open           = vhost_net_open,
> +};

This is missing a compat_ioctl pointer. It should simply be

static long vhost_net_compat_ioctl(struct file *f,
			unsigned int ioctl, unsigned long arg)
{
	return f, ioctl, (unsigned long)compat_ptr(arg);
}

> +/* Bits from fs/aio.c. TODO: export and use from there? */
> +/*
> + * use_mm
> + *	Makes the calling kernel thread take on the specified
> + *	mm context.
> + *	Called by the retry thread execute retries within the
> + *	iocb issuer's mm context, so that copy_from/to_user
> + *	operations work seamlessly for aio.
> + *	(Note: this routine is intended to be called only
> + *	from a kernel thread context)
> + */
> +static void use_mm(struct mm_struct *mm)
> +{
> +	struct mm_struct *active_mm;
> +	struct task_struct *tsk = current;
> +
> +	task_lock(tsk);
> +	active_mm = tsk->active_mm;
> +	atomic_inc(&mm->mm_count);
> +	tsk->mm = mm;
> +	tsk->active_mm = mm;
> +	switch_mm(active_mm, mm, tsk);
> +	task_unlock(tsk);
> +
> +	mmdrop(active_mm);
> +}

Why do you need a kernel thread here? If the data transfer functions
all get called from a guest intercept, shouldn't you already be
in the right mm?

> +static void handle_tx(struct vhost_net *net)
> +{
> +	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
> +	unsigned head, out, in;
> +	struct msghdr msg = {
> +		.msg_name = NULL,
> +		.msg_namelen = 0,
> +		.msg_control = NULL,
> +		.msg_controllen = 0,
> +		.msg_iov = (struct iovec *)vq->iov + 1,
> +		.msg_flags = MSG_DONTWAIT,
> +	};
> +	size_t len;
> +	int err;
> +	struct socket *sock = rcu_dereference(net->sock);
> +	if (!sock || !sock_writeable(sock->sk))
> +		return;
> +
> +	use_mm(net->dev.mm);
> +	mutex_lock(&vq->mutex);
> +	for (;;) {
> +		head = vhost_get_vq_desc(&net->dev, vq, vq->iov, &out, &in);
> +		if (head == vq->num)
> +			break;
> +		if (out <= 1 || in) {
> +			vq_err(vq, "Unexpected descriptor format for TX: "
> +			       "out %d, int %d\n", out, in);
> +			break;
> +		}
> +		/* Sanity check */
> +		if (vq->iov->iov_len != sizeof(struct virtio_net_hdr)) {
> +			vq_err(vq, "Unexpected header len for TX: "
> +			       "%ld expected %zd\n", vq->iov->iov_len,
> +			       sizeof(struct virtio_net_hdr));
> +			break;
> +		}
> +		/* Skip header. TODO: support TSO. */
> +		msg.msg_iovlen = out - 1;
> +		len = iov_length(vq->iov + 1, out - 1);
> +		/* TODO: Check specific error and bomb out unless ENOBUFS? */
> +		err = sock->ops->sendmsg(NULL, sock, &msg, len);
> +		if (err < 0) {
> +			vhost_discard_vq_desc(vq);
> +			break;
> +		}
> +		if (err != len)
> +			pr_err("Truncated TX packet: "
> +			       " len %d != %zd\n", err, len);
> +		vhost_add_used_and_trigger(vq, head,
> +				     len + sizeof(struct virtio_net_hdr));
> +	}
> +
> +	mutex_unlock(&vq->mutex);
> +	unuse_mm(net->dev.mm);
> +}

I guess that this is where one could plug into macvlan directly, using
sock_alloc_send_skb/memcpy_fromiovec/dev_queue_xmit directly,
instead of filling a msghdr for each, if we want to combine this
with the work I did on that.

	Arnd <><
