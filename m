From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next] tcp: remove a bogus TSO split
Date: Fri, 13 Dec 2013 13:17:32 -0500
Message-ID: <CADVnQy=ayiUVjXPscUkONDOGhfQ7xDyqn=KFzrndjw2mrPufrw@mail.gmail.com>
References: <1386876523.19078.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<1386958426.19078.162.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:53989 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470Ab3LMSRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 13:17:33 -0500
Received: by mail-ee0-f52.google.com with SMTP id d17so1039054eek.11
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 10:17:32 -0800 (PST)
In-Reply-To: <1386958426.19078.162.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 1:13 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While investigating performance problems on small RPC workloads,
> I noticed linux TCP stack was always splitting the last TSO skb
> into two parts (skbs). One being a multiple of MSS, and a small one
> with the Push flag. This split is done even if TCP_NODELAY is set.
>
...
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Nandita Dukkipati <nanditad@google.com>
> Cc: Van Jacobson <vanj@google.com>
> ---
> v2: changed tcp_minshall_update() as Neal pointed out.

It occurred to me after staring at this code a little longer that
although the Nagle test is already done before the call to
tcp_mss_split_point(), the tcp_nagle_check() is only run if
tso_segs==1 and is only checking whether skb->len < mss_now, so the
Nagle code currently is implicitly assuming that if there is an skb
that is not an exact multiple of MSS, then the tcp_mss_split_point()
will chop off the odd bytes at the end and we'll loop back to the top
of the tcp_write_xmit() loop to make a Nagle decision on an skb that
has tso_segs==1.

So if we just make this improvement to tcp_mss_split_point() and the
adjustment to tcp_minshall_update() (as in patch v2), we will still
have broken Nagle behavior in a scenario like:

- suppose MSS=1460 and Nagle is enabled (TCP_NODELAY is not set)

- suppose there is an outstanding un-ACKed small packet, so that
tcp_minshall_check() returns true

- user writes 2000 bytes

- tso_segs is 2, so we do not call tcp_nagle_test()

- new version of tcp_mss_split_point() sends out the full 2000 bytes,
  leading to having 2 packets smaller than an MSS un-ACKed in the network,
  violating the invariant the minshall/nagle code is trying to maintain
  or having only one such packet un-ACKed in the network.

Previously, tcp_mss_split_point() would have split off the 2000-1460
bytes into a new skb, we would have looped back and executed the
tcp_nagle_test() code and decided not to send that small sub-MSS
2000-1460 packet.

neal
