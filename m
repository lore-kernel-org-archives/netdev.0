From: Nikolay Borisov <kernel@kyup.com>
Subject: [BUG] Erroneous behavior in try_to_coalesce
Date: Thu, 29 Oct 2015 04:19:17 +0900
Message-ID: <CAJFSNy4ar_=QP-zYi_AmEZ_70JOgOiqELBdWWQ=AZy=2Faxf5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	SiteGround Operations <operations@siteground.com>
To: Eric Dumazet <eric.dumazet@gmail.com>, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:33839 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbbJ1TTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 15:19:18 -0400
Received: by obbza9 with SMTP id za9so15083452obb.1
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 12:19:17 -0700 (PDT)
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com. [209.85.218.43])
        by smtp.gmail.com with ESMTPSA id s1sm15480063oem.14.2015.10.28.12.19.17
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 12:19:17 -0700 (PDT)
Received: by oies66 with SMTP id s66so10817169oie.1
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 12:19:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Recently I observed 2 crashes on one of my server with the following backtraces:

[22751.889645] ------------[ cut here ]------------
[22751.889660] WARNING: CPU: 38 PID: 12807 at net/core/skbuff.c:3498
skb_try_coalesce+0x34b/0x360()
[22751.889661] Modules linked in: tcp_diag inet_diag xt_LOG xt_limit
xt_addrtype xt_multiport xt_pkt
type xt_conntrack netconsole act_police cls_basic sch_ingress veth
ipv6 openvswitch gre vxlan ip_tun
nel xt_owner xt_state iptable_mangle xt_nat iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat xt_CT nf_conntrack
iptable_raw ext2 dm_thin_pool dm_bio_prison dm_persistent_data
dm_bufio dm_mirror dm_region_hash dm_log ixgbe i2c_i801 lpc_ich
mfd_core igb i2c_algo_bit ioapic ses enclosure ioatdma dca
ipmi_devintf ipmi_si ipmi_msghandler aacraid
[22751.889704] CPU: 38 PID: 12807 Comm: handler22 Not tainted
3.12.49-clouder2 #2
[22751.889706] Hardware name: Supermicro
PIO-617R-TLN4F+-ST031/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0b 05/27/2014
[22751.889708]  0000000000000daa ffff883fff4839e8 ffffffff81643c91
0000000000000daa
[22751.889716]  0000000000000000 ffff883fff483a28 ffffffff81089acc
ffff883fff483b68
[22751.889721]  ffff8832bd282b00 ffff882e6b0190e8 ffff883fff483aa4
00000000000005b4
[22751.889726] Call Trace:
[22751.889728]  <IRQ>  [<ffffffff81643c91>] dump_stack+0x58/0x7f
[22751.889739]  [<ffffffff81089acc>] warn_slowpath_common+0x8c/0xc0
[22751.889742]  [<ffffffff81089b1a>] warn_slowpath_null+0x1a/0x20
[22751.889745]  [<ffffffff8157847b>] skb_try_coalesce+0x34b/0x360
[22751.889752]  [<ffffffff815d6a79>] tcp_try_coalesce+0x69/0xc0
[22751.889755]  [<ffffffff815d6b23>] tcp_queue_rcv+0x53/0x130
[22751.889758]  [<ffffffff815da0f3>] tcp_data_queue+0x1d3/0xd40
[22751.889761]  [<ffffffff815dcb99>] tcp_rcv_established+0x319/0x5e0
[22751.889767]  [<ffffffffa01b6281>] ? nf_nat_ipv4_fn+0x1e1/0x270 [iptable_nat]
[22751.889771]  [<ffffffff815e6a12>] tcp_v4_do_rcv+0x152/0x3d0
[22751.889777]  [<ffffffff812e0206>] ? security_sock_rcv_skb+0x16/0x20
[22751.889781]  [<ffffffff8159b3e7>] ? sk_filter+0x37/0xf0
[22751.889784]  [<ffffffff815e7347>] tcp_v4_rcv+0x6b7/0x730
[22751.889787]  [<ffffffff815c3240>] ? ip_rcv+0x3a0/0x3a0
[22751.889791]  [<ffffffff815b78c5>] ? nf_hook_slow+0x85/0x130
[22751.889794]  [<ffffffff815c3240>] ? ip_rcv+0x3a0/0x3a0
[22751.889796]  [<ffffffff815c3302>] ip_local_deliver_finish+0xc2/0x250
[22751.889799]  [<ffffffff815c3518>] ip_local_deliver+0x88/0x90
[22751.889802]  [<ffffffff815c2af9>] ip_rcv_finish+0x119/0x380
[22751.889804]  [<ffffffff815c3165>] ip_rcv+0x2c5/0x3a0
[22751.889809]  [<ffffffffa01ef135>] ? netdev_frame_hook+0xb5/0x130
[openvswitch]
[22751.889815]  [<ffffffff81589916>] __netif_receive_skb_core+0x626/0x7e0
[22751.889818]  [<ffffffff81589af7>] __netif_receive_skb+0x27/0x70
[22751.889820]  [<ffffffff81589c19>] process_backlog+0xd9/0x1e0
[22751.889823]  [<ffffffff8158a4fc>] net_rx_action+0x12c/0x280
[22751.889828]  [<ffffffff8108ede7>] __do_softirq+0x137/0x2e0
[22751.889832]  [<ffffffff8164ae8c>] call_softirq+0x1c/0x30
[22751.889833]  <EOI>  [<ffffffff8104a35d>] do_softirq+0x8d/0xc0
[22751.889843]  [<ffffffffa01e6ea7>] ?
ovs_packet_cmd_execute+0x217/0x250 [openvswitch]
[22751.889846]  [<ffffffff8108ec9b>] local_bh_enable+0xdb/0xf0
[22751.889849]  [<ffffffffa01e6ea7>]
ovs_packet_cmd_execute+0x217/0x250 [openvswitch]
[22751.889853]  [<ffffffff815b60d1>] genl_family_rcv_msg+0x221/0x390
[22751.889856]  [<ffffffff815b6240>] ? genl_family_rcv_msg+0x390/0x390
[22751.889858]  [<ffffffff815b62a3>] genl_rcv_msg+0x63/0xb0
[22751.889861]  [<ffffffff815b4689>] netlink_rcv_skb+0xa9/0xd0
[22751.889864]  [<ffffffff815b5b1c>] genl_rcv+0x2c/0x40
[22751.889867]  [<ffffffff815b36ef>] netlink_unicast+0x10f/0x190
[22751.889869]  [<ffffffff815b510b>] netlink_sendmsg+0x2bb/0x650
[22751.889874]  [<ffffffff811bce50>] ? __pollwait+0xf0/0xf0
[22751.889881]  [<ffffffff8156e140>] sock_sendmsg+0x90/0xc0
[22751.889883]  [<ffffffff811bce50>] ? __pollwait+0xf0/0xf0
[22751.889887]  [<ffffffff8108fbc7>] ? local_bh_enable_ip+0x87/0xf0
[22751.889890]  [<ffffffff816485a4>] ? _raw_spin_unlock_bh+0x24/0x30
[22751.889894]  [<ffffffff8157bd3d>] ? verify_iovec+0x8d/0x110
[22751.889898]  [<ffffffff8156f037>] ___sys_sendmsg+0x417/0x440
[22751.889904]  [<ffffffff811f10f4>] ? ep_poll+0x144/0x370

And then alter the actual crashed occured:

[44923.628546] BUG: unable to handle kernel paging request at 0000008202990000
[44923.629139] IP: [<ffffffff81579178>] kfree_skb_list+0x18/0x30
[44923.629463] PGD 35cc3b5067 PUD 0
[44923.629823] Oops: 0000 [#1] SMP
[44923.630182] Modules linked in: tcp_diag inet_diag xt_LOG xt_limit
xt_addrtype xt_multiport xt_pkttype xt_conntrack netconsole act_police
cls_basic sch_ingress veth ipv6 openvswitch gre vxlan ip_tunnel
xt_owner xt_state iptable_mangle xt_nat iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat xt_CT nf_conntrack iptable_raw ext2
dm_thin_pool dm_bio_prison dm_persistent_data dm_bufio dm_mirror
dm_region_hash dm_log ixgbe i2c_i801 lpc_ich mfd_core igb i2c_algo_bit
ioapic ses enclosure ioatdma dca ipmi_devintf ipmi_si ipmi_msghandler
aacraid
[44923.634368] CPU: 10 PID: 39391 Comm: kworker/u80:0 Tainted: G
 W    3.12.49-clouder2 #2
[44923.634851] Hardware name: Supermicro
PIO-617R-TLN4F+-ST031/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0b 05/27/2014
[44923.635340] Workqueue: dm-thin do_worker [dm_thin_pool]
[44923.635653] task: ffff881918cb0810 ti: ffff880d5a4ea000 task.ti:
ffff880d5a4ea000
[44923.635926] RIP: 0010:[<ffffffff81579178>]  [<ffffffff81579178>]
kfree_skb_list+0x18/0x30
[44923.636251] RSP: 0018:ffff883fff003cd0  EFLAGS: 00010206
[44923.636521] RAX: 0000000000000000 RBX: ffff882e5622be00 RCX: ffff883fd12b9800
[44923.636791] RDX: 0000000000000100 RSI: 0000000000000040 RDI: 0000008202990000
[44923.637064] RBP: ffff883fff003ce0 R08: 00000000000000dc R09: 0000000000000003
[44923.637336] R10: 0000000000000003 R11: ffff883fff003e68 R12: ffff883f000003c6
[44923.637610] R13: ffff881fce6f7f90 R14: ffff881fce6f7fa0 R15: ffff883fd12b9940
[44923.637882] FS:  0000000000000000(0000) GS:ffff883fff000000(0000)
knlGS:0000000000000000
[44923.638156] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[44923.638424] CR2: 0000008202990000 CR3: 0000001938f3a000 CR4: 00000000001407e0
[44923.638696] Stack:
[44923.638962]  ffff883fff003ce0 ffff882e5622be00 ffff883fff003d10
ffffffff81578e6b
[44923.639427]  0000000000000000 ffff882e5622be00 ffff882e5622be00
ffff881fce6f7f90
[44923.639890]  ffff883fff003d30 ffffffff81578ee8 ffff883fff003d50
ffff882e5622be00
[44923.640350] Call Trace:
[44923.640614]  <IRQ>
[44923.640663]
[44923.640973]  [<ffffffff81578e6b>] skb_release_data+0xab/0x100
[44923.641245]  [<ffffffff81578ee8>] skb_release_all+0x28/0x30
[44923.641512]  [<ffffffff81578f46>] __kfree_skb+0x16/0xa0
[44923.641781]  [<ffffffff81579311>] consume_skb+0x31/0x90
[44923.642061]  [<ffffffff815847bd>] dev_kfree_skb_any+0x3d/0x50
[44923.642356]  [<ffffffffa00bf11c>] ixgbe_poll+0xec/0x6b0 [ixgbe]
[44923.642639]  [<ffffffff8158a4fc>] net_rx_action+0x12c/0x280
[44923.642925]  [<ffffffff8108ede7>] __do_softirq+0x137/0x2e0
[44923.643211]  [<ffffffff8164ae8c>] call_softirq+0x1c/0x30
[44923.643494]  [<ffffffff8104a35d>] do_softirq+0x8d/0xc0
[44923.643778]  [<ffffffff8108e985>] irq_exit+0x95/0xa0
[44923.644062]  [<ffffffff8164b3f6>] do_IRQ+0x66/0xe0
[44923.644346]  [<ffffffff81648c6f>] common_interrupt+0x6f/0x6f
[44923.644624]  <EOI>
[44923.644677]
[44923.645001]  [<ffffffff810c6d94>] ? dequeue_entity+0x174/0x5b0
[44923.645286]  [<ffffffff81648790>] ? _raw_spin_unlock_irqrestore+0x20/0x50
[44923.645574]  [<ffffffffa0147c28>] process_prepared+0x68/0xa0 [dm_thin_pool]
[44923.645863]  [<ffffffffa014a1de>] do_worker+0x4e/0x270 [dm_thin_pool]
[44923.646151]  [<ffffffff810a6245>] process_one_work+0x195/0x550
[44923.646435]  [<ffffffff810a84ea>] worker_thread+0x13a/0x430
[44923.646717]  [<ffffffff810a83b0>] ? manage_workers+0x2c0/0x2c0
[44923.647003]  [<ffffffff810ae4ee>] kthread+0xce/0xe0
[44923.647288]  [<ffffffff810ae420>] ? kthread_freezable_should_stop+0x80/0x80
[44923.647573]  [<ffffffff81649648>] ret_from_fork+0x58/0x90
[44923.647856]  [<ffffffff810ae420>] ? kthread_freezable_should_stop+0x80/0x80
[44923.648138] Code: 48 83 c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00
00 00 00 55 48 89 e5 53 48 83 ec 08 0f 1f 44 00 00 48 85 ff 74 15 0f
1f 44 00 00 <48> 8b 1f e8 50 fe ff ff 48 89 df 48 85 db 75 f0 48 83 c4
08 5b
[44923.652122] RIP  [<ffffffff81579178>] kfree_skb_list+0x18/0x30
[44923.652459]  RSP <ffff883fff003cd0>
[44923.652735] CR2: 0000008202990000

After looking into the code in try_to_coalesce I think there is an
error in the function.
Particularly, I think it's wrong to print a WARN_ON and at the same
time return true
for the coalescing code. This means that we have wrongly calculated
delta ( I don't know
how this can actually, occur - a bogus packet?), yet we've coalesced
the skbs. Even though
this has occured on 3.12.49 kernel, the code for this function is the
same in 4.3-rc6.

I've created the following patch (against 4.3-rc6) which I believe
could fix the issue:

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fab4599ba8b2..d0ac294f412a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4156,6 +4156,8 @@ bool skb_try_coalesce(struct sk_buff *to, struct
sk_buff * from,
                        return false;

                delta = from->truesize - SKB_DATA_ALIGN(sizeof(struct sk_buff));
+               if (WARN_ON_ONCE(delta < len)
+                       return false;

                page = virt_to_head_page(from->head);
                offset = from->data - (unsigned char *)page_address(page);
@@ -4163,6 +4165,7 @@ bool skb_try_coalesce(struct sk_buff *to, struct
sk_buff * from,
                skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
                                   page, offset, skb_headlen(from));
                *fragstolen = true;
+
        } else {
                if (skb_shinfo(to)->nr_frags +
                    skb_shinfo(from)->nr_frags > MAX_SKB_FRAGS)
@@ -4171,7 +4174,8 @@ bool skb_try_coalesce(struct sk_buff *to, struct
sk_buff * from,
                delta = from->truesize - SKB_TRUESIZE(skb_end_offset(from));
        }

-       WARN_ON_ONCE(delta < len);
+       WARN_ON_ONCE(delta < len)
+               return false;

        memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
               skb_shinfo(from)->frags,



Could you please comment whether it looks viable so that I can resend
as a proper fix? Also the interesting question is what kind of packets
could trigger this warn_on_once? In both traces ovs_packet_cmd_execute
is present so I suspect it might be possible that somehow openvswitch is
injecting wrong packets which make the kernel crash.
