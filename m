From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Sat, 3 Dec 2016 16:24:13 +0100
Message-ID: <20161203162413.5f305f9f@redhat.com>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
        <1480721013-1047541-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49172 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752111AbcLCPfD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 10:35:03 -0500
In-Reply-To: <1480721013-1047541-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Dec 2016 15:23:30 -0800
Martin KaFai Lau <kafai@fb.com> wrote:

> -bool bpf_helper_changes_skb_data(void *func)
> +BPF_CALL_2(bpf_xdp_adjust_head, struct xdp_buff *, xdp, int, offset)
> +{
> +	/* Both mlx4 and mlx5 driver align each packet to PAGE_SIZE when
> +	 * XDP prog is set.
> +	 * If the above is not true for the other drivers to support
> +	 * bpf_xdp_adjust_head, struct xdp_buff can be extended.
> +	 */
> +	void *head = (void *)((unsigned long)xdp->data & PAGE_MASK);
> +	void *new_data = xdp->data + offset;
> +
> +	if (new_data < head || new_data >= xdp->data_end)
> +		/* The packet length must be >=1 */
> +		return -EINVAL;
> +
> +	xdp->data = new_data;
> +
> +	return 0;
> +}

First time I read this code, I was about to complain about you didn't
use XDP_PACKET_HEADROOM in your boundary check.  But then I noticed the
PAGE_MASK.  If you rename "head" to "page_boundary" or "page_start"
then IMHO the code would be more readable.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
