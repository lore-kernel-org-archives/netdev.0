From: David Ahern <dsahern@gmail.com>
Subject: Re: net/ipv6: use-after-free in ip6_dst_ifdown
Date: Wed, 31 May 2017 19:17:08 -0600
Message-ID: <a239969f-c794-49cb-8afe-c396b9c19392@gmail.com>
References: <CAAeHK+wBQgfW_mRjmP-rScMtvUfs61iCzCHn1SmkdnLGNyRm0A@mail.gmail.com>
 <CAM_iQpUxmME-9Gi9=dtAgeGeK4v3R0NV-REFRtMAU26yBXwrPQ@mail.gmail.com>
 <CANn89iJ0Qd6FHXBva1sztCL0cVNk70J+3sQ9S0VAbVyTTD41fg@mail.gmail.com>
 <CAM_iQpV3NyvTLbg3S0_Eq6WYpz0MbPfcGt=A7Vu6=ttAuY1V3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
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
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpV3NyvTLbg3S0_Eq6WYpz0MbPfcGt=A7Vu6=ttAuY1V3Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/31/17 4:49 PM, Cong Wang wrote:
>>>> ==================================================================
>>>> BUG: KASAN: use-after-free in ip6_dst_ifdown+0x3cc/0x400 net/ipv6/route.c:422
>>>> Read of size 8 at addr ffff88006afa4ad8 by task syz-executor6/23554
>>>
>>>
>>> This one is very interesting.
>>>
>>> Here we are at:
>>>
>>>         if (dev != loopback_dev) {
>>>                 if (idev && idev->dev == dev) {
>>>                         struct inet6_dev *loopback_idev =
>>>                                 in6_dev_get(loopback_dev);
>>>                         if (loopback_idev) {
>>>                                 rt->rt6i_idev = loopback_idev;
>>>                                 in6_dev_put(idev);
>>>                         }
>>>                 }
>>>         }
>>>
>>> clearly no skb involved, it looks like idev is the one used-after-free.
>>>
>>> But below it is actually skb which is allocated and freed...
>>>
>>
>> skb->head was a kmalloc(X)   with X = 1024 in this case.
>>
>> So it is very possible the two different objects (skb->head and idev )
>>  were accidentally using the same slab (1024 bytes).
>>
>> KASAN only remember the last pair of alloc/free for a particular memory zone.
> 
> I see. So that memory area was freed for idev and then allocated
> and freed again for skb->head, this happened so quick that the
> use-after-free happened after it... Therefore we lost the track on where
> we free the idev.
> 

Andrey: can you add this to your runs? If it triggers again, we can see
if this use-after-free is another problem where the dst hit the gc list
and came back into the IPv6 FIB. The location of the idev entry in
rt6_info is after the size of rtable so if this is an IPv4 dst on the
IPv6 list it could trigger that warning.

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9d9b5bbea153..237f42144b3e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -418,6 +418,7 @@ static void ip6_dst_ifdown(struct dst_entry *dst,
struct net_device *dev,
        struct net_device *loopback_dev =
                dev_net(dev)->loopback_dev;

+WARN_ON(dst->ops->family != AF_INET6);
        if (dev != loopback_dev) {
                if (idev && idev->dev == dev) {
                        struct inet6_dev *loopback_idev =
