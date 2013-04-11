From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost_net: remove tx polling state
Date: Thu, 11 Apr 2013 10:24:30 +0300
Message-ID: <20130411072430.GC17063@redhat.com>
References: <1365663048-38332-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1365663048-38332-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 11, 2013 at 02:50:48PM +0800, Jason Wang wrote:
> After commit 2b8b328b61c799957a456a5a8dab8cc7dea68575 (vhost_net: handle polling
> errors when setting backend), we in fact track the polling state through
> poll->wqh, so there's no need to duplicate the work with an extra
> vhost_net_polling_state. So this patch removes this and make the code simpler.
> 
> This patch also removes the all tx starting/stopping code in tx path according
> to Michael's suggestion.
> 
> Netperf test shows almost the same result in stream test, but gets improvements
> on TCP_RR tests (both zerocopy or copy) especially on low load cases.
> 
> Tested between multiqueue kvm guest and external host with two direct
> connected 82599s.
> 
> zerocopy disabled:
> 
> sessions|transaction rates|normalize|
> before/after/+improvements
> 1 | 9510.24/11727.29/+23.3%    | 693.54/887.68/+28.0%   |
> 25| 192931.50/241729.87/+25.3% | 2376.80/2771.70/+16.6% |
> 50| 277634.64/291905.76/+5%    | 3118.36/3230.11/+3.6%  |
> 
> zerocopy enabled:
> 
> sessions|transaction rates|normalize|
> before/after/+improvements
> 1 | 7318.33/11929.76/+63.0%    | 521.86/843.30/+61.6%   |
> 25| 167264.88/242422.15/+44.9% | 2181.60/2788.16/+27.8% |
> 50| 272181.02/294347.04/+8.1%  | 3071.56/3257.85/+6.1%  |
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Less code and better speed, what's not to like.
Davem, could you pick this up for 3.10 please?

Acked-by: Michael S. Tsirkin <mst@redhat.com>


> ---
>  drivers/vhost/net.c   |   74 ++++---------------------------------------------
>  drivers/vhost/vhost.c |    3 ++
>  2 files changed, 9 insertions(+), 68 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index ec6fb3f..87c216c 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -64,20 +64,10 @@ enum {
>  	VHOST_NET_VQ_MAX = 2,
>  };
>  
> -enum vhost_net_poll_state {
> -	VHOST_NET_POLL_DISABLED = 0,
> -	VHOST_NET_POLL_STARTED = 1,
> -	VHOST_NET_POLL_STOPPED = 2,
> -};
> -
>  struct vhost_net {
>  	struct vhost_dev dev;
>  	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
>  	struct vhost_poll poll[VHOST_NET_VQ_MAX];
> -	/* Tells us whether we are polling a socket for TX.
> -	 * We only do this when socket buffer fills up.
> -	 * Protected by tx vq lock. */
> -	enum vhost_net_poll_state tx_poll_state;
>  	/* Number of TX recently submitted.
>  	 * Protected by tx vq lock. */
>  	unsigned tx_packets;
> @@ -155,28 +145,6 @@ static void copy_iovec_hdr(const struct iovec *from, struct iovec *to,
>  	}
>  }
>  
> -/* Caller must have TX VQ lock */
> -static void tx_poll_stop(struct vhost_net *net)
> -{
> -	if (likely(net->tx_poll_state != VHOST_NET_POLL_STARTED))
> -		return;
> -	vhost_poll_stop(net->poll + VHOST_NET_VQ_TX);
> -	net->tx_poll_state = VHOST_NET_POLL_STOPPED;
> -}
> -
> -/* Caller must have TX VQ lock */
> -static int tx_poll_start(struct vhost_net *net, struct socket *sock)
> -{
> -	int ret;
> -
> -	if (unlikely(net->tx_poll_state != VHOST_NET_POLL_STOPPED))
> -		return 0;
> -	ret = vhost_poll_start(net->poll + VHOST_NET_VQ_TX, sock->file);
> -	if (!ret)
> -		net->tx_poll_state = VHOST_NET_POLL_STARTED;
> -	return ret;
> -}
> -
>  /* In case of DMA done not in order in lower device driver for some reason.
>   * upend_idx is used to track end of used idx, done_idx is used to track head
>   * of used idx. Once lower device DMA done contiguously, we will signal KVM
> @@ -242,7 +210,7 @@ static void handle_tx(struct vhost_net *net)
>  		.msg_flags = MSG_DONTWAIT,
>  	};
>  	size_t len, total_len = 0;
> -	int err, wmem;
> +	int err;
>  	size_t hdr_size;
>  	struct socket *sock;
>  	struct vhost_ubuf_ref *uninitialized_var(ubufs);
> @@ -253,19 +221,9 @@ static void handle_tx(struct vhost_net *net)
>  	if (!sock)
>  		return;
>  
> -	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> -	if (wmem >= sock->sk->sk_sndbuf) {
> -		mutex_lock(&vq->mutex);
> -		tx_poll_start(net, sock);
> -		mutex_unlock(&vq->mutex);
> -		return;
> -	}
> -
>  	mutex_lock(&vq->mutex);
>  	vhost_disable_notify(&net->dev, vq);
>  
> -	if (wmem < sock->sk->sk_sndbuf / 2)
> -		tx_poll_stop(net);
>  	hdr_size = vq->vhost_hlen;
>  	zcopy = vq->ubufs;
>  
> @@ -285,23 +243,14 @@ static void handle_tx(struct vhost_net *net)
>  		if (head == vq->num) {
>  			int num_pends;
>  
> -			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> -			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
> -				tx_poll_start(net, sock);
> -				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
> -				break;
> -			}
>  			/* If more outstanding DMAs, queue the work.
>  			 * Handle upend_idx wrap around
>  			 */
>  			num_pends = likely(vq->upend_idx >= vq->done_idx) ?
>  				    (vq->upend_idx - vq->done_idx) :
>  				    (vq->upend_idx + UIO_MAXIOV - vq->done_idx);
> -			if (unlikely(num_pends > VHOST_MAX_PEND)) {
> -				tx_poll_start(net, sock);
> -				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
> +			if (unlikely(num_pends > VHOST_MAX_PEND))
>  				break;
> -			}
>  			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
>  				vhost_disable_notify(&net->dev, vq);
>  				continue;
> @@ -364,8 +313,6 @@ static void handle_tx(struct vhost_net *net)
>  					UIO_MAXIOV;
>  			}
>  			vhost_discard_vq_desc(vq, 1);
> -			if (err == -EAGAIN || err == -ENOBUFS)
> -				tx_poll_start(net, sock);
>  			break;
>  		}
>  		if (err != len)
> @@ -628,7 +575,6 @@ static int vhost_net_open(struct inode *inode, struct file *f)
>  
>  	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
>  	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
> -	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
>  
>  	f->private_data = n;
>  
> @@ -638,32 +584,24 @@ static int vhost_net_open(struct inode *inode, struct file *f)
>  static void vhost_net_disable_vq(struct vhost_net *n,
>  				 struct vhost_virtqueue *vq)
>  {
> +	struct vhost_poll *poll = n->poll + (vq - n->vqs);
>  	if (!vq->private_data)
>  		return;
> -	if (vq == n->vqs + VHOST_NET_VQ_TX) {
> -		tx_poll_stop(n);
> -		n->tx_poll_state = VHOST_NET_POLL_DISABLED;
> -	} else
> -		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
> +	vhost_poll_stop(poll);
>  }
>  
>  static int vhost_net_enable_vq(struct vhost_net *n,
>  				struct vhost_virtqueue *vq)
>  {
> +	struct vhost_poll *poll = n->poll + (vq - n->vqs);
>  	struct socket *sock;
> -	int ret;
>  
>  	sock = rcu_dereference_protected(vq->private_data,
>  					 lockdep_is_held(&vq->mutex));
>  	if (!sock)
>  		return 0;
> -	if (vq == n->vqs + VHOST_NET_VQ_TX) {
> -		n->tx_poll_state = VHOST_NET_POLL_STOPPED;
> -		ret = tx_poll_start(n, sock);
> -	} else
> -		ret = vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
>  
> -	return ret;
> +	return vhost_poll_start(poll, sock->file);
>  }
>  
>  static struct socket *vhost_net_stop_vq(struct vhost_net *n,
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 9759249..4eecdb8 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -89,6 +89,9 @@ int vhost_poll_start(struct vhost_poll *poll, struct file *file)
>  	unsigned long mask;
>  	int ret = 0;
>  
> +	if (poll->wqh)
> +		return 0;
> +
>  	mask = file->f_op->poll(file, &poll->table);
>  	if (mask)
>  		vhost_poll_wakeup(&poll->wait, 0, 0, (void *)mask);
> -- 
> 1.7.1
