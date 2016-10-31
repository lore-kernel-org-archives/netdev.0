From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/4] bpf: BPF for lightweight tunnel
 encapsulation
Date: Mon, 31 Oct 2016 16:06:40 +0100
Message-ID: <20161031150640.GC32374@pox.localdomain>
References: <cover.1477827877.git.tgraf@suug.ch>
 <2ab47e198828261438e8762ef484a6023481a756.1477827877.git.tgraf@suug.ch>
 <CALx6S35PMvoMZ-L0bC4R=Q9qw=V5N7JY_Xbit0BffFccH0nMgw@mail.gmail.com>
 <20161030214717.GA27148@pox.localdomain>
 <CALx6S35TOQumWFu1ha9nkNNOEwq2Y2VH6oCOK6F3HZg97omQgw@mail.gmail.com>
 <20161031125906.GB32374@pox.localdomain>
 <CALx6S34hHZDdtZgLBZzw-QiOc80tjrLAuAVBDeWRuUonR1MfXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        roopa <roopa@cumulusnetworks.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38839 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943632AbcJaPGn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 11:06:43 -0400
Received: by mail-wm0-f51.google.com with SMTP id n67so234301365wme.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 08:06:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S34hHZDdtZgLBZzw-QiOc80tjrLAuAVBDeWRuUonR1MfXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/16 at 07:17am, Tom Herbert wrote:
> On Mon, Oct 31, 2016 at 5:59 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > Noticed while implementing this: How does ILA ensure that dst_output()
> > is not invoked in a circular manner?
> >
> > dstA->output() -> dstB->otuput() -> dstA->output() -> ...
> 
> It doesn't. We'll need to add a check for that. Maybe the rule should
> be that an skbuff is only allowed to hit one LWT route?

I'll add a per cpu variable to do a recursion limit for dst_output()
which callers to possibly recurse can use. ILA can use that as well.

> Another scenario to consider: Suppose someone is doing protocol
> translation like in RFC7915. This is one of operations we'd need with
> ILA or GRE to implement an IPv4 overlay network over IPv6. Would this
> be allowed/supported in LWT BPF?

In lwtunnel_xmit() yes, input and output would not support this right
now. It will need some logic as the orig_input and orig_output would
obviously be expecting the same protocol. This is the reason why the
xmit prog type currently has a wider set of allowed helpers.
