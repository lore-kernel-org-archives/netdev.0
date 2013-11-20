From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 1/3] virtio-net: drop the rest of buffers when we
	can't allocate skb
Date: Wed, 20 Nov 2013 12:34:06 +0200
Message-ID: <20131120103406.GF19341@redhat.com>
References: <1384938447-3775-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, Shirley Ma <xma@us.ibm.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1384938447-3775-1-git-send-email-jasowang@redhat.com>
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

On Wed, Nov 20, 2013 at 05:07:25PM +0800, Jason Wang wrote:
> When mergeable buffer were used, we only put the first page buf leave the rest
> of buffers in the virt queue. This will cause the driver could not get the
> correct head buffer any more. Fix this by dropping the rest of buffers for this
> packet.
> 
> The bug was introduced by commit 9ab86bbcf8be755256f0a5e994e0b38af6b4d399
> (virtio_net: Defer skb allocation in receive path).
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michael Dalton <mwdalton@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Shirley Ma <xma@us.ibm.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> This patch was needed for stable
> ---
>  drivers/net/virtio_net.c | 18 +++++++++++++++++-
>  1 file changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 7bab4de..24fd502 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -222,6 +222,17 @@ static void skb_xmit_done(struct virtqueue *vq)
>  	netif_wake_subqueue(vi->dev, vq2txq(vq));
>  }
>  
> +static void drop_mergeable_buffer(struct receive_queue *rq, int num_buf)
> +{
> +	char *buf;
> +	int len;
> +
> +	while (--num_buf && (buf = virtqueue_get_buf(rq->vq, &len)) != NULL) {
> +		--rq->num;
> +		put_page(virt_to_head_page(buf));
> +	}
> +}
> +

This is the same code we have in receive_mergeable anyway.
So let's reuse that.


>  /* Called from bottom half context */
>  static struct sk_buff *page_to_skb(struct receive_queue *rq,
>  				   struct page *page, unsigned int offset,
> @@ -237,8 +248,13 @@ static struct sk_buff *page_to_skb(struct receive_queue *rq,
>  
>  	/* copy small packet so we can reuse these pages for small data */
>  	skb = netdev_alloc_skb_ip_align(vi->dev, GOOD_COPY_LEN);
> -	if (unlikely(!skb))
> +	if (unlikely(!skb)) {
> +		if (vi->mergeable_rx_bufs) {
> +			hdr = (struct skb_vnet_hdr *)p;
> +			drop_mergeable_buffer(rq, hdr->mhdr.num_buffers);
> +		}
>  		return NULL;
> +	}
>  
>  	hdr = skb_vnet_hdr(skb);
>  
> -- 
> 1.8.3.2
