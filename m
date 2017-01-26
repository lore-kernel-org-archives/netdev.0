From: Roy Keene <lkml@rkeene.org>
Subject: ip_rcv_finish() NULL pointer kernel panic
Date: Thu, 26 Jan 2017 06:28:41 -0600 (CST)
Message-ID: <alpine.LNX.2.02.1701260627510.24491@maul.oc9.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oc9.org ([108.175.9.112]:43134 "EHLO mail.oc9.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752297AbdAZMpG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 07:45:06 -0500
Received: from maul.oc9.org (localhost [127.0.0.1])
        by mail.oc9.org (8.14.9/8.14.9) with ESMTP id v0QCSgnL021102
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 06:28:43 -0600
Received: from localhost (rkeene@localhost)
        by maul.oc9.org (8.14.9/8.14.5) with ESMTP id v0QCSfXs021095
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 06:28:42 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resending to netdev from LKML]

All,

  	I am experiencing a kernel panic on different (but identical) 
hardware in ip_rcv_finish on Linux 4.4.39 (but I can see no changes that 
would improve the situation on 4.4.44, or master).

Looking at the disassembly at the last stack frame it looks like we are 
calling a NULL function pointer in net/ipv4/ip_input.c:365

Panic:


[ 214.518262] BUG: unable to handle kernel NULL pointer dereference at (null)
[ 214.612199] IP: [< (null)>] (null)
[ 214.672744] PGD 0 
[ 214.696887] Oops: 0010 [#1] SMP 
[ 214.735697] Modules linked in: br_netfilter(+) tun 8021q bridge stp llc bonding iTCO_wdt iTCO_vendor_support tpm_tis tpm kvm_intel kvm irqbypass sb_edac edac_core ixgbe mdio ipmi_si ipmi_msghandler lpc_ich mfd_core mousedev evdev igb dca procmemro(O) nokeyctl(O) noptrace(O)
[ 215.029240] CPU: 34 PID: 0 Comm: swapper/34 Tainted: G O 4.4.39 #1
[ 215.116720] Hardware name: Cisco Systems Inc UCSC-C220-M3L/UCSC-C220-M3L, BIOS C220M3.2.0.13a.0.0713160937 07/13/16
[ 215.241644] task: ffff882038fb4380 ti: ffff8810392b0000 task.ti: ffff8810392b0000
[ 215.331207] RIP: 0010:[<0000000000000000>] [< (null)>] (null)
[ 215.420877] RSP: 0018:ffff88103fec3880 EFLAGS: 00010286
[ 215.484436] RAX: ffff881011631000 RBX: ffff881011067100 RCX: 0000000000000000
[ 215.569836] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff881011067100
[ 215.655234] RBP: ffff88103fec38a8 R08: 0000000000000008 R09: ffff8810116300a0
[ 215.740629] R10: 0000000000000000 R11: 0000000000000000 R12: ffff881018917dce
[ 215.826030] R13: ffffffff81c9be00 R14: ffffffff81c9be00 R15: ffff881011630078
[ 215.911432] FS: 0000000000000000(0000) GS:ffff88103fec0000(0000) knlGS:0000000000000000
[ 216.008274] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 216.077032] CR2: 0000000000000000 CR3: 0000001011b9d000 CR4: 00000000001406e0
[ 216.162430] Stack:
[ 216.186461] ffffffff8157d7f9 ffff881011067100 ffff881018917dce ffff881011630000
[ 216.275407] ffffffff81c9be00 ffff88103fec3918 ffffffff8157e0db 0000000000000000
[ 216.364352] 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[ 216.453301] Call Trace:
[ 216.482536] <IRQ> 
[ 216.505533] [<ffffffff8157d7f9>] ? ip_rcv_finish+0x99/0x320
[ 216.575442] [<ffffffff8157e0db>] ip_rcv+0x25b/0x370
[ 216.634842] [<ffffffff81540e0b>] __netif_receive_skb_core+0x2cb/0xa20
[ 216.712965] [<ffffffff81541578>] __netif_receive_skb+0x18/0x60
[ 216.783801] [<ffffffff815415e3>] netif_receive_skb_internal+0x23/0x80
[ 216.861921] [<ffffffff8154165c>] netif_receive_skb+0x1c/0x70
[ 216.930686] [<ffffffffa02f6439>] br_handle_frame_finish+0x1b9/0x5b0 [bridge]
[ 217.016091] [<ffffffff81187a00>] ? ___slab_alloc+0x1d0/0x440
[ 217.084849] [<ffffffffa0584074>] br_nf_pre_routing_finish+0x174/0x3d0 [br_netfilter]
[ 217.178568] [<ffffffffa0584c07>] ? br_nf_pre_routing+0x97/0x470 [br_netfilter]
[ 217.266052] [<ffffffffa02f6280>] ? br_handle_local_finish+0x80/0x80 [bridge]
[ 217.351450] [<ffffffffa0584d17>] br_nf_pre_routing+0x1a7/0x470 [br_netfilter]
[ 217.437891] [<ffffffff81572f6d>] nf_iterate+0x5d/0x70
[ 217.499367] [<ffffffff81572fe4>] nf_hook_slow+0x64/0xc0
[ 217.562928] [<ffffffffa02f69e9>] br_handle_frame+0x1b9/0x290 [bridge]
[ 217.641048] [<ffffffffa02f6280>] ? br_handle_local_finish+0x80/0x80 [bridge]
[ 217.726446] [<ffffffff81540e82>] __netif_receive_skb_core+0x342/0xa20
[ 217.804566] [<ffffffff815a7916>] ? tcp4_gro_receive+0x126/0x1d0
[ 217.876445] [<ffffffff815b7446>] ? inet_gro_receive+0x1c6/0x250
[ 217.948322] [<ffffffff81541578>] __netif_receive_skb+0x18/0x60
[ 218.019161] [<ffffffff815415e3>] netif_receive_skb_internal+0x23/0x80
[ 218.097281] [<ffffffff81542213>] napi_gro_receive+0xc3/0x110
[ 218.166051] [<ffffffffa00a801f>] ixgbe_clean_rx_irq+0x52f/0xa70 [ixgbe]
[ 218.246255] [<ffffffffa00a9248>] ixgbe_poll+0x438/0x790 [ixgbe]
[ 218.318131] [<ffffffff81541a6e>] net_rx_action+0x1ee/0x320
[ 218.384813] [<ffffffff8109c837>] ? handle_irq_event_percpu+0x167/0x1d0
[ 218.463973] [<ffffffff8105c3c1>] __do_softirq+0x101/0x280
[ 218.529608] [<ffffffff8105c69e>] irq_exit+0x8e/0x90
[ 218.589007] [<ffffffff816dd504>] do_IRQ+0x54/0xd0
[ 218.646323] [<ffffffff816dba02>] common_interrupt+0x82/0x82
[ 218.714039] <EOI> 
[ 218.737040] [<ffffffff814fb4f3>] ? cpuidle_enter_state+0x133/0x2a0
[ 218.814226] [<ffffffff814fb4cf>] ? cpuidle_enter_state+0x10f/0x2a0
[ 218.889224] [<ffffffff814fb697>] cpuidle_enter+0x17/0x20
[ 218.953825] [<ffffffff81093cf1>] cpu_startup_entry+0x2a1/0x300
[ 219.024663] [<ffffffff8103838d>] start_secondary+0xed/0xf0
[ 219.091337] Code: Bad RIP value.
[ 219.131186] RIP [< (null)>] (null)
[ 219.192770] RSP <ffff88103fec3880>
[ 219.234483] CR2: 0000000000000000
[ 219.274121] ---[ end trace 9ce5d4620e3bcbdf ]---
[ 219.274125] BUG: unable to handle kernel NULL pointer dereference at (null)
[ 219.274126] IP: [< (null)>] (null)
[ 219.274126] PGD 0 
[ 219.274128] Oops: 0010 [#2] SMP 
[ 219.274137] Modules linked in: br_netfilter(+) tun 8021q bridge stp llc bonding iTCO_wdt iTCO_vendor_support tpm_tis tpm kvm_intel kvm irqbypass sb_edac edac_core ixgbe mdio ipmi_si ipmi_msghandler lpc_ich mfd_core mousedev evdev igb dca procmemro(O) nokeyctl(O) noptrace(O)
[ 219.274139] CPU: 7 PID: 0 Comm: swapper/7 Tainted: G D O 4.4.39 #1
[ 219.274140] Hardware name: Cisco Systems Inc UCSC-C220-M3L/UCSC-C220-M3L, BIOS C220M3.2.0.13a.0.0713160937 07/13/16
[ 219.274141] task: ffff882038f84380 ti: ffff881039044000 task.ti: ffff881039044000
[ 219.274142] RIP: 0010:[<0000000000000000>] [< (null)>] (null)
[ 219.274143] RSP: 0018:ffff88103fce3880 EFLAGS: 00010286
[ 219.274143] RAX: ffff881


Notes:
----
include/linux/skbuff.h:

   734 #define SKB_DST_NOREF   1UL
   735 #define SKB_DST_PTRMASK ~(SKB_DST_NOREF)
...
   743 static inline struct dst_entry *skb_dst(const struct sk_buff *skb) {
   745         /* If refdst was not refcounted, check we still are in a
   746          * rcu_read_lock section
   747          */
   748         WARN_ON((skb->_skb_refdst & SKB_DST_NOREF) &&
   749                 !rcu_read_lock_held() &&
   750                 !rcu_read_lock_bh_held());
   751         return (struct dst_entry *)(skb->_skb_refdst & SKB_DST_PTRMASK);
   752 }
---
include/net/dst.h:
   496 static inline int dst_input(struct sk_buff *skb) {
   498         return skb_dst(skb)->input(skb);
   499 }
---
net/ipv4/ip_input.c:

   359         rt = skb_rtable(skb);
   360         if (rt->rt_type == RTN_MULTICAST) {
   361                 IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_INMCAST, skb->len);
   362         } else if (rt->rt_type == RTN_BROADCAST)
   363                 IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_INBCAST, skb->len);
   364
   365         return dst_input(skb);
----
Expand net/ipv4/ip_input.c:365:
       return dst_input(skb);

Into:
       return skb_dst(skb)->input(skb);

Into:
       return ((struct dst_entry *)(skb->_skb_refdst & SKB_DST_PTRMASK))->input(skb);

Into:
       return ((struct dst_entry *)(skb->_skb_refdst & (~(1UL))))->input(skb);

Into:
       return ((struct dst_entry *)(skb->_skb_refdst & 0xfffffffffffffffe))->input(skb);
----
Disassembly with C code next to it
      0xffffffff8157d7d4 <ip_rcv_finish+116>  movzwl 0xa0(%rdx),%edx                                | rt = skb_rtable(skb);
      0xffffffff8157d7db <ip_rcv_finish+123>  cmp    $0x5,%dx                                       | if (rt->rt_type == RTN_MULTICAST) {
      0xffffffff8157d7df <ip_rcv_finish+127>  je     0xffffffff8157d908 <ip_rcv_finish+424>         ....
      0xffffffff8157d7e5 <ip_rcv_finish+133>  cmp    $0x3,%dx                                       | } else if (rt->rt_type == RTN_BROADCAST)
      0xffffffff8157d7e9 <ip_rcv_finish+137>  je     0xffffffff8157d87e <ip_rcv_finish+286>         ...
      0xffffffff8157d7ef <ip_rcv_finish+143>  and    $0xfffffffffffffffe,%rax                       | skb->_skb_refdst & SKB_DST_PTRMASK
      0xffffffff8157d7f3 <ip_rcv_finish+147>  mov    %rbx,%rdi
--> 0xffffffff8157d7f6 <ip_rcv_finish+150>  callq  *0x50(%rax)                                    | ((struct dst_entry *)(skb->_skb_refdst & SKB_DST_PTRMASK))->input(skb)
      0xffffffff8157d7f9 <ip_rcv_finish+153>  pop    %rbx
      0xffffffff8157d7fa <ip_rcv_finish+154>  pop    %r12
      0xffffffff8157d7fc <ip_rcv_finish+156>  pop    %r13
      0xffffffff8157d7fe <ip_rcv_finish+158>  pop    %r14
      0xffffffff8157d800 <ip_rcv_finish+160>  pop    %rbp
      0xffffffff8157d801 <ip_rcv_finish+161>  retq
----

This leads me to believe that ((struct dst_entry *)(skb->_skb_refdst & SKB_DST_PTRMASK))->input is NULL and we are jumping there (callq).


Under what conditions would ((struct dst_entry *)(skb->_skb_refdst & 
SKB_DST_PTRMASK))->input be NULL at this point ?

Thanks,
  	Roy Keene
