From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: fixes for DSACK-based undo of cwnd reduction during
 fast recovery
Date: Tue, 15 Nov 2011 04:05:57 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1111150333360.24223@melkinpaasi.cs.helsinki.fi>
References: <1320775631-16341-1-git-send-email-ncardwell@google.com> <20111114.152359.1131974895743731960.davem@davemloft.net> <CADVnQyn7czRocYV3-goTtwqCDg9MBv+bTHeZ-A8R4n45LH8L=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1632962702-1321320923=:24223"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, nanditad@google.com,
	ycheng@google.com, therbert@google.com
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36599 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755117Ab1KOCLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 21:11:01 -0500
In-Reply-To: <CADVnQyn7czRocYV3-goTtwqCDg9MBv+bTHeZ-A8R4n45LH8L=g@mail.gmail.com>
Content-ID: <alpine.DEB.2.00.1111150336270.24223@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1632962702-1321320923=:24223
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1111150336271.24223@melkinpaasi.cs.helsinki.fi>

On Mon, 14 Nov 2011, Neal Cardwell wrote:

> On Mon, Nov 14, 2011 at 3:23 PM, David Miller <davem@davemloft.net> wrote:
> > From: Neal Cardwell <ncardwell@google.com>
> > Date: Tue,  8 Nov 2011 13:07:11 -0500
> >
> >> (2)

When you need to say "fixes 1), 2), and 3)", please stop for a moment 
thinking if the fixes really need to be sent as one fix or 3 fixes (a 
series PATCH x/3, see netdev for examples). It would make review much 
simpler if unrelated fixes are not put together even if all of them 
would be needed to get DSACK working as intented.

> >>  When the ACK field is below snd_una (the "old_ack" goto label),
> >> process any DSACKs and try to send out more packets based on
> >> newly-SACKed packets.
> >
> > This seems dubious.

Indeed. However, there's nothing wrong in the processing of DSACKs nor 
SACKs in the given case but we lack call to tcp_fastretrans_alert. But the 
commit message does not say that, in fact, I failed to understand what 2) 
tried to say as I knew that DSACK and SACK processing itself is ok and 
done (it also mixes "DSACKs"/"SACKed" illogically). This commit message 
must be fixed so that guys who read it later won't get confused too. BUT
I'd on the same time split the whole fix to 3 different patches unless 
there's some very good reason why the changes are interlocked so that the 
splitting is not possible.

> > An older ACK should not have more uptodate SACK information than a newer
> > ACK.

This is not true with DSACK that are not cumulative. And also the 
reported SACK state is cumulative up to a limit.

> I grant that it is a rare corner case, but it is possible if there is
> reordering and packet loss in both directions.
> 
> In fact, AFAICT the code path to handle this corner case is already
> there: AFAICT we call tcp_sacktag_write_queue() in the old_ack code
> path exactly because it is possible for old ACKs to carry SACK ranges
> that we haven't seen yet.

I agree. ...And also DSACKs that can only be seen in that particular ACK.

> Let me try to lay out a specific example:
> 
> Suppose a sender sends packets 1-12, and there is lots of loss and
> reordering in both directions.
> 
> Suppose the receiver sends the following ACKs with SACK blocks, in the
> following order (using packet numbers rather than sequence numbers):
> 
> (1) ack 1, sack <3-4>
> (2) ack 1, sack <3-4 6>
> (3) ack 1, sack <3-4 6 8>
> (4) ack 1, sack <3-4 6 8 10>
> (5) ack 1, sack <6 8 10 12>
> (6) ack 2, sack <6 8 10 12>
> 
> Note that starting at ACK (5) the receiver is limited by the fact that
> TCP options can only hold 4 SACK ranges, so the SACK for 3-4 "falls
> off" the SACK block set.
> 
> Now suppose the ACKs are reordered, and some are dropped, so that the
> sender receives the ACKs in this order:
> 
> (6) ack 2, sack <6 8 10 12>
> (1) ack 1, sack <3-4>
> 
> The arrival of (6) advances snd_una to 2. Now the question is what to
> do when (1), with an ACK field below snd_una, arrives at the
> sender. The existing code tags packets 3-4 as SACKed, but does not use
> this newly SACK-tagged data to send out new data. This commit proposes 
> to use the newly SACK-tagged 3-4 to send out new data.

Contrary to your commit message, new data sending is already done outside 
of tcp_ack() in tcp_data_snd_check? ...It's tcp_fastretrans_alert call 
that is lacking so no rexmits could be done currently?

In addition, this given scenarios was not DSACK related!?! I think your 
commit message is just bogus discussing (only) DSACK processing for this 
case.


-- 
 i.
--8323329-1632962702-1321320923=:24223--
