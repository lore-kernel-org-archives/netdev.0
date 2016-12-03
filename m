From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 1/4] bpf: xdp: Allow head adjustment in XDP prog
Date: Sat, 3 Dec 2016 11:32:49 -0800
Message-ID: <20161203193249.GC70461@kafai-mba.local>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
 <1480721013-1047541-2-git-send-email-kafai@fb.com>
 <20161203162413.5f305f9f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36228 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750774AbcLCUUD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 15:20:03 -0500
Content-Disposition: inline
In-Reply-To: <20161203162413.5f305f9f@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 03, 2016 at 04:24:13PM +0100, Jesper Dangaard Brouer wrote:
> On Fri, 2 Dec 2016 15:23:30 -0800
> Martin KaFai Lau <kafai@fb.com> wrote:
>
> > -bool bpf_helper_changes_skb_data(void *func)
> > +BPF_CALL_2(bpf_xdp_adjust_head, struct xdp_buff *, xdp, int, offset)
> > +{
> > +	/* Both mlx4 and mlx5 driver align each packet to PAGE_SIZE when
> > +	 * XDP prog is set.
> > +	 * If the above is not true for the other drivers to support
> > +	 * bpf_xdp_adjust_head, struct xdp_buff can be extended.
> > +	 */
> > +	void *head = (void *)((unsigned long)xdp->data & PAGE_MASK);
> > +	void *new_data = xdp->data + offset;
> > +
> > +	if (new_data < head || new_data >= xdp->data_end)
> > +		/* The packet length must be >=1 */
> > +		return -EINVAL;
> > +
> > +	xdp->data = new_data;
> > +
> > +	return 0;
> > +}
>
> First time I read this code, I was about to complain about you didn't
> use XDP_PACKET_HEADROOM in your boundary check.  But then I noticed the
> PAGE_MASK.  If you rename "head" to "page_boundary" or "page_start"
> then IMHO the code would be more readable.
bpf_xdp_adjust_head() could be called multiple times.  Hence,
XDP_PACKET_HEADROOM is not used in the boundary check.

My thinking is "head" here can closely resemble the meaning of
skb->head as a boundary.  I think missing the info on
what head it is could be the confusing part.

Instead of skb boundary (there is no skb here) or
page boundary (other future XDP driver may not align like mlx4/5),
I think may be "pkt_head" can give more clarity here and also
for furture XDP-capble driver?
