From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 0/2] skb_array: array based FIFO for skbs
Date: Mon, 23 May 2016 06:31:46 -0700
Message-ID: <1464010306.5939.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464000201-15560-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464000201-15560-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-05-23 at 13:43 +0300, Michael S. Tsirkin wrote:
> This is in response to the proposal by Jason to make tun
> rx packet queue lockless using a circular buffer.
> My testing seems to show that at least for the common usecase
> in networking, which isn't lockless, circular buffer
> with indices does not perform that well, because
> each index access causes a cache line to bounce between
> CPUs, and index access causes stalls due to the dependency.
> 
> By comparison, an array of pointers where NULL means invalid
> and !NULL means valid, can be updated without messing up barriers
> at all and does not have this issue.

Note that both consumers and producers write in the array, so in light
load (like TCP_RR), there are 2 cache line used byt the producers, and 2
cache line used for consumers, with potential bouncing.

In the other hand, the traditional sk_buff_head has one cache line,
holding the spinlock and list head/tail.

We might use the 'shared cache line' :

+       /* Shared consumer/producer data */
+       int size ____cacheline_aligned_in_smp; /* max entries in queue
*/
+       struct sk_buff **queue;


To put here some fast path involving a single cache line access when
queue has 0 or 1 item.
