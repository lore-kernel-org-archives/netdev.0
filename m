From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH]: sctp: Fix skb_over_panic resulting from multiple invalid
 parameter errors (CVE-2010-1173) (v3)
Date: Wed, 28 Apr 2010 16:16:54 -0400
Message-ID: <4BD897B6.5040405@hp.com>
References: <20100428134748.GA4818@hmsreliant.think-freely.org> <4BD83F85.8090308@hp.com> <20100428142147.GB4818@hmsreliant.think-freely.org> <4BD8481E.3010509@hp.com> <20100428174711.GC4818@hmsreliant.think-freely.org> <20100428193755.GF4818@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, linux-sctp@vger.kernel.org, eteo@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net, security@kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:36074 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591Ab0D1UQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 16:16:59 -0400
In-Reply-To: <20100428193755.GF4818@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Neil Horman wrote:

... snip description ...

> 
> 
>  include/net/sctp/structs.h |    1 
>  net/sctp/sm_make_chunk.c   |   70 +++++++++++++++++++++++++++++++++++++++------
>  2 files changed, 62 insertions(+), 9 deletions(-)
> 
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index ff30177..597f8e2 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -778,6 +778,7 @@ int sctp_user_addto_chunk(struct sctp_chunk *chunk, int off, int len,
>  			  struct iovec *data);
>  void sctp_chunk_free(struct sctp_chunk *);
>  void  *sctp_addto_chunk(struct sctp_chunk *, int len, const void *data);
> +void  *sctp_addto_chunk_fixed(struct sctp_chunk *, int len, const void *data);
>  struct sctp_chunk *sctp_chunkify(struct sk_buff *,
>  				 const struct sctp_association *,
>  				 struct sock *);
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index f592163..9623112 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -107,7 +107,7 @@ static const struct sctp_paramhdr prsctp_param = {
>  	cpu_to_be16(sizeof(struct sctp_paramhdr)),
>  };
>  
> -/* A helper to initialize to initialize an op error inside a
> +/* A helper to initialize an op error inside a
>   * provided chunk, as most cause codes will be embedded inside an
>   * abort chunk.
>   */
> @@ -124,6 +124,29 @@ void  sctp_init_cause(struct sctp_chunk *chunk, __be16 cause_code,
>  	chunk->subh.err_hdr = sctp_addto_chunk(chunk, sizeof(sctp_errhdr_t), &err);
>  }
>  
> +/* A helper to initialize an op error inside a
> + * provided chunk, as most cause codes will be embedded inside an
> + * abort chunk.  Differs from sctp_init_cause in that it won't oops
> + * if there isn't enough space in the op error chunk
> + */
> +int sctp_init_cause_fixed(struct sctp_chunk *chunk, __be16 cause_code,
> +		      size_t paylen)
> +{
> +	sctp_errhdr_t err;
> +	__u16 len;
> +
> +	/* Cause code constants are now defined in network order.  */
> +	err.cause = cause_code;
> +	len = sizeof(sctp_errhdr_t) + paylen;
> +	err.length  = htons(len);
> +
> +	if (skb_tailroom(chunk->skb) >  len)
> +		return -ENOSPC;
> +	chunk->subh.err_hdr = sctp_addto_chunk_fixed(chunk,
> +						     sizeof(sctp_errhdr_t),
> +						     &err);
> +	return 0;
> +}
>  /* 3.3.2 Initiation (INIT) (1)
>   *
>   * This chunk is used to initiate a SCTP association between two
> @@ -1131,6 +1154,24 @@ nodata:
>  	return retval;
>  }
>  
> +/* Create an Operation Error chunk of a fixed size,
> + * specifically, max(asoc->pathmtu, SCTP_DEFAULT_MAXSEGMENT)
> + * This is a helper function to allocate an error chunk for
> + * for those invalid parameter codes in which we may not want
> + * to report all the errors, if the incomming chunk is large
> + */
> +static inline struct sctp_chunk *sctp_make_op_error_fixed(
> +	const struct sctp_association *asoc,
> +	const struct sctp_chunk *chunk)
> +{
> +	size_t size = asoc ? asoc->pathmtu : 0;
> +
> +	if (size > SCTP_DEFAULT_MAXSEGMENT)
> +		size = SCTP_DEFAULT_MAXSEGMENT;
> +

This doesn't look right.  If you don't have an association or if pmtu is
not initialized, you will end up with a size of 0.  I think you simply
want to a
	if (!size)

there.


> +	return sctp_make_op_error_space(asoc, chunk, size);
> +}
> +
>  /* Create an Operation Error chunk.  */
>  struct sctp_chunk *sctp_make_op_error(const struct sctp_association *asoc,
>  				 const struct sctp_chunk *chunk,
> @@ -1373,6 +1414,18 @@ void *sctp_addto_chunk(struct sctp_chunk *chunk, int len, const void *data)
>  	return target;
>  }
>  
> +/* Append bytes to the end of a chunk. Returns NULL if there isn't sufficient
> + * space in the chunk
> + */
> +void *sctp_addto_chunk_fixed(struct sctp_chunk *chunk,
> +			     int len, const void *data)
> +{
> +	if (skb_tailroom(chunk->skb) > len)
> +		return sctp_addto_chunk(chunk, len, data);
> +	else
> +		return NULL;
> +}
> +
>  /* Append bytes from user space to the end of a chunk.  Will panic if
>   * chunk is not big enough.
>   * Returns a kernel err value.
> @@ -1793,9 +1846,9 @@ static int sctp_process_missing_param(const struct sctp_association *asoc,
>  	if (*errp) {
>  		report.num_missing = htonl(1);
>  		report.type = paramtype;
> -		sctp_init_cause(*errp, SCTP_ERROR_MISS_PARAM,
> -				sizeof(report));
> -		sctp_addto_chunk(*errp, sizeof(report), &report);
> +		sctp_init_cause_fixed(*errp, SCTP_ERROR_MISS_PARAM,
> +				      sizeof(report));
> +		sctp_addto_chunk_fixed(*errp, sizeof(report), &report);
>  	}
>  
>  	/* Stop processing this chunk. */
> @@ -1813,7 +1866,7 @@ static int sctp_process_inv_mandatory(const struct sctp_association *asoc,
>  		*errp = sctp_make_op_error_space(asoc, chunk, 0);
>  
>  	if (*errp)
> -		sctp_init_cause(*errp, SCTP_ERROR_INV_PARAM, 0);
> +		sctp_init_cause_fixed(*errp, SCTP_ERROR_INV_PARAM, 0);
>  
>  	/* Stop processing this chunk. */
>  	return 0;

I don't think missing or mandatory parameters are effected by this.  They are a
once and done deal.  There don't report multiple errors and we don't add any
more error after them.

> @@ -1976,13 +2029,12 @@ static sctp_ierror_t sctp_process_unk_param(const struct sctp_association *asoc,
>  		 * returning multiple unknown parameters.
>  		 */
>  		if (NULL == *errp)
> -			*errp = sctp_make_op_error_space(asoc, chunk,
> -					ntohs(chunk->chunk_hdr->length));
> +			*errp = sctp_make_op_error_fixed(asoc, chunk);
>  
>  		if (*errp) {
> -			sctp_init_cause(*errp, SCTP_ERROR_UNKNOWN_PARAM,
> +			sctp_init_cause_fixed(*errp, SCTP_ERROR_UNKNOWN_PARAM,
>  					WORD_ROUND(ntohs(param.p->length)));
> -			sctp_addto_chunk(*errp,
> +			sctp_addto_chunk_fixed(*errp,
>  					WORD_ROUND(ntohs(param.p->length)),
>  					param.v);
>  		} else {
> 

So we completely get rid of variable size error chunk in this case, which I can
live with.  It simplifies the code.

-vlad
