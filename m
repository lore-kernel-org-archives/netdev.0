From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 1/2] vhost_net: stop polling socket during rx processing
Date: Mon, 30 May 2016 18:47:11 +0300
Message-ID: <20160530184211-mutt-send-email-mst@redhat.com>
References: <1464590874-39539-1-git-send-email-jasowang@redhat.com>
	<1464590874-39539-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1464590874-39539-2-git-send-email-jasowang@redhat.com>
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

On Mon, May 30, 2016 at 02:47:53AM -0400, Jason Wang wrote:
> We don't stop rx polling socket during rx processing, this will lead
> unnecessary wakeups from under layer net devices (E.g
> sock_def_readable() form tun). Rx will be slowed down in this
> way. This patch avoids this by stop polling socket during rx
> processing. A small drawback is that this introduces some overheads in
> light load case because of the extra start/stop polling, but single
> netperf TCP_RR does not notice any change. In a super heavy load case,
> e.g using pktgen to inject packet to guest, we get about ~8.8%
> improvement on pps:
> 
> before: ~1240000 pkt/s
> after:  ~1350000 pkt/s
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/net.c | 56 +++++++++++++++++++++++++++--------------------------
>  1 file changed, 29 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 10ff494..e91603b 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -301,6 +301,32 @@ static bool vhost_can_busy_poll(struct vhost_dev *dev,
>  	       !vhost_has_work(dev);
>  }
>  
> +static void vhost_net_disable_vq(struct vhost_net *n,
> +				 struct vhost_virtqueue *vq)
> +{
> +	struct vhost_net_virtqueue *nvq =
> +		container_of(vq, struct vhost_net_virtqueue, vq);
> +	struct vhost_poll *poll = n->poll + (nvq - n->vqs);
> +	if (!vq->private_data)
> +		return;
> +	vhost_poll_stop(poll);
> +}
> +
> +static int vhost_net_enable_vq(struct vhost_net *n,
> +				struct vhost_virtqueue *vq)
> +{
> +	struct vhost_net_virtqueue *nvq =
> +		container_of(vq, struct vhost_net_virtqueue, vq);
> +	struct vhost_poll *poll = n->poll + (nvq - n->vqs);
> +	struct socket *sock;
> +
> +	sock = vq->private_data;
> +	if (!sock)
> +		return 0;
> +
> +	return vhost_poll_start(poll, sock->file);
> +}
> +
>  static int vhost_net_tx_get_vq_desc(struct vhost_net *net,
>  				    struct vhost_virtqueue *vq,
>  				    struct iovec iov[], unsigned int iov_size,

BTW we might want to rename these functions, name no longer
reflects function ...


> @@ -627,6 +653,7 @@ static void handle_rx(struct vhost_net *net)
>  	if (!sock)
>  		goto out;
>  	vhost_disable_notify(&net->dev, vq);
> +	vhost_net_disable_vq(net, vq);
>  
>  	vhost_hlen = nvq->vhost_hlen;
>  	sock_hlen = nvq->sock_hlen;
> @@ -715,9 +742,10 @@ static void handle_rx(struct vhost_net *net)
>  		total_len += vhost_len;
>  		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
>  			vhost_poll_queue(&vq->poll);
> -			break;
> +			goto out;
>  		}
>  	}
> +	vhost_net_enable_vq(net, vq);

OK so if sock is readable but RX VQ is empty, this will
immediately schedule another round of handle_rx and so ad
infinitum,

Looks like a bug.


>  out:
>  	mutex_unlock(&vq->mutex);
>  }
> @@ -796,32 +824,6 @@ static int vhost_net_open(struct inode *inode, struct file *f)
>  	return 0;
>  }
>  
> -static void vhost_net_disable_vq(struct vhost_net *n,
> -				 struct vhost_virtqueue *vq)
> -{
> -	struct vhost_net_virtqueue *nvq =
> -		container_of(vq, struct vhost_net_virtqueue, vq);
> -	struct vhost_poll *poll = n->poll + (nvq - n->vqs);
> -	if (!vq->private_data)
> -		return;
> -	vhost_poll_stop(poll);
> -}
> -
> -static int vhost_net_enable_vq(struct vhost_net *n,
> -				struct vhost_virtqueue *vq)
> -{
> -	struct vhost_net_virtqueue *nvq =
> -		container_of(vq, struct vhost_net_virtqueue, vq);
> -	struct vhost_poll *poll = n->poll + (nvq - n->vqs);
> -	struct socket *sock;
> -
> -	sock = vq->private_data;
> -	if (!sock)
> -		return 0;
> -
> -	return vhost_poll_start(poll, sock->file);
> -}
> -
>  static struct socket *vhost_net_stop_vq(struct vhost_net *n,
>  					struct vhost_virtqueue *vq)
>  {
> -- 
> 1.8.3.1
