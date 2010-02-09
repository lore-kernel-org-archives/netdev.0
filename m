From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 0/3][v2] tcp: fix ICMP-RTO war
Date: Tue, 9 Feb 2010 14:37:38 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1002091433230.7063@wel-95.cs.helsinki.fi>
References: <4B635E17.406@tvk.rwth-aachen.de> <20100131.233338.254690877.davem@davemloft.net> <op.u7s6j0qup498uc@nexus> <4B708913.906@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54446 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063Ab0BIMhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 07:37:39 -0500
In-Reply-To: <4B708913.906@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Feb 2010, Damian Lukowski wrote:

> Damian Lukowski schrieb:
> > Am 01.02.2010, 08:33 Uhr, schrieb David Miller <davem@davemloft.net>:
> > 
> >> From: Damian Lukowski <damian@tvk.rwth-aachen.de>
> >> Date: Fri, 29 Jan 2010 23:15:51 +0100
> >>
> >>> This patches fix the current RTO calculation routine, when
> >>> srtt and rttvar are zero, yielding an RTO of zero
> >>> Under some circumstances, TCPs srtt and rttvar are zero,
> >>> yielding a calculated RTO of zero.
> >>> This is particularly unfortunate for ICMP based RTO recalculation
> >>> as introduced in f1ecd5d9e736660 (Revert Backoff [v3]: Revert RTO
> >>> on ICMP destination unreachable), as it results in RTO retransmission
> >>> flooding.
> >>>
> >>> Thanks to Ilpo Jarvinen for providing debug patches and to
> >>> Denys Fedoryshchenko for reporting and testing.
> >>>
> >>> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
> >>
> >> I still haven't seen a detailed enough analysis of why these
> >> tiny RTOs can come to exist in the first place.
> >>
> >> Please show me a list of events, function by function, the value of
> >> relevant variables and per-socket TCP state, in the TCP stack, that
> >> show how this ends up happening.
> >>
> >> Thanks for all of your work on this so far.
> > 
> > I might have figured it out, but could not verify it, so maybe you can
> > comment my thought.
> > 
> > When a listening TCP receives a SYN, it will send a SYN+ACK
> > and wait for an ACK to complete the handshake.
> > Look at tcp_rcv_state_process::step 5::case SYN_RECV::acceptable
> > and the code after the comment "tcp_ack considers this ACK as duplicate
> > and does not calculate rtt".
> > 
> > If the connecting client has disabled timestamps, the rtt statistics
> > won't be updated here, while the state is changed above.
> > I printk'ed at the very end of TCP_SYN_RECV and got the following:
> > state 1 (ESTABLISHED), srtt 0, rttvar 0.
> > 
> > So my suspicion is: If connectivity breaks right after a listening TCP
> > has completed the handshake without timestamps, and the listening TCP
> > sends data after establishing the connection, we will get the observed
> > behaviour.
> 
> Just verified that by dropping pure ACKs coming from the originally
> listening TCP using iptables.

Isn't that "tcp_ack considers" comment like this: we have bug elsewhere in 
the code but workaround it here, at least for some of the cases? (I'd put 
it other way around: but alas, only for part of the cases.) ...It sound 
like that to me. What exactly is the reason why rtt shouldn't be 
calculated/initialized on such ACK, anything I'm missing?

-- 
 i.
