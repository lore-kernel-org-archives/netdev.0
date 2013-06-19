From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next rfc 1/3] net: avoid high order memory allocation for
 queues by using flex array
Date: Wed, 19 Jun 2013 02:56:03 -0700
Message-ID: <1371635763.3252.289.camel@edumazet-glaptop>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
	 <1371620452-49349-2-git-send-email-jasowang@redhat.com>
	 <1371623518.3252.267.camel@edumazet-glaptop>
	 <20130619091132.GA2816@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	edumazet@google.com, hkchu@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130619091132.GA2816@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-19 at 12:11 +0300, Michael S. Tsirkin wrote:

> Well KVM supports up to 160 VCPUs on x86.
> 
> Creating a queue per CPU is very reasonable, and
> assuming cache line size of 64 bytes, netdev_queue seems to be 320
> bytes, that's 320*160 = 51200. So 12.5 pages, order-4 allocation.
> I agree most people don't have such systems yet, but
> they do exist.

Even so, it will just work, like a fork() is likely to work, even if a
process needs order-1 allocation for kernel stack.

Some drivers still use order-10 allocations with kmalloc(), and nobody
complained yet.

We had complains with mlx4 driver lately only bcause kmalloc() now gives
a warning if allocations above MAX_ORDER are attempted.

Having a single pointer means that we can :

- Attempts a regular kmalloc() call, it will work most of the time.
- fallback to vmalloc() _if_ kmalloc() failed.

Frankly, if you want one tx queue per cpu, I would rather use
NETIF_F_LLTX, like some other virtual devices.

This way, you can have real per cpu memory, with proper NUMA affinity.
