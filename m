From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Introduce FCLONE_SCRATCH skbs to reduce stack memory useage and
 napi jitter
Date: Fri, 28 Oct 2011 04:37:02 +0200
Message-ID: <1319769422.23112.54.camel@edumazet-laptop>
References: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
	 <1319756146.19125.42.camel@edumazet-laptop>
	 <20111028013729.GA6524@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56439 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865Ab1J1ChM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 22:37:12 -0400
Received: by mail-wy0-f174.google.com with SMTP id 36so3446173wyg.19
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 19:37:12 -0700 (PDT)
In-Reply-To: <20111028013729.GA6524@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 27 octobre 2011 =C3=A0 21:37 -0400, Neil Horman a =C3=A9crit :
> >=20
> Yes, I'd experimented with some of this, and had mixed results.  Spec=
ifically I
> came up with a way to use the additional space as an array of list he=
ads, with
> backpointers to the socket_queue each list_head was owned by and the =
skb that
> owned the entry.  It was nice because it let me enqueue the same skb =
to hundreds
> of sockets at the same time, which was really nice.  It was bad howev=
er, because
> it completely broke socket accounting (any likely anything else that =
required on
> any part of the socket state).  Any thoughts on ways I might improve =
on that.
> If I could make some sort of reduced sk_buff so that I didn't have to=
 allocate
> all 256 bytes of a full sk_buff, that would be great!

It seems your objectives are contradictory (memory saving and cpu
saving). Most of the time we have to fight false sharing first.

I dont want to try to use the available space from skb, since its cache
unfriendly, in case you have one CPU 100% in softirq handling,
dispatching messages to XX other application cpus.

You dont want each application cpu slowing down other cpus by
manipulating a list anchor, contained in a shared cache line, highly
contended. We already have one high contention point (skb refcount or
data refcount).

Another point of interest is that modern NIC tend to use paged frag
skbs, with very litle space available in skb head. frag part is
readonly, and sometime with no available space neither.

So your idea only works on some (old gen) nics and some narrow
conditions.

I believe it adds too much complex code for this.

I understand you are disappointed, but maybe you should have shared you=
r
ideas before coding them !
