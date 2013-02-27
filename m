From: "Roberts, Lee A." <lee.roberts@hp.com>
Subject: RE: [PATCH 4/4] sctp: fix association hangs due to partial delivery
 errors
Date: Wed, 27 Feb 2013 04:38:38 +0000
Message-ID: <D64EC45690EF85409BA6C4730E0162244310EDA1@G4W3231.americas.hpqcorp.net>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
 <1361889376-22171-5-git-send-email-lee.roberts@hp.com>
 <512D70D0.1060208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "vyasevic@redhat.com" <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:5616 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab3B0Ekj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 23:40:39 -0500
In-Reply-To: <512D70D0.1060208@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad,

> -----Original Message-----
> From: Vlad Yasevich [mailto:vyasevic@redhat.com]
> Sent: Tuesday, February 26, 2013 7:35 PM
> To: Roberts, Lee A.
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH 4/4] sctp: fix association hangs due to partial delivery errors
> 
> On 02/26/2013 09:36 AM, Lee A. Roberts wrote:
> > From: "Lee A. Roberts" <lee.roberts@hp.com>
> >
> > Resolve SCTP association hangs observed during SCTP stress
> > testing.  Observable symptoms include communications hangs
> > with data being held in the association reassembly and/or lobby
> > (ordering) queues.  Close examination of reassembly queue shows
> > missing packets.
> >
> > In sctp_ulpq_tail_data(), use return values 0,1 to indicate whether
> > a complete event (with MSG_EOR set) was delivered.  A return value
> > of -ENOMEM continues to indicate an out-of-memory condition was
> > encountered.
> >
> > In sctp_ulpq_retrieve_partial() and sctp_ulpq_retrieve_first(),
> > correct message reassembly logic for SCTP partial delivery.
> > Change logic to ensure that as much data as possible is sent
> > with the initial partial delivery and that following partial
> > deliveries contain all available data.
> >
> > In sctp_ulpq_partial_delivery(), attempt partial delivery only
> > if the data on the head of the reassembly queue is at or before
> > the cumulative TSN ACK point.
> >
> > In sctp_ulpq_renege(), use the modified return values from
> > sctp_ulpq_tail_data() to choose whether to attempt partial
> > delivery or to attempt to drain the reassembly queue as a
> > means to reduce memory pressure.  Remove call to
> > sctp_tsnmap_mark(), as this is handled correctly in call to
> > sctp_ulpq_tail_data().
> >
> > Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
> > ---
> >   net/sctp/ulpqueue.c |   54 ++++++++++++++++++++++++++++++++++++++++-----------
> >   1 file changed, 43 insertions(+), 11 deletions(-)
> >
> > diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
> > index f221fbb..482e3ea 100644
> > --- a/net/sctp/ulpqueue.c
> > +++ b/net/sctp/ulpqueue.c
> > @@ -106,6 +106,7 @@ int sctp_ulpq_tail_data(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
> >   {
> >   	struct sk_buff_head temp;
> >   	struct sctp_ulpevent *event;
> > +	int event_eor = 0;
> >
> >   	/* Create an event from the incoming chunk. */
> >   	event = sctp_ulpevent_make_rcvmsg(chunk->asoc, chunk, gfp);
> > @@ -127,10 +128,12 @@ int sctp_ulpq_tail_data(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
> >   	/* Send event to the ULP.  'event' is the sctp_ulpevent for
> >   	 * very first SKB on the 'temp' list.
> >   	 */
> > -	if (event)
> > +	if (event) {
> > +		event_eor = (event->msg_flags & MSG_EOR) ? 1 : 0;
> >   		sctp_ulpq_tail_event(ulpq, event);
> > +	}
> 
> You can re-use the check just before this one to catch the EOR
> condition.   You already do
> 	if ((event) && (event->msg_flags & MSG_EOR)){
> 
> right after you try to get a reassembled event.
> 
> Everything else looks good.
> -vlad
> 
It depends on what we want the return value to mean.  In the case where we've reneged
to be able to put in a packet, we know that the incoming packet is the next one we're
looking for.  In which case, the earlier test is correct, since this will be the next
event.

In general, the event that's being passed to sctp_ulpq_order() might not be the
next event.  In that case, sctp_ulpq_order() will call sctp_ulpq_store_ordered()
and return NULL.  Only at the last "if (event)" can we really be sure that an event
is being passed to the ULP.

In general, do we want to return 1 if a complete event is actually passed to the ULP?
Or, do we want to return 1 if we've seen a complete event come from reassembly?

                                                    - Lee

> >
> > -	return 0;
> > +	return event_eor;
> >   }
> >
> >   /* Add a new event for propagation to the ULP.  */
> > @@ -540,14 +543,19 @@ static struct sctp_ulpevent *sctp_ulpq_retrieve_partial(struct sctp_ulpq
> *ulpq)
> >   		ctsn = cevent->tsn;
> >
> >   		switch (cevent->msg_flags & SCTP_DATA_FRAG_MASK) {
> > +		case SCTP_DATA_FIRST_FRAG:
> > +			if (!first_frag)
> > +				return NULL;
> > +			goto done;
> >   		case SCTP_DATA_MIDDLE_FRAG:
> >   			if (!first_frag) {
> >   				first_frag = pos;
> >   				next_tsn = ctsn + 1;
> >   				last_frag = pos;
> > -			} else if (next_tsn == ctsn)
> > +			} else if (next_tsn == ctsn) {
> >   				next_tsn++;
> > -			else
> > +				last_frag = pos;
> > +			} else
> >   				goto done;
> >   			break;
> >   		case SCTP_DATA_LAST_FRAG:
> > @@ -651,6 +659,14 @@ static struct sctp_ulpevent *sctp_ulpq_retrieve_first(struct sctp_ulpq *ulpq)
> >   			} else
> >   				goto done;
> >   			break;
> > +
> > +		case SCTP_DATA_LAST_FRAG:
> > +			if (!first_frag)
> > +				return NULL;
> > +			else
> > +				goto done;
> > +			break;
> > +
> >   		default:
> >   			return NULL;
> >   		}
> > @@ -1025,16 +1041,28 @@ void sctp_ulpq_partial_delivery(struct sctp_ulpq *ulpq,
> >   	struct sctp_ulpevent *event;
> >   	struct sctp_association *asoc;
> >   	struct sctp_sock *sp;
> > +	__u32 ctsn;
> > +	struct sk_buff *skb;
> >
> >   	asoc = ulpq->asoc;
> >   	sp = sctp_sk(asoc->base.sk);
> >
> >   	/* If the association is already in Partial Delivery mode
> > -	 * we have noting to do.
> > +	 * we have nothing to do.
> >   	 */
> >   	if (ulpq->pd_mode)
> >   		return;
> >
> > +	/* Data must be at or below the Cumulative TSN ACK Point to
> > +	 * start partial delivery.
> > +	 */
> > +	skb = skb_peek(&asoc->ulpq.reasm);
> > +	if (skb != NULL) {
> > +		ctsn = sctp_skb2event(skb)->tsn;
> > +		if (!TSN_lte(ctsn, sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map)))
> > +			return;
> > +	}
> > +
> >   	/* If the user enabled fragment interleave socket option,
> >   	 * multiple associations can enter partial delivery.
> >   	 * Otherwise, we can only enter partial delivery if the
> > @@ -1077,12 +1105,16 @@ void sctp_ulpq_renege(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
> >   	}
> >   	/* If able to free enough room, accept this chunk. */
> >   	if (chunk && (freed >= needed)) {
> > -		__u32 tsn;
> > -		tsn = ntohl(chunk->subh.data_hdr->tsn);
> > -		sctp_tsnmap_mark(&asoc->peer.tsn_map, tsn, chunk->transport);
> > -		sctp_ulpq_tail_data(ulpq, chunk, gfp);
> > -
> > -		sctp_ulpq_partial_delivery(ulpq, gfp);
> > +		int retval;
> > +		retval = sctp_ulpq_tail_data(ulpq, chunk, gfp);
> > +		/*
> > +		 * Enter partial delivery if chunk has not been
> > +		 * delivered; otherwise, drain the reassembly queue.
> > +		 */
> > +		if (retval <= 0)
> > +			sctp_ulpq_partial_delivery(ulpq, chunk, gfp);
> > +		else if (retval == 1)
> > +			sctp_ulpq_reasm_drain(ulpq);
> >   	}
> >
> >   	sk_mem_reclaim(asoc->base.sk);
> >
