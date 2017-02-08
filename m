From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv6 net-next 3/6] sctp: add support for generating stream
 reconf ssn/tsn reset request chunk
Date: Wed, 8 Feb 2017 19:57:34 -0200
Message-ID: <20170208215734.GJ3414@localhost.localdomain>
References: <cover.1486573727.git.lucien.xin@gmail.com>
 <376d8794b81d7c5efe02b588ca381b88ed5f05ad.1486573728.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37770 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751209AbdBHV5h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 16:57:37 -0500
Content-Disposition: inline
In-Reply-To: <376d8794b81d7c5efe02b588ca381b88ed5f05ad.1486573728.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 01:18:17AM +0800, Xin Long wrote:
> This patch is to define SSN/TSN Reset Request Parameter described
> in rfc6525 section 4.3.
> 
> It's also to drop some unnecessary __packed in include/linux/sctp.h.

Oups, extra line in the changelog here.

> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  include/linux/sctp.h     |  5 +++++
>  include/net/sctp/sm.h    |  2 ++
>  net/sctp/sm_make_chunk.c | 29 +++++++++++++++++++++++++++++
>  3 files changed, 36 insertions(+)
> 
> diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> index d74fca3..71c0d41 100644
> --- a/include/linux/sctp.h
> +++ b/include/linux/sctp.h
> @@ -737,4 +737,9 @@ struct sctp_strreset_inreq {
>  	__u16 list_of_streams[0];
>  };
>  
> +struct sctp_strreset_tsnreq {
> +	sctp_paramhdr_t param_hdr;
> +	__u32 request_seq;
> +};
> +
>  #endif /* __LINUX_SCTP_H__ */
> diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
> index 430ed13..ac37c17 100644
> --- a/include/net/sctp/sm.h
> +++ b/include/net/sctp/sm.h
> @@ -265,6 +265,8 @@ struct sctp_chunk *sctp_make_strreset_req(
>  				const struct sctp_association *asoc,
>  				__u16 stream_num, __u16 *stream_list,
>  				bool out, bool in);
> +struct sctp_chunk *sctp_make_strreset_tsnreq(
> +				const struct sctp_association *asoc);
>  void sctp_chunk_assign_tsn(struct sctp_chunk *);
>  void sctp_chunk_assign_ssn(struct sctp_chunk *);
>  
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index c7d3249..749842a 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3658,3 +3658,32 @@ struct sctp_chunk *sctp_make_strreset_req(
>  
>  	return retval;
>  }
> +
> +/* RE-CONFIG 4.3 (SSN/TSN RESET ALL)
> + *   0                   1                   2                   3
> + *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *  |     Parameter Type = 15       |      Parameter Length = 8     |
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *  |         Re-configuration Request Sequence Number              |
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + */
> +struct sctp_chunk *sctp_make_strreset_tsnreq(
> +				const struct sctp_association *asoc)
> +{
> +	struct sctp_strreset_tsnreq tsnreq;
> +	__u16 length = sizeof(tsnreq);
> +	struct sctp_chunk *retval;
> +
> +	retval = sctp_make_reconf(asoc, length);
> +	if (!retval)
> +		return NULL;
> +
> +	tsnreq.param_hdr.type = SCTP_PARAM_RESET_TSN_REQUEST;
> +	tsnreq.param_hdr.length = htons(length);
> +	tsnreq.request_seq = htonl(asoc->strreset_outseq);
> +
> +	sctp_addto_chunk(retval, sizeof(tsnreq), &tsnreq);
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
