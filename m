From: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Subject: Re: [PATCH][CAN]: Fix copy_from_user() results interpretation.
Date: Fri, 25 Apr 2008 16:22:13 +0200
Message-ID: <4811E915.80303@volkswagen.de>
References: <4811D1A6.909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Thuermann, Urs, Dr. (K-EFFI/I)" <urs.thuermann@volkswagen.de>,
	socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxout1.volkswagen.de ([194.114.62.41]:17765 "EHLO
	mxout1.volkswagen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756649AbYDYO1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 10:27:32 -0400
In-Reply-To: <4811D1A6.909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
>
> Sorry for the noise, I had to check this right after facing this problem
> with the copy_to_user()...
>
> Both copy_to_ and _from_user return the number of bytes, that failed to
> reach their destination, not the 0/-EXXX values.
>
> Other net/ code handles this correctly.
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>

Thanks very much for catching this, Pavel!

Acked-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>

> ---
>
> diff --git a/net/can/raw.c b/net/can/raw.c
> index ead50c7..2be8c6e 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -438,12 +438,12 @@ static int raw_setsockopt(struct socket *sock, 
> int level, int optname,
>                         err = copy_from_user(filter, optval, optlen);
>                         if (err) {
>                                 kfree(filter);
> -                               return err;
> +                               return -EFAULT;
>                         }
>                 } else if (count == 1) {
>                         err = copy_from_user(&sfilter, optval, optlen);
>                         if (err)
> -                               return err;
> +                               return -EFAULT;
>                 }
>  
>                 lock_sock(sk);
> @@ -495,7 +495,7 @@ static int raw_setsockopt(struct socket *sock, int 
> level, int optname,
>  
>                 err = copy_from_user(&err_mask, optval, optlen);
>                 if (err)
> -                       return err;
> +                       return -EFAULT;
>  
>                 err_mask &= CAN_ERR_MASK;
>  
> @@ -531,7 +531,8 @@ static int raw_setsockopt(struct socket *sock, int 
> level, int optname,
>                 if (optlen != sizeof(ro->loopback))
>                         return -EINVAL;
>  
> -               err = copy_from_user(&ro->loopback, optval, optlen);
> +               err = copy_from_user(&ro->loopback, optval, optlen) ?
> +                       -EFAULT : 0;
>  
>                 break;
>  
> @@ -539,7 +540,8 @@ static int raw_setsockopt(struct socket *sock, int 
> level, int optname,
>                 if (optlen != sizeof(ro->recv_own_msgs))
>                         return -EINVAL;
>  
> -               err = copy_from_user(&ro->recv_own_msgs, optval, optlen);
> +               err = copy_from_user(&ro->recv_own_msgs, optval, 
> optlen) ?
> +                       -EFAULT : 0;
>  
>                 break;
>  
>

