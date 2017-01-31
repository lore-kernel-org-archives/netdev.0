From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: suspicious RCU usage in nf_hook
Date: Mon, 30 Jan 2017 22:19:52 -0800
Message-ID: <CAM_iQpXiQMH1zMJM6sYFNUySUYjaHnLZ3T2d34GwCMQ9u6RkwQ@mail.gmail.com>
References: <CACT4Y+bpmwj1WH7g6inQBm+7PvHepv9tTmYBUqkJYFvquGDYCQ@mail.gmail.com>
 <1485560124.6360.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVvBPhP4q=Egsaoqf8ym-73jLZow8xDMbOq9RhYmL5XAQ@mail.gmail.com> <1485567090.6360.92.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485567090.6360.92.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2017 at 5:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-01-27 at 17:00 -0800, Cong Wang wrote:
>> On Fri, Jan 27, 2017 at 3:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > Oh well, I forgot to submit the official patch I think, Jan 9th.
>> >
>> > https://groups.google.com/forum/#!topic/syzkaller/BhyN5OFd7sQ
>> >
>>
>> Hmm, but why only fragments need skb_orphan()? It seems like
>> any kfree_skb() inside a nf hook needs to have a preceding
>> skb_orphan().
>
>
>>
>> Also, I am not convinced it is similar to commit 8282f27449bf15548
>> which is on RX path.
>
> Well, we clearly see IPv6 reassembly being part of the equation in both
> cases.

Yeah, of course. My worry is that this problem is more than just
IPv6 reassembly.

>
> I was replying to first part of the splat [1], which was already
> diagnosed and had a non official patch.
>
> use after free is also a bug, regardless of jump label being used or
> not.
>
> I still do not really understand this nf_hook issue, I thought we were
> disabling BH in netfilter.

It is a different warning from use-after-free, this one is about sleep
in atomic context, mutex lock is acquired with RCU read lock held.


>
> So the in_interrupt() check in net_disable_timestamp() should trigger,
> this was the intent of netstamp_needed_deferred existence.
>
> Not sure if we can test for rcu_read_lock() as well.
>

The context is process context (TX path before hitting qdisc), and
BH is not disabled, so in_interrupt() doesn't catch it. Hmm, this
makes me thinking maybe we really need to disable BH in this
case for nf_hook()? But it is called in RX path too, and BH is
already disabled there.
