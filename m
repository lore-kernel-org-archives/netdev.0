From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv3 net-next 2/4] sctp: implement sender-side procedures
 for SSN/TSN Reset Request Parameter
Date: Thu, 19 Jan 2017 20:02:06 -0200
Message-ID: <20170119220206.GN3781@localhost.localdomain>
References: <cover.1484845510.git.lucien.xin@gmail.com>
 <a44bc2b9cf8d12598d3e7962e1edf0f5da738af4.1484845510.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51346 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751974AbdASWCL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 17:02:11 -0500
Content-Disposition: inline
In-Reply-To: <a44bc2b9cf8d12598d3e7962e1edf0f5da738af4.1484845510.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 20, 2017 at 01:19:12AM +0800, Xin Long wrote:
> This patch is to implement Sender-Side Procedures for the SSN/TSN
> Reset Request Parameter descibed in rfc6525 section 5.1.4.
> 
> It is also to add sockopt SCTP_RESET_ASSOC in rfc6525 section 6.3.3
> for users.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  include/net/sctp/sctp.h   |  1 +
>  include/uapi/linux/sctp.h |  1 +
>  net/sctp/socket.c         | 29 +++++++++++++++++++++++++++++
>  net/sctp/stream.c         | 33 +++++++++++++++++++++++++++++++++
>  4 files changed, 64 insertions(+)
> 
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 3cfd365b..b93820f 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -198,6 +198,7 @@ int sctp_offload_init(void);
>   */
>  int sctp_send_reset_streams(struct sctp_association *asoc,
>  			    struct sctp_reset_streams *params);
> +int sctp_send_reset_assoc(struct sctp_association *asoc);
>  
>  /*
>   * Module global variables
> diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
> index 03c27ce..c0bd8c3 100644
> --- a/include/uapi/linux/sctp.h
> +++ b/include/uapi/linux/sctp.h
> @@ -117,6 +117,7 @@ typedef __s32 sctp_assoc_t;
>  #define SCTP_PR_ASSOC_STATUS	115
>  #define SCTP_ENABLE_STREAM_RESET	118
>  #define SCTP_RESET_STREAMS	119
> +#define SCTP_RESET_ASSOC	120
>  
>  /* PR-SCTP policies */
>  #define SCTP_PR_SCTP_NONE	0x0000
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index bee4dd3..2c5c9ca 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -3812,6 +3812,32 @@ static int sctp_setsockopt_reset_streams(struct sock *sk,
>  	return retval;
>  }
>  
> +static int sctp_setsockopt_reset_assoc(struct sock *sk,
> +				       char __user *optval,
> +				       unsigned int optlen)
> +{
> +	struct sctp_association *asoc;
> +	sctp_assoc_t associd;
> +	int retval = -EINVAL;
> +
> +	if (optlen != sizeof(associd))
> +		goto out;
> +
> +	if (copy_from_user(&associd, optval, optlen)) {
> +		retval = -EFAULT;
> +		goto out;
> +	}
> +
> +	asoc = sctp_id2assoc(sk, associd);
> +	if (!asoc)
> +		goto out;
> +
> +	retval = sctp_send_reset_assoc(asoc);
> +
> +out:
> +	return retval;
> +}
> +
>  /* API 6.2 setsockopt(), getsockopt()
>   *
>   * Applications use setsockopt() and getsockopt() to set or retrieve
> @@ -3984,6 +4010,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
>  	case SCTP_RESET_STREAMS:
>  		retval = sctp_setsockopt_reset_streams(sk, optval, optlen);
>  		break;
> +	case SCTP_RESET_ASSOC:
> +		retval = sctp_setsockopt_reset_assoc(sk, optval, optlen);
> +		break;
>  	default:
>  		retval = -ENOPROTOOPT;
>  		break;
> diff --git a/net/sctp/stream.c b/net/sctp/stream.c
> index 13d5e07..b368191 100644
> --- a/net/sctp/stream.c
> +++ b/net/sctp/stream.c
> @@ -162,3 +162,36 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
>  out:
>  	return retval;
>  }
> +
> +int sctp_send_reset_assoc(struct sctp_association *asoc)
> +{
> +	struct sctp_chunk *chunk = NULL;
> +	int retval;
> +	__u16 i;
> +
> +	if (!asoc->peer.reconf_capable ||
> +	    !(asoc->strreset_enable & SCTP_ENABLE_RESET_ASSOC_REQ))
> +		return -ENOPROTOOPT;
> +
> +	if (asoc->strreset_outstanding)
> +		return -EINPROGRESS;
> +
> +	chunk = sctp_make_strreset_tsnreq(asoc);
> +	if (!chunk)
> +		return -ENOMEM;
> +

Please add a comment here explaining that the for below is to block
further xmit of data until this request is completed.

> +	for (i = 0; i < asoc->stream->outcnt; i++)
> +		asoc->stream->out[i].state = SCTP_STREAM_CLOSED;
> +
> +	asoc->strreset_outstanding = 1;
> +	asoc->strreset_chunk = chunk;
> +	sctp_chunk_hold(asoc->strreset_chunk);
> +
> +	retval = sctp_send_reconf(asoc, chunk);
> +	if (retval) {
> +		sctp_chunk_put(asoc->strreset_chunk);
> +		asoc->strreset_chunk = NULL;

If this happens, the asoc will get stuck, as strreset_outstanding is
marked as 1, all streams are closed and no packet was even queued
(I'm assuming so as you're dropping the reference on it).


> +	}
> +
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
