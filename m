From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Thu, 04 Oct 2012 23:27:38 +0200
Message-ID: <1349386058.16011.118.camel@edumazet-glaptop>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
	 <1349369406.16011.82.camel@edumazet-glaptop>
	 <1349370573.2532.25.camel@sakura.staff.proxad.net>
	 <1349371049.16011.90.camel@edumazet-glaptop>
	 <1349372079.16710.15.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41792 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946385Ab2JDV1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 17:27:44 -0400
In-Reply-To: <1349372079.16710.15.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-04 at 19:34 +0200, Maxime Bizon wrote:
> On Thu, 2012-10-04 at 19:17 +0200, Eric Dumazet wrote:
> 
> > > yes, on ipv6 forward path the default NET_SKB_PAD is too small, so each
> > > packet forwarded has its headroom expanded, it is then recycled and gets
> > > its original default headroom back, then it gets forwarded,
> > > expanded, ...
> > 
> > Hmm, this sounds bad (especially without recycle)
> > 
> > Might I assume NET_SKB_PAD is 32 on this arch ?
> 
> It is, I have a setup with 6to4 tunneling, so needed headroom on tx is
> quite big.
> 

If we change NET_SKB_PAD minimum to be 64 (as it is on x86), it should
be enough for the added tunnel encapsulation or not ?


> I used to be careful about raising this value to avoid drivers using
> slab-4096 instead of slab-2048, but since our boards no longer have 16MB
> of RAM and with the recent changes in mainline it doesn't seem to be an
> issue anymore.

Yes, granted we can allocate order-3 pages for delivering skb->head
fragments, adding 32 bytes doesnt switch to slab-4096 since we dont use
it anymore.

> 
> It's not a that big issue in the non recycle case, just lower
> performance if the tunable is not set correctly. Though it would be nice
> to have a stat/counter so you know when you hit this kind of slow path.
> 

Yeah, we already mentioned this idea in the past. We are lazy now we
have good performance tools (perf)

> But on the recycle case, skb->head is reallocated to twice the size each
> time the packet is recycled and takes the same path again. This stresses
> the VM and you eventually get packet loss (and scary printk)
> 

OK, so to fix this on stable trees, skb_recycle() should not recycle skb
if skb->head is too big.

By the way, another problem with skb_recycle() is that skb->truesize can
be wrong as well. (One skb might had one frag, with a truesize of
2048/4096 bytes, and this frag was pulled in skb->head, so skb->truesize
is slightly wrong.

So we also must check if skb->truesize is equal to
SKB_TRUESIZE(skb_end_offset(skb)), or reset it in skb_recycle(),
I have no strong opinion.

Something like this (untested) patch :

But I really think we should remove skb_recycle() when net-next is
opened again.


diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b33a3a1..13ca215 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2659,7 +2659,10 @@ static inline bool skb_is_recycleable(const struct sk_buff *skb, int skb_size)
 	skb_size = SKB_DATA_ALIGN(skb_size + NET_SKB_PAD);
 	if (skb_end_offset(skb) < skb_size)
 		return false;
-
+	if (skb_end_offset(skb) > 2 * skb_size)
+		return false;
+	if (skb->truesize != SKB_TRUESIZE(skb_end_offset(skb)))
+		return false;
 	if (skb_shared(skb) || skb_cloned(skb))
 		return false;
 
