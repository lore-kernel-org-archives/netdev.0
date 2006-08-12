From: David Miller <davem@davemloft.net>
Subject: Re: skb_shared_info()
Date: Fri, 11 Aug 2006 17:27:30 -0700 (PDT)
Message-ID: <20060811.172730.34542868.davem@davemloft.net>
References: <20060808.163915.03600382.davem@davemloft.net>
	<20060811140019.GA8611@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63179
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932451AbWHLA1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 20:27:17 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060811140019.GA8611@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Fri, 11 Aug 2006 18:00:19 +0400

> > The e1000 issue is just one example of this, another
> 
> What is this issue?

E1000 wants 16K buffers for jumbo MTU settings.

The reason is that the chip can only handle power-of-2 buffer
sizes, and next hop from 9K is 16K.

It is not possible to tell the chip to only accept 9K packets, you
must give it the whole next power of 2 buffer size for the MTU you
wish to use.

With skb_shared_info() overhead this becomes a 32K allocation
in the simplest implementation.

Whichever hardware person was trying to save some trace lines on the
chip should have consulted software folks before implementing things
this way :-)

> What's about aggregated tcp queue, I can guess you did not find
> place where to add protocol headers, but cannot figure out how
> adding non-pagecache references could help.

This is not the idea.  I'm trying to see if we can salvage non-SG
paths in the design.

The idea is that "struct retransmit_queue" entries could hold either
paged or non-paged data, based upon the capabilities of the transmit
device.

If we store raw kmalloc buffers, we cannot attach them to an arbitrary
skb because of skb_shared_info().  This is true even if we
purposefully allocate the necessary head room for these kmalloc based
buffers.

It's requirement to live in the skb->data area really does preclude
any kind of clever buffering schemes.

> I think Evgeniy's idea about inlining skb_shared_info to skb head
> is promising and simple enough.

I think you are talking about "struct sk_buff" area when you say "skb
head".  It is confusing talk because when I hear this phrase my brain
says "skb->head" which exactly where we want to move skb_shared_info()
away from! :-)

> But it makes lots of sense to inline some short vector inot skb head
> (and, probably, even a MAX_HEADER space _instead_ of space for
> fclone).

If inlined, one implementation of retransmit queue becomes apparent.
"struct retransmit_queue" is just list of data blobs, each represented
by usual vector of pages and offset and length.

Then transmission from write queue is merely propagating pages to
inline skb vector.

Some silly sample datastructure:

struct retransmit_block {
	struct list_head	rblk_node;
	void			*rblk_data;
	unsigned short		rblk_frags;
	skb_frag_t		frags[MAX_SKB_FRAGS];
};

struct retransmit_queue {
	struct list_head	rqueue_head;
	struct retransmit_block	*rqueue_send_head;
	int			rqueue_send_head_frag;
	unsigned int		rqueue_send_head_off;
};

tcp_sendmsg() and tcp_sendpage() just accumulate into the tail
retransmit_block until all of MAX_SKB_FRAGS are consumed.

tcp_write_xmit() and friends build skbs like this:

struct struct sk_buff *tcp_xmit_build(struct retransmit_block *rblk,
                                      int frag, unsigned int off,
				      unsigned int len)
{
	struct sk_buff *skb = alloc_skb(MAX_HEADER, GFP_KERNEL);
	int ent;

	if (unlikely(!skb))
		return NULL;
	ent = 0;
	while (len) {
		unsigned int this_off = rblk->frags[frag].page_offset + off;
		unsigned int this_len = rblk->flags[frag].size - off;

		if (this_len > len)
			this_len = len;

		skb->inline_info.frags[ent].page =
			rblk->frags[frag].page;
		skb->inline_info.frags[ent].page_offset = this_off;
		skb->inline_info.frags[ent].size = this_len;
		ent++;

		frag++;
		off = 0;
		len -= this_len;
	}
	return skb;
}

(sorry, another outer loop is also needed to traverse to subsequent
 retransmit_blocks in the list when all of rblk_frags of current
 retransmit_block are consumed by inner loop)

Depending upon how we do completion callbacks, as you discuss below,
either we'll need a get_page() refcount grab in that inner loop
or we won't.

> With aggregated tcp send queue, when transmitting a segment, you could
> allocate new skb head with space for header and either take existing
> skb_shared_info from queue, attach it to head and set offset/length.
> Or, alternatively, set one or two of page pointers in array, inlined in head.
> (F.e. in the case of AF_UNIX socket, mentioned by Evgeniy, we would keep data
> in pages and attach it directly to skb head).

The latter scheme is closer to what I was thinking about.  Why
not inline this entire fraglist thing alongside sk_buff?

> Cloning becomes more expensive, but who needs it cheap, if tcp does not?

Exactly :)

> One idea is to announce (some) skb_shared_info completely immutable,
> force each layer who needs to add a header or to fragment to refer
> to original skb_shared_info as whole, using for modifications
> another skb_shared_info() or area inlined in skb head.
> And if someone is not able to, he must reallocate all the pages.
> In this case destructor/notification can be done not for fragment,
> but for whole aggregated skb_shared_info. Seems, it will work both
> with aggregated tcp queue and with udp.

It sounds interesting... so using my sample datastructures above
for aggregated tcp queue, such notifications would be made on
(for example) "retransmit_block" objects?
