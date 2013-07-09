From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 2/2] macvtap: correctly linearize skb when zerocopy
 is used
Date: Tue, 9 Jul 2013 13:35:14 +0300
Message-ID: <20130709103514.GC14321@redhat.com>
References: <1373364651-10474-1-git-send-email-jasowang@redhat.com>
 <1373364651-10474-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1373364651-10474-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 09, 2013 at 06:10:51PM +0800, Jason Wang wrote:
> Userspace may produce vectors greater than MAX_SKB_FRAGS. When we try to
> linearize parts of the skb to let the rest of iov to be fit in
> the frags, we need count copylen into linear when calling macvtap_alloc_skb()
> instead of partly counting it into data_len. Since this breaks
> zerocopy_sg_from_iovec() since its inner counter assumes nr_frags should
> be zero at beginning. This cause nr_frags to be increased wrongly without
> setting the correct frags.
> 
> This bug were introduced from b92946e2919134ebe2a4083e4302236295ea2a73
> (macvtap: zerocopy: validate vectors before building skb).
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> This patch is needed for stable.
> ---
>  drivers/net/macvtap.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index f2c4a3b..b213020 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -770,7 +770,8 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  		copylen = len;
>  
>  	skb = macvtap_alloc_skb(&q->sk, NET_IP_ALIGN, copylen,
> -				vnet_hdr.hdr_len, noblock, &err);
> +				zerocopy ? copylen : vnet_hdr.hdr_len,
> +				noblock, &err);
>  	if (!skb)
>  		goto err;

Same comment as for tun - let's add code for the if statement above.
Thanks!

> -- 
> 1.7.1
