From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: sctp: sctp_verify_init: clean up mandatory
 checks and add comment
Date: Tue, 27 Aug 2013 09:43:02 -0400
Message-ID: <20130827134302.GB7619@hmsreliant.think-freely.org>
References: <1377609830-10193-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45954 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753655Ab3H0NnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 09:43:11 -0400
Content-Disposition: inline
In-Reply-To: <1377609830-10193-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 03:23:50PM +0200, Daniel Borkmann wrote:
> Add a comment related to RFC4960 explaning why we do not check for initial
> TSN, and while at it, remove yoda notation checks and clean up code from
> checks of mandatory conditions. That's probably just really minor, but makes
> reviewing easier.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/sctp/sm_make_chunk.c | 26 ++++++++++++--------------
>  1 file changed, 12 insertions(+), 14 deletions(-)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 01e9783..c6ca3c9 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -2240,25 +2240,23 @@ int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
>  		     struct sctp_chunk **errp)
>  {
>  	union sctp_params param;
> -	int has_cookie = 0;
> +	bool has_cookie = false;
>  	int result;
>  
> -	/* Verify stream values are non-zero. */
> -	if ((0 == peer_init->init_hdr.num_outbound_streams) ||
> -	    (0 == peer_init->init_hdr.num_inbound_streams) ||
> -	    (0 == peer_init->init_hdr.init_tag) ||
> -	    (SCTP_DEFAULT_MINWINDOW > ntohl(peer_init->init_hdr.a_rwnd))) {
> -
> +	/* Check for missing mandatory parameters. Note: Initial TSN is also
> +	 * mandatory, but not checked here since range is possible from 0 to
> +	 * 2**32-1 (4294967295), RFC4960 3.3.3.
> +	 */
nit: If we're making this easier to review, I think the above would be easier to
read if it said:
Note: Initial TSN is also mandatory, but is not checked here since the valid
range is 0..2**(32-1)

> +	if (peer_init->init_hdr.num_outbound_streams == 0 ||
> +	    peer_init->init_hdr.num_inbound_streams == 0 ||
> +	    peer_init->init_hdr.init_tag == 0 ||
> +	    ntohl(peer_init->init_hdr.a_rwnd) < SCTP_DEFAULT_MINWINDOW)
>  		return sctp_process_inv_mandatory(asoc, chunk, errp);
> -	}
>  
> -	/* Check for missing mandatory parameters.  */
>  	sctp_walk_params(param, peer_init, init_hdr.params) {
> -
> -		if (SCTP_PARAM_STATE_COOKIE == param.p->type)
> -			has_cookie = 1;
> -
> -	} /* for (loop through all parameters) */
> +		if (param.p->type == SCTP_PARAM_STATE_COOKIE)
> +			has_cookie = true;
> +	}
>  
>  	/* There is a possibility that a parameter length was bad and
>  	 * in that case we would have stoped walking the parameters.
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
