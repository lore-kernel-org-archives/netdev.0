From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v2 net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Tue, 6 Dec 2016 10:52:30 -0800
Message-ID: <20161206185230.GB16682@kafai-mba.local>
References: <1480821446-4122277-1-git-send-email-kafai@fb.com>
 <1480821446-4122277-2-git-send-email-kafai@fb.com>
 <5846F6E3.2040808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "Saeed Mahameed" <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "Kernel Team" <kernel-team@fb.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49482 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751495AbcLFTKd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 14:10:33 -0500
Content-Disposition: inline
In-Reply-To: <5846F6E3.2040808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 06, 2016 at 09:35:31AM -0800, John Fastabend wrote:
> On 16-12-03 07:17 PM, Martin KaFai Lau wrote:
> > This patch allows XDP prog to extend/remove the packet
> > data at the head (like adding or removing header).  It is
> > done by adding a new XDP helper bpf_xdp_adjust_head().
> >
> > It also renames bpf_helper_changes_skb_data() to
> > bpf_helper_changes_pkt_data() to better reflect
> > that XDP prog does not work on skb.
> >
> > Acked-by: Alexei Starovoitov <ast@kernel.org>
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > ---
>
>
> [...]
>
> >
> > -bool bpf_helper_changes_skb_data(void *func)
> > +BPF_CALL_2(bpf_xdp_adjust_head, struct xdp_buff *, xdp, int, offset)
> > +{
> > +	/* Both mlx4 and mlx5 driver align each packet to PAGE_SIZE when
> > +	 * XDP prog is set.
> > +	 * If the above is not true for the other drivers to support
> > +	 * bpf_xdp_adjust_head, struct xdp_buff can be extended.
> > +	 */
> > +	unsigned long addr = (unsigned long)xdp->data & PAGE_MASK;
> > +	void *data_hard_start = (void *)addr;
> > +	void *data = xdp->data + offset;
> > +
> > +	if (unlikely(data < data_hard_start || data > xdp->data_end - ETH_HLEN))
> > +		return -EINVAL;
> > +
> > +	xdp->data = data;
> > +
> > +	return 0;
> > +}
> > +
>
> Sorry for the delay but I don't like the assumptions being made here
> with regards to page alignment and free space.
>
> Instead of taking the offset from PAGE_MASK how about adding a pointer
> to xdp_buff so that we get,
>
>  struct xdp_buff {
>  	void *data;
> 	void *data_end;
> 	void *data_start;
>  };
>
> This gives the headroom explicitly in the data structure. This way we
> can handle non-paged aligned usages and also some of the drivers are
> putting metadata (descriptors) at the front of the page. With this
> patch we could stomp on that metadata with the above we avoid that
> problem altogether.
Extending the xdp_buff like this was my first local attempt.  And
then I realized the assumption that mlx4/5 is making.  Since
there is no immediate need for this patch series and the xdp_buff
can always be extended later if needed without breaking
the xdp prog, I dropped the xdp_buff addition for now in this patch.

Sure, it will be done at the next spin.
