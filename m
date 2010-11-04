From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] virtio_net: Fix queue full check
Date: Thu, 4 Nov 2010 21:47:04 +0530
Message-ID: <OF9196A33D.75E1F25E-ON652577D1.0057D889-652577D1.00592104@in.ibm.com>
References: <20101028051036.25340.23442.sendpatchset@krkumar2.in.ibm.com> <201010292017.25099.rusty@rustcorp.com.au> <OF30574F6E.113EC5F4-ON652577CB.0037DAB5-652577CB.003BACE8@in.ibm.com> <201010292158.40411.rusty@rustcorp.com.au> <20101102161730.GA32311@redhat.com> <20101104122424.GA29830@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>, yvugenfi@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:47411 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab0KDQNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 12:13:37 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id oA4GDYG8004489
	for <netdev@vger.kernel.org>; Thu, 4 Nov 2010 21:43:34 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oA4GDYUl3858644
	for <netdev@vger.kernel.org>; Thu, 4 Nov 2010 21:43:34 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oA4GDXiD009170
	for <netdev@vger.kernel.org>; Thu, 4 Nov 2010 21:43:34 +0530
In-Reply-To: <20101104122424.GA29830@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 11/04/2010 05:54:24 PM:

> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>
> I thought about this some more.  I think the original
> code is actually correct in returning ENOSPC: indirect
> buffers are nice, but it's a mistake
> to rely on them as a memory allocation might fail.
>
> And if you look at virtio-net, it is dropping packets
> under memory pressure which is not really a happy outcome:
> the packet will get freed, reallocated and we get another one,
> adding pressure on the allocator instead of releasing it
> until we free up some buffers.
>
> So I now think we should calculate the capacity
> assuming non-indirect entries, and if we manage to
> use indirect, all the better.
>
> So below is what I propose now - as a replacement for
> my original patch.  Krishna Kumar, Rusty, what do you think?
>
> Separately I'm also considering moving the
>    if (vq->num_free < out + in)
> check earlier in the function to keep all users honest,
> but need to check what the implications are for e.g. block.
> Thoughts on this?

This looks like the right thing to do.  Besides this, I
think virtio-net still needs to remove check for ENOMEM?
I will test this patch tomorrow.

Another question about add_recvbuf_small and
add_recvbuf_big - both call virtqueue_add_buf_gfp with
in+out > 1, and that can fail with -ENOSPC.  So try_fill_recv
gets -ENOSPC.  When that happens, oom is not set to true,
I thought it should have got set.  Is this a bug?

Thanks,

- KK

