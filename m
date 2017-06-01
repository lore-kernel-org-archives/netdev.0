From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv6: use-after-free in ip6_dst_ifdown
Date: Thu, 1 Jun 2017 14:00:40 +0200
Message-ID: <CAAeHK+xKEgMk1sZrVr-NZ_RK4+6ezDnVHebaaWBmyomBgCMgGw@mail.gmail.com>
References: <CAAeHK+wBQgfW_mRjmP-rScMtvUfs61iCzCHn1SmkdnLGNyRm0A@mail.gmail.com>
 <CAM_iQpUxmME-9Gi9=dtAgeGeK4v3R0NV-REFRtMAU26yBXwrPQ@mail.gmail.com>
 <CANn89iJ0Qd6FHXBva1sztCL0cVNk70J+3sQ9S0VAbVyTTD41fg@mail.gmail.com>
 <CAM_iQpV3NyvTLbg3S0_Eq6WYpz0MbPfcGt=A7Vu6=ttAuY1V3Q@mail.gmail.com> <a239969f-c794-49cb-8afe-c396b9c19392@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a239969f-c794-49cb-8afe-c396b9c19392@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 1, 2017 at 3:17 AM, David Ahern <dsahern@gmail.com> wrote:
> On 5/31/17 4:49 PM, Cong Wang wrote:
>>>>> ==================================================================
>>>>> BUG: KASAN: use-after-free in ip6_dst_ifdown+0x3cc/0x400 net/ipv6/route.c:422
>>>>> Read of size 8 at addr ffff88006afa4ad8 by task syz-executor6/23554
>>>>
>>>>
>>>> This one is very interesting.
>>>>
>>>> Here we are at:
>>>>
>>>>         if (dev != loopback_dev) {
>>>>                 if (idev && idev->dev == dev) {
>>>>                         struct inet6_dev *loopback_idev =
>>>>                                 in6_dev_get(loopback_dev);
>>>>                         if (loopback_idev) {
>>>>                                 rt->rt6i_idev = loopback_idev;
>>>>                                 in6_dev_put(idev);
>>>>                         }
>>>>                 }
>>>>         }
>>>>
>>>> clearly no skb involved, it looks like idev is the one used-after-free.
>>>>
>>>> But below it is actually skb which is allocated and freed...
>>>>
>>>
>>> skb->head was a kmalloc(X)   with X = 1024 in this case.
>>>
>>> So it is very possible the two different objects (skb->head and idev )
>>>  were accidentally using the same slab (1024 bytes).
>>>
>>> KASAN only remember the last pair of alloc/free for a particular memory zone.
>>
>> I see. So that memory area was freed for idev and then allocated
>> and freed again for skb->head, this happened so quick that the
>> use-after-free happened after it... Therefore we lost the track on where
>> we free the idev.
>>
>
> Andrey: can you add this to your runs? If it triggers again, we can see
> if this use-after-free is another problem where the dst hit the gc list
> and came back into the IPv6 FIB. The location of the idev entry in
> rt6_info is after the size of rtable so if this is an IPv4 dst on the
> IPv6 list it could trigger that warning.

Done, now testing with your patch.

BTW, I've also been getting the report below, which looks related.
However it's a null-ptr-deref, so much less useful info is present.
This one is being triggered much more often, I'll see if I'm able to
extract a reproducer.

kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 26651 Comm: syz-executor1 Not tainted 4.12.0-rc3+ #373
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88003bcdc480 task.stack: ffff880028ff0000
RIP: 0010:rt6_uncached_list_flush_dev net/ipv6/route.c:167 [inline]
RIP: 0010:rt6_ifdown+0x3cf/0x910 net/ipv6/route.c:2824
RSP: 0018:ffff880028ff6e38 EFLAGS: 00010246
RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffffc900033c6000
RDX: 0000000000010000 RSI: ffffffff83e4d153 RDI: ffff88003ec25444
RBP: ffff880028ff6f98 R08: 0000000000000001 R09: 43743c8b00000000
R10: ffff88003bcdcc90 R11: dffffc0000000000 R12: ffff88003dc1aa98
R13: ffff88003dc1aa80 R14: ffff88003a7d0000 R15: dffffc0000000000
FS:  00007fb818f8a700(0000) GS:ffff88003ec00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000705dcc CR3: 0000000068757000 CR4: 00000000000006f0
Call Trace:
 addrconf_ifdown+0x1a3/0x1a30 net/ipv6/addrconf.c:3588
 addrconf_notify+0x1ca/0x2630 net/ipv6/addrconf.c:3512
 notifier_call_chain+0x145/0x2e0 kernel/notifier.c:93
 __raw_notifier_call_chain kernel/notifier.c:394 [inline]
 raw_notifier_call_chain+0x2d/0x40 kernel/notifier.c:401
 call_netdevice_notifiers_info+0x51/0x90 net/core/dev.c:1649
 call_netdevice_notifiers net/core/dev.c:1665 [inline]
 __dev_notify_flags+0x1fd/0x320 net/core/dev.c:6640
 dev_change_flags+0xf5/0x140 net/core/dev.c:6671
 dev_ifsioc+0x62a/0x9f0 net/core/dev_ioctl.c:254
 dev_ioctl+0x249/0x1160 net/core/dev_ioctl.c:532
 sock_do_ioctl+0x94/0xb0 net/socket.c:913
 sock_ioctl+0x28f/0x440 net/socket.c:1004
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1bf/0x1660 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x446179
RSP: 002b:00007fb818f89c08 EFLAGS: 00000282 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 0000000000003220 RCX: 0000000000446179
RDX: 00000000206fe000 RSI: 0000000000008914 RDI: 0000000000000005
RBP: 00000000ffffffff R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000282 R12: 0000000000000005
R13: 0000000000000000 R14: 00007fb818f8a9c0 R15: 00007fb818f8a700
Code: 49 8b 9d 58 01 00 00 4c 89 e0 48 c1 e8 03 42 80 3c 38 00 0f 85
6d 04 00 00 49 8b 45 18 48 89 85 f0 fe ff ff 48 89 d8 48 c1 e8 03 <42>
80 3c 38 00 0f 85 5d 04 00 00 4c 3b 33 0f 84 d7 01 00 00 e8
RIP: rt6_uncached_list_flush_dev net/ipv6/route.c:167 [inline] RSP:
ffff880028ff6e38
RIP: rt6_ifdown+0x3cf/0x910 net/ipv6/route.c:2824 RSP: ffff880028ff6e38
---[ end trace 9e62f05a0ea34b53 ]---


>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 9d9b5bbea153..237f42144b3e 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -418,6 +418,7 @@ static void ip6_dst_ifdown(struct dst_entry *dst,
> struct net_device *dev,
>         struct net_device *loopback_dev =
>                 dev_net(dev)->loopback_dev;
>
> +WARN_ON(dst->ops->family != AF_INET6);
>         if (dev != loopback_dev) {
>                 if (idev && idev->dev == dev) {
>                         struct inet6_dev *loopback_idev =
