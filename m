From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: fix slow start after idle vs TSO/GSO
Date: Fri, 21 Aug 2015 11:10:26 -0400
Message-ID: <CADVnQyms7VoJm32dY5qiUf4A332mZTHXZXKUkkOm5BS0f77GDQ@mail.gmail.com>
References: <1440090487.6610.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34071 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbbHUPK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 11:10:27 -0400
Received: by oiey141 with SMTP id y141so43234528oie.1
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 08:10:26 -0700 (PDT)
In-Reply-To: <1440090487.6610.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2015 at 1:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> slow start after idle might reduce cwnd, but we perform this
> after first packet was cooked and sent.
>
> With TSO/GSO, it means that we might send a full TSO packet
> even if cwnd should have been reduced to IW10.
>
> Moving the SSAI check in skb_entail() makes sense, because
> we slightly reduce number of times this check is done,
> especially for large send() and TCP Small queue callbacks from
> softirq context.

Very nice catch, and this fix seems like a definite improvement.

One potential issue is that the connection can restart from idle not
just because new data has been written (which this patch addresses),
but also because the receive window opens and so now packets can be
sent again. The old version of the code implicitly fired the restart
code path in the "receive window opens" case as well, since it fired
every time new data was sent. We might want to check if we need to
call tcp_cwnd_restart() in tcp_ack_update_window(), next to the call
for tcp_fast_path_check()?

neal
