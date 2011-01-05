From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] net_sched: pfifo_head_drop problem
Date: Wed, 05 Jan 2011 18:00:50 +0100
Message-ID: <1294246850.2775.244.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	Patrick McHardy <kaber@trash.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54929 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170Ab1AEROC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 12:14:02 -0500
Received: by wyb28 with SMTP id 28so15553116wyb.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 09:14:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While reviewing CHOKe stuff, I found following problem :

commit 57dbb2d83d100ea (sched: add head drop fifo queue)
introduced pfifo_head_drop, and broke the invariant that
sch->bstats.bytes and sch->bstats.packets are COUNTER (increasing
counters only)

This can break estimators because est_timer() handle unsigned deltas
only. A decreasing counter can then give a huge unsigned delta.

My suggestion would be to change things so that sch->bstats.bytes and
sch->bstats.packets are incremented in dequeue() only, not at enqueue()
time.

It would be more sensible anyway for very low speeds, and big bursts.
Right now, if we drop packets, they still are accounted in estimators.

Or maybe my understanding of estimators is wrong, and only apply to
enqueue rate, not dequeue rate ?

If so, we should remove the 

sch->bstats.bytes -= qdisc_pkt_len(skb_head);
sch->bstats.packets--;

done in pfifo_tail_enqueue() in case we drop the head skb.


My preference would be to add dropped pack/byte rates to estimators...
It might be good for tuning.



