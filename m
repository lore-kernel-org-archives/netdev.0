From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ptr_ring: use kmalloc_array()
Date: Fri, 25 Aug 2017 13:13:10 -0700
Message-ID: <1503691990.11498.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502905007.4936.133.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170825205653-mutt-send-email-mst@kernel.org>
         <1503687439.11498.5.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170825222015-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Jason Wang <jasowang@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34152 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754704AbdHYUNM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 16:13:12 -0400
Received: by mail-pg0-f66.google.com with SMTP id 63so1114685pgc.1
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 13:13:12 -0700 (PDT)
In-Reply-To: <20170825222015-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-25 at 22:25 +0300, Michael S. Tsirkin wrote:
> On Fri, Aug 25, 2017 at 11:57:19AM -0700, Eric Dumazet wrote:
> > On Fri, 2017-08-25 at 21:03 +0300, Michael S. Tsirkin wrote:
> > > On Wed, Aug 16, 2017 at 10:36:47AM -0700, Eric Dumazet wrote:
> > > > From: Eric Dumazet <edumazet@google.com>
> > > > 
> > > > As found by syzkaller, malicious users can set whatever tx_queue_len
> > > > on a tun device and eventually crash the kernel.
> > > > 
> > > > Lets remove the ALIGN(XXX, SMP_CACHE_BYTES) thing since a small
> > > > ring buffer is not fast anyway.
> > > 
> > > I'm not sure it's worth changing for small rings.
> > > 
> > > Does kmalloc_array guarantee cache line alignment for big buffers
> > > then? If the ring is misaligned it will likely cause false sharing
> > > as it's designed to be accessed from two CPUs.
> > 
> > I specifically said that in the changelog :
> > 
> > "since a small ring buffer is not fast anyway."
> > 
> > If one user sets up a pathological small ring buffer, kernel should not
> > try to fix it.
> 
> Yes, I got that point. My question is about big buffers.
> Does kmalloc_array give us an aligned array in that case?
> 

The answer is yes, kmalloc() uses aligned slabs for allocations larger
than the L1 cache sizes.

> E.g. imagine a 100 slot array. Will 800 bytes be allocated?
> In that case it uses up 12.5 cache lines. It looks like the
> last cache line can become false shared with something else,
> causing cache line bounces on each wrap around.
> 

800 bytes are rounded to 1024 by slab allocators.

> 
> > In this case, you would have to setup a ring of 2 or 4 slots to
> > eventually hit false sharing.
> > 
> 
> I don't think many people set up such tiny rings so I do not really
> think we care what happens in that case. But you need 8 slots to avoid
> false sharing I think.
> 
