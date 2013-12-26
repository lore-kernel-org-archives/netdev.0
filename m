From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH stable 2/2] virtio-net: make all RX paths handle erors
	consistently
Date: Thu, 26 Dec 2013 15:28:58 +0800
Message-ID: <52BBDABA.1080804@redhat.com>
References: <1387983339-1172-1-git-send-email-mst@redhat.com>
	<1387983339-1172-3-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1387983339-1172-3-git-send-email-mst@redhat.com>
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

On 12/25/2013 10:56 PM, Michael S. Tsirkin wrote:
> receive mergeable now handles errors internally.
> Do same for big and small packet paths, otherwise
> the logic is too hard to follow.
>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>
> (cherry picked from commit f121159d72091f25afb22007c833e60a6845e912)
> ---
>  drivers/net/virtio_net.c | 56 +++++++++++++++++++++++++++++++-----------------
>  1 file changed, 36 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 435076f..c0ed6d5 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -297,6 +297,34 @@ static struct sk_buff *page_to_skb(struct receive_queue *rq,
>  	return skb;
>  }
>  
> +static struct sk_buff *receive_small(void *buf, unsigned int len)
> +{
> +	struct sk_buff * skb = buf;
> +
> +	len -= sizeof(struct virtio_net_hdr);
> +	skb_trim(skb, len);
> +
> +	return skb;
> +}
> +
> +static struct sk_buff *receive_big(struct net_device *dev,
> +				   struct receive_queue *rq,
> +				   void *buf)
> +{
> +	struct page *page = buf;
> +	struct sk_buff *skb = page_to_skb(rq, page, 0);
> +
> +	if (unlikely(!skb))
> +		goto err;
> +
> +	return skb;
> +
> +err:
> +	dev->stats.rx_dropped++;
> +	give_pages(rq, page);
> +	return NULL;
> +}
> +
>  static struct sk_buff *receive_mergeable(struct net_device *dev,
>  					 struct receive_queue *rq,
>  					 void *buf,
> @@ -360,7 +388,6 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>  	struct net_device *dev = vi->dev;
>  	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>  	struct sk_buff *skb;
> -	struct page *page;
>  	struct skb_vnet_hdr *hdr;
>  
>  	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
> @@ -372,26 +399,15 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>  			dev_kfree_skb(buf);
>  		return;
>  	}
> +	if (vi->mergeable_rx_bufs)
> +		skb = receive_mergeable(dev, rq, buf, len);
> +	else if (vi->big_packets)
> +		skb = receive_big(dev, rq, buf);
> +	else
> +		skb = receive_small(buf, len);
>  
> -	if (!vi->mergeable_rx_bufs && !vi->big_packets) {
> -		skb = buf;
> -		len -= sizeof(struct virtio_net_hdr);
> -		skb_trim(skb, len);
> -	} else {
> -		page = buf;
> -		if (vi->mergeable_rx_bufs) {
> -			skb = receive_mergeable(dev, rq, page, len);
> -			if (unlikely(!skb))
> -				return;
> -		} else {
> -			skb = page_to_skb(rq, page, len);
> -			if (unlikely(!skb)) {
> -				dev->stats.rx_dropped++;
> -				give_pages(rq, page);
> -				return;
> -			}
> -		}
> -	}
> +	if (unlikely(!skb))
> +		return;
>  
>  	hdr = skb_vnet_hdr(skb);
>  
Ack-ed by: Jason Wang <jasowang@redhat.com>
