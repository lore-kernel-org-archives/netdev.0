From: David Miller <davem@davemloft.net>
Subject: Re: neigh_lookup lockdep bug.
Date: Mon, 31 Jul 2006 14:02:52 -0700 (PDT)
Message-ID: <20060731.140252.31448010.davem@davemloft.net>
References: <20060731205004.GA31845@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arjan@infradead.org, mingo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52386
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030457AbWGaVDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 17:03:36 -0400
To: davej@redhat.com
In-Reply-To: <20060731205004.GA31845@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Mon, 31 Jul 2006 16:50:04 -0400

> 2.6.18rc2-gitSomething on my firewall box just triggered this..

Lockdep is perhaps confused.

> [515613.904945] swapper/0 is trying to acquire lock:
> [515613.931489]  (&tbl->lock){-+-+}, at: [<c05b5d63>] neigh_lookup+0x50/0xaf
> [515613.964369] 
> [515613.964373] but task is already holding lock:
> [515614.006550]  (&skb_queue_lock_key){-+..}, at: [<c05b741c>] neigh_proxy_process+0x20/0xc2

The skb_queue_lock in question is &tbl->proxy_queue.lock

> [515614.103459] the existing dependency chain (in reverse order) is:
> [515614.148752] 
> [515614.148755] -> #2 (&skb_queue_lock_key){-+..}:
> [515614.188880]        [<c043bf43>] lock_acquire+0x4b/0x6c
> [515614.215554]        [<c06089a7>] _spin_lock_irqsave+0x22/0x32
> [515614.243606]        [<c05ac2e3>] skb_dequeue+0x12/0x43
> [515614.269657]        [<c05acffe>] skb_queue_purge+0x14/0x1b
> [515614.296565]        [<c05b673e>] neigh_update+0x317/0x353

This is a different queue lock, namely &neigh->arp_queue.lock

Like the ipv6 trace we got yesterday from Matt Domsche, lockdep
is aparently confusing two instances of the skb_queue_lock_key

> [515614.677724] -> #0 (&tbl->lock){-+-+}:
> [515614.707327]        [<c043bf43>] lock_acquire+0x4b/0x6c
> [515614.729897]        [<c060878a>] _read_lock_bh+0x1e/0x2d
> [515614.752546]        [<c05b5d63>] neigh_lookup+0x50/0xaf
> [515614.774754]        [<c05b6e5e>] neigh_event_ns+0x2c/0x77
> [515614.797271]        [<c05e88c7>] arp_process+0x366/0x4e4
> [515614.819349]        [<c05e8b3e>] parp_redo+0x8/0xa
> [515614.839660]        [<c05b7462>] neigh_proxy_process+0x66/0xc2
> [515614.862931]        [<c042db48>] run_timer_softirq+0x108/0x167
> [515614.886048]        [<c04293d5>] __do_softirq+0x78/0xf2
> [515614.907136]        [<c040662f>] do_softirq+0x5a/0xbe
> [515614.927553] 

And this path takes &neigh->proxy_queue.lock, then &tbl->lock

I don't see the problem.
