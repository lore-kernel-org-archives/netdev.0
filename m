From: David Russell <david@aprsworld.com>
Subject: Re: [PATCH] netdev: enc28j60 kernel panic fix.
Date: Mon, 9 May 2016 11:59:47 -0500
Message-ID: <CAEGHc+zPFseHTiXRcHsbX4ptWGDYLEbOcMzRO29jGmOcNqRaww@mail.gmail.com>
References: <CAEGHc+xdoSVa9J_uYm-Az7n4xc+mycy7Jf1p75pss3eVK3jUHA@mail.gmail.com>
	<20160505085110.GA29858@electric-eye.fr.zoreil.com>
	<CAEGHc+ymc3uY0C0WhjfEo5RoS-bQ7h7f6tbBQpAGEJ=D9rr6FA@mail.gmail.com>
	<20160506203546.GA10067@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34026 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbcEIQ7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 12:59:48 -0400
Received: by mail-io0-f177.google.com with SMTP id 190so178828683iow.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 09:59:47 -0700 (PDT)
In-Reply-To: <20160506203546.GA10067@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 6, 2016 at 3:35 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> (please don't top post)

Sorry about that.

> David Russell <david@aprsworld.com> :
>> I kind of thought my patch was at best incomplete.  When you state
>> this change silences the bug but does not fix it, what are the
>> implications of systems running this patch?  We have some production
>> systems using this patch.  They reboot daily, but have been solid.
>
> If my assumption is right it should drop an extra packet here and there.
> No leak.

Lost packets are "acceptable" in this case as much as I hate "Good Enough".

> However transmit errors + transmit packets should still match the number
> of times the driver calls enc28j60_send_packet (you would have to cook
> your own stat to check the latter though).
>
>> In addition, if we sent you a pi and the ethernet controller and a
>> small but reasonable sum of money for your labor, would you be able to
>> properly fix it ?
>
> I'd rather see you testing my crap. :o)
>
> Pi as multi-core (the expected race needs several cores or a netconsole
> style transmit from an irq/bh context) ?

Yes, multi-core ARM.

>> Short of that, do you have any recommendations on quick overviews of
>> the networking stack in the kernel and then documentation on the
>> various flags and such?
>
> A tad bit too high-level a question... Plain ctags + printk for a start ?

I was afraid of that.  I prefer proper documentation/specifications in
addition to source.

> Does the patch below make a difference ?
>
> Takes longer to crash counts as a difference.

As far as I can tell it solves the problem of the kernel panicing.

> diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
> index 7066954..405fe3f 100644
> --- a/drivers/net/ethernet/microchip/enc28j60.c
> +++ b/drivers/net/ethernet/microchip/enc28j60.c
> @@ -1170,7 +1170,8 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
>                                 enc28j60_dump_tsv(priv, "Tx Done", tsv);
>                         }
>                         enc28j60_tx_clear(ndev, err);
> -                       locked_reg_bfclr(priv, EIR, EIR_TXIF);
> +                       locked_reg_bfclr(priv, EIR, EIR_TXIF | EIR_TXERIF);
> +                       intflags &= ~EIR_TXERIF;
>                 }
>                 /* TX Error handler */
>                 if ((intflags & EIR_TXERIF) != 0) {
> @@ -1190,6 +1191,7 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
>                         nolock_reg_bfclr(priv, ECON1, ECON1_TXRST);
>                         nolock_txfifo_init(priv, TXSTART_INIT, TXEND_INIT);
>                         mutex_unlock(&priv->lock);
> +                       locked_reg_bfclr(priv, EIR, EIR_TXIF | EIR_TXERIF);
>                         /* Transmit Late collision check for retransmit */
>                         if (TSV_GETBIT(tsv, TSV_TXLATECOLLISION)) {
>                                 if (netif_msg_tx_err(priv))
> @@ -1203,7 +1205,6 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
>                                         enc28j60_tx_clear(ndev, true);
>                         } else
>                                 enc28j60_tx_clear(ndev, true);
> -                       locked_reg_bfclr(priv, EIR, EIR_TXERIF);
>                 }
>                 /* RX Error handler */
>                 if ((intflags & EIR_RXERIF) != 0) {
