From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/4]: Store TCP retransmit queue in RB-tree
Date: Wed, 28 Feb 2007 11:48:27 -0800 (PST)
Message-ID: <20070228.114827.71091072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48282
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751458AbXB1Ts3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 14:48:29 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E4D11AE426D
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 11:48:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'd had this idea in the back of my head for a while and
finally I tried it out yesterday to see how it would look.

Basically, we store the write queue packets in an RB tree
keyed by start sequence number.  The objective is to use
this information to parse the SACK blocks more efficiently
and get rid of the "hints" we use to optimize that code
currently.

The big win is that we can now find the start of any sequence of
packets in the retransmit queue in O(log n) time.  The downsides
are numerous, such as:

1) Increased state stored in sk_buff, we need to store an rb_node
   there which is 3 points :-(((

   It is possible that perhaps we could alias the rb_node with the
   existing next/prev pointers in sk_buff, but like the VMA code
   in the Linux MM, I decided to keep the linked list around since
   that's the fastest for all the other operations.  rb_next()
   and rb_prev() would need to be used otherwise, and those aren't
   the cheapest.

2) We eat a O(log n) insert and delete for every packet now, even
   when no SACK processing occurs.

   I think this part can be sped up.  We insert to the tail on
   new packets, so we can take the existing tail packet and do
   something similar to "rb_next()" to find the insertion point.
   But we'd still have the cost of the potential tree rotations.

Even if none of the RB stuff is useful, the first patch which
abstracts all of the write queue accesses should probably go in
because it allows experimentation in this area to be done quite
effortlessly.

One thing I'm not sure about wrt. the RB tree stuff is that although
we key on start sequence of the SKB, we do change this when trimming
the head of TSO packets.  I think this is "OK" because such changes
would never change the position of the SKB within the RB tree, but I'd
like someone else to think that is true too :-) Worst case we could
key on end sequence which never ever changes.  Actually, the whole
case of tcp SKB chopping and mid-queue insert/delete, and it's effect
on the RB tree entires needs to be audited if we are to take this
idea seriously.

I wonder if there is an algorithm better suited to this application.
It's an interval search, which needs fast insert to the tail and
fast delete from the head.

Another aspect of this patch are the per-SKB packet counts (I
named them "fack_count" but I'd rename that to "packet_count"
when I ever commited it for real).  The idea is that this can
eliminate most of the packet count hints in the tcp_sock.
The algorithm is simple:

1) On skb insert:
   if write queue empty, assign packet_count of zero
   else, assign packet_count of
		tail_skb->packet_count + tcp_skb_pcount(tail_skb)
2) To get normalized packet_count of arbitrary SKB:
   	(skb->packet_count - head_skb->packet_count)

You can see in patch 4 how fastpath_cnt_hint is replaced by
that logic.

I added the packet count to TCP_SKB_CB() and that takes it up to the
limit of 48 bytes of skb->cb[] on 64-bit architectures.  I wanted
to steal TCP_SKB_CB()->ack_seq for this, but that's used for some
SACK logic already.

There are some pains necessary to keep the counts correct, and in
some cases I just recalculate the whole queue's packet counts
after the insert point.  I'm sure this can be improved.

Back to the RB tree, there is another way to go after at least the
SACK processing overhead, and that is to maintain a not-sacked
table which is the inverse of the SACK blocks.  There are a few
references out there which discuss that kind of approach.

Some of the other hints are hard to eliminate.  In particular the
cached retransmit state is non-trivial to replace with logic that
does not require state.  The RB tree can't help, and we can't even
use the per-SKB packet_count for the count hints because one of them
wants to remember how many packets in the queue were marked lost,
for example.

If we could get rid of all the hints, that would be an easy
44 bytes killed in tcp_sock on 64-bit.

Anyways, here come the patches, enjoy.
