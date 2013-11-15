From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: sctp: recover a tranport when an ack comes
Date: Fri, 15 Nov 2013 15:25:36 -0500
Message-ID: <20131115202536.GD29877@hmsreliant.think-freely.org>
References: <1384461624-17636-1-git-send-email-changxiangzhong@gmail.com>
 <5285884F.8030907@gmail.com>
 <20131115123055.GA29877@hmsreliant.think-freely.org>
 <5286291A.7060507@gmail.com>
 <20131115145609.GC29877@hmsreliant.think-freely.org>
 <52867D2E.2090907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dreibh@simula.no, ernstgr@simula.no
To: Chang <changxiangzhong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35896 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453Ab3KOUZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 15:25:59 -0500
Content-Disposition: inline
In-Reply-To: <52867D2E.2090907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 15, 2013 at 08:59:42PM +0100, Chang wrote:
> I've tried to catch you guys up~
> 
> Here's a quick question:
> 
> Where are the default [transport->pf_retrans] and
> [transport->pathmaxrtx] set? I could figure out that they could be
> set through setsockopt(SCTP_PEER_ADDR_THLDS, ...) (but it seems like
> the SCTP library has not supported such option yet, maybe that's due
Yeah, it looks like Daniel hasn't implemented option 31 yet.  You could
certainly issue that socket option on your own thought, without the help of the
library.

> to my library is out of date). So by default both of the two
> threshold are zero.
> 
Thats not tre, pathmaxrtx should be initalized to 5, which is what the per-net
sysctl get initalized to in sctp_net_init.

> Here's my question: Does it go conflict with "the recommended value
> for Path.Max.Retrans in the standard is 5"?
> 
pathmaxrtx is initalized to 5 in sctp_init_sock, so we're in compliance with the
RFC hre.

> Thanks!
> 
> On 11/15/2013 03:56 PM, Neil Horman wrote:
> >On Fri, Nov 15, 2013 at 09:00:58AM -0500, Vlad Yasevich wrote:
> >>On 11/15/2013 07:30 AM, Neil Horman wrote:
> >>>On Thu, Nov 14, 2013 at 09:34:55PM -0500, Vlad Yasevich wrote:
> >>>>On 11/14/2013 03:40 PM, Chang Xiangzhong wrote:
> >>>>>Expected Behavior:
> >>>>>When hearing an ack from a tranport/path, set its state to normal/on if it's
> >>>>>in abnormal(__partial_failure__ or inactive) state.
> >>>>>
> >>>>>state machine of tranport->state
> >>>>>Whenever a T3_RTX timer expires, then transport->error_count++.
> >>>>>When (association->pf_retrans < transport->error_count < tranport->pathmaxrtx)
> >>>>>	transport->state = SCTP_PF //partial failure
> >>>>>
> >>>>>When a heartbeat-ack comes or conventional ack acknowledged its availability,
> >>>>>	transport->state = SCTP_ON
> >>>>>
> >>>>>Signed-off-by: Chang Xiangzhong <changxiangzhong@gmail.com>
> >>>>>Fixes: 5aa93bcf66f ("sctp: Implement quick failover draft from tsvwg")
> >>>>I don't think this is right.  The spec states:
> >>>>  8.  ACKs for retransmissions do not transition a PF destination back
> >>>>        to Active state, since a sender cannot disambiguate whether the
> >>>>        ack was for the original transmission or the retransmission(s).
> >>>>
> >>>>
> >>>>Now, the proper way to this would would be modify
> >>>>sctp_assoc_control_transport() to transition the transport state to
> >>>>ACTIVE if it was PF transport that was chosen to send data.
> >>>>
> >>>>-vlad
> >>>>
> >>>I agree, this patch doesn't agree with the spec, the only time we transition
> >>>from PF to ACTIVE should be on receipt of ack of new data.
> >>
> >>You mean HB ACK, right?  The 02 spec that see on the ietf site doesn't
> >>mention anything about transition on SACKs.  Also, there is no way to
> >>tell right now if the ack is for new or retransmitted data.  We could
> >>mark chunks that are retransmitted though.
> >>
> >Yes, sorry I wasn't clear, I was speaknig about HB Acks.
> >
> >>>I'm not even sure if
> >>>we should allow PF transports to be selected to send new data.  Currently a
> >>>potentially failed transport will get ignored when specified, and the stack will
> >>>use the active path in its place.  Only if all transports are PF will a PF
> >>>transport be chosen.
> >>Not even that :(.  If all transports are PF, we are going to camp on
> >>the primary path instead of choosing a PF transport with the lowest
> >>error count.
> >>
> >Yes, we don't do the smallest error count check, though I have to wonder if
> >thats really worthwhile.  If all your transports are PF, you're a step away from
> >a connection reset anyway.
> >Neil
> >
> >>-vlad
> >>
> >>>Neil
> >>>
> >>>>>---
> >>>>>  net/sctp/outqueue.c |    1 +
> >>>>>  1 file changed, 1 insertion(+)
> >>>>>
> >>>>>diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> >>>>>index 94df758..2557fa5 100644
> >>>>>--- a/net/sctp/outqueue.c
> >>>>>+++ b/net/sctp/outqueue.c
> >>>>>@@ -1517,6 +1517,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
> >>>>>  			 * active if it is not so marked.
> >>>>>  			 */
> >>>>>  			if ((transport->state == SCTP_INACTIVE ||
> >>>>>+			     transport->state == SCTP_PF ||
> >>>>>  			     transport->state == SCTP_UNCONFIRMED) &&
> >>>>>  			    sctp_cmp_addr_exact(&transport->ipaddr, saddr)) {
> >>>>>  				sctp_assoc_control_transport(
> >>>>>
> >>>>
> >>--
> >>To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> >>the body of a message to majordomo@vger.kernel.org
> >>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> 
> 
