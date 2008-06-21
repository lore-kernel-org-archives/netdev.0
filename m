From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH]: SCTP length validation.
Date: Sat, 21 Jun 2008 11:55:19 -0400
Message-ID: <485D2467.7020300@hp.com>
References: <20080620.221205.183623344.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:7930 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbYFUP4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 11:56:16 -0400
In-Reply-To: <20080620.221205.183623344.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I just checked in the following SCTP bug fix to net-2.6 and will make
> sure it gets into -stable as well.
> 
> sctp: Make sure N * sizeof(union sctp_addr) does not overflow.
> 
> As noticed by Gabriel Campana, the kmalloc() length arg
> passed in by sctp_getsockopt_local_addrs_old() can overflow
> if ->addr_num is large enough.
> 
> Therefore, enforce an appropriate limit.

Hi David

The same vulnerability also exists in sctp_getsockopt_peer_addrs_old().
It's a bit more difficult to trigger since there is a dependency on
the peer being multihomed as well, but it's still possible to cause the
overwrite.

-vlad

> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/sctp/socket.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index e7e3baf..0dbcde6 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4401,7 +4401,9 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
>  	if (copy_from_user(&getaddrs, optval, len))
>  		return -EFAULT;
>  
> -	if (getaddrs.addr_num <= 0) return -EINVAL;
> +	if (getaddrs.addr_num <= 0 ||
> +	    getaddrs.addr_num >= (INT_MAX / sizeof(union sctp_addr)))
> +		return -EINVAL;
>  	/*
>  	 *  For UDP-style sockets, id specifies the association to query.
>  	 *  If the id field is set to the value '0' then the locally bound

