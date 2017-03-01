From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: use-after-free in neigh_timer_handler/sock_wfree
Date: Wed, 1 Mar 2017 15:09:12 -0800
Message-ID: <CAM_iQpVb62N=0veNSvCfgE7RfGcR=EKOgCtyF3c9t5b+Rk_avg@mail.gmail.com>
References: <CACT4Y+Y6T3hLkgEKR5o3spjjSdTj0HXys2qeVZ9CA7MKsZc15Q@mail.gmail.com>
 <CAM_iQpWGAwXu7yO_XsX2Rk-whLvZPLSXd5Btok=L9VSCV5gr=Q@mail.gmail.com>
 <CAM_iQpUdpjXS-yq8McZne+hobWv+pQS-Q0Fk4w0i0mXJQQ8fhQ@mail.gmail.com> <CANn89iJyDtZxj0Qksi7P7-FpEW4MDP6HpJTcb9o_yRXJQtym_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iJyDtZxj0Qksi7P7-FpEW4MDP6HpJTcb9o_yRXJQtym_g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 1, 2017 at 1:54 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Wed, Mar 1, 2017 at 1:43 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>
>>> This one looks very similar to a previous one:
>>> https://groups.google.com/forum/#!topic/syzkaller/BhyN5OFd7sQ
>>>
>>> Both happen on raw v6 sockets.
>>>
>>> For me, it seems the sk refcnt is not correct, skb should still hold
>>> a refcnt so it should not be freed before kfree_skb() in a timer
>>> handler...
>>
>> More precisely, after this commit:
>>
>> commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
>> Author: Eric Dumazet <eric.dumazet@gmail.com>
>> Date:   Thu Jun 11 02:55:43 2009 -0700
>>
>>     net: No more expensive sock_hold()/sock_put() on each tx
>>
>> we don't take (old) refcnt any more on TX path, sk_wmem_alloc
>> is the new refcnt. ;)
>
> So the bug is that skb->truesize is mangled by reassembly unit,
> while sbk->sk is tracking sk_wmem_alloc changes in order
> to decide when it is safe to free sk.

That is my suspicion as well, skb->truesize is updated somewhere
but sk->sk_wmem_alloc isn't, so leads to this bug.

>
> This is why we need to call skb_orphan(), as we did for IPv4 in
> 8282f27449bf15548


But I doubt skb_orphan() is the solution here, shouldn't we just
update sk->sk_wmem_alloc with skb->truesize changes?
