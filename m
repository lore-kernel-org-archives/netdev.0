From: steve@chygwyn.com
Subject: Re: [PATCH] decnet: incorrect optlen size
Date: Thu, 29 Jan 2009 08:58:58 +0000
Message-ID: <20090129085858.GA14198@fogou.chygwyn.com>
References: <498166FB.5030104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: christine.caulfield@googlemail.com,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:56628 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397AbZA2KWc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 05:22:32 -0500
Content-Disposition: inline
In-Reply-To: <498166FB.5030104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Jan 29, 2009 at 09:21:15AM +0100, Roel Kluin wrote:
> Several functions with something like this occur:
> 
> int sock_set_foo(int optlen, ...)
> {
> 	struct food foo;
> 
> 	if (optlen < sizeof(foo))
> 		return -EINVAL;
> 
> 	if (copy_from_user(&foo, optval, sizeof(foo)))
> 		return -EFAULT;
> 	...
> }
> 
> see for instance:
> grep -C5 -E -R -n "copy_from_user\(&([a-zA-Z0-9]*), optval, sizeof\(\1\)\)" net
> 
> but in __dn_setsockopt, below, the checks are slightly different.
> Should maybe the changes below be apllied?
> 
> -------------->8----------------8<-----------------------
> fix size checks before copy_from_user
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
> index cf0e184..45b9199 100644
> --- a/net/decnet/af_decnet.c
> +++ b/net/decnet/af_decnet.c
> @@ -1359,10 +1359,10 @@ static int __dn_setsockopt(struct socket *sock, int level,int optname, char __us
>  	if (optlen && !optval)
>  		return -EINVAL;
>  
> -	if (optlen > sizeof(u))
> +	if (optlen < sizeof(u))
>  		return -EINVAL;
>
I don't see that this makes sense... we want to ensure that the passed
length is less than the size of the union which we are going to use
as a buffer.
  
> -	if (copy_from_user(&u, optval, optlen))
> +	if (copy_from_user(&u, optval, sizeof(u)))
>  		return -EFAULT;
>
 ... and here we only want to copy the amount of data that has actually
been supplied, not the whole buffer size since in many cases the
amount of data is less than the total buffer size.

The only sensible addition that I can see, would be to zero out the
buffer before the copy to ensure that we don't land up using data
from the stack in the case that the supplied data is less than that
required for a particular command.

Steve.
