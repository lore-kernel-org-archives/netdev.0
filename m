From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv5] add mergeable receiver buffers support to vhost
Date: Sat, 24 Apr 2010 22:07:54 +0300
Message-ID: <20100424190753.GA968@redhat.com>
References: <1272053205.3114.3.camel@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1272053205.3114.3.camel@lab1.dls>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 23, 2010 at 01:06:45PM -0700, David L Stevens wrote:
> This patch adds mergeable receive buffers support to vhost.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

It seems the logging is wrong. Did you test live migration? Please do.
I think reason for the bug could be you did some cut and paste
from code that was there before 86e9424d7252bae5ad1c17b4b8088193e6b27cbe.
So I put a suggestion on reducing this duplication a bit, below.

Also, I think this patch adds sparse errors: some __user annotations
seem missing.  Could you please make your patch apply
on top of patch 'vhost: fix sparse warnings' from
Christoph Hellwig, and then make sure your patch
does not add new sparse errors?

I also wanted to make some coding style tweaks, to make
patch match the style of the rest of the code, I could do
them myself but since there's these issues, and we need another
round, I put them in comments in mail below.

Thanks!

> diff -ruNp net-next-v0/drivers/vhost/net.c net-next-v5/drivers/vhost/net.c
> --- net-next-v0/drivers/vhost/net.c	2010-04-22 11:31:57.000000000 -0700
> +++ net-next-v5/drivers/vhost/net.c	2010-04-22 12:41:17.000000000 -0700
> @@ -109,7 +109,7 @@ static void handle_tx(struct vhost_net *
>  	};
>  	size_t len, total_len = 0;
>  	int err, wmem;
> -	size_t hdr_size;
> +	size_t vhost_hlen;
>  	struct socket *sock = rcu_dereference(vq->private_data);
>  	if (!sock)
>  		return;
> @@ -128,13 +128,13 @@ static void handle_tx(struct vhost_net *
>  
>  	if (wmem < sock->sk->sk_sndbuf / 2)
>  		tx_poll_stop(net);
> -	hdr_size = vq->hdr_size;
> +	vhost_hlen = vq->vhost_hlen;
>  
>  	for (;;) {
> -		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> -					 ARRAY_SIZE(vq->iov),
> -					 &out, &in,
> -					 NULL, NULL);
> +		head = vhost_get_desc(&net->dev, vq, vq->iov,
> +				      ARRAY_SIZE(vq->iov),
> +				      &out, &in,
> +				      NULL, NULL);
>  		/* Nothing new?  Wait for eventfd to tell us they refilled. */
>  		if (head == vq->num) {
>  			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> @@ -155,20 +155,20 @@ static void handle_tx(struct vhost_net *
>  			break;
>  		}
>  		/* Skip header. TODO: support TSO. */
> -		s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
> +		s = move_iovec_hdr(vq->iov, vq->hdr, vhost_hlen, out);
>  		msg.msg_iovlen = out;
>  		len = iov_length(vq->iov, out);
>  		/* Sanity check */
>  		if (!len) {
>  			vq_err(vq, "Unexpected header len for TX: "
>  			       "%zd expected %zd\n",
> -			       iov_length(vq->hdr, s), hdr_size);
> +			       iov_length(vq->hdr, s), vhost_hlen);
>  			break;
>  		}
>  		/* TODO: Check specific error and bomb out unless ENOBUFS? */
>  		err = sock->ops->sendmsg(NULL, sock, &msg, len);
>  		if (unlikely(err < 0)) {
> -			vhost_discard_vq_desc(vq);
> +			vhost_discard_desc(vq, 1);
>  			tx_poll_start(net, sock);
>  			break;
>  		}
> @@ -187,12 +187,25 @@ static void handle_tx(struct vhost_net *
>  	unuse_mm(net->dev.mm);
>  }
>  
> +static int vhost_head_len(struct vhost_virtqueue *vq, struct sock *sk)
> +{
> +	struct sk_buff *head;
> +	int len = 0;
> +
> +	lock_sock(sk);
> +	head = skb_peek(&sk->sk_receive_queue);
> +	if (head)
> +		len = head->len + vq->sock_hlen;
> +	release_sock(sk);
> +	return len;
> +}
> +
>  /* Expects to be always run from workqueue - which acts as
>   * read-size critical section for our kind of RCU. */
>  static void handle_rx(struct vhost_net *net)
>  {
>  	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
> -	unsigned head, out, in, log, s;
> +	unsigned in, log, s;
>  	struct vhost_log *vq_log;
>  	struct msghdr msg = {
>  		.msg_name = NULL,
> @@ -203,14 +216,14 @@ static void handle_rx(struct vhost_net *
>  		.msg_flags = MSG_DONTWAIT,
>  	};
>  
> -	struct virtio_net_hdr hdr = {
> -		.flags = 0,
> -		.gso_type = VIRTIO_NET_HDR_GSO_NONE
> +	struct virtio_net_hdr_mrg_rxbuf hdr = {
> +		.hdr.flags = 0,
> +		.hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
>  	};
>  
>  	size_t len, total_len = 0;
> -	int err;
> -	size_t hdr_size;
> +	int err, headcount, datalen;
> +	size_t vhost_hlen;
>  	struct socket *sock = rcu_dereference(vq->private_data);
>  	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
>  		return;
> @@ -218,18 +231,18 @@ static void handle_rx(struct vhost_net *
>  	use_mm(net->dev.mm);
>  	mutex_lock(&vq->mutex);
>  	vhost_disable_notify(vq);
> -	hdr_size = vq->hdr_size;
> +	vhost_hlen = vq->vhost_hlen;
>  
>  	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
>  		vq->log : NULL;
>  
> -	for (;;) {
> -		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> -					 ARRAY_SIZE(vq->iov),
> -					 &out, &in,
> -					 vq_log, &log);
> +	while ((datalen = vhost_head_len(vq, sock->sk))) {
> +		headcount = vhost_get_desc_n(vq, vq->heads, datalen+vhost_hlen,

checkpatch does not catch this but please add spaces around +.

> +					     &in, vq_log, &log);
> +		if (headcount < 0)
> +			break;
>  		/* OK, now we need to know about added descriptors. */
> -		if (head == vq->num) {
> +		if (!headcount) {
>  			if (unlikely(vhost_enable_notify(vq))) {
>  				/* They have slipped one in as we were
>  				 * doing that: check again. */
> @@ -241,46 +254,54 @@ static void handle_rx(struct vhost_net *
>  			break;
>  		}
>  		/* We don't need to be notified again. */
> -		if (out) {
> -			vq_err(vq, "Unexpected descriptor format for RX: "
> -			       "out %d, int %d\n",
> -			       out, in);
> -			break;
> -		}
> -		/* Skip header. TODO: support TSO/mergeable rx buffers. */
> -		s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
> +		/* Skip header. TODO: support TSO. */
> +		s = move_iovec_hdr(vq->iov, vq->hdr, vhost_hlen, in);
>  		msg.msg_iovlen = in;
>  		len = iov_length(vq->iov, in);
>  		/* Sanity check */
>  		if (!len) {
>  			vq_err(vq, "Unexpected header len for RX: "
>  			       "%zd expected %zd\n",
> -			       iov_length(vq->hdr, s), hdr_size);
> +			       iov_length(vq->hdr, s), vhost_hlen);
>  			break;
>  		}
>  		err = sock->ops->recvmsg(NULL, sock, &msg,
>  					 len, MSG_DONTWAIT | MSG_TRUNC);
>  		/* TODO: Check specific error and bomb out unless EAGAIN? */
>  		if (err < 0) {
> -			vhost_discard_vq_desc(vq);
> +			vhost_discard_desc(vq, headcount);
>  			break;
>  		}
> -		/* TODO: Should check and handle checksum. */
> -		if (err > len) {
> -			pr_err("Discarded truncated rx packet: "
> -			       " len %d > %zd\n", err, len);
> -			vhost_discard_vq_desc(vq);
> +		if (err != datalen) {
> +			pr_err("Discarded rx packet: "
> +			       " len %d, expected %zd\n", err, datalen);
> +			vhost_discard_desc(vq, headcount);
>  			continue;
>  		}
>  		len = err;
> -		err = memcpy_toiovec(vq->hdr, (unsigned char *)&hdr, hdr_size);
> +		err = memcpy_toiovec(vq->hdr, (unsigned char *)&hdr,
> +				     vhost_hlen);
>  		if (err) {
>  			vq_err(vq, "Unable to write vnet_hdr at addr %p: %d\n",
>  			       vq->iov->iov_base, err);
>  			break;
>  		}
> -		len += hdr_size;
> -		vhost_add_used_and_signal(&net->dev, vq, head, len);
> +		/* TODO: Should check and handle checksum. */
> +		if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF)) {
> +			struct virtio_net_hdr_mrg_rxbuf hdr;
> +			struct iovec *iov = vhost_hlen ? vq->hdr : vq->iov;
> +
> +			if (memcpy_toiovecend(iov, (unsigned char *)&headcount,
> +				      offsetof(typeof(hdr), num_buffers),
> +				      sizeof(hdr.num_buffers))) {
> +				vq_err(vq, "Failed num_buffers write");
> +				vhost_discard_desc(vq, headcount);
> +				break;
> +			}
> +		}
> +		len += vhost_hlen;
> +		vhost_add_used_and_signal_n(&net->dev, vq, vq->heads,
> +					    headcount);
>  		if (unlikely(vq_log))
>  			vhost_log_write(vq, vq_log, log, len);
>  		total_len += len;
> @@ -561,9 +582,24 @@ done:
>  
>  static int vhost_net_set_features(struct vhost_net *n, u64 features)
>  {
> -	size_t hdr_size = features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
> -		sizeof(struct virtio_net_hdr) : 0;
> +	size_t vhost_hlen;
> +	size_t sock_hlen;
>  	int i;
> +
> +	if (features & (1 << VHOST_NET_F_VIRTIO_NET_HDR)) {
> +		/* vhost provides vnet_hdr */
> +		vhost_hlen = sizeof(struct virtio_net_hdr);
> +		if (features & (1 << VIRTIO_NET_F_MRG_RXBUF))
> +			vhost_hlen = sizeof(struct virtio_net_hdr_mrg_rxbuf);
> +		sock_hlen = 0;
> +	} else {
> +		/* socket provides vnet_hdr */
> +		vhost_hlen = 0;
> +		if (features & (1 << VIRTIO_NET_F_MRG_RXBUF))
> +			sock_hlen = sizeof(struct virtio_net_hdr_mrg_rxbuf);
> +		else
> +			sock_hlen = sizeof(struct virtio_net_hdr);
> +	}
>  	mutex_lock(&n->dev.mutex);
>  	if ((features & (1 << VHOST_F_LOG_ALL)) &&
>  	    !vhost_log_access_ok(&n->dev)) {
> @@ -574,7 +610,8 @@ static int vhost_net_set_features(struct
>  	smp_wmb();
>  	for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
>  		mutex_lock(&n->vqs[i].mutex);
> -		n->vqs[i].hdr_size = hdr_size;
> +		n->vqs[i].vhost_hlen = vhost_hlen;
> +		n->vqs[i].sock_hlen = sock_hlen;
>  		mutex_unlock(&n->vqs[i].mutex);
>  	}
>  	vhost_net_flush(n);
> diff -ruNp net-next-v0/drivers/vhost/vhost.c net-next-v5/drivers/vhost/vhost.c
> --- net-next-v0/drivers/vhost/vhost.c	2010-04-22 11:31:57.000000000 -0700
> +++ net-next-v5/drivers/vhost/vhost.c	2010-04-22 12:19:59.000000000 -0700
> @@ -114,7 +114,8 @@ static void vhost_vq_reset(struct vhost_
>  	vq->used_flags = 0;
>  	vq->log_used = false;
>  	vq->log_addr = -1ull;
> -	vq->hdr_size = 0;
> +	vq->vhost_hlen = 0;
> +	vq->sock_hlen = 0;
>  	vq->private_data = NULL;
>  	vq->log_base = NULL;
>  	vq->error_ctx = NULL;
> @@ -861,6 +862,53 @@ static unsigned get_indirect(struct vhos
>  	return 0;
>  }
>  
> +/* This is a multi-buffer version of vhost_get_vq_desc
> + * @vq		- the relevant virtqueue
> + * datalen	- data length we'll be reading
> + * @iovcount	- returned count of io vectors we fill
> + * @log		- vhost log
> + * @log_num	- log offset
> + *	returns number of buffer heads allocated, negative on error
> + */
> +int vhost_get_desc_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
> +		     int datalen, int *iovcount, struct vhost_log *log,
> +		     unsigned int *log_num)
> +{
> +	int out, in;
> +	int seg = 0;		/* iov index */

In rest of code, I always put comments above the commented code,
not to the right of it.

> +	int hc = 0;		/* head count */

Maybe just call the variable head_count? That'd make the
comment unnecessary.

> +	int rv;

rest of code uses r or ret for such variables.

> +
> +	while (datalen > 0) {
> +		if (hc >= VHOST_NET_MAX_SG) {
> +			rv = -ENOBUFS;
> +			goto err;
> +		}
> +		heads[hc].id = vhost_get_desc(vq->dev, vq, vq->iov+seg,
> +					      ARRAY_SIZE(vq->iov)-seg, &out,

same here, spaces around + and -

> +					      &in, log, log_num);
> +		if (heads[hc].id == vq->num) {
> +			rv = 0;
> +			goto err;
> +		}
> +		if (out || in <= 0) {
> +			vq_err(vq, "unexpected descriptor format for RX: "
> +				"out %d, in %d\n", out, in);
> +			rv = -EINVAL;
> +			goto err;
> +		}
> +		heads[hc].len = iov_length(vq->iov+seg, in);

and here

> +		datalen -= heads[hc].len;
> +		hc++;

I use ++x in the rest of the code wher I don't care for
the old value.

> +		seg += in;
> +	}
> +	*iovcount = seg;
> +	return hc;
> +err:
> +	vhost_discard_desc(vq, hc);
> +	return rv;
> +}
> +
>  /* This looks in the virtqueue and for the first available buffer, and converts
>   * it to an iovec for convenient access.  Since descriptors consist of some
>   * number of output then some number of input descriptors, it's actually two
> @@ -868,7 +916,7 @@ static unsigned get_indirect(struct vhos
>   *
>   * This function returns the descriptor number found, or vq->num (which
>   * is never a valid descriptor number) if none was found. */
> -unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
> +unsigned vhost_get_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
>  			   struct iovec iov[], unsigned int iov_size,
>  			   unsigned int *out_num, unsigned int *in_num,
>  			   struct vhost_log *log, unsigned int *log_num)
> @@ -986,9 +1034,9 @@ unsigned vhost_get_vq_desc(struct vhost_
>  }
>  
>  /* Reverse the effect of vhost_get_vq_desc. Useful for error handling. */
> -void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
> +void vhost_discard_desc(struct vhost_virtqueue *vq, int n)
>  {
> -	vq->last_avail_idx--;
> +	vq->last_avail_idx -= n;
>  }
>  
>  /* After we've used one of their buffers, we tell them about it.  We'll then
> @@ -1017,6 +1065,54 @@ int vhost_add_used(struct vhost_virtqueu
>  	if (unlikely(vq->log_used)) {
>  		/* Make sure data is seen before log. */
>  		smp_wmb();
> +		log_write(vq->log_base, vq->log_addr + sizeof *vq->used->ring *
> +			  (vq->last_used_idx % vq->num),
> +			  sizeof *vq->used->ring);
> +		log_write(vq->log_base, vq->log_addr, sizeof *vq->used->ring);
> +		if (vq->log_ctx)
> +			eventfd_signal(vq->log_ctx, 1);
> +	}
> +	vq->last_used_idx++;
> +	return 0;

The above looks like a copy from an old version of vhost.


> +}
> +
> +/* After we've used one of their buffers, we tell them about it.  We'll then
> + * want to notify the guest, using eventfd. */
> +int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
> +		   int count)

please align int at least to the right of (.

> +{
> +	struct vring_used_elem *used;
> +	int start, n;
> +
> +	if (count <= 0)
> +		return -EINVAL;

Is the above necessary?
Just make count unsigned for clarity?

> +
> +	start = vq->last_used_idx % vq->num;
> +	if (vq->num - start < count)
> +		n = vq->num - start;
> +	else
> +		n = count;

I'd say use min, or reorder code as I suggest below
to only have a single if.

> +	used = vq->used->ring + start;
> +	if (copy_to_user(used, heads, sizeof(heads[0])*n)) {

Pls put spaces around *
Also I'd prefer sizeof *used here instead of sizeof(heads[0]),
it's shorter. My style is also to put () after sizeof only
if the argument is a type, and order the expression
to make precedence not matter. So we'd end up with:

	n * sizeof *used.

> +		vq_err(vq, "Failed to write used");
> +		return -EFAULT;
> +	}
> +	if (n < count) {	/* wrapped the ring */

In rest of code, I always put comments above the commented code,
not to the right of it.

The only case we can have n < count is wrap-around,
so I find this a roundabout way to code this up, and we
end up with test for same condition, which makes the
code fragile (ignoring performance impact).
Also note need for extra logging as explained below.

Maybe it's cleanest to have static __vhost_add_used_n which assumes
no wrap-around, and then just call:

vhost_add_used_n()
	if (unlikely(n < count)) {
		if (r = __vhost_add_used_n())
			return r;
		heads += n;
		count -= n;
	}
	return __vhost_add_used_n()

this would do an extra write into used index,
but this is almost freem 


> +		used = vq->used->ring;
> +		if (copy_to_user(used, heads+n, sizeof(heads[0])*(count-n))) {

spaces around + and *

> +			vq_err(vq, "Failed to write used");
> +			return -EFAULT;
> +		}
> +	}
> +	/* Make sure buffer is written before we update index. */
> +	smp_wmb();
> +	if (put_user(vq->last_used_idx+count, &vq->used->idx)) {

and here

> +		vq_err(vq, "Failed to increment used idx");
> +		return -EFAULT;
> +	}
> +	if (unlikely(vq->log_used)) {
> +		/* Make sure data is seen before log. */
> +		smp_wmb();
>  		/* Log used ring entry write. */
>  		log_write(vq->log_base,
>  			  vq->log_addr +

this uses 'used' pointer, but I think it's wrong in case
of wrap-around. I think we'll need extra logging for
wrap-around. That would be 3 copies of identical code:
maybe add a function?

static void vhost_log_used(struct vhost_virtqueue *vq,
			   struct vring_used_elem __user *used)
{
	/* Make sure data is seen before log. */
	smp_wmb();
	/* Log used ring entry write. */
	log_write(vq->log_base,
		  vq->log_addr +
		   ((void __user *)used - (void __user *)vq->used),
		  sizeof *used);
	/* Log used index update. */
	log_write(vq->log_base,
		  vq->log_addr + offsetof(struct vring_used, idx),
		  sizeof vq->used->idx);
	if (vq->log_ctx)
		eventfd_signal(vq->log_ctx, 1);
}


> @@ -1029,7 +1125,7 @@ int vhost_add_used(struct vhost_virtqueu
>  		if (vq->log_ctx)
>  			eventfd_signal(vq->log_ctx, 1);
>  	}
> -	vq->last_used_idx++;
> +	vq->last_used_idx += count;
>  	return 0;
>  }
>  
> @@ -1062,6 +1158,15 @@ void vhost_add_used_and_signal(struct vh
>  	vhost_signal(dev, vq);
>  }
>  
> +/* multi-buffer version of vhost_add_used_and_signal */
> +void vhost_add_used_and_signal_n(struct vhost_dev *dev,
> +				 struct vhost_virtqueue *vq,
> +				 struct vring_used_elem *heads, int count)
> +{
> +	vhost_add_used_n(vq, heads, count);
> +	vhost_signal(dev, vq);
> +}
> +
>  /* OK, now we need to know about added descriptors. */
>  bool vhost_enable_notify(struct vhost_virtqueue *vq)
>  {
> @@ -1086,7 +1191,7 @@ bool vhost_enable_notify(struct vhost_vi
>  		return false;
>  	}
>  
> -	return avail_idx != vq->last_avail_idx;
> +	return avail_idx != vq->avail_idx;
>  }
>  
>  /* We don't need to be notified again. */
> diff -ruNp net-next-v0/drivers/vhost/vhost.h net-next-v5/drivers/vhost/vhost.h
> --- net-next-v0/drivers/vhost/vhost.h	2010-03-22 12:04:38.000000000 -0700
> +++ net-next-v5/drivers/vhost/vhost.h	2010-04-22 11:35:54.000000000 -0700
> @@ -84,7 +84,9 @@ struct vhost_virtqueue {
>  	struct iovec indirect[VHOST_NET_MAX_SG];
>  	struct iovec iov[VHOST_NET_MAX_SG];
>  	struct iovec hdr[VHOST_NET_MAX_SG];
> -	size_t hdr_size;
> +	size_t vhost_hlen;
> +	size_t sock_hlen;
> +	struct vring_used_elem heads[VHOST_NET_MAX_SG];
>  	/* We use a kind of RCU to access private pointer.
>  	 * All readers access it from workqueue, which makes it possible to
>  	 * flush the workqueue instead of synchronize_rcu. Therefore readers do
> @@ -120,16 +122,23 @@ long vhost_dev_ioctl(struct vhost_dev *,
>  int vhost_vq_access_ok(struct vhost_virtqueue *vq);
>  int vhost_log_access_ok(struct vhost_dev *);
>  
> -unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
> +int vhost_get_desc_n(struct vhost_virtqueue *, struct vring_used_elem *heads,
> +		     int datalen, int *iovcount, struct vhost_log *log,
> +		     unsigned int *log_num);
> +unsigned vhost_get_desc(struct vhost_dev *, struct vhost_virtqueue *,
>  			   struct iovec iov[], unsigned int iov_count,
>  			   unsigned int *out_num, unsigned int *in_num,
>  			   struct vhost_log *log, unsigned int *log_num);
> -void vhost_discard_vq_desc(struct vhost_virtqueue *);
> +void vhost_discard_desc(struct vhost_virtqueue *, int);
>  
>  int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
> -void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
> +int vhost_add_used_n(struct vhost_virtqueue *, struct vring_used_elem *heads,
> +		    int count);
>  void vhost_add_used_and_signal(struct vhost_dev *, struct vhost_virtqueue *,
> -			       unsigned int head, int len);
> +			       unsigned int id, int len);
> +void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
> +			       struct vring_used_elem *heads, int count);
> +void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
>  void vhost_disable_notify(struct vhost_virtqueue *);
>  bool vhost_enable_notify(struct vhost_virtqueue *);
>  
> @@ -149,7 +158,8 @@ enum {
>  	VHOST_FEATURES = (1 << VIRTIO_F_NOTIFY_ON_EMPTY) |
>  			 (1 << VIRTIO_RING_F_INDIRECT_DESC) |
>  			 (1 << VHOST_F_LOG_ALL) |
> -			 (1 << VHOST_NET_F_VIRTIO_NET_HDR),
> +			 (1 << VHOST_NET_F_VIRTIO_NET_HDR) |
> +			 (1 << VIRTIO_NET_F_MRG_RXBUF),
>  };
>  
>  static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
> 
