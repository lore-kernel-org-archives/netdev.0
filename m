From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/4] ip/options: explicitly provide net ns to
 __ip_options_echo()
Date: Tue, 05 Sep 2017 10:18:47 -0700
Message-ID: <1504631927.15310.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1501775813.git.pabeni@redhat.com>
         <31096a330a56cfd40eea136be505270184fbb5d4.1501775813.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35134 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751959AbdIERSu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 13:18:50 -0400
Received: by mail-pf0-f193.google.com with SMTP id g13so1612718pfm.2
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 10:18:50 -0700 (PDT)
In-Reply-To: <31096a330a56cfd40eea136be505270184fbb5d4.1501775813.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-03 at 18:07 +0200, Paolo Abeni wrote:
> __ip_options_echo() uses the current network namespace, and
> currently retrives it via skb->dst->dev.
> 
> This commit adds an explicit 'net' argument to __ip_options_echo()
> and update all the call sites to provide it, usually via a simpler
> sock_net().
> 
> After this change, __ip_options_echo() no more needs to access
> skb->dst and we can drop a couple of hack to preserve such
> info in the rx path.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

David, Paolo

This commit (91ed1e666a4ea2e260452a7d7d311ac5ae852cba "ip/options:
explicitly provide net ns to __ip_options_echo()")

needs to be backported to linux-4.13 stable version to avoid these kind
of crashes [1]

This is because of MSG_PEEK operation, hitting skb_consume_udp() while
skb is still in receive queue.

Next read() finding again the skb then can see a NULL skb->dst

Thanks !

[1]
general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 3017 Comm: syzkaller446772 Not tainted 4.13.0+ #68
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
Google 01/01/2011
task: ffff8801cd0a4380 task.stack: ffff8801cc498000
RIP: 0010:__ip_options_echo+0xea8/0x1430 net/ipv4/ip_options.c:143
RSP: 0018:ffff8801cc49f628 EFLAGS: 00010246
RAX: dffffc0000000000 RBX: ffff8801cc49f928 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000004
RBP: ffff8801cc49f6b8 R08: ffff8801cc49f936 R09: ffffed0039893f28
R10: 0000000000000003 R11: ffffed0039893f27 R12: ffff8801cc49f918
R13: ffff8801ccbcf36c R14: 000000000000000f R15: 0000000000000018
FS:  0000000000979880(0000) GS:ffff8801db200000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000200c0ff0 CR3: 00000001cc4ed000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 ip_options_echo include/net/ip.h:574 [inline]
 ip_cmsg_recv_retopts net/ipv4/ip_sockglue.c:91 [inline]
 ip_cmsg_recv_offset+0xa17/0x1280 net/ipv4/ip_sockglue.c:207
 udp_recvmsg+0xe0b/0x1260 net/ipv4/udp.c:1641
 inet_recvmsg+0x14c/0x5f0 net/ipv4/af_inet.c:793
 sock_recvmsg_nosec net/socket.c:792 [inline]
 sock_recvmsg+0xc9/0x110 net/socket.c:799
 SYSC_recvfrom+0x2dc/0x570 net/socket.c:1788
 SyS_recvfrom+0x40/0x50 net/socket.c:1760
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x444c89
RSP: 002b:00007ffd80c788e8 EFLAGS: 00000286 ORIG_RAX: 000000000000002d
RAX: ffffffffffffffda RBX: ffffffffffffffff RCX: 0000000000444c89
RDX: 0000000000000000 RSI: 0000000020bc0000 RDI: 0000000000000004
RBP: 0000000000000082 R08: 00000000200c0ff0 R09: 0000000000000010
R10: 0000000000000000 R11: 0000000000000286 R12: 0000000000402390
R13: 0000000000402420 R14: 0000000000000000 R15: 0000000000000000
Code: f6 c1 01 0f 85 a5 01 00 00 48 89 4d b8 e8 31 e9 6b fd 48 8b 4d b8
48 b8 00 00 00 00 00 fc ff df 48 83 e1 fe 48 89 ca 48 c1 ea 03 <80> 3c
02 00 0f 85 41 02 00 00 48 8b 09 48 b8 00 00 00 00 00 fc 
RIP: __ip_options_echo+0xea8/0x1430 net/ipv4/ip_options.c:143 RSP:
ffff8801cc49f628
---[ end trace b30d95b284222843 ]---
Kernel panic - not syncing: Fatal exception
