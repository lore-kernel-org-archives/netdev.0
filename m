From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: neigh_lookup lockdep bug.
Date: Tue, 01 Aug 2006 15:00:58 +0200
Message-ID: <1154437278.3113.0.camel@laptopd505.fenrus.org>
References: <20060731205004.GA31845@redhat.com>
	 <20060731.140252.31448010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org, mingo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e-nvb.com ([69.27.17.200]:65504 "EHLO e-nvb.com")
	by vger.kernel.org with ESMTP id S1750838AbWHANBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 09:01:39 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060731.140252.31448010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-31 at 14:02 -0700, David Miller wrote:
> From: Dave Jones <davej@redhat.com>
> Date: Mon, 31 Jul 2006 16:50:04 -0400
> 
> > 2.6.18rc2-gitSomething on my firewall box just triggered this..
> 
> Lockdep is perhaps confused.
> 
> > [515613.904945] swapper/0 is trying to acquire lock:
> > [515613.931489]  (&tbl->lock){-+-+}, at: [<c05b5d63>] neigh_lookup+0x50/0xaf
> > [515613.964369] 
> > [515613.964373] but task is already holding lock:
> > [515614.006550]  (&skb_queue_lock_key){-+..}, at: [<c05b741c>] neigh_proxy_process+0x20/0xc2
> 
> The skb_queue_lock in question is &tbl->proxy_queue.lock
> 
> > [515614.103459] the existing dependency chain (in reverse order) is:
> > [515614.148752] 
> > [515614.148755] -> #2 (&skb_queue_lock_key){-+..}:
> > [515614.188880]        [<c043bf43>] lock_acquire+0x4b/0x6c
> > [515614.215554]        [<c06089a7>] _spin_lock_irqsave+0x22/0x32
> > [515614.243606]        [<c05ac2e3>] skb_dequeue+0x12/0x43
> > [515614.269657]        [<c05acffe>] skb_queue_purge+0x14/0x1b
> > [515614.296565]        [<c05b673e>] neigh_update+0x317/0x353
> 
> This is a different queue lock, namely &neigh->arp_queue.lock
> 
> Like the ipv6 trace we got yesterday from Matt Domsche, lockdep
> is aparently confusing two instances of the skb_queue_lock_key

we fixed lockdep to have this lock key to be per skb queue ... didn't
you put that patch in rawhide Dave (J) ?

