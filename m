From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/nfc: GPF in llcp_sock_getname
Date: Fri, 1 Jan 2016 12:58:11 -0800
Message-ID: <CAM_iQpX-vHywG6DJb=5wLCouNAXXqA1wo=tKJ1S78MDyZfkNCw@mail.gmail.com>
References: <CACT4Y+baorktL_dBHEWcz_jHYTzhM_-DJoms81bzVx8FbYk63w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:36398 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbcAAU6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jan 2016 15:58:13 -0500
In-Reply-To: <CACT4Y+baorktL_dBHEWcz_jHYTzhM_-DJoms81bzVx8FbYk63w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 1, 2016 at 5:58 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>
> kasan: GPF could be caused by NULL-ptr deref or user memory
> accessgeneral protection fault: 0000 [#51] SMP KASAN
> Modules linked in:
> CPU: 2 PID: 4207 Comm: a.out Not tainted 4.4.0-rc7+ #184
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff8800683e9780 ti: ffff880064c70000 task.ti: ffff880064c70000
> RIP: 0010:[<ffffffff816d1d5b>]  [<ffffffff816d1d5b>]
> kasan_report_error+0x1b/0x560
> RSP: 0018:ffff880064c77c90  EFLAGS: 00010286
> RAX: dffffc0000000000 RBX: 0000000000000003 RCX: dffffc0000000000
> RDX: 0000000000000000 RSI: 0000000000000003 RDI: ffff880064c77c98
> RBP: ffff880064c77cc0 R08: ffffed000c98efd6 R09: ffff880064c77e58
> R10: ffff8800639670a0 R11: ffff880063967098 R12: ffff880064c77e6a
> R13: 0000000000000000 R14: 0000000000000000 R15: ffff880063967088
> FS:  00000000018ca880(0063) GS:ffff88006da00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 000000c8200012e0 CR3: 0000000064c59000 CR4: 00000000000006e0
> Stack:
>  ffffffff816d25d4 0000000000000000 0000000000000018 0000000000000003
>  0000000300004000 ffffffff816d17ed ffff880064c77cd0 ffffffff816d1264
>  ffff880064c77cf8 ffffffff816d17ed 0000000000000000 ffff880064c77e58
> Call Trace:
>  [<     inline     >] check_memory_region mm/kasan/kasan.c:264
>  [<ffffffff816d1264>] __asan_loadN+0x124/0x1a0 mm/kasan/kasan.c:512
>  [<ffffffff816d17ed>] memcpy+0x1d/0x40 mm/kasan/kasan.c:297
>  [<ffffffff85becf44>] llcp_sock_getname+0x424/0x600 net/nfc/llcp_sock.c:519
>  [<ffffffff84b5ab4d>] SYSC_getsockname+0x1bd/0x220 net/socket.c:1570
>  [<ffffffff84b60244>] SyS_getsockname+0x24/0x30 net/socket.c:1555
>  [<ffffffff85c8eaf6>] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185
> Code: 48 01 c7 e8 38 2b fc ff 5d c3 66 0f 1f 44 00 00 48 8b 17 48 b9
> 00 00 00 00 00 fc ff df 48 8b 77 10 48 89 d0 48 c1 e8 03 48 01 c8 <80>
> 38 00 75 1d 48 01 d6 eb 13 48 83 c2 08 48 89 d0 48 c1 e8 03
> RIP  [<ffffffff816d1d5b>] kasan_report_error+0x1b/0x560 mm/kasan/report.c:214
>  RSP <ffff880064c77c90>
> ---[ end trace b0c68fb0d02b9447 ]---
>
> On commit 8513342170278468bac126640a5d2d12ffbff106 (Dec 28).
> GPF seems to be caused by a data race on socket state.

It looks like we forget to initialize ->service_name_len
and ->servicce_name before bind().

Could you try the following patch?

Thanks!

----------------->

diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index ecf0a01..252f3c0 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -961,6 +961,8 @@ struct sock *nfc_llcp_sock_alloc(struct socket
*sock, int type, gfp_t gfp, int k

        llcp_sock->ssap = 0;
        llcp_sock->dsap = LLCP_SAP_SDP;
+       llcp_sock->service_name_len = 0;
+       llcp_sock->service_name = NULL;
        llcp_sock->rw = LLCP_MAX_RW + 1;
        llcp_sock->miux = cpu_to_be16(LLCP_MAX_MIUX + 1);
        llcp_sock->send_n = llcp_sock->send_ack_n = 0;
