From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: GPF in rt6_device_match
Date: Wed, 3 May 2017 10:02:07 -0700
Message-ID: <CAM_iQpUtVZiKTxnUBYEPLQzJSK+G_=Be-uzwuqph6g2VPsZijw@mail.gmail.com>
References: <CAAeHK+yfX9ZtpFMTFXKAtjYE17MDBXMQJS_mH0b3=xTuv3jk9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsahern@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+yfX9ZtpFMTFXKAtjYE17MDBXMQJS_mH0b3=xTuv3jk9g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 3, 2017 at 9:33 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi David,
>
> Got another report related to fib6.
>
> I'm on 89c9fea3c8034cdb2fd745f551cde0b507fd6893 with your last patch applied.
>
> A reproducer and .config are attached.
>
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 1 PID: 4059 Comm: a.out Not tainted 4.11.0+ #312
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff880064d11600 task.stack: ffff88006b0e8000
> RIP: 0010:rt6_device_match net/ipv6/route.c:515
> RIP: 0010:ip6_pol_route_lookup+0x2f2/0xa90 net/ipv6/route.c:885
> RSP: 0018:ffff88006b0ef0b8 EFLAGS: 00010246
> RAX: 1ffff1000d00f20b RBX: ffff880066dd96c0 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: ffff88006b0ef5b8 RDI: ffff880068079058
> RBP: ffff88006b0ef1e0 R08: 0000000000000002 R09: 4e43247300000000
> R10: ffff88006b0ef0b8 R11: dffffc0000000000 R12: 0000000000090000
> R13: ffff880068078f00 R14: 0000000000000000 R15: dffffc0000000000
> FS:  00007fd68b4d5700(0000) GS:ffff88006cb00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000208e2fe0 CR3: 0000000064c9b000 CR4: 00000000000006e0
> Call Trace:
>  fib6_rule_action+0x261/0x8a0 net/ipv6/fib6_rules.c:100
>  fib_rules_lookup+0x3cf/0xca0 net/core/fib_rules.c:279
>  fib6_rule_lookup+0x175/0x360 net/ipv6/fib6_rules.c:44
>  rt6_lookup+0x267/0x3b0 net/ipv6/route.c:924
>  ip6gre_tnl_link_config+0x774/0xc00 net/ipv6/ip6_gre.c:746
>  ip6gre_tunnel_locate+0x4ab/0x7c0 net/ipv6/ip6_gre.c:340
>  ip6gre_tunnel_ioctl+0x5cd/0x21f0 net/ipv6/ip6_gre.c:878
>  dev_ifsioc+0x53f/0x9f0 net/core/dev_ioctl.c:338

A quick glance shows we need to simply check local->rt6i_idev
since we do the same check for sprt right above.

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a1bf426..61ec3c8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -511,7 +511,7 @@ static inline struct rt6_info
*rt6_device_match(struct net *net,
                                    sprt->rt6i_idev->dev->ifindex != oif) {
                                        if (flags & RT6_LOOKUP_F_IFACE)
                                                continue;
-                                       if (local &&
+                                       if (local && local->rt6i_idev &&

local->rt6i_idev->dev->ifindex == oif)
                                                continue;
                                }
