From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH] net: ip_finish_output_gso: Attempt gso_size clamping
 if segments exceed mtu
Date: Mon, 22 Aug 2016 14:58:42 +0200
Message-ID: <20160822125842.GF6199@breakpoint.cc>
References: <1471867570-1406-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>,
        Florian Westphal <fw@strlen.de>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35622 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755718AbcHVNlm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 09:41:42 -0400
Content-Disposition: inline
In-Reply-To: <1471867570-1406-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:
> There are cases where gso skbs (which originate from an ingress
> interface) have a gso_size value that exceeds the output dst mtu:
> 
>  - ipv4 forwarding middlebox having in/out interfaces with different mtus
>    addressed by fe6cc55f3a 'net: ip, ipv6: handle gso skbs in forwarding path'
>  - bridge having a tunnel member interface stacked over a device with small mtu
>    addressed by b8247f095e 'net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU, allow segmentation for local udp tunneled skbs'
> 
> In both cases, such skbs are identified, then go through early software
> segmentation+fragmentation as part of ip_finish_output_gso.
> 
> Another approach is to shrink the gso_size to a value suitable so
> resulting segments are smaller than dst mtu, as suggeted by Eric
> Dumazet (as part of [1]) and Florian Westphal (as part of [2]).
> 
> This will void the need for software segmentation/fragmentation at
> ip_finish_output_gso, thus significantly improve throughput and lower
> cpu load.
> 
> This RFC patch attempts to implement this gso_size clamping.
> 
> [1] https://patchwork.ozlabs.org/patch/314327/
> [2] https://patchwork.ozlabs.org/patch/644724/
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Florian Westphal <fw@strlen.de>
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> ---
> 
>  Comments welcome.
> 
>  Few questions embedded in the patch.
> 
>  Florian, in fe6cc55f you described a BUG due to gso_size decrease.
>  I've tested both bridged and routed cases, but in my setups failed to
>  hit the issue; Appreciate if you can provide some hints.

Still get the BUG, I applied this patch on top of net-next.

On hypervisor:
10.0.0.2 via 192.168.7.10 dev tap0 mtu lock 1500
ssh root@10.0.0.2 'cat > /dev/null' < /dev/zero

On vm1 (which dies instantly, see below):
eth0 mtu 1500 (192.168.7.10)
eth1 mtu 1280 (10.0.0.1)

On vm2
eth0 mtu 1280 (10.0.0.2)

Normal ipv4 routing via vm1, no iptables etc. present, so

we have  hypervisor 1500 -> 1500 VM1 1280 -> 1280 VM2

Turning off gro avoids this problem.

------------[ cut here ]------------
kernel BUG at net-next/net/core/skbuff.c:3210!
invalid opcode: 0000 [#1] SMP
CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.8.0-rc2+ #1842
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
task: ffff88013b100000 task.stack: ffff88013b0fc000
RIP: 0010:[<ffffffff8135ab44>]  [<ffffffff8135ab44>] skb_segment+0x964/0xb20
RSP: 0018:ffff88013fd838d0  EFLAGS: 00010212
RAX: 00000000000005a8 RBX: ffff88013a9f9900 RCX: ffff88013b1cf500
RDX: 0000000000006612 RSI: 0000000000000494 RDI: 0000000000000114
RBP: ffff88013fd839a8 R08: 00000000000069ca R09: ffff88013b1cf400
R10: 0000000000000011 R11: 0000000000006612 R12: 00000000000064fe
R13: ffff8801394c7300 R14: ffff88013937ad80 R15: 0000000000000011
FS:  0000000000000000(0000) GS:ffff88013fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f059fc3b2b0 CR3: 0000000001806000 CR4: 00000000000006a0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Stack:
 000000000000003b ffffffffffffffbe fffffff400000000 ffff88013b1cf400
 0000000000000000 0000000000000042 0000000000000040 0000000000000001
 0000000000000042 ffff88013b1cf600 0000000000000000 ffff8801000004cc
Call Trace:
 <IRQ> 
 [<ffffffff8123bacf>] ? swiotlb_map_page+0x5f/0x120
 [<ffffffff813eda00>] tcp_gso_segment+0x100/0x480
 [<ffffffff813eddb3>] tcp4_gso_segment+0x33/0x90
 [<ffffffff813fda7a>] inet_gso_segment+0x12a/0x3b0
 [<ffffffff81368c00>] ? dev_hard_start_xmit+0x20/0x110
 [<ffffffff813684f0>] skb_mac_gso_segment+0x90/0xf0
 [<ffffffff81368601>] __skb_gso_segment+0xb1/0x140
 [<ffffffff81368a7f>] validate_xmit_skb+0x14f/0x2b0
 [<ffffffff81368d2e>] validate_xmit_skb_list+0x3e/0x60
 [<ffffffff8138cb6a>] sch_direct_xmit+0x10a/0x1a0
 [<ffffffff81369199>] __dev_queue_xmit+0x369/0x5d0
 [<ffffffff8136940b>] dev_queue_xmit+0xb/0x10
 [<ffffffff813c8f47>] ip_finish_output2+0x247/0x310
 [<ffffffff813cac10>] ip_finish_output+0x1c0/0x250
 [<ffffffff813cadea>] ip_output+0x3a/0x40
 [<ffffffff813c751c>] ip_forward+0x36c/0x410
 [<ffffffff813c5b06>] ip_rcv+0x2e6/0x630
 [<ffffffff81364d5f>] __netif_receive_skb_core+0x2cf/0x940
 [<ffffffff813189bd>] ? e1000_alloc_rx_buffers+0x1bd/0x490
 [<ffffffff813653e8>] __netif_receive_skb+0x18/0x60
 [<ffffffff81365728>] netif_receive_skb_internal+0x28/0x90
 [<ffffffff813ee3b0>] ? tcp4_gro_complete+0x80/0x90
 [<ffffffff8136580a>] napi_gro_complete+0x7a/0xa0
 [<ffffffff813697e5>] napi_gro_flush+0x55/0x70
 [<ffffffff81369d06>] napi_complete_done+0x66/0xb0
 [<ffffffff81319810>] e1000_clean+0x380/0x900
 [<ffffffff81368c65>] ? dev_hard_start_xmit+0x85/0x110
 [<ffffffff81369ef3>] net_rx_action+0x1a3/0x2b0
 [<ffffffff81049c22>] __do_softirq+0xe2/0x1d0
 [<ffffffff81049f09>] irq_exit+0x89/0x90
 [<ffffffff810199bf>] do_IRQ+0x4f/0xd0
 [<ffffffff81498882>] common_interrupt+0x82/0x82
 <EOI> 
 [<ffffffff81035bd6>] ? native_safe_halt+0x6/0x10
 [<ffffffff8101ff49>] default_idle+0x9/0x10
 [<ffffffff8102052a>] arch_cpu_idle+0xa/0x10
 [<ffffffff810791ce>] default_idle_call+0x2e/0x30
 [<ffffffff8107933f>] cpu_startup_entry+0x16f/0x220
 [<ffffffff8102d6f5>] start_secondary+0x105/0x130
Code: 00 08 02 48 89 df 44 89 44 24 18 83 e6 c0 e8 04 c7 ff ff 85 c0 0f 85 02 01 00 00 8b 83 b8 00 00 00 44 8b 44 24 18 e9 cc fe ff ff <0f> 0b 0f 0b 0f 0b 8b 4b 74 85 c9 0f 85 ce 00 00 00 48 8b 83 c0 
RIP  [<ffffffff8135ab44>] skb_segment+0x964/0xb20
 RSP <ffff88013fd838d0>
---[ end trace 924612451efe8dce ]---
Kernel panic - not syncing: Fatal exception in interrupt
Kernel Offset: disabled
---[ end Kernel panic - not syncing: Fatal exception in interrupt
