From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [PATCH net-next] cadence: Add hardware PTP support.
Date: Fri, 18 Nov 2016 17:14:51 +0530
Message-ID: <CAFcVECLoMyJJLwAQ_+xN9GNLeVbew7RU_vURZjK94VXH2zS7EA@mail.gmail.com>
References: <1479466028-29914-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
        Andrei Pistirica <Andrei.Pistirica@microchip.com>,
        netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rafal Ozieblo <rafalo@cadence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:35631 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752758AbcKRLoz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 06:44:55 -0500
In-Reply-To: <1479466028-29914-1-git-send-email-rafalo@cadence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rafal

I'm still comparing the full solution but just a couple of things first:
<snip>
> @@ -876,6 +964,17 @@ static int gem_rx(struct macb *bp, int budget)
>                 bp->stats.rx_packets++;
>                 bp->stats.rx_bytes += skb->len;
>
> +#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
> +               if (bp->ptp_hw_support) {
> +                       struct timespec64 ts;
> +
> +                       if (MACB_BFEXT(DMA_RX_TS_VALID, desc->addr)) {
> +                               macb_hw_timestamp(bp, desc->dma_desc_ts_1, desc->dma_desc_ts_2, &ts);
> +                               skb_hwtstamps(skb)->hwtstamp = ktime_set(ts.tv_sec, ts.tv_nsec);
> +                       }
> +               }
> +#endif
> +

I've had to read PTP event registers for upper part of seconds timestamp
in addition to the descriptor (since descriptor only has 5 bits of seconds TS).
I don't know which version of the IP you use - it could be different.
Please let me know so that I can check the spec.
Same with tx timestamp of course.

<snip>
> @@ -1195,6 +1297,87 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
>                                 queue_writel(queue, ISR, MACB_BIT(HRESP));
>                 }
>
> +#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
> +               if (status & MACB_BIT(PTP_DELAY_REQ_FRAME_RECEIVED)) {
> +                       if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +                               queue_writel(queue, ISR, MACB_BIT(PTP_DELAY_REQ_FRAME_RECEIVED));
> +                       if (macb_ptp_time_frame_rx_get(bp, &ts) != 0) {
> +                               ts.tv_sec = 0;
> +                               ts.tv_nsec = 0;
> +                       }
> +                       macb_ptp_event(bp, &ts);
> +               }
> +
> +               if (status & MACB_BIT(PTP_SYNC_FRAME_RECEIVED)) {
> +                       if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +                               queue_writel(queue, ISR, MACB_BIT(PTP_SYNC_FRAME_RECEIVED));
> +                       if (macb_ptp_time_frame_rx_get(bp, &ts) != 0) {
> +                               ts.tv_sec = 0;
> +                               ts.tv_nsec = 0;
> +                       }
> +                       macb_ptp_event(bp, &ts);
> +               }
> +
> +               if (status & MACB_BIT(PTP_DELAY_REQ_FRAME_TRANSMITTED)) {
> +                       if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +                               queue_writel(queue, ISR, MACB_BIT(PTP_DELAY_REQ_FRAME_TRANSMITTED));
> +                       if (macb_ptp_time_frame_tx_get(bp, &ts) != 0) {
> +                               ts.tv_sec = 0;
> +                               ts.tv_nsec = 0;
> +                       }
> +                       macb_ptp_event(bp, &ts);
> +               }
> +
> +               if (status & MACB_BIT(PTP_SYNC_FRAME_TRANSMITTED)) {
> +                       if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +                               queue_writel(queue, ISR, MACB_BIT(PTP_SYNC_FRAME_TRANSMITTED));
> +                       if (macb_ptp_time_frame_tx_get(bp, &ts) != 0) {
> +                               ts.tv_sec = 0;
> +                               ts.tv_nsec = 0;
> +                       }
> +                       macb_ptp_event(bp, &ts);
> +               }
> +
> +               if (status & MACB_BIT(PTP_PDELAY_REQ_FRAME_RECEIVED)) {
> +                       if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +                               queue_writel(queue, ISR, MACB_BIT(PTP_PDELAY_REQ_FRAME_RECEIVED));
> +                       if (macb_ptp_time_peer_frame_rx_get(bp, &ts) != 0) {
> +                               ts.tv_sec = 0;
> +                               ts.tv_nsec = 0;
> +                       }
> +                       macb_ptp_event(bp, &ts);
> +               }
> +
> +               if (status & MACB_BIT(PTP_PDELAY_RESP_FRAME_RECEIVED)) {
> +                       if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +                               queue_writel(queue, ISR, MACB_BIT(PTP_PDELAY_RESP_FRAME_RECEIVED));
> +                       if (macb_ptp_time_peer_frame_rx_get(bp, &ts) != 0) {
> +                               ts.tv_sec = 0;
> +                               ts.tv_nsec = 0;
> +                       }
> +                       macb_ptp_event(bp, &ts);
> +               }
> +
> +               if (status & MACB_BIT(PTP_PDELAY_REQ_FRAME_TRANSMITTED)) {
> +                       if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +                               queue_writel(queue, ISR, MACB_BIT(PTP_PDELAY_REQ_FRAME_TRANSMITTED));
> +                       if (macb_ptp_time_peer_frame_tx_get(bp, &ts) != 0) {
> +                               ts.tv_sec = 0;
> +                               ts.tv_nsec = 0;
> +                       }
> +                       macb_ptp_event(bp, &ts);
> +               }
> +
> +               if (status & MACB_BIT(PTP_PDELAY_RESP_FRAME_TRANSMITTED)) {
> +                       if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +                               queue_writel(queue, ISR, MACB_BIT(PTP_PDELAY_RESP_FRAME_TRANSMITTED));
> +                       if (macb_ptp_time_peer_frame_tx_get(bp, &ts) != 0) {
> +                               ts.tv_sec = 0;
> +                               ts.tv_nsec = 0;
> +                       }
> +                       macb_ptp_event(bp, &ts);
> +               }
> +#endif

I'm not sure of your application and why this is necessary.
Can you please check Andrei's patches and mine and
Richard Cochran's comments?
I use linuxptp to test.

Regards,
Harini
