From: Ani Sinha <ani@arista.com>
Subject: Re: tbl->lock not taken in neigh_lookup() ?
Date: Mon, 25 Jan 2016 10:11:15 +0530
Message-ID: <CAOxq_8Mj2kxq1r-MFGWCXBBE=7hi0ASy2p99=Tx4ageDTnMHtA@mail.gmail.com>
References: <CAOxq_8Okd4uLcj-MeLoms3mzpQhjX6t06fR6svDUeCV6VNEyAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34904 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754632AbcAYEla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 23:41:30 -0500
Received: by mail-ig0-f174.google.com with SMTP id t15so27736827igr.0
        for <netdev@vger.kernel.org>; Sun, 24 Jan 2016 20:41:29 -0800 (PST)
In-Reply-To: <CAOxq_8Okd4uLcj-MeLoms3mzpQhjX6t06fR6svDUeCV6VNEyAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All:

Can I get some insights into this? I am sure I am missing something.

thanks
ani


On Thu, Jan 21, 2016 at 9:05 PM, Ani Sinha <ani@arista.com> wrote:
> hi guys
>
> As per the comment at the top of net/core/neighbor.c we should be
> taking this lock even for scanning the hash buckets. I do see that
> this lock is taken in pneigh_lookup() but not in neigh_lookup(). Am i
> missing something?
>
> For the context I am investigating the following crash which happened
> on one of our boxes. This is in 3.18.19 kernel where the following
> code in neigh_lookup() returns a corrupt value of neighbour* :
>
> for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
>
>
>
> [ 4918.117044] BUG: unable to handle kernel paging request at 0000000014000270
> [ 4918.200203] IP: [<ffffffff813b84d5>] neigh_lookup+0x64/0xdf
> [ 4918.266790] PGD 7e383067 PUD 7e202067 PMD 0
> [ 4918.266795] Oops: 0000 [#1] PREEMPT SMP
> [ 4918.266798] Modules linked in: macvlan l2mod_dma(PO)
> arptable_filter arp_tables nf_log_ipv6 nf_conntrack_ipv6
> nf_defrag_ipv6 ip6t_REJECT nf_reject_ipv6 ip6table_mangle nf_log_ipv4
> nf_log_common nf_conntrack_ipv4 nf_defrag_ipv4 xt_LOG xt_limit xt_hl
> xt_conntrack ipt_REJECT nf_reject_ipv4 xt_multiport xt_tcpudp
> iptable_mangle sch_prio strata_dma(PO) arista_strata_bde(PO) msr
> kbfd(O) 8021q garp stp llc tun scd_em_driver(O) plxnt_nl(O)
> plxnt_ll(O) nf_conntrack_tftp iptable_raw iptable_filter ip_tables
> xt_CT nf_conntrack xt_mark ip6table_raw ip6table_filter ip6_tables
> x_tables coretemp microcode intel_ips scd(O) sb_e3_edac kvm_intel kvm
> [last unloaded: plxnt_ll]
> [ 4918.266837] CPU: 5 PID: 3315 Comm: Arp Tainted: P           O   3.18.19 #1
> [ 4918.266840] task: ffff8803c6dd3720 ti: ffff88007b98c000 task.ti:
> ffff88007b98c000
> [ 4918.266841] RIP: 0010:[<ffffffff813b84d5>]  [<ffffffff813b84d5>]
> neigh_lookup+0x64/0xdf
> [ 4918.266847] RSP: 0018:ffff88007b98faa8  EFLAGS: 00210206
> [ 4918.266849] RAX: ffff8803203bf278 RBX: ffffffff81866990 RCX: 0000000000000014
> [ 4918.266851] RDX: ffff88032a46624c RSI: ffff88005ff82000 RDI: ffff880319ee6020
> [ 4918.266852] RBP: ffff88007b98fad8 R08: 000000000a000000 R09: ffff880319ee6000
> [ 4918.266854] R10: ffff88007b98faf8 R11: ffff88043d001900 R12: 0000000014000100
> [ 4918.266855] R13: ffff880319ee6020 R14: ffff88005ff82000 R15: 0000000000000010
> [ 4918.266857] FS:  0000000000000000(0000) GS:ffff88044f540000(0063)
> knlGS:00000000f73cb8e0
> [ 4918.266859] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
> [ 4918.266860] CR2: 0000000014000270 CR3: 000000007e371000 CR4: 00000000000007e0
> [ 4918.266862] Stack:
> [ 4918.266863]  0000000000000180 ffffffff8185cd00 ffffffff81866990
> ffff880319ee6010
> [ 4918.266866]  ffff880319ee601c ffff88005ff82000 ffff88007b98fb28
> ffffffff813b97c2
> [ 4918.266869]  ffff88007b98faf8 ffffffff818282c0 ffff88007b98fb18
> ffff880377411600
> [ 4918.266872] Call Trace:
> [ 4918.266875] [<ffffffff813b97c2>] neigh_delete+0x113/0x17f
> [ 4918.266878] [<ffffffff813bdf1e>] rtnetlink_rcv_msg+0x18a/0x1a0
> [ 4918.266882] [<ffffffff8105580c>] ? get_parent_ip+0x11/0x42
> [ 4918.266885] [<ffffffff812005df>] ? rhashtable_lookup_compare+0x4b/0x71
> [ 4918.266887] [<ffffffff813bdd94>] ? rtnetlink_rcv_msg+0x0/0x1a0
> [ 4918.266890] [<ffffffff813cfd58>] netlink_rcv_skb+0x3e/0x94
> [ 4918.266891] [<ffffffff813be5ea>] rtnetlink_rcv+0x21/0x28
> [ 4918.266893] [<ffffffff813cfaed>] netlink_unicast+0x10b/0x1ad
> [ 4918.266895] [<ffffffff813d0304>] netlink_sendmsg+0x2e6/0x327
> [ 4918.266898] [<ffffffff81397efa>] sock_sendmsg+0x6d/0x86
> [ 4918.266901] [<ffffffff8139a2c3>] ? sock_poll+0x10e/0x11c
> [ 4918.266903] [<ffffffff813974d0>] ? sockfd_lookup_light+0x12/0x5d
> [ 4918.266906] [<ffffffff81398006>] SyS_sendto+0xf3/0x11b
> [ 4918.266909] [<ffffffff81486667>] ? __mutex_lock_slowpath+0x2de/0x2fe
> [ 4918.266911] [<ffffffff8105580c>] ? get_parent_ip+0x11/0x42
> [ 4918.266914] [<ffffffff81396dd0>] SyS_send+0xf/0x11
> [ 4918.266916] [<ffffffff813c61c7>] compat_SyS_socketcall+0x122/0x1e3
> [ 4918.266919] [<ffffffff8148b6df>] sysenter_dispatch+0x7/0x1e
> [ 4918.266920] Code: 00 00 4c 89 f6 4c 89 ef 49 8d 54 24 0c ff 53 18
> b9 20 00 00 00 41 2b 4c 24 08 d3 e8 89 c0 48 c1 e0 03 49 03 04 24 4c
> 8b 20 eb 55 <4d> 3b b4 24 70 01 00 00 75 47 49 8d bc 24 78 01 00 00 4c
> 89 fa
> [ 4918.266947] RIP  [<ffffffff813b84d5>] neigh_lookup+0x64/0xdf
> [ 4918.334502]  RSP <ffff88007b98faa8>
> [ 4918.334505] Kernel version: 3.18.19 #1 SMP PREEMPT Mon Jan 4
> 12:34:37 PST 2016
>
> [ 4918.455186] CR2: 0000000014000270
