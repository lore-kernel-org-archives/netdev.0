From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next rfc 1/3] net: avoid high order memory allocation for
 queues by using flex array
Date: Wed, 19 Jun 2013 18:40:59 +0300
Message-ID: <20130619154059.GA13735@redhat.com>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
 <1371620452-49349-2-git-send-email-jasowang@redhat.com>
 <1371623518.3252.267.camel@edumazet-glaptop>
 <20130619091132.GA2816@redhat.com>
 <1371635763.3252.289.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	edumazet@google.com, hkchu@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56214 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756936Ab3FSPkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 11:40:19 -0400
Content-Disposition: inline
In-Reply-To: <1371635763.3252.289.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 19, 2013 at 02:56:03AM -0700, Eric Dumazet wrote:
> On Wed, 2013-06-19 at 12:11 +0300, Michael S. Tsirkin wrote:
> 
> > Well KVM supports up to 160 VCPUs on x86.
> > 
> > Creating a queue per CPU is very reasonable, and
> > assuming cache line size of 64 bytes, netdev_queue seems to be 320
> > bytes, that's 320*160 = 51200. So 12.5 pages, order-4 allocation.
> > I agree most people don't have such systems yet, but
> > they do exist.
> 
> Even so, it will just work, like a fork() is likely to work, even if a
> process needs order-1 allocation for kernel stack.
> 
> Some drivers still use order-10 allocations with kmalloc(), and nobody
> complained yet.
> 
> We had complains with mlx4 driver lately only bcause kmalloc() now gives
> a warning if allocations above MAX_ORDER are attempted.
> 
> Having a single pointer means that we can :
> 
> - Attempts a regular kmalloc() call, it will work most of the time.
> - fallback to vmalloc() _if_ kmalloc() failed.

That's a good trick too - vmalloc memory is a bit slower
on x86 since it's not using a huge page, but that's only
when we have lots of CPUs/queues...

Short term - how about switching to vmalloc if > 32 queues?

> Frankly, if you want one tx queue per cpu, I would rather use
> NETIF_F_LLTX, like some other virtual devices.
> 
> This way, you can have real per cpu memory, with proper NUMA affinity.
> 
> 
