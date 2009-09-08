From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 1/1] netpoll: fix race between skb_queue_len and
 skb_dequeue
Date: Tue, 08 Sep 2009 12:27:05 -0500
Message-ID: <1252430825.7145.55.camel@calx>
References: <1252396189.16528.19.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: DDD <Dongdong.deng@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([173.11.57.241]:60498 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074AbZIHR3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2009 13:29:41 -0400
In-Reply-To: <1252396189.16528.19.camel@dengdd-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-09-08 at 15:49 +0800, DDD wrote:
> This race will break the messages order.
> 
> Sequence of events in the problem case:
> 
> Assume there is one skb "A" in skb_queue and the next action of
> netpoll_send_skb() is: sending out "B" skb.
> The right order of messages should be: send A first, then send B.
> 
> But as following orders, it will send B first, then send A.

I would say no, the order of messages A and B queued on different CPUs
is undefined. The only issue is that we can queue a message A on CPU0,
then causally trigger a message on CPU1 B that arrives first. But bear
in mind that the message A >>may never arrive<< because the message is
about a lockup that kills processing of delayed work.

Generally speaking, queueing should be a last ditch effort. We should
instead aim to deliver all messages immediately, even if they might be
out of order. Because out of order is better than not arriving at all.

-- 
http://selenic.com : development and support for Mercurial and Linux


