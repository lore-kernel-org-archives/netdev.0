From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: mlx5: ifup failure due to huge allocation
Date: Wed, 2 Nov 2016 14:37:58 +0100 (CET)
Message-ID: <alpine.LFD.2.20.1611021431410.1831@schleppi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Ifup on an interface provided by CX4 (MLX5 driver) on s390 fails with:

[   22.318553] ------------[ cut here ]------------
[   22.318564] WARNING: CPU: 1 PID: 399 at mm/page_alloc.c:3421 __alloc_pages_nodemask+0x2ee/0x1298
[   22.318568] Modules linked in: mlx4_ib ib_core mlx5_core mlx4_en mlx4_core [...]
[   22.318610] CPU: 1 PID: 399 Comm: NetworkManager Not tainted 4.8.0 #13
[   22.318614] Hardware name: IBM              2964 N96              704              (LPAR)
[   22.318618] task: 00000000dbe1c008 task.stack: 00000000dd9e4000
[   22.318622] Krnl PSW : 0704c00180000000 00000000002a427e (__alloc_pages_nodemask+0x2ee/0x1298)
[   22.318631]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:0 PM:0 RI:0 EA:3
               Krnl GPRS: 0000000000000000 0000000000ceb4d4 00000000024080c0 0000000000000001
[   22.318640]            00000000002a4204 00000000ffffa410 00000000001fffff 0000000000000001
[   22.318644]            00000000024080c0 0000000000000009 0000000000000000 0000000000000000
[   22.318648]            00000000ffffa400 000000000088ea30 00000000002a4204 00000000dd9e7060
[   22.318660] Krnl Code: 00000000002a4272: a7740592            brc     7,2a4d96
                          00000000002a4276: 92011000            mvi     0(%r1),1
                         #00000000002a427a: a7f40001            brc     15,2a427c
                         >00000000002a427e: a7f4058c            brc     15,2a4d96
                          00000000002a4282: 5830f0b4            l       %r3,180(%r15)
                          00000000002a4286: 5030f0ec            st      %r3,236(%r15)
                          00000000002a428a: 1823                lr      %r2,%r3
                          00000000002a428c: a53e0048            llilh   %r3,72
[   22.318695] Call Trace:
[   22.318700] ([<00000000002a4204>] __alloc_pages_nodemask+0x274/0x1298)
[   22.318706] ([<000000000030dac0>] alloc_pages_current+0x1c0/0x268)
[   22.318712] ([<0000000000135aa6>] s390_dma_alloc+0x6e/0x1e0)
[   22.318733] ([<000003ff8015474c>] mlx5_dma_zalloc_coherent_node+0xb4/0xf8 [mlx5_core])
[   22.318748] ([<000003ff80154c58>] mlx5_buf_alloc_node+0x70/0x108 [mlx5_core])
[   22.318765] ([<000003ff8015fe06>] mlx5_cqwq_create+0xf6/0x180 [mlx5_core])
[   22.318783] ([<000003ff8016654c>] mlx5e_open_cq+0xac/0x1e0 [mlx5_core])
[   22.318802] ([<000003ff801693e6>] mlx5e_open_channels+0xe66/0xeb8 [mlx5_core])
[   22.318820] ([<000003ff8016982e>] mlx5e_open_locked+0x8e/0x1e0 [mlx5_core])
[   22.318837] ([<000003ff801699c6>] mlx5e_open+0x46/0x68 [mlx5_core])
[   22.318844] ([<0000000000748338>] __dev_open+0xa8/0x118)
[   22.318848] ([<000000000074867a>] __dev_change_flags+0xc2/0x190)
[   22.318853] ([<000000000074877e>] dev_change_flags+0x36/0x78)
[   22.318858] ([<000000000075bc8a>] do_setlink+0x332/0xb30)
[   22.318862] ([<000000000075de3a>] rtnl_newlink+0x3e2/0x820)
[   22.318867] ([<000000000075e46e>] rtnetlink_rcv_msg+0x1f6/0x248)
[   22.318873] ([<0000000000782202>] netlink_rcv_skb+0x92/0x108)
[   22.318878] ([<000000000075c668>] rtnetlink_rcv+0x48/0x58)
[   22.318882] ([<0000000000781ace>] netlink_unicast+0x14e/0x1f0)
[   22.318887] ([<0000000000781f82>] netlink_sendmsg+0x32a/0x3b0)
[   22.318892] ([<000000000071d502>] sock_sendmsg+0x5a/0x80)
[   22.318897] ([<000000000071ed38>] ___sys_sendmsg+0x270/0x2a8)
[   22.318901] ([<000000000071fe80>] __sys_sendmsg+0x60/0x90)
[   22.318905] ([<00000000007207c6>] SyS_socketcall+0x2be/0x388)
[   22.318912] ([<000000000086fcae>] system_call+0xd6/0x270)
[   22.318916] 3 locks held by NetworkManager/399:
[   22.318920]  #0:  (rtnl_mutex){+.+.+.}, at: [<000000000075c658>] rtnetlink_rcv+0x38/0x58
[   22.318935]  #1:  (&priv->state_lock){+.+.+.}, at: [<000003ff801699bc>] mlx5e_open+0x3c/0x68 [mlx5_core]
[   22.318962]  #2:  (&priv->alloc_mutex){+.+.+.}, at: [<000003ff801546e0>] mlx5_dma_zalloc_coherent_node+0x48/0xf8 [mlx5_core]
[   22.318987] Last Breaking-Event-Address:
[   22.318992]  [<00000000002a427a>] __alloc_pages_nodemask+0x2ea/0x1298
[   22.318996] ---[ end trace d2b54f5a0cd00b89 ]---
[   22.319001] mlx5_core 0001:00:00.0: 0001:00:00.0:mlx5_cqwq_create:121:(pid 399): mlx5_buf_alloc_node() failed, -12
[   22.320548] mlx5_core 0001:00:00.0 enP1s171: mlx5e_open_locked: mlx5e_open_channels failed, -12



This fails because the largest possible allocation on s390 is currently 1MB (order 8).
Would it be possible to add the __GFP_NOWARN flag and try a smaller allocation if the
big one failed? (The latter change also would make the device usable when it is added
via hotplug and free memory is scattered).

Regards,
Sebastian
