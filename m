From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH] bpf: cpumap micro-optimization in
 cpu_map_enqueue
Date: Wed, 1 Nov 2017 06:54:46 -0700
Message-ID: <bcee429e-2f51-b75e-62cb-798e023d0ceb@gmail.com>
References: <150953668583.30172.5069550217700139382.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:51954 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751511AbdKANy7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 09:54:59 -0400
Received: by mail-pf0-f194.google.com with SMTP id n14so2021069pfh.8
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 06:54:59 -0700 (PDT)
In-Reply-To: <150953668583.30172.5069550217700139382.stgit@firesoul>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2017 04:44 AM, Jesper Dangaard Brouer wrote:
> Discovered that the compiler laid-out asm code in suboptimal way
> when studying perf report during benchmarking of cpumap. Help
> the compiler by the marking unlikely code paths.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  kernel/bpf/cpumap.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/bpf/cpumap.c b/kernel/bpf/cpumap.c
> index 86e29cbf7827..ce5b669003b2 100644
> --- a/kernel/bpf/cpumap.c
> +++ b/kernel/bpf/cpumap.c
> @@ -208,7 +208,7 @@ static struct xdp_pkt *convert_to_xdp_pkt(struct xdp_buff *xdp)
>  	headroom = xdp->data - xdp->data_hard_start;
>  	metasize = xdp->data - xdp->data_meta;
>  	metasize = metasize > 0 ? metasize : 0;
> -	if ((headroom - metasize) < sizeof(*xdp_pkt))
> +	if (unlikely((headroom - metasize) < sizeof(*xdp_pkt)))
>  		return NULL;
>  
>  	/* Store info in top of packet */
> @@ -656,7 +656,7 @@ int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
>  	struct xdp_pkt *xdp_pkt;
>  
>  	xdp_pkt = convert_to_xdp_pkt(xdp);
> -	if (!xdp_pkt)
> +	if (unlikely(!xdp_pkt))
>  		return -EOVERFLOW;
>  
>  	/* Info needed when constructing SKB on remote CPU */
> 

Seems OK to me, just curious is this noticeable at pps benchmarks?

Acked-by: John Fastabend <john.fastabend@gmail.com>
