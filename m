From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio-net: don't free skb immediately on kick failure
Date: Sun, 23 Mar 2014 13:27:19 +0200
Message-ID: <20140323112719.GE6989@redhat.com>
References: <1395390601-13177-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1395390601-13177-1-git-send-email-jasowang@redhat.com>
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

On Fri, Mar 21, 2014 at 04:30:01PM +0800, Jason Wang wrote:
> We free the skb immediately on kick failure during xmit without detaching it
> from the virtqueue. This may lead double free for the skb during
> free_unused_bufs(). This patch fixes this by not freeing it on kick failure and
> let it to be freed through free_unused_bufs().
> 
> Fixes 67975901183799af8e93ec60e322f9e2a1940b9b
> ("virtio_net: verify if virtqueue_kick() succeeded").

It's not even obvious we want to increment fifo errors
counter.
So basically we want to ignore these errors.
In that case how about just reverting this chunk
of the patch?

Seems cleaner than adding more code.

The chunk filling in RX also seems inappropriate:
it will cause RX work to be requeued which isn't what
we wanted.

Also, what happens with virtnet_send_command?

Looks like that patch is completely wrong.

> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Heinz Graalfs <graalfs@linux.vnet.ibm.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 5632a99..d833d38 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -882,8 +882,10 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		if (net_ratelimit())
>  			dev_warn(&dev->dev,
>  				 "Unexpected TXQ (%d) queue failure: %d\n", qnum, err);
> -		dev->stats.tx_dropped++;
> -		kfree_skb(skb);
> +		if (err) {
> +			dev->stats.tx_dropped++;
> +			kfree_skb(skb);
> +		}
>  		return NETDEV_TX_OK;
>  	}
>  
> -- 
> 1.8.3.2
