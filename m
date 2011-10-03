From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 2/2] virtio-net: Prevent NULL dereference
Date: Mon, 3 Oct 2011 21:05:17 +0200
Message-ID: <20111003190516.GD22427@redhat.com>
References: <1317220855-9352-1-git-send-email-levinsasha928@gmail.com>
 <1317220855-9352-2-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1317220855-9352-2-git-send-email-levinsasha928@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 28, 2011 at 05:40:55PM +0300, Sasha Levin wrote:
> This patch prevents a NULL dereference when the user has passed a length
> longer than an actual buffer to virtio-net.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: virtualization@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Cc: kvm@vger.kernel.org
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  drivers/net/virtio_net.c |   12 +++++++++++-
>  1 files changed, 11 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index bde0dec..4a53d2a 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -208,12 +208,22 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
>  		return NULL;
>  	}
>  
> -	while (len) {
> +	while (len && page) {

I think if (unlikely(!page))
		goto err_page;

would make the logic clearer. But see below

>  		set_skb_frag(skb, page, offset, &len);
>  		page = (struct page *)page->private;
>  		offset = 0;
>  	}
>  
> +	/*
> +	 * This is the case where we ran out of pages in our linked list, but
> +	 * supposedly have more data to read.
> +	 */	
> +	if (len > 0) {
> +		pr_debug("%s: missing data to assemble skb\n", skb->dev->name);
> +		dev_kfree_skb(skb);
> +		return NULL;
> +	}
> +
>  	if (page)
>  		give_pages(vi, page);
>

I thought about this some more. If length was too large host is
right now writing into pages that we have freed.
That is very bad, and I don't know what do do with it,
really not worth prettifying that IMO, NULL pointer is the least of our
worries.

But, with mergeable buffers at least, and that is the main mode anyway,
there is always a single page per buf, right?
So I think we should change the code,
and for mergeable buffers we shall only verify that
length <= PAGE_SIZE.

IOW copy a bit of code from page_to_skb(vi, page, len)
to receive_mergeable, maybe add a common function
if we need to avoid duplication.

  
> -- 
> 1.7.6.1
