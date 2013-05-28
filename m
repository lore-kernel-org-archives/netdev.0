From: Joe Perches <joe@perches.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Mon, 27 May 2013 21:31:46 -0700
Message-ID: <1369715506.2034.30.camel@joe-AO722>
References: <1369599557-22677-1-git-send-email-atomlin@redhat.com>
	 <51A39A3F.8080903@redhat.com> <1369693520.3301.477.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rik van Riel <riel@redhat.com>, atomlin@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	aquini@redhat.com, sergei.shtylyov@cogentembedded.com,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369693520.3301.477.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-27 at 15:25 -0700, Eric Dumazet wrote:
> On Mon, 2013-05-27 at 13:39 -0400, Rik van Riel wrote:
> > On 05/26/2013 04:19 PM, atomlin@redhat.com wrote:
> > > Failed GFP_ATOMIC allocations by the network stack result in dropped
> > > packets, which will be received on a subsequent retransmit, and an
> > > unnecessary, noisy warning with a kernel backtrace.
> 
> This claim is wrong, only some protocols deal with retransmits.
> 
> > > These warnings are harmless, but they still cause users to panic and
> > > file bug reports over dropped packets. It would be better to hide the
> > > failed allocation warnings and backtraces, and let retransmits handle
> > > dropped packets quietly.
> > 
> > Yes please. Getting memory management bug reports for
> > dropped network packets got old years ago.  Lets get
> > rid of those messages.
> 
> I am only wondering why this path has anything needing special
> attention, over thousands of kmalloc() like call sites in the kernel.

I don't think this site is particularly special.

> If mm allocation warnings are useless, just make __GFP_NOWARN the
> default, and save us thousand of patches (adding the __GFP_NOWARN
> everywhere)
> 
> Truth is : some network drivers don't deal very well with allocation
> errors. mlx4 for example absolutely wants order-2 pages in RX path, with
> no fallback to order-0 pages.
> 
> So I am not against this patch, but I can not really acknowledge it,
> sorry.

I think the __alloc_skb alloc failure message is ok,
but maybe there shouldn't be something "scary" like
a dump_stack.

Maybe this site should use a trivial debug error
message like below instead.
---
 net/core/skbuff.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d629891..0154803 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -231,17 +231,24 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	struct sk_buff *skb;
 	u8 *data;
 	bool pfmemalloc;
+	bool warn_no_skb = !(gfp_mask & __GFP_NOWARN);
 
 	cache = (flags & SKB_ALLOC_FCLONE)
 		? skbuff_fclone_cache : skbuff_head_cache;
 
 	if (sk_memalloc_socks() && (flags & SKB_ALLOC_RX))
-		gfp_mask |= __GFP_MEMALLOC;
+		gfp_mask |= __GFP_MEMALLOC | __GFP_NOWARN;
 
 	/* Get the HEAD */
 	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
-	if (!skb)
+	if (!skb) {
+		if (warn_no_skb)
+			printk_ratelimited(KERN_DEBUG "%s: OOM from %pF via %pF\n",
+					   __func__,
+					   __builtin_return_address(0),
+					   __builtin_return_address(1));
 		goto out;
+	}
 	prefetchw(skb);
 
 	/* We do our best to align skb_shared_info on a separate cache
