From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 5/5] tcp: skip cwnd moderation in TCP_CA_Open in tcp_try_to_open
Date: Sat, 19 Nov 2011 16:08:40 -0500
Message-ID: <CADVnQymPTWsD0Hx060qYUMrFPxgQPdJWwPA9oDce6qMVL4tVpA@mail.gmail.com>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
	<1321469885-10885-5-git-send-email-ncardwell@google.com>
	<alpine.DEB.2.00.1111170706330.23028@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:36797 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402Ab1KSVIl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2011 16:08:41 -0500
Received: by ggnr5 with SMTP id r5so1223338ggn.19
        for <netdev@vger.kernel.org>; Sat, 19 Nov 2011 13:08:40 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111170706330.23028@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2011 at 12:14 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:

> I think it's intentional. Because of receiver lying bandwidth cheats =
all
> unlimited undos are bit dangerous.

If your concern is receivers lying, then there are other easy ways
that a misbehaving receiver can get a sender to send too fast
(e.g. cumulatively ACKing the highest sequence number seen,
irrespective of holes). IMHO it would be a shame to penalize the vast
majority of well-behaved users to plug one potential attack vector
when there are other easy holes that an attacker would use.

> Wouldn't it be enough if tcp max burst is increased to match IW (iirc=
 we
> had 3 still there as a magic number)?

Yes, tcp_max_burst() returns tp->reordering now. Changing it to return
max(tp->reordering, TCP_INIT_CWND) sounds good to me. I think that's
an excellent idea in any case, regardless of the outcome of this undo
discussion.

However, I don't think this is sufficient for request-response
protocols (e.g. RPC) running over long-lived connections over a path
with a large bandwidth-delay product. In such cases, the cwnd will
grow quite large (hundreds of packets). The DSACKs will often arrive
after the entire response is sent, so that cwnd moderation will
typically pull the cwnd down to 3 (or, with your proposal, 10)
packets. IMHO that seems like an unnecessarily steep price to pay.

neal
