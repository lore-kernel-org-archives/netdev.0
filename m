From: John Heffner <johnwheffner@gmail.com>
Subject: Re: tcp_mtu_probe implementation details
Date: Sat, 24 Dec 2011 10:03:08 -0500
Message-ID: <CABrhC0mhuY75Y0Q_dkkPMH4si1OinM3bvpK_cHhOwQRpAAFu2A@mail.gmail.com>
References: <op.v6s5j2i0fzo5me@stalin>
	<CAGK4HS93u=3muZu_rkqK7FSacTHUytK5H6_dMNo_uOQY738R_g@mail.gmail.com>
	<op.v6t2ygnyfzo5me@stalin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Anatoly Sivov <mm05@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:57719 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755126Ab1LXPDJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2011 10:03:09 -0500
Received: by vcbfk14 with SMTP id fk14so7850584vcb.19
        for <netdev@vger.kernel.org>; Sat, 24 Dec 2011 07:03:08 -0800 (PST)
In-Reply-To: <op.v6t2ygnyfzo5me@stalin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP doesn't operate as well with a small window, and below some point
there isn't really a justification for increasing the MTU size.  11 is
something of a magic number, but here's the reasoning:

A cwnd of 11 pre-probe will result in a cwnd of 6 after a successful
probe.  (By the time the probe succeeds, cwnd will have been increased
to 12, then doubling MSS will halve cwnd to 6.)  A window size smaller
than this makes TCP more vulnerable to double loss events and
increases the likeliness of timeouts.

  -John


2011/12/21 Anatoly Sivov <mm05@mail.ru>:
> Hello Vijay,
>
> Thank you for your response.
>
>
>>> The other question is about size_needed variable.
>>> It is assigned to value probe_size + (tp->reordering + 1) * tp->mss=
_cache
>>> And that is not clear for me.
>>> What is this "(tp->reordering + 1) * tp->mss_cache" addition?
>>>
>>
>> I think the idea is that you want enough bytes in the write_queue so
>> that even if the probe is lost, the sender will get an ack even if
>> there is reordering in the network. Without sufficient bytes, the
>> probe will not be sent. This is what I make of the code but I could =
be
>> wrong.
>
>
> I believe, I found the explanation of this addition in RFC 4821:
> =A0"TCP Fast Retransmit is not robust unless there are
> =A0 sufficient segments following a probe; that is, the sender SHOULD
> =A0 have enough data queued and sufficient receiver window to send th=
e
> =A0 probe plus at least Tcprexmtthresh [RFC2760] additional segments.=
"
>
> However, I'm still confused with magic number 11 in "tp->snd_cwnd < 1=
1"
> check.
>
> Thanks.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
