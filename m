From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v3] sctp: asconf's process should verify address parameter
 is in the beginning
Date: Wed, 26 Aug 2015 16:42:21 -0400
Message-ID: <55DE24AD.5090507@redhat.com>
References: <a4904b1345d0e96667e8608454c225ae038acbbe.1440621325.git.lucien.xin@gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752722AbbHZUmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 16:42:23 -0400
In-Reply-To: <a4904b1345d0e96667e8608454c225ae038acbbe.1440621325.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2015 04:35 PM, Xin Long wrote:
> in sctp_process_asconf(), we get address parameter from the beginning of
> the addip params. but we never check if it's really there. if the addr
> param is not there, it still can pass sctp_verify_asconf(), then to be
> handled by sctp_process_asconf(), it will not be safe.
> 
> so add a code in sctp_verify_asconf() to check the address parameter is in
> the beginning, or return false to send abort.
> 
> v2->v3:
>  * put the check in the loop, add the check for multiple address parameters.


Please split the multiple address detection from first address detection.
They are 2 different bugs and each one deserves a separate commit and
changelog.

Thanks
-vlad

> v1->v2:
>  * put the check behind the params' length verify.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  net/sctp/sm_make_chunk.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 06320c8..4068fe1 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3130,14 +3130,24 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
>  		case SCTP_PARAM_ERR_CAUSE:
>  			break;
>  		case SCTP_PARAM_IPV4_ADDRESS:
> +			if (addr_param_seen) {
> +				/* peer placed multiple address parameters into
> +				 * the same asconf. reject it.
> +				 */
> +				return false;
> +			}
>  			if (length != sizeof(sctp_ipv4addr_param_t))
>  				return false;
> -			addr_param_seen = true;
> +			if (param.v == addip->addip_hdr.params)
> +				addr_param_seen = true;
>  			break;
>  		case SCTP_PARAM_IPV6_ADDRESS:
> +			if (addr_param_seen)
> +				return false;
>  			if (length != sizeof(sctp_ipv6addr_param_t))
>  				return false;
> -			addr_param_seen = true;
> +			if (param.v == addip->addip_hdr.params)
> +				addr_param_seen = true;
>  			break;
>  		case SCTP_PARAM_ADD_IP:
>  		case SCTP_PARAM_DEL_IP:
> 
