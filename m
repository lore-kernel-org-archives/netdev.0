From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: 3.16/3.16.1: Kernel Oops in nft_do_chain
Date: Tue, 2 Sep 2014 12:41:14 +0200
Message-ID: <20140902104114.GA10805@salvia>
References: <54059883.4060309@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: leroy christophe <christophe.leroy@c-s.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58228 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752272AbaIBKlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 06:41:03 -0400
Content-Disposition: inline
In-Reply-To: <54059883.4060309@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2014 at 12:14:27PM +0200, leroy christophe wrote:
> Calling 'iptables-compat -L', first time nothing is listed on the screen.
> Second try, it generates following Oops.

I'm going to pass this patch to -stable asap:

commit b88825de8545ad252c31543fef13cadf4de7a2bc
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Aug 5 17:25:59 2014 +0200

    netfilter: nf_tables: don't update chain with unset counters
    
    Fix possible replacement of the per-cpu chain counters by null
    pointer when updating an existing chain in the commit path.
    
    Reported-by: Matteo Croce <technoboy85@gmail.com>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

I think it's the root cause for this problem.

> c7ff3c30 c7ff3d98
> [  191.490095] NIP [c02f9924] nft_do_chain+0x438/0x4f4
> [  191.494890] LR [c0365b54] nft_do_chain_ipv4+0x6c/0x7c
> [  191.499833] Call Trace:
> [  191.502295] [c7ff3c20] [c02f9970] nft_do_chain+0x484/0x4f4 (unreliable)
> [  191.508830] [c7ff3d90] [c0365b54] nft_do_chain_ipv4+0x6c/0x7c
> [  191.514514] [c7ff3de0] [c02e134c] nf_iterate+0xe4/0x12c
> [  191.519673] [c7ff3e20] [c02e15c8] nf_hook_slow+0xa0/0x1f4
> [  191.525034] [c7ff3e60] [c030dd70] ip_local_deliver+0xa0/0xac
> [  191.530613] [c7ff3e70] [c030d4f4] ip_rcv_finish+0x130/0x350
> [  191.536128] [c7ff3e90] [c02b5304] __netif_receive_skb_core+0x4c4/0x600
> [  191.542595] [c7ff3ef0] [c0237824] fs_enet_rx_napi+0x30c/0x448
> [  191.548252] [c7ff3f50] [c02b5c38] net_rx_action+0x140/0x20c
> [  191.553771] [c7ff3f90] [c001c918] __do_softirq+0x13c/0x2b4
> [  191.559177] [c7ff3ff0] [c000b660] call_do_softirq+0x24/0x3c
> [  191.564696] [c79e5e50] [c0003e04] do_softirq_own_stack+0x3c/0x7c
> [  191.570625] [c79e5e70] [c001c7d8] do_softirq+0x58/0x5c
> [  191.575705] [c79e5e80] [c001cd34] __local_bh_enable_ip+0xa0/0xc4
> [  191.581649] [c79e5e90] [c00525cc] irq_forced_thread_fn+0x64/0x84
> [  191.587577] [c79e5eb0] [c00521fc] irq_thread+0x130/0x188
> [  191.592848] [c79e5ef0] [c0039190] kthread+0xd0/0xe4
> [  191.597651] [c79e5f40] [c000c6d0] ret_from_kernel_thread+0x5c/0x64
> [  191.603706] Instruction dump:
> [  191.606636] 83210014 4bfffc90 813f0000 80090060 74090001 40820070
> 54290024 8009000c
> [  191.614294] 30000200 9009000c 8130fff8 39600000 <80690008>
> 8089000c 80a90000 31040001
> [  191.622147] ---[ end trace 86fcabb2513eb932 ]---
> [  191.626687]
> [  192.599223] Kernel panic - not syncing: Fatal exception in interrupt
> [  192.605305] Rebooting in 180 seconds..
> 
>     if (unlikely(pkt->skb->nf_trace))
> c02f98fc:    81 3f 00 00     lwz     r9,0(r31)
> c02f9900:    80 09 00 60     lwz     r0,96(r9)
> c02f9904:    74 09 00 01     andis.  r9,r0,1
> c02f9908:    40 82 00 70     bne-    c02f9978 <nft_do_chain+0x48c>
> c02f990c:    54 29 00 24     rlwinm  r9,r1,0,0,18
> c02f9910:    80 09 00 0c     lwz     r0,12(r9)
> c02f9914:    30 00 02 00     addic   r0,r0,512
> c02f9918:    90 09 00 0c     stw     r0,12(r9)
>         nft_trace_packet(pkt, basechain, -1, NFT_TRACE_POLICY);
> 
>     rcu_read_lock_bh();
>     stats =
> this_cpu_ptr(rcu_dereference(nft_base_chain(basechain)->stats));
> c02f991c:    81 30 ff f8     lwz     r9,-8(r16)
>     u64_stats_update_begin(&stats->syncp);
>     stats->pkts++;
>     stats->bytes += pkt->skb->len;
> c02f9920:    39 60 00 00     li      r11,0
>         nft_trace_packet(pkt, basechain, -1, NFT_TRACE_POLICY);
> 
>     rcu_read_lock_bh();
>     stats =
> this_cpu_ptr(rcu_dereference(nft_base_chain(basechain)->stats));
>     u64_stats_update_begin(&stats->syncp);
>     stats->pkts++;
> ==> c02f9924:    80 69 00 08     lwz     r3,8(r9)
> c02f9928:    80 89 00 0c     lwz     r4,12(r9)
>     stats->bytes += pkt->skb->len;
> c02f992c:    80 a9 00 00     lwz     r5,0(r9)
>         nft_trace_packet(pkt, basechain, -1, NFT_TRACE_POLICY);
> 
>     rcu_read_lock_bh();
>     stats =
> this_cpu_ptr(rcu_dereference(nft_base_chain(basechain)->stats));
>     u64_stats_update_begin(&stats->syncp);
>     stats->pkts++;
> c02f9930:    31 04 00 01     addic   r8,r4,1
> c02f9934:    7c e3 01 94     addze   r7,r3
> c02f9938:    90 e9 00 08     stw     r7,8(r9)
> c02f993c:    91 09 00 0c     stw     r8,12(r9)
>     stats->bytes += pkt->skb->len;
> c02f9940:    80 c9 00 04     lwz     r6,4(r9)
> c02f9944:    81 5f 00 00     lwz     r10,0(r31)
>     __local_bh_enable_ip(ip, SOFTIRQ_DISABLE_OFFSET);
> }
> 
> 
> Christophe
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
