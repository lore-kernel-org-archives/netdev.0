From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: BUG in netxen_release_tx_buffers when TSO enabled on kernels >= 3.3 and <= 3.6
Date: Tue, 22 Jan 2013 11:15:17 +0100
Message-ID: <1659861.dHpGAGoXHj@cpaasch-mac>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: Ian Campbell <Ian.Campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:60307 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747Ab3AVKPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 05:15:48 -0500
Received: by mail-wi0-f172.google.com with SMTP id o1so7964080wic.11
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 02:15:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a scenario where I can trigger a bug on kernels >= 3.3 and <= 3.6. 
Thus, I can produce it with the latest longterm-stable v3.4.26.

The crashdumps/warning can be seen below. Sometimes it is only the warning, 
sometimes it also produces the crash. But, it happens each time I try out my 
scenario.


How to reproduce the bug (I have HP Proliant DL165 machines with HP NC375T 1Gb 
interface):

 * Launch an iperf-session ( -t 10 ) to a server over a 1Gbps interface.

 * After 5 seconds on the client, remove the IP-address from the interface
with ip addr del dev [itf] [ip]

 * Wait 10 more seconds and kill the iperf on the client and the server.

 * Then do: ifconfig down [itf]

Now the crash happens.

What I observe in netxen_release_tx_buffers is that upon the 18th iteration (j 
== 17), buffrag->length == 0. buffrag->frag_count is 18.
Sometimes (much more rare), buffrag->length rather looks like garbage (e.g., > 
2^32)


I bisected this, and it was introduced by commit 9d4dde521577 (net: only use a 
single page of slop in MAX_SKB_FRAGS). 
It was fixed by Eric in commit 5640f7685831 (net: use a per task frag 
allocator) since kernel > 3.6.

As this bug is present in the longterm-stable 3.4, should Eric's patch be 
backported?
If not, does somebody (with more knowledge than I have of this part of the 
code) can have a look at it, or maybe give me a pointer on how I could solve 
this properly?

Reverting commit 9d4dde521577 (net: only use a single page of slop in 
MAX_SKB_FRAGS) fixes it for me on 3.4.26.



Thanks,
Christoph



[  610.315966] ------------[ cut here ]------------
[  610.371099] WARNING: at /home/cpaasch/builder/net-next/lib/dma-debug.c:865 
check_unmap+0x18e/0x61e()
[  610.480197] Hardware name: ProLiant DL165 G7
[  610.531168] netxen_nic 0000:05:00.2: DMA-API: device driver tries to free 
DMA memory it has not allocated [device address=0x0000000000000012] [size=0 
bytes]
[  610.698391] Modules linked in:
[  610.734935] Pid: 3728, comm: ip Not tainted 3.4.26-mptcp #30
[  610.802511] Call Trace:
[  610.831692]  [<ffffffff81025af7>] warn_slowpath_common+0x80/0x98
[  610.903424]  [<ffffffff81025ba3>] warn_slowpath_fmt+0x41/0x43
[  610.972041]  [<ffffffff811c93d1>] check_unmap+0x18e/0x61e
[  611.036505]  [<ffffffff811c99aa>] debug_dma_unmap_page+0x50/0x52
[  611.108236]  [<ffffffff813642f3>] netxen_release_tx_buffers+0x11e/0x175
[  611.187232]  [<ffffffff813621a6>] __netxen_nic_down+0x12c/0x13f
[  611.257922]  [<ffffffff81362290>] netxen_nic_close+0x13/0x17
[  611.325502]  [<ffffffff813fc7dc>] __dev_close_many+0x90/0xbc
[  611.393079]  [<ffffffff813fc839>] __dev_close+0x31/0x42
[  611.455469]  [<ffffffff813fa38d>] __dev_change_flags+0xb9/0x13d
[  611.526160]  [<ffffffff813fd16e>] dev_change_flags+0x1c/0x52
[  611.593740]  [<ffffffff814075ad>] do_setlink+0x2c0/0x7d2
[  611.657167]  [<ffffffff8146fcb5>] ? inet6_fill_ifla6_attrs+0x205/0x219
[  611.735124]  [<ffffffff814085a3>] rtnl_newlink+0x26b/0x4a1
[  611.800626]  [<ffffffff81408400>] ? rtnl_newlink+0xc8/0x4a1
[  611.867166]  [<ffffffff81419ebb>] ? netlink_sendmsg+0x22b/0x2b2
[  611.937859]  [<ffffffff8109fcf3>] ? check_object+0x13b/0x1df
[  612.005437]  [<ffffffff8140831d>] rtnetlink_rcv_msg+0x22c/0x247
[  612.076128]  [<ffffffff814080f1>] ? rtnetlink_rcv+0x28/0x28
[  612.142668]  [<ffffffff81419c3f>] netlink_rcv_skb+0x3e/0x8f
[  612.209209]  [<ffffffff814080ea>] rtnetlink_rcv+0x21/0x28
[  612.273673]  [<ffffffff81419a01>] netlink_unicast+0x134/0x1ab
[  612.342289]  [<ffffffff81419eda>] netlink_sendmsg+0x24a/0x2b2
[  612.410908]  [<ffffffff813ebb1a>] sock_sendmsg+0xb8/0xd1
[  612.474332]  [<ffffffff81073a29>] ? filemap_fault+0x199/0x35d
[  612.542948]  [<ffffffff810732ab>] ? unlock_page+0x2d/0x32
[  612.607412]  [<ffffffff810894c2>] ? __do_fault+0x3ce/0x409
[  612.672916]  [<ffffffff813eb239>] ? move_addr_to_kernel+0x3a/0x51
[  612.745685]  [<ffffffff813f4f76>] ? verify_iovec+0x59/0xaf
[  612.811187]  [<ffffffff813ec675>] __sys_sendmsg+0x1b9/0x23e
[  612.877725]  [<ffffffff8108c2ab>] ? handle_mm_fault+0x1b7/0x1cd
[  612.948420]  [<ffffffff8101f08e>] ? do_page_fault+0x336/0x375
[  613.017035]  [<ffffffff81090681>] ? do_brk+0x2e4/0x346
[  613.078385]  [<ffffffff813ec80d>] sys_sendmsg+0x3d/0x5e
[  613.140775]  [<ffffffff814e62a2>] system_call_fastpath+0x16/0x1b
[  613.212502] ---[ end trace d4f0eb8a4ca35e8a ]---



[  719.276359] BUG: unable to handle kernel paging request at ffffc900103cd000
[  719.359733] IP: [<ffffffff81364295>] netxen_release_tx_buffers+0xc0/0x175
[  719.440926] PGD 42d851067 PUD 42d852067 PMD 42c11b067 PTE 0
[  719.507897] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  719.562307] CPU 7
[  719.584214] Modules linked in:
[  719.622944]
[  719.640700] Pid: 4563, comm: ip Tainted: G        W    3.4.26-mptcp #30 HP 
ProLiant DL165 G7
[  719.741707] RIP: 0010:[<ffffffff81364295>]  [<ffffffff81364295>] 
netxen_release_tx_buffers+0xc0/0x175
[  719.851952] RSP: 0018:ffff880422c79668  EFLAGS: 00010246
[  719.915380] RAX: ffff88042dbce360 RBX: ffffc900103cced0 RCX: 
0000000000000000
[  720.000603] RDX: 0000000000000011 RSI: 0000000000000282 RDI: 
0000000000000000
[  720.085826] RBP: ffff880422c796b8 R08: 0000000000000000 R09: 
ffff88042dbce3e8
[  720.171049] R10: 0000000000000001 R11: 0000000000000206 R12: 
ffffc900103ccff8
[  720.256273] R13: ffff88042d9aa720 R14: 0000000000000012 R15: 
0000000000000000
[  720.341499] FS:  00007f191d157700(0000) GS:ffff88043fdc0000(0000) 
knlGS:0000000000000000
[  720.438138] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  720.506755] CR2: ffffc900103cd000 CR3: 0000000422cbd000 CR4: 
00000000000007e0
[  720.591979] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[  720.677203] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[  720.762427] Process ip (pid: 4563, threadinfo ffff880422c78000, task 
ffff88042d9b4b90)
[  720.856990] Stack:
[  720.880968]  ffff880422c796b8 0000000000000000 ffff88042bc53b28 
00000011000003ff
[  720.969736]  ffff880422c796b8 ffff88042d9aa720 ffff88042bc6c920 
0000000000000001
[  721.058506]  ffff88042d9aa0a0 0000000000000007 ffff880422c796f8 
ffffffff813621a6
[  721.147273] Call Trace:
[  721.176450]  [<ffffffff813621a6>] __netxen_nic_down+0x12c/0x13f
[  721.247140]  [<ffffffff81362290>] netxen_nic_close+0x13/0x17
[  721.314721]  [<ffffffff813fc7dc>] __dev_close_many+0x90/0xbc
[  721.382295]  [<ffffffff813fc839>] __dev_close+0x31/0x42
[  721.444687]  [<ffffffff813fa38d>] __dev_change_flags+0xb9/0x13d
[  721.515378]  [<ffffffff813fd16e>] dev_change_flags+0x1c/0x52
[  721.582958]  [<ffffffff814075ad>] do_setlink+0x2c0/0x7d2
[  721.646384]  [<ffffffff8146fcb5>] ? inet6_fill_ifla6_attrs+0x205/0x219
[  721.724342]  [<ffffffff814085a3>] rtnl_newlink+0x26b/0x4a1
[  721.789842]  [<ffffffff81408400>] ? rtnl_newlink+0xc8/0x4a1
[  721.856384]  [<ffffffff81419ebb>] ? netlink_sendmsg+0x22b/0x2b2
[  721.927079]  [<ffffffff8109fcf3>] ? check_object+0x13b/0x1df
[  721.994659]  [<ffffffff8140831d>] rtnetlink_rcv_msg+0x22c/0x247
[  722.065351]  [<ffffffff814080f1>] ? rtnetlink_rcv+0x28/0x28
[  722.131893]  [<ffffffff81419c3f>] netlink_rcv_skb+0x3e/0x8f
[  722.198433]  [<ffffffff814080ea>] rtnetlink_rcv+0x21/0x28
[  722.262897]  [<ffffffff81419a01>] netlink_unicast+0x134/0x1ab
[  722.331515]  [<ffffffff81419eda>] netlink_sendmsg+0x24a/0x2b2
[  722.400131]  [<ffffffff813ebb1a>] sock_sendmsg+0xb8/0xd1
[  722.463559]  [<ffffffff81073a29>] ? filemap_fault+0x199/0x35d
[  722.532171]  [<ffffffff810732ab>] ? unlock_page+0x2d/0x32
[  722.596636]  [<ffffffff810894c2>] ? __do_fault+0x3ce/0x409
[  722.662140]  [<ffffffff813eb239>] ? move_addr_to_kernel+0x3a/0x51
[  722.734909]  [<ffffffff813f4f76>] ? verify_iovec+0x59/0xaf
[  722.800410]  [<ffffffff813ec675>] __sys_sendmsg+0x1b9/0x23e
[  722.866951]  [<ffffffff8108c2ab>] ? handle_mm_fault+0x1b7/0x1cd
[  722.937643]  [<ffffffff8101f08e>] ? do_page_fault+0x336/0x375
[  723.006260]  [<ffffffff81090681>] ? do_brk+0x2e4/0x346
[  723.067610]  [<ffffffff813ec80d>] sys_sendmsg+0x3d/0x5e
[  723.129998]  [<ffffffff814e62a2>] system_call_fastpath+0x16/0x1b
[  723.201724] Code: e6 ff 48 c7 43 08 00 00 00 00 4c 8d 63 08 c7 45 cc 00 00 
00 00 eb 7d 49 83 c4 10 4d 8b 34 24 4d 85 f6 74 6d 49 8b 45 58 45 31 ff <4d> 
8b 4c 24 08 48 85 c0 74 13 4c 8d b8 88 00 00 00 48 8b 80 b8
[  723.434030] RIP  [<ffffffff81364295>] netxen_release_tx_buffers+0xc0/0x175
[  723.516249]  RSP <ffff880422c79668>
[  723.557878] CR2: ffffc900103cd000
[  723.597832] ---[ end trace d4f0eb8a4ca35e8b ]---


-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
UCLouvain
--
