From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [RFC PATCH net] sctp: ASCONF-ACK with Unresolvable Address
 should be sent
Date: Fri, 24 Jul 2015 16:11:13 -0300
Message-ID: <20150724191113.GO1730@localhost.localdomain>
References: <1437720989-6610-1-git-send-email-lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54027 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbbGXTLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2015 15:11:15 -0400
Content-Disposition: inline
In-Reply-To: <1437720989-6610-1-git-send-email-lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 24, 2015 at 02:56:29PM +0800, Xin Long wrote:
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
>  net/sctp/sm_make_chunk.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 06320c8..88d82ef 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3090,8 +3090,18 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,

Please let's avoid increasing the indentation level when possible

>  			sctp_assoc_set_primary(asoc, asconf->transport);
>  			sctp_assoc_del_nonprimary_peers(asoc,
>  							asconf->transport);
add a return here

> -		} else
> +		} else {
and remove this else {}
and we're good.

sctp code is often too indented, trying to reduce that bit here and
there.

> +			/* If the address is not part of the association, the
> +			 * ASCONF-ACK with Error Cause Indication Parameter
> +			 * which including cause of Unresolvable Address should
> +			 * be sent.
> +			 */
> +			peer = sctp_assoc_lookup_paddr(asoc, &addr);
> +			if (!peer)
> +				return SCTP_ERROR_DNS_FAILED;
> +
>  			sctp_assoc_del_peer(asoc, &addr);

Here we can replace this call to sctp_assoc_rm_peer() , because if we
already have peer, we don't have to search for it again.

Thanks,
Marcelo

> +		}
>  		break;
>  	case SCTP_PARAM_SET_PRIMARY:
>  		/* ADDIP Section 4.2.4
> -- 
> 2.1.0
> 
