From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 4/4] sctp: fix association hangs due to partial delivery
 errors
Date: Thu, 21 Feb 2013 15:25:51 -0500
Message-ID: <512682CF.4000609@gmail.com>
References: <D64EC45690EF85409BA6C4730E0162244310DF18@G4W3231.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Roberts, Lee A." <lee.roberts@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D64EC45690EF85409BA6C4730E0162244310DF18@G4W3231.americas.hpqcorp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/21/2013 11:45 AM, Roberts, Lee A. wrote:
> From: Lee A. Roberts <lee.roberts@hp.com>
>
> Resolve SCTP association hangs observed during SCTP stress
> testing.  Observable symptoms include communications hangs
> with data being held in the association reassembly and/or lobby
> (ordering) queues.  Close examination of reassembly queue shows
> missing packets.
>
> In sctp_ulpq_retrieve_partial() and sctp_ulpq_retrieve_first(),
> correct message reassembly logic for SCTP partial delivery.
> Change logic to ensure that as much data as possible is sent
> with the initial partial delivery and that following partial
> deliveries contain all available data.
>
> In sctp_ulpq_partial_delivery(), attempt partial delivery only
> if the data on the head of the reassembly queue is at or before
> the cumulative TSN ACK point.
>
> In sctp_ulpq_renege(), adjust logic to enter partial delivery
> only if the incoming chunk remains on the reassembly queue
> after processing by sctp_ulpq_tail_data().  If the incoming
> chunk has been delivered and data remains on the reassembly
> queue, attempt to drain the queue.  Remove call to
> sctp_tsnmap_mark(), as this is handled correctly in call to
> sctp_ulpq_tail_data().
>
> Patch applies to linux-3.8 kernel.
>
> Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>

Ok, we still have the weirdness of when partial deliver is started and 
that can be another patch.  This looks better.  I am still not crazy 
about all the checking of the TSNs at the head of the reassembly queue, 
but this is better then before.

I really might be better to re-work the the return value from 
sctp_ulpq_tail_data().  If we can return 1 if EOR was set, we can remove 
the TSN check in sctp_ulpq_renege().  It would convert that code to 
something like

retval = sctp_ulpq_tail_data(ulpq, chunk, gfp);
if (retval <= 0)
	sctp_ulpq_partial_delivery(ulpq, chunk, gfp);
else if (retval > 0)
	sctp_ulpq_reasm_drain(ulpq);

Just a suggestion.

-vlad

> ---
>   net/sctp/ulpqueue.c |   53 +++++++++++++++++++++++++++++++++++-------
>   1 file changed, 45 insertions(+), 8 deletions(-)
>
> diff -uprN -X linux-3.8-vanilla/Documentation/dontdiff linux-3.8-SCTP+3/net/sctp/ulpqueue.c linux-3.8-SCTP+4/net/sctp/ulpqueue.c
> --- linux-3.8-SCTP+3/net/sctp/ulpqueue.c	2013-02-21 07:55:32.817713326 -0700
> +++ linux-3.8-SCTP+4/net/sctp/ulpqueue.c	2013-02-21 08:07:41.562212475 -0700
> @@ -540,14 +540,19 @@ static struct sctp_ulpevent *sctp_ulpq_r
>   		ctsn = cevent->tsn;
>
>   		switch (cevent->msg_flags & SCTP_DATA_FRAG_MASK) {
> +		case SCTP_DATA_FIRST_FRAG:
> +			if (!first_frag)
> +				return NULL;
> +			goto done;
>   		case SCTP_DATA_MIDDLE_FRAG:
>   			if (!first_frag) {
>   				first_frag = pos;
>   				next_tsn = ctsn + 1;
>   				last_frag = pos;
> -			} else if (next_tsn == ctsn)
> +			} else if (next_tsn == ctsn) {
>   				next_tsn++;
> -			else
> +				last_frag = pos;
> +			} else
>   				goto done;
>   			break;
>   		case SCTP_DATA_LAST_FRAG:
> @@ -651,6 +656,14 @@ static struct sctp_ulpevent *sctp_ulpq_r
>   			} else
>   				goto done;
>   			break;
> +
> +		case SCTP_DATA_LAST_FRAG:
> +			if (!first_frag)
> +				return NULL;
> +			else
> +				goto done;
> +			break;
> +
>   		default:
>   			return NULL;
>   		}
> @@ -1025,16 +1038,28 @@ void sctp_ulpq_partial_delivery(struct s
>   	struct sctp_ulpevent *event;
>   	struct sctp_association *asoc;
>   	struct sctp_sock *sp;
> +	__u32 ctsn;
> +	struct sk_buff *skb;
>
>   	asoc = ulpq->asoc;
>   	sp = sctp_sk(asoc->base.sk);
>
>   	/* If the association is already in Partial Delivery mode
> -	 * we have noting to do.
> +	 * we have nothing to do.
>   	 */
>   	if (ulpq->pd_mode)
>   		return;
>
> +	/* Data must be at or below the Cumulative TSN ACK Point to
> +	 * start partial delivery.
> +	 */
> +	skb = skb_peek(&asoc->ulpq.reasm);
> +	if (skb != NULL) {
> +		ctsn = sctp_skb2event(skb)->tsn;
> +		if (!TSN_lte(ctsn, sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map)))
> +			return;
> +	}
> +
>   	/* If the user enabled fragment interleave socket option,
>   	 * multiple associations can enter partial delivery.
>   	 * Otherwise, we can only enter partial delivery if the
> @@ -1057,6 +1082,7 @@ void sctp_ulpq_renege(struct sctp_ulpq *
>   		      gfp_t gfp)
>   {
>   	struct sctp_association *asoc;
> +	struct sk_buff *skb;
>   	__u16 needed, freed;
>
>   	asoc = ulpq->asoc;
> @@ -1077,12 +1103,23 @@ void sctp_ulpq_renege(struct sctp_ulpq *
>   	}
>   	/* If able to free enough room, accept this chunk. */
>   	if (chunk && (freed >= needed)) {
> -		__u32 tsn;
> +		__u32 tsn, ctsn;
>   		tsn = ntohl(chunk->subh.data_hdr->tsn);
> -		sctp_tsnmap_mark(&asoc->peer.tsn_map, tsn, chunk->transport);
> -		sctp_ulpq_tail_data(ulpq, chunk, gfp);
> -
> -		sctp_ulpq_partial_delivery(ulpq, gfp);
> +		if (sctp_ulpq_tail_data(ulpq, chunk, gfp) == 0) {
> +			/*
> +			 * Enter partial delivery if chunk is still on
> +			 * reassembly queue; otherwise, drain the queue.
> +			 */
> +			skb = skb_peek(&ulpq->reasm);
> +			if (skb != NULL) {
> +				ctsn = sctp_skb2event(skb)->tsn;
> +				if (TSN_lte(ctsn, tsn))
> +					sctp_ulpq_partial_delivery(ulpq, chunk,
> +						gfp);
> +				else
> +					sctp_ulpq_reasm_drain(ulpq);
> +			}
> +		}
>   	}
>
>   	sk_mem_reclaim(asoc->base.sk);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
