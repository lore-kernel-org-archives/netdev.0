From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Tue, 5 Apr 2016 15:06:49 -0700
Message-ID: <20160405220647.GA95458@ast-mbp.thefacebook.com>
References: <57022A85.6040002@iogearbox.net>
 <20160404150700.1456ae80@redhat.com>
 <57026DFA.3090201@iogearbox.net>
 <CALx6S37aK79AbkUPBFTHkonUziSb7A1KV47vnG1OgciPD2qXcA@mail.gmail.com>
 <20160404171227.1f862cb1@redhat.com>
 <20160404152948.GA495@gmail.com>
 <57029127.3040303@gmail.com>
 <20160404161720.GB495@gmail.com>
 <20160404200032.GA69842@ast-mbp.thefacebook.com>
 <20160405112905.66b84e13@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ogerlitz@mellanox.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33532 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759952AbcDEWGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 18:06:54 -0400
Received: by mail-pf0-f172.google.com with SMTP id 184so19142379pff.0
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 15:06:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160405112905.66b84e13@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2016 at 11:29:05AM +0200, Jesper Dangaard Brouer wrote:
> > 
> > Of course, there are other pieces to accelerate:
> >  12.71%  ksoftirqd/1    [mlx4_en]         [k] mlx4_en_alloc_frags
> >   6.87%  ksoftirqd/1    [mlx4_en]         [k] mlx4_en_free_frag
> >   4.20%  ksoftirqd/1    [kernel.vmlinux]  [k] get_page_from_freelist
> >   4.09%  swapper        [mlx4_en]         [k] mlx4_en_process_rx_cq
> > and I think Jesper's work on batch allocation is going help that a lot.
> 
> Actually, it looks like all of this "overhead" comes from the page
> alloc/free (+ dma unmap/map). We would need a page-pool recycle
> mechanism to solve/remove this overhead.  For the early drop case we
> might be able to hack recycle the page directly in the driver (and also
> avoid dma_unmap/map cycle).

Exactly. A cache of allocated and mapped pages will help a lot both drop
and redirect use cases. After tx completion we can recycle still mmaped
page into the cache (need to make sure to map them PCI_DMA_BIDIRECTIONAL)
and rx can refill the ring with it. For load balancer steady state
we won't have any calls to page allocator and dma.
Being able to do cheap percpu pool like this is a huge advantage
that any kernel bypass cannot have. I'm pretty sure it will be
possible to avoid local_cmpxchg as well.
