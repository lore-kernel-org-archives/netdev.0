From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 0/5] Add driver bpf hook for early packet drop
Date: Mon, 4 Apr 2016 11:10:42 -0700
Message-ID: <20160404181040.GA68392@ast-mbp.thefacebook.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <CALx6S37y8+kFh=04cceSpLWZMHkanwWREgoVKc7Edmyhe3qvzg@mail.gmail.com>
 <20160403054103.GB21980@gmail.com>
 <20160404094846.4df8defc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ogerlitz@mellanox.com, Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34949 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbcDDSKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 14:10:48 -0400
Received: by mail-pf0-f173.google.com with SMTP id n1so44312123pfn.2
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 11:10:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160404094846.4df8defc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2016 at 09:48:46AM +0200, Jesper Dangaard Brouer wrote:
> On Sat, 2 Apr 2016 22:41:04 -0700
> Brenden Blanco <bblanco@plumgrid.com> wrote:
> 
> > On Sat, Apr 02, 2016 at 12:47:16PM -0400, Tom Herbert wrote:
> >
> > > Very nice! Do you think this hook will be sufficient to implement a
> > > fast forward patch also?
> 
> (DMA experts please verify and correct me!)
> 
> One of the gotchas is how DMA sync/unmap works.  For forwarding you
> need to modify the headers.  The DMA sync API (DMA_FROM_DEVICE) specify
> that the data is to be _considered_ read-only.  AFAIK you can write into
> the data, BUT on DMA_unmap the API/DMA-engine is allowed to overwrite
> data... note on most archs the DMA_unmap does not overwrite.
> 
> This DMA issue should not block the work on a hook for early packet drop.
> Maybe we should add a flag option, that can specify to the hook if the
> packet read-only? (e.g. if driver use page-fragments and DMA_sync)
> 
> 
> We should have another track/thread on how to solve the DMA issue:
> I see two solutions.
> 
> Solution 1: Simply use a "full" page per packet and do the DMA_unmap.
> This result in a slowdown on arch's with expensive DMA-map/unmap.  And
> we stress the page allocator more (can be solved with a page-pool-cache).
> Eric will not like this due to memory usage, but we can just add a
> "copy-break" step for normal stack hand-off.
> 
> Solution 2: (Due credit to Alex Duyck, this idea came up while
> discussing issue with him).  Remember DMA_sync'ed data is only
> considered read-only, because the DMA_unmap can be destructive.  In many
> cases DMA_unmap is not.  Thus, we could take advantage of this, and
> allow modifying DMA sync'ed data on those DMA setups.

I bet on those device dma_sync is a noop as well.
In ndo_bpf_set we can check
if (sync_single_for_cpu != swiotlb_sync_single_for_cpu)
 return -ENOTSUPP;

to avoid all these problems altogether. We're doing this to have
as high as possible performance, so we have to sacrifice generality.

This BPF_PROG_TYPE_PHYS_DEV program type is only applicable to physical
ethernet networking device and the name clearly indicates that.
Devices like taps or veth will not have such ndo.
These are early architectural decisions that we have to make to
actually hit our performance targets.
This is not 'yet another hook in the stack'. We already have tc+cls_bpf
that is pretty fast, but it's generic and works with veth, taps, phys dev
and by design operates on skb.
The BPF_PROG_TYPE_PHYS_DEV is operating on dma buffer. Virtual devices
don't have dma buffers, so no ndo.
Probably the confusion is due to 'pseudo skb' name in the patches.
I guess we have to pick some other name.
