From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: harden copy_linear_skb()
Date: Fri, 11 Aug 2017 15:01:15 -0700 (PDT)
Message-ID: <20170811.150115.297796132472385936.davem@davemloft.net>
References: <1502473733.4936.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60928 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753401AbdHKWBQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 18:01:16 -0400
In-Reply-To: <1502473733.4936.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 11 Aug 2017 10:48:53 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller got crashes with CONFIG_HARDENED_USERCOPY=y configs.
> 
> Issue here is that recvfrom() can be used with user buffer of Z bytes,
> and SO_PEEK_OFF of X bytes, from a skb with Y bytes, and following
> condition :
> 
> Z < X < Y
> 
> kernel BUG at mm/usercopy.c:72!
> invalid opcode: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 2917 Comm: syzkaller842281 Not tainted 4.13.0-rc3+ #16
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> task: ffff8801d2fa40c0 task.stack: ffff8801d1fe8000
> RIP: 0010:report_usercopy mm/usercopy.c:64 [inline]
> RIP: 0010:__check_object_size+0x3ad/0x500 mm/usercopy.c:264
> RSP: 0018:ffff8801d1fef8a8 EFLAGS: 00010286
> RAX: 0000000000000078 RBX: ffffffff847102c0 RCX: 0000000000000000
> RDX: 0000000000000078 RSI: 1ffff1003a3fded5 RDI: ffffed003a3fdf09
> RBP: ffff8801d1fef998 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801d1ea480e
> R13: fffffffffffffffa R14: ffffffff84710280 R15: dffffc0000000000
> FS:  0000000001360880(0000) GS:ffff8801dc000000(0000)
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000202ecfe4 CR3: 00000001d1ff8000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  check_object_size include/linux/thread_info.h:108 [inline]
>  check_copy_size include/linux/thread_info.h:139 [inline]
>  copy_to_iter include/linux/uio.h:105 [inline]
>  copy_linear_skb include/net/udp.h:371 [inline]
>  udpv6_recvmsg+0x1040/0x1af0 net/ipv6/udp.c:395
>  inet_recvmsg+0x14c/0x5f0 net/ipv4/af_inet.c:793
>  sock_recvmsg_nosec net/socket.c:792 [inline]
>  sock_recvmsg+0xc9/0x110 net/socket.c:799
>  SYSC_recvfrom+0x2d6/0x570 net/socket.c:1788
>  SyS_recvfrom+0x40/0x50 net/socket.c:1760
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
> 
> 
> Fixes: b65ac44674dd ("udp: try to avoid 2 cache miss on dequeue")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
