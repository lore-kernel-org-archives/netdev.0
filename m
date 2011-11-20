From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 5/5] tcp: skip cwnd moderation in TCP_CA_Open in
 tcp_try_to_open
Date: Sun, 20 Nov 2011 10:38:33 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1111201024080.22397@melkinpaasi.cs.helsinki.fi>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com> <1321469885-10885-5-git-send-email-ncardwell@google.com> <alpine.DEB.2.00.1111170706330.23028@melkinpaasi.cs.helsinki.fi>
 <CADVnQymPTWsD0Hx060qYUMrFPxgQPdJWwPA9oDce6qMVL4tVpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1585358912-1321778313=:22397"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38642 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818Ab1KTIig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 03:38:36 -0500
In-Reply-To: <CADVnQymPTWsD0Hx060qYUMrFPxgQPdJWwPA9oDce6qMVL4tVpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1585358912-1321778313=:22397
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 19 Nov 2011, Neal Cardwell wrote:

> On Thu, Nov 17, 2011 at 12:14 AM, Ilpo Järvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > I think it's intentional. Because of receiver lying bandwidth cheats all
> > unlimited undos are bit dangerous.
> 
> If your concern is receivers lying, then there are other easy ways
> that a misbehaving receiver can get a sender to send too fast
> (e.g. cumulatively ACKing the highest sequence number seen,
> irrespective of holes). IMHO it would be a shame to penalize the vast
> majority of well-behaved users to plug one potential attack vector
> when there are other easy holes that an attacker would use.

I disagree... there is huge difference as the receiver then has to gamble 
with the reliability of the flow. DSACK attack is nasty in that that it
allows maintaining reliability while cheating bw.

> > Wouldn't it be enough if tcp max burst is increased to match IW (iirc we
> > had 3 still there as a magic number)?
> 
> Yes, tcp_max_burst() returns tp->reordering now. Changing it to return
> max(tp->reordering, TCP_INIT_CWND) sounds good to me. I think that's
> an excellent idea in any case, regardless of the outcome of this undo
> discussion.

Feel free to provide a patch then as I'm likely to forget :).

> However, I don't think this is sufficient for request-response
> protocols (e.g. RPC) running over long-lived connections over a path
> with a large bandwidth-delay product. In such cases, the cwnd will
> grow quite large (hundreds of packets). The DSACKs will often arrive
> after the entire response is sent, so that cwnd moderation will
> typically pull the cwnd down to 3 (or, with your proposal, 10)
> packets. IMHO that seems like an unnecessarily steep price to pay.

Sounds rather hypotetical scenario that you'd happen to get those DSACKs 
in such scenario... DSACK would only be sent when receiver and sender were 
out of sync due to heavy ACK loss that exceeds SACK redundancy or heavy 
reordering... the later prevents large window in the first place (or 
reordering has already adapted). Honestly I don't believe this is likely 
scenario. ...And FRTO handles single unnecesary rexmit in case of spurious 
RTO even before DSACK could be seen.

-- 
 i.
--8323329-1585358912-1321778313=:22397--
