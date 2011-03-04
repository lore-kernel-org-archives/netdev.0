From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: fix the fast retransmit limit
Date: Fri, 04 Mar 2011 09:09:57 -0500
Message-ID: <1299247797.2581.18.camel@oscar>
References: <4D6F5F83.705@cn.fujitsu.com> <4D6FA2D3.501@hp.com>
	 <4D707CB6.8020502@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>,
	Mingyuan Zhu <liyha.zhu@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:43671 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753267Ab1CDOKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 09:10:00 -0500
In-Reply-To: <4D707CB6.8020502@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-04 at 13:46 +0800, Wei Yongjun wrote:
> > On 03/03/2011 04:29 AM, Wei Yongjun wrote:
> >> If chunk is still lost after fast retransmit, SCTP stack will
> >> never allow the second fast retransmit of this chunk, even if
> >> the peer need we do this. This chunk will be retransmit until
> >> the rtx timeout. This limit is introduce by the following patch:
> >>   sctp: reduce memory footprint of sctp_chunk structure
> >>   (c226ef9b83694311327f3ab0036c6de9c22e9daf)
> >>
> >> This patch revert this limit and removed useless SCTP_DONT_FRTX.
> > NACK.  Please read the spec and how fast recovery is specified.
> 
> 
> RFC 7.2.4. Fast Retransmit on Gap Reports said:
> 5) Mark the DATA chunk(s) as being fast retransmitted and thus
> ineligible for a subsequent Fast Retransmit. Those TSNs marked
> for retransmission due to the Fast-Retransmit algorithm that did
> not fit in the sent datagram carrying K other TSNs are also
> marked as ineligible for a subsequent Fast Retransmit. However,
> as they are marked for retransmission they will be retransmitted
> later on as soon as cwnd allows.
> 
> So we can treat this chunk can be Fast Retransmit again if not in
> fast recovery?

Right, but you are in Fast Recovery until Cumulative TSN moves
past fast recovery exit point.  In other words, you can't exit
fast recovery until the missing chunk has been acknowledged.

The algorithm states that you can Fast Retransmit a chunk once.
If the Fast RTX chunk is lost, you revert to time-outs for that chunk.

Now, there are some improvements to this algorithm that have been
researched, but not standardized.  One such improvement is to allow
subsequent FAST-RTXs once the New TSN in SACK reaches the fast recovery
exit point (meaning, that all in-flight data has been SACKed, but the
chunk is still missing).  Once that happens, you can start counting
misses again and FAST-RTX when 3 more misses occur.  This will improve
the performance of FAST-RTX.

The reason we don't automatically allow additional miss indications to
count is because you may have a lot of chunks in flight.  That means
that you end up doing FAST-RTX too often.  The idea is to allow the
retransmitted chunk to get there.

-vlad
> 
> > -vlad
> >
> >> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> >> ---
> >>  include/net/sctp/structs.h |    1 -
> >>  net/sctp/outqueue.c        |    4 ++--
> >>  2 files changed, 2 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> >> index cc9185c..82a0f84 100644
> >> --- a/include/net/sctp/structs.h
> >> +++ b/include/net/sctp/structs.h
> >> @@ -751,7 +751,6 @@ struct sctp_chunk {
> >>  
> >>  #define SCTP_CAN_FRTX 0x0
> >>  #define SCTP_NEED_FRTX 0x1
> >> -#define SCTP_DONT_FRTX 0x2
> >>  	__u16	rtt_in_progress:1,	/* This chunk used for RTT calc? */
> >>  		has_tsn:1,		/* Does this chunk have a TSN yet? */
> >>  		has_ssn:1,		/* Does this chunk have a SSN yet? */
> >> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> >> index 8c6d379..7ed5862 100644
> >> --- a/net/sctp/outqueue.c
> >> +++ b/net/sctp/outqueue.c
> >> @@ -657,7 +657,7 @@ redo:
> >>  			 * after it is retransmitted.
> >>  			 */
> >>  			if (chunk->fast_retransmit == SCTP_NEED_FRTX)
> >> -				chunk->fast_retransmit = SCTP_DONT_FRTX;
> >> +				chunk->fast_retransmit = SCTP_CAN_FRTX;
> >>  
> >>  			q->empty = 0;
> >>  			break;
> >> @@ -679,7 +679,7 @@ redo:
> >>  	if (rtx_timeout || fast_rtx) {
> >>  		list_for_each_entry(chunk1, lqueue, transmitted_list) {
> >>  			if (chunk1->fast_retransmit == SCTP_NEED_FRTX)
> >> -				chunk1->fast_retransmit = SCTP_DONT_FRTX;
> >> +				chunk1->fast_retransmit = SCTP_CAN_FRTX;
> >>  		}
> >>  	}
> >>  
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 



