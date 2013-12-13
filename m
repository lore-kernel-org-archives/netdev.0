From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: remove a bogus TSO split
Date: Fri, 13 Dec 2013 10:38:46 -0800
Message-ID: <1386959926.19078.169.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386876523.19078.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386958426.19078.162.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CADVnQy=ayiUVjXPscUkONDOGhfQ7xDyqn=KFzrndjw2mrPufrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:65226 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746Ab3LMSit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 13:38:49 -0500
Received: by mail-yh0-f46.google.com with SMTP id l109so1805981yhq.19
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 10:38:49 -0800 (PST)
In-Reply-To: <CADVnQy=ayiUVjXPscUkONDOGhfQ7xDyqn=KFzrndjw2mrPufrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-13 at 13:17 -0500, Neal Cardwell wrote:

> It occurred to me after staring at this code a little longer that
> although the Nagle test is already done before the call to
> tcp_mss_split_point(), the tcp_nagle_check() is only run if
> tso_segs==1 and is only checking whether skb->len < mss_now, so the
> Nagle code currently is implicitly assuming that if there is an skb
> that is not an exact multiple of MSS, then the tcp_mss_split_point()
> will chop off the odd bytes at the end and we'll loop back to the top
> of the tcp_write_xmit() loop to make a Nagle decision on an skb that
> has tso_segs==1.
> 
> So if we just make this improvement to tcp_mss_split_point() and the
> adjustment to tcp_minshall_update() (as in patch v2), we will still
> have broken Nagle behavior in a scenario like:
> 
> - suppose MSS=1460 and Nagle is enabled (TCP_NODELAY is not set)
> 
> - suppose there is an outstanding un-ACKed small packet, so that
> tcp_minshall_check() returns true
> 
> - user writes 2000 bytes
> 
> - tso_segs is 2, so we do not call tcp_nagle_test()
> 
> - new version of tcp_mss_split_point() sends out the full 2000 bytes,
>   leading to having 2 packets smaller than an MSS un-ACKed in the network,
>   violating the invariant the minshall/nagle code is trying to maintain
>   or having only one such packet un-ACKed in the network.
> 
> Previously, tcp_mss_split_point() would have split off the 2000-1460
> bytes into a new skb, we would have looped back and executed the
> tcp_nagle_test() code and decided not to send that small sub-MSS
> 2000-1460 packet.
> 

Hmm, it seems we need to refactor a bit.

tcp_snd_test() seems to not care of TSO being partial.
