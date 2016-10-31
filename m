From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 3/4] bpf: BPF for lightweight tunnel encapsulation
Date: Mon, 31 Oct 2016 09:07:20 -0700
Message-ID: <CALx6S34hjr9-OV1qiyh+J=zhFdUtmMeC+7S=gj3BR7Z=1vaitA@mail.gmail.com>
References: <cover.1477827877.git.tgraf@suug.ch> <2ab47e198828261438e8762ef484a6023481a756.1477827877.git.tgraf@suug.ch>
 <CALx6S35PMvoMZ-L0bC4R=Q9qw=V5N7JY_Xbit0BffFccH0nMgw@mail.gmail.com>
 <20161030214717.GA27148@pox.localdomain> <CALx6S35TOQumWFu1ha9nkNNOEwq2Y2VH6oCOK6F3HZg97omQgw@mail.gmail.com>
 <20161031125906.GB32374@pox.localdomain> <CALx6S34hHZDdtZgLBZzw-QiOc80tjrLAuAVBDeWRuUonR1MfXA@mail.gmail.com>
 <20161031150640.GC32374@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        roopa <roopa@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36049 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756205AbcJaQHW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 12:07:22 -0400
Received: by mail-qk0-f194.google.com with SMTP id z190so10167035qkc.3
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 09:07:21 -0700 (PDT)
In-Reply-To: <20161031150640.GC32374@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 8:06 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 10/31/16 at 07:17am, Tom Herbert wrote:
>> On Mon, Oct 31, 2016 at 5:59 AM, Thomas Graf <tgraf@suug.ch> wrote:
>> > Noticed while implementing this: How does ILA ensure that dst_output()
>> > is not invoked in a circular manner?
>> >
>> > dstA->output() -> dstB->otuput() -> dstA->output() -> ...
>>
>> It doesn't. We'll need to add a check for that. Maybe the rule should
>> be that an skbuff is only allowed to hit one LWT route?
>
> I'll add a per cpu variable to do a recursion limit for dst_output()
> which callers to possibly recurse can use. ILA can use that as well.
>
>> Another scenario to consider: Suppose someone is doing protocol
>> translation like in RFC7915. This is one of operations we'd need with
>> ILA or GRE to implement an IPv4 overlay network over IPv6. Would this
>> be allowed/supported in LWT BPF?
>
> In lwtunnel_xmit() yes, input and output would not support this right
> now. It will need some logic as the orig_input and orig_output would
> obviously be expecting the same protocol. This is the reason why the
> xmit prog type currently has a wider set of allowed helpers.

I guess this leads to a more general question I have about the effects
of allowing userspace to insert code in the kernel that modifies
packets. If we allow BPF programs to arbitrarily modify packets in
LWT, how do we ensure that there are no insidious effects later in the
path? For instance,  what someone uses BPF to convert an IPv6 packet
to IPv4, or maybe convert packet to something that isn't even IP, or
what if someone just decides to overwrite every byte in a packet with
0xff? Are these thing allowed, and if so what is the effect? I would
assume a policy that these can't cause any insidious effects to
unrelated traffic or the rest of the system, in particular such things
should not cause the  kernel to crash (based on the principle that
user space code should never cause kernel to crash). I think XDP might
be okay since the path is straightforward and only deals with raw
packets, but LWT is much higher in that stack.

Thanks,
Tom
