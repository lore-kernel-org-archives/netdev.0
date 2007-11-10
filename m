From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression with tbench
Date: Sat, 10 Nov 2007 14:28:25 +1100
Message-ID: <200711101428.25295.nickpiggin@yahoo.com.au>
References: <200711092336.56172.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0711091533300.17621@schroedinger.engr.sgi.com> <200711101229.35822.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org
To: Christoph Lameter <clameter@sgi.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.mail.mud.yahoo.com ([209.191.85.216]:41376 "HELO
	smtp106.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751525AbXKJGHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 01:07:03 -0500
In-Reply-To: <200711101229.35822.nickpiggin@yahoo.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 10 November 2007 12:29, Nick Piggin wrote:
> cc'ed linux-netdev

Err, make that 'netdev' :P

> On Saturday 10 November 2007 10:46, Christoph Lameter wrote:
> > commit deea84b0ae3d26b41502ae0a39fe7fe134e703d0 seems to cause a drop
> > in SLUB tbench performance:
> >
> > 8p x86_64 system:
> >
> > 2.6.24-rc2:
> > 	1260.80 MB/sec
> >
> > After reverting the patch:
> > 	2350.04 MB/sec
> >
> > SLAB performance (which is at 2435.58 MB/sec, ~3% better than SLUB) is
> > not affected by the patch.
>
> Ah, I didn't realise this was a regression. Thanks for bisecting it.
>
> > Since this is an alignment change it seems that tbench performance is
> > sensitive to the data layout? SLUB packs data more tightly than SLAB. So
> > 8 byte allocations could result in cacheline contention if adjacent
> > objects are allocated from different cpus. SLABs minimum size is 32
> > bytes so the cacheline contention is likely more limited.
> >
> > Maybe we need to allocate a mininum of one cacheline to the skb head? Or
> > padd it out to a full cacheline?
>
> The data should already be cacheline aligned. It is kmalloced, and
> with a minimum size of somewhere around 200 bytes on a 64-bit machine.
> So it will hit a cacheline aligned kmalloc slab AFAIKS  -- cacheline
> interference is probably not the problem. (To verify, I built slub with
> minimum kmalloc size set to 32 like slab and it's no real difference)
>
> But I can't see why restricting the allocation to PAGE_SIZE would help
> either. Maybe the macros are used in some other areas.
>
> BTW. your size-2048 kmalloc cache is order-1 in the default setup,
> wheras kmalloc(1024) or kmalloc(4096) will be order-0 allocations. And
> SLAB also uses order-0 for size-2048. It would be nice if SLUB did the
> same...
>
> > commit deea84b0ae3d26b41502ae0a39fe7fe134e703d0
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Sun Oct 21 16:27:46 2007 -0700
> >
> >     [NET]: Fix SKB_WITH_OVERHEAD calculation
> >
> >     The calculation in SKB_WITH_OVERHEAD is incorrect in that it can
> > cause an overflow across a page boundary which is what it's meant to
> > prevent. In particular, the header length (X) should not be lumped
> > together with skb_shared_info.  The latter needs to be aligned properly
> > while the header has no choice but to sit in front of wherever the
> > payload is.
> >
> >     Therefore the correct calculation is to take away the aligned size of
> >     skb_shared_info, and then subtract the header length.  The resulting
> >     quantity L satisfies the following inequality:
> >
> >         SKB_DATA_ALIGN(L + X) + sizeof(struct skb_shared_info) <=
> > PAGE_SIZE
> >
> >     This is the quantity used by alloc_skb to do the actual allocation.
> >     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index f93f22b..369f60a 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -41,8 +41,7 @@
> >  #define SKB_DATA_ALIGN(X)      (((X) + (SMP_CACHE_BYTES - 1)) & \
> >                                  ~(SMP_CACHE_BYTES - 1))
> >  #define SKB_WITH_OVERHEAD(X)   \
> > -       (((X) - sizeof(struct skb_shared_info)) & \
> > -        ~(SMP_CACHE_BYTES - 1))
> > +       ((X) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
> >  #define SKB_MAX_ORDER(X, ORDER) \
> >         SKB_WITH_OVERHEAD((PAGE_SIZE << (ORDER)) - (X))
> >  #define SKB_MAX_HEAD(X)                (SKB_MAX_ORDER((X), 0))
