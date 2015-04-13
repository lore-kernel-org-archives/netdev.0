From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v4 2/9] bgmac: leave interrupts disabled as long as there
 is work to do
Date: Mon, 13 Apr 2015 16:34:21 +0200
Message-ID: <CACna6rxgjUPdMsnhgvoRQLaOZ+T1epyvj3cDbZnYRtOeG0irtA@mail.gmail.com>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org>
	<1428933162-26763-2-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33826 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753423AbbDMOeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:34:22 -0400
Received: by iedfl3 with SMTP id fl3so75357293ied.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 07:34:22 -0700 (PDT)
In-Reply-To: <1428933162-26763-2-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 April 2015 at 15:52, Felix Fietkau <nbd@openwrt.org> wrote:
> Always poll rx and tx during NAPI poll instead of relying on the status
> of the first interrupt. This prevents bgmac_poll from leaving unfinished
> work around until the next IRQ.
> In my tests this makes bridging/routing throughput under heavy load more
> stable and ensures that no new IRQs arrive as long as bgmac_poll uses up
> the entire budget.

What do you think about keeping u32 int_status; and just updating it
at the end of bgmac_poll? In case you decide to implement multiple TX
queues, it may be cheaper to just check a single bit in memory instead
reading DMA ring status.


> @@ -1221,14 +1219,13 @@ static irqreturn_t bgmac_interrupt(int irq, void *dev_id)
>         if (!int_status)
>                 return IRQ_NONE;
>
> -       /* Ack */
> -       bgmac_write(bgmac, BGMAC_INT_STATUS, int_status);
> +       int_status &= ~(BGMAC_IS_TX0 | BGMAC_IS_RX);
> +       if (int_status)
> +               bgmac_err(bgmac, "Unknown IRQs: 0x%08X\n", int_status);
>
>         /* Disable new interrupts until handling existing ones */
>         bgmac_chip_intrs_off(bgmac);
>
> -       bgmac->int_status = int_status;
> -
>         napi_schedule(&bgmac->napi);
>
>         return IRQ_HANDLED;
> @@ -1237,25 +1234,17 @@ static irqreturn_t bgmac_interrupt(int irq, void *dev_id)
>  static int bgmac_poll(struct napi_struct *napi, int weight)
>  {
>         struct bgmac *bgmac = container_of(napi, struct bgmac, napi);
> -       struct bgmac_dma_ring *ring;
>         int handled = 0;
>
> -       if (bgmac->int_status & BGMAC_IS_TX0) {
> -               ring = &bgmac->tx_ring[0];
> -               bgmac_dma_tx_free(bgmac, ring);
> -               bgmac->int_status &= ~BGMAC_IS_TX0;
> -       }
> +       /* Ack */
> +       bgmac_write(bgmac, BGMAC_INT_STATUS, ~0);

Is this OK to ack every IRQ, even un handled ones?


> +       /* poll again if more events arrived in the mean time */
> +       if (bgmac_read(bgmac, BGMAC_INT_STATUS) & (BGMAC_IS_TX0 | BGMAC_IS_RX))
> +               return handled;

s/mean time/meantime/ (or meanwhile)
And if you care to keep one type of comments:
s/poll/Poll/
