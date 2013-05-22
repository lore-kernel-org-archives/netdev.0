From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: fix kernel panic with icmp_dest_unreach
Date: Wed, 22 May 2013 04:37:46 -0700
Message-ID: <1369222666.3301.304.camel@edumazet-glaptop>
References: <D2CA09D3-A93C-48CF-A23B-DC1B76D66818@rcs-rds.ro>
	 <1369170063.3301.251.camel@edumazet-glaptop> <519C839E.1000309@rcs-rds.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Petre <daniel.petre@rcs-rds.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:37902 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160Ab3EVLhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 07:37:48 -0400
Received: by mail-da0-f46.google.com with SMTP id e20so1086000dak.5
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 04:37:48 -0700 (PDT)
In-Reply-To: <519C839E.1000309@rcs-rds.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 11:36 +0300, Daniel Petre wrote:
> On 05/22/2013 12:01 AM, Eric Dumazet wrote:
> > On Tue, 2013-05-21 at 20:53 +0300, Daniel Petre wrote:
> >> Hello,
> >> This mini patch mitigates the kernel panic with "stack-protector: Kernel stack
> >> is corrupted" when using gre tunnels and network interface flaps and ip_gre 
> >> sends a icmp dest unreachable which gets in the IP stack and most probably messes things up.
> >>
> >> Current ip_gre panics both 3.7.10 and 3.8.13 few seconds after ether interface is down, 
> >> i managed to take a look at the vmcore with crash utility to find each time icmp_send :
> >>
> >> crash> bt
> >>
> >> PID: 0      TASK: ffffffff81813420  CPU: 0   COMMAND: "swapper/0"
> >> #0 [ffff88003fc03798] machine_kexec at ffffffff81027430
> >> #1 [ffff88003fc037e8] crash_kexec at ffffffff8107da80
> >> #2 [ffff88003fc038b8] panic at ffffffff81540026
> >> #3 [ffff88003fc03938] __stack_chk_fail at ffffffff81037f77
> >> #4 [ffff88003fc03948] icmp_send at ffffffff814d5fec
> >> #5 [ffff88003fc03ae8] ipv4_link_failure at ffffffff814a1795
> >> #6 [ffff88003fc03af8] ipgre_tunnel_xmit at ffffffff814e7965
> >> #7 [ffff88003fc03b78] dev_hard_start_xmit at ffffffff8146e032
> >> #8 [ffff88003fc03bc8] sch_direct_xmit at ffffffff81487d66
> >> #9 [ffff88003fc03c08] __qdisc_run at ffffffff81487efd
> >> #10 [ffff88003fc03c48] dev_queue_xmit at ffffffff8146e5a7
> >> #11 [ffff88003fc03c88] ip_finish_output at ffffffff814ab596
> >> #12 [ffff88003fc03ce8] __netif_receive_skb at ffffffff8146ed13
> >> #13 [ffff88003fc03d88] napi_gro_receive at ffffffff8146fc50
> >> #14 [ffff88003fc03da8] e1000_clean_rx_irq at ffffffff813bc67b
> >> #15 [ffff88003fc03e48] e1000e_poll at ffffffff813c3a20
> >> #16 [ffff88003fc03e98] net_rx_action at ffffffff8146f796
> >> #17 [ffff88003fc03ee8] __do_softirq at ffffffff8103ebb9
> >> #18 [ffff88003fc03f38] call_softirq at ffffffff8154444c
> >> #19 [ffff88003fc03f50] do_softirq at ffffffff810047dd
> >> #20 [ffff88003fc03f80] do_IRQ at ffffffff81003f6c
> >> --- <IRQ stack> ---
> >> #21 [ffffffff81801ea8] ret_from_intr at ffffffff81542c2a
> >>  [exception RIP: mwait_idle+95]
> >>  RIP: ffffffff8100ad8f  RSP: ffffffff81801f50  RFLAGS: 00000246
> >>  RAX: 0000000000000000  RBX: ffffffff8154194e  RCX: 0000000000000000
> >>  RDX: 0000000000000000  RSI: ffffffff81801fd8  RDI: ffff88003fc0d840
> >>  RBP: ffffffff8185be80   R8: 0000000000000000   R9: 0000000000000001
> >>  R10: 0000000000000000  R11: 0000000000000000  R12: 0000000000000000
> >>  R13: ffffffff81813420  R14: ffff88003fc11000  R15: ffffffff81813420
> >>  ORIG_RAX: ffffffffffffff1e  CS: 0010  SS: 0018
> >> #22 [ffffffff81801f50] cpu_idle at ffffffff8100b126
> >>
> >> crash> log
> >>
> >> [..]
> >>
> >> [ 6772.560124] e1000e: eth3 NIC Link is Down
> >> [ 6786.680876] e1000e: eth3 NIC Link is Up 1000 Mbps Full Duplex, Flow
> >> Control: Rx
> >> [ 6928.050119] e1000e: eth3 NIC Link is Down
> >> [ 6945.240875] e1000e: eth3 NIC Link is Up 1000 Mbps Full Duplex, Flow
> >> Control: Rx
> >> [ 6945.738103] Kernel panic - not syncing: stack-protector: Kernel stack
> >> is corrupted in: ffffffff814d5fec
> >>
> >> [ 6945.738165] Pid: 0, comm: swapper/0 Not tainted 3.8.13 #3
> >> [ 6945.738189] Call Trace:
> >> [ 6945.738212]  <IRQ>  [<ffffffff8154001f>] ? panic+0xbf/0x1c9
> >> [ 6945.738245]  [<ffffffff814ab505>] ? ip_finish_output+0x255/0x3e0
> >> [ 6945.738271]  [<ffffffff814d5fec>] ? icmp_send+0x6bc/0x730
> >> [ 6945.738296]  [<ffffffff81037f77>] ? __stack_chk_fail+0x17/0x30
> >> [ 6945.738320]  [<ffffffff814d5fec>] ? icmp_send+0x6bc/0x730
> >> [ 6945.738344]  [<ffffffff81009470>] ? nommu_map_sg+0x110/0x110
> >> [ 6945.738369]  [<ffffffff815428f9>] ? _raw_spin_lock_bh+0x9/0x30
> >> [ 6945.738393]  [<ffffffff814a1795>] ? ipv4_link_failure+0x15/0x60
> >> [ 6945.738418]  [<ffffffff814e7965>] ? ipgre_tunnel_xmit+0x7f5/0x9f0
> >> [ 6945.738443]  [<ffffffff8146e032>] ? dev_hard_start_xmit+0x102/0x490
> >> [ 6945.738470]  [<ffffffff81487d66>] ? sch_direct_xmit+0x106/0x1e0
> >> [ 6945.738494]  [<ffffffff81487efd>] ? __qdisc_run+0xbd/0x150
> >> [ 6945.738518]  [<ffffffff8146e5a7>] ? dev_queue_xmit+0x1e7/0x3a0
> >> [ 6945.738542]  [<ffffffff814ab596>] ? ip_finish_output+0x2e6/0x3e0
> >> [ 6945.738567]  [<ffffffff8146ed13>] ? __netif_receive_skb+0x5b3/0x7c0
> >> [ 6945.738591]  [<ffffffff8146f114>] ? netif_receive_skb+0x24/0x80
> >> [ 6945.738616]  [<ffffffff8146fc50>] ? napi_gro_receive+0x110/0x140
> >> [ 6945.738642]  [<ffffffff813bc67b>] ? e1000_clean_rx_irq+0x29b/0x490
> >> [ 6945.738667]  [<ffffffff813c3a20>] ? e1000e_poll+0x90/0x3a0
> >> [ 6945.738690]  [<ffffffff8146f796>] ? net_rx_action+0xc6/0x1e0
> >> [ 6945.738715]  [<ffffffff8103ebb9>] ? __do_softirq+0xa9/0x170
> >> [ 6945.738739]  [<ffffffff8154444c>] ? call_softirq+0x1c/0x30
> >> [ 6945.738762]  [<ffffffff810047dd>] ? do_softirq+0x4d/0x80
> >> [ 6945.738786]  [<ffffffff8103e9cd>] ? irq_exit+0x7d/0x90
> >> [ 6945.738808]  [<ffffffff81003f6c>] ? do_IRQ+0x5c/0xd0
> >> [ 6945.738831]  [<ffffffff81542c2a>] ? common_interrupt+0x6a/0x6a
> >> [ 6945.738854]  <EOI>  [<ffffffff8154194e>] ? __schedule+0x26e/0x5b0
> >> [ 6945.738884]  [<ffffffff8100ad8f>] ? mwait_idle+0x5f/0x70
> >> [ 6945.738907]  [<ffffffff8100b126>] ? cpu_idle+0xf6/0x110
> >> [ 6945.738930]  [<ffffffff81875c58>] ? start_kernel+0x33d/0x348
> >> [ 6945.738954]  [<ffffffff8187573b>] ? repair_env_string+0x5b/0x5b
> >> [ 6945.738978]  [<ffffffff8187541d>] ? x86_64_start_kernel+0xee/0xf2
> >>
> >>
> >> Signed-off-by: Daniel Petre <daniel.petre@rcs-rds.ro>
> >> ---
> >>
> >> --- linux-3.8.13/net/ipv4/ip_gre.c.orig	2013-05-21 20:28:37.340537935 +0300
> >> +++ linux-3.8.13/net/ipv4/ip_gre.c	2013-05-21 20:32:47.248722835 +0300
> >> @@ -728,7 +728,9 @@ static int ipgre_rcv(struct sk_buff *skb
> >> 		gro_cells_receive(&tunnel->gro_cells, skb);
> >> 		return 0;
> >> 	}
> >> -	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
> >> +	/* don't send icmp destination unreachable if tunnel is down
> >> +	the IP stack gets corrupted and machine panics!
> >> +	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0); */
> >>
> >> drop:
> >> 	kfree_skb(skb);
> > 
> > Hmm... can you reproduce this bug on latest kernel ?
> > 
> > (preferably David Miller net tree :
> > http://git.kernel.org/cgit/linux/kernel/git/davem/net.git
> > )
> 
> Hello Eric,
> unfortunately the machine we have worked on the last weeks cannot be
> used anymore for tests as it was and still is a production router..
> 
> I can tell you we have tested kernel 3.6.3, 3.6.8, 3.7.1, 3.7.6, 3.7.10
> and right now it runs 3.8.13 with intel e1000e and broadcom tg3 nics and
> each time the interface where we have the few gre tunnels goes down the
> debian squeeze up-to-date router will panic.
> 
> I might be able to get a similar setup in the next weeks but it's a
> little uncertain.
> 

What's the setup of the machine exactly ?

You receive packets from e1000e, add forward them through a GRE tunnel
via tg3 ?

Please give us some details so that we can reproduce the bug and fix it.
