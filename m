From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net v2] sctp: ASCONF-ACK with Unresolvable Address should
 be sent
Date: Fri, 28 Aug 2015 08:43:26 -0400
Message-ID: <55E0576E.4050908@gmail.com>
References: <bf1cc62ac51821f36b0e195fa610544d7c4808d7.1440755158.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, davem@davemloft.net, vyasevic@redhat.com
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:36657 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbbH1Mna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 08:43:30 -0400
Received: by qkda128 with SMTP id a128so27041470qkd.3
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 05:43:28 -0700 (PDT)
In-Reply-To: <bf1cc62ac51821f36b0e195fa610544d7c4808d7.1440755158.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2015 05:45 AM, Xin Long wrote:
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

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>  net/sctp/sm_make_chunk.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 4068fe1..ce7f343 100644
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
> 
