From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather than
 individually
Date: Fri, 6 Jan 2012 11:20:15 +0000
Message-ID: <1325848815.25206.471.camel@zakaz.uk.xensource.com>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
	 <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325791164.29084.8.camel@dagon.hellion.org.uk>
	 <1325794968.2748.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:15266 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758647Ab2AFLUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 06:20:17 -0500
In-Reply-To: <1325794968.2748.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-01-05 at 20:22 +0000, Eric Dumazet wrote:
> Take a look at kfree_skb() and please list all skb_shared_info needed
> fields, for a typical skb with nr_frags= 0 or 1.
> 
> If all fit in a single cache line, its ok.

It doesn't fit in a single cache line today.

Before I started touching any of this stuff (e.g. in v3.1) kfree_skb
would touch 3x32 byte caches lines (with boundaries between
frag_list/hwtstamps and destructor_arg/frags[0]) or 2x64 byte cache
lines (boundary between between frag_list/hwtstamps).

After the v2 version of these patches the situation is much the same,
although the boundaries are different and which field is in which line
has shifted a bit. The boundaries are now gso_type/frag_list and
dataref/destructor_arg for 32 byte cache lines and gso_type/frag_list
for 64 byte cache lines.

With the proposed reordering to put destructor_arg first it actually
shrinks to just 2 32 byte cache lines (boundary between hwtstamps and
ip6_frag_id) or a single 64 byte cache line, since the other 32&64
boundary is between destructor_arg and nr_frags.

Even if we don't consider destructor_arg to be rarely used / cold things
are no worse than they were before (3x32 or 2x64 byte cache lines
touched).

So I think if anything I think these patches improve things when
nr_frags = 0 or 1 or at at least no worse than the current situation.

> If not, this adds a cache line miss in a critical path.

I think it does not, but please do check my working (see below).

> Also in transmit path, when an skb is queued by cpu X on qdisc, and
> dequeued by another cpu Y to be delivered to device.

You mean the path starting at dev_queue_xmit -> q->enqueue is true ->
__dev_xmit_skb ?

I didn't follow it properly but it doesn't seem like there is much use
of the shinfo at all in this area qdisc, the only thing I spotted was
the use of the gso_{size,segs} fields in qdisc_bstats_update and those
are always on the same cache line. Did I miss something?

Anyway, by similar logic to the kfree_skb case I think the number of
cachelines touched will always be <= the current number.

Ian.

My working:

						Used in kfree_skb?
unsigned short  nr_frags;			YES (if dataref -> 0 etc)
unsigned short  gso_size;
unsigned short  gso_segs;
unsigned short  gso_type;
__be32          ip6_frag_id;
__u8            tx_flags;			YES (if dataref -> 0 etc)
struct sk_buff  *frag_list;			YES (if dataref -> 0 etc)
struct skb_shared_hwtstamps hwtstamps;
atomic_t        dataref;			YES
void *          destructor_arg;			YES if skb->destructor || tx_flags & ZEROCOPY
                                                -> I count this as unused by
						   kfree_skb for the purposes here

skb_frag_t      frags[MAX_SKB_FRAGS];		YES (<nr_frags, if dataref->0 etc)

LEGEND:

*<-used in kfree_skb
 N<-offset from start of shinfo		    offset from end of shinfo-> -N

v3.1:

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= 32 & 64 byte cache line =-=-=-=-=
 -40									-384
--------------------------------------------- 32 byte cache line --------------
 -8									-352
struct skb_shared_info {
*0	unsigned short  nr_frags;					-344
 2	unsigned short  gso_size;					-342
        /* Warning: this field is not always filled in (UFO)! */
 4	unsigned short  gso_segs;					-340
 6	unsigned short  gso_type;					-338
 8	__be32          ip6_frag_id;					-336
*12	__u8            tx_flags;					-332
*16	struct sk_buff  *frag_list;					-328
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= 32 & 64 byte cache line =-=-=-=-=
 24	struct skb_shared_hwtstamps hwtstamps;				-320

        /*
         * Warning : all fields before dataref are cleared in __alloc_skb()
         */
*40	atomic_t        dataref;					-304

        /* Intermediate layers must ensure that destructor_arg
         * remains valid until skb destructor */
 48	void *          destructor_arg;					-296

        /* must be last field, see pskb_expand_head() */
--------------------------------------------- 32 byte cache line --------------
*56	skb_frag_t      frags[MAX_SKB_FRAGS];				-16x18 
									= -288
									=  9x32
									or 4.5x64
									or 2.25x128
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= 32 & 64 & 128 byte cache line =-=
 344	= 10.75x32 or 5.375x64 or 2.6875x128				-0
};

skb patches v2:

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= 32 & 64 byte cache line =-=-=-=-=
 -56									-512
--------------------------------------------- 32 byte cache line --------------
 -24									-480
struct skb_shared_info {
*0	unsigned char	nr_frags;					-456
*1	__u8		tx_flags;					-455
 2	unsigned short	gso_size;					-454
	/* Warning: this field is not always filled in (UFO)! */
 4	unsigned short	gso_segs;					-452
 6	unsigned short  gso_type;					-450
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= 32 & 64 byte cache line =-=-=-=-=
*8	struct sk_buff	*frag_list;					-448
 16	struct skb_shared_hwtstamps hwtstamps;				-440
 32	__be32          ip6_frag_id;					-424

	/*
	 * Warning : all fields before dataref are cleared in __alloc_skb()
	 */
*36	atomic_t	dataref;					-420

	/* Intermediate layers must ensure that destructor_arg
	 * remains valid until skb destructor */
--------------------------------------------- 32 byte cache line --------------
 40	void *		destructor_arg;					-416

	/* must be last field, see pskb_expand_head() */
*48	skb_frag_t	frags[MAX_SKB_FRAGS];				-24*17
									= -408
									=  12.75x32
									or 6.375x64
									or 3.1875x128
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= 32 & 64 & 128 byte cache line =-=
 456	= 14.25x32 or 7.125x64 or 3.5625x128				-0
};

skb patches + put destructor_arg first

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= 32 & 64 byte cache line =-=-=-=-=
 -56									-512
--------------------------------------------- 32 byte cache line
 -24									-480
struct skb_shared_info {
	/* Intermediate layers must ensure that destructor_arg
	 * remains valid until skb destructor */
 0	void *		destructor_arg;					-456

	/* Warning all fields from here until dataref are cleared in __alloc_skb() */
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= 32 & 64 byte cache line =-=-=-=-=
*8	unsigned char	nr_frags;					-448
*9	__u8		tx_flags;					-447
 10	unsigned short	gso_size;					-446
	/* Warning: this field is not always filled in (UFO)! */
 12	unsigned short	gso_segs;					-444
 14	unsigned short  gso_type;					-442
*16	struct sk_buff	*frag_list;					-440
 24	struct skb_shared_hwtstamps hwtstamps;				-432
--------------------------------------------- 32 byte cache line --------------
 40	__be32          ip6_frag_id;					-416

	/*
	 * Warning : all fields before dataref are cleared in __alloc_skb()
	 */
*44	atomic_t	dataref;					-412

	/* must be last field, see pskb_expand_head() */
*48	skb_frag_t	frags[MAX_SKB_FRAGS];				-24*17
									= -408
									=  12.75x32
									or 6.375x64
									or 3.1875x128
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= 32 & 64 & 128 byte cache line =-=
}; 456 = 14.25x32 or 7.125x64 or 3.5625x128
