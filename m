From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 03/10] tipc: sk_recv_queue size check only for
 connectionless sockets
Date: Mon, 10 Dec 2012 09:22:54 -0500
Message-ID: <20121210142254.GA23628@hmsreliant.think-freely.org>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
 <1354890498-6448-4-git-send-email-paul.gortmaker@windriver.com>
 <20121207192030.GA30339@hmsreliant.think-freely.org>
 <50C26DF3.90409@ericsson.com>
 <20121209165020.GA4362@neilslaptop.think-freely.org>
 <50C580E6.7030905@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36501 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab2LJOXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 09:23:13 -0500
Content-Disposition: inline
In-Reply-To: <50C580E6.7030905@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 10, 2012 at 02:27:50PM +0800, Ying Xue wrote:
> Neil Horman wrote:
> >On Fri, Dec 07, 2012 at 05:30:11PM -0500, Jon Maloy wrote:
> >>On 12/07/2012 02:20 PM, Neil Horman wrote:
> >>>On Fri, Dec 07, 2012 at 09:28:11AM -0500, Paul Gortmaker wrote:
> >>>>From: Ying Xue <ying.xue@windriver.com>
> >>>>
> >>>>The sk_receive_queue limit control is currently performed for
> >>>>all arriving messages, disregarding socket and message type.
> >>>>But for connected sockets this check is redundant, since the protocol
> >>>>flow control already makes queue overflow impossible.
> >>>>
> >>>Can you explain where that occurs?
> >>It happens in the functions port_dispatcher_sigh() and
> >>tipc_send(), among other places. Both are to be found in the
> >>file port.c, which was supposed to contain the 'generic' (i.e.,
> >>API independent) part of the send/receive code.
> >>Now that we have only one API left, the socket API, we are
> >>planning to merge the code in socket.c and port.c, and get rid
> >>of some code overhead.
> >>
> >>The flow control in TIPC is message based, where the sender
> >>requires to receive an explicit acknowledge message for each 512
> >>message the receiver reads to user space.
> >>If the sender has more than 1024 messages outstanding without having
> >>received an acknowledge he will be suspended or receive EAGAIN
> >>until he does.
> >>The plan going forward is to replace this mechanism with a more
> >>standard looking byte based flow control, while maintaining
> >>backwards compatibility.
> >>
> >Ok, That makes more sense, thank you.  Although I still don't think this is
> >safe (but the problem may not be solely introduced by this patch).  Using a
> >global limit that assumes the sender will block when the congestion window is
> >reached just doesn't seem sane to me.  It clearly works with the Linux
> >implementation, as it conforms to your expectations, but an alternate
> >implementation could create a DOS situation by simply ignoring the window limit,
> >and continuing to send.  I see that we drop frames over the global limit in
> >filter_rcv, but the check in rx_queue_full bumps up that limit based on the
> >value of msg_importance(msg), but that threshold is ignored if the value of
> >msg_importance is invalid.  All a sender needs to do is flood a receiver with
> >frames containing an invalid set of message importance bits, and you will queue
> >frames indefinately.  In fact that will also happen if you send message of
> >CRITICAL importance as well, so you don't even need to supply an invalid value
> >here.
> >
> 
> You are absolutely right. I will correct these drawbacks in next version.
> 
> >>>I see where the tipc dispatch function calls
> >>>sk_add_backlog, which checks the per socket recieve queue (regardless of weather
> >>>the receiving socket is connection oriented or connectionless), but if the
> >>>receiver doesn't call receive very often, This just adds a check against your
> >>>global limit, doing nothing for your per-socket limits.
> >>OVERLOAD_LIMIT_BASE is tested against a per-socket message counter, so it _is_
> >>our per-socket limit. In fact, TIPC connectionless overflow
> >>control currently is a kind of a hybrid, based on a message
> >>counter when the socket is not locked, and based on
> >>sk_rcv_queue's byte limit when a message has to be added to the
> >>backlog.
> >>We are planning to fix this inconsistency too.
> >Good, thank you,  that was seeming quite wrong to me.
> >
> >> In fact it seems to
> >>>repeat the same check twice, as in the worst case of the incomming message being
> >>>TIPC_LOW_IMPORTANCE, its just going to check that the global limit is exactly
> >>>OVERLOAD_LIMIT_BASE/2 again.
> >>Yes, you are right. The intention is that only the first test,
> >>if (unlikely(recv_q_len >= (OVERLOAD_LIMIT_BASE / 2)){..}
> >>will be run for the vast majority of messages, since we must assume
> >>that there is no overload most of the time.
> >>An inelegant optimization, perhaps, but not logically wrong.
> >No, not logically wrong, but not an optimization either.  With this change,
> >your only use of rx_queue_full passes OVERLOAD_LIMIT_BASE/2 as the base value to
> >rx_queue_full, and then you do some multiplication based on that.  If you really
> >want to optimize this, leave OVERLOAD_LIMIT_BASE where it is (rather than
> >doubling it like this patch series does), mark rx_queue_full as inline, and just
> >pass OVERLOAD_LIMIT_BASE as the argument, it will save you a division opration,
> >the conditional branch and a call instruction.  If you add a multiplication
> >factor table, you can eliminate the if/else clauses in rx_queue_full as well.
> >
> 
> Good suggestion with a factor table. Maybe it's unnecessary to
> explicitly mark rx_queue_full as inline. Currently it sounds like we
> let complier decide whether a function is defined as inline or not.
> 
Thats correct, the compiler usually decides if something should be inlined
(unless you use the __always_inline) attribute.  In this case, given a single
call site, it most like will just inline anyway.  But if you're interested in
optimizing here, it might be worth taking the extra steps to make sure.  In
fact, since this is your only call site, it may be worthwhile to just remove the
function entirely, and manually inline the check.
Neil

> Regards,
> Ying
> 
> >Neil
> >
> >>///jon
> >>
> >>>Neil
> >>>
> >>>--
> >>>To unsubscribe from this list: send the line "unsubscribe netdev" in
> >>>the body of a message to majordomo@vger.kernel.org
> >>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
> 
