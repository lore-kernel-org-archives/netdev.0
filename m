From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: use-after-free in ip6_dst_ifdown
Date: Wed, 31 May 2017 15:49:29 -0700
Message-ID: <CAM_iQpV3NyvTLbg3S0_Eq6WYpz0MbPfcGt=A7Vu6=ttAuY1V3Q@mail.gmail.com>
References: <CAAeHK+wBQgfW_mRjmP-rScMtvUfs61iCzCHn1SmkdnLGNyRm0A@mail.gmail.com>
 <CAM_iQpUxmME-9Gi9=dtAgeGeK4v3R0NV-REFRtMAU26yBXwrPQ@mail.gmail.com> <CANn89iJ0Qd6FHXBva1sztCL0cVNk70J+3sQ9S0VAbVyTTD41fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrey Konovalov <andreyknvl@google.com>,
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
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iJ0Qd6FHXBva1sztCL0cVNk70J+3sQ9S0VAbVyTTD41fg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 31, 2017 at 9:55 AM, Eric Dumazet <edumazet@google.com> wrote:
> On Wed, May 31, 2017 at 9:45 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Wed, May 31, 2017 at 2:42 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>> Hi,
>>>
>>> I've got the following error report while fuzzing the kernel with syzkaller.
>>>
>>> On commit 5ed02dbb497422bf225783f46e6eadd237d23d6b (4.12-rc3).
>>>
>>> Unfortunately it's not reproducible.
>>>
>>> ==================================================================
>>> BUG: KASAN: use-after-free in ip6_dst_ifdown+0x3cc/0x400 net/ipv6/route.c:422
>>> Read of size 8 at addr ffff88006afa4ad8 by task syz-executor6/23554
>>
>>
>> This one is very interesting.
>>
>> Here we are at:
>>
>>         if (dev != loopback_dev) {
>>                 if (idev && idev->dev == dev) {
>>                         struct inet6_dev *loopback_idev =
>>                                 in6_dev_get(loopback_dev);
>>                         if (loopback_idev) {
>>                                 rt->rt6i_idev = loopback_idev;
>>                                 in6_dev_put(idev);
>>                         }
>>                 }
>>         }
>>
>> clearly no skb involved, it looks like idev is the one used-after-free.
>>
>> But below it is actually skb which is allocated and freed...
>>
>
> skb->head was a kmalloc(X)   with X = 1024 in this case.
>
> So it is very possible the two different objects (skb->head and idev )
>  were accidentally using the same slab (1024 bytes).
>
> KASAN only remember the last pair of alloc/free for a particular memory zone.

I see. So that memory area was freed for idev and then allocated
and freed again for skb->head, this happened so quick that the
use-after-free happened after it... Therefore we lost the track on where
we free the idev.
