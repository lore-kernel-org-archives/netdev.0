From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: neigh_lookup lockdep warning
Date: Sun, 3 Sep 2006 21:32:50 +1000
Message-ID: <20060903113250.GB12580@gondor.apana.org.au>
References: <20060903012659.GA28183@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38150 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751290AbWICLdT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Sep 2006 07:33:19 -0400
To: Dave Jones <davej@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <20060903012659.GA28183@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 03, 2006 at 01:26:59AM +0000, Dave Jones wrote:
> Seen during boot of a 2.6.18rc5-git1 based kernel.
> 
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.17-1.2608.fc6 #1
> -------------------------------------------------------
> swapper/0 is trying to acquire lock:
>  (&tbl->lock){-+-+}, at: [<c05bdf97>] neigh_lookup+0x50/0xaf
> 
> but task is already holding lock:
>  (&list->lock#3){-+..}, at: [<c05bf677>] neigh_proxy_process+0x20/0xc2

Looks like a validator bug.  Arjan, it seems that the removal of the
lockdep_set_class from skb_queue_head_init doesn't completely cure
the problem.

> the existing dependency chain (in reverse order) is:
> 
> -> #2 (&list->lock#3){-+..}:
>        [<c043c09a>] lock_acquire+0x4b/0x6d
>        [<c061411f>] _spin_lock_irqsave+0x22/0x32
>        [<c05b451f>] skb_dequeue+0x12/0x43
>        [<c05b523a>] skb_queue_purge+0x14/0x1b
>        [<c05be990>] neigh_update+0x34a/0x3a6

This list->lock is n->arp_queue.

>        [<c05f0f6e>] arp_process+0x4ad/0x4e7
>        [<c05f107c>] arp_rcv+0xd4/0xf1
>        [<c05b942c>] netif_receive_skb+0x205/0x274
>        [<c7bb0566>] rhine_napipoll+0x28d/0x449 [via_rhine]
>        [<c05baf73>] net_rx_action+0x9d/0x196
>        [<c04293a7>] __do_softirq+0x78/0xf2
>        [<c0406673>] do_softirq+0x5a/0xbe

...
 
> -> #0 (&tbl->lock){-+-+}:
>        [<c043c09a>] lock_acquire+0x4b/0x6d
>        [<c0613f02>] _read_lock_bh+0x1e/0x2d
>        [<c05bdf97>] neigh_lookup+0x50/0xaf
>        [<c05bf0b9>] neigh_event_ns+0x2c/0x77
>        [<c05f0e2a>] arp_process+0x369/0x4e7
>        [<c05f10a1>] parp_redo+0x8/0xa
>        [<c05bf6bd>] neigh_proxy_process+0x66/0xc2

This list->lock is tbl->proxy_queue.

>        [<c042dc58>] run_timer_softirq+0x108/0x167
>        [<c04293a7>] __do_softirq+0x78/0xf2
>        [<c0406673>] do_softirq+0x5a/0xbe

BTW, out of the last four validator reports I've read three have turned
out to be genuine bugs.  So you guys have done a fantastic job!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-- 
VGER BF report: U 0.5
