From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH v2 net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Tue, 6 Dec 2016 09:35:31 -0800
Message-ID: <5846F6E3.2040808@gmail.com>
References: <1480821446-4122277-1-git-send-email-kafai@fb.com>
 <1480821446-4122277-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33367 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754044AbcLFRfr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 12:35:47 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so20473179pgd.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 09:35:46 -0800 (PST)
In-Reply-To: <1480821446-4122277-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-03 07:17 PM, Martin KaFai Lau wrote:
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
> +

Sorry for the delay but I don't like the assumptions being made here
with regards to page alignment and free space.

Instead of taking the offset from PAGE_MASK how about adding a pointer
to xdp_buff so that we get,

 struct xdp_buff {
 	void *data;
	void *data_start;
	void *data_end;
 };

This gives the headroom explicitly in the data structure. This way we
can handle non-paged aligned usages and also some of the drivers are
putting metadata (descriptors) at the front of the page. With this
patch we could stomp on that metadata with the above we avoid that
problem altogether.

Thanks,
John
