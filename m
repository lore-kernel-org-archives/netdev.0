From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH 4/5] net: new XDP feature for reading HW
 rxhash from drivers
Date: Sun, 21 May 2017 17:55:50 +0200
Message-ID: <20170521175550.762b2cf8@redhat.com>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
        <149512210827.14733.13997041998775151648.stgit@firesoul>
        <20170520030750.c2b55oqdms5n764c@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>, netdev@vger.kernel.org,
        brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34880 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755073AbdEUPz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 11:55:57 -0400
In-Reply-To: <20170520030750.c2b55oqdms5n764c@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 May 2017 20:07:52 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Thu, May 18, 2017 at 05:41:48PM +0200, Jesper Dangaard Brouer wrote:
> >  
> > +/* XDP rxhash have an associated type, which is related to the RSS
> > + * (Receive Side Scaling) standard, but NIC HW have different mapping
> > + * and support. Thus, create mapping that is interesting for XDP.  XDP
> > + * would primarly want insight into L3 and L4 protocol info.
> > + *
> > + * TODO: Likely need to get extended with "L3_IPV6_EX" due RSS standard
> > + *
> > + * The HASH_TYPE will be returned from bpf helper as the top 32-bit of
> > + * the 64-bit rxhash (internally type stored in xdp_buff->flags).
> > + */
> > +#define XDP_HASH(x)		((x) & ((1ULL << 32)-1))
> > +#define XDP_HASH_TYPE(x)	((x) >> 32)
> > +
> > +#define XDP_HASH_TYPE_L3_SHIFT	0
> > +#define XDP_HASH_TYPE_L3_BITS	3
> > +#define XDP_HASH_TYPE_L3_MASK	((1ULL << XDP_HASH_TYPE_L3_BITS)-1)
> > +#define XDP_HASH_TYPE_L3(x)	((x) & XDP_HASH_TYPE_L3_MASK)
> > +enum {
> > +	XDP_HASH_TYPE_L3_IPV4 = 1,
> > +	XDP_HASH_TYPE_L3_IPV6,
> > +};
> > +
> > +#define XDP_HASH_TYPE_L4_SHIFT	XDP_HASH_TYPE_L3_BITS
> > +#define XDP_HASH_TYPE_L4_BITS	5
> > +#define XDP_HASH_TYPE_L4_MASK						\
> > +	(((1ULL << XDP_HASH_TYPE_L4_BITS)-1) << XDP_HASH_TYPE_L4_SHIFT)
> > +#define XDP_HASH_TYPE_L4(x)	((x) & XDP_HASH_TYPE_L4_MASK)
> > +enum {
> > +	_XDP_HASH_TYPE_L4_TCP = 1,
> > +	_XDP_HASH_TYPE_L4_UDP,
> > +};
> > +#define XDP_HASH_TYPE_L4_TCP (_XDP_HASH_TYPE_L4_TCP << XDP_HASH_TYPE_L4_SHIFT)
> > +#define XDP_HASH_TYPE_L4_UDP (_XDP_HASH_TYPE_L4_UDP << XDP_HASH_TYPE_L4_SHIFT)  
> 
> imo this is dangerous territory.
> As far as I can see this information doesn't exist in the current drivers at all
> and you're enabling it in the patch 5 via fancy:
> +       u32 ht = (mlx5_htype_l4_to_xdp[((cht & CQE_RSS_HTYPE_L4) >> 6)] | \
> +                 mlx5_htype_l3_to_xdp[((cht & CQE_RSS_HTYPE_IP) >> 2)]);
> 
> It's pretty cool that you've discovered this hidden mlx5 feature
> Did you find it in some hw spec ?

The Mellanox ConnectX-4/mlx5 spec is actually open, see:
[1] http://www.mellanox.com/page/products_dyn?product_family=204&mtag=connectx_4_en_card
and follow link to "Programming Manual (PRM)".


> And it looks useful to me, but

> 1. i'm worried that we'd be relying on something that mellanox didn't
>  implement in their drivers before. Was it tested and guarnteed to
>  exist in the future revisions of firmware? Is it cx4 or cx4-lx or cx5
>  feature?

It is not a hidden mlx5 or specific feature.  Due to the Microsoft RSS
standard/requirements[2] most NICs actually implement this.

[2] https://docs.microsoft.com/en-us/windows-hardware/drivers/network/rss-hashing-types


> 2. but the main concern that it is mellanox only feature. At least I cannot
> see anything like this in broadcom and intel nics

All the drivers I looked at have support for an RSS hash type.
Including Broadcom[3] and Intel. Just grep after NETIF_F_RXHASH, and
follow data-structs.  The Intel i40 NIC have the most elaborate rss type
system (it can e.g. tell if this was SCTP).

[3] http://elixir.free-electrons.com/linux/latest/source/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h#L4198
 
> In the very beginning we discussed that XDP programs should be as
> generic as possible and HW independent while at the same time we want
> to expose HW specific features to XDP programs.
>
> So I'm totally fine to expose this fancy hw hash and ipv4 vs v6 and
> tcp vs udp flags to xdp programs somehow, but I'm completely against
> making it into uapi.
> 
> How about exposing 'struct mlx5_cqe64 *' to XDP programs as-is?
> We can make sure that XDP program does read only access into it and
> it will see cqe->rss_hash_result, cqe->rss_hash_type and everything else
> in there, but this will not be uapi and it will be pretty obvious
> to program authors that their programs are vendor specific.

This sounds EXTREMELY dangerous to me... IHMO this will lead to vendor
lock-in.  As BPF program authors will become dependent on vendor
specific features, and their program are no longer portable to run on
other NICs.

How are you going to avoid vendor lock-in with this model?


> 'not uapi' here means that mellanox is free to change their HW descriptor
> and its contents as they wish.

Hmmm... IMHO directly exposing the HW descriptor to userspace, will
limit vendors ability to change its contents.


> Also no copies and bit conversions will be necessary, so the cost will
> be zero to programs that don't use it and we wouldn't need to change
> verifier to discover access to this stuff.

I'm not sure this would work out well, as we would need to keep the
CQE descriptor memory around longer.


The longer term plan with having RXHASH for XDP is to allow
implementing RPS (Receive Packet Steering) without touching packet
memory.  Which plays into my plans for XDP_REDIRECT to another CPU.
I guess, I'll go implement XDP_REDIRECT first, and then return back to
RXHASH when I need that feature (as I have the rxhash PoC code here).
RXHASH does have merits of its own, for e.g. flow-based XDP_TX
load-balancing (without touching memory).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
