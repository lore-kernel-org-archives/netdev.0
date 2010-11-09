From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: Fix queue full check
Date: Tue, 9 Nov 2010 15:15:55 +0200
Message-ID: <20101109131555.GE22705@redhat.com>
References: <20101028051036.25340.23442.sendpatchset@krkumar2.in.ibm.com>
 <20101102161730.GA32311@redhat.com>
 <20101104122424.GA29830@redhat.com>
 <201011080938.47938.rusty@rustcorp.com.au>
 <OF5977B5FB.669A3250-ON652577D6.00168221-652577D6.00180738@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, davem@davemloft.net,
	netdev@vger.kernel.org, yvugenfi@redhat.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7313 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265Ab0KINQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Nov 2010 08:16:08 -0500
Content-Disposition: inline
In-Reply-To: <OF5977B5FB.669A3250-ON652577D6.00168221-652577D6.00180738@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 09, 2010 at 09:56:03AM +0530, Krishna Kumar2 wrote:
> Rusty Russell <rusty@rustcorp.com.au> wrote on 11/08/2010 04:38:47 AM:
> 
> > Re: [PATCH] virtio_net: Fix queue full check
> >
> > On Thu, 4 Nov 2010 10:54:24 pm Michael S. Tsirkin wrote:
> > > I thought about this some more.  I think the original
> > > code is actually correct in returning ENOSPC: indirect
> > > buffers are nice, but it's a mistake
> > > to rely on them as a memory allocation might fail.
> > >
> > > And if you look at virtio-net, it is dropping packets
> > > under memory pressure which is not really a happy outcome:
> > > the packet will get freed, reallocated and we get another one,
> > > adding pressure on the allocator instead of releasing it
> > > until we free up some buffers.
> > >
> > > So I now think we should calculate the capacity
> > > assuming non-indirect entries, and if we manage to
> > > use indirect, all the better.
> >
> > I've long said it's a weakness in the network stack that it insists
> > drivers stop the tx queue before they *might* run out of room, leading to
> > worst-case assumptions and underutilization of the tx ring.
> >
> > However, I lost that debate, and so your patch is the way it's supposed
> to
> > work.  The other main indirect user (block) doesn't care as its queue
> > allows for post-attempt blocking.
> >
> > I enhanced your commentry a little:
> >
> > Subject: virtio: return correct capacity to users
> > Date: Thu, 4 Nov 2010 14:24:24 +0200
> > From: "Michael S. Tsirkin" <mst@redhat.com>
> >
> > We can't rely on indirect buffers for capacity
> > calculations because they need a memory allocation
> > which might fail.  In particular, virtio_net can get
> > into this situation under stress, and it drops packets
> > and performs badly.
> >
> > So return the number of buffers we can guarantee users.
> >
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> > Reported-By: Krishna Kumar2 <krkumar2@in.ibm.com>
> 
> I have tested this patch for 3-4 hours but so far I have not got the tx
> full
> error. I am not sure if "Tested-By" applies to this situation, but just in
> case:
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> Reported-By: Krishna Kumar2 <krkumar2@in.ibm.com>
> Tested-By: Krishna Kumar2 <krkumar2@in.ibm.com>
> 
> I think both this patch and the original patch I submitted
> are needed? That patch removes ENOMEM check and the increment
> of dev->stats.tx_fifo_errors, and reports "memory failure".
> 
> Thanks,
> 
> - KK

So I think your patch on top of this one would be wrong:
we actually make sure out of memory does not affect TX path
at all, so any error would be unexpected.

Incrementing tx fifo errors is probably also helpful for debugging.

If you like, we could kill the special handling for ENOMEM.
Not sure whether it matters.

-- 
MST
