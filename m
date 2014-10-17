From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC v2 2/3] virtio_net: bql
Date: Fri, 17 Oct 2014 13:16:27 +0800
Message-ID: <5440A62B.9050006@redhat.com>
References: <1413383116-30977-1-git-send-email-mst@redhat.com>
	<1413383116-30977-3-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1413383116-30977-3-git-send-email-mst@redhat.com>
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

On 10/15/2014 10:32 PM, Michael S. Tsirkin wrote:
> Improve tx batching using byte queue limits.
> Should be especially effective for MQ.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index a9bf178..8dea411 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -219,13 +219,15 @@ static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
>  	return p;
>  }
>  
> -static unsigned int free_old_xmit_skbs(struct send_queue *sq, int budget)
> +static unsigned int free_old_xmit_skbs(struct netdev_queue *txq,
> +				       struct send_queue *sq, int budget)
>  {
>  	struct sk_buff *skb;
>  	unsigned int len;
>  	struct virtnet_info *vi = sq->vq->vdev->priv;
>  	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>  	unsigned int packets = 0;
> +	unsigned int bytes = 0;
>  
>  	while (packets < budget &&
>  	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
> @@ -233,6 +235,7 @@ static unsigned int free_old_xmit_skbs(struct send_queue *sq, int budget)
>  
>  		u64_stats_update_begin(&stats->tx_syncp);
>  		stats->tx_bytes += skb->len;
> +		bytes += skb->len;
>  		stats->tx_packets++;
>  		u64_stats_update_end(&stats->tx_syncp);
>  
> @@ -240,6 +243,8 @@ static unsigned int free_old_xmit_skbs(struct send_queue *sq, int budget)
>  		packets++;
>  	}
>  
> +	netdev_tx_completed_queue(txq, packets, bytes);
> +
>  	return packets;
>  }
>  
> @@ -810,7 +815,7 @@ static int virtnet_poll_tx(struct napi_struct *napi, int budget)
>  again:
>  	__netif_tx_lock(txq, smp_processor_id());
>  	virtqueue_disable_cb(sq->vq);
> -	sent += free_old_xmit_skbs(sq, budget - sent);
> +	sent += free_old_xmit_skbs(txq, sq, budget - sent);
>  
>  	if (sent < budget) {
>  		enable_done = virtqueue_enable_cb_delayed(sq->vq);
> @@ -962,12 +967,13 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
>  	bool kick = !skb->xmit_more;
>  	bool stopped;
> +	unsigned int bytes = skb->len;
>  
>  	virtqueue_disable_cb(sq->vq);
>  
>  	/* We are going to push one skb.
>  	 * Try to pop one off to free space for it. */
> -	free_old_xmit_skbs(sq, 1);
> +	free_old_xmit_skbs(txq, sq, 1);
>  
>  	/* Try to transmit */
>  	err = xmit_skb(sq, skb);
> @@ -983,6 +989,12 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		return NETDEV_TX_OK;
>  	}
>  
> +	netdev_tx_sent_queue(txq, bytes);
> +
> +	/* Kick early so device can process descriptors in parallel with us. */
> +	if (kick)
> +		virtqueue_kick(sq->vq);

Haven't figured out how this will help for bql, consider only a
netif_stop_subqueue() may be called during two possible kicks. And since
we don't add any buffer between the two kicks, the send kick is almost
useless.
> +
>  	/* Apparently nice girls don't return TX_BUSY; stop the queue
>  	 * before it gets out of hand.  Naturally, this wastes entries. */
>  	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
> @@ -997,7 +1009,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
>  		/* More just got used, free them then recheck. */
> -		free_old_xmit_skbs(sq, qsize);
> +		free_old_xmit_skbs(txq, sq, qsize);
>  		if (stopped && sq->vq->num_free >= 2+MAX_SKB_FRAGS)
>  			netif_start_subqueue(dev, qnum);
>  	}
