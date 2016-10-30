From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/4] bpf: BPF for lightweight tunnel
 encapsulation
Date: Sun, 30 Oct 2016 22:47:17 +0100
Message-ID: <20161030214717.GA27148@pox.localdomain>
References: <cover.1477827877.git.tgraf@suug.ch>
 <2ab47e198828261438e8762ef484a6023481a756.1477827877.git.tgraf@suug.ch>
 <CALx6S35PMvoMZ-L0bC4R=Q9qw=V5N7JY_Xbit0BffFccH0nMgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        roopa <roopa@cumulusnetworks.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36750 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754633AbcJ3VrT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 17:47:19 -0400
Received: by mail-wm0-f49.google.com with SMTP id p190so115063878wmp.1
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 14:47:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35PMvoMZ-L0bC4R=Q9qw=V5N7JY_Xbit0BffFccH0nMgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/16 at 01:34pm, Tom Herbert wrote:
> On Sun, Oct 30, 2016 at 4:58 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > +       if (unlikely(!dst->lwtstate->orig_output)) {
> > +               WARN_ONCE(1, "orig_output not set on dst for prog %s\n",
> > +                         bpf->out.name);
> > +               kfree_skb(skb);
> > +               return -EINVAL;
> > +       }
> > +
> > +       return dst->lwtstate->orig_output(net, sk, skb);
> 
> The BPF program may have changed the destination address so continuing
> with original route in skb may not be appropriate here. This was fixed
> in ila_lwt by calling ip6_route_output and we were able to dst cache
> facility to cache the route to avoid cost of looking it up on every
> packet. Since the kernel  has no insight into what the BPF program
> does to the packet I'd suggest 1) checking if destination address
> changed by BPF and if it did then call route_output to get new route
> 2) If the LWT destination is a host route then try to keep a dst
> cache. This would entail checking destination address on return that
> it is the same one as kept in the dst cache.

Instead of building complex logic, we can allow the program to return
a code to indicate when to perform another route lookup just as we do
for the redirect case. Just because the destination address has
changed may not require another lookup in all cases. A typical example
would be a program rewriting addresses for the default route to other
address which are always handled by the default route as well. An
unconditional lookup would hurt performance in many cases.
