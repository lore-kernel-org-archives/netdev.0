From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net V2 2/2] macvtap: do not zerocopy if iov needs more
 pages than MAX_SKB_FRAGS
Date: Fri, 19 Jul 2013 08:03:51 +0300
Message-ID: <20130719050351.GB8537@redhat.com>
References: <1374116116-43844-1-git-send-email-jasowang@redhat.com>
 <1374116116-43844-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1374116116-43844-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 18, 2013 at 10:55:16AM +0800, Jason Wang wrote:
> We try to linearize part of the skb when the number of iov is greater than
> MAX_SKB_FRAGS. This is not enough since each single vector may occupy more than
> one pages, so zerocopy_sg_fromiovec() may still fail and may break the guest
> network.
> 
> Solve this problem by calculate the pages needed for iov before trying to do
> zerocopy and switch to use copy instead of zerocopy if it needs more than
> MAX_SKB_FRAGS.
> 
> This is done through introducing a new helper to count the pages for iov, and
> call uarg->callback() manually when switching from zerocopy to copy to notify
> vhost.
> 
> We can do further optimization on top.
> 
> This bug were introduced from b92946e2919134ebe2a4083e4302236295ea2a73
> (macvtap: zerocopy: validate vectors before building skb).
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>


Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
> The patch is needed for -stable.
> Changes from V1:
> - remove the wrong comment
> ---
>  drivers/net/macvtap.c |   62 +++++++++++++++++++++++++++++-------------------
>  1 files changed, 37 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index a7c5654..a98fb0e 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -698,6 +698,28 @@ static int macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
>  	return 0;
>  }
>  
> +static unsigned long iov_pages(const struct iovec *iv, int offset,
> +			       unsigned long nr_segs)
> +{
> +	unsigned long seg, base;
> +	int pages = 0, len, size;
> +
> +	while (nr_segs && (offset >= iv->iov_len)) {
> +		offset -= iv->iov_len;
> +		++iv;
> +		--nr_segs;
> +	}
> +
> +	for (seg = 0; seg < nr_segs; seg++) {
> +		base = (unsigned long)iv[seg].iov_base + offset;
> +		len = iv[seg].iov_len - offset;
> +		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
> +		pages += size;
> +		offset = 0;
> +	}
> +
> +	return pages;
> +}
>  
>  /* Get packet from user space buffer */
>  static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
> @@ -744,31 +766,15 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  	if (unlikely(count > UIO_MAXIOV))
>  		goto err;
>  
> -	if (m && m->msg_control && sock_flag(&q->sk, SOCK_ZEROCOPY))
> -		zerocopy = true;
> -
> -	if (zerocopy) {
> -		/* Userspace may produce vectors with count greater than
> -		 * MAX_SKB_FRAGS, so we need to linearize parts of the skb
> -		 * to let the rest of data to be fit in the frags.
> -		 */
> -		if (count > MAX_SKB_FRAGS) {
> -			copylen = iov_length(iv, count - MAX_SKB_FRAGS);
> -			if (copylen < vnet_hdr_len)
> -				copylen = 0;
> -			else
> -				copylen -= vnet_hdr_len;
> -		}
> -		/* There are 256 bytes to be copied in skb, so there is enough
> -		 * room for skb expand head in case it is used.
> -		 * The rest buffer is mapped from userspace.
> -		 */
> -		if (copylen < vnet_hdr.hdr_len)
> -			copylen = vnet_hdr.hdr_len;
> -		if (!copylen)
> -			copylen = GOODCOPY_LEN;
> +	if (m && m->msg_control && sock_flag(&q->sk, SOCK_ZEROCOPY)) {
> +		copylen = vnet_hdr.hdr_len ? vnet_hdr.hdr_len : GOODCOPY_LEN;
>  		linear = copylen;
> -	} else {
> +		if (iov_pages(iv, vnet_hdr_len + copylen, count)
> +		    <= MAX_SKB_FRAGS)
> +			zerocopy = true;
> +	}
> +
> +	if (!zerocopy) {
>  		copylen = len;
>  		linear = vnet_hdr.hdr_len;
>  	}
> @@ -780,9 +786,15 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  
>  	if (zerocopy)
>  		err = zerocopy_sg_from_iovec(skb, iv, vnet_hdr_len, count);
> -	else
> +	else {
>  		err = skb_copy_datagram_from_iovec(skb, 0, iv, vnet_hdr_len,
>  						   len);
> +		if (!err && m && m->msg_control) {
> +			struct ubuf_info *uarg = m->msg_control;
> +			uarg->callback(uarg, false);
> +		}
> +	}
> +
>  	if (err)
>  		goto err_kfree;
>  
> -- 
> 1.7.1
