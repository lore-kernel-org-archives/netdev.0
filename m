From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [RFC PATCH net] sctp: ASCONF-ACK with Unresolvable Address
 should be sent
Date: Mon, 27 Jul 2015 10:44:26 -0300
Message-ID: <20150727134426.GS1730@localhost.localdomain>
References: <1437800888-17413-1-git-send-email-lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54820 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753289AbbG0No2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 09:44:28 -0400
Content-Disposition: inline
In-Reply-To: <1437800888-17413-1-git-send-email-lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 25, 2015 at 01:08:08PM +0800, Xin Long wrote:
> RFC 5061:
>     This is an opaque integer assigned by the sender to identify each
>     request parameter.  The receiver of the ASCONF Chunk will copy this
>     32-bit value into the ASCONF Response Correlation ID field of the
>     ASCONF-ACK response parameter.  The sender of the ASCONF can use this
>     same value in the ASCONF-ACK to find which request the response is
>     for.  Note that the receiver MUST NOT change this 32-bit value.
> 
>     Address Parameter: TLV
> 
>     This field contains an IPv4 or IPv6 address parameter, as described
>     in Section 3.3.2.1 of [RFC4960].
> 
> ASCONF chunk with Error Cause Indication Parameter (Unresolvable Address)
> should be sent if the Delete IP Address is not part of the association.
> 
>   Endpoint A                           Endpoint B
>   (ESTABLISHED)                        (ESTABLISHED)
> 
>   ASCONF        ----------------->
>   (Delete IP Address)
>                 <-----------------      ASCONF-ACK
>                                         (Unresolvable Address)
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/sm_make_chunk.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 06320c8..6e399f6 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3090,8 +3090,19 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
>  			sctp_assoc_set_primary(asoc, asconf->transport);
>  			sctp_assoc_del_nonprimary_peers(asoc,
>  							asconf->transport);
> -		} else
> -			sctp_assoc_del_peer(asoc, &addr);
> +			return SCTP_ERROR_NO_ERROR;
> +		}
> +
> +		/* If the address is not part of the association, the
> +		 * ASCONF-ACK with Error Cause Indication Parameter
> +		 * which including cause of Unresolvable Address should
> +		 * be sent.
> +		 */
> +		peer = sctp_assoc_lookup_paddr(asoc, &addr);
> +		if (!peer)
> +			return SCTP_ERROR_DNS_FAILED;
> +
> +		sctp_assoc_rm_peer(asoc, peer);
>  		break;
>  	case SCTP_PARAM_SET_PRIMARY:
>  		/* ADDIP Section 4.2.4
> -- 
> 2.1.0
> 

Looks good to me.

  Marcelo
