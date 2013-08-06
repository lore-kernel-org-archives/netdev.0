From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH for 3.4 2/2] macvtap: do not zerocopy if iov needs more
 pages than MAX_SKB_FRAGS
Date: Tue, 6 Aug 2013 13:04:51 +0300
Message-ID: <20130806100451.GG11051@redhat.com>
References: <1375781359-5764-1-git-send-email-jasowang@redhat.com>
 <1375781359-5764-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5639 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754631Ab3HFKDO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 06:03:14 -0400
Content-Disposition: inline
In-Reply-To: <1375781359-5764-2-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 05:29:19PM +0800, Jason Wang wrote:
> commit ece793fcfc417b3925844be88a6a6dc82ae8f7c6 upstream.
> 
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
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/macvtap.c |   62 +++++++++++++++++++++++++++++-------------------
>  1 files changed, 37 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 5151f06..77ce8b2 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -642,6 +642,28 @@ static int macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
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
> @@ -688,31 +710,15 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
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
> @@ -724,9 +730,15 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  
>  	if (zerocopy)
>  		err = zerocopy_sg_from_iovec(skb, iv, vnet_hdr_len, count);
> -	else
> +	else {
>  		err = skb_copy_datagram_from_iovec(skb, 0, iv, vnet_hdr_len,
>  						   len);
> +		if (!err && m && m->msg_control) {
> +			struct ubuf_info *uarg = m->msg_control;
> +			uarg->callback(uarg);
> +		}
> +	}
> +
>  	if (err)
>  		goto err_kfree;
>  
> -- 
> 1.7.1
