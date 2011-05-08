From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] NET: slip, fix ldisc->open retval
Date: Sun, 08 May 2011 19:37:19 +0200
Message-ID: <4DC6D4CF.2080006@hartkopp.net>
References: <BANLkTinWqaoMNHbOb5PbZzewQafWhBfY4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: matvejchikov@gmail.com, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jeff Dike <jdike@addtoit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:39406 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754039Ab1EHRhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 13:37:17 -0400
In-Reply-To: <BANLkTinWqaoMNHbOb5PbZzewQafWhBfY4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.05.2011 18:23, Matvejchikov Ilya wrote:
> TTY layer expects 0 if the ldisc->open operation succeeded.
> 
> Signed-off-by : Matvejchikov Ilya <matvejchikov@gmail.com>
> ---
>  drivers/net/slip.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/slip.c b/drivers/net/slip.c
> index 86cbb9e..8ec1a9a 100644
> --- a/drivers/net/slip.c
> +++ b/drivers/net/slip.c
> @@ -853,7 +853,9 @@ static int slip_open(struct tty_struct *tty)
>  	/* Done.  We have linked the TTY line to a channel. */
>  	rtnl_unlock();
>  	tty->receive_room = 65536;	/* We don't flow control */
> -	return sl->dev->base_addr;
> +
> +	/* TTY layer expects 0 on success */
> +	return 0;
> 
>  err_free_bufs:
>  	sl_free_bufs(sl);

sl->dev->base_addr holds the index into the pointer array of the slip devices.
This is a value >= 0.

The return values of tty_ldisc_open in drivers/tty/tty_ldisc.c are checking
for errors with '< 0' but in some cases they check for '!= 0' which is
correctly addressed in this patch.

Looks reasonable to me.

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Alan?

There is also a slip_open() in arch/um/drivers/slip_user.c which also returns
positive numbers (filedescriptors) having the same issue ... Jeff?

Once this patch is accepted, i would send a similar patch for
drivers/net/can/slcan.c too.

Regards,
Oliver
