From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: Fix queue full check
Date: Mon, 8 Nov 2010 09:38:47 +1030
Message-ID: <201011080938.47938.rusty@rustcorp.com.au>
References: <20101028051036.25340.23442.sendpatchset@krkumar2.in.ibm.com> <20101102161730.GA32311@redhat.com> <20101104122424.GA29830@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, yvugenfi@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43716 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753453Ab0KGXI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Nov 2010 18:08:56 -0500
In-Reply-To: <20101104122424.GA29830@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Nov 2010 10:54:24 pm Michael S. Tsirkin wrote:
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

I've long said it's a weakness in the network stack that it insists
drivers stop the tx queue before they *might* run out of room, leading to
worst-case assumptions and underutilization of the tx ring.

However, I lost that debate, and so your patch is the way it's supposed to
work.  The other main indirect user (block) doesn't care as its queue
allows for post-attempt blocking.

I enhanced your commentry a little:

Subject: virtio: return correct capacity to users
Date: Thu, 4 Nov 2010 14:24:24 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>

We can't rely on indirect buffers for capacity
calculations because they need a memory allocation
which might fail.  In particular, virtio_net can get
into this situation under stress, and it drops packets
and performs badly.

So return the number of buffers we can guarantee users.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Reported-By: Krishna Kumar2 <krkumar2@in.ibm.com>

Thanks!
Rusty.
