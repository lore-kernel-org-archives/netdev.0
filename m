From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv6 net-next 2/6] sctp: streams should be recovered when it
 fails to send request.
Date: Wed, 8 Feb 2017 19:56:34 -0200
Message-ID: <20170208215633.GI3414@localhost.localdomain>
References: <cover.1486573727.git.lucien.xin@gmail.com>
 <3d1180fcc5c72dea7d6cb7c7fafae4c4a7782cb3.1486573728.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57316 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751405AbdBHV4i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 16:56:38 -0500
Content-Disposition: inline
In-Reply-To: <3d1180fcc5c72dea7d6cb7c7fafae4c4a7782cb3.1486573728.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 01:18:16AM +0800, Xin Long wrote:
> Now when sending stream reset request, it closes the streams to
> block further xmit of data until this request is completed, then
> calls sctp_send_reconf to send the chunk.
> 
> But if sctp_send_reconf returns err, and it doesn't recover the
> streams' states back,  which means the request chunk would not be
> queued and sent, so the asoc will get stuck, streams are closed
> and no packet is even queued.
> 
> This patch is to fix it by recovering the streams' states when
> it fails to send the request, it is also to fix a return value.
> 
> Fixes: 7f9d68ac944e ("sctp: implement sender-side procedures for SSN Reset Request Parameter")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/stream.c | 19 +++++++++++++++++--
>  1 file changed, 17 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/stream.c b/net/sctp/stream.c
> index 13d5e07..6a686e3 100644
> --- a/net/sctp/stream.c
> +++ b/net/sctp/stream.c
> @@ -136,8 +136,10 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
>  				goto out;
>  
>  	chunk = sctp_make_strreset_req(asoc, str_nums, str_list, out, in);
> -	if (!chunk)
> +	if (!chunk) {
> +		retval = -ENOMEM;
>  		goto out;
> +	}
>  
>  	if (out) {
>  		if (str_nums)
> @@ -149,7 +151,6 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
>  				stream->out[i].state = SCTP_STREAM_CLOSED;
>  	}
>  
> -	asoc->strreset_outstanding = out + in;
>  	asoc->strreset_chunk = chunk;
>  	sctp_chunk_hold(asoc->strreset_chunk);
>  
> @@ -157,8 +158,22 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
>  	if (retval) {
>  		sctp_chunk_put(asoc->strreset_chunk);
>  		asoc->strreset_chunk = NULL;
> +		if (!out)
> +			goto out;
> +
> +		if (str_nums)
> +			for (i = 0; i < str_nums; i++)
> +				stream->out[str_list[i]].state =
> +						       SCTP_STREAM_OPEN;
> +		else
> +			for (i = 0; i < stream->outcnt; i++)
> +				stream->out[i].state = SCTP_STREAM_OPEN;
> +
> +		goto out;
>  	}
>  
> +	asoc->strreset_outstanding = out + in;
> +
>  out:
>  	return retval;
>  }
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
