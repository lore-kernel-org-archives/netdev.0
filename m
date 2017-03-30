From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 net-next 7/7] vhost_net: try batch dequing from skb
 array
Date: Thu, 30 Mar 2017 17:21:45 +0300
Message-ID: <20170330165332-mutt-send-email-mst@kernel.org>
References: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
 <1490858550-7763-8-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1490858550-7763-8-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 30, 2017 at 03:22:30PM +0800, Jason Wang wrote:
> We used to dequeue one skb during recvmsg() from skb_array, this could
> be inefficient because of the bad cache utilization

which cache does this refer to btw?

> and spinlock
> touching for each packet.

Do you mean the effect of extra two atomics here?

> This patch tries to batch them by calling
> batch dequeuing helpers explicitly on the exported skb array and pass
> the skb back through msg_control for underlayer socket to finish the
> userspace copying.
> 
> Tests were done by XDP1:
> - small buffer:
>   Before: 1.88Mpps
>   After : 2.25Mpps (+19.6%)
> - mergeable buffer:
>   Before: 1.83Mpps
>   After : 2.10Mpps (+14.7%)
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Looks like I misread the code previously. More comments below,
sorry about not asking these questions earlier.

> ---
>  drivers/vhost/net.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 60 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 9b51989..ffa78c6 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -28,6 +28,8 @@
>  #include <linux/if_macvlan.h>
>  #include <linux/if_tap.h>
>  #include <linux/if_vlan.h>
> +#include <linux/skb_array.h>
> +#include <linux/skbuff.h>
>  
>  #include <net/sock.h>
>  
> @@ -85,6 +87,7 @@ struct vhost_net_ubuf_ref {
>  	struct vhost_virtqueue *vq;
>  };
>  
> +#define VHOST_RX_BATCH 64
>  struct vhost_net_virtqueue {
>  	struct vhost_virtqueue vq;
>  	size_t vhost_hlen;

Could you please try playing with batch size and see
what the effect is?


> @@ -99,6 +102,10 @@ struct vhost_net_virtqueue {
>  	/* Reference counting for outstanding ubufs.
>  	 * Protected by vq mutex. Writers must also take device mutex. */
>  	struct vhost_net_ubuf_ref *ubufs;
> +	struct skb_array *rx_array;
> +	void *rxq[VHOST_RX_BATCH];
> +	int rt;
> +	int rh;
>  };
>  
>  struct vhost_net {
> @@ -201,6 +208,8 @@ static void vhost_net_vq_reset(struct vhost_net *n)
>  		n->vqs[i].ubufs = NULL;
>  		n->vqs[i].vhost_hlen = 0;
>  		n->vqs[i].sock_hlen = 0;
> +		n->vqs[i].rt = 0;
> +		n->vqs[i].rh = 0;
>  	}
>  
>  }
> @@ -503,13 +512,30 @@ static void handle_tx(struct vhost_net *net)
>  	mutex_unlock(&vq->mutex);
>  }
>  
> -static int peek_head_len(struct sock *sk)
> +static int fetch_skbs(struct vhost_net_virtqueue *rvq)
> +{
> +	if (rvq->rh != rvq->rt)
> +		goto out;
> +
> +	rvq->rh = rvq->rt = 0;
> +	rvq->rt = skb_array_consume_batched(rvq->rx_array, rvq->rxq,
> +					    VHOST_RX_BATCH);
> +	if (!rvq->rt)
> +		return 0;
> +out:
> +	return __skb_array_len_with_tag(rvq->rxq[rvq->rh]);
> +}
> +
> +static int peek_head_len(struct vhost_net_virtqueue *rvq, struct sock *sk)
>  {
>  	struct socket *sock = sk->sk_socket;
>  	struct sk_buff *head;
>  	int len = 0;
>  	unsigned long flags;
>  
> +	if (rvq->rx_array)
> +		return fetch_skbs(rvq);
> +
>  	if (sock->ops->peek_len)
>  		return sock->ops->peek_len(sock);
>  
> @@ -535,12 +561,14 @@ static int sk_has_rx_data(struct sock *sk)
>  	return skb_queue_empty(&sk->sk_receive_queue);
>  }
>  
> -static int vhost_net_rx_peek_head_len(struct vhost_net *net, struct sock *sk)
> +static int vhost_net_rx_peek_head_len(struct vhost_net *net,
> +				      struct sock *sk)
>  {
> +	struct vhost_net_virtqueue *rvq = &net->vqs[VHOST_NET_VQ_RX];
>  	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
>  	struct vhost_virtqueue *vq = &nvq->vq;
>  	unsigned long uninitialized_var(endtime);
> -	int len = peek_head_len(sk);
> +	int len = peek_head_len(rvq, sk);
>  
>  	if (!len && vq->busyloop_timeout) {
>  		/* Both tx vq and rx socket were polled here */
> @@ -561,7 +589,7 @@ static int vhost_net_rx_peek_head_len(struct vhost_net *net, struct sock *sk)
>  			vhost_poll_queue(&vq->poll);
>  		mutex_unlock(&vq->mutex);
>  
> -		len = peek_head_len(sk);
> +		len = peek_head_len(rvq, sk);
>  	}
>  
>  	return len;
> @@ -699,6 +727,8 @@ static void handle_rx(struct vhost_net *net)
>  		/* On error, stop handling until the next kick. */
>  		if (unlikely(headcount < 0))
>  			goto out;
> +		if (nvq->rx_array)
> +			msg.msg_control = nvq->rxq[nvq->rh++];
>  		/* On overrun, truncate and discard */
>  		if (unlikely(headcount > UIO_MAXIOV)) {
>  			iov_iter_init(&msg.msg_iter, READ, vq->iov, 1, 1);

So there's a bit of a mystery here. vhost code isn't
batched, all we are batching is the fetch from the tun ring.

So what is the source of the speedup?

Are queued spinlocks that expensive? They shouldn't be ...
Could you try using virt_spin_lock instead (at least as a quick hack)
to see whether that helps?
  
> @@ -841,6 +871,8 @@ static int vhost_net_open(struct inode *inode, struct file *f)
>  		n->vqs[i].done_idx = 0;
>  		n->vqs[i].vhost_hlen = 0;
>  		n->vqs[i].sock_hlen = 0;
> +		n->vqs[i].rt = 0;
> +		n->vqs[i].rh = 0;
>  	}
>  	vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
>
> @@ -856,11 +888,15 @@ static struct socket *vhost_net_stop_vq(struct vhost_net *n,
>  					struct vhost_virtqueue *vq)
>  {
>  	struct socket *sock;
> +	struct vhost_net_virtqueue *nvq =
> +		container_of(vq, struct vhost_net_virtqueue, vq);
>  
>  	mutex_lock(&vq->mutex);
>  	sock = vq->private_data;
>  	vhost_net_disable_vq(n, vq);
>  	vq->private_data = NULL;
> +	while (nvq->rh != nvq->rt)
> +		kfree_skb(nvq->rxq[nvq->rh++]);
>  	mutex_unlock(&vq->mutex);
>  	return sock;
>  }

So I didn't realise it but of course the effect will be
dropped packets if we just connect and disconnect without
consuming anything.

So I think it's worth it to try analysing the speedup a bit
and see whether we can get the gains without queueing
the skbs in vhost.

> @@ -953,6 +989,25 @@ static struct socket *get_raw_socket(int fd)
>  	return ERR_PTR(r);
>  }
>  
> +static struct skb_array *get_tap_skb_array(int fd)

That's a confusing name, pls prefix with vhost_, not tap.

> +{
> +	struct skb_array *array;
> +	struct file *file = fget(fd);
> +
> +	if (!file)
> +		return NULL;
> +	array = tun_get_skb_array(file);
> +	if (!IS_ERR(array))
> +		goto out;
> +	array = tap_get_skb_array(file);
> +	if (!IS_ERR(array))
> +		goto out;
> +	array = NULL;
> +out:
> +	fput(file);
> +	return array;
> +}
> +
>  static struct socket *get_tap_socket(int fd)
>  {
>  	struct file *file = fget(fd);
> @@ -1029,6 +1084,7 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
>  
>  		vhost_net_disable_vq(n, vq);
>  		vq->private_data = sock;
> +		nvq->rx_array = get_tap_skb_array(fd);
>  		r = vhost_vq_init_access(vq);
>  		if (r)
>  			goto err_used;
> -- 
> 2.7.4
