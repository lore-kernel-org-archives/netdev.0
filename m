From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: skb_shared_info()
Date: Sun, 13 Aug 2006 17:04:31 +0400
Message-ID: <20060813130431.GA14138@ms2.inr.ac.ru>
References: <20060808.163915.03600382.davem@davemloft.net> <20060811140019.GA8611@ms2.inr.ac.ru> <20060811.172730.34542868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:19110 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751233AbWHMNEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2006 09:04:53 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060811.172730.34542868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> E1000 wants 16K buffers for jumbo MTU settings.
> 
> The reason is that the chip can only handle power-of-2 buffer
> sizes, and next hop from 9K is 16K.

Let it use pages. Someone should start. :-)

High order allocations are disaster in any case.


> If we store raw kmalloc buffers, we cannot attach them to an arbitrary
> skb because of skb_shared_info().  This is true even if we
> purposefully allocate the necessary head room for these kmalloc based
> buffers.

I still do not see. For non-SG paths, you have to keep header and data
together, you just do not need anything clever. And it does not look
like you can. If you have a fixed space for header, you already have
a space for refcnt to make skb_shared_info().

For SG paths, TCP_PAGE() seems to be enough and even better than
kmalloc()ed buffers.


> I think you are talking about "struct sk_buff"

Yes. :-)


> If inlined, one implementation of retransmit queue becomes apparent.
> "struct retransmit_queue" is just list of data blobs, each represented
> by usual vector of pages and offset and length.
> 
> Then transmission from write queue is merely propagating pages to
> inline skb vector.

Yes. I have no idea how good it is, but at least it is something
different of what we have now. :-)

Seems, it is too simple to be correct. See below.


> The latter scheme is closer to what I was thinking about.  Why
> not inline this entire fraglist thing alongside sk_buff?

Sorry, that crap about cost of clone still clouds my mind. :-)

Actually, the borderline was not between "short" and "long",
but between "plain page vector" and "not-so-plain". See below.


> It sounds interesting... so using my sample datastructures above
> for aggregated tcp queue, such notifications would be made on
> (for example) "retransmit_block" objects?

Not quite.

TCP is too easy case. If you remember, I did some ugly but 100% functional
zero-copy send() without any "architectural" changes: async_seq at socket side
and SIOCOUTQ/SIOCOUTWAITQ + POLLWRCOMP extension to poll() at api side
were enough to notify when to recycle pages. This sucks because of two reasons:

1. Small one. Someone sort of packet sniffer could hold those pages
   after they are acked. If they are recycled, it will see wrong content.
   Seems, we can live with this. TCP works, that's all that is really
   important.

2. Non-TCP. No queue. Notifications has to be done from skb destructor.
   It means skb have to carry all the info somewhere.

With UDP it could be original not-fragmented skb_shared_info().
Provided we prohibit to change it and to clone page references,
the point of recycle is when this skb_shared_info() is destroyed.
This is the place, where skb_shared_info() does not want to be
inlined.

For TCP the idea was to do the same. If transmitted skb does not have
separate pages in it, referring to an aggregated skb_shared_info()
instead, it would work. This is the second place.

It was the first approach. Probably, the best, but utterly inflexible.
F.e. it is impossible to merge two tcp segments from different sources.


I am afraid, per-fragment destructors are still required.
And this is so not cool. :-) Carrying in each skb space for 18
destructors and necessary data looks too scary.

I see two ways to do this, both consider the case, when destructors
are required as exceptional.

1. Multiple skb_shared_info() per skb. Some of them are nothing but
   wrapper for a page with refcounter and information necessary
   for destruction.

   So, in each skb you have vector:

   struct {
     union {
	struct page		*page;
	struct skb_shared_info	*shinfo;
     } datum;
     unsigned int offset, size;	/* This selects an area inside datum */
   } data [MAX_SKB_FRAGS_INLINED];

   The pointers could be distingushed by selector hidden in low bits. Sorry. :)

   struct skb_shared_info is essentially preserved, only some ops and space
   for information to clone/release are added and frag_list is removed.
   Seems, it is flexible enough and even reduces overhead sometimes
   (for SG you have only struct sk_buff with MAX_HEADER inlined and
   direct references to pages)
   But code promises to be ugly: sometimes page references are direct,
   sometimes they are indirect.

2. Another idea is to preserve current structure,
   but for those "pathological" cases, when special notifications are
   required, to allocate optional additional vector which could hold
   "transaction tokens", crap sort of pipe_inode_info for splice(),
   arbitrarily obscure and complicated, the advantage is that
   it keeps "normal" skbs small and clean.

Alexey
