From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv6 net-next 6/6] sctp: implement sender-side procedures
 for Add Incoming/Outgoing Streams Request Parameter
Date: Thu, 9 Feb 2017 09:24:11 -0200
Message-ID: <20170209112411.GM3414@localhost.localdomain>
References: <cover.1486573727.git.lucien.xin@gmail.com>
 <12e8878a56e37cae2a9c65ee1f548b7c8dff6b78.1486573728.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43470 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752061AbdBILYN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 06:24:13 -0500
Content-Disposition: inline
In-Reply-To: <12e8878a56e37cae2a9c65ee1f548b7c8dff6b78.1486573728.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 01:18:20AM +0800, Xin Long wrote:
> This patch is to implement Sender-Side Procedures for the Add
> Outgoing and Incoming Streams Request Parameter described in
> rfc6525 section 5.1.5-5.1.6.
> 
> It is also to add sockopt SCTP_ADD_STREAMS in rfc6525 section
> 6.3.4 for users.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  include/net/sctp/sctp.h   |  2 ++
>  include/uapi/linux/sctp.h |  7 +++++
>  net/sctp/socket.c         | 29 ++++++++++++++++++
>  net/sctp/stream.c         | 77 +++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 115 insertions(+)
> 
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index b60ca14..6dfc553 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -199,6 +199,8 @@ int sctp_offload_init(void);
>  int sctp_send_reset_streams(struct sctp_association *asoc,
>  			    struct sctp_reset_streams *params);
>  int sctp_send_reset_assoc(struct sctp_association *asoc);
> +int sctp_send_add_streams(struct sctp_association *asoc,
> +			  struct sctp_add_streams *params);
>  
>  /*
>   * Module global variables
> diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
> index c0bd8c3..a91a9cc 100644
> --- a/include/uapi/linux/sctp.h
> +++ b/include/uapi/linux/sctp.h
> @@ -118,6 +118,7 @@ typedef __s32 sctp_assoc_t;
>  #define SCTP_ENABLE_STREAM_RESET	118
>  #define SCTP_RESET_STREAMS	119
>  #define SCTP_RESET_ASSOC	120
> +#define SCTP_ADD_STREAMS	121
>  
>  /* PR-SCTP policies */
>  #define SCTP_PR_SCTP_NONE	0x0000
> @@ -1027,4 +1028,10 @@ struct sctp_reset_streams {
>  	uint16_t srs_stream_list[];	/* list if srs_num_streams is not 0 */
>  };
>  
> +struct sctp_add_streams {
> +	sctp_assoc_t sas_assoc_id;
> +	uint16_t sas_instrms;
> +	uint16_t sas_outstrms;
> +};
> +
>  #endif /* _UAPI_SCTP_H */
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 45a7c41..75f35ce 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -3844,6 +3844,32 @@ static int sctp_setsockopt_reset_assoc(struct sock *sk,
>  	return retval;
>  }
>  
> +static int sctp_setsockopt_add_streams(struct sock *sk,
> +				       char __user *optval,
> +				       unsigned int optlen)
> +{
> +	struct sctp_association *asoc;
> +	struct sctp_add_streams params;
> +	int retval = -EINVAL;
> +
> +	if (optlen != sizeof(params))
> +		goto out;
> +
> +	if (copy_from_user(&params, optval, optlen)) {
> +		retval = -EFAULT;
> +		goto out;
> +	}
> +
> +	asoc = sctp_id2assoc(sk, params.sas_assoc_id);
> +	if (!asoc)
> +		goto out;
> +
> +	retval = sctp_send_add_streams(asoc, &params);
> +
> +out:
> +	return retval;
> +}
> +
>  /* API 6.2 setsockopt(), getsockopt()
>   *
>   * Applications use setsockopt() and getsockopt() to set or retrieve
> @@ -4019,6 +4045,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
>  	case SCTP_RESET_ASSOC:
>  		retval = sctp_setsockopt_reset_assoc(sk, optval, optlen);
>  		break;
> +	case SCTP_ADD_STREAMS:
> +		retval = sctp_setsockopt_add_streams(sk, optval, optlen);
> +		break;
>  	default:
>  		retval = -ENOPROTOOPT;
>  		break;
> diff --git a/net/sctp/stream.c b/net/sctp/stream.c
> index 53e49fc..eb02490 100644
> --- a/net/sctp/stream.c
> +++ b/net/sctp/stream.c
> @@ -217,3 +217,80 @@ int sctp_send_reset_assoc(struct sctp_association *asoc)
>  
>  	return 0;
>  }
> +
> +int sctp_send_add_streams(struct sctp_association *asoc,
> +			  struct sctp_add_streams *params)
> +{
> +	struct sctp_stream *stream = asoc->stream;
> +	struct sctp_chunk *chunk = NULL;
> +	int retval = -ENOMEM;
> +	__u32 outcnt, incnt;
> +	__u16 out, in;
> +
> +	if (!asoc->peer.reconf_capable ||
> +	    !(asoc->strreset_enable & SCTP_ENABLE_CHANGE_ASSOC_REQ)) {
> +		retval = -ENOPROTOOPT;
> +		goto out;
> +	}
> +
> +	if (asoc->strreset_outstanding) {
> +		retval = -EINPROGRESS;
> +		goto out;
> +	}
> +
> +	out = params->sas_outstrms;
> +	in  = params->sas_instrms;
> +	outcnt = stream->outcnt + out;
> +	incnt = stream->incnt + in;
> +	if (outcnt > SCTP_MAX_STREAM || incnt > SCTP_MAX_STREAM ||
> +	    (!out && !in)) {
> +		retval = -EINVAL;
> +		goto out;
> +	}
> +
> +	if (out) {
> +		struct sctp_stream_out *streamout;
> +
> +		streamout = krealloc(stream->out, outcnt * sizeof(*streamout),
> +				     GFP_KERNEL);
> +		if (!streamout)
> +			goto out;
> +
> +		memset(streamout + stream->outcnt, 0, out * sizeof(*streamout));
> +		stream->out = streamout;
> +	}
> +
> +	if (in) {
> +		struct sctp_stream_in *streamin;
> +
> +		streamin = krealloc(stream->in, incnt * sizeof(*streamin),
> +				    GFP_KERNEL);
> +		if (!streamin)
> +			goto out;
> +
> +		memset(streamin + stream->incnt, 0, in * sizeof(*streamin));
> +		stream->in = streamin;
> +	}
> +
> +	chunk = sctp_make_strreset_addstrm(asoc, out, in);
> +	if (!chunk)
> +		goto out;
> +
> +	asoc->strreset_chunk = chunk;
> +	sctp_chunk_hold(asoc->strreset_chunk);
> +
> +	retval = sctp_send_reconf(asoc, chunk);
> +	if (retval) {
> +		sctp_chunk_put(asoc->strreset_chunk);
> +		asoc->strreset_chunk = NULL;
> +		goto out;
> +	}
> +
> +	stream->incnt = incnt;
> +	stream->outcnt = outcnt;
> +
> +	asoc->strreset_outstanding = !!out + !!in;
> +
> +out:
> +	return retval;
> +}
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
