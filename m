From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: Fix CWV being too strict on thin streams
Date: Tue, 22 Sep 2015 14:02:25 -0400
Message-ID: <CADVnQy=PPe+-HP2Sm7qK6BUxbp-iKjERq7eXvR29+3R1yas7LA@mail.gmail.com>
References: <1442619503-2282-1-git-send-email-bro.devel+kernel@gmail.com>
	<CADVnQy=BXvWMXUGeeABjsHDpfa4FF+RUfCvJXpupcyYKG+=+ig@mail.gmail.com>
	<8021096.gY5K1ti0Dn@garfield>
	<1442933196.29850.94.camel@edumazet-glaptop2.roam.corp.google.com>
	<1442938150.29850.97.camel@edumazet-glaptop2.roam.corp.google.com>
	<1442941902.29850.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36397 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933721AbbIVSCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 14:02:36 -0400
Received: by oibi136 with SMTP id i136so10207532oib.3
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 11:02:25 -0700 (PDT)
In-Reply-To: <1442941902.29850.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'll describe two example scenarios in detail. In both scenarios we are in
> congestion avoidance after experiencing loss. Nagle is disabled.

Thanks for the detailed follow-up! And thanks, Eric, for the packetdrill
script!

This looks like an issue of how to deal with the case when we run out of
packets to send and cwnd at exactly the same moment, and whether we consider
that case cwnd-limited.

Previously we did not consider ourselves cwnd-limited in that case, but I think
your "scenario 1", and Eric's packetdrill case, show convincingly that we ought
to consider ourselves cwnd-limited in that case.

I would suggest we try fixing this by making sure that in scenario 1, at the
moment when we fill the cwnd (packets_in_flight == cwnd == 2) we mark ourselves
as cwnd-limited.

More generally, my sense is that we should tweak the is_cwnd_limited code to
shift from saying "set is_cwnd_limited to true iff the cwnd is known to be
limiting transmits" to saying "set is_cwnd_limited to true iff the packets in
flight fill the cwnd".

This is partly justified by the kind of case presented here. Plus, in RFC 2861,
section 3.1, which this code is helping to implement, it says:

   After TCP sends a packet, it also checks to see if that packet filled
   the congestion window.  If so, the sender is network-limited, and
   sets the variable T_prev to the current TCP clock time,

So at the point in Scenario 1 when we send the second packet, and
  packets_in_flight == cwnd == 2
then IMHO we should set
  tp->is_cwnd_limited = true
and thus
  tp->snd_cwnd_stamp = tcp_time_stamp;

So maybe we want to slightly tweak the way tcp_write_xmit() and
tcp_tso_should_defer() treat this boundary condition? Gotta run to a
meeting....

neal

ps: If the tp->is_cwnd_limited and tcp_cwnd_validate() code were only used to
decide whether to increase cwnd, then I think your fix would probably be
sufficient. But it is also used for the code to implement RFC 2861 ("TCP
Congestion Window Validation"). So I don't think just changing
tp->is_cwnd_limited is sufficient.
