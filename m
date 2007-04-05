From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFT] proxy arp deadlock possible
Date: Thu, 5 Apr 2007 15:32:01 +1000
Message-ID: <20070405053201.GA8423@gondor.apana.org.au>
References: <E1HZG5h-0001oF-00@gondolin.me.apana.org.au> <1175735443.3270.11.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	davem@davemloft.net, mingo@elte.hu, davej@redhat.com,
	netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2256 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161206AbXDEFcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 01:32:43 -0400
Content-Disposition: inline
In-Reply-To: <1175735443.3270.11.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 04, 2007 at 06:10:42PM -0700, Arjan van de Ven wrote:
> 
> what's the exact lockdep output here?

Here's the original report:

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.20-1.2933.fc6debug #1
-------------------------------------------------------
swapper/0 is trying to acquire lock:
 (&tbl->lock){-+-+}, at: [<c05d5664>] neigh_lookup+0x43/0xa2

but task is already holding lock:
 (&list->lock#4){-+..}, at: [<c05d65c8>] neigh_proxy_process+0x20/0xc2

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (&list->lock#4){-+..}:
       [<c043f4f2>] __lock_acquire+0x913/0xa43
       [<c043f933>] lock_acquire+0x56/0x6f
       [<c06325df>] _spin_lock_irqsave+0x34/0x44
       [<c05cbb87>] skb_dequeue+0x12/0x43
       [<c05cc9d4>] skb_queue_purge+0x14/0x1b
       [<c05d5b70>] neigh_update+0x349/0x3a5
       [<c060cd37>] arp_process+0x4d1/0x50a
       [<c060ce53>] arp_rcv+0xe3/0x100
       [<c05d0e43>] netif_receive_skb+0x2db/0x35a
       [<c05d2806>] process_backlog+0x95/0xf6
       [<c05d29ed>] net_rx_action+0xa1/0x1a8
       [<c042c1f6>] __do_softirq+0x6f/0xe2
       [<c04063c6>] do_softirq+0x61/0xd0
       [<ffffffff>] 0xffffffff

-> #1 (&n->lock){-+-+}:
       [<c043f4f2>] __lock_acquire+0x913/0xa43
       [<c043f933>] lock_acquire+0x56/0x6f
       [<c063231e>] _write_lock+0x2b/0x38
       [<c05d74b7>] neigh_periodic_timer+0x99/0x138
       [<c042f053>] run_timer_softirq+0x104/0x168
       [<c042c1f6>] __do_softirq+0x6f/0xe2
       [<c04063c6>] do_softirq+0x61/0xd0
       [<ffffffff>] 0xffffffff

-> #0 (&tbl->lock){-+-+}:
       [<c043f3f3>] __lock_acquire+0x814/0xa43
       [<c043f933>] lock_acquire+0x56/0x6f
       [<c06323d6>] _read_lock_bh+0x30/0x3d
       [<c05d5664>] neigh_lookup+0x43/0xa2
       [<c05d6317>] neigh_event_ns+0x2c/0x7a
       [<c060cbec>] arp_process+0x386/0x50a
       [<c060ce78>] parp_redo+0x8/0xa
       [<c05d660e>] neigh_proxy_process+0x66/0xc2
       [<c042f053>] run_timer_softirq+0x104/0x168
       [<c042c1f6>] __do_softirq+0x6f/0xe2
       [<c04063c6>] do_softirq+0x61/0xd0
       [<ffffffff>] 0xffffffff

other info that might help us debug this:

1 lock held by swapper/0:
 #0:  (&list->lock#4){-+..}, at: [<c05d65c8>] neigh_proxy_process+0x20/0xc2

stack backtrace:
 [<c04051dd>] show_trace_log_lvl+0x1a/0x2f
 [<c0405782>] show_trace+0x12/0x14
 [<c0405806>] dump_stack+0x16/0x18
 [<c043dcf5>] print_circular_bug_tail+0x5f/0x68
 [<c043f3f3>] __lock_acquire+0x814/0xa43
 [<c043f933>] lock_acquire+0x56/0x6f
 [<c06323d6>] _read_lock_bh+0x30/0x3d
 [<c05d5664>] neigh_lookup+0x43/0xa2
 [<c05d6317>] neigh_event_ns+0x2c/0x7a
 [<c060cbec>] arp_process+0x386/0x50a
 [<c060ce78>] parp_redo+0x8/0xa
 [<c05d660e>] neigh_proxy_process+0x66/0xc2
 [<c042f053>] run_timer_softirq+0x104/0x168
 [<c042c1f6>] __do_softirq+0x6f/0xe2
 [<c04063c6>] do_softirq+0x61/0xd0
 =======================

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
