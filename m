From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH 1/3] Advance fast path pointer for first block only
Date: Thu, 1 Feb 2007 09:38:57 +0200
Message-ID: <20070201073857.GY22455@galon.ev-en.org>
References: <20070129071339.24050.21052.sendpatchset@galon.ev-en.org> <20070131.124830.93210236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:33402
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030527AbXBAHi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 02:38:59 -0500
Content-Disposition: inline
In-Reply-To: <20070131.124830.93210236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [070131 22:48]:
> From: Baruch Even <baruch@ev-en.org>
> Date: Mon, 29 Jan 2007 09:13:39 +0200
> 
> > Only advance the SACK fast-path pointer for the first block, the fast-path
> > assumes that only the first block advances next time so we should not move the
> > skb for the next sack blocks.
> > 
> > Signed-Off-By: Baruch Even <baruch@ev-en.org>
> > 
> > ---
> > 
> > I'm not sure about the fack_count part, this patch changes the value that is
> > maintained in this case.
> 
> I'm not sure about this patch :-)

That's why we have a gatekeeper for. To keep us on our toes.

> The fastpath is being used for two things here, I believe.
> 
> First, it's being used to monitor the expanding of the initial
> SACK block, as you note.  This is clear by the fact that we
> only use the fastpath cache on future calls when this code path
> triggers:
> 
> 	if (flag)
> 		num_sacks = 1;
>
> because otherwise we clear the fastpath cache to NULL.

True.

> But it's also being used in this loop you are editing to remember
> where we stopped in the previous iteration of the loop.  With your
> change it will always walk the whole retransmit queue from the end of
> the first SACK block, whereas before it would iterate starting at the
> last SKB visited at the end of the previous sack block processed by
> the loop.

OK. When I did the patch I forgot that by this stage we have sorted the
SACK blocks and we can't rely on the expanding block to be the first.

> I'll use this opportunity to say I'm rather unhappy with all of
> these fastpath hinting schemes.  They chew up a ton of space in
> the tcp_sock because we have several pointers for each of the
> different queue states we can cache and those eat 8 bytes a
> piece on 64-bit.

Understood. I do intend to look at different ways to organise the data
and do the work, but I wouldn't hold my breath for this.

One option to limit the damage of slow processing of SACK is to limit
the amount of work we are willing to do for SACK, if we limit the SACK
walk to 1000 packets we will prevent the worst and I believe that we
will still not cause much harm to the TCP recovery. This belief will
need to be checked, the value 1000 will also need to be checked and
maybe made configurable.

This is obviously a hack, but it will guarantee that we never cause the
ACK clock to die like it can now.

> We can probably fix the bug and preserve the inter-iteration
> end-SKB caching by having local variable SKB/fack_count caches
> in this function, and only updating the tcp_sock cache values
> for the first SACK block.
> 
> Maybe something like this?

Ah, now I see what you meant and it is indeed another issue with my
patch. I'll change my patch with this fix and fix the issue of i == 0
being the wrong way to cache only the originally first SACK block.

Baruch
