From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH v2 net-next 2/6] udp: Constify skb argument in lookup functions
Date: Tue, 29 Aug 2017 20:09:17 -0700
Message-ID: <CAPDqMeqp94FdyMZdrbbaxU3=RrgcOk5Rf7nyKcLzu+89oSzOOg@mail.gmail.com>
References: <20170829232711.1465-1-tom@quantonium.net> <20170829232711.1465-3-tom@quantonium.net>
 <20170829.175832.437965683493864458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37493 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751329AbdH3DJT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 23:09:19 -0400
Received: by mail-wm0-f51.google.com with SMTP id u26so2318791wma.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 20:09:18 -0700 (PDT)
In-Reply-To: <20170829.175832.437965683493864458.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 5:58 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@quantonium.net>
> Date: Tue, 29 Aug 2017 16:27:07 -0700
>
>> For UDP socket lookup functions, and associateed functions that take an
>> skbuf as argument, declare the skb argument as constant.
>>
>> One caveat is that reuseport_select_sock can be called from the UDP
>> lookup functions with an skb argument. This function temporarily
>> modifies the skbuff data pointer (in bpf_run via a pull/push sequence).
>> To resolve compiler warning I added a local skbuf declaration that is
>> not const and assigned to the skb argument with an explicit cast.
>>
>> Signed-off-by: Tom Herbert <tom@quantonium.net>
>
> Please don't do this.
>
> If reuseport_select_sock() modifies anything in the SKB, especially
> skb->data, it infects the entire call chain.  So you can't mark it
> const in this family of calls.
>
reuseport_select_sock calls run_bpf that calls pskb_pull to
"temporarily advance data past protocol header" and it calls
bpf_prog_run_save_cb which takes non-constant skb argument. This is
the only instance in all the udp lookup functions where non-constant
is needed. It's logical that constant skbuf makes sense for socket
lookup-- I doubt any caller would expect the skbuf to be modified as a
side effect. It's also an implicit characteristic since
reuseport_select_sock may just clone the socket before calling BPF.

The problem is that all the flow dissector functions operate on const
skbs (again that's logical :-) ). So if we want to be able to call
lookup functions or even BPF to do flow dissection, then I think
something needs to change. I really don't want to unconsitify the flow
dissector functions. We could just always do the skb before calling
BPF, but I suppose that is a potential performance hit. Is there a
better way to resolve this?

Thanks,
Tom
