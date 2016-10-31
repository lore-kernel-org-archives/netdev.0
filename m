From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/4] bpf: BPF for lightweight tunnel
 encapsulation
Date: Mon, 31 Oct 2016 18:35:00 +0100
Message-ID: <20161031173500.GD32374@pox.localdomain>
References: <cover.1477827877.git.tgraf@suug.ch>
 <2ab47e198828261438e8762ef484a6023481a756.1477827877.git.tgraf@suug.ch>
 <CALx6S35PMvoMZ-L0bC4R=Q9qw=V5N7JY_Xbit0BffFccH0nMgw@mail.gmail.com>
 <20161030214717.GA27148@pox.localdomain>
 <CALx6S35TOQumWFu1ha9nkNNOEwq2Y2VH6oCOK6F3HZg97omQgw@mail.gmail.com>
 <20161031125906.GB32374@pox.localdomain>
 <CALx6S34hHZDdtZgLBZzw-QiOc80tjrLAuAVBDeWRuUonR1MfXA@mail.gmail.com>
 <20161031150640.GC32374@pox.localdomain>
 <CALx6S34hjr9-OV1qiyh+J=zhFdUtmMeC+7S=gj3BR7Z=1vaitA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        roopa <roopa@cumulusnetworks.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38873 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945043AbcJaRfD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 13:35:03 -0400
Received: by mail-wm0-f45.google.com with SMTP id n67so242568453wme.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 10:35:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S34hjr9-OV1qiyh+J=zhFdUtmMeC+7S=gj3BR7Z=1vaitA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/16 at 09:07am, Tom Herbert wrote:
> I guess this leads to a more general question I have about the effects
> of allowing userspace to insert code in the kernel that modifies
> packets. If we allow BPF programs to arbitrarily modify packets in
> LWT, how do we ensure that there are no insidious effects later in the
> path? For instance,  what someone uses BPF to convert an IPv6 packet
> to IPv4, or maybe convert packet to something that isn't even IP, or
> what if someone just decides to overwrite every byte in a packet with
> 0xff?

This is why modifying packets is not allowed on input at all as it
would invalidate the IP parsing that has already been done.

Writing is allowed for dst_output() on the basis that it is the
equivalent of a raw socket with header inclusion. If you look at
rawv6_send_hdrinc(), it does not perform any validation and calls into
dst_output() directly. I agree though that this must be made water
proof.

Pushing additional headers is only allowed at xmit, this is the
equivalent LWT MPLS.

> Are these thing allowed, and if so what is the effect? I would
> assume a policy that these can't cause any insidious effects to
> unrelated traffic or the rest of the system, in particular such things
> should not cause the  kernel to crash (based on the principle that
> user space code should never cause kernel to crash). I think XDP might

Agreed. Although it's already possible to hook a kernel module at LWT
or Netfilter to do arbitrary packet modifications, BPF must be held
at a higher standard even in privileged mode.
