From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: reduce memory footprint of sctp_chunk structure
Date: Fri, 25 Jul 2008 09:03:33 -0400
Message-ID: <4889CF25.30405@hp.com>
References: <20080725121130.GB12725@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:16790 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbYGYNDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 09:03:38 -0400
In-Reply-To: <20080725121130.GB12725@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil

A few small nits.

Neil Horman wrote:
> sctp_chunks should be put on a diet.  This is some of the low hanging fruit that
> we can strip out.  Changes all the __s8/__u8 flags to bitfields.  Saves 12 bytes
> per chunk.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
>  include/net/sctp/structs.h |   31 +++++++++++++++++--------------
>  net/sctp/output.c          |    3 ++-
>  net/sctp/outqueue.c        |   14 +++++++-------
>  net/sctp/sm_make_chunk.c   |    2 +-
>  4 files changed, 27 insertions(+), 23 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 7f25195..cadd7a6 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -731,20 +731,23 @@ struct sctp_chunk {
>  	 */
>  	struct sk_buff *auth_chunk;
>  
> -	__u8 rtt_in_progress;	/* Is this chunk used for RTT calculation? */
> -	__u8 resent;		/* Has this chunk ever been retransmitted. */
> -	__u8 has_tsn;		/* Does this chunk have a TSN yet? */
> -	__u8 has_ssn;		/* Does this chunk have a SSN yet? */
> -	__u8 singleton;		/* Was this the only chunk in the packet? */
> -	__u8 end_of_packet;	/* Was this the last chunk in the packet? */
> -	__u8 ecn_ce_done;	/* Have we processed the ECN CE bit? */
> -	__u8 pdiscard;		/* Discard the whole packet now? */
> -	__u8 tsn_gap_acked;	/* Is this chunk acked by a GAP ACK? */
> -	__s8 fast_retransmit;	 /* Is this chunk fast retransmitted? */
> -	__u8 tsn_missing_report; /* Data chunk missing counter. */
> -	__u8 data_accepted; 	/* At least 1 chunk in this packet accepted */
> -	__u8 auth;		/* IN: was auth'ed | OUT: needs auth */
> -	__u8 has_asconf;	/* IN: have seen an asconf before */
> +#define SCTP_NO_FRT 0x0
> +#define SCTP_NEED_FRT 0x1
> +#define SCTP_CANT_FRT 0x2

I think FRTX suffix is little better.

SCTP_NO_FRT makes it sound like there can't be a fast retransmission of this chunk.
May be use SCTP_CAN_FRTX as that says that the chun can be marked for fast retransmit.

Also, maybe cange SCTP_CANT_FRT to SCTP_DONT_FRTX so that it's easier on the eyes.

> +	__u16	rtt_in_progress:1,	/* This chunk used for RTT calc? */
> +		resent:1,		/* Has this chunk ever been resent. */
> +		has_tsn:1,		/* Does this chunk have a TSN yet? */
> +		has_ssn:1,		/* Does this chunk have a SSN yet? */
> +		singleton:1,		/* Only chunk in the packet? */
> +		end_of_packet:1,	/* Last chunk in the packet? */
> +		ecn_ce_done:1,		/* Have we processed the ECN CE bit? */
> +		pdiscard:1,		/* Discard the whole packet now? */
> +		tsn_gap_acked:1,	/* Is this chunk acked by a GAP ACK? */
> +		tsn_missing_report:1,	/* Data chunk missing counter. */
> +		data_accepted:1,	/* At least 1 chunk accepted */
> +		auth:1,			/* IN: was auth'ed | OUT: needs auth */
> +		has_asconf:1,		/* IN: have seen an asconf before */
> +		fast_retransmit:2;	/* Is this chunk fast retransmitted? */
>  };
>  
>  void sctp_chunk_hold(struct sctp_chunk *);
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 7e7e612..6ee3475 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -709,7 +709,8 @@ static sctp_xmit_t sctp_packet_append_data(struct sctp_packet *packet,
>  	 *    When a Fast Retransmit is being performed the sender SHOULD
>  	 *    ignore the value of cwnd and SHOULD NOT delay retransmission.
>  	 */
> -	if (chunk->fast_retransmit <= 0)
> +	if ((chunk->fast_retransmit == SCTP_CANT_FRT) ||
> +	    (chunk->fast_retransmit == SCTP_NO_FRT))

if (chunk->fast_retransmit != SCTP_CAN_FRTX)


The rest looks good.

Thanks
-vlad
