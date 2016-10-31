From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 3/4] bpf: BPF for lightweight tunnel encapsulation
Date: Sun, 30 Oct 2016 18:28:24 -0700
Message-ID: <CALx6S35TOQumWFu1ha9nkNNOEwq2Y2VH6oCOK6F3HZg97omQgw@mail.gmail.com>
References: <cover.1477827877.git.tgraf@suug.ch> <2ab47e198828261438e8762ef484a6023481a756.1477827877.git.tgraf@suug.ch>
 <CALx6S35PMvoMZ-L0bC4R=Q9qw=V5N7JY_Xbit0BffFccH0nMgw@mail.gmail.com> <20161030214717.GA27148@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        roopa <roopa@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36199 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757394AbcJaB2Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 21:28:25 -0400
Received: by mail-qk0-f194.google.com with SMTP id z190so8937202qkc.3
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 18:28:25 -0700 (PDT)
In-Reply-To: <20161030214717.GA27148@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 30, 2016 at 2:47 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 10/30/16 at 01:34pm, Tom Herbert wrote:
>> On Sun, Oct 30, 2016 at 4:58 AM, Thomas Graf <tgraf@suug.ch> wrote:
>> > +       if (unlikely(!dst->lwtstate->orig_output)) {
>> > +               WARN_ONCE(1, "orig_output not set on dst for prog %s\n",
>> > +                         bpf->out.name);
>> > +               kfree_skb(skb);
>> > +               return -EINVAL;
>> > +       }
>> > +
>> > +       return dst->lwtstate->orig_output(net, sk, skb);
>>
>> The BPF program may have changed the destination address so continuing
>> with original route in skb may not be appropriate here. This was fixed
>> in ila_lwt by calling ip6_route_output and we were able to dst cache
>> facility to cache the route to avoid cost of looking it up on every
>> packet. Since the kernel  has no insight into what the BPF program
>> does to the packet I'd suggest 1) checking if destination address
>> changed by BPF and if it did then call route_output to get new route
>> 2) If the LWT destination is a host route then try to keep a dst
>> cache. This would entail checking destination address on return that
>> it is the same one as kept in the dst cache.
>
> Instead of building complex logic, we can allow the program to return
> a code to indicate when to perform another route lookup just as we do
> for the redirect case. Just because the destination address has
> changed may not require another lookup in all cases. A typical example
> would be a program rewriting addresses for the default route to other
> address which are always handled by the default route as well. An
> unconditional lookup would hurt performance in many cases.

Right, that's why we rely on a dst cache. Any use of LWT that
encapsulates or tunnels to a fixed destination (ILA, VXLAN, IPIP,
etc.) would want to use the dst cache optimization to avoid the second
lookup. The ILA LWT code used to call orig output and that worked as
long as we could set the default router as the gateway "via". It was
something we were able to deploy, but not a general solution.
Integrating properly with routing gives a much better solution IMO.
Note that David Lebrun's latest LWT Segment Routing patch does the
second lookup with the dst cache to try to avoid it.

Thanks,
Tom
