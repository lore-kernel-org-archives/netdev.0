From: Philippe De Muyter <phdm@macqel.be>
Subject: Re: [PATCH 1/4] IP100A: Fix TX Pause bug (reset_tx, intr_handler)
Date: Fri, 15 Sep 2006 13:44:48 +0200
Message-ID: <20060915114448.GA7329@ingate.macqel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.macqel.be ([194.78.208.39]:35090 "EHLO mail.macqel.be")
	by vger.kernel.org with ESMTP id S1750989AbWIOLoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2006 07:44:55 -0400
To: Jesse Huang <jesse@icplus.com.tw>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2006 at 12:58:30AM +0000, Jesse Huang wrote:
[...]
> @@ -262,8 +262,6 @@ enum alta_offsets {
>  	ASICCtrl = 0x30,
>  	EEData = 0x34,
>  	EECtrl = 0x36,
> -	TxStartThresh = 0x3c,
> -	RxEarlyThresh = 0x3e,

Why ?

>  	FlashAddr = 0x40,
>  	FlashData = 0x44,
>  	TxStatus = 0x46,
[...]
> @@ -1156,29 +1160,29 @@ static irqreturn_t intr_handler(int irq,
>  						np->stats.tx_fifo_errors++;
>  					if (tx_status & 0x02)
>  						np->stats.tx_window_errors++;
> -					/*
> -					** This reset has been verified on
> -					** DFE-580TX boards ! phdm@macqel.be.
> -					*/
> -					if (tx_status & 0x10) {	/* TxUnderrun */
> -						unsigned short txthreshold;
> -
> -						txthreshold = ioread16 (ioaddr + TxStartThresh);
> -						/* Restart Tx FIFO and transmitter */
> -						sundance_reset(dev, (NetworkReset|FIFOReset|TxReset) << 16);
> -						iowrite16 (txthreshold, ioaddr + TxStartThresh);
> -						/* No need to reset the Tx pointer here */
> +
> +					/* FIFO ERROR need to be reset tx */
> +					if (tx_status & 0x10) {	/* Reset the Tx. */
> +						spin_lock(&np->lock);
> +						reset_tx(dev);
> +						spin_unlock(&np->lock);
> +					}

Just as the comments say, on DFE-580TX 4 port boards, where it is easy to
reproduce TxUnderrun problems, just resetting on the chip the Tx FIFO and
transmitter is enough.
There is no need to call reset_tx, which discards all pending messages and
frees all the skb's.  It is also not necessary to reload the Tx pointer.

Is it different with newer versions of the chip ?

Philippe
