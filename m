From: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v2] sctp: fully initialize the IPv6 address in sctp_v6_to_addr()
Date: Tue, 15 Aug 2017 10:43:59 +0900
Message-ID: <CAPA1RqDzSs3LogN+z69Ba2yoE6=jniobC-tEGd3TTh3z=39qxg@mail.gmail.com>
References: <20170814184304.82747-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        marcelo.leitner@gmail.com, lucien.xin@gmail.com,
        vyasevich@gmail.com, David Miller <davem@davemloft.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-sctp@vger.kernel.org, network dev <netdev@vger.kernel.org>,
        =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Alexander Potapenko <glider@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:33999 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753585AbdHOBoV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 21:44:21 -0400
Received: by mail-it0-f50.google.com with SMTP id m34so13182773iti.1
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 18:44:20 -0700 (PDT)
In-Reply-To: <20170814184304.82747-1-glider@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2017-08-15 3:43 GMT+09:00 Alexander Potapenko <glider@google.com>:
> KMSAN reported use of uninitialized sctp_addr->v4.sin_addr.s_addr and
> sctp_addr->v6.sin6_scope_id in sctp_v6_cmp_addr() (see below).
> Make sure all fields of an IPv6 address are initialized, which
> guarantees that the IPv4 fields are also initialized.
>
> ==================================================================
>  BUG: KMSAN: use of uninitialized memory in sctp_v6_cmp_addr+0x8d4/0x9f0
>  net/sctp/ipv6.c:517
>  CPU: 2 PID: 31056 Comm: syz-executor1 Not tainted 4.11.0-rc5+ #2944
>  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs
>  01/01/2011
>  Call Trace:
>   dump_stack+0x172/0x1c0 lib/dump_stack.c:42
>   is_logbuf_locked mm/kmsan/kmsan.c:59 [inline]
>   kmsan_report+0x12a/0x180 mm/kmsan/kmsan.c:938
>   native_save_fl arch/x86/include/asm/irqflags.h:18 [inline]
>   arch_local_save_flags arch/x86/include/asm/irqflags.h:72 [inline]
>   arch_local_irq_save arch/x86/include/asm/irqflags.h:113 [inline]
>   __msan_warning_32+0x61/0xb0 mm/kmsan/kmsan_instr.c:467
>   sctp_v6_cmp_addr+0x8d4/0x9f0 net/sctp/ipv6.c:517
>   sctp_v6_get_dst+0x8c7/0x1630 net/sctp/ipv6.c:290
>   sctp_transport_route+0x101/0x570 net/sctp/transport.c:292
>   sctp_assoc_add_peer+0x66d/0x16f0 net/sctp/associola.c:651
>   sctp_sendmsg+0x35a5/0x4f90 net/sctp/socket.c:1871
>   inet_sendmsg+0x498/0x670 net/ipv4/af_inet.c:762
>   sock_sendmsg_nosec net/socket.c:633 [inline]
>   sock_sendmsg net/socket.c:643 [inline]
>   SYSC_sendto+0x608/0x710 net/socket.c:1696
>   SyS_sendto+0x8a/0xb0 net/socket.c:1664
>   entry_SYSCALL_64_fastpath+0x13/0x94
>  RIP: 0033:0x44b479
>  RSP: 002b:00007f6213f21c08 EFLAGS: 00000286 ORIG_RAX: 000000000000002c
>  RAX: ffffffffffffffda RBX: 0000000020000000 RCX: 000000000044b479
>  RDX: 0000000000000041 RSI: 0000000020edd000 RDI: 0000000000000006
>  RBP: 00000000007080a8 R08: 0000000020b85fe4 R09: 000000000000001c
>  R10: 0000000000040005 R11: 0000000000000286 R12: 00000000ffffffff
>  R13: 0000000000003760 R14: 00000000006e5820 R15: 0000000000ff8000
>  origin description: ----dst_saddr@sctp_v6_get_dst
>  local variable created at:
>   sk_fullsock include/net/sock.h:2321 [inline]
>   inet6_sk include/linux/ipv6.h:309 [inline]
>   sctp_v6_get_dst+0x91/0x1630 net/sctp/ipv6.c:241
>   sctp_transport_route+0x101/0x570 net/sctp/transport.c:292
> ==================================================================
>  BUG: KMSAN: use of uninitialized memory in sctp_v6_cmp_addr+0x8d4/0x9f0
>  net/sctp/ipv6.c:517
>  CPU: 2 PID: 31056 Comm: syz-executor1 Not tainted 4.11.0-rc5+ #2944
>  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs
>  01/01/2011
>  Call Trace:
>   dump_stack+0x172/0x1c0 lib/dump_stack.c:42
>   is_logbuf_locked mm/kmsan/kmsan.c:59 [inline]
>   kmsan_report+0x12a/0x180 mm/kmsan/kmsan.c:938
>   native_save_fl arch/x86/include/asm/irqflags.h:18 [inline]
>   arch_local_save_flags arch/x86/include/asm/irqflags.h:72 [inline]
>   arch_local_irq_save arch/x86/include/asm/irqflags.h:113 [inline]
>   __msan_warning_32+0x61/0xb0 mm/kmsan/kmsan_instr.c:467
>   sctp_v6_cmp_addr+0x8d4/0x9f0 net/sctp/ipv6.c:517
>   sctp_v6_get_dst+0x8c7/0x1630 net/sctp/ipv6.c:290
>   sctp_transport_route+0x101/0x570 net/sctp/transport.c:292
>   sctp_assoc_add_peer+0x66d/0x16f0 net/sctp/associola.c:651
>   sctp_sendmsg+0x35a5/0x4f90 net/sctp/socket.c:1871
>   inet_sendmsg+0x498/0x670 net/ipv4/af_inet.c:762
>   sock_sendmsg_nosec net/socket.c:633 [inline]
>   sock_sendmsg net/socket.c:643 [inline]
>   SYSC_sendto+0x608/0x710 net/socket.c:1696
>   SyS_sendto+0x8a/0xb0 net/socket.c:1664
>   entry_SYSCALL_64_fastpath+0x13/0x94
>  RIP: 0033:0x44b479
>  RSP: 002b:00007f6213f21c08 EFLAGS: 00000286 ORIG_RAX: 000000000000002c
>  RAX: ffffffffffffffda RBX: 0000000020000000 RCX: 000000000044b479
>  RDX: 0000000000000041 RSI: 0000000020edd000 RDI: 0000000000000006
>  RBP: 00000000007080a8 R08: 0000000020b85fe4 R09: 000000000000001c
>  R10: 0000000000040005 R11: 0000000000000286 R12: 00000000ffffffff
>  R13: 0000000000003760 R14: 00000000006e5820 R15: 0000000000ff8000
>  origin description: ----dst_saddr@sctp_v6_get_dst
>  local variable created at:
>   sk_fullsock include/net/sock.h:2321 [inline]
>   inet6_sk include/linux/ipv6.h:309 [inline]
>   sctp_v6_get_dst+0x91/0x1630 net/sctp/ipv6.c:241
>   sctp_transport_route+0x101/0x570 net/sctp/transport.c:292
> ==================================================================
>
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Reviewed-by: Xin Long <lucien.xin@gmail.com>
> ---
> v2 is identical to v1, resending per request by Marcelo Ricardo Leitner.
> ---
>  net/sctp/ipv6.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index 2a186b201ad2..a15d691829c6 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -513,6 +513,8 @@ static void sctp_v6_to_addr(union sctp_addr *addr, struct in6_addr *saddr,
>         addr->sa.sa_family = AF_INET6;
>         addr->v6.sin6_port = port;
>         addr->v6.sin6_addr = *saddr;
> +       addr->v6.sin6_flowinfo = 0;
> +       addr->v6.sin6_scope_id = 0;

Please set flowinfo between port and addr.

--yoshfuji

>  }
>
>  /* Compare addresses exactly.
> --
> 2.14.0.434.g98096fd7a8-goog
>
