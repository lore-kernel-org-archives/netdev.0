From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] skb_array: array based FIFO for skbs
Date: Thu, 19 May 2016 05:49:54 -0700
Message-ID: <1463662194.18194.185.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463659932-14570-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463659932-14570-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-05-19 at 15:15 +0300, Michael S. Tsirkin wrote:
> A simple array based FIFO of pointers.  Intended for net stack so uses
> skbs for type safety, but we can replace with with void * if others find
> it useful outside of net stack.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> Still untested, fixed the bug pointed out by Eric.
> Posting since several people expressed interest in
> helping test this.
> 
> Note: SKB_ARRAY_MIN_SIZE is a heuristic. It can be increased
> to more than 2 cache lines, or even to INT_MAX to disable
> the heuristic completely.
> 
>  include/linux/skb_array.h | 115 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 115 insertions(+)
>  create mode 100644 include/linux/skb_array.h
> 
> diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
> new file mode 100644
> index 0000000..fd4ff23
> --- /dev/null
> +++ b/include/linux/skb_array.h
> @@ -0,0 +1,115 @@
> +/*
> + * See Documentation/skb-array.txt for more information.
> + */
> +
> +#ifndef _LINUX_SKB_ARRAY_H
> +#define _LINUX_SKB_ARRAY_H 1
> +
> +#include <linux/spinlock.h>
> +#include <linux/cache.h>
> +#include <linux/types.h>
> +#include <linux/compiler.h>
> +#include <linux/cache.h>
> +#include <linux/slab.h>
> +#include <asm/errno.h>
> +
> +struct sk_buff;
> +
> +struct skb_array {
> +	int producer ____cacheline_aligned_in_smp;
> +	spinlock_t producer_lock;
> +	int consumer ____cacheline_aligned_in_smp;
> +	spinlock_t consumer_lock;
> +	/* Shared consumer/producer data */
> +	int size ____cacheline_aligned_in_smp; /* max entries in queue */
> +	struct sk_buff **queue;
> +};
> +
> +#define SKB_ARRAY_MIN_SIZE (2 * (0x1 << cache_line_size()) / \
> +			    sizeof (struct sk_buff *))
> +

0x1 << cache_line_size() is overflowing when cache_line_size() is 64
bytes.


> +static inline int __skb_array_produce(struct skb_array *a,
> +				       struct sk_buff *skb)
> +{
> +	/* Try to start from beginning: good for cache utilization as we'll
> +	 * keep reusing the same cache line.
> +	 * Produce at least SKB_ARRAY_MIN_SIZE entries before trying to do this,
> +	 * to reduce bouncing cache lines between them.
> +	 */
> +	if (a->producer >= SKB_ARRAY_MIN_SIZE && !a->queue[0])
> +		a->producer = 0;

I really do not see how this works. reading first cache line every time
is not going to help stress load.

Then, say you queued 100 skbs, and consumer removes the first one,
you set a->producer to 0 here.

Then next __skb_array_produce() will look at queue[1] and find it busy.
No more packet can be queued, even if the queue contains 99 skbs only.

Could we be very basic and not add heuristics like that ?

Then, if we really need to optimize further, add an incremental patch.
