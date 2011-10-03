From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 1/2] virtio-net: Verify page list size before fitting
 into  skb
Date: Mon, 3 Oct 2011 21:04:16 +0200
Message-ID: <20111003190416.GC22427@redhat.com>
References: <1317220855-9352-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1317220855-9352-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 28, 2011 at 05:40:54PM +0300, Sasha Levin wrote:
> This patch verifies that the length of a buffer stored in a linked list
> of pages is small enough to fit into a skb.
> 
> If the size is larger than a max size of a skb, it means that we shouldn't
> go ahead building skbs anyway since we won't be able to send the buffer as
> the user requested.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: virtualization@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Cc: kvm@vger.kernel.org
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  drivers/net/virtio_net.c |   13 +++++++++++++
>  1 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 0c7321c..bde0dec 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -195,6 +195,19 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
>  	len -= copy;
>  	offset += copy;
>  
> +	/*
> +	 * Verify that we can indeed put this data into a skb.
> +	 * This is here to handle cases when the device erroneously
> +	 * tries to receive more than is possible. This is usually
> +	 * the case of a broken device.
> +	 */
> +	if (unlikely(len > MAX_SKB_FRAGS * PAGE_SIZE)) {
> +		if (net_ratelimit())
> +			pr_debug("%s: too much data\n", skb->dev->name);
> +		dev_kfree_skb(skb);
> +		return NULL;
> +	}
> +

BTW, receive_mergeable does
                        pr_debug("%s: packet too long\n", skb->dev->name);
                        skb->dev->stats.rx_length_errors++;

which makes sense.

>  	while (len) {
>  		set_skb_frag(skb, page, offset, &len);
>  		page = (struct page *)page->private;
> -- 
> 1.7.6.1
