From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4]: Kill fastpath_{skb,cnt}_hint.
Date: Fri, 02 Mar 2007 22:22:50 -0800 (PST)
Message-ID: <20070302.222250.41632359.davem@davemloft.net>
References: <20070228.114949.18302561.davem@davemloft.net>
	<20070301181340.GD25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51567
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751125AbXCCGWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 01:22:51 -0500
In-Reply-To: <20070301181340.GD25760@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Thu, 1 Mar 2007 20:13:40 +0200

> If you take this approach it makes sense to also remove the sorting of
> SACKs, the traversal of the SACK blocks will not start from the
> beginning anyway which was the reason for this sorting in the first
> place.
> 
> One drawback for this approach is that you now walk the entire sack
> block when you advance one packet. If you consider a 10,000 packet queue
> which had several losses at the beginning and a large sack block that
> advances from the middle to the end you'll walk a lot of packets for
> that one last stretch of a sack block.
> 
> One way to handle that is to use the still existing sack fast path to
> detect this case and calculate what is the sequence number to search
> for. Since you know what was the end_seq that was handled last, you can
> search for it as the start_seq and go on from there. Does it make sense?

Thanks for the feedback and these great ideas.

BTW, I think I figured out a way to get rid of
lost_{skb,cnt}_hint.  The fact of the matter in this case is that
the setting of the tag bits always propagates from front of the queue
onward.  We don't get holes mid-way.

So what we can do is search the RB-tree for high_seq and walk
backwards.  Once we hit something with TCPCB_TAGBITS set, we
stop processing as there are no earlier SKBs which we'd need
to do anything with.

Do you see any problems with that idea?

scoreboard_skb_hint is a little bit trickier, but it is a similar
case to the tcp_lost_skb_hint case.  Except here the termination
condition is a relative timeout instead of a sequence number and
packet count test.

Perhaps for that we can remember some state from the
tcp_mark_head_lost() we do first.  In fact, we can start
the queue walk from the latest packet which tcp_mark_head_lost()
marked with a tag bit.

Basically these two algorithms are saying:

1) Mark up to smallest of 'lost' or tp->high_seq.
2) Mark packets after those processed in #1 which have
   timed out.

Right?
