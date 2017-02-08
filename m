From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv6 net-next 4/6] sctp: implement sender-side procedures
 for SSN/TSN Reset Request Parameter
Date: Wed, 8 Feb 2017 19:48:01 -0200
Message-ID: <20170208214801.GF3414@localhost.localdomain>
References: <cover.1486573727.git.lucien.xin@gmail.com>
 <7095f88e0d93a7189df08fec56b3db89deb0397c.1486573728.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38398 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751134AbdBHVsF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 16:48:05 -0500
Content-Disposition: inline
In-Reply-To: <7095f88e0d93a7189df08fec56b3db89deb0397c.1486573728.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Xin,

On Thu, Feb 09, 2017 at 01:18:18AM +0800, Xin Long wrote:
> This patch is to implement Sender-Side Procedures for the SSN/TSN
> Reset Request Parameter descibed in rfc6525 section 5.1.4.
> 
> It is also to add sockopt SCTP_RESET_ASSOC in rfc6525 section 6.3.3
> for users.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
...
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
          ^--- refcnf = 1 (as per sctp_chunkify())

> +	if (!chunk)
> +		return -ENOMEM;
> +
> +	/* Block further xmit of data until this request is completed */
> +	for (i = 0; i < asoc->stream->outcnt; i++)
> +		asoc->stream->out[i].state = SCTP_STREAM_CLOSED;
> +
> +	asoc->strreset_chunk = chunk;
> +	sctp_chunk_hold(asoc->strreset_chunk);
                                 ^--- refcnf = 2
> +
> +	retval = sctp_send_reconf(asoc, chunk);
> +	if (retval) {
> +		sctp_chunk_put(asoc->strreset_chunk);
                                          ^--- refcnf = 1

Won't we leak the chunk here?


> +		asoc->strreset_chunk = NULL;
> +
> +		for (i = 0; i < asoc->stream->outcnt; i++)
> +			asoc->stream->out[i].state = SCTP_STREAM_OPEN;
> +
> +		return retval;
> +	}
> +
> +	asoc->strreset_outstanding = 1;
> +
> +	return 0;
> +}
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
