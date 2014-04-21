From: Alexey Preobrazhensky <preobr@google.com>
Subject: Potential out-of-bounds access in ip6_finish_output2
Date: Mon, 21 Apr 2014 17:22:05 +0400
Message-ID: <CA+FTKhu_zEWrd8Zc4dj91D2fOmhwOQoH-W7byMpn1usJ1gZ6MA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>, yoshfuji@linux-ipv6.org,
	maze@google.com, edumazet@google.com, brutus@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:53034 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbaDUNW0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 09:22:26 -0400
Received: by mail-oa0-f47.google.com with SMTP id i11so4216894oag.34
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 06:22:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I=E2=80=99m working on AddressSanitizer[1] -- a tool that detects
use-after-free and out-of-bounds bugs in kernel.

I=E2=80=99ve encountered a heap-buffer-overflow in ip6_finish_output2 i=
n linux
kernel 3.14 (revision 455c6fdbd219161bd09b1165f11699d6d73de11c). A
similar problem was reported earlier[2] and resulted in a patch[3],
but we=E2=80=99ve hit this report again, so it seems the issue weren=E2=
=80=99t fixed,
or there is another issue. The offending code in
include/net/neighbour.h:401 is:

do {
        seq =3D read_seqbegin(&hh->hh_lock);
        hh_len =3D hh->hh_len;
        if (likely(hh_len <=3D HH_DATA_MOD)) {
                /* this is inlined by gcc */
/* 401: */    memcpy(skb->data - HH_DATA_MOD, hh->hh_data, HH_DATA_MOD)=
;
        } else {
                int hh_alen =3D HH_DATA_ALIGN(hh_len);

                memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
        }
} while (read_seqretry(&hh->hh_lock, seq));

This heap-buffer-overflow was triggered under trinity syscall fuzzer,
so there is no reproducer. The report is followed by crash (included).

It would be great if someone familiar with the code took time to look
into this report.

Thanks,
 Alexey

[1] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerFo=
rKernel
[2] http://www.spinics.net/lists/netdev/msg250734.html
[3] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3D2811ebac2521ceac84f2bdae402455baa6a7fb47

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
AddressSanitizer: heap-buffer-overflow in ip6_finish_output2
Write of size 16 by thread T15020:
[<     inlined    >] ip6_finish_output2+0x51e/0x840 [ipv6]
neigh_hh_output ./include/net/neighbour.h:401
[<     inlined    >] ip6_finish_output2+0x51e/0x840 [ipv6]
dst_neigh_output ./include/net/dst.h:409
[<ffffffffa0003a9e>] ip6_finish_output2+0x51e/0x840 [ipv6]
=2E/net/ipv6/ip6_output.c:113
[<ffffffffa0008efd>] ip6_fragment+0x12ed/0x14e0 [ipv6]
=2E/net/ipv6/ip6_output.c:664
[<ffffffffa0009247>] ip6_finish_output+0x157/0x1b0 [ipv6]
=2E/net/ipv6/ip6_output.c:130
[<     inlined    >] ip6_output+0x77/0x130 [ipv6] NF_HOOK_COND
=2E/include/linux/netfilter.h:186
[<ffffffffa0009317>] ip6_output+0x77/0x130 [ipv6] ./net/ipv6/ip6_output=
=2Ec:146
[<ffffffff8185c4fc>] ip6_local_out+0x3c/0x50 ??:0
[<ffffffffa0006b9a>] ip6_push_pending_frames+0x86a/0xa90 [ipv6]
=2E/net/ipv6/ip6_output.c:1573
[<     inlined    >] rawv6_sendmsg+0x1323/0x1680 [ipv6]
rawv6_push_pending_frames ./net/ipv6/raw.c:608
[<ffffffffa0033eb3>] rawv6_sendmsg+0x1323/0x1680 [ipv6] ./net/ipv6/raw.=
c:906
[<ffffffff81829a3a>] inet_sendmsg+0x10a/0x160 ./net/ipv4/af_inet.c:740
[<     inlined    >] sock_aio_write+0x263/0x290 do_sock_write ./net/soc=
ket.c:633
[<ffffffff81739003>] sock_aio_write+0x263/0x290 ./net/socket.c:973
[<ffffffff812b1ad9>] do_sync_write+0xd9/0x120 ??:0
[<ffffffff812b27fd>] vfs_write+0x2cd/0x2f0 ??:0
[<ffffffff812b3742>] SyS_write+0x62/0xd0 ??:0
[<ffffffff8188e492>] system_call_fastpath+0x16/0x1b
=2E/arch/x86/kernel/entry_64.S:629

Allocated by thread T15020:
[<ffffffff81295a86>] __kmalloc_node_track_caller+0x36/0x60 ./mm/slab.c:=
3567
[<     inlined    >] __alloc_skb+0x8f/0x290 __kmalloc_reserve
=2E/net/core/skbuff.c:132
[<ffffffff817487ef>] __alloc_skb+0x8f/0x290 ./net/core/skbuff.c:225
[<     inlined    >] sock_wmalloc+0x5d/0x100 alloc_skb
=2E/include/linux/skbuff.h:668
[<ffffffff81742aed>] sock_wmalloc+0x5d/0x100 ./net/core/sock.c:1649
[<ffffffffa000614d>] ip6_append_data+0x1c1d/0x1e00 [ipv6]
=2E/net/ipv6/ip6_output.c:1359
[<ffffffffa0033ac5>] rawv6_sendmsg+0xf35/0x1680 [ipv6] ./net/ipv6/raw.c=
:899
[<ffffffff81829a3a>] inet_sendmsg+0x10a/0x160 ./net/ipv4/af_inet.c:740
[<     inlined    >] sock_aio_write+0x263/0x290 do_sock_write ./net/soc=
ket.c:633
[<ffffffff81739003>] sock_aio_write+0x263/0x290 ./net/socket.c:973
[<ffffffff812b1ad9>] do_sync_write+0xd9/0x120 ??:0
[<ffffffff812b27fd>] vfs_write+0x2cd/0x2f0 ??:0
[<ffffffff812b3742>] SyS_write+0x62/0xd0 ??:0
[<ffffffff8188e492>] system_call_fastpath+0x16/0x1b
=2E/arch/x86/kernel/entry_64.S:629

The buggy address ffff880035ab9bb8 is located 8 bytes to the left
of 448-byte region [ffff880035ab9bc0, ffff880035ab9d80)

Memory state around the buggy address:
ffff880035ab9600: rrrrrrrr ........ ........ ........
ffff880035ab9700: ........ .......r rrrrrrrr rrrrrrrr
ffff880035ab9800: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
ffff880035ab9900: ........ ........ ........ ........
ffff880035ab9a00: .......r rrrrrrrr rrrrrrrr rrrrrrrr
>ffff880035ab9b00: rrrrrrrr rrrrrrrr rrrrrrrr ........
                                           ^
ffff880035ab9c00: ........ ........ ........ ........
ffff880035ab9d00: ........ ........ rrrrrrrr rrrrrrrr
ffff880035ab9e00: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
ffff880035ab9f00: rrrrrrrr rrrrrrrr rrrrrrrr rrrrrrrr
ffff880035aba000: rrrrrrrr r....... .rrrrrrr rrrrrrrr
Legend:
f - 8 freed bytes
r - 8 redzone bytes
=2E - 8 allocated bytes
x=3D1..7 - x allocated bytes + (8-x) redzone bytes
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
skbuff: skb_under_panic: text:ffffffffa0003abb len:102 put:14
head:ffff880035ab9bc0 data:ffff880035ab9bba tail:0x60 end:0x80 dev:lo
------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:99!
invalid opcode: 0000 [#1] SMP
Modules linked in: sr_mod cdrom loop 8021q bridge stp llc st ipt_ULOG
nfnetlink i2c_piix4 i2c_core msr cpuid e1000 ipv6
CPU: 0 PID: 15020 Comm: trinity-child39 Not tainted 3.14.0-smp-DEV #1
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
task: ffff8800355d69c0 ti: ffff880026d70000 task.ti: ffff880026d70000
RIP: 0010:[<ffffffff8174709c>]  [<ffffffff8174709c>] skb_panic+0xcc/0xd=
0
RSP: 0018:ffff880026d71820  EFLAGS: 00010282
RAX: 0000000000000083 RBX: ffff88002bc8f680 RCX: ffff88003fc0d308
RDX: ffff880036400600 RSI: ffff88003fc0d308 RDI: ffff88003fc0d300
RBP: ffff880026d71888 R08: 000000000000000a R09: 0000000000000006
R10: 0000000000000011 R11: 0000000000000000 R12: ffff8800345aaa80
R13: ffff880035ab9bba R14: 0000000000000060 R15: 0000000000000080
=46S:  000000000092e880(0063) GS:ffff88003fc00000(0000) knlGS:000000000=
0000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f027d76c000 CR3: 00000000316af000 CR4: 00000000000006f0
Stack:
ffff880035ab9bba 0000000000000060 0000000000000080 ffff8800345aaa80
0000000e35ab9bb8 ffffffffa0003abb ffffffff81a9e440 ffff880035ab9bc0
ffff88002bc8f680 ffff880035ab9bba 000000000000000e ffff88002bc8f6e0
Call Trace:
[<ffffffffa0003abb>] ? ip6_finish_output2+0x53b/0x840 [ipv6]
[<ffffffff8174713e>] skb_push+0x9e/0xa0 ./net/core/skbuff.c:109
[<     inlined    >] ip6_finish_output2+0x53b/0x840 [ipv6]
neigh_hh_output ./include/net/neighbour.h:409
[<     inlined    >] ip6_finish_output2+0x53b/0x840 [ipv6]
dst_neigh_output ./include/net/dst.h:409
[<ffffffffa0003abb>] ip6_finish_output2+0x53b/0x840 [ipv6]
=2E/net/ipv6/ip6_output.c:113
[<     inlined    >] ? asan_memcpy+0x5a2/0x630 check_memory_region
=2E/arch/x86/mm/asan/asan.c:256
[<ffffffff810e47c2>] ? asan_memcpy+0x5a2/0x630 ./arch/x86/mm/asan/asan.=
c:547
[<ffffffffa0008efd>] ip6_fragment+0x12ed/0x14e0 [ipv6]
=2E/net/ipv6/ip6_output.c:664
[<ffffffffa0003580>] ? ip6_flush_pending_frames+0x1c0/0x1c0 [ipv6]
[<     inlined    >] ? kmem_cache_alloc_node_trace+0x9c/0x640
slab_alloc_node ./mm/slab.c:3257
[<ffffffff812954ac>] ? kmem_cache_alloc_node_trace+0x9c/0x640 ./mm/slab=
=2Ec:3548
[<ffffffffa0009247>] ip6_finish_output+0x157/0x1b0 [ipv6]
=2E/net/ipv6/ip6_output.c:130
[<     inlined    >] ip6_output+0x77/0x130 [ipv6] NF_HOOK_COND
=2E/include/linux/netfilter.h:186
[<ffffffffa0009317>] ip6_output+0x77/0x130 [ipv6] ./net/ipv6/ip6_output=
=2Ec:146
[<ffffffff8185c4fc>] ip6_local_out+0x3c/0x50 ??:0
[<ffffffffa0006b9a>] ip6_push_pending_frames+0x86a/0xa90 [ipv6]
=2E/net/ipv6/ip6_output.c:1573
[<     inlined    >] rawv6_sendmsg+0x1323/0x1680 [ipv6]
rawv6_push_pending_frames ./net/ipv6/raw.c:608
[<ffffffffa0033eb3>] rawv6_sendmsg+0x1323/0x1680 [ipv6] ./net/ipv6/raw.=
c:906
[<ffffffff81223e27>] ? __generic_file_aio_write+0x367/0x560 ./mm/filema=
p.c:2524
[<ffffffff81829a3a>] inet_sendmsg+0x10a/0x160 ./net/ipv4/af_inet.c:740
[<     inlined    >] sock_aio_write+0x263/0x290 do_sock_write ./net/soc=
ket.c:633
[<ffffffff81739003>] sock_aio_write+0x263/0x290 ./net/socket.c:973
[<ffffffff812b1ad9>] do_sync_write+0xd9/0x120 ??:0
[<ffffffff812b27fd>] vfs_write+0x2cd/0x2f0 ??:0
[<ffffffff812b3742>] SyS_write+0x62/0xd0 ??:0
[<ffffffff8188e492>] system_call_fastpath+0x16/0x1b
=2E/arch/x86/kernel/entry_64.S:629
Code: c7 50 7e b9 81 44 8b 45 bc 48 8b 55 c0 31 c0 48 8b 75 c8 4c 89
64 24 18 4c 89 7c 24 10 4c 89 74 24 08 4c 89 2c 24 e8 c5 f3 12 00 <0f>
0b 66 90 0f 1f 44 00 00 55 48 89 e5 41 57 41 56 4c 8d b7 c8
RIP  [<ffffffff8174709c>] skb_panic+0xcc/0xd0
RSP <ffff880026d71820>
---[ end trace 3c86b5021571cac8 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range:
0xffffffff80000000-0xffffffff9fffffff)
Rebooting in 10 seconds..
