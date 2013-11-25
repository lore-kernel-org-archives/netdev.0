From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [V2 PATCH] sctp: Restore 'resent' bit to avoid retransmitted
 chunks for RTT measurements
Date: Mon, 25 Nov 2013 13:17:34 -0500
Message-ID: <5293943E.2000800@gmail.com>
References: <1385350017-11324-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Xufeng Zhang <xufeng.zhang@windriver.com>, nhorman@tuxdriver.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385350017-11324-1-git-send-email-xufeng.zhang@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/24/2013 10:26 PM, Xufeng Zhang wrote:
> Currently retransmitted DATA chunks could also be used for
> RTT measurements since there are no flag to identify whether
> the transmitted DATA chunk is a new one or a retransmitted one.
> This problem is introduced by commit ae19c5486 ("sctp: remove
> 'resent' bit from the chunk") which inappropriately removed the
> 'resent' bit completely, instead of doing this, we should set
> the resent bit only for the retransmitted DATA chunks.
> 
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Thanks
-vlad

> ---
> v1->v2:
> Rmoved initialization for resent bit.
> Combined two if clause
> 
>  include/net/sctp/structs.h |    1 +
>  net/sctp/output.c          |    3 ++-
>  net/sctp/outqueue.c        |    3 +++
>  3 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 2174d8d..ea0ca5f 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -629,6 +629,7 @@ struct sctp_chunk {
>  #define SCTP_NEED_FRTX 0x1
>  #define SCTP_DONT_FRTX 0x2
>  	__u16	rtt_in_progress:1,	/* This chunk used for RTT calc? */
> +		resent:1,		/* Has this chunk ever been resent. */
>  		has_tsn:1,		/* Does this chunk have a TSN yet? */
>  		has_ssn:1,		/* Does this chunk have a SSN yet? */
>  		singleton:1,		/* Only chunk in the packet? */
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index e650978..0e2644d 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -474,10 +474,11 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>  			 * for a given destination transport address.
>  			 */
>  
> -			if (!tp->rto_pending) {
> +			if (!chunk->resent && !tp->rto_pending) {
>  				chunk->rtt_in_progress = 1;
>  				tp->rto_pending = 1;
>  			}
> +
>  			has_data = 1;
>  		}
>  
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 94df758..70f4f56 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -446,6 +446,8 @@ void sctp_retransmit_mark(struct sctp_outq *q,
>  				transport->rto_pending = 0;
>  			}
>  
> +			chunk->resent = 1;
> +
>  			/* Move the chunk to the retransmit queue. The chunks
>  			 * on the retransmit queue are always kept in order.
>  			 */
> @@ -1375,6 +1377,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  				 * instance).
>  				 */
>  				if (!tchunk->tsn_gap_acked &&
> +				    !tchunk->resent &&
>  				    tchunk->rtt_in_progress) {
>  					tchunk->rtt_in_progress = 0;
>  					rtt = jiffies - tchunk->sent_at;
> 
