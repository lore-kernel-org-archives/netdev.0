From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: refactor sctp_packet_append_chunk and clenup some
 memory leaks
Date: Tue, 03 Jul 2012 10:39:36 -0400
Message-ID: <4FF30428.6070403@gmail.com>
References: <1341259164-7396-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:47717 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278Ab2GCOjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 10:39:39 -0400
In-Reply-To: <1341259164-7396-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2012 03:59 PM, Neil Horman wrote:
> While doing some recent work on sctp sack bundling I noted that
> sctp_packet_append_chunk was pretty inefficient.  Specifially, it was called
> recursively while trying to bundle auth and sack chunks.  Because of that we
> call sctp_packet_bundle_sack and sctp_packet_bundle_auth a total of 4 times for
> every call to sctp_packet_append_chunk, knowing that at least 3 of those calls
> will do nothing.
>
> So lets refactor sctp_packet_bundle_auth to have an outer part that does the
> attempted bundling, and an inner part that just does the chunk appends.  This
> saves us several calls per iteration that we just don't need.
>
> Also, noticed that the auth and sack bundling fail to free the chunks they
> allocate if the append fails, so make sure we add that in
>
> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
> CC: Vlad Yasevich<vyasevich@gmail.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> CC: "David S. Miller"<davem@davemloft.net>
> CC: linux-sctp@vger.kernel.org
> ---
>   net/sctp/output.c |   80 +++++++++++++++++++++++++++++++++++------------------
>   1 files changed, 53 insertions(+), 27 deletions(-)
>
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 0de6cd5..0b62f6c 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -64,6 +64,8 @@
>   #include<net/sctp/checksum.h>
>
>   /* Forward declarations for private helpers. */
> +static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
> +					      struct sctp_chunk *chunk);
>   static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
>   					   struct sctp_chunk *chunk);
>   static void sctp_packet_append_data(struct sctp_packet *packet,
> @@ -224,7 +226,10 @@ static sctp_xmit_t sctp_packet_bundle_auth(struct sctp_packet *pkt,
>   	if (!auth)
>   		return retval;
>
> -	retval = sctp_packet_append_chunk(pkt, auth);
> +	retval = __sctp_packet_append_chunk(pkt, auth);
> +
> +	if (retval != SCTP_XMIT_OK)
> +		sctp_chunk_free(auth);
>
>   	return retval;
>   }
> @@ -256,48 +261,31 @@ static sctp_xmit_t sctp_packet_bundle_sack(struct sctp_packet *pkt,
>   			asoc->a_rwnd = asoc->rwnd;
>   			sack = sctp_make_sack(asoc);
>   			if (sack) {
> -				retval = sctp_packet_append_chunk(pkt, sack);
> +				retval = __sctp_packet_append_chunk(pkt, sack);
> +				if (retval != SCTP_XMIT_OK) {
> +					sctp_chunk_free(sack);
> +					goto out;
> +				}
>   				asoc->peer.sack_needed = 0;
>   				if (del_timer(timer))
>   					sctp_association_put(asoc);
>   			}
>   		}
>   	}
> +out:
>   	return retval;
>   }
>
> +
>   /* Append a chunk to the offered packet reporting back any inability to do
>    * so.
>    */
> -sctp_xmit_t sctp_packet_append_chunk(struct sctp_packet *packet,
> -				     struct sctp_chunk *chunk)
> +static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
> +					      struct sctp_chunk *chunk)
>   {
>   	sctp_xmit_t retval = SCTP_XMIT_OK;
>   	__u16 chunk_len = WORD_ROUND(ntohs(chunk->chunk_hdr->length));
>
> -	SCTP_DEBUG_PRINTK("%s: packet:%p chunk:%p\n", __func__, packet,
> -			  chunk);
> -
> -	/* Data chunks are special.  Before seeing what else we can
> -	 * bundle into this packet, check to see if we are allowed to
> -	 * send this DATA.
> -	 */
> -	if (sctp_chunk_is_data(chunk)) {
> -		retval = sctp_packet_can_append_data(packet, chunk);
> -		if (retval != SCTP_XMIT_OK)
> -			goto finish;
> -	}
> -
> -	/* Try to bundle AUTH chunk */
> -	retval = sctp_packet_bundle_auth(packet, chunk);
> -	if (retval != SCTP_XMIT_OK)
> -		goto finish;
> -
> -	/* Try to bundle SACK chunk */
> -	retval = sctp_packet_bundle_sack(packet, chunk);
> -	if (retval != SCTP_XMIT_OK)
> -		goto finish;
> -
>   	/* Check to see if this chunk will fit into the packet */
>   	retval = sctp_packet_will_fit(packet, chunk, chunk_len);
>   	if (retval != SCTP_XMIT_OK)
> @@ -339,6 +327,44 @@ finish:
>   	return retval;
>   }
>
> +/* Append a chunk to the offered packet reporting back any inability to do
> + * so.
> + */
> +sctp_xmit_t sctp_packet_append_chunk(struct sctp_packet *packet,
> +				     struct sctp_chunk *chunk)
> +{
> +	sctp_xmit_t retval = SCTP_XMIT_OK;
> +	__u16 chunk_len = WORD_ROUND(ntohs(chunk->chunk_hdr->length));
> +
> +	SCTP_DEBUG_PRINTK("%s: packet:%p chunk:%p\n", __func__, packet,
> +			  chunk);
> +
> +	/* Data chunks are special.  Before seeing what else we can
> +	 * bundle into this packet, check to see if we are allowed to
> +	 * send this DATA.
> +	 */
> +	if (sctp_chunk_is_data(chunk)) {
> +		retval = sctp_packet_can_append_data(packet, chunk);
> +		if (retval != SCTP_XMIT_OK)
> +			goto finish;
> +	}
> +
> +	/* Try to bundle AUTH chunk */
> +	retval = sctp_packet_bundle_auth(packet, chunk);
> +	if (retval != SCTP_XMIT_OK)
> +		goto finish;
> +
> +	/* Try to bundle SACK chunk */
> +	retval = sctp_packet_bundle_sack(packet, chunk);
> +	if (retval != SCTP_XMIT_OK)
> +		goto finish;
> +
> +	retval = __sctp_packet_append_chunk(packet, chunk);
> +
> +finish:
> +	return retval;
> +}
> +
>   /* All packets are sent to the network through this function from
>    * sctp_outq_tail().
>    *
