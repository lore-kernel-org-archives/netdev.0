From: Florian Westphal <fw@strlen.de>
Subject: Re: general protection fault in fib_dump_info
Date: Tue, 15 Aug 2017 14:05:28 +0200
Message-ID: <20170815120528.GD16998@breakpoint.cc>
References: <CADUsjNkM2KuAJj6xc=Xj3he8z3B5XYv5m8H5x-FCHwdGjW_AYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, syzkaller@googlegroups.com,
        roopa@cumulusnetworks.com
To: idaifish <idaifish@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:40324 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751196AbdHOMIC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 08:08:02 -0400
Content-Disposition: inline
In-Reply-To: <CADUsjNkM2KuAJj6xc=Xj3he8z3B5XYv5m8H5x-FCHwdGjW_AYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

idaifish <idaifish@gmail.com> wrote:
> Syzkaller hit 'general protection fault in fib_dump_info' bug on
> commit 4.13-rc5..

CC Roopa

> Guilty file: net/ipv4/fib_semantics.c
> 
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 0 PID: 2808 Comm: syz-executor0 Not tainted 4.13.0-rc5 #1
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> Ubuntu-1.8.2-1ubuntu1 04/01/2014
> task: ffff880078562700 task.stack: ffff880078110000
> RIP: 0010:fib_dump_info+0x388/0x1170 net/ipv4/fib_semantics.c:1314
> RSP: 0018:ffff880078117010 EFLAGS: 00010206
> RAX: dffffc0000000000 RBX: 00000000000000fe RCX: 0000000000000002
> RDX: 0000000000000006 RSI: ffff880078117084 RDI: 0000000000000030
> RBP: ffff880078117268 R08: 000000000000000c R09: ffff8800780d80c8
> R10: 0000000058d629b4 R11: 0000000067fce681 R12: 0000000000000000
> R13: ffff8800784bd540 R14: ffff8800780d80b5 R15: ffff8800780d80a4
> FS:  00000000022fa940(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000004387d0 CR3: 0000000079135000 CR4: 00000000000006f0
> Call Trace:
>  inet_rtm_getroute+0xc89/0x1f50 net/ipv4/route.c:2766
>  rtnetlink_rcv_msg+0x288/0x680 net/core/rtnetlink.c:4217

Seems like this is from
b61798130f1be5bff08712308126c2d7ebe390ef

Roopa, it seems to assume res.fi != NULL, but afaics there
is no guarantee, f.e. in ip_route_input_rcu() in the multicast
branch res isn't changed at all.

If thats true, we might need this fix?

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7effa62beed3..fc0708f7792d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2763,7 +2763,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
        if (rtm->rtm_flags & RTM_F_LOOKUP_TABLE)
                table_id = rt->rt_table_id;
 
-       if (rtm->rtm_flags & RTM_F_FIB_MATCH)
+       if ((rtm->rtm_flags & RTM_F_FIB_MATCH) && res.fi)
                err = fib_dump_info(skb, NETLINK_CB(in_skb).portid,
                                    nlh->nlmsg_seq, RTM_NEWROUTE, table_id,
                                    rt->rt_type, res.prefix, res.prefixlen,
                                    fl4.flowi4_tos, res.fi, 0);
