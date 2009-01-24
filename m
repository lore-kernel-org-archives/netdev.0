From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH] virtio_net: use correct accessors for scatterlists
Date: Sat, 24 Jan 2009 10:41:54 -0800
Message-ID: <20090124184154.GA18513@ovro.caltech.edu>
References: <20090124001053.GA20156@ovro.caltech.edu> <200901250010.11434.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Mark McLoughlin <markmc@redhat.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:44070 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281AbZAXSl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2009 13:41:56 -0500
Content-Disposition: inline
In-Reply-To: <200901250010.11434.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 25, 2009 at 12:10:10AM +1030, Rusty Russell wrote:
> On Saturday 24 January 2009 10:40:53 Ira Snyder wrote:
> > Without this fix, virtio_net makes incorrect usage of scatterlists. It sets
> > the end of the scatterlist chain after the first element, despite the fact
> > that more entries come after it.
> 
> Yes, but shouldn't you also be doing sg_mark_end() here somewhere if we're
> going to use this new sg mechanism?
> 

sg_init_table() and sg_init_one() have an sg_mark_end() inside them, so
the scatterlists are terminated at their last entry.

In the only case where the scatterlist has a single entry, we use
sg_init_one(), which is terminated correctly.

In all other cases, we use skb_to_sgvec(), which calls sg_mark_end().

In other words, they're all magically terminated at the right place. I
didn't even think about it until you mentioned it, but I just verified
that in every case, they get terminated correctly. So the patch is ok
as-is.

The only reason they can't be terminated early is that the for_each_sg()
loop in arch/x86/kernel/pci-nommu.c nommu_map_sg() gets a null pointer
for s, and then we oops. It doesn't check that the scatterlist ended
early. I'd argue that it is the definition of for_each_sg() that is
wrong, because it doesn't check for sg == NULL, which sg_next() returns
when you reach the end of the chain. I don't want to be changing core
kernel code, though.

> I despise the new scatterlist magic chaining no-typesafety crap too much to get around to doing the Right Thing, which is to change vq_ops->add_buf to take two (terminated) scatterlists instead of a sg array and two numbers.
> 

I didn't want to change the API. I'm comfortable with how virtio_net
works, but I haven't even tried to understand virtio_console or
virtio_blk yet.

The main problem I've run into is that the scatterlists are allocated on
the stack. Since I'm trying to do DMA transfers, I run dma_map_sg() on
them in add_buf(), and then I need to run dma_unmap_sg() on them in
get_buf(), after the DMA has completed. I've resorted to making copies
of the scatterlists.

Also, I have no idea how get()/set(), get_status()/set_status(), and
get_features()/finalize_features() are supposed to work. I'm going to
try and hook up two instances of virtio_net in memory, and see if I can
get them to communicate. Any pointers on that? :)

> But if you want to look at that... :)

Maybe later. I need to get something working first.

Thanks for the input.
Ira
