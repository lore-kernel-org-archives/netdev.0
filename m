From: Eric Dumazet <edumazet@google.com>
Subject: Re: net: use-after-free in neigh_timer_handler/sock_wfree
Date: Wed, 1 Mar 2017 21:36:08 -0800
Message-ID: <CANn89iKTMLbhXHA1uoD8J37NLyA-e5W-At+TZ1qkNe6FBMTw5g@mail.gmail.com>
References: <CACT4Y+Y6T3hLkgEKR5o3spjjSdTj0HXys2qeVZ9CA7MKsZc15Q@mail.gmail.com>
 <CAM_iQpWGAwXu7yO_XsX2Rk-whLvZPLSXd5Btok=L9VSCV5gr=Q@mail.gmail.com>
 <CAM_iQpUdpjXS-yq8McZne+hobWv+pQS-Q0Fk4w0i0mXJQQ8fhQ@mail.gmail.com>
 <CANn89iJyDtZxj0Qksi7P7-FpEW4MDP6HpJTcb9o_yRXJQtym_g@mail.gmail.com>
 <CAM_iQpVb62N=0veNSvCfgE7RfGcR=EKOgCtyF3c9t5b+Rk_avg@mail.gmail.com>
 <CANn89iKERkynDdVA1Wzn4MLfXY9E+c5QRU_qXJT_=Ya4_2og+A@mail.gmail.com> <CAM_iQpU7AAVPvvw1921=UJ9E8ktvEo3ONaUkDEeD_yVN5+jwSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpU7AAVPvvw1921=UJ9E8ktvEo3ONaUkDEeD_yVN5+jwSA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 1, 2017 at 9:25 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Mar 1, 2017 at 3:15 PM, Eric Dumazet <edumazet@google.com> wrote:
>> On Wed, Mar 1, 2017 at 3:09 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>>>
>>> But I doubt skb_orphan() is the solution here, shouldn't we just
>>> update sk->sk_wmem_alloc with skb->truesize changes?
>>
>> Is it worth it ? Apart from syszkaller I mean...
>>
>> We started with something that had a real impact on real workloads.
>>
>> 158f323b9868b59967ad96957c4ca388161be321 net: adjust skb->truesize in
>> pskb_expand_head()
>>
>> Note that auditing the stack took me a while.
>
> I don't know how sk refcnt could work correctly without making
> sk_wmem_alloc correctly. We certainly could just call skb_orphan()
> is we don't need skb->sk any more, probably like the frag case,
> but for this case, the neigh one, the skb's sitting in neigh->arp_queue
> are not going to be freed unless in failed case, therefore skb->sk
> should not be orphaned so early.


There is absolutely no issue in arp/nd case.
Many skbs can sit there and it is fine.
Same with skbs sitting a long time in a qdisc.

Of course we try to not call skb_orphan() unless really needed.

tcp_gso_segment() tries very hard to propagate skb ownership to the segments,
but even something apparently easy like that took some patches before
being done right.

(for details : 0d08c42cf9a71530fef5ebcfe368f38f2dd0476f "tcp: gso: fix
truesize tracking")

conntrack reasm is mostly used in forwarding workloads, where skb->sk
is already NULL.

Are you thinking of a real workload where skb->sk _needs_ to be kept
in ipv6 reasm ?
