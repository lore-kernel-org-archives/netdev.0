From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCHv2] sctp: Enforce retransmission limit during shutdown
Date: Wed, 6 Jul 2011 11:49:00 -0400
Message-ID: <20110706154900.GB17652@canuck.infradead.org>
References: <20110629143649.GC10085@canuck.infradead.org>
 <4E0B3DA1.9060200@hp.com>
 <20110629154814.GD10085@canuck.infradead.org>
 <4E0B4F71.4020108@hp.com>
 <20110630084933.GA24074@canuck.infradead.org>
 <4E0C8368.5090502@hp.com>
 <20110704135019.GA801@canuck.infradead.org>
 <4E146652.7010205@hp.com>
 <20110706141808.GA17652@canuck.infradead.org>
 <4E1471DC.2090407@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:42198 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585Ab1GFPtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 11:49:03 -0400
Content-Disposition: inline
In-Reply-To: <4E1471DC.2090407@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2011 at 10:31:56AM -0400, Vladislav Yasevich wrote:
> >>> +			 *
> >>> +			 * Allow the association to timeout if SHUTDOWN is
> >>> +			 * pending in case the receiver stays in zero window
> >>> +			 * mode forever.
> >>>  			 */
> >>>  			if (!q->asoc->peer.rwnd &&
> >>>  			    !list_empty(&tlist) &&
> >>> -			    (sack_ctsn+2 == q->asoc->next_tsn)) {
> >>> +			    (sack_ctsn+2 == q->asoc->next_tsn) &&
> >>> +			    !(q->asoc->state >= SCTP_STATE_SHUTDOWN_PENDING)) {
> >>
> >> Would a test for (q->asoc->state != SCTP_STATE_SHUTDOWN_PENDING) be clearer?  We only
> >> care about the PENDING state here.
> > 
> > I think SHUTDOWN_RECEIVED should also be included. We continue to transmit and
> > process SACKs after receiving a SHUTDOWN.
> 
> I am not sure about SHUTDOWN_RECEIVED.  If we received shutdown, then we are not in
> a 0 window situation.  Additionally, the sender of the SHUTDOWN started the GUARD timer
> and will abort after it expires.  So there is no special handling on our part.

Why can't we be in a 0 window situation? A well behaving sctp peer may not,
but we're on the Internet, everyone behaves at their worst :-)

Seriously, this would make for a simple dos. Establish a stream, don't ack any
data to make sure there is something on the retransmission queue of the peer.
Immediately shutdown the stream and ack any retransmission attempt with
a_rwnd=0 to keep the association around forever.

Starting the T5 SHUTDOWN GUARD timer is specified as MAY and not MUST so even in
a well behaving world we could not really rely on it.

Alternatively the peer could just be buggy as well.
