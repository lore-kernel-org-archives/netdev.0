From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH V2] For for each TSN t being newly acked (Not only cumulatively,
 but also SELECTIVELY) cacc_saw_newack should be set to 1.
Date: Tue, 15 Oct 2013 22:13:06 -0400
Message-ID: <525DF632.1030507@gmail.com>
References: <1381860784-16481-1-git-send-email-changxiangzhong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chang Xiangzhong <changxiangzhong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381860784-16481-1-git-send-email-changxiangzhong@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/15/2013 02:13 PM, Chang Xiangzhong wrote:
> Signed-off-by: Xiangzhong Chang <changxiangzhong@gmail.com>

Your proposed solution is very nice, but it does 2 things in one
patch.
  1) It fixes the bug
  2) It refactors the code to improve the flow.

While (2) is very nice, it needs a much more careful review.
Can you please split this into 2 patches?  First patch can
make the code look like this:

	if (sctp_acked(sack, tsn)) {
		...
		if (!tchunk->tsn_gap_acked) {
			tchunk->tsn_gap_acked = 1;
			*highest_new_tsn_in_sack = tsn;
			bytes_acked += sctp_data_size(tchunk);
                         if (!tchunk->transport)
				migrate_bytes += sctp_data_size(tchunk);
			forward_progress = true;

			/*
			 * SFR-CACC algorithm:
			 * 2) If the SACK contains gap acks
			 * and the flag CHANGEOVER_ACTIVE is
			 * set the receiver of the SACK MUST
			 * take the following action:
			...
		}
	}

Then you can file a second patch to improve the flow/refactor the 
function.  You have to be very careful here though and be sure to
run through all the regression tests since you would be modifying
a very critcal part of the code.

Thanks
-vlad

> ---
>   net/sctp/outqueue.c |   76 ++++++++++++++++++++++++---------------------------
>   1 file changed, 35 insertions(+), 41 deletions(-)
>
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 94df758..84ef3b8 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -1357,13 +1357,13 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>
>   		tsn = ntohl(tchunk->subh.data_hdr->tsn);
>   		if (sctp_acked(sack, tsn)) {
> -			/* If this queue is the retransmit queue, the
> -			 * retransmit timer has already reclaimed
> -			 * the outstanding bytes for this chunk, so only
> -			 * count bytes associated with a transport.
> -			 */
> -			if (transport) {
> -				/* If this chunk is being used for RTT
> +			if (!tchunk->tsn_gap_acked) {
> +				/* If this queue is the retransmit queue, the
> +				 * retransmit timer has already reclaimed
> +				 * the outstanding bytes for this chunk, so only
> +				 * count bytes associated with a transport.
> +				 *
> +				 * If this chunk is being used for RTT
>   				 * measurement, calculate the RTT and update
>   				 * the RTO using this value.
>   				 *
> @@ -1374,28 +1374,44 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>   				 * first instance of the packet or a later
>   				 * instance).
>   				 */
> -				if (!tchunk->tsn_gap_acked &&
> -				    tchunk->rtt_in_progress) {
> +				if (transport && tchunk->rtt_in_progress) {
>   					tchunk->rtt_in_progress = 0;
>   					rtt = jiffies - tchunk->sent_at;
>   					sctp_transport_update_rto(transport,
> -								  rtt);
> +						rtt);
>   				}
> -			}
>
> -			/* If the chunk hasn't been marked as ACKED,
> -			 * mark it and account bytes_acked if the
> -			 * chunk had a valid transport (it will not
> -			 * have a transport if ASCONF had deleted it
> -			 * while DATA was outstanding).
> -			 */
> -			if (!tchunk->tsn_gap_acked) {
> +				/* If the chunk hasn't been marked as ACKED,
> +				 * mark it and account bytes_acked if the
> +				 * chunk had a valid transport (it will not
> +				 * have a transport if ASCONF had deleted it
> +				 * while DATA was outstanding).
> +				 */
>   				tchunk->tsn_gap_acked = 1;
>   				*highest_new_tsn_in_sack = tsn;
>   				bytes_acked += sctp_data_size(tchunk);
>   				if (!tchunk->transport)
>   					migrate_bytes += sctp_data_size(tchunk);
>   				forward_progress = true;
> +
> +				/* SFR-CACC algorithm:
> +				 * 2) If the SACK contains gap acks
> +				 * and the flag CHANGEOVER_ACTIVE is
> +				 * set the receiver of the SACK MUST
> +				 * take the following action:
> +				 *
> +				 * B) For each TSN t being acked that
> +				 * has not been acked in any SACK so
> +				 * far, set cacc_saw_newack to 1 for
> +				 * the destination that the TSN was
> +				 * sent to.
> +				 */
> +				if (transport &&
> +					sack->num_gap_ack_blocks &&
> +					q->asoc->peer.primary_path->cacc.
> +					changeover_active
> +				   )
> +					transport->cacc.cacc_saw_newack = 1;
>   			}
>
>   			if (TSN_lte(tsn, sack_ctsn)) {
> @@ -1411,30 +1427,8 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>   				restart_timer = 1;
>   				forward_progress = true;
>
> -				if (!tchunk->tsn_gap_acked) {
> -					/*
> -					 * SFR-CACC algorithm:
> -					 * 2) If the SACK contains gap acks
> -					 * and the flag CHANGEOVER_ACTIVE is
> -					 * set the receiver of the SACK MUST
> -					 * take the following action:
> -					 *
> -					 * B) For each TSN t being acked that
> -					 * has not been acked in any SACK so
> -					 * far, set cacc_saw_newack to 1 for
> -					 * the destination that the TSN was
> -					 * sent to.
> -					 */
> -					if (transport &&
> -					    sack->num_gap_ack_blocks &&
> -					    q->asoc->peer.primary_path->cacc.
> -					    changeover_active)
> -						transport->cacc.cacc_saw_newack
> -							= 1;
> -				}
> -
>   				list_add_tail(&tchunk->transmitted_list,
> -					      &q->sacked);
> +					&q->sacked);
>   			} else {
>   				/* RFC2960 7.2.4, sctpimpguide-05 2.8.2
>   				 * M2) Each time a SACK arrives reporting
>
