From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: linux-next: UBSAN whine and BUG in net/ipv4/fib_trie.c
Date: Mon, 06 Jun 2016 16:43:41 -0400
Message-ID: <4427.1465245821@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1465245821_2052P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1465245821_2052P
Content-Type: text/plain; charset=us-ascii

Seeing this in next-20160606 (next-20160530 is fine), does it ring
any bells before I spend a long evening doing a bisect?  The Google
doesn't seem to have seen this traceback in the past week....

[  226.938222] ================================================================================
[  226.938231] UBSAN: Undefined behaviour in net/ipv4/fib_trie.c:1573:14
[  226.938235] shift exponent 136 is too large for 64-bit type 'long unsigned int'

[  226.938403] ================================================================================
[  226.938406] UBSAN: Undefined behaviour in net/ipv4/fib_trie.c:1589:22
[  226.938409] shift exponent 136 is too large for 64-bit type 'long unsigned int'

[  226.938434] Call Trace:
[  226.938437]  [<ffffffffa06998ea>] dump_stack+0x7b/0xd1
[  226.938441]  [<ffffffffa071114d>] ubsan_epilogue+0xd/0x40
[  226.938445]  [<ffffffffa0711799>] __ubsan_handle_shift_out_of_bounds+0xf9/0x150
[  226.938449]  [<ffffffffa0140031>] ? cpuacct_account_field+0x251/0x2b0
[  226.938453]  [<ffffffffa03ced14>] ? bh_lru_install+0x244/0x2c0
[  226.938456]  [<ffffffffa0d3e122>] leaf_walk_rcu+0x302/0x440
[  226.938460]  [<ffffffffa0d4508b>] fib_table_dump+0x6b/0x440
[  226.938464]  [<ffffffffa0d35d34>] ? inet_dump_fib+0x74/0x370
[  226.938468]  [<ffffffffa0d35e02>] inet_dump_fib+0x142/0x370
[  226.938471]  [<ffffffffa0d35d34>] ? inet_dump_fib+0x74/0x370
[  226.938475]  [<ffffffffa0c2533c>] rtnl_dump_all+0x12c/0x350
[  226.938479]  [<ffffffffa0bd7a76>] ? __alloc_skb+0x96/0x2c0
[  226.938482]  [<ffffffffa0c60f14>] netlink_dump+0x174/0x3e0
[  226.938486]  [<ffffffffa0c62720>] __netlink_dump_start+0x190/0x240
[  226.938490]  [<ffffffffa0c25f40>] rtnetlink_rcv_msg+0x1c0/0x640
[  226.938493]  [<ffffffffa01479b6>] ? trace_hardirqs_on_caller+0x16/0x2c0
[  226.938497]  [<ffffffffa0c25210>] ? fdb_vid_parse+0x90/0x90
[  226.938500]  [<ffffffffa0c25210>] ? fdb_vid_parse+0x90/0x90
[  226.938504]  [<ffffffffa0c25d80>] ? rtnl_link_unregister+0x140/0x140
[  226.938508]  [<ffffffffa0c66c17>] netlink_rcv_skb+0x87/0xc0
[  226.938511]  [<ffffffffa0c23dca>] rtnetlink_rcv+0x2a/0x40
[  226.938515]  [<ffffffffa0c661a0>] netlink_unicast+0x200/0x300
[  226.938518]  [<ffffffffa0c666a2>] netlink_sendmsg+0x402/0x670
[  226.938523]  [<ffffffffa0bc8bab>] sock_sendmsg+0x5b/0xd0
[  226.938526]  [<ffffffffa0bc8f13>] SYSC_sendto+0x153/0x1f0
[  226.938531]  [<ffffffffa05c0de5>] ? selinux_socket_setsockopt+0x45/0x60
[  226.938535]  [<ffffffffa1089652>] ? entry_SYSCALL_64_fastpath+0x5/0xa8
[  226.938538]  [<ffffffffa01479b6>] ? trace_hardirqs_on_caller+0x16/0x2c0
[  226.938541]  [<ffffffffa000222a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[  226.938545]  [<ffffffffa0bc9fde>] SyS_sendto+0xe/0x10
[  226.938549]  [<ffffffffa1089665>] entry_SYSCALL_64_fastpath+0x18/0xa8
[  226.938553]  [<ffffffffa0142a0f>] ? trace_hardirqs_off_caller+0x1f/0xf0

followed by a not-surprising BUG while we pagefault because we went off
the deep end:

[  226.938555] ================================================================================
[  226.938559] BUG: sleeping function called from invalid context at arch/x86/mm/fault.c:1309
[  226.938563] in_atomic(): 0, irqs_disabled(): 0, pid: 4577, name: geoclue
[  226.938565] INFO: lockdep is turned off.

[  226.938591] Call Trace:
[  226.938595]  [<ffffffffa06998ea>] dump_stack+0x7b/0xd1
[  226.938599]  [<ffffffffa00f91c6>] ___might_sleep+0x196/0x2f0
[  226.938603]  [<ffffffffa00f9385>] __might_sleep+0x65/0x1f0
[  226.938607]  [<ffffffffa0087566>] __do_page_fault+0x5b6/0x7d0
[  226.938611]  [<ffffffffa008778c>] do_page_fault+0xc/0x10
[  226.938614]  [<ffffffffa108b1c2>] page_fault+0x22/0x30
[  226.938619]  [<ffffffffa0d3dfb5>] ? leaf_walk_rcu+0x195/0x440
[  226.938622]  [<ffffffffa0d3df95>] ? leaf_walk_rcu+0x175/0x440
[  226.938626]  [<ffffffffa0d4508b>] fib_table_dump+0x6b/0x440
[  226.938630]  [<ffffffffa0d35d34>] ? inet_dump_fib+0x74/0x370
[  226.938633]  [<ffffffffa0d35e02>] inet_dump_fib+0x142/0x370
[  226.938637]  [<ffffffffa0d35d34>] ? inet_dump_fib+0x74/0x370
[  226.938641]  [<ffffffffa0c2533c>] rtnl_dump_all+0x12c/0x350
[  226.938644]  [<ffffffffa0bd7a76>] ? __alloc_skb+0x96/0x2c0
[  226.938648]  [<ffffffffa0c60f14>] netlink_dump+0x174/0x3e0
[  226.938651]  [<ffffffffa0c62720>] __netlink_dump_start+0x190/0x240
[  226.938655]  [<ffffffffa0c25f40>] rtnetlink_rcv_msg+0x1c0/0x640
[  226.938658]  [<ffffffffa01479b6>] ? trace_hardirqs_on_caller+0x16/0x2c0
[  226.938662]  [<ffffffffa0c25210>] ? fdb_vid_parse+0x90/0x90
[  226.938666]  [<ffffffffa0c25210>] ? fdb_vid_parse+0x90/0x90
[  226.938669]  [<ffffffffa0c25d80>] ? rtnl_link_unregister+0x140/0x140
[  226.938673]  [<ffffffffa0c66c17>] netlink_rcv_skb+0x87/0xc0
[  226.938677]  [<ffffffffa0c23dca>] rtnetlink_rcv+0x2a/0x40
[  226.938680]  [<ffffffffa0c661a0>] netlink_unicast+0x200/0x300
[  226.938684]  [<ffffffffa0c666a2>] netlink_sendmsg+0x402/0x670
[  226.938688]  [<ffffffffa0bc8bab>] sock_sendmsg+0x5b/0xd0
[  226.938692]  [<ffffffffa0bc8f13>] SYSC_sendto+0x153/0x1f0
[  226.938696]  [<ffffffffa05c0de5>] ? selinux_socket_setsockopt+0x45/0x60
[  226.938700]  [<ffffffffa1089652>] ? entry_SYSCALL_64_fastpath+0x5/0xa8
[  226.938703]  [<ffffffffa01479b6>] ? trace_hardirqs_on_caller+0x16/0x2c0
[  226.938706]  [<ffffffffa000222a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[  226.938710]  [<ffffffffa0bc9fde>] SyS_sendto+0xe/0x10
[  226.938714]  [<ffffffffa1089665>] entry_SYSCALL_64_fastpath+0x18/0xa8
[  226.938718]  [<ffffffffa0142a0f>] ? trace_hardirqs_off_caller+0x1f/0xf0

and then the wheels come totally off the bus:

[  226.938728] BUG: unable to handle kernel paging request at 00000000000f6105
[  226.938733] IP: [<ffffffffa0d3dfb5>] leaf_walk_rcu+0x195/0x440
[  226.938738] PGD 0
[  226.938742] Oops: 0000 [#1] PREEMPT SMP

[  226.938845] Call Trace:
[  226.938849]  [<ffffffffa0d4508b>] fib_table_dump+0x6b/0x440
[  226.938853]  [<ffffffffa0d35d34>] ? inet_dump_fib+0x74/0x370
[  226.938857]  [<ffffffffa0d35e02>] inet_dump_fib+0x142/0x370
[  226.938860]  [<ffffffffa0d35d34>] ? inet_dump_fib+0x74/0x370
[  226.938864]  [<ffffffffa0c2533c>] rtnl_dump_all+0x12c/0x350
[  226.938867]  [<ffffffffa0bd7a76>] ? __alloc_skb+0x96/0x2c0
[  226.938871]  [<ffffffffa0c60f14>] netlink_dump+0x174/0x3e0
[  226.938874]  [<ffffffffa0c62720>] __netlink_dump_start+0x190/0x240
[  226.938878]  [<ffffffffa0c25f40>] rtnetlink_rcv_msg+0x1c0/0x640
[  226.938881]  [<ffffffffa01479b6>] ? trace_hardirqs_on_caller+0x16/0x2c0
[  226.938885]  [<ffffffffa0c25210>] ? fdb_vid_parse+0x90/0x90
[  226.938889]  [<ffffffffa0c25210>] ? fdb_vid_parse+0x90/0x90
[  226.938892]  [<ffffffffa0c25d80>] ? rtnl_link_unregister+0x140/0x140
[  226.938896]  [<ffffffffa0c66c17>] netlink_rcv_skb+0x87/0xc0
[  226.938900]  [<ffffffffa0c23dca>] rtnetlink_rcv+0x2a/0x40
[  226.938903]  [<ffffffffa0c661a0>] netlink_unicast+0x200/0x300
[  226.938906]  [<ffffffffa0c666a2>] netlink_sendmsg+0x402/0x670
[  226.938911]  [<ffffffffa0bc8bab>] sock_sendmsg+0x5b/0xd0
[  226.938914]  [<ffffffffa0bc8f13>] SYSC_sendto+0x153/0x1f0
[  226.938919]  [<ffffffffa05c0de5>] ? selinux_socket_setsockopt+0x45/0x60
[  226.938923]  [<ffffffffa1089652>] ? entry_SYSCALL_64_fastpath+0x5/0xa8
[  226.938926]  [<ffffffffa01479b6>] ? trace_hardirqs_on_caller+0x16/0x2c0
[  226.938929]  [<ffffffffa000222a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[  226.938933]  [<ffffffffa0bc9fde>] SyS_sendto+0xe/0x10
[  226.938936]  [<ffffffffa1089665>] entry_SYSCALL_64_fastpath+0x18/0xa8
[  226.938940]  [<ffffffffa0142a0f>] ? trace_hardirqs_off_caller+0x1f/0xf0



--==_Exmh_1465245821_2052P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBV1XgfQdmEQWDXROgAQI78A//btOrtPWbh94U9RVdoQDUAE9Drw8oAE91
vzt5kEyhczTvwLejUWNDfD7JkPNtyMt54S11aJbDT892XsZsTjYNI+7DILkFuCNm
k+3ep66YrBdSqS8/3bX3G+3nsfaOw/nud3NbPOegKcFHI/wUSMKP8d183l5f9pdQ
dSmmIIWbS3XqPxDtwc6vdlDv8BzoRoeqUYqoHFmAulNTlKPmVX477/JfLf1OR7cc
tS7HTUve1bqxvO+MmrCfIilBV/wtlw4rE15eryzFZR8HXPISUrb9s8EmctORG/eq
Ov6PK0yF7+x2bJXPIVgWcDJma5jBf6Z3LaJCATHFDHbpsdu94F8RZtaCmwzLYuD2
FoEXXZQEHLqSxC2tpSD3x/RWGKQMMCZb57vpaiEbgLfy2s4xk0XTivGCDKvmoEUx
7/8yh72avCzQR7girGS9MHu7PYOryHpgx4i95q+J9Vpqcc0xVtIOVX8OHnVq87zM
wQRPGGROpRrYwPzNjNFxEtOPp/5fR4Q7lXMNBVQ8v9zvJMMQhngyueMT2iIC91T7
0HyYKuAKGezroFF8Ih3IeI5MZRPi/rsVad/9NIPudIY10LT9ebsgFVVy1WCShF5d
7fFsdAkOHH2YoVk02mrg5XA7dgdKAxZ+2dkmvRaXdIaHRhJCouuhGaESEorz3s8O
l20f1bugY40=
=c8Dw
-----END PGP SIGNATURE-----

--==_Exmh_1465245821_2052P--
