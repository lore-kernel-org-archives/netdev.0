From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/llc: bug in llc_pdu_init_as_xid_cmd/skb_over_panic
Date: Sun, 12 Feb 2017 17:45:21 +0100
Message-ID: <CAAeHK+xu-r8DzGHaXMHEDNnZ+SecddD3hAbTEPO2PHUpL_B8mQ@mail.gmail.com>
References: <CAAeHK+w9jDhPRFjTd=e5EK+jRyv__7ou-WpQpXZ_5c5wv7uAPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, acme@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+w9jDhPRFjTd=e5EK+jRyv__7ou-WpQpXZ_5c5wv7uAPQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 10, 2017 at 4:12 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit 926af6273fc683cd98cd0ce7bf0d04a02eed6742.
>
> A reproducer and .config are attached
>
> kernel BUG at net/core/skbuff.c:105!
> invalid opcode: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 2 PID: 6558 Comm: syz-executor4 Not tainted 4.10.0-rc7+ #126
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88003c49c480 task.stack: ffff88003a5c0000
> RIP: 0010:skb_panic+0x16f/0x200 net/core/skbuff.c:101
> RSP: 0018:ffff88003a5c77d0 EFLAGS: 00010286
> RAX: 0000000000000082 RBX: ffff88006be991c0 RCX: 0000000000000000
> RDX: 0000000000000082 RSI: ffffffff814567fc RDI: ffffed00074b8eec
> RBP: ffff88003a5c7838 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000002 R11: 0000000000000001 R12: ffffffff85231ee0
> R13: ffffffff834a6722 R14: 0000000000000003 R15: ffff88006c81c580
> FS:  00007f89298c7700(0000) GS:ffff88006de00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020ee5000 CR3: 0000000058697000 CR4: 00000000000006e0
> Call Trace:
>  skb_over_panic net/core/skbuff.c:110 [inline]
>  skb_put+0x18d/0x1d0 net/core/skbuff.c:1437
>  llc_pdu_init_as_xid_cmd include/net/llc_pdu.h:377 [inline]
>  llc_sap_action_send_xid_c+0x2a2/0x3b0 net/llc/llc_s_ac.c:82
>  llc_exec_sap_trans_actions net/llc/llc_sap.c:152 [inline]
>  llc_sap_next_state net/llc/llc_sap.c:181 [inline]
>  llc_sap_state_process+0x26b/0x4e0 net/llc/llc_sap.c:212
>  llc_build_and_send_xid_pkt+0x19f/0x200 net/llc/llc_sap.c:276
>  llc_ui_sendmsg+0xad9/0x1430 net/llc/af_llc.c:938
>  sock_sendmsg_nosec net/socket.c:635 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:645
>  ___sys_sendmsg+0x9d2/0xae0 net/socket.c:1985
>  __sys_sendmsg+0x138/0x320 net/socket.c:2019
>  SYSC_sendmsg net/socket.c:2030 [inline]
>  SyS_sendmsg+0x2d/0x50 net/socket.c:2026
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x4458b9
> RSP: 002b:00007f89298c6b58 EFLAGS: 00000286 ORIG_RAX: 000000000000002e
> RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004458b9
> RDX: 0000000000040085 RSI: 0000000020001fc8 RDI: 0000000000000005
> RBP: 00000000006e1ae0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000286 R12: 0000000000708000
> R13: ffffffffffffffff R14: 00000000c0206434 R15: 00000000201fcfe0
> Code: 00 00 00 48 89 54 24 10 48 c7 c7 60 19 23 85 48 89 74 24 08 4c
> 89 04 24 4c 89 ea 4c 89 7c 24 18 45 89 f0 4c 89 e6 e8 1e c0 38 fe <0f>
> 0b 4c 89 4d b8 4c 89 45 c0 48 89 75 c8 48 89 55 d0 e8 6a 5e
> RIP: skb_panic+0x16f/0x200 net/core/skbuff.c:101 RSP: ffff88003a5c77d0
> ---[ end trace 89f0ca2ea5bc3ead ]---
> Kernel panic - not syncing: Fatal exception
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..

+acme@redhat.com
