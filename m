From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH 4/4]: Kill fastpath_{skb,cnt}_hint.
Date: Thu, 1 Mar 2007 20:13:40 +0200
Message-ID: <20070301181340.GD25760@galon.ev-en.org>
References: <20070228.114949.18302561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:28668
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965473AbXCASNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 13:13:41 -0500
Content-Disposition: inline
In-Reply-To: <20070228.114949.18302561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [070228 21:49]:
> 
> commit 71b270d966cd42e29eabcd39434c4ad4d33aa2be
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Tue Feb 27 19:28:07 2007 -0800
> 
>     [TCP]: Kill fastpath_{skb,cnt}_hint.
>     
>     Now that we have per-skb fack_counts and an interval
>     search mechanism for the retransmit queue, we don't
>     need these things any more.
>     
>     Instead, as we traverse the SACK blocks to tag the
>     queue, we use the RB tree to lookup the first SKB
>     covering the SACK block by sequence number.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>

If you take this approach it makes sense to also remove the sorting of
SACKs, the traversal of the SACK blocks will not start from the
beginning anyway which was the reason for this sorting in the first
place.

One drawback for this approach is that you now walk the entire sack
block when you advance one packet. If you consider a 10,000 packet queue
which had several losses at the beginning and a large sack block that
advances from the middle to the end you'll walk a lot of packets for
that one last stretch of a sack block.

One way to handle that is to use the still existing sack fast path to
detect this case and calculate what is the sequence number to search
for. Since you know what was the end_seq that was handled last, you can
search for it as the start_seq and go on from there. Does it make sense?

Baruch
