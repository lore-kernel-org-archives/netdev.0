From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 14/37] dccp: Tidy up setsockopt calls
Date: Thu, 28 Aug 2008 18:35:41 -0300
Message-ID: <20080828213541.GS9193@ghostprotocols.net>
References: <1219945512-7723-6-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-11-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-12-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-13-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-14-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36045 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755710AbYH1Vk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 17:40:29 -0400
Content-Disposition: inline
In-Reply-To: <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Aug 28, 2008 at 07:44:49PM +0200, Gerrit Renker escreveu:
> This splits the setsockopt calls into two groups, depending on whether an
> integer argument (val) is required and whether routines being called do
> their own locking.
> 
> Some options (such as setting the CCID) use u8 rather than int, so that for
> these the test with regard to integer-sizeof can not be used.
> 
> The second switch-case statement now only has those statements which need
> locking and which make use of `val'.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>



> ---
>  net/dccp/proto.c |   31 ++++++++++++++++---------------
>  1 files changed, 16 insertions(+), 15 deletions(-)
> 
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -511,26 +511,27 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
>  	struct dccp_sock *dp = dccp_sk(sk);
>  	int val, err = 0;
>  
> -	if (optlen < sizeof(int))
> -		return -EINVAL;
> -
> -	if (get_user(val, (int __user *)optval))
> -		return -EFAULT;
> -
> -	if (optname == DCCP_SOCKOPT_SERVICE)
> -		return dccp_setsockopt_service(sk, val, optval, optlen);
> -
> -	lock_sock(sk);
>  	switch (optname) {
>  	case DCCP_SOCKOPT_PACKET_SIZE:
>  		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
> -		err = 0;
> -		break;
> +		return 0;
>  	case DCCP_SOCKOPT_CHANGE_L:
>  	case DCCP_SOCKOPT_CHANGE_R:
>  		DCCP_WARN("sockopt(CHANGE_L/R) is deprecated: fix your app\n");
> -		err = 0;
> -		break;
> +		return 0;
> +	default:
> +		if (optlen < sizeof(int))
> +			return -EINVAL;
> +
> +		if (get_user(val, (int __user *)optval))
> +			return -EFAULT;
> +
> +		if (optname == DCCP_SOCKOPT_SERVICE)
> +			return dccp_setsockopt_service(sk, val, optval, optlen);

What is in the default could well continue outside the switch
statatement, since all the other cases return directly.

Other than that:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

> +	}
> +
> +	lock_sock(sk);
> +	switch (optname) {
>  	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
>  		if (dp->dccps_role != DCCP_ROLE_SERVER)
>  			err = -EOPNOTSUPP;
> @@ -547,8 +548,8 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
>  		err = -ENOPROTOOPT;
>  		break;
>  	}
> -
>  	release_sock(sk);
> +
>  	return err;
>  }
>  
> -- 
> 1.6.0.rc2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
