From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Re: [PATCH v3 net-next 1/4] tcp: ULP infrastructure
Date: Sun, 25 Jun 2017 02:42:53 +0000
Message-ID: <20170625024258.qoynefxset3cmdla@sasha-lappy>
References: <cover.1497465295.git.davejwatson@fb.com>
 <20170614183714.GA80310@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        "Matan Barak" <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Alexei Starovoitov" <alexei.starovoitov@gmail.com>,
        "nmav@gnutls.org" <nmav@gnutls.org>,
        "fridolin.pokorny@gmail.com" <fridolin.pokorny@gmail.com>
To: Dave Watson <davejwatson@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omzsmtpe01.verizonbusiness.com ([199.249.25.210]:25818 "EHLO
        omzsmtpe01.verizonbusiness.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751144AbdFYCnR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Jun 2017 22:43:17 -0400
In-Reply-To: <20170614183714.GA80310@davejwatson-mba.dhcp.thefacebook.com>
Content-Language: en-US
Content-ID: <43836D28FD4C2844962AFAC2F895E454@vzwcorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 14, 2017 at 11:37:14AM -0700, Dave Watson wrote:
>Add the infrustructure for attaching Upper Layer Protocols (ULPs) over TCP
>sockets. Based on a similar infrastructure in tcp_cong.  The idea is that =
any
>ULP can add its own logic by changing the TCP proto_ops structure to its o=
wn
>methods.
>
>Example usage:
>
>setsockopt(sock, SOL_TCP, TCP_ULP, "tls", sizeof("tls"));
>
>modules will call:
>tcp_register_ulp(&tcp_tls_ulp_ops);
>
>to register/unregister their ulp, with an init function and name.
>
>A list of registered ulps will be returned by tcp_get_available_ulp, which=
 is
>hooked up to /proc.  Example:
>
>$ cat /proc/sys/net/ipv4/tcp_available_ulp
>tls
>
>There is currently no functionality to remove or chain ULPs, but
>it should be possible to add these in the future if needed.
>
>Signed-off-by: Boris Pismenny <borisp@mellanox.com>
>Signed-off-by: Dave Watson <davejwatson@fb.com>

Hey Dave,

I'm seeing the following while fuzzing, which was bisected to this commit:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BUG: KASAN: null-ptr-deref in copy_to_user include/linux/uaccess.h:168 [inl=
ine]
BUG: KASAN: null-ptr-deref in do_tcp_getsockopt.isra.33+0x24f/0x1e30 net/ip=
v4/tcp.c:3057
Read of size 4 at addr 0000000000000020 by task syz-executor1/15452

CPU: 0 PID: 15452 Comm: syz-executor1 Not tainted 4.12.0-rc6-next-20170623+=
 #173
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1=
 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x11d/0x1e5 lib/dump_stack.c:52
 kasan_report_error mm/kasan/report.c:349 [inline]
 kasan_report+0x15e/0x370 mm/kasan/report.c:408
 check_memory_region_inline mm/kasan/kasan.c:260 [inline]
 check_memory_region+0x14b/0x1a0 mm/kasan/kasan.c:267
 kasan_check_read+0x11/0x20 mm/kasan/kasan.c:272
 copy_to_user include/linux/uaccess.h:168 [inline]
 do_tcp_getsockopt.isra.33+0x24f/0x1e30 net/ipv4/tcp.c:3057
 tcp_getsockopt+0xb0/0xd0 net/ipv4/tcp.c:3194
 sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2863
 SYSC_getsockopt net/socket.c:1869 [inline]
 SyS_getsockopt+0x180/0x360 net/socket.c:1851
 do_syscall_64+0x267/0x740 arch/x86/entry/common.c:284
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x451759
RSP: 002b:00007f5dc2b1fc08 EFLAGS: 00000216 ORIG_RAX: 0000000000000037
RAX: ffffffffffffffda RBX: 0000000000718000 RCX: 0000000000451759
RDX: 000000000000001f RSI: 0000000000000006 RDI: 0000000000000005
RBP: 0000000000000c30 R08: 00000000207bf000 R09: 0000000000000000
R10: 0000000020000ffc R11: 0000000000000216 R12: 00000000004b824b
R13: 00000000ffffffff R14: 0000000000000005 R15: 0000000000000006
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Disabling lock debugging due to kernel taint
Kernel panic - not syncing: panic_on_warn set ...

CPU: 0 PID: 15452 Comm: syz-executor1 Tainted: G    B           4.12.0-rc6-=
next-20170623+ #173
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1=
 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x11d/0x1e5 lib/dump_stack.c:52
 panic+0x1bc/0x3ad kernel/panic.c:180
 kasan_end_report+0x47/0x4f mm/kasan/report.c:176
 kasan_report_error mm/kasan/report.c:356 [inline]
 kasan_report+0x167/0x370 mm/kasan/report.c:408
 check_memory_region_inline mm/kasan/kasan.c:260 [inline]
 check_memory_region+0x14b/0x1a0 mm/kasan/kasan.c:267
 kasan_check_read+0x11/0x20 mm/kasan/kasan.c:272
 copy_to_user include/linux/uaccess.h:168 [inline]
 do_tcp_getsockopt.isra.33+0x24f/0x1e30 net/ipv4/tcp.c:3057
 tcp_getsockopt+0xb0/0xd0 net/ipv4/tcp.c:3194
 sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2863
 SYSC_getsockopt net/socket.c:1869 [inline]
 SyS_getsockopt+0x180/0x360 net/socket.c:1851
 do_syscall_64+0x267/0x740 arch/x86/entry/common.c:284
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x451759
RSP: 002b:00007f5dc2b1fc08 EFLAGS: 00000216 ORIG_RAX: 0000000000000037
RAX: ffffffffffffffda RBX: 0000000000718000 RCX: 0000000000451759
RDX: 000000000000001f RSI: 0000000000000006 RDI: 0000000000000005
RBP: 0000000000000c30 R08: 00000000207bf000 R09: 0000000000000000
R10: 0000000020000ffc R11: 0000000000000216 R12: 00000000004b824b
R13: 00000000ffffffff R14: 0000000000000005 R15: 0000000000000006
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: 0x24800000 from 0xffffffff81000000 (relocation range: 0xffff=
ffff80000000-0xffffffffbfffffff)
Rebooting in 86400 seconds..

--=20

Thanks,
Sasha=
