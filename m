From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Lksctp-developers] [PATCH] SCTP: Fix kernel panic while
	received AUTH chunk with BAD shared key identifier
Date: Thu, 24 Jan 2008 07:16:08 -0500
Message-ID: <20080124121608.GA20633@hmsreliant.think-freely.org>
References: <4795A960.7000700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>,
	lksctp-developers@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2140 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529AbYAXMSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 07:18:44 -0500
Content-Disposition: inline
In-Reply-To: <4795A960.7000700@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2008 at 05:29:20PM +0900, Wei Yongjun wrote:
> 
> 
> This patch fix this problem.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> --- a/net/sctp/auth.c	2008-01-21 00:03:25.000000000 -0500
> +++ b/net/sctp/auth.c	2008-01-21 21:31:47.000000000 -0500
> @@ -420,15 +420,15 @@ struct sctp_shared_key *sctp_auth_get_sh
>  				const struct sctp_association *asoc,
>  				__u16 key_id)
>  {
> -	struct sctp_shared_key *key = NULL;
> +	struct sctp_shared_key *key;
>  
>  	/* First search associations set of endpoint pair shared keys */
>  	key_for_each(key, &asoc->endpoint_shared_keys) {
>  		if (key->key_id == key_id)
> -			break;
> +			return key;
>  	}
>  
> -	return key;
> +	return NULL;
>  }
>  
>  /*
> 

FWIW, Ack from me.  The assignment of NULL to key can safely be removed, since
key_for_each (which is just list_for_each_entry under the covers does an initial
assignment to key anyway). 

If the endpoint_shared_keys list is empty, or if the key_id being requested does
not exist, the function as it currently stands returns the actuall list_head (in
this case endpoint_shared_keys.  Since that list_head isn't surrounded by an
actuall data structure, the last iteration through list_for_each_entry will do a
container_of on key, and we wind up returning a bogus pointer, instead of NULL,
as we should.  Wei's patch corrects that.

Regards
Neil

Acked-by: Neil Horman <nhorman@tuxdriver.com>

> 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2008.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> Lksctp-developers mailing list
> Lksctp-developers@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lksctp-developers
