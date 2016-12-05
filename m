From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Mon, 5 Dec 2016 08:35:33 +0100
Message-ID: <20161205083533.1467e329@redhat.com>
References: <1480821446-4122277-1-git-send-email-kafai@fb.com>
        <1480821446-4122277-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>, brouer@redhat.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55014 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750785AbcLEHfj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 02:35:39 -0500
In-Reply-To: <1480821446-4122277-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 3 Dec 2016 19:17:23 -0800 Martin KaFai Lau <kafai@fb.com> wrote:

> This patch allows XDP prog to extend/remove the packet
> data at the head (like adding or removing header).  It is
> done by adding a new XDP helper bpf_xdp_adjust_head().
> 
> It also renames bpf_helper_changes_skb_data() to
> bpf_helper_changes_pkt_data() to better reflect
> that XDP prog does not work on skb.
> 
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---
[...]
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 56b43587d200..ccef948cf58a 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2234,7 +2234,34 @@ static const struct bpf_func_proto bpf_skb_change_head_proto = {
>  	.arg3_type	= ARG_ANYTHING,
>  };
>  
> -bool bpf_helper_changes_skb_data(void *func)
> +BPF_CALL_2(bpf_xdp_adjust_head, struct xdp_buff *, xdp, int, offset)
> +{
> +	/* Both mlx4 and mlx5 driver align each packet to PAGE_SIZE when
> +	 * XDP prog is set.
> +	 * If the above is not true for the other drivers to support
> +	 * bpf_xdp_adjust_head, struct xdp_buff can be extended.
> +	 */
> +	unsigned long addr = (unsigned long)xdp->data & PAGE_MASK;
> +	void *data_hard_start = (void *)addr;
> +	void *data = xdp->data + offset;
> +
> +	if (unlikely(data < data_hard_start || data > xdp->data_end - ETH_HLEN))
> +		return -EINVAL;
> +
> +	xdp->data = data;
> +
> +	return 0;
> +}

Thanks for adjusting this, I like Daniel's suggestion.

For this patch:

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

As it still looks like 3/4 need some adjustments based on Saeed's
comments.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
