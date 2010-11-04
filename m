From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: Fix queue full check
Date: Thu, 4 Nov 2010 18:45:44 +0200
Message-ID: <20101104164544.GB1038@redhat.com>
References: <20101028051036.25340.23442.sendpatchset@krkumar2.in.ibm.com>
 <201010292017.25099.rusty@rustcorp.com.au>
 <OF30574F6E.113EC5F4-ON652577CB.0037DAB5-652577CB.003BACE8@in.ibm.com>
 <201010292158.40411.rusty@rustcorp.com.au>
 <20101102161730.GA32311@redhat.com>
 <20101104122424.GA29830@redhat.com>
 <OF9196A33D.75E1F25E-ON652577D1.0057D889-652577D1.00592104@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>, yvugenfi@redhat.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13465 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457Ab0KDQp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 12:45:58 -0400
Content-Disposition: inline
In-Reply-To: <OF9196A33D.75E1F25E-ON652577D1.0057D889-652577D1.00592104@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 04, 2010 at 09:47:04PM +0530, Krishna Kumar2 wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 11/04/2010 05:54:24 PM:
> 
> > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >
> > I thought about this some more.  I think the original
> > code is actually correct in returning ENOSPC: indirect
> > buffers are nice, but it's a mistake
> > to rely on them as a memory allocation might fail.
> >
> > And if you look at virtio-net, it is dropping packets
> > under memory pressure which is not really a happy outcome:
> > the packet will get freed, reallocated and we get another one,
> > adding pressure on the allocator instead of releasing it
> > until we free up some buffers.
> >
> > So I now think we should calculate the capacity
> > assuming non-indirect entries, and if we manage to
> > use indirect, all the better.
> >
> > So below is what I propose now - as a replacement for
> > my original patch.  Krishna Kumar, Rusty, what do you think?
> >
> > Separately I'm also considering moving the
> >    if (vq->num_free < out + in)
> > check earlier in the function to keep all users honest,
> > but need to check what the implications are for e.g. block.
> > Thoughts on this?
> 
> This looks like the right thing to do.  Besides this, I
> think virtio-net still needs to remove check for ENOMEM?

Yes, the only valid reason for failure would be a unexpected error.
No need to special-case ENOMEM anymore.

> I will test this patch tomorrow.
> 
> Another question about add_recvbuf_small and
> add_recvbuf_big - both call virtqueue_add_buf_gfp with
> in+out > 1, and that can fail with -ENOSPC.  So try_fill_recv
> gets -ENOSPC.  When that happens, oom is not set to true,
> I thought it should have got set.  Is this a bug?
> 
> Thanks,
> 
> - KK

I don't see a bug: on ENOSPC we don't need to (and can't) add any more
buffers, we know we will make progress since there must be some buffers
in the ring already, ENOMEM makes us try again later with more buffers
(and possibly more aggressive GFP flag).  What's wrong?

-- 
MST
