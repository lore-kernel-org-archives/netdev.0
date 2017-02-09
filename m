From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv6 net-next 5/6] sctp: add support for generating stream
 reconf add incoming/outgoing streams request chunk
Date: Thu, 9 Feb 2017 09:23:49 -0200
Message-ID: <20170209112349.GL3414@localhost.localdomain>
References: <cover.1486573727.git.lucien.xin@gmail.com>
 <2664f74a3821c493b1b8beea4bc5c4077e994243.1486573728.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56502 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752021AbdBILYM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 06:24:12 -0500
Content-Disposition: inline
In-Reply-To: <2664f74a3821c493b1b8beea4bc5c4077e994243.1486573728.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 01:18:19AM +0800, Xin Long wrote:
> This patch is to define Add Incoming/Outgoing Streams Request
> Parameter described in rfc6525 section 4.5 and 4.6. They can
> be in one same chunk trunk as rfc6525 section 3.1-7 describes,
> so make them in one function.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  include/linux/sctp.h     |  7 +++++++
>  include/net/sctp/sm.h    |  3 +++
>  net/sctp/sm_make_chunk.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 56 insertions(+)
> 
> diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> index 71c0d41..b055788 100644
> --- a/include/linux/sctp.h
> +++ b/include/linux/sctp.h
> @@ -742,4 +742,11 @@ struct sctp_strreset_tsnreq {
>  	__u32 request_seq;
>  };
>  
> +struct sctp_strreset_addstrm {
> +	sctp_paramhdr_t param_hdr;
> +	__u32 request_seq;
> +	__u16 number_of_streams;
> +	__u16 reserved;
> +};
> +
>  #endif /* __LINUX_SCTP_H__ */
> diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
> index ac37c17..3675fde 100644
> --- a/include/net/sctp/sm.h
> +++ b/include/net/sctp/sm.h
> @@ -267,6 +267,9 @@ struct sctp_chunk *sctp_make_strreset_req(
>  				bool out, bool in);
>  struct sctp_chunk *sctp_make_strreset_tsnreq(
>  				const struct sctp_association *asoc);
> +struct sctp_chunk *sctp_make_strreset_addstrm(
> +				const struct sctp_association *asoc,
> +				__u16 out, __u16 in);
>  void sctp_chunk_assign_tsn(struct sctp_chunk *);
>  void sctp_chunk_assign_ssn(struct sctp_chunk *);
>  
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 749842a..7f8dbf2 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3687,3 +3687,49 @@ struct sctp_chunk *sctp_make_strreset_tsnreq(
>  
>  	return retval;
>  }
> +
> +/* RE-CONFIG 4.5/4.6 (ADD STREAM)
> + *   0                   1                   2                   3
> + *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *  |     Parameter Type = 17       |      Parameter Length = 12    |
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *  |          Re-configuration Request Sequence Number             |
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *  |      Number of new streams    |         Reserved              |
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + */
> +struct sctp_chunk *sctp_make_strreset_addstrm(
> +				const struct sctp_association *asoc,
> +				__u16 out, __u16 in)
> +{
> +	struct sctp_strreset_addstrm addstrm;
> +	__u16 size = sizeof(addstrm);
> +	struct sctp_chunk *retval;
> +
> +	retval = sctp_make_reconf(asoc, (!!out + !!in) * size);
> +	if (!retval)
> +		return NULL;
> +
> +	if (out) {
> +		addstrm.param_hdr.type = SCTP_PARAM_RESET_ADD_OUT_STREAMS;
> +		addstrm.param_hdr.length = htons(size);
> +		addstrm.number_of_streams = htons(out);
> +		addstrm.request_seq = htonl(asoc->strreset_outseq);
> +		addstrm.reserved = 0;
> +
> +		sctp_addto_chunk(retval, size, &addstrm);
> +	}
> +
> +	if (in) {
> +		addstrm.param_hdr.type = SCTP_PARAM_RESET_ADD_IN_STREAMS;
> +		addstrm.param_hdr.length = htons(size);
> +		addstrm.number_of_streams = htons(in);
> +		addstrm.request_seq = htonl(asoc->strreset_outseq + !!out);
> +		addstrm.reserved = 0;
> +
> +		sctp_addto_chunk(retval, size, &addstrm);
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
