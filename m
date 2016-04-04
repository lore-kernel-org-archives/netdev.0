From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 0/5] Add driver bpf hook for early packet drop
Date: Mon, 4 Apr 2016 09:48:46 +0200
Message-ID: <20160404094846.4df8defc@redhat.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	<CALx6S37y8+kFh=04cceSpLWZMHkanwWREgoVKc7Edmyhe3qvzg@mail.gmail.com>
	<20160403054103.GB21980@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	gerlitz@mellanox.com, Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>, brouer@redhat.com,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47108 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932079AbcDDHsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 03:48:53 -0400
In-Reply-To: <20160403054103.GB21980@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2 Apr 2016 22:41:04 -0700
Brenden Blanco <bblanco@plumgrid.com> wrote:

> On Sat, Apr 02, 2016 at 12:47:16PM -0400, Tom Herbert wrote:
>
> > Very nice! Do you think this hook will be sufficient to implement a
> > fast forward patch also?

(DMA experts please verify and correct me!)

One of the gotchas is how DMA sync/unmap works.  For forwarding you
need to modify the headers.  The DMA sync API (DMA_FROM_DEVICE) specify
that the data is to be _considered_ read-only.  AFAIK you can write into
the data, BUT on DMA_unmap the API/DMA-engine is allowed to overwrite
data... note on most archs the DMA_unmap does not overwrite.

This DMA issue should not block the work on a hook for early packet drop.
Maybe we should add a flag option, that can specify to the hook if the
packet read-only? (e.g. if driver use page-fragments and DMA_sync)


We should have another track/thread on how to solve the DMA issue:
I see two solutions.

Solution 1: Simply use a "full" page per packet and do the DMA_unmap.
This result in a slowdown on arch's with expensive DMA-map/unmap.  And
we stress the page allocator more (can be solved with a page-pool-cache).
Eric will not like this due to memory usage, but we can just add a
"copy-break" step for normal stack hand-off.

Solution 2: (Due credit to Alex Duyck, this idea came up while
discussing issue with him).  Remember DMA_sync'ed data is only
considered read-only, because the DMA_unmap can be destructive.  In many
cases DMA_unmap is not.  Thus, we could take advantage of this, and
allow modifying DMA sync'ed data on those DMA setups.


> That is the goal, but more work needs to be done of course. It won't be
> possible with just a single pseudo skb, the driver will need a fast
> way to get batches of pseudo skbs (per core?) through from rx to tx.
> In mlx4 for instance, either the skb needs to be much more complete
> to be handled from the start of mlx4_en_xmit(), or that function
> would need to be split so that the fast tx could start midway through.
> 
> Or, skb allocation just gets much faster. Then it should be pretty
> straightforward.

With the bulking SLUB API, we can reduce the bare kmem_cache_alloc+free
cost per SKB from 90 cycles to 27 cycles.  It is good, but for really
fast forwarding it would be good to avoid allocating any extra data
structures.  We just want to move a RX packet-page to a TX ring queue.

Maybe the 27 cycles kmem_cache/slab cost is considered "fast-enough",
for what we gain in ease of implementation.  The real expensive part of
the SKB process is memset/clearing the SKB.  Which the fast forward
use-case could avoid.  Splitting the SKB alloc and clearing part would
be a needed first step.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
