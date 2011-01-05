From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG] net_sched: pfifo_head_drop problem
Date: Wed, 5 Jan 2011 09:15:47 -0800
Message-ID: <20110105091547.200b49ad@nehalam>
References: <1294246850.2775.244.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	Patrick McHardy <kaber@trash.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47232 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711Ab1AERPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jan 2011 12:15:50 -0500
In-Reply-To: <1294246850.2775.244.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Jan 2011 18:00:50 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> While reviewing CHOKe stuff, I found following problem :
> 
> commit 57dbb2d83d100ea (sched: add head drop fifo queue)
> introduced pfifo_head_drop, and broke the invariant that
> sch->bstats.bytes and sch->bstats.packets are COUNTER (increasing
> counters only)
> 
> This can break estimators because est_timer() handle unsigned deltas
> only. A decreasing counter can then give a huge unsigned delta.
> 
> My suggestion would be to change things so that sch->bstats.bytes and
> sch->bstats.packets are incremented in dequeue() only, not at enqueue()
> time.
> 
> It would be more sensible anyway for very low speeds, and big bursts.
> Right now, if we drop packets, they still are accounted in estimators.
> 
> Or maybe my understanding of estimators is wrong, and only apply to
> enqueue rate, not dequeue rate ?
> 
> If so, we should remove the 
> 
> sch->bstats.bytes -= qdisc_pkt_len(skb_head);
> sch->bstats.packets--;
> 
> done in pfifo_tail_enqueue() in case we drop the head skb.
> 
> 
> My preference would be to add dropped pack/byte rates to estimators...
> It might be good for tuning.

Agreed counters should reflect dequeued packets not enqueued packets.


-- 
