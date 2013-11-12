From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 1/2] tuntap: limit head length of skb allocated
Date: Tue, 12 Nov 2013 13:20:09 +0200
Message-ID: <20131112112008.GA28597@redhat.com>
References: <1384250577-20330-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanha@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4035 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214Ab3KLLRP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 06:17:15 -0500
Content-Disposition: inline
In-Reply-To: <1384250577-20330-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 12, 2013 at 06:02:56PM +0800, Jason Wang wrote:
> We currently use hdr_len as a hint of head length which is advertised by
> guest. But when guest advertise a very big value, it can lead to an 64K+
> allocating of kmalloc() which has a very high possibility of failure when host
> memory is fragmented or under heavy stress. The huge hdr_len also reduce the
> effect of zerocopy or even disable if a gso skb is linearized in guest.
> 
> To solves those issues, this patch introduces an upper limit (PAGE_SIZE) of the
> head, which guarantees an order 0 allocation each time.
> 
> Cc: Stefan Hajnoczi <stefanha@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
> The patch was needed for stable.
> ---
>  drivers/net/tun.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 7cb105c..5537b65 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -954,6 +954,11 @@ static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
>  	struct sock *sk = tfile->socket.sk;
>  	struct sk_buff *skb;
>  	int err;
> +	int good_linear = SKB_MAX_HEAD(prepad);
> +
> +	/* Don't use huge linear part */
> +	if (linear > good_linear)
> +		linear = good_linear;
>  
>  	/* Under a page?  Don't bother with paged skb. */
>  	if (prepad + len < PAGE_SIZE || !linear)
> -- 
> 1.8.3.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
