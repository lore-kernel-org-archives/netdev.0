From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Sun, 25 Sep 2016 08:29:23 -0400
Message-ID: <a18c41bc-0a44-589f-685e-9cd9e44f9261@mojatatu.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
 <06280af8-5451-c423-d295-a5f3f51e63cf@mojatatu.com>
 <CALx6S36rFUaaeFU4sE7gNaPn2Jxf-FaOESy_rrDpLKRx-SWkDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36375 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966128AbcIYM30 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 08:29:26 -0400
Received: by mail-io0-f195.google.com with SMTP id z135so9642808ioe.3
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 05:29:25 -0700 (PDT)
In-Reply-To: <CALx6S36rFUaaeFU4sE7gNaPn2Jxf-FaOESy_rrDpLKRx-SWkDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-23 10:14 AM, Tom Herbert wrote:
> On Fri, Sep 23, 2016 at 4:13 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 16-09-20 06:00 PM, Tom Herbert wrote:

>> Tom,
>> perused the thread and it seems you are serious ;->
>> Are we heading towards Frankenstein Avenue?
>
> I'm surprised. I thought you'd like democratizing an interface. :-)
>

I do;-> challenge here is the worry about the classical camel's nose
metaphor[1]. The original intent was for simplicity. Do one very
simple thing. Do it fast.
Note: this is code that is sitting in a critical driver path

[Democratizing the interfaces is a bigger scope discussion we can have
not just for XDP but tc, netfilter etc.]

>> The whole point behind letting in XDP is so that _small programs_
>> can be written to do some quick thing. eBPF 4K program limit was
>> touted as the check and bound. eBPF sounded fine.
>> This sounds like a huge contradiction.
>
> Jamal, thanks for the feedback.
>
> IMO, XDP != BPF. XDP is an interface in drivers that allow raw packet
> processing in the receive path,. This is akin to DPDK in the kernel.

Understood.

Most of these DPDK apps do simple things. EX: show ILA forwarding with
high throughput on a single core - which can be achieved with XDP as is
right now. With DPDK you start doing more generic things and shit starts
slowing down. We can have the best of both worlds In Linux (with 2-3
other modular interfaces above XDP).
Getting both {performance, flexibility} is hard. Add a third dimension
of usability and everything starts spiralling on the z-axis.
i.e pick one and a quarter of those 3 features; anything else is a
an art project. Example: you start adding flexibility we will no doubt
need a northbound control interface, etc.

So I see XDP as this "fast and specific blob" and things above are more
generic.
Our biggest issue, as the netmap and other folks have shown,
is the obesity of the skb. On XDP, I would bet things
get faster because there is no skb - the danger is turning it into
"move your stack to XDP to avoid skbs"

 > BPF is critical use case of the interface.
> As for the 4K limit that still allows for a lot of damage and abuse
> that the user can do with a loadable program and, yes, code in the
> kernel can do significant damage as well.

But we have at least a handwavy insurance limit.
A determined person could circumvent the limit - but it is more a
deterrent than enforcement.


> However, unlike BPF programs
> being set from userspace, kernel code has a well established process
> for acceptance, any suggested code gets review, and if it's going
> "Frankenstein Avenue" I'd expect it to be rejected. I get a little
> worried that we are going to start artificially limiting what we can
> do in the kernel on the basis that we don't trust kernel programmers
> to be competent enough not to abuse kernel interfaces-- the fact that
> we are enabling userspace to arbitrarily program the kernel but
> purposely limiting what the kernel itself can do would be a huge irony
> to me.

My concern is not incompentency. We already allow people to shoot
their little finger if they want to. And just to be clear I am
not concerned with allowing other people to save the world their
way ;->

So lets say we said ebpf was one use case:
If you wrote an XDP "app" in plain C, could you still enforce this
limit so bigcorp doesnt start building islands around Linux?
Again, the camel metaphor applies.

Note, comparison with kernel modules at tc or netfilter hooks doesnt
apply because:
a) it is a lot harder to avoid kernel interfaces (skbs etc) in those
places. XDP for example totally avoids the skb. So contributing to the
Linux base is a given with kernel modules.
b) Programs that are usable as kernel modules tend to be geared towards
inclusion into the kernel because of the complexity. It is more
maintainance to keep them off tree.
XDP is such a  simple interface that the opportunity to move a whole
DPDK-like industry into the kernel is huge (at the detriment of the
Linux kernel networking).

cheers,
jamal
