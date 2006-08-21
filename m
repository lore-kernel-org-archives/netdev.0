From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Patch] Signedness issue in drivers/net/3c515.c
Date: Mon, 21 Aug 2006 14:05:58 -0700
Message-ID: <20060821140558.4cfee23c.akpm@osdl.org>
References: <1156009077.18374.1.camel@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16265 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751104AbWHUVGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 17:06:11 -0400
To: Eric Sesterhenn <snakebyte@gmx.de>
In-Reply-To: <1156009077.18374.1.camel@alice>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 19 Aug 2006 19:37:57 +0200
Eric Sesterhenn <snakebyte@gmx.de> wrote:

> while playing with gcc 4.1 -Wextra warnings, I came across this one:
> 
> drivers/net/3c515.c:1027: warning: comparison of unsigned expression >= 0 is always true
> 
> Since i is unsigned the >= 0 check in the for loop is always true,
> so we might spin there forever unless the if condition triggers.
> Since i is only used in this loop, this patch changes it to
> an integer.
> 
> Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>
> 
> --- linux-2.6.18-rc4/drivers/net/3c515.c.orig	2006-08-19 19:35:04.000000000 +0200
> +++ linux-2.6.18-rc4/drivers/net/3c515.c	2006-08-19 19:35:14.000000000 +0200
> @@ -1003,7 +1003,8 @@ static int corkscrew_start_xmit(struct s
>  		/* Calculate the next Tx descriptor entry. */
>  		int entry = vp->cur_tx % TX_RING_SIZE;
>  		struct boom_tx_desc *prev_entry;
> -		unsigned long flags, i;
> +		unsigned long flags;
> +		int i;
>  
>  		if (vp->tx_full)	/* No room to transmit with */
>  			return 1;

Which affects this loop:

	/* Wait for the stall to complete. */
	for (i = 20; i >= 0; i--)
		if ((inw(ioaddr + EL3_STATUS) & CmdInProgress) == 0) 
			break;

Your fix will convert this indefinit wait into a bounded one.  It might
cause the driver to malfunction.

Given that our pool of 3c515 testers is less than enormous, a more prudent
change might be to remove `i' and simply formalise the existing behaviour
into a while(1) loop.

