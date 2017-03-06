From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] packet: fix panic in __packet_set_timestamp on
 tpacket_v3 in tx mode
Date: Mon, 6 Mar 2017 17:13:01 -0500
Message-ID: <CAF=yD-+Nqv+cVOj6Vy-1DJTXeYkH_nadz0uQZWDn1Ly9zEmBtg@mail.gmail.com>
References: <1483580068-13854-1-git-send-email-daniel@iogearbox.net>
 <1483640872.9712.1.camel@edumazet-glaptop3.roam.corp.google.com>
 <586E9A0F.1020002@iogearbox.net> <CAAsGZS59KsGHJzG-U962kK4AP+M40zAV-ERgDqYvDLz5JB6Exg@mail.gmail.com>
 <CAF=yD-Jr5J9yoaNmBBSneL4HBuWcw3uRV4Smw=AnPAB+Sq9YSw@mail.gmail.com> <CAAsGZS5U_gX2-MTdnixtiNv8Wa8f+F7Wx7g=i3iffQEgruQ2bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35721 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932076AbdCFWNo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 17:13:44 -0500
Received: by mail-wm0-f65.google.com with SMTP id z63so13807676wmg.2
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 14:13:43 -0800 (PST)
In-Reply-To: <CAAsGZS5U_gX2-MTdnixtiNv8Wa8f+F7Wx7g=i3iffQEgruQ2bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> Gosh. Can we also replace this BUG() into something less aggressive ?
>>>>
>>>>
>>>> There are currently 5 of these WARN() + BUG() constructs and 1 BUG()-only
>>>> for the 'default' TPACKET version spread all over af_packet, so probably
>>>> makes sense to rather make all of them less aggressive.
>>>>
>>>>
>>>
>>> Very few consumers actually go looking in the kernel logs to see the
>>> error-warnings and report them back here.
>>>
>>> This severity will get them to report the incident which in this case
>>> got fixed??
>>
>> But BUG_ONs in the datapath can cause outages in real production
>> environments. This should not happen for recoverable failures. For
>> users who cannot be bothered to check their logs, there is sysctl
>> kernel.panic_on_warn.
>
>
> Completely understand(and you should have failover to handle these
> outages).

Not for correlated failures where all systems can hit the same path.
This is especially dangerous when remote packets or untrusted
local users can trigger a BUG-enabled path.

> But then are you ok giving incorrect info to the
> application?

No, we should certainly signal an error. For instance, returning
TP_STATUS_WRONG_FORMAT instead of TP_STATUS_AVAILABLE.

> For this specific bug: it is so basic that you should hit this bug 1st
> time everytime when you are adding support or porting a new header.
> Correct?

Agreed, but that is small consolation if an unprivileged user (say, in
a namespace) finds out that it can trigger the codepath.

But I agree that this particular BUG_ON is one of the easier to
reason about.
