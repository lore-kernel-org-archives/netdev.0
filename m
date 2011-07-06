From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCHv2] sctp: Enforce retransmission limit during shutdown
Date: Wed, 6 Jul 2011 10:18:08 -0400
Message-ID: <20110706141808.GA17652@canuck.infradead.org>
References: <20110629135704.GB10085@canuck.infradead.org>
 <4E0B3491.1060603@hp.com>
 <20110629143649.GC10085@canuck.infradead.org>
 <4E0B3DA1.9060200@hp.com>
 <20110629154814.GD10085@canuck.infradead.org>
 <4E0B4F71.4020108@hp.com>
 <20110630084933.GA24074@canuck.infradead.org>
 <4E0C8368.5090502@hp.com>
 <20110704135019.GA801@canuck.infradead.org>
 <4E146652.7010205@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:48863 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab1GFOSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 10:18:11 -0400
Content-Disposition: inline
In-Reply-To: <4E146652.7010205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2011 at 09:42:42AM -0400, Vladislav Yasevich wrote:
> On a related note, were you going to re-submit the receiver patch as well?

Yes

> On 07/04/2011 09:50 AM, Thomas Graf wrote:
> > +			 * retransmission limit. Stop that timer as soon
> > +			 * as the receiver acknowledged any data.
> > +			 */
> > +			t = &asoc->timers[SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD];
> > +			if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING &&
> > +			    timer_pending(t) && del_timer(t))
> > +				sctp_association_put(asoc);
> > +
> 
> I believe 'state' and 'timers' are in different cache lines, so might be able to optimize it
> a little by checking the state prior to referencing timers array.

gcc should do that but I'm fine with changing it.

> > +			 *
> > +			 * Allow the association to timeout if SHUTDOWN is
> > +			 * pending in case the receiver stays in zero window
> > +			 * mode forever.
> >  			 */
> >  			if (!q->asoc->peer.rwnd &&
> >  			    !list_empty(&tlist) &&
> > -			    (sack_ctsn+2 == q->asoc->next_tsn)) {
> > +			    (sack_ctsn+2 == q->asoc->next_tsn) &&
> > +			    !(q->asoc->state >= SCTP_STATE_SHUTDOWN_PENDING)) {
> 
> Would a test for (q->asoc->state != SCTP_STATE_SHUTDOWN_PENDING) be clearer?  We only
> care about the PENDING state here.

I think SHUTDOWN_RECEIVED should also be included. We continue to transmit and
process SACKs after receiving a SHUTDOWN.

> > +	 * Although RFC2960 and RFC4460 specify that the overall error
> > +	 * count must be cleared when a HEARTBEAT ACK is received this
> > +	 * behaviour may prevent the maximum retransmission count from
> > +	 * being reached while in SHUTDOWN. If the peer keeps its window
> > +	 * closed not acknowledging any outstanding TSN we may rely on
> > +	 * reaching the max_retrans limit via the T3-rtx timer to close
> > +	 * the association which will never happen if the error count is
> > +	 * reset every heartbeat interval.
> > +	 */
> > +	if (!(t->asoc->state >= SCTP_STATE_SHUTDOWN_PENDING))
> > +		t->asoc->overall_error_count = 0;
> 
> Same here.  We only care about the PENDING state. Also, please fix the comment to reflect
> the code.

Agreed.

> > +		if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
> > +			/*
> > +			 * We are here likely because the receiver had its rwnd
> > +			 * closed for a while and we have not been able to
> > +			 * transmit the locally queued data within the maximum
> > +			 * retransmission attempts limit.  Start the T5
> > +			 * shutdown guard timer to give the receiver one last
> > +			 * chance and some additional time to recover before
> > +			 * aborting.
> > +			 */
> > +			sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
> > +				SCTP_TO(SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD));
> 
> This is bug.  You don't want to restart the timer every time you hit a T3-timeout.  Remember, since you fall
> through here, you do another retransmission and schedule another timeout.  So next time the timeout happens,
> you'll restart the SHUTDOWN_GUARD, which is not what you want.
> 
> We want to start it once if it isn't pending, and leave it running without restart if it is already pending.

Doh, absolutely. The timer_pending() check got lost between testing and submission.

