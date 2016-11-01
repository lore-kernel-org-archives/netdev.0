From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded ICMP errors from offending packet
Date: Tue, 01 Nov 2016 16:13:51 +0100
Message-ID: <87bmxznsgg.fsf@redhat.com>
References: <20161031.151534.329043104568805244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: tom@herbertland.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35651 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758149AbcKAPTK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:19:10 -0400
Received: by mail-wm0-f41.google.com with SMTP id a197so84143786wmd.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 08:19:09 -0700 (PDT)
In-reply-to: <20161031.151534.329043104568805244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 07:15 PM GMT, David Miller wrote:
> From: Jakub Sitnicki <jkbs@redhat.com>
> Date: Sun, 30 Oct 2016 14:03:11 +0100
>
>> 2) ensure the flow labels used in both directions are the same (either
>>    reflected by one side, or fixed, e.g. not used and set to 0), so that
>>    the 4-tuple we hash over when forwarding, <src addr, dst addr, flow
>>    label, next hdr>, is the same both ways, modulo the order of
>>    addresses.
>
> Even Linux, by default, does not do reflection.
>
> See the flowlabel_consistency sysctl, which we set by default to '1'.

Yes, unfortunately, if Linux-based hosts are used as sending/receiving
IPv6, ICMP error forwarding will not work out of the box. Users will be
burdened with adjusting the runtime network stack config, as you point
out, or otherwise instructing the apps to set the flow label,
e.g. traceroute6 -I <flow label> ...

> I think we need to think a lot more about how systems actually set and
> use flowlabels.

The only alternative I can think of, only for ECMP routing, is having a
toggle option that would exclude the flow label from the input to the
multipath hash.

We would be sacrificing the entropy that potentially comes from hashing
over the flow label, leading to better flow balancing. But we wouldn't
be making IPv6 multipath routing any worse than IPv4 is in that regard.
And user-space apps wouldn't need to resort to reflecting/setting the
label, just like with IPv4.

Is that something that you would consider a viable option?

> Also, one issue I also had with this series was adding a new member
> to the flow label.  Is it possible to implement this like the ipv4
> side did, by simply passing a new parameter around to the necessary
> functions?

This was my initial approach, i.e. to mimic the IPv4 and pass the
multipath hash down the call chain via a parameter. However, I gave up
on it, thinking it will cause too much disturbance in the involved
functions' interfaces, when I realized that one of the call paths the
multipath hash would have to also be passed through is:

  ip6_route_input_lookup
    fib6_rule_lookup
      fib_rules_lookup
        fib6_rule_action
          ip6_pol_route_input

To be honest, I was thinking that if extending flowi6 structure would
find acceptance, then maybe the new member could be at some point moved
to flowi_common and also used by IPv4 to avoid parameter passing there
as well.

Thanks,
Jakub
