From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH] NET: mkiss/6pack: Fix SIOCSIFENCAP ioctl
Date: Sat, 11 Feb 2017 11:53:09 +0100
Message-ID: <589EED15.8090303@bfs.de>
References: <20170210230121.GA27466@linux-mips.org>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Thomas Osterried <thomas@osterried.de>,
        linux-hams@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02-sz.bfs.de ([194.94.69.103]:37993 "EHLO mx02-sz.bfs.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752936AbdBKKxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 11 Feb 2017 05:53:16 -0500
In-Reply-To: <20170210230121.GA27466@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 11.02.2017 00:01, schrieb Ralf Baechle:
> When looking at Thomas' mkiss fix 7ba1b6890387 ("NET: mkiss: Fix panic")
> I noticed that the mkiss SIOCSIFENCAPS ioctl was also doing a slightly
> strange assignment 
> 
>                dev->hard_header_len = AX25_KISS_HEADER_LEN +
>                                       AX25_MAX_HEADER_LEN + 3;
> 
> AX25_MAX_HEADER_LEN already accounts for the KISS byte so adding
> AX25_KISS_HEADER_LEN is a double allocation nor does the "+ 3" seem to
> be necessary.  So this can be simplified to
> 
>                dev->hard_header_len = AX25_MAX_HEADER_LEN
> 
> which after the preceeding fix is a redundant assignment of what
> ax_setup has already assigned so delete the line.  The assignments
> to dev->addr_len and dev->type are similarly redundant.
> 
> The SIOCSIFENCAP argument was never checked for validity.  Check that
> it is 4 and return -EINVAL if not.  The magic constant 4 dates back to
> the days when KISS was handled by the SLIP driver where it had the
> symbol name SL_MODE_AX25.
> 
> Since however mkiss.c only supports a single encapsulation mode there
> is no point in storing it in struct mkiss so delete all that.
> 
> Note that while useless we can't delete the SIOCSIFENCAP ioctl as
> kissattach(8) is still using it and without mkiss issuing a
> SIOCSIFENCAP ioctl an older kernel that does not have Thomas' mkiss fix
> would still panic on attempt to transmit via mkiss.
> 
> 6pack was suffering from the same issue except there SIOCGIFENCAP was
> return 0 for the encapsulation while the spattach utility was passing 4
> for the mode, so the mode check added for 6pack is a bit more lenient
> allow the values 0 and 4 to be set.  That way we retain the option
> to set different encapsulation modes for future extensions.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
>  drivers/net/hamradio/6pack.c | 10 ++++------
>  drivers/net/hamradio/mkiss.c | 10 ++++------
>  2 files changed, 8 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
> index 470b3dc..d949b9f 100644
> --- a/drivers/net/hamradio/6pack.c
> +++ b/drivers/net/hamradio/6pack.c
> @@ -104,7 +104,6 @@ struct sixpack {
>  	int			buffsize;       /* Max buffers sizes */
>  
>  	unsigned long		flags;		/* Flag values/ mode etc */
> -	unsigned char		mode;		/* 6pack mode */
>  
>  	/* 6pack stuff */
>  	unsigned char		tx_delay;
> @@ -723,11 +722,10 @@ static int sixpack_ioctl(struct tty_struct *tty, struct file *file,
>  			break;
>  		}
>  
> -		sp->mode = tmp;
> -		dev->addr_len        = AX25_ADDR_LEN;
> -		dev->hard_header_len = AX25_KISS_HEADER_LEN +
> -		                       AX25_MAX_HEADER_LEN + 3;
> -		dev->type            = ARPHRD_AX25;
> +		if (tmp != 0 && tmp != 4) {
> +			err = -EINVAL;
> +			break;
> +		}
>  

What is about a comment like:
/*
The magic constant 4 dates back to the days when KISS was handled by the SLIP driver where it had the
 symbol name SL_MODE_AX25.
*/

just not to confuse future readers ..

re,
 wh


>  		err = 0;
>  		break;
> diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
> index 1dfe230..cdaf819 100644
> --- a/drivers/net/hamradio/mkiss.c
> +++ b/drivers/net/hamradio/mkiss.c
> @@ -71,7 +71,6 @@ struct mkiss {
>  #define AXF_KEEPTEST	3		/* Keepalive test flag		*/
>  #define AXF_OUTWAIT	4		/* is outpacket was flag	*/
>  
> -	int		mode;
>          int		crcmode;	/* MW: for FlexNet, SMACK etc.  */
>  	int		crcauto;	/* CRC auto mode */
>  
> @@ -841,11 +840,10 @@ static int mkiss_ioctl(struct tty_struct *tty, struct file *file,
>  			break;
>  		}
>  
> -		ax->mode = tmp;
> -		dev->addr_len        = AX25_ADDR_LEN;
> -		dev->hard_header_len = AX25_KISS_HEADER_LEN +
> -		                       AX25_MAX_HEADER_LEN + 3;
> -		dev->type            = ARPHRD_AX25;
> +		if (tmp != 4) {
> +			err = -EINVAL;
> +			break;
> +		}
>  
>  		err = 0;
>  		break;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-hams" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
