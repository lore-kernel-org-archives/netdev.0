From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC v7 0/5] skb_array: array based FIFO for skbs
Date: Fri, 3 Jun 2016 20:41:35 +0200
Message-ID: <20160603204135.7476f806@redhat.com>
References: <1464883305-32368-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	kvm@vger.kernel.org, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464883305-32368-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I applied this V7 to my github tree:
 https://github.com/netoptimizer/prototype-kernel/commits/master

And adjusted my benchmark and unit-tests of this skb_array API.
Added an unit test of re-sizing to small queue size.
 https://github.com/netoptimizer/prototype-kernel/blob/81ca09c2a9/kernel/lib/skb_array_test01.c#L130


On Thu, 2 Jun 2016 19:08:14 +0300 "Michael S. Tsirkin" <mst@redhat.com> wrote:

[...]
> My testing seems to show that at least for the common usecase
> in networking, which isn't lockless, circular buffer
> with indices does not perform that well, because
> each index access causes a cache line to bounce between
> CPUs, and index access causes stalls due to the dependency.
> 
> By comparison, an array of pointers where NULL means invalid
> and !NULL means valid

I confirm and validate that this is a good approach.
In module skb_array_parallel01:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/skb_array_parallel01.c

> As this might be useful outside of networking, I implemented
> a generic array of void pointers, with a type-safe wrapper for skbs.

Nice

[...]
> The only issue is with calls within a loop using the __ptr_ring_XXX
> accessors - in theory compiler could hoist accesses out of the loop.
> 
> Following volatile-considered-harmful.txt I merely
> documented that callers that busy-poll should invoke cpu_relax().
> Most people will use the external skb_array_XXX APIs with a spinlock,
> so this should not be an issue for them.

I would like to see some bulking support...

As my experiments[1] show that alf_queue (primarily) can beat skb_array due
to bulking support.  It seems like an obvious optimization for the virt
tun use-case to bulk dequeue SKBs.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/alf_queue_parallel01.c
