From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v5 0/2] skb_array: array based FIFO for skbs
Date: Mon, 23 May 2016 23:35:04 +0300
Message-ID: <20160523232743-mutt-send-email-mst@redhat.com>
References: <1464000201-15560-1-git-send-email-mst@redhat.com>
 <1464010306.5939.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464010306.5939.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2016 at 06:31:46AM -0700, Eric Dumazet wrote:
> On Mon, 2016-05-23 at 13:43 +0300, Michael S. Tsirkin wrote:
> > This is in response to the proposal by Jason to make tun
> > rx packet queue lockless using a circular buffer.
> > My testing seems to show that at least for the common usecase
> > in networking, which isn't lockless, circular buffer
> > with indices does not perform that well, because
> > each index access causes a cache line to bounce between
> > CPUs, and index access causes stalls due to the dependency.
> > 
> > By comparison, an array of pointers where NULL means invalid
> > and !NULL means valid, can be updated without messing up barriers
> > at all and does not have this issue.
> 
> Note that both consumers and producers write in the array, so in light
> load (like TCP_RR), there are 2 cache line used byt the producers, and 2
> cache line used for consumers, with potential bouncing.

The shared part is RO by producer and consumer both,
so it's not bouncing - it can be shared in both caches.

Clearly memory footprint for this data structure is bigger
so it might cause more misses.

> In the other hand, the traditional sk_buff_head has one cache line,
> holding the spinlock and list head/tail.
>
> We might use the 'shared cache line' :
> 
> +       /* Shared consumer/producer data */
> +       int size ____cacheline_aligned_in_smp; /* max entries in queue
> */
> +       struct sk_buff **queue;
> 
> 
> To put here some fast path involving a single cache line access when
> queue has 0 or 1 item.
> 

I will try to experiment with it, but pls note that
this cache line is RO by producer and consumer currently,
if we make it writeable it will be bouncing.

-- 
MST
