From: Andre Naujoks <nautsch@gmail.com>
Subject: Re: [PATCH net/stable] can bcm: fix tx_setup off-by-one errors
Date: Tue, 27 Sep 2011 23:09:16 +0200
Message-ID: <4E823B7C.4040906@gmail.com>
References: <4E7CCEB3.4050408@hartkopp.net>
Reply-To: nautsch@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44333 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab1I0VJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 17:09:21 -0400
Received: by fxe4 with SMTP id 4so7549398fxe.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 14:09:20 -0700 (PDT)
In-Reply-To: <4E7CCEB3.4050408@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 23.09.2011 20:23, schrieb Oliver Hartkopp:
> This patch fixes two off-by-one errors that canceled each other out.
> Checking for the same condition two times in bcm_tx_timeout_tsklet() reduced
> the count of frames to be sent by one. This did not show up the first time
> tx_setup is invoked as an additional frame is sent due to TX_ANNONCE.
> Invoking a second tx_setup on the same item led to a reduced (by 1) number of
> sent frames.
> 
> Reported-by: Andre Naujoks <nautsch@gmail.com>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Tested by: Andre Naujoks <nautsch@gmail.com>

> 
> ---
> 
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index d6c8ae5..c9cdb8d 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -365,9 +365,6 @@ static void bcm_tx_timeout_tsklet(unsigned long data)
>  
>  			bcm_send_to_user(op, &msg_head, NULL, 0);
>  		}
> -	}
> -
> -	if (op->kt_ival1.tv64 && (op->count > 0)) {
>  
>  		/* send (next) frame */
>  		bcm_can_tx(op);
> @@ -970,8 +967,9 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
>  		/* spec: send can_frame when starting timer */
>  		op->flags |= TX_ANNOUNCE;
>  
> -		if (op->kt_ival1.tv64 && (op->count > 0)) {
> -			/* op->count-- is done in bcm_tx_timeout_handler */
> +		/* only start timer when having more frames than sent below */
> +		if (op->kt_ival1.tv64 && (op->count > 1)) {
> +			/* op->count-- is done in bcm_tx_timeout_tsklet */
>  			hrtimer_start(&op->timer, op->kt_ival1,
>  				      HRTIMER_MODE_REL);
>  		} else
> @@ -979,8 +977,11 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
>  				      HRTIMER_MODE_REL);
>  	}
>  
> -	if (op->flags & TX_ANNOUNCE)
> +	if (op->flags & TX_ANNOUNCE) {
>  		bcm_can_tx(op);
> +		if (op->kt_ival1.tv64 && (op->count > 0))
> +			op->count--;
> +	}
>  
>  	return msg_head->nframes * CFSIZ + MHSIZ;
>  }
> 
