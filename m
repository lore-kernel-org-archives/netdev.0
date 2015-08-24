From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] sctp: asconf's process should verify address parameter
 is in the beginning
Date: Mon, 24 Aug 2015 13:33:48 -0400
Message-ID: <55DB557C.6090506@redhat.com>
References: <87d339ea910a3665c9376b6ba69b003af967c6d1.1440410878.git.lucien.xin@gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39431 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932242AbbHXRdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2015 13:33:51 -0400
In-Reply-To: <87d339ea910a3665c9376b6ba69b003af967c6d1.1440410878.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2015 06:07 AM, Xin Long wrote:
> in sctp_process_asconf(), we get address parameter from the beginning of the
> addip params. but we never check if it's really there. if the addr param is not
> there, it still can pass sctp_verify_asconf(), then to be handled by
> sctp_process_asconf(), it will not be safe.
> 
> so add a code in sctp_verify_asconf() to check the address parameter is in the
> beginning, or return false to send abort.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/sm_make_chunk.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 0ee5ca7..a2a72d5 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3122,6 +3122,14 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
>  	union sctp_params param;
>  	bool addr_param_seen = false;
>  
> +	if(addr_param_needed){
> +		/* Ensure the address parameter is in the beginning */
> +		param.v = chunk->skb->data + sizeof(sctp_addiphdr_t);
> +		if (param.p->type != SCTP_PARAM_IPV4_ADDRESS &&
> +		    param.p->type != SCTP_PARAM_IPV6_ADDRESS)
> +			return false;
> +	}
> +

Sorry, you can't do that directly without a lot more checks.  The parameer
may be only only partial, or may not be there at all.  You'd end up looking
at wrong mememory.

A better way would be to set the addr_param_seen only when looking at
the first parameter (addip_hdr.params).

-vlad

>  	sctp_walk_params(param, addip, addip_hdr.params) {
>  		size_t length = ntohs(param.p->length);
>  
> 
