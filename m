From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Mon, 6 Jun 2011 07:15:07 -0400
Message-ID: <20110606111507.GA1000@hmsreliant.think-freely.org>
References: <4DE93422.3070000@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49523 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755746Ab1FFLP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 07:15:26 -0400
Content-Disposition: inline
In-Reply-To: <4DE93422.3070000@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 03, 2011 at 09:21:06PM +0200, Alexander Holler wrote:
> Hello,
> 
> I'm getting a oops in the bridge code in br_change_mtu() with
> 2.6.39.1. The patch below seems to fix that.
> 
> I'm not sure about the usage of dst_cow_metrics_generic() in
> fake_dst_ops, but after having a quick look at it seems to be ok to
> use that here.
> 
> Regards,
> 
> Alexander
> 
How did the flags of the dst entry on which we're callnig dst_entry_write_ptr
wind up getting the  READ_ONLY flag set on it?  I don't see how we'er falling
into that clause in which we call cow_metrics when we call dst_metric_set.  It
seems like that flag is set erroneously.  perhaps we should just update
fake_rtable.dst to have the correct flags?
Neil

> -----
> From 3c1d5951af73389798afeea672ec224e195b8e8d Mon Sep 17 00:00:00 2001
> From: Alexander Holler <holler@ahsoftware.de>
> Date: Fri, 3 Jun 2011 20:43:06 +0200
> Subject: [PATCH] bridge: add dst_cow_metrics_generic to fake_dst_ops
> 
> Commit 42923465fb8d025a2b5153f2e7ab1e6e1058bf00 does here what it
> should prevent, it introduces NULL a dereference.
> 
> The above commit uses dst_init_metrics() which sets the metrics as
> read only. As result br_change_mtu() dies in dst_metric_set()
> which calls dst_metrics_write_ptr() which calls
> dst->ops->cow_metrics() if the metrics are read only.
> ---
>  net/bridge/br_netfilter.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 5f9c091..de982a1 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -107,6 +107,7 @@ static void fake_update_pmtu(struct dst_entry
> *dst, u32 mtu)
>  static struct dst_ops fake_dst_ops = {
>         .family =               AF_INET,
>         .protocol =             cpu_to_be16(ETH_P_IP),
> +       .cow_metrics =          dst_cow_metrics_generic,
>         .update_pmtu =          fake_update_pmtu,
>  };
> 
> -- 
> 1.7.3.4
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
