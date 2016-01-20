From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 3/3] vhost_net: basic polling support
Date: Wed, 20 Jan 2016 16:35:24 +0200
Message-ID: <20160120143524.GA27168@redhat.com>
References: <1448951985-12385-1-git-send-email-jasowang@redhat.com>
 <1448951985-12385-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45393 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932261AbcATOf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 09:35:27 -0500
Content-Disposition: inline
In-Reply-To: <1448951985-12385-4-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2015 at 02:39:45PM +0800, Jason Wang wrote:
> This patch tries to poll for new added tx buffer or socket receive
> queue for a while at the end of tx/rx processing. The maximum time
> spent on polling were specified through a new kind of vring ioctl.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/net.c        | 72 ++++++++++++++++++++++++++++++++++++++++++----
>  drivers/vhost/vhost.c      | 15 ++++++++++
>  drivers/vhost/vhost.h      |  1 +
>  include/uapi/linux/vhost.h | 11 +++++++
>  4 files changed, 94 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 9eda69e..ce6da77 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -287,6 +287,41 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
>  	rcu_read_unlock_bh();
>  }
>  
> +static inline unsigned long busy_clock(void)
> +{
> +	return local_clock() >> 10;
> +}
> +
> +static bool vhost_can_busy_poll(struct vhost_dev *dev,
> +				unsigned long endtime)
> +{
> +	return likely(!need_resched()) &&
> +	       likely(!time_after(busy_clock(), endtime)) &&
> +	       likely(!signal_pending(current)) &&
> +	       !vhost_has_work(dev) &&
> +	       single_task_running();
> +}
> +
> +static int vhost_net_tx_get_vq_desc(struct vhost_net *net,
> +				    struct vhost_virtqueue *vq,
> +				    struct iovec iov[], unsigned int iov_size,
> +				    unsigned int *out_num, unsigned int *in_num)
> +{
> +	unsigned long uninitialized_var(endtime);
> +
> +	if (vq->busyloop_timeout) {
> +		preempt_disable();
> +		endtime = busy_clock() + vq->busyloop_timeout;
> +		while (vhost_can_busy_poll(vq->dev, endtime) &&
> +		       !vhost_vq_more_avail(vq->dev, vq))
> +			cpu_relax();
> +		preempt_enable();
> +	}

Isn't there a way to call all this after vhost_get_vq_desc?
First, this will reduce the good path overhead as you
won't have to play with timers and preemption.

Second, this will reduce the chance of a pagefault on avail ring read.

> +
> +	return vhost_get_vq_desc(vq, vq->iov, ARRAY_SIZE(vq->iov),
> +				 out_num, in_num, NULL, NULL);
> +}
> +
>  /* Expects to be always run from workqueue - which acts as
>   * read-size critical section for our kind of RCU. */
>  static void handle_tx(struct vhost_net *net)
> @@ -331,10 +366,9 @@ static void handle_tx(struct vhost_net *net)
>  			      % UIO_MAXIOV == nvq->done_idx))
>  			break;
>  
> -		head = vhost_get_vq_desc(vq, vq->iov,
> -					 ARRAY_SIZE(vq->iov),
> -					 &out, &in,
> -					 NULL, NULL);
> +		head = vhost_net_tx_get_vq_desc(net, vq, vq->iov,
> +						ARRAY_SIZE(vq->iov),
> +						&out, &in);
>  		/* On error, stop handling until the next kick. */
>  		if (unlikely(head < 0))
>  			break;
> @@ -435,6 +469,34 @@ static int peek_head_len(struct sock *sk)
>  	return len;
>  }
>  
> +static int vhost_net_peek_head_len(struct vhost_net *net, struct sock *sk)

Need a hint that it's rx related in the name.

> +{
> +	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
> +	struct vhost_virtqueue *vq = &nvq->vq;
> +	unsigned long uninitialized_var(endtime);
> +
> +	if (vq->busyloop_timeout) {
> +		mutex_lock(&vq->mutex);

This appears to be called under vq mutex in handle_rx.
So how does this work then?


> +		vhost_disable_notify(&net->dev, vq);

This appears to be called after disable notify
in handle_rx - so why disable here again?

> +
> +		preempt_disable();
> +		endtime = busy_clock() + vq->busyloop_timeout;
> +
> +		while (vhost_can_busy_poll(&net->dev, endtime) &&
> +		       skb_queue_empty(&sk->sk_receive_queue) &&
> +		       !vhost_vq_more_avail(&net->dev, vq))
> +			cpu_relax();

This seems to mix in several items.
RX queue is normally not empty. I don't think
we need to poll for that.
So IMHO we only need to poll for sk_receive_queue really.

> +
> +		preempt_enable();
> +
> +		if (vhost_enable_notify(&net->dev, vq))
> +			vhost_poll_queue(&vq->poll);

But vhost_enable_notify returns true on queue not empty.
So in fact this will requeue on good path -
does not make sense to me.

> +		mutex_unlock(&vq->mutex);
> +	}
> +

Same comment as for get vq desc here: don't slow
down the good path.

> +	return peek_head_len(sk);
> +}
> +
>  /* This is a multi-buffer version of vhost_get_desc, that works if
>   *	vq has read descriptors only.
>   * @vq		- the relevant virtqueue
> @@ -553,7 +615,7 @@ static void handle_rx(struct vhost_net *net)
>  		vq->log : NULL;
>  	mergeable = vhost_has_feature(vq, VIRTIO_NET_F_MRG_RXBUF);
>  
> -	while ((sock_len = peek_head_len(sock->sk))) {
> +	while ((sock_len = vhost_net_peek_head_len(net, sock->sk))) {
>  		sock_len += sock_hlen;
>  		vhost_len = sock_len + vhost_hlen;
>  		headcount = get_rx_bufs(vq, vq->heads, vhost_len,
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 4f45a03..b8ca873 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -285,6 +285,7 @@ static void vhost_vq_reset(struct vhost_dev *dev,
>  	vq->memory = NULL;
>  	vq->is_le = virtio_legacy_is_little_endian();
>  	vhost_vq_reset_user_be(vq);
> +	vq->busyloop_timeout = 0;
>  }
>  
>  static int vhost_worker(void *data)
> @@ -747,6 +748,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
>  	struct vhost_vring_state s;
>  	struct vhost_vring_file f;
>  	struct vhost_vring_addr a;
> +	struct vhost_vring_busyloop_timeout t;
>  	u32 idx;
>  	long r;
>  
> @@ -919,6 +921,19 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
>  	case VHOST_GET_VRING_ENDIAN:
>  		r = vhost_get_vring_endian(vq, idx, argp);
>  		break;
> +	case VHOST_SET_VRING_BUSYLOOP_TIMEOUT:
> +		if (copy_from_user(&t, argp, sizeof(t))) {
> +			r = -EFAULT;
> +			break;
> +		}
> +		vq->busyloop_timeout = t.timeout;
> +		break;
> +	case VHOST_GET_VRING_BUSYLOOP_TIMEOUT:
> +		t.index = idx;
> +		t.timeout = vq->busyloop_timeout;
> +		if (copy_to_user(argp, &t, sizeof(t)))
> +			r = -EFAULT;
> +		break;
>  	default:
>  		r = -ENOIOCTLCMD;
>  	}
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 2f3c57c..4b7d4fa 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -115,6 +115,7 @@ struct vhost_virtqueue {
>  	/* Ring endianness requested by userspace for cross-endian support. */
>  	bool user_be;
>  #endif
> +	u32 busyloop_timeout;
>  };
>  
>  struct vhost_dev {
> diff --git a/include/uapi/linux/vhost.h b/include/uapi/linux/vhost.h
> index ab373191..eaf6c33 100644
> --- a/include/uapi/linux/vhost.h
> +++ b/include/uapi/linux/vhost.h
> @@ -27,6 +27,11 @@ struct vhost_vring_file {
>  
>  };
>  
> +struct vhost_vring_busyloop_timeout {
> +	unsigned int index;
> +	unsigned int timeout;
> +};
> +

So why not reuse vhost_vring_state then?




>  struct vhost_vring_addr {
>  	unsigned int index;
>  	/* Option flags. */
> @@ -126,6 +131,12 @@ struct vhost_memory {
>  #define VHOST_SET_VRING_CALL _IOW(VHOST_VIRTIO, 0x21, struct vhost_vring_file)
>  /* Set eventfd to signal an error */
>  #define VHOST_SET_VRING_ERR _IOW(VHOST_VIRTIO, 0x22, struct vhost_vring_file)
> +/* Set busy loop timeout */

Units?

> +#define VHOST_SET_VRING_BUSYLOOP_TIMEOUT _IOW(VHOST_VIRTIO, 0x23,	\
> +					 struct vhost_vring_busyloop_timeout)
> +/* Get busy loop timeout */
> +#define VHOST_GET_VRING_BUSYLOOP_TIMEOUT _IOW(VHOST_VIRTIO, 0x24,	\
> +					 struct vhost_vring_busyloop_timeout)
>  
>  /* VHOST_NET specific defines */
>  
> -- 
> 2.5.0
