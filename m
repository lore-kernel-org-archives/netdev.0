From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 2/3] vhost_net: handle polling errors when setting
 backend
Date: Wed, 16 Jan 2013 13:00:15 +0200
Message-ID: <20130116110015.GC13470@redhat.com>
References: <1358332441-26859-1-git-send-email-jasowang@redhat.com>
 <1358332441-26859-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358332441-26859-3-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 16, 2013 at 06:34:00PM +0800, Jason Wang wrote:
> Currently, the polling errors were ignored, which can lead following issues:
> 
> - vhost remove itself unconditionally from waitqueue when stopping the poll,
>   this may crash the kernel since the previous attempt of starting may fail to
>   add itself to the waitqueue
> - userspace may think the backend were successfully set even when the polling
>   failed.
> 
> Solve this by:
> 
> - check poll->wqh before trying to remove from waitqueue
> - report polling errors in vhost_poll_start(), tx_poll_start(), the return value
>   will be checked and returned when userspace want to set the backend
> 
> After this fix, there still could be a polling failure after backend is set, it
> will addressed by the next patch.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>


Looks ok but needs to be considered together with the next one,
to make sure we cover all cases.

> ---
>  drivers/vhost/net.c   |   27 ++++++++++++++++++---------
>  drivers/vhost/vhost.c |   18 +++++++++++++++---
>  drivers/vhost/vhost.h |    2 +-
>  3 files changed, 34 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index d10ad6f..959b1cd 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -165,12 +165,16 @@ static void tx_poll_stop(struct vhost_net *net)
>  }
>  
>  /* Caller must have TX VQ lock */
> -static void tx_poll_start(struct vhost_net *net, struct socket *sock)
> +static int tx_poll_start(struct vhost_net *net, struct socket *sock)
>  {
> +	int ret;
> +
>  	if (unlikely(net->tx_poll_state != VHOST_NET_POLL_STOPPED))
> -		return;
> -	vhost_poll_start(net->poll + VHOST_NET_VQ_TX, sock->file);
> -	net->tx_poll_state = VHOST_NET_POLL_STARTED;
> +		return 0;
> +	ret = vhost_poll_start(net->poll + VHOST_NET_VQ_TX, sock->file);
> +	if (!ret)
> +		net->tx_poll_state = VHOST_NET_POLL_STARTED;
> +	return ret;
>  }
>  
>  /* In case of DMA done not in order in lower device driver for some reason.
> @@ -642,20 +646,23 @@ static void vhost_net_disable_vq(struct vhost_net *n,
>  		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
>  }
>  
> -static void vhost_net_enable_vq(struct vhost_net *n,
> +static int vhost_net_enable_vq(struct vhost_net *n,
>  				struct vhost_virtqueue *vq)
>  {
>  	struct socket *sock;
> +	int ret;
>  
>  	sock = rcu_dereference_protected(vq->private_data,
>  					 lockdep_is_held(&vq->mutex));
>  	if (!sock)
> -		return;
> +		return 0;
>  	if (vq == n->vqs + VHOST_NET_VQ_TX) {
>  		n->tx_poll_state = VHOST_NET_POLL_STOPPED;
> -		tx_poll_start(n, sock);
> +		ret = tx_poll_start(n, sock);
>  	} else
> -		vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
> +		ret = vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
> +
> +	return ret;
>  }
>  
>  static struct socket *vhost_net_stop_vq(struct vhost_net *n,
> @@ -833,7 +840,9 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
>  		r = vhost_init_used(vq);
>  		if (r)
>  			goto err_used;
> -		vhost_net_enable_vq(n, vq);
> +		r = vhost_net_enable_vq(n, vq);
> +		if (r)
> +			goto err_used;
>  
>  		oldubufs = vq->ubufs;
>  		vq->ubufs = ubufs;
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 34389f7..9759249 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -77,26 +77,38 @@ void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
>  	init_poll_funcptr(&poll->table, vhost_poll_func);
>  	poll->mask = mask;
>  	poll->dev = dev;
> +	poll->wqh = NULL;
>  
>  	vhost_work_init(&poll->work, fn);
>  }
>  
>  /* Start polling a file. We add ourselves to file's wait queue. The caller must
>   * keep a reference to a file until after vhost_poll_stop is called. */
> -void vhost_poll_start(struct vhost_poll *poll, struct file *file)
> +int vhost_poll_start(struct vhost_poll *poll, struct file *file)
>  {
>  	unsigned long mask;
> +	int ret = 0;
>  
>  	mask = file->f_op->poll(file, &poll->table);
>  	if (mask)
>  		vhost_poll_wakeup(&poll->wait, 0, 0, (void *)mask);
> +	if (mask & POLLERR) {
> +		if (poll->wqh)
> +			remove_wait_queue(poll->wqh, &poll->wait);
> +		ret = -EINVAL;
> +	}
> +
> +	return ret;
>  }
>  
>  /* Stop polling a file. After this function returns, it becomes safe to drop the
>   * file reference. You must also flush afterwards. */
>  void vhost_poll_stop(struct vhost_poll *poll)
>  {
> -	remove_wait_queue(poll->wqh, &poll->wait);
> +	if (poll->wqh) {
> +		remove_wait_queue(poll->wqh, &poll->wait);
> +		poll->wqh = NULL;
> +	}
>  }
>  
>  static bool vhost_work_seq_done(struct vhost_dev *dev, struct vhost_work *work,
> @@ -792,7 +804,7 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
>  		fput(filep);
>  
>  	if (pollstart && vq->handle_kick)
> -		vhost_poll_start(&vq->poll, vq->kick);
> +		r = vhost_poll_start(&vq->poll, vq->kick);
>  
>  	mutex_unlock(&vq->mutex);
>  
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 2639c58..17261e2 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -42,7 +42,7 @@ void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work);
>  
>  void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
>  		     unsigned long mask, struct vhost_dev *dev);
> -void vhost_poll_start(struct vhost_poll *poll, struct file *file);
> +int vhost_poll_start(struct vhost_poll *poll, struct file *file);
>  void vhost_poll_stop(struct vhost_poll *poll);
>  void vhost_poll_flush(struct vhost_poll *poll);
>  void vhost_poll_queue(struct vhost_poll *poll);
> -- 
> 1.7.1
