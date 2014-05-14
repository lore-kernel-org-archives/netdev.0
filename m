From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 3/5] pktgen: avoid atomic_inc per packet in
 xmit loop
Date: Wed, 14 May 2014 17:13:06 +0200
Message-ID: <20140514171306.52980157@redhat.com>
References: <20140514141545.20309.28343.stgit@dragon>
	<20140514141753.20309.19785.stgit@dragon>
	<1400078131.7973.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	John Fastabend <john.r.fastabend@intel.com>, danieltt@kth.se,
	zhouzhouyi@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106AbaENPNZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 11:13:25 -0400
In-Reply-To: <1400078131.7973.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2014 07:35:31 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2014-05-14 at 16:17 +0200, Jesper Dangaard Brouer wrote:
> > Avoid the expensive atomic refcnt increase in the pktgen xmit loop, by
> > simply setting the refcnt only when a new SKB gets allocated. Setting
> > it according to how many times we are spinning the same SKB (and
> > handling the case of skb_clone=0).
> > 
> > Performance data with CLONE_SKB==100000 and TX ring buffer size=1024:
> >  (single CPU performance, ixgbe 10Gbit/s, E5-2630)
> >  * Before: 5,362,722 pps --> 186.47ns per pkt (1/5362722*10^9)
> >  * Now:    5,608,781 pps --> 178.29ns per pkt (1/5608781*10^9)
> >  * Diff:    +246,059 pps -->  -8.18ns
> > 
> > The performance increase converted to nanoseconds (8.18ns), correspond
> > well to the measured overhead of LOCK prefixed assembler instructions
> > on my E5-2630 CPU which is measured to be 8.23ns.
> > 
> > Note, with TX ring size 768 I see some "tx_restart_queue" events.
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> 
> OK, but then you need to properly undo the refcnt at the end of pktgen
> loop, otherwise you leak one skb ?
> 
> Say you run pktgen for 995 sends, and clone_count is 10.

Ah I see, then pktgen gets stopped, I might leak a SKB.


> If done properly, you probably can avoid the kfree_skb(pkt_dev->skb) in
> pktgen_xmit(), and set initial skb->users to max(1, pkt_dev->clone_skb);

Just setting max(1, pkt_dev->clone_skb) killed my machine (and my
netconsole didn't send the entire output before dying).

kernel:[91899.988338] skbuff: skb_under_panic: text:ffffffffa03a0b5f len:56 put:14 head:ffff88081bdeb400 data:ffff88081bdeb3f4 tail:0x2c end:0xc0 dev:eth8
 kernel:[91899.988505] ------------[ cut here ]------------
 kernel:[91899.988643] invalid opcode: 0000 [#1] SMP 
 kernel:[91899.988711] Modules linked in: pktgen netconsole ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_CHECKSUM iptable_mangle bridge stp llc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4
 kernel:[91899.988887] general protection fault: 0000 [#2] SMP 
 kernel:[91899.988888] Modules linked in: pktgen netconsole ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_CHECKSUM iptable_mangle bridge stp llc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables binfmt_misc vhost_net macvtap macvlan vhost tun kvm_intel kvm microcode pcspkr ipmi_si ipmi_msghandler hid_generic i2c_i801 sg ixgbe mlx4_en mdio vxlan mlx4_core igb i2c_algo_bit i2c_core ptp pps_core sd_mod crc_t10dif crct10dif_common ahci libahci libata dm_mirror dm_region_hash dm_log dm_mod [last unloaded: pktgen]
 kernel:[91899.988912] CPU: 0 PID: 21807 Comm: kpktgend_0 Tainted: G        W     3.15.0-rc1-dpaccel01-pktgen+ #469
 kernel:[91899.988913] Hardware name: Supermicro X9DR3-F/X9DR3-F, BIOS 3.0a 07/31/2013
 kernel:[91899.988914] task: ffff88081e1b6480 ti: ffff880807374000 task.ti: ffff880807374000
 kernel:[91899.988915] RIP: 0010:[<ffffffff8119ecdc>]  [<ffffffff8119ecdc>] __kmalloc_node_track_caller+0xdc/0x240
 kernel:[91899.988920] RSP: 0018:ffff880807375798  EFLAGS: 00010046
 kernel:[91899.988921] RAX: 0000000000000000 RBX: 0000000000000020 RCX: dc0a9af1def08800
 kernel:[91899.988922] RDX: 0000000000046786 RSI: 0000000000000000 RDI: 0000000000016340
 kernel:[91899.988922] RBP: ffff8808073757f8 R08: ffff88085fc16340 R09: ffffffff815a8367
 kernel:[91899.988923] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000010220
 kernel:[91899.988924] R13: ffff88085f803600 R14: 0000000000000180 R15: 00000000ffffffff
 kernel:[91899.988925] FS:  0000000000000000(0000) GS:ffff88085fc00000(0000) knlGS:0000000000000000
 kernel:[91899.988925] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 kernel:[91899.988926] CR2: 00007f311af84000 CR3: 00000000019f0000 CR4: 00000000000407f0
 kernel:[91899.988926] Stack:
 kernel:[91899.988927]  00000020ffffffff ffff88081a78e800 ffff8808594c6800 ffff8808594c6000
 kernel:[91899.988928]  ffffffff815a839b dc0a9af1def08800 ffff8808073757e8 0000000000000020
 kernel:[91899.988930]  00000000ffffffff 0000000000000180 ffff880807375867 0000000000000180
 kernel:[91899.988931] Call Trace:
 kernel:[91899.988932]  [<ffffffff815a839b>] ? __alloc_skb+0x8b/0x1e0
 kernel:[91899.988936]  [<ffffffff815a805b>] __kmalloc_reserve+0x3b/0xa0
 kernel:[91899.988938]  [<ffffffff815a839b>] __alloc_skb+0x8b/0x1e0
 kernel:[91899.988940]  [<ffffffff815d508c>] netpoll_send_udp+0x8c/0x400
 kernel:[91899.988943]  [<ffffffffa03962c3>] write_msg+0xd3/0x130 [netconsole]
 kernel:[91899.988946]  [<ffffffff810b5e75>] call_console_drivers.clone.1+0xa5/0x110
 kernel:[91899.988950]  [<ffffffff810b5fc7>] console_cont_flush.clone.0+0xe7/0x1a0
 kernel:[91899.988952]  [<ffffffff810b60b2>] console_unlock+0x32/0x2a0
 kernel:[91899.988953]  [<ffffffff810b6805>] vprintk_emit+0x325/0x510
 kernel:[91899.988954]  [<ffffffff810b577c>] ? wake_up_klogd+0x3c/0x50
 kernel:[91899.988956]  [<ffffffff816be2a1>] printk+0x77/0x79
 kernel:[91899.988959]  [<ffffffff816c6e95>] ? notifier_call_chain+0x55/0x80
 kernel:[91899.988962]  [<ffffffff810d4547>] print_modules+0xb7/0xd0
 kernel:[91899.988965]  [<ffffffff816c6f3e>] ? notify_die+0x2e/0x30
 kernel:[91899.988966]  [<ffffffff816c3f7b>] __die+0xab/0x100
 kernel:[91899.988967]  [<ffffffff81005e78>] die+0x48/0x90
 kernel:[91899.988970]  [<ffffffff816c3b9b>] do_trap+0xcb/0x170
 kernel:[91899.988971]  [<ffffffff816c6eda>] ? __atomic_notifier_call_chain+0x1a/0x30
 kernel:[91899.988972]  [<ffffffff81003615>] do_invalid_op+0x95/0xb0
 kernel:[91899.988974]  [<ffffffff815a7f45>] ? skb_push+0x85/0x90
 kernel:[91899.988976]  [<ffffffff810b66c8>] ? vprintk_emit+0x1e8/0x510
 kernel:[91899.988977]  [<ffffffff816cd378>] invalid_op+0x18/0x20
 kernel:[91899.988979]  [<ffffffff815a7f45>] ? skb_push+0x85/0x90
 kernel:[91899.988981]  [<ffffffff815a7f45>] ? skb_push+0x85/0x90
 kernel:[91899.988982]  [<ffffffffa03a0b5f>] fill_packet_ipv4+0xaf/0x470 [pktgen]
 kernel:[91899.988985]  [<ffffffff815a8eff>] ? __kfree_skb+0x3f/0xc0
 kernel:[91899.988987]  [<ffffffffa0167ed0>] ? ixgbe_xmit_frame_ring+0x610/0x610 [ixgbe]
 kernel:[91899.988993]  [<ffffffffa03a1438>] pktgen_xmit+0x98/0x370 [pktgen]
 kernel:[91899.988995]  [<ffffffffa03a1540>] ? pktgen_xmit+0x1a0/0x370 [pktgen]
 kernel:[91899.988997]  [<ffffffffa03a1887>] pktgen_thread_worker+0x177/0x500 [pktgen]
 kernel:[91899.988999]  [<ffffffff810af2b0>] ? bit_waitqueue+0xd0/0xd0
 kernel:[91899.989001]  [<ffffffff810af2b0>] ? bit_waitqueue+0xd0/0xd0
 kernel:[91899.989002]  [<ffffffffa03a1710>] ? pktgen_xmit+0x370/0x370 [pktgen]
 kernel:[91899.989004]  [<ffffffff8108e7ae>] kthread+0xce/0xf0
 kernel:[91899.989006]  [<ffffffff8108e6e0>] ? kthread_worker_fn+0x120/0x120
 kernel:[91899.989008]  [<ffffffff816cbd6c>] ret_from_fork+0x7c/0xb0
 kernel:[91899.989011]  [<ffffffff8108e6e0>] ? kthread_worker_fn+0x120/0x120
 kernel:[91899.989012] Code: 48 8b 4d c0 44 89 fa 44 89 e6 4c 89 ef e8 4d c5 ff ff 48 89 45 c8 eb 37 0f 1f 80 00 00 00 00 49 63 45 20 48 8b 4d c8 49 8b 7d 00 <48> 8b 1c 01 48 8d 4a 01 48 8b 45 c8 65 48 0f c7 0f 0f 94 c0 3c 
 kernel:[91899.989030]  RSP <ffff880807375798>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
