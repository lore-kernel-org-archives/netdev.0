From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC net-next PATCH 4/5] net: new XDP feature for reading HW
 rxhash from drivers
Date: Sun, 21 May 2017 20:21:31 -0700
Message-ID: <20170522032129.kjxf465zbj6dfoaw@ast-mbp>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
 <149512210827.14733.13997041998775151648.stgit@firesoul>
 <20170520030750.c2b55oqdms5n764c@ast-mbp>
 <20170521175550.762b2cf8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <borkmann@iogearbox.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36163 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750930AbdEVDVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 23:21:35 -0400
Received: by mail-pf0-f194.google.com with SMTP id n23so16782468pfb.3
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 20:21:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170521175550.762b2cf8@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 21, 2017 at 05:55:50PM +0200, Jesper Dangaard Brouer wrote:
> > And it looks useful to me, but
> 
> > 1. i'm worried that we'd be relying on something that mellanox didn't
> >  implement in their drivers before. Was it tested and guarnteed to
> >  exist in the future revisions of firmware? Is it cx4 or cx4-lx or cx5
> >  feature?
> 
> It is not a hidden mlx5 or specific feature.  Due to the Microsoft RSS
> standard/requirements[2] most NICs actually implement this.
> 
> [2] https://docs.microsoft.com/en-us/windows-hardware/drivers/network/rss-hashing-types

...

> > 2. but the main concern that it is mellanox only feature. At least I cannot
> > see anything like this in broadcom and intel nics
> 
> All the drivers I looked at have support for an RSS hash type.
> Including Broadcom[3] and Intel. Just grep after NETIF_F_RXHASH, and
> follow data-structs.  The Intel i40 NIC have the most elaborate rss type
> system (it can e.g. tell if this was SCTP).
> 
> [3] http://elixir.free-electrons.com/linux/latest/source/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h#L4198

yes and bnxt too.
msft spec requires RSS to be configured in these different ways, but
it doesn't mean that HW descriptor will have 'is_v4' and 'is_v6' bits set.
imo this is mlx specific behavior.
If you want to piggy back on msft spec and make linux rss to be configurable
the same way, I guess that's fine, but imo it's orthogonal to xdp.

> > How about exposing 'struct mlx5_cqe64 *' to XDP programs as-is?
> > We can make sure that XDP program does read only access into it and
> > it will see cqe->rss_hash_result, cqe->rss_hash_type and everything else
> > in there, but this will not be uapi and it will be pretty obvious
> > to program authors that their programs are vendor specific.
> 
> This sounds EXTREMELY dangerous to me... IHMO this will lead to vendor
> lock-in.  As BPF program authors will become dependent on vendor
> specific features, and their program are no longer portable to run on
> other NICs.
> 
> How are you going to avoid vendor lock-in with this model?

It looked to me that that was the intent of your patch set, hence
counter proposal to make it much simpler.
I'm not going to use vendor specific features. The proposal
to expose hw rx descriptor as-is is for people who desperately want
that info without burdening core xdp with it.

> > 'not uapi' here means that mellanox is free to change their HW descriptor
> > and its contents as they wish.
> 
> Hmmm... IMHO directly exposing the HW descriptor to userspace, will
> limit vendors ability to change its contents.

kprobes can already look at hw rx descriptor.
if somebody really wants to look into it, they have a way to do it already:
- add kprobe to mlx5e_handle_rx_cqe(), look into cqe, store the outcome on a side
- use that info in the xdp program
All I proposed is to make it first class citizen and avoid kprobe.
