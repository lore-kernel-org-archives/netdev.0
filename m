From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: v4.14-rc2/arm64 kernel BUG at net/core/skbuff.c:2626
Date: Tue, 3 Oct 2017 18:06:54 +0200
Message-ID: <CACT4Y+azruiH-oEXVFen8WiDHhz0PS3DF7OdrkSCJYVRmkhoiQ@mail.gmail.com>
References: <20171002104947.GE20737@leverpostej> <CANn89i++X2rzsaHkTRayMpCED_exL8WPq12=RwD_hXsZ6cN-wQ@mail.gmail.com>
 <20171002142156.GB21696@leverpostej> <CANn89i+zQG=rjHRqzsvPzjg5tqW43Lcz-BJ9spLascP9Nt5z8Q@mail.gmail.com>
 <CACT4Y+Yf86hS_3u=qe0ZL208GmrfF6bp50kYcL+3D9QFBh=LZA@mail.gmail.com> <CANn89iJrJzTL+e4FDN76Fc1iptXpM9aJ6Hwa=pT=+v-zbv7+8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Mark Rutland <mark.rutland@arm.com>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-arm-kernel@lists.infradead.org,
        syzkaller <syzkaller@googlegroups.com>,
        "David S. Miller" <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iJrJzTL+e4FDN76Fc1iptXpM9aJ6Hwa=pT=+v-zbv7+8g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 3, 2017 at 5:38 PM, 'Eric Dumazet' via syzkaller
<syzkaller@googlegroups.com> wrote:
> On Tue, Oct 3, 2017 at 8:19 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Mon, Oct 2, 2017 at 4:42 PM, 'Eric Dumazet' via syzkaller
>> <syzkaller@googlegroups.com> wrote:
>>> On Mon, Oct 2, 2017 at 7:21 AM, Mark Rutland <mark.rutland@arm.com> wrote:
>>>> Hi Eric,
>>>>
>>>> On Mon, Oct 02, 2017 at 06:36:32AM -0700, Eric Dumazet wrote:
>>>>> On Mon, Oct 2, 2017 at 3:49 AM, Mark Rutland <mark.rutland@arm.com> wrote:
>>>>> > I hit the below splat at net/core/skbuff.c:2626 while fuzzing v4.14-rc2
>>>>> > on arm64 with Syzkaller. This is the BUG_ON(len) at the end of
>>>>> > skb_copy_and_csum_bits().
>>>>
>>>>> > kernel BUG at net/core/skbuff.c:2626!
>>>>
>>>>> > [<ffff200009e03214>] skb_copy_and_csum_bits+0x8dc/0xae0 net/core/skbuff.c:2626
>>>>> > [<ffff20000a01d244>] icmp_glue_bits+0xa4/0x2a0 net/ipv4/icmp.c:357
>>>>> > [<ffff200009f3f0d4>] __ip_append_data+0x10e4/0x20a8 net/ipv4/ip_output.c:1018
>>>>> > [<ffff200009f41a88>] ip_append_data.part.3+0xe8/0x1a0 net/ipv4/ip_output.c:1170
>>>>> > [<ffff200009f46e74>] ip_append_data+0xa4/0xb0 net/ipv4/ip_output.c:1173
>>>>> > [<ffff20000a01ccc8>] icmp_push_reply+0x1b8/0x690 net/ipv4/icmp.c:375
>>>>> > [<ffff20000a0211b0>] icmp_send+0x1070/0x1890 net/ipv4/icmp.c:741
>>>>> > [<ffff200009f41d48>] ip_fragment.constprop.4+0x208/0x340 net/ipv4/ip_output.c:552
>>>>> > [<ffff200009f42228>] ip_finish_output+0x3a8/0xab0 net/ipv4/ip_output.c:315
>>>>> > [<ffff200009f468c4>] NF_HOOK_COND include/linux/netfilter.h:238 [inline]
>>>>> > [<ffff200009f468c4>] ip_output+0x284/0x790 net/ipv4/ip_output.c:405
>>>>> > [<ffff200009f43204>] dst_output include/net/dst.h:458 [inline]
>>>>> > [<ffff200009f43204>] ip_local_out+0x9c/0x1b8 net/ipv4/ip_output.c:124
>>>>> > [<ffff200009f445e8>] ip_queue_xmit+0x850/0x18e0 net/ipv4/ip_output.c:504
>>>>> > [<ffff200009fb091c>] tcp_transmit_skb+0x107c/0x3338 net/ipv4/tcp_output.c:1123
>>>>> > [<ffff200009fbbcc4>] __tcp_retransmit_skb+0x614/0x1d18 net/ipv4/tcp_output.c:2847
>>>>> > [<ffff200009fbd840>] tcp_send_loss_probe+0x478/0x7d0 net/ipv4/tcp_output.c:2457
>>>>> > [<ffff200009fc707c>] tcp_write_timer_handler+0x50c/0x7e8 net/ipv4/tcp_timer.c:557
>>>>> > [<ffff200009fc73d0>] tcp_write_timer+0x78/0x170 net/ipv4/tcp_timer.c:579
>>>>> > [<ffff2000082f8980>] call_timer_fn+0x1b8/0x430 kernel/time/timer.c:1281
>>>>> > [<ffff2000082f8dcc>] expire_timers+0x1d4/0x320 kernel/time/timer.c:1320
>>>>> > [<ffff2000082f912c>] __run_timers kernel/time/timer.c:1620 [inline]
>>>>> > [<ffff2000082f912c>] run_timer_softirq+0x214/0x5f0 kernel/time/timer.c:1646
>>>>> > [<ffff2000080826c0>] __do_softirq+0x350/0xc0c kernel/softirq.c:284
>>>>> > [<ffff200008170af4>] do_softirq_own_stack include/linux/interrupt.h:498 [inline]
>>>>> > [<ffff200008170af4>] invoke_softirq kernel/softirq.c:371 [inline]
>>>>> > [<ffff200008170af4>] irq_exit+0x1dc/0x2f8 kernel/softirq.c:405
>>>>> > [<ffff2000082a95bc>] __handle_domain_irq+0xdc/0x230 kernel/irq/irqdesc.c:647
>>>>> > [<ffff2000080820ac>] handle_domain_irq include/linux/irqdesc.h:175 [inline]
>>>>> > [<ffff2000080820ac>] gic_handle_irq+0x6c/0xe0 drivers/irqchip/irq-gic.c:367
>>>>
>>>>> This is most likely a bug caused by syzkaller setting a ridiculous MTU
>>>>> on loopback device, below minimum size of ipv4 MTU.
>>>>
>>>>> I tried to track it in August [1], but it seems hard to find all the
>>>>> issues with this.
>>>>>
>>>>> commit c780a049f9bf442314335372c9abc4548bfe3e44
>>>>> Author: Eric Dumazet <edumazet@google.com>
>>>>> Date:   Wed Aug 16 11:09:12 2017 -0700
>>>>>
>>>>>     ipv4: better IP_MAX_MTU enforcement
>>>>>
>>>>>     While working on yet another syzkaller report, I found
>>>>>     that our IP_MAX_MTU enforcements were not properly done.
>>>>>
>>>>>     gcc seems to reload dev->mtu for min(dev->mtu, IP_MAX_MTU), and
>>>>>     final result can be bigger than IP_MAX_MTU :/
>>>>>
>>>>>     This is a problem because device mtu can be changed on other cpus or
>>>>>     threads.
>>>>>
>>>>>     While this patch does not fix the issue I am working on, it is
>>>>>     probably worth addressing it.
>>>>
>>>> Just to check I've understood correctly, are you suggesting that the
>>>> IPv4 code should also check the dev->mtu against a IP_MIN_MTU (which
>>>> doesn't seem to exist today)?
>>>
>>> We have plenty of places this is checked.
>>>
>>> For example, trying to set MTU < 68 usually removes IPv4 addresses and routes.
>>>
>>> Problem is : these checks are not fool proof yet.
>>>
>>> ( Only the admin was supposed to play these games )
>>>
>>>>
>>>> Otherwise, I do spot another potential issue. The writer side (e.g. most
>>>> net_device::ndo_change_mtu implementations and the __dev_set_mtu()
>>>> fallback) doesn't use WRITE_ONCE().
>>>
>>> It does not matter how many strange values can be observed by the reader :
>>> We must be fool proof anyway from reader point of view, so the
>>> WRITE_ONCE() is not strictly needed.
>>
>>
>> Note if writer stores some temporal garbage there (which C language
>> perfectly allows), it does not matter what we do on reader side --
>> reader won't get correct data anyway. Say mtu changes from 1000 to
>> 2000, but writer temporary stores 1 there, reader can observe 1 while
>> it must not. Synchronization is always a game of two.
>
> Since we have no sync here, a reader _must_ cope with any MTU value.
>
> We need to care of any value, so we do not care how dummy writers can be.
>
> Sure, a WRITE_ONCE() will help avoiding some strange values being written,
>  but since we _allow_ writers to write such strange values,
> there is really no point pretending to be safe here.
>
> Adding a WRITE_ONCE() will not fix the bug.


Reader must cope with any value. But there is an additional
requirement that it must behave correctly. If mtu was 1000 and then
reset to 2000 once (and not other manipulations with mtu), then
correct behavior is either (1) sending packets with mtu 1000 or (2)
sending packets with mtu 2000 (after mtu change) and nothing else.
Sending packets with mtu 500, dropping packets because mtu is observed
to be 1, or formatting hard drive are all incorrect behaviors and must
not happen.

What you say is valid for communication with user-space
(copy_form_user, etc). Because there we don't control write side and
racy writes are indistinguishable from intentional writes that do the
same.
