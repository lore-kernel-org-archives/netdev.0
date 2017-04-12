From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: net/ipv4: use-after-free in ipv4_datagram_support_cmsg
Date: Wed, 12 Apr 2017 19:26:22 -0400
Message-ID: <CAF=yD-KL5i_567+fUjny=0VWwDRFb0mh0UE-9ahZFRB__i=brA@mail.gmail.com>
References: <CAAeHK+ysUb+yuES_XYYPDWGrXS4VUXLmQRrD2dJTeXDPL5BKpw@mail.gmail.com>
 <CAF=yD-++XtWeaVmdhnrwiYLOG84JTMEuZr9mxyTRnde8vE7AFQ@mail.gmail.com>
 <CAM_iQpVVc1ev8juG8=dQ0wu8c_RoJ8HfDUewRc1AempvV=85kw@mail.gmail.com>
 <1492030046.10587.72.camel@edumazet-glaptop3.roam.corp.google.com> <CAF=yD-KN8Z3MyxsWsC-8sAk7kzSU7w7GQGbkUBUh-FuXm0fYWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF=yD-KN8Z3MyxsWsC-8sAk7kzSU7w7GQGbkUBUh-FuXm0fYWg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 6:25 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Wed, Apr 12, 2017 at 4:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Wed, 2017-04-12 at 13:07 -0700, Cong Wang wrote:
>>> On Wed, Apr 12, 2017 at 8:39 AM, Willem de Bruijn
>>> <willemdebruijn.kernel@gmail.com> wrote:
>>> > ===================
>>> >> BUG: KASAN: use-after-free in ipv4_datagram_support_cmsg
>>> >> net/ipv4/ip_sockglue.c:500 [inline] at addr ffff880059be0128
>>> >
>>> > Thanks for the report. This is accessing skb->dev from within recvmsg() at line
>>> >
>>> >         info->ipi_ifindex = skb->dev->ifindex;
>>> >
>>> > Introduced in 829ae9d61165 ("net-timestamp: allow reading recv cmsg on
>>> > errqueue with origin tstamp"). At this time the device may indeed have
>>> > gone away. I'm having a look at a way to read this in the receive BH
>>> > and store the ifindex.
>>>
>>> Why not use skb_iif?
>
> This code is called from the error path for transmit timestamps.
>
> We can make use of the fact that SKB_EXT_ERR used on enqueue has iif as
> the first field in its control block. This also holds for the PKTINFO_SKB_CB
> struct to which skb->cb is cast on dequeue when it copies pktinfo to userspace.
> So if set on enqueue in __skb_complete_tx_timestamp, no conversion operation
> is even needed on dequeue, let alone the currently buggy line that touches
> skb->dev.
>
> This iif cast was added for this purpose in the receive path in 0b922b7a829c
> ("net: original ingress device index in PKTINFO").
>
> The device pointer is valid on enqueue for all paths called from device drivers,
> as well as from dev_queue_xmit for SCM_TSTAMP_SCHED generation in
> __dev_queue_xmit. The exception is SCM_TSTAMP_ACK generation, but
> there skb->dev is NULL.
>
> The v6 path does need a conversion, but already does this in
> ip6_datagram_recv_common_ctl. There, too, we can remove the buggy
> logic to set it from skb->dev->ifindex in ip6_datagram_support_cmsg.
>
> I will send a patch.

Sent http://patchwork.ozlabs.org/patch/750197
