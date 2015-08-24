From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] sctp: asconf process should treat multiple address
 parameter as unrecognized parameter
Date: Mon, 24 Aug 2015 13:49:45 -0400
Message-ID: <55DB5939.8030902@redhat.com>
References: <13ab95079875febb3985b32d0fdaf587c6de1973.1440410850.git.lucien.xin@gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33123 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751115AbbHXRtq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2015 13:49:46 -0400
In-Reply-To: <13ab95079875febb3985b32d0fdaf587c6de1973.1440410850.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2015 06:07 AM, Xin Long wrote:
> currently, we sctp_walk_params(), if we encounter the address parameter, we will
> skip them, we do not care about how many addr params are there.
> 
> but the params of ASCONF chunk should consist of one *Address Parameter* and one
> or more *ASCONF Parameters*.
> 
> so we will process multiple address parameters as unrecognized parameter and
> send error cause to peer.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/sm_make_chunk.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 06320c8..0ee5ca7 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3217,10 +3217,18 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
>  
>  	/* Process the TLVs contained within the ASCONF chunk. */
>  	sctp_walk_params(param, addip, addip_hdr.params) {
> -		/* Skip preceeding address parameters. */
> +		/* Skip preceeding address parameters.
> +		 * process multi-addrparam as unrecognized parameters
> +		 */
>  		if (param.p->type == SCTP_PARAM_IPV4_ADDRESS ||
> -		    param.p->type == SCTP_PARAM_IPV6_ADDRESS)
> +		    param.p->type == SCTP_PARAM_IPV6_ADDRESS) {
> +			if(param.addr != addr_param) {
> +				all_param_pass = false;
> +				sctp_add_asconf_response(asconf_ack, 0,
> +					SCTP_ERROR_UNKNOWN_PARAM, param.v);
> +			}
>  			continue;
> +		}
>  

I think it would be much better to catch this in the validation stage.
If an implementation inserts multiple address parameters, we don't really know
which one we should be using.

-vlad

>  		err_code = sctp_process_asconf_param(asoc, asconf,
>  						     param.addip);
> 
