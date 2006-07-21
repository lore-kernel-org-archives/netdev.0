From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Thu, 20 Jul 2006 21:55:04 -0700 (PDT)
Message-ID: <20060720.215504.41641534.davem@davemloft.net>
References: <20060720164100.GA9213@ms2.inr.ac.ru>
	<20060720210849.GA28715@tservice.net.ru>
	<20060720225908.GA18362@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5833
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030458AbWGUEzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 00:55:06 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060720225908.GA18362@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Fri, 21 Jul 2006 02:59:08 +0400

> > Moving protocol (no matter if it is TCP or not) closer to user allows
> > naturally control the dataflow - when user can read that data(and _this_
> > is the main goal), user acks, when it can not - it does not generate
> > ack. In theory
> 
> To all that I rememeber, in theory absence of feedback leads
> to loss of control yet. The same is in practice, unfortunately.
> You must say that window is closed, otherwise sender is totally
> confused.

Correct, and too large delay even results in retransmits.  You can say
that RTT will be adjusted by delay of ACK, but if user context
switches cleanly at the beginning, resulting in near immediate ACKs,
and then blocks later you will get spurious retransmits.  Alexey's
example of blocking on a disk write is a good example.  I really don't
like when pure NULL data sinks are used for "benchmarking" these kinds
of things because real applications 1) touch the data, 2) do something
with that data, and 3) have some life outside of TCP!

If you optimize an application that does nothing with the data it
receives, you have likewise optimized nothing :-)

All this talk reminds me of one thing, how expensive tcp_ack() is.
And this expense has nothing to do with TCP really.  The main cost is
purging and freeing up the skbs which have been ACK'd in the
retransmit queue.

So tcp_ack() sort of inherits the cost of freeing a bunch of SKBs
which haven't been touched by the cpu in some time and are thus nearly
guarenteed to be cold in the cache.

This is the kind of work we could think about batching to user
sleeping on some socket call.

Also notice that retransmit queue is potentially a good use of an
array similar VJ netchannel lockless queue data structure. :)

BTW, notice that TSO makes this work touch less skb state.  TSO also
decreases cpu utilization.  I think these two things are no
coincidence. :-)

I have even toyed with the idea of eventually abstracting the
retransmit queue into a pure data representation.  The skb_shinfo()
page vector is very nearly this already.  Or, a less extreme idea
where we have fully retained huge TSO skbs, but we do not chop them up
to create smaller TSO frames.  Instead, we add "offset" GSO attribute
which is used in the clones.

Calls to tso_fragment() would be replaced with pure clones and
adjustment of skb->len and the new "skb->gso_offset" in the clone.
Rest of the logic would remain identical except that non-linear data
would start "skb->gso_offset" bytes into the skb_shinfo() described
area.

In this way we could also set tp->xmit_size_goal to it's maximum
possible value, always.  Actually, I was looking at this the other day
and this clamping of xmit_size_goal to 1/2 max_window is extremely
dubious.  In fact it's downright wrong, only MSS needs this limiting
for sender side SWS avoidance.
