From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Thu, 14 Aug 2014 20:36:58 -0400
Message-ID: <20140815003657.GB11038@localhost.localdomain>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57309 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbaHOAhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 20:37:19 -0400
Content-Disposition: inline
In-Reply-To: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 05:09:54PM -0700, Eric Dumazet wrote:
> It looks like PACKET_V3 has no check that a packet can always fit in a
> block.
> 
> Its trivial with GRO to break the assumption and write into kernel
> memory.
> 
> [  840.989881] BUG: unable to handle kernel paging req0
> [  840.997667] IP: [<ffffffff9ed17466>] memcpy+0x6/0x110
> [  841.003314] PGD 2068b067 PUD 20371d3067 PMD 20370e7067 PTE 80000001dd6b2060
> [  841.011120] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
> [  841.016199] Modules linked in: nf_conntrack_ipv6 nf_defrag_ipv6 xt_NFLOG nfnetlink_log nfo
> [  841.060739] CPU: 12 PID: 0 Comm: swapper/12 Not tainted 3.16
> [  841.077824] task: ffff880119ad2580 ti: ffff880119ad8000 task.ti: ffff880119ad8000
> [  841.086173] RIP: 0010:[<ffffffff9ed17466>]  [<ffffffff9ed17466>] memcpy+0x6/0x110
> [  841.094531] RSP: 0018:ffff880fffac3b48  EFLAGS: 00010286
> [  841.100461] RAX: ffff8801dd6b1b9c RBX: 0000000000000a74 RCX: 00000000000000d6
> [  841.108412] RDX: 000000000000053a RSI: ffff880132a769ce RDI: ffff8801dd6b2000
> [  841.116373] RBP: ffff880fffac3bb0 R08: 0000000000000ff0 R09: ffff8801dd6b1b9c
> [  841.124332] R10: ffff8801bb529f00 R11: 000000000000053a R12: 0000000000000ab6
> [  841.132292] R13: ffff880119ad8000 R14: 0000000000000001 R15: ffff8801bb529f00
> [  841.140252] FS:  0000000000000000(0000) GS:ffff880fffac0000(0000) knlGS:0000000000000000
> [  841.149279] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  841.155689] CR2: ffff8801dd6b2000 CR3: 000000001f40e000 CR4: 00000000001427e0
> [  841.163649] Stack:
> [  841.165888]  ffffffff9eed1a15 ffff8801e1d06800 ffff88010000053a 000000000000053a
> [  841.174176]  ffff8801dd6b1b9c ffff880100000ff0 ffff880119adbfd8 ffff880132a755b6
> [  841.182466]  ffff8801bb529f00 ffff8801e1d06800 000000000000151c ffff880132a755b6
> [  841.190764] Call Trace:
> [  841.193490]  <IRQ>
> [  841.195632]  [<ffffffff9eed1a15>] ? skb_copy_bits+0x145/0x290
> [  841.202272]  [<ffffffff9ef95899>] tpacket_rcv+0x249/0x820
> [  841.208295]  [<ffffffff9eee3358>] __netif_receive_skb_core+0x388/0x950
> [  841.215578]  [<ffffffff9eee30fb>] ? __netif_receive_skb_core+0x12b/0x950
> [  841.223054]  [<ffffffff9eee3941>] __netif_receive_skb+0x21/0x70
> [  841.229658]  [<ffffffff9eee3b35>] netif_receive_skb+0x25/0x120
> [  841.236166]  [<ffffffff9eee3b60>] ? netif_receive_skb+0x50/0x120
> [  841.242869]  [<ffffffff9ef67b5e>] ? inet_gro_receive+0x6e/0x290
> [  841.249474]  [<ffffffff9eee3d6e>] napi_gro_complete.isra.77+0x13e/0x160
> [  841.256853]  [<ffffffff9eee3c60>] ? napi_gro_complete.isra.77+0x30/0x160
> [  841.264331]  [<ffffffffc03dc0bd>] ? gro_cell_poll+0x8d/0xd0 [ip_tunnel]
> [  841.271711]  [<ffffffff9eee4178>] napi_gro_flush+0x78/0xa0
> [  841.277830]  [<ffffffff9eee41d3>] napi_complete+0x33/0x80
> [  841.283852]  [<ffffffffc03dc0d4>] gro_cell_poll+0xa4/0xd0 [ip_tunnel]
> [  841.291038]  [<ffffffff9eee435a>] net_rx_action+0x13a/0x240
> [  841.297254]  [<ffffffff9ea575c0>] __do_softirq+0x100/0x290
> [  841.303374]  [<ffffffff9efb1b0c>] call_softirq+0x1c/0x30
> [  841.309300]  [<ffffffff9ea0bdbd>] do_softirq+0x8d/0xc0
> [  841.315032]  [<ffffffff9ea5791d>] irq_exit+0xcd/0xd0
> [  841.320571]  [<ffffffff9ea05db3>] do_IRQ+0x63/0xe0
> [  841.325915]  [<ffffffff9efa762f>] common_interrupt+0x6f/0x6f
> 
> Not sure how to fix this.
> 
> This patch only shows where the problem is, but should we :
> 
> 1) drop the too long packet
> 2) clamp size to maximal admissible size
> 3) other solution ? (PACKET_V2 can queue a clone of skb in
> receive_queue, but PACKET_V3 has no such capability)
> 

Can we separate a gro packet into its constituent pieces and write them
into/across blocks accordingly?  Or alternatively can we add a bit to the
tp_status field to indicate that a packet may span a block?  That probably
breaks applications I would imagine, but maybe we can create a sockopt to allow
applications to opt in to that behavior to give them the choice between that,
and a simple packet drop.

Neil


> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 8d9f8042705a..6ee072b746fb 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1073,6 +1073,11 @@ static void *__packet_lookup_frame_in_block(struct packet_sock *po,
>  		return (void *)curr;
>  	}
>  
> +	/* If frame do not fit on a single block, bail out */
> +	if (BLK_PLUS_PRIV(pkc->blk_sizeof_priv) +
> +	    TOTAL_PKT_LEN_INCL_ALIGN(len) >= pkc->kblk_size)
> +		return NULL;
> +
>  	/* Ok, close the current block */
>  	prb_retire_current_block(pkc, po, 0);
>  
> 
> 
> 
