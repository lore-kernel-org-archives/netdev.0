From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] virtio_net: fix use after free
Date: Wed, 15 Oct 2014 13:24:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9D77AB@AcuExch.aculab.com>
References: <1413378878-28118-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jason Wang <jasowang@redhat.com>
To: "'Michael S. Tsirkin'" <mst@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413378878-28118-1-git-send-email-mst@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael S. Tsirkin
> commit 0b725a2ca61bedc33a2a63d0451d528b268cf975
>     net: Remove ndo_xmit_flush netdev operation, use signalling instead.
> 
> added code that looks at skb->xmit_more after the skb has
> been put in TX VQ. Since some paths process the ring and free the skb
> immediately, this can cause use after free.
> 
> Fix by storing xmit_more in a local variable.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> David, am I using the API correctly?
> Seems to work for me.
> You used __netif_subqueue_stopped but that seems to use
> a slightly more expensive test_bit internally.
> The reason I added a variable for the txq here is because it's handy for
> BQL patch later on.
> 
> 
>  drivers/net/virtio_net.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 3d0ce44..13d0a8b 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -920,6 +920,8 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	int qnum = skb_get_queue_mapping(skb);
>  	struct send_queue *sq = &vi->sq[qnum];
>  	int err;
> +	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);

Do you need to cache 'txq' on stack for the entire call?
Looks like it is only needed when 'kick' is true.
I've not looked to see if saves both 'dev' and 'qnum' being kept.

In any case it isn't mentioned in the commit message.

	David

> +	bool kick = !skb->xmit_more;
> 
>  	/* Free up any pending old buffers before queueing new ones. */
>  	free_old_xmit_skbs(sq);
> @@ -956,7 +958,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		}
>  	}
> 
> -	if (__netif_subqueue_stopped(dev, qnum) || !skb->xmit_more)
> +	if (kick || netif_xmit_stopped(txq))
>  		virtqueue_kick(sq->vq);
> 
>  	return NETDEV_TX_OK;
> --
> MST
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
