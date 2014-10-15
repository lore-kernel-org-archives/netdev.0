From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH net-next 6/6] virtio-net: enable tx interrupt only
	for the final skb in the chain
Date: Wed, 15 Oct 2014 13:22:51 +0300
Message-ID: <20141015102251.GE25776@redhat.com>
References: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
	<1413357930-45302-7-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413357930-45302-7-git-send-email-jasowang@redhat.com>
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

On Wed, Oct 15, 2014 at 03:25:30PM +0800, Jason Wang wrote:
> With the help of xmit_more and virtqueue_enable_cb_avail(), this patch
> enable tx interrupt only for the final skb in the chain if
> needed. This will help to mitigate tx interrupts.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

I think you should split xmit_more stuff out.



> ---
>  drivers/net/virtio_net.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 2afc2e2..5943f3f 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -993,12 +993,16 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  				virtqueue_disable_cb(sq->vq);
>  			}
>  		}
> -	} else if (virtqueue_enable_cb(sq->vq)) {
> -		free_old_xmit_skbs(sq, qsize);
>  	}
>  
> -	if (__netif_subqueue_stopped(dev, qnum) || !skb->xmit_more)
> +	if (__netif_subqueue_stopped(dev, qnum) || !skb->xmit_more) {
>  		virtqueue_kick(sq->vq);
> +		if (sq->vq->num_free >= 2 +MAX_SKB_FRAGS &&
> +		    unlikely(virtqueue_enable_cb_avail(sq->vq))) {
> +			free_old_xmit_skbs(sq, qsize);
> +			virtqueue_disable_cb(sq->vq);
> +		}
> +	}
>  
>  	return NETDEV_TX_OK;
>  }
> -- 
> 1.7.1
