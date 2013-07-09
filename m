From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 1/2] tuntap: correctly linearize skb when zerocopy is
 used
Date: Tue, 9 Jul 2013 13:34:52 +0300
Message-ID: <20130709103452.GB14321@redhat.com>
References: <1373364651-10474-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28033 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611Ab3GIKdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jul 2013 06:33:39 -0400
Content-Disposition: inline
In-Reply-To: <1373364651-10474-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 09, 2013 at 06:10:50PM +0800, Jason Wang wrote:
> Userspace may produce vectors greater than MAX_SKB_FRAGS. When we try to
> linearize parts of the skb to let the rest of iov to be fit in
> the frags, we need count copylen into linear when calling tun_alloc_skb()
> instead of partly counting it into data_len. Since this breaks
> zerocopy_sg_from_iovec() since its inner counter assumes nr_frags should
> be zero at beginning. This cause nr_frags to be increased wrongly without
> setting the correct frags.
> 
> This bug were introduced from 0690899b4d4501b3505be069b9a687e68ccbe15b
> (tun: experimental zero copy tx support)
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> This patch is needed for stable.
> ---
>  drivers/net/tun.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 7eab5fc..01d5a86 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1109,7 +1109,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  	} else
>  		copylen = len;
>  
> -	skb = tun_alloc_skb(tfile, align, copylen, gso.hdr_len, noblock);
> +	skb = tun_alloc_skb(tfile, align, copylen,
> +			    zerocopy ? copylen : gso.hdr_len, noblock);
>  	if (IS_ERR(skb)) {
>  		if (PTR_ERR(skb) != -EAGAIN)
>  			tun->dev->stats.rx_dropped++;

Good catch, thanks. But let's add a new variable and
set it in the if statement above
instead of an extra branch here - not for performance but
because it's clearer this way.

> -- 
> 1.7.1
