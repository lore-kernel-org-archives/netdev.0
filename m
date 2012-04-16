From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/6] macvtap: zerocopy: fix truesize underestimation
Date: Mon, 16 Apr 2012 10:14:23 +0300
Message-ID: <20120416071423.GA25396@redhat.com>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
 <20120416060758.14140.40252.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120416060758.14140.40252.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 16, 2012 at 02:07:59PM +0800, Jason Wang wrote:
> As the skb fragment were pinned/built from user pages, we should
> account the page instead of length for truesize.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

I'm not sure this is right: the skb does *not* consume the
whole page, userspace uses the rest of the page
for other skbs. So we'll end up accounting for the
same page twice.
Eric, what's the right thing to do here in your opinion?

> ---
>  drivers/net/macvtap.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index bd4a70d..7cb2684 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -519,6 +519,7 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
>  		struct page *page[MAX_SKB_FRAGS];
>  		int num_pages;
>  		unsigned long base;
> +		unsigned long truesize;
>  
>  		len = from->iov_len - offset;
>  		if (!len) {
> @@ -533,10 +534,11 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
>  		    (num_pages > MAX_SKB_FRAGS - skb_shinfo(skb)->nr_frags))
>  			/* put_page is in skb free */
>  			return -EFAULT;
> +		truesize = size * PAGE_SIZE;
>  		skb->data_len += len;
>  		skb->len += len;
> -		skb->truesize += len;
> -		atomic_add(len, &skb->sk->sk_wmem_alloc);
> +		skb->truesize += truesize;
> +		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
>  		while (len) {
>  			int off = base & ~PAGE_MASK;
>  			int size = min_t(int, len, PAGE_SIZE - off);
