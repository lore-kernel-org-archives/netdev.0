From: Xin Long <lucien.xin@gmail.com>
Subject: Re: net/sctp: null-ptr-deref in sctp_put_port/sctp_endpoint_destroy
Date: Fri, 10 Feb 2017 01:22:50 +0800
Message-ID: <CADvbK_cSzM+wLMnDGjDdEV=GHh2iw69STFeLpuc6j_2os8Q99w@mail.gmail.com>
References: <CAAeHK+wX-KCOEseoYAgKzX1UZm4ucT6jSxx7U_hT=SzNPx2FOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+wX-KCOEseoYAgKzX1UZm4ucT6jSxx7U_hT=SzNPx2FOQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 9, 2017 at 3:00 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit 926af6273fc683cd98cd0ce7bf0d04a02eed6742.
>
> A reproducer and .config are attached.
>
> general protection fault: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 3 PID: 19506 Comm: syz-executor0 Not tainted 4.10.0-rc7+ #126
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88003d7c1700 task.stack: ffff880037990000
> RIP: 0010:__write_once_size include/linux/compiler.h:272 [inline]
> RIP: 0010:__hlist_del include/linux/list.h:635 [inline]
> RIP: 0010:__sk_del_bind_node include/net/sock.h:685 [inline]
> RIP: 0010:__sctp_put_port net/sctp/socket.c:6994 [inline]
> RIP: 0010:sctp_put_port+0x210/0x620 net/sctp/socket.c:7004
> RSP: 0018:ffff8800379969e0 EFLAGS: 00010246
> RAX: dffffc0000000010 RBX: 1ffff10006f32d41 RCX: ffff880037996a28
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: dffffc0000000000
> RBP: ffff880037996b10 R08: 0000000000000000 R09: 0000000000000000
> R10: 1c8b9dfca637effe R11: dffffc0000000000 R12: 0000000000000005
> R13: ffff880037996ae8 R14: ffff88003a066c40 R15: ffff88003a067178
> FS:  00007fd314dba700(0000) GS:ffff88006df00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020002ffc CR3: 000000003b10e000 CR4: 00000000000006e0
> Call Trace:
>  sctp_endpoint_destroy net/sctp/endpointola.c:275 [inline]
>  sctp_endpoint_put+0x1b2/0x260 net/sctp/endpointola.c:296
>  sctp_endpoint_free+0x97/0xc0 net/sctp/endpointola.c:238
>  sctp_destroy_sock+0xd6/0x470 net/sctp/socket.c:4254
>  sctp_v6_destroy_sock+0x15/0x20 net/sctp/socket.c:7871
>  sk_common_release+0xbf/0x4e0 net/core/sock.c:2747
>  sctp_close+0x764/0x9f0 net/sctp/socket.c:1550
>  inet_release+0xed/0x1c0 net/ipv4/af_inet.c:425
>  inet6_release+0x50/0x70 net/ipv6/af_inet6.c:431
>  sock_release+0x8d/0x1e0 net/socket.c:599
>  sock_close+0x16/0x20 net/socket.c:1063
>  __fput+0x332/0x7f0 fs/file_table.c:208
>  ____fput+0x15/0x20 fs/file_table.c:244
>  task_work_run+0x19b/0x270 kernel/task_work.c:116
>  exit_task_work include/linux/task_work.h:21 [inline]
>  do_exit+0x186b/0x2800 kernel/exit.c:839
>  do_group_exit+0x149/0x420 kernel/exit.c:943
>  get_signal+0x76d/0x17e0 kernel/signal.c:2313
>  do_signal+0xd2/0x2190 arch/x86/kernel/signal.c:807
>  exit_to_usermode_loop+0x170/0x200 arch/x86/entry/common.c:156
>  prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
>  syscall_return_slowpath+0x3d3/0x420 arch/x86/entry/common.c:259
>  entry_SYSCALL_64_fastpath+0xc0/0xc2
> RIP: 0033:0x4458b9
> RSP: 002b:00007fd314db9cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
> RAX: fffffffffffffe00 RBX: 0000000000708170 RCX: 00000000004458b9
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000708170
> RBP: 0000000000708150 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
> R13: 0000000000000000 R14: 00007fd314dba9c0 R15: 00007fd314dba700
> Code: ff ff ff 49 8b 76 20 48 bf 00 00 00 00 00 fc ff df 49 89 c8 49
> c1 e8 03 41 c6 04 38 00 49 89 f0 49 89 95 40 ff ff ff 49 c1 e8 03 <41>
> 80 3c 38 00 0f 85 f6 02 00 00 48 c1 e9 03 49 b8 00 00 00 00
> RIP: __write_once_size include/linux/compiler.h:272 [inline] RSP:
> ffff8800379969e0
> RIP: __hlist_del include/linux/list.h:635 [inline] RSP: ffff8800379969e0
> RIP: __sk_del_bind_node include/net/sock.h:685 [inline] RSP: ffff8800379969e0
> RIP: __sctp_put_port net/sctp/socket.c:6994 [inline] RSP: ffff8800379969e0
> RIP: sctp_put_port+0x210/0x620 net/sctp/socket.c:7004 RSP: ffff8800379969e0
> ---[ end trace 54c316f8731a5a88 ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
the script is trying to add a new mrtable and set raw6_sk(sk)->ip6mr_table,
but it's a sctp_sock. to set raw6_sk(sk)->ip6mr_table will cover
sctp_sock(sk)->bind_hash, as [1] and [2] are at the same
offset, this issue then is triggered when release this sk.

struct sctp_sock {
    [0x0] struct inet_sock inet;
  [0x3d0] sctp_socket_type_t type;
  [0x3d8] struct sctp_pf *pf;
  [0x3e0] struct crypto_hash *hmac;
  [0x3e8] char *sctp_hmac_alg;
  [0x3f0] struct sctp_endpoint *ep;
  [0x3f8] struct sctp_bind_bucket *bind_hash; <----[1]
  ...

struct raw6_sock {
    [0x0] struct inet_sock inet;
  [0x3d0] __u32 checksum;
  [0x3d4] __u32 offset;
  [0x3d8] struct icmp6_filter filter;
  [0x3f8] __u32 ip6mr_table; <------[2]
  ...

We may need to check sk->sk_type != SOCK_RAW in the case
MRT6_TABLE in ip6_mroute_setsockopt just as in case MRT6_INIT.
The similar issue may also exists in other protocol sk.
