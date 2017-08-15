From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: general protection fault in fib_dump_info
Date: Tue, 15 Aug 2017 07:55:16 -0700
Message-ID: <CAJieiUhDoaaAc0w=1-pKGcymVpfYqG9figmrKHduzdtJu_hZig@mail.gmail.com>
References: <CADUsjNkM2KuAJj6xc=Xj3he8z3B5XYv5m8H5x-FCHwdGjW_AYg@mail.gmail.com>
 <20170815120528.GD16998@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: idaifish <idaifish@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        syzkaller@googlegroups.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f175.google.com ([209.85.217.175]:34046 "EHLO
        mail-ua0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751665AbdHOOzR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:55:17 -0400
Received: by mail-ua0-f175.google.com with SMTP id q25so3781696uah.1
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 07:55:17 -0700 (PDT)
In-Reply-To: <20170815120528.GD16998@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 5:05 AM, Florian Westphal <fw@strlen.de> wrote:
> idaifish <idaifish@gmail.com> wrote:
>> Syzkaller hit 'general protection fault in fib_dump_info' bug on
>> commit 4.13-rc5..
>
> CC Roopa
>
>> Guilty file: net/ipv4/fib_semantics.c
>>
>> kasan: GPF could be caused by NULL-ptr deref or user memory access
>> general protection fault: 0000 [#1] SMP KASAN
>> Modules linked in:
>> CPU: 0 PID: 2808 Comm: syz-executor0 Not tainted 4.13.0-rc5 #1
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>> task: ffff880078562700 task.stack: ffff880078110000
>> RIP: 0010:fib_dump_info+0x388/0x1170 net/ipv4/fib_semantics.c:1314
>> RSP: 0018:ffff880078117010 EFLAGS: 00010206
>> RAX: dffffc0000000000 RBX: 00000000000000fe RCX: 0000000000000002
>> RDX: 0000000000000006 RSI: ffff880078117084 RDI: 0000000000000030
>> RBP: ffff880078117268 R08: 000000000000000c R09: ffff8800780d80c8
>> R10: 0000000058d629b4 R11: 0000000067fce681 R12: 0000000000000000
>> R13: ffff8800784bd540 R14: ffff8800780d80b5 R15: ffff8800780d80a4
>> FS:  00000000022fa940(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 00000000004387d0 CR3: 0000000079135000 CR4: 00000000000006f0
>> Call Trace:
>>  inet_rtm_getroute+0xc89/0x1f50 net/ipv4/route.c:2766
>>  rtnetlink_rcv_msg+0x288/0x680 net/core/rtnetlink.c:4217
>
> Seems like this is from
> b61798130f1be5bff08712308126c2d7ebe390ef
>
> Roopa, it seems to assume res.fi != NULL, but afaics there
> is no guarantee, f.e. in ip_route_input_rcu() in the multicast
> branch res isn't changed at all.

yes, you are right. Just checked. Thanks for catching this and digging
into it further.



>
> If thats true, we might need this fix?

I think fib match should error out for this case.
still debating about the return error code... But the below should fix it.



diff --git a/net/ipv4/route.c b/net/ipv4/route.c

index 0383e66f..f21c760 100644

--- a/net/ipv4/route.c

+++ b/net/ipv4/route.c

@@ -2762,14 +2762,19 @@ static int inet_rtm_getroute(struct sk_buff
*in_skb, struct nlmsghdr *nlh,

        if (rtm->rtm_flags & RTM_F_LOOKUP_TABLE)

                table_id = rt->rt_table_id;



-       if (rtm->rtm_flags & RTM_F_FIB_MATCH)

+       if (rtm->rtm_flags & RTM_F_FIB_MATCH) {

+               if (!res->fi) {

+                       err = -EINVAL;

+                       goto errout_free;

+               }

                err = fib_dump_info(skb, NETLINK_CB(in_skb).portid,

                                    nlh->nlmsg_seq, RTM_NEWROUTE, table_id,

                                    rt->rt_type, res.prefix, res.prefixlen,

                                    fl4.flowi4_tos, res.fi, 0);

-       else

+       } else {

                err = rt_fill_info(net, dst, src, table_id, &fl4, skb,

                                   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq);

+       }

        if (err < 0)

                goto errout_free;
