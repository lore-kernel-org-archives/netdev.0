From: Carsten Paeth <calle@calle.in-berlin.de>
Subject: Re: Possible race in c4.ko
Date: Wed, 16 Aug 2017 06:55:37 +0200
Message-ID: <20170816045537.kvadru5f57cr44o6@calle.in-berlin.de>
References: <b839c418-9c1d-aba7-4d00-e9c7786870bf@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: isdn@linux-pingi.de, davem@davemloft.net, calle@calle.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org,
        Alexey Khoroshilov <khoroshilov@ispras.ru>
To: Anton Volkov <avolkov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b839c418-9c1d-aba7-4d00-e9c7786870bf@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Anton,

Thanks for reviewing the code.

This would be right, if the c4 could rise an interrupt at this moment ...

After a reset with c4_reset(), the card will not generate an interrupt,
until firmware has been loaded and the SEND_INIT message has been sent.
c4_load_firmware() -> c4_send_init() sets the card number in the card.

Therefor it's not an issue.

best regards,

calle

Tue, Aug 15, 2017 at 04:22:16PM +0300, Anton Volkov schrieb:
> Hello.
> 
> While searching for races in the Linux kernel I've come across
> "drivers/isdn/hardware/avm/c4.ko" module. Here is a question that I came up
> with while analyzing results. Lines are given using the info from Linux
> v4.12.
> 
> Consider the following case:
> 
> Thread 1:                  Thread 2:
> c4_probe
> ->c4_add_card
>     request_irq()
>                            c4_interrupt
>                            ->c4_handle_interrupt
>                              ->c4_handle_rx
>     card->cardnr = ...         cidx = f(card->cardnr)
>     (c4.c: line 1227)          (c4.c: line 526)
>                                if (cidx >= card->nlogcontr) cidx = 0;
>                                ctrl = &card->ctrlinfo[cidx].capi_ctrl
> 
> card->cardnr is 0 until it is initialized in c4_add_card(). If at the moment
> of read access in c4_handle_rx() it is still 0, cidx may then be assigned an
> undesirable value and wrong controller may handle messages. Is this case
> feasible from your point of view?
> 
> Thank you for your time.
> 
> -- Anton Volkov
> Linux Verification Center, ISPRAS
> web: http://linuxtesting.org
> e-mail: avolkov@ispras.ru
