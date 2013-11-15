From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: sctp: recover a tranport when an ack comes
Date: Fri, 15 Nov 2013 07:30:55 -0500
Message-ID: <20131115123055.GA29877@hmsreliant.think-freely.org>
References: <1384461624-17636-1-git-send-email-changxiangzhong@gmail.com>
 <5285884F.8030907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chang Xiangzhong <changxiangzhong@gmail.com>, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dreibh@simula.no, ernstgr@simula.no
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59539 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157Ab3KOMbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 07:31:07 -0500
Content-Disposition: inline
In-Reply-To: <5285884F.8030907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 09:34:55PM -0500, Vlad Yasevich wrote:
> On 11/14/2013 03:40 PM, Chang Xiangzhong wrote:
> >Expected Behavior:
> >When hearing an ack from a tranport/path, set its state to normal/on if it's
> >in abnormal(__partial_failure__ or inactive) state.
> >
> >state machine of tranport->state
> >Whenever a T3_RTX timer expires, then transport->error_count++.
> >When (association->pf_retrans < transport->error_count < tranport->pathmaxrtx)
> >	transport->state = SCTP_PF //partial failure
> >
> >When a heartbeat-ack comes or conventional ack acknowledged its availability,
> >	transport->state = SCTP_ON
> >
> >Signed-off-by: Chang Xiangzhong <changxiangzhong@gmail.com>
> >Fixes: 5aa93bcf66f ("sctp: Implement quick failover draft from tsvwg")
> 
> I don't think this is right.  The spec states:
>  8.  ACKs for retransmissions do not transition a PF destination back
>        to Active state, since a sender cannot disambiguate whether the
>        ack was for the original transmission or the retransmission(s).
> 
> 
> Now, the proper way to this would would be modify
> sctp_assoc_control_transport() to transition the transport state to
> ACTIVE if it was PF transport that was chosen to send data.
> 
> -vlad
> 
I agree, this patch doesn't agree with the spec, the only time we transition
from PF to ACTIVE should be on receipt of ack of new data.  I'm not even sure if
we should allow PF transports to be selected to send new data.  Currently a
potentially failed transport will get ignored when specified, and the stack will
use the active path in its place.  Only if all transports are PF will a PF
transport be chosen.
Neil

> >---
> >  net/sctp/outqueue.c |    1 +
> >  1 file changed, 1 insertion(+)
> >
> >diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> >index 94df758..2557fa5 100644
> >--- a/net/sctp/outqueue.c
> >+++ b/net/sctp/outqueue.c
> >@@ -1517,6 +1517,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
> >  			 * active if it is not so marked.
> >  			 */
> >  			if ((transport->state == SCTP_INACTIVE ||
> >+			     transport->state == SCTP_PF ||
> >  			     transport->state == SCTP_UNCONFIRMED) &&
> >  			    sctp_cmp_addr_exact(&transport->ipaddr, saddr)) {
> >  				sctp_assoc_control_transport(
> >
> 
> 
