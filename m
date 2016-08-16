From: David Ahern <dsa@cumulusnetworks.com>
Subject: kernel panic in qdisc_match_from_root starting openvswitch
Date: Tue, 16 Aug 2016 12:27:57 -0600
Message-ID: <bfb76544-6d3a-dcd4-9338-72ecfda9f691@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Simon Horman <simon.horman@netronome.com>
To: jkosina@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34948 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbcHPS2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 14:28:00 -0400
Received: by mail-pf0-f174.google.com with SMTP id x72so30017307pfd.2
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 11:28:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri:

I am hitting a kernel panic with '/etc/init.d/openvswitch-switch restart' Stack trace below. Reverting 59cc1f61f09c ("net: sched: convert qdisc linked list to hashtable") clears the problem.


    [   30.664503] BUG: unable to handle kernel NULL pointer dereference at 0000000000000418
    [   30.665960] IP: [<ffffffff813ecf65>] qdisc_match_from_root+0x2a/0x58
    [   30.667146] PGD 134bfd067 PUD 1377d2067 PMD 0
    [   30.667983] Oops: 0000 [#1] SMP
    [   30.668574] Modules linked in: openvswitch nf_conntrack_ipv6 nf_nat_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_defrag_ipv6 nf_nat nf_conntrack libcrc32c crc32c_intel 8021q garp mrp stp llc vrf
    [   30.672770] CPU: 3 PID: 888 Comm: ovs-vswitchd Not tainted 4.7.0+ #69
    [   30.674167] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
    [   30.676353] task: ffff880134031240 task.stack: ffff880134bd4000
    [   30.677633] RIP: 0010:[<ffffffff813ecf65>]  [<ffffffff813ecf65>] qdisc_match_from_root+0x2a/0x58
    [   30.679555] RSP: 0018:ffff880134bd7ae0  EFLAGS: 00010202
    [   30.680689] RAX: 0000000000000410 RBX: 0000000000010000 RCX: ffff8801340bd800
    [   30.682222] RDX: ffffffff81a8e380 RSI: 0000000000010000 RDI: ffffffff81a8e240
    [   30.683751] RBP: ffff880134bd7ae0 R08: 0000000000000000 R09: ffff880134031240
    [   30.685281] R10: 0000000000000024 R11: 000000007ffff000 R12: ffff8801340bd800
    [   30.686807] R13: ffff8801340bd800 R14: ffff880139976a00 R15: ffffffff81a886c0
    [   30.688338] FS:  00007f4753c6b940(0000) GS:ffff88013fd80000(0000) knlGS:0000000000000000
    [   30.690074] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
    [   30.691321] CR2: 0000000000000418 CR3: 00000001340f2000 CR4: 00000000000406e0
    [   30.692863] Stack:
    [   30.693310]  ffff880134bd7b00 ffffffff813eec03 ffff8801399b0e00 0000000000000000
    [   30.695013]  ffff880134bd7b98 ffffffff813ef0c1 ffff880134bd7b80 ffffffff811e2309
    [   30.696696]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
    [   30.698408] Call Trace:
    [   30.698958]  [<ffffffff813eec03>] qdisc_lookup+0x18/0x3a
    [   30.700113]  [<ffffffff813ef0c1>] tc_get_qdisc+0x102/0x19d
    [   30.701323]  [<ffffffff811e2309>] ? jbd2_journal_stop+0x6c/0x33e
    [   30.702616]  [<ffffffff813dd4ef>] rtnetlink_rcv_msg+0x178/0x187
    [   30.703911]  [<ffffffff81131d4a>] ? __kmalloc_track_caller+0xb1/0xc3
    [   30.705285]  [<ffffffff813bc885>] ? __alloc_skb+0x7b/0x19c
    [   30.706483]  [<ffffffff813f3be6>] ? rht_key_hashfn.isra.20.constprop.55+0x18/0x24
    [   30.708088]  [<ffffffff813dd377>] ? rtnl_newlink+0x6cf/0x6cf
    [   30.709327]  [<ffffffff813f60bd>] netlink_rcv_skb+0x45/0x8b
    [   30.710536]  [<ffffffff813d8fb4>] rtnetlink_rcv+0x1e/0x25
    [   30.711699]  [<ffffffff813f5c26>] netlink_unicast+0x114/0x192
    [   30.712948]  [<ffffffff813f5f71>] netlink_sendmsg+0x2cd/0x2ed
    [   30.714195]  [<ffffffff813b544b>] sock_sendmsg_nosec+0x12/0x1d
    [   30.715448]  [<ffffffff813b547a>] sock_sendmsg+0x24/0x29
    [   30.716602]  [<ffffffff813b5f30>] ___sys_sendmsg+0x1ad/0x21b
    [   30.717840]  [<ffffffff813c67c6>] ? dev_name_hash+0x27/0x40
    [   30.719039]  [<ffffffff813c6866>] ? dev_get_by_name_rcu+0x34/0x53
    [   30.720348]  [<ffffffff813e2062>] ? dev_ioctl+0x48f/0x5ab
    [   30.721532]  [<ffffffff813b32a5>] ? sock_do_ioctl+0x34/0x3d
    [   30.722734]  [<ffffffff813b32a5>] ? sock_do_ioctl+0x34/0x3d
    [   30.723947]  [<ffffffff81157dd3>] ? __fget+0x2a/0x64
    [   30.725018]  [<ffffffff813b6252>] __sys_sendmsg+0x40/0x5e
    [   30.726193]  [<ffffffff813b6252>] ? __sys_sendmsg+0x40/0x5e
    [   30.727389]  [<ffffffff813b6284>] SyS_sendmsg+0x14/0x16
    [   30.728523]  [<ffffffff814ae032>] entry_SYSCALL_64_fastpath+0x1a/0xa4
    [   30.729667] Code: c3 f6 47 10 01 55 48 89 e5 75 08 39 77 38 48 89 f8 74 44 69 c6 47 86 c8 61 48 8b 57 48 c1 e8 1c 48 8d 04 c5 d0 03 00 00 48 03 02 <48> 8b 50 08 31 c0 48 8d 4a d8 48 85 d2 48 0f 45 c1 48 85 c0 74
    [   30.733052] RIP  [<ffffffff813ecf65>] qdisc_match_from_root+0x2a/0x58
    [   30.733877]  RSP <ffff880134bd7ae0>
    [   30.734313] CR2: 0000000000000418
