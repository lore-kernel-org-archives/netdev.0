From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Fri, 05 Oct 2012 09:41:08 +0200
Message-ID: <1349422868.21172.38.camel@edumazet-glaptop>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
	 <1349368171.16011.79.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: mbizon@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349368171.16011.79.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-10-04 at 18:29 +0200, Eric Dumazet wrote:
> On Thu, 2012-10-04 at 18:02 +0200, Maxime Bizon wrote:
> > On Fri, 2012-08-31 at 19:21 -0700, Hugh Dickins wrote:
> > 
> > Hi,
> > 
> > > Francois is right that a GFP_ATOMIC allocation from pskb_expand_head()
> > > is failing, which can easily happen, and cause your "failed to reallocate
> > > TX buffer" errors; but it's well worth looking up what's actually on
> > > lines 2108 and 2109 of mm/page_alloc.c in 3.2.27:
> > > 
> > > 	if (order >= MAX_ORDER) {
> > > 		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
> > > 
> > > That was probably not a sane allocation request, it has gone out of range:
> > > maybe the skb header is even corrupted.  If you're lucky, it might be
> > > something that netdev will recognize as already fixed.
> > 
> > I have the same problem on the exact same hardware and found the cause:
> > 
> > Author: Eric Dumazet <eric.dumazet@gmail.com>
> > Date:   Tue Apr 10 20:08:39 2012 +0000
> > 
> >     net: allow pskb_expand_head() to get maximum tailroom
> >     
> >     [ Upstream commit 87151b8689d890dfb495081f7be9b9e257f7a2df ]
> >     
> > 
> > It turns out this change has a bad side effect on drivers that uses
> > skb_recycle(), in that case mv643xx_eth.c
> > 
> > Since skb_recycle() resets skb->data using (skb->head + NET_SKB_PAD), a
> > recycled skb going multiple times through a path that needs to expand
> > skb head will get bigger and bigger each time, and you eventually end up
> > with an allocation failure.
> > 
> > An idea to fix this would be to pass needed skb size to skb_resize() and
> > set skb->data to MIN(NET_SKB_PAD, (skb->end - skb->head - skb_size) / 2)
> > 
> > skb recycling gives a small speed boost, but does not get a lot of test
> > coverage since only 3 drivers uses it
> > 
> 
> Thanks Maxime

By the way, the commit you pointed has no effect on the reallocation
performed by pskb_expand_head() :

int size = nhead + skb_end_offset(skb) + ntail;

So pskb_expand_head() always assumed the current head is fully used, and
because we have some kmalloc-power-of-two contraints, each time
pskb_expand_head() is called with a non zero (nhead + ntail) we double
the skb->head ksize.

So why are we using skb_end_offset(skb) here is the question.

I guess it could be (skb_tail_pointer(skb) - skb->head) on some uses.

(ie not counting the unused bytes from tail_pointer to end_pointer)

Its probably long to audit all pskb_expand_head() users (about 77 in
tree), but most of them use (nhead = 0, ntail = 0) 

It looks like the following patch should be fine.


diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cdc2859..dd42c6a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1053,11 +1053,22 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 {
 	int i;
 	u8 *data;
-	int size = nhead + skb_end_offset(skb) + ntail;
+	unsigned int tail_offset = skb_tail_pointer(skb) - skb->head;
+	int size = nhead + ntail;
 	long off;
 
 	BUG_ON(nhead < 0);
 
+	/* callers using nhead == 0 and ntail == 0 want to get a fresh copy,
+	 * so allocate same amount of memory (skb_end_offset)
+	 * For others, they want extra headroom or tailroom against the
+	 * currently used portion of header (skb->head -> skb_tail_pointer)
+	 */
+	if (!size)
+		size = skb_end_offset(skb);
+	else
+		size += tail_offset;
+
 	if (skb_shared(skb))
 		BUG();
 
@@ -1074,7 +1085,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	/* Copy only real data... and, alas, header. This should be
 	 * optimized for the cases when header is void.
 	 */
-	memcpy(data + nhead, skb->head, skb_tail_pointer(skb) - skb->head);
+	memcpy(data + nhead, skb->head, tail_offset);
 
 	memcpy((struct skb_shared_info *)(data + size),
 	       skb_shinfo(skb),
