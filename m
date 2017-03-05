From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Sun, 5 Mar 2017 11:53:54 +0100
Message-ID: <CACT4Y+Z49kard6__12XyaD8DjnG5hjO0ZD2KcM24dQ7YmVC+8w@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com> <1488658514.9415.356.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488658514.9415.356.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 4, 2017 at 9:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On 3/3/17 6:39 AM, Dmitry Vyukov wrote:
>> >> I am getting heap out-of-bounds reports in
>> >> fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone while running
>> >> syzkaller fuzzer on 86292b33d4b79ee03e2f43ea0381ef85f077c760. They all
>> >> follow the same pattern: an object of size 216 is allocated from
>> >> ip_dst_cache slab, and then accessed at offset 272/276 withing
>> >> fib6_walk. Looks like type confusion. Unfortunately this is not
>> >> reproducible.
>> >
>> > I'll take a look this weekend or Monday at the latest.
>>
>>
>> I've got some additional useful info on this. I think this is
>> use-after-free rather than out-of-bounds. I've collected stack where
>> the route was disposed with call_rcu, see the last "Disposed" stack.
>> The crash happens when cmpxchg in rt_cache_route replaces an existing
>> route. And that route seems to have some existing pointers to it
>> (rt->dst.rt6_next) which fib6_walk uses to get to it after its
>> deletion.
>
> rt_cache_route() deals with IPv4 routes.
>
> We somehow mix IPv4 and IPv6 dsts in IPv6 tree.
>
> We need to add type safety at IPV6 route insertions to catch the
> offender.


If you suggest additional checks, I will collect stacks.
