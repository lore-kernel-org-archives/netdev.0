From: David Miller <davem@davemloft.net>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
 overwritten
Date: Thu, 17 Jul 2008 19:13:37 -0700 (PDT)
Message-ID: <20080717.191337.76211017.davem@davemloft.net>
References: <20080717214222.GA29449@elte.hu>
	<19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com>
	<20080717235254.GA6833@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penberg@cs.helsinki.fi, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51002
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751959AbYGRCNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 22:13:38 -0400
In-Reply-To: <20080717235254.GA6833@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 18 Jul 2008 01:52:54 +0200

> kmemcheck: Caught 8-bit read from uninitialized memory (f653ad24)
> iiiiiiiiiiiiiiiiuuuuuuuuuuuuuuuuuuuuuiuuuuuuuuuuuuuuuuuuuuuuuuuu
>                                     ^
> 
> Pid: 2484, comm: arping Not tainted (2.6.26-tip #20187)
> EIP: 0060:[<c05e973c>] EFLAGS: 00010282 CPU: 0
> EIP is at __copy_skb_header+0x7c/0x100
> EAX: 00000000 EBX: f653acc0 ECX: f653ac00 EDX: f653ac00
> ESI: f653ac50 EDI: f653ad10 EBP: c09b9e84 ESP: c09ddaa8
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> CR0: 8005003b CR2: f71c2700 CR3: 36513000 CR4: 000006d0
> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> DR6: ffff4ff0 DR7: 00000400
>  [<c05e97e7>] __skb_clone+0x27/0xe0
>  [<c05eb101>] skb_clone+0x41/0x60
>  [<c065cbf1>] packet_rcv+0xc1/0x290
>  [<c05f07ad>] netif_receive_skb+0x20d/0x400
>  [<c03b2aa7>] e1000_receive_skb+0x47/0x180
>  [<c03b3983>] e1000_clean_rx_irq+0x223/0x2e0
>  [<c03b225b>] e1000_clean+0x5b/0x200
>  [<c05f29db>] net_rx_action+0xfb/0x160
>  [<c0129092>] __do_softirq+0x82/0xf0
>  [<c0105b8a>] call_on_stack+0x1a/0x30
> 
> false positive? Find below the quick hacks i did to pre-initialize skb 
> allocations that have RX DMA into them.

Maybe.  Every SKB object allocated is fully initialized
in __alloc_skb():

	/*
	 * Only clear those fields we need to clear, not those that we will
	 * actually initialise below. Hence, don't put any more fields after
	 * the tail pointer in struct sk_buff!
	 */
	memset(skb, 0, offsetof(struct sk_buff, tail));

That leaves the following trailing members of struct sk_buff:

	/* These elements must be at the end, see alloc_skb() for details.  */
	sk_buff_data_t		tail;
	sk_buff_data_t		end;
	unsigned char		*head,
				*data;
	unsigned int		truesize;
	atomic_t		users;

which are the explicitly initialized right after the quotes memset().

	skb->truesize = size + sizeof(struct sk_buff);
	atomic_set(&skb->users, 1);
	skb->head = data;
	skb->data = data;
	skb_reset_tail_pointer(skb);
	skb->end = skb->tail + size;

When we clone, there are probably some fields we don't copy over
explicitly.  And we usually do that because they don't matter or
if they do the caller will take care of it.
