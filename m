From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: cleanup_net is slow
Date: Fri, 21 Apr 2017 21:45:23 +0200
Message-ID: <CACT4Y+biEu_ZcAaAbKNYEGoEtqPS2_tsKDCfHYvB4f+iKMUoxg@mail.gmail.com>
References: <CAAeHK+yJXMo8kr_p8iM_dicVGQCtwQhdk=rdE+9dNbsoghAb6Q@mail.gmail.com>
 <CANn89i+iYtPLGDZpt3qk_cA-dq+004B=1qjP0ZygY3oREskQYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Konovalov <andreyknvl@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89i+iYtPLGDZpt3qk_cA-dq+004B=1qjP0ZygY3oREskQYA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 21, 2017 at 7:57 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Fri, Apr 21, 2017 at 10:50 AM, Andrey Konovalov
> <andreyknvl@google.com> wrote:
>> Hi!
>>
>> We're investigating some approaches to improve isolation of syzkaller
>> programs. One of the ideas is run each program in it's own user/net
>> namespace. However, while I was experimenting with this, I stumbled
>> upon a problem.
>>
>> It seems that cleanup_net() might take a very long time to execute.
>>
>> I've attached the reproducer and kernel .config that I used. Run as
>> "./a.out 1". The reproducer just forks and does unshare(CLONE_NEWNET)
>> in a loop. Note, that I have a lot of network-related configs enabled,
>> which causes a few interfaces to be set up by default.
>>
>> What I see with this reproducer is that at first a huge number
>> (~200-300) net namespaces are created without any contention. But then
>> (probably when one of these namespaces gets destroyed) the program
>> hangs for a considerable amount of time (~100 seconds in my vm).
>> Nothing locks up inside the kernel and the CPU is mostly idle.
>>
>> Adding debug printfs showed that the part that takes almost all of
>> that time is the lines between synchronize_rcu() and
>> mutex_unlock(&net_mutex) in cleanup_net. Running perf showed that the
>> cause of this might be a lot of calls to synchronize_net that happen
>> while executing those lines.
>>
>> Is there any change that can be done to speed up the
>> creation/destruction of a huge number of net namespaces?
>>
>
> We have batches, but fundamentally this is a hard problem to solve.
>
> Every time we try, we add bugs :/
>
> RTNL is the new BKL (Big Kernel Lock of early linux) of today.
>
> Even the synchronize_rcu_expedited() done from synchronize_net() is a
> serious issue on some platforms.

Not sure how hard it is (I suppose hard) but if whole cleanup_net is
structured as series of call_rcu callbacks, it should give perfect
batching across all possible dimensions (e.g. across different
ops_exit_list calls and even across cleanup of different namespaces).
