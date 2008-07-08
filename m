From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Mark the tsn as received after all allocations
 finish
Date: Tue, 08 Jul 2008 02:30:08 -0700 (PDT)
Message-ID: <20080708.023008.77788464.davem@davemloft.net>
References: <1215465041-13276-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50223
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753541AbYGHJaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 05:30:08 -0400
In-Reply-To: <1215465041-13276-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon,  7 Jul 2008 17:10:41 -0400

> If we don't have the buffer space or memory allocations fail,
> the data chunk is dropped, but TSN is still reported as received.
> This introduced a data loss that can't be recovered.  We should
> only mark TSNs are received after memory allocations finish.
> The one exception is the invalid stream identifier, but that's
> due to user error and is reported back to the user.
> 
> This was noticed by Michael Tuexen.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied and pushed out to net-2.6, thanks Vlad.

In the future please CC: netdev on changes you actually want me to
commit so other networking developers can look it over.

Thanks!

> ---
>  net/sctp/sm_statefuns.c |    9 +++------
>  net/sctp/ulpevent.c     |    5 +++++
>  2 files changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index 0c9d5a6..fcdb45d 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -5899,12 +5899,6 @@ static int sctp_eat_data(const struct sctp_association *asoc,
>  		return SCTP_IERROR_NO_DATA;
>  	}
>  
> -	/* If definately accepting the DATA chunk, record its TSN, otherwise
> -	 * wait for renege processing.
> -	 */
> -	if (SCTP_CMD_CHUNK_ULP == deliver)
> -		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_TSN, SCTP_U32(tsn));
> -
>  	chunk->data_accepted = 1;
>  
>  	/* Note: Some chunks may get overcounted (if we drop) or overcounted
> @@ -5924,6 +5918,9 @@ static int sctp_eat_data(const struct sctp_association *asoc,
>  	 * and discard the DATA chunk.
>  	 */
>  	if (ntohs(data_hdr->stream) >= asoc->c.sinit_max_instreams) {
> +		/* Mark tsn as received even though we drop it */
> +		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_TSN, SCTP_U32(tsn));
> +
>  		err = sctp_make_op_error(asoc, chunk, SCTP_ERROR_INV_STRM,
>  					 &data_hdr->stream,
>  					 sizeof(data_hdr->stream));
> diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
> index ce6cda6..a1f654a 100644
> --- a/net/sctp/ulpevent.c
> +++ b/net/sctp/ulpevent.c
> @@ -710,6 +710,11 @@ struct sctp_ulpevent *sctp_ulpevent_make_rcvmsg(struct sctp_association *asoc,
>  	if (!skb)
>  		goto fail;
>  
> +	/* Now that all memory allocations for this chunk succeeded, we
> +	 * can mark it as received so the tsn_map is updated correctly.
> +	 */
> +	sctp_tsnmap_mark(&asoc->peer.tsn_map, ntohl(chunk->subh.data_hdr->tsn));
> +
>  	/* First calculate the padding, so we don't inadvertently
>  	 * pass up the wrong length to the user.
>  	 *
> -- 
> 1.5.3.5
> 
