From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC net-next PATCH 4/5] net: new XDP feature for reading HW
 rxhash from drivers
Date: Fri, 19 May 2017 20:07:52 -0700
Message-ID: <20170520030750.c2b55oqdms5n764c@ast-mbp>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
 <149512210827.14733.13997041998775151648.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33620 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751816AbdETDH4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 23:07:56 -0400
Received: by mail-pf0-f181.google.com with SMTP id e193so47671500pfh.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 20:07:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <149512210827.14733.13997041998775151648.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 05:41:48PM +0200, Jesper Dangaard Brouer wrote:
>  
> +/* XDP rxhash have an associated type, which is related to the RSS
> + * (Receive Side Scaling) standard, but NIC HW have different mapping
> + * and support. Thus, create mapping that is interesting for XDP.  XDP
> + * would primarly want insight into L3 and L4 protocol info.
> + *
> + * TODO: Likely need to get extended with "L3_IPV6_EX" due RSS standard
> + *
> + * The HASH_TYPE will be returned from bpf helper as the top 32-bit of
> + * the 64-bit rxhash (internally type stored in xdp_buff->flags).
> + */
> +#define XDP_HASH(x)		((x) & ((1ULL << 32)-1))
> +#define XDP_HASH_TYPE(x)	((x) >> 32)
> +
> +#define XDP_HASH_TYPE_L3_SHIFT	0
> +#define XDP_HASH_TYPE_L3_BITS	3
> +#define XDP_HASH_TYPE_L3_MASK	((1ULL << XDP_HASH_TYPE_L3_BITS)-1)
> +#define XDP_HASH_TYPE_L3(x)	((x) & XDP_HASH_TYPE_L3_MASK)
> +enum {
> +	XDP_HASH_TYPE_L3_IPV4 = 1,
> +	XDP_HASH_TYPE_L3_IPV6,
> +};
> +
> +#define XDP_HASH_TYPE_L4_SHIFT	XDP_HASH_TYPE_L3_BITS
> +#define XDP_HASH_TYPE_L4_BITS	5
> +#define XDP_HASH_TYPE_L4_MASK						\
> +	(((1ULL << XDP_HASH_TYPE_L4_BITS)-1) << XDP_HASH_TYPE_L4_SHIFT)
> +#define XDP_HASH_TYPE_L4(x)	((x) & XDP_HASH_TYPE_L4_MASK)
> +enum {
> +	_XDP_HASH_TYPE_L4_TCP = 1,
> +	_XDP_HASH_TYPE_L4_UDP,
> +};
> +#define XDP_HASH_TYPE_L4_TCP (_XDP_HASH_TYPE_L4_TCP << XDP_HASH_TYPE_L4_SHIFT)
> +#define XDP_HASH_TYPE_L4_UDP (_XDP_HASH_TYPE_L4_UDP << XDP_HASH_TYPE_L4_SHIFT)

imo this is dangerous territory.
As far as I can see this information doesn't exist in the current drivers at all
and you're enabling it in the patch 5 via fancy:
+       u32 ht = (mlx5_htype_l4_to_xdp[((cht & CQE_RSS_HTYPE_L4) >> 6)] | \
+                 mlx5_htype_l3_to_xdp[((cht & CQE_RSS_HTYPE_IP) >> 2)]);

It's pretty cool that you've discovered this hidden mlx5 feature
Did you find it in some hw spec ?
And it looks useful to me, but
1. i'm worried that we'd be relying on something that mellanox didn't
 implement in their drivers before. Was it tested and guarnteed to exist
 in the future revisions of firmware? Is it cx4 or cx4-lx or cx5 feature?
2. but the main concern that it is mellanox only feature. At least I cannot
see anything like this in broadcom and intel nics

In the very beginning we discussed that XDP programs should be as generic as
possible and HW independent while at the same time we want to expose HW
specific features to XDP programs.
So I'm totally fine to expose this fancy hw hash and ipv4 vs v6 and tcp vs udp
flags to xdp programs somehow, but I'm completely against making it into uapi.

How about exposing 'struct mlx5_cqe64 *' to XDP programs as-is?
We can make sure that XDP program does read only access into it and
it will see cqe->rss_hash_result, cqe->rss_hash_type and everything else
in there, but this will not be uapi and it will be pretty obvious
to program authors that their programs are vendor specific.
'not uapi' here means that mellanox is free to change their HW descriptor
and its contents as they wish.
Also no copies and bit conversions will be necessary, so the cost will
be zero to programs that don't use it and we wouldn't need to change
verifier to discover access to this stuff.

Note that bpf programs already have access to all in-kernel data structures
on the tracing side, so this is nothing new and tracing program authors
got used to structures changing from kernel to kernel.
XDP program authors can do the same for vendor specific bits while we
keep core XDP uapi generic across all nics.
