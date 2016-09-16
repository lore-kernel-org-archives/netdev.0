From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Modification to skb->queue_mapping affecting performance
Date: Fri, 16 Sep 2016 12:53:59 -0700
Message-ID: <1474055639.22679.74.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAmHdhxyrwJXHysUU6KoXeTaRHK8Mxr5PH9j4drR_87T+Wnypg@mail.gmail.com>
         <1473808021.18970.246.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAmHdhw6JXYtYNjcJchieW-KcwRkNnFmXTRTXrLQS_Kh+rfP2w@mail.gmail.com>
         <1473811749.18970.259.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAmHdhy_=GJKBE9=YD2n8MZOaBzD_JJrk4i8Rq43ob2HbWqbCA@mail.gmail.com>
         <1473815917.18970.266.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAmHdhxGBBOCebkvq43pwsaZ8HcULZmXnikQAtc2uLBMWZgXjA@mail.gmail.com>
         <1473830571.22679.4.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAmHdhzKyZ0M_L6OSxaOoLwf4u-T+yFOvBckaiq9OpVJA7Ca0A@mail.gmail.com>
         <CAAmHdhyhywBPhHgB5ySXwhvvSAnxUwkCNQrhnLY9WxoMbAYqoQ@mail.gmail.com>
         <CAAmHdhx7uvg_q49oz_u8q6NYmv=okxmKg1Tc5ny6oRCvaxbnww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33074 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933663AbcIPTyC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 15:54:02 -0400
Received: by mail-pa0-f44.google.com with SMTP id cm16so28856907pac.0
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 12:54:02 -0700 (PDT)
In-Reply-To: <CAAmHdhx7uvg_q49oz_u8q6NYmv=okxmKg1Tc5ny6oRCvaxbnww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-16 at 10:57 -0700, Michael Ma wrote:

> This is actually the problem - if flows from different RX queues are
> switched to the same RX queue in IFB, they'll use different processor
> context with the same tasklet, and the processor context of different
> tasklets might be the same. So multiple tasklets in IFB competes for
> the same core when queue is switched.
> 
> The following simple fix proved this - with this change even switching
> the queue won't affect small packet bandwidth/latency anymore:
> 
> in ifb.c:
> 
> -       struct ifb_q_private *txp = dp->tx_private + skb_get_queue_mapping(skb);
> +       struct ifb_q_private *txp = dp->tx_private +
> (smp_processor_id() % dev->num_tx_queues);
> 
> This should be more efficient since we're not sending the task to a
> different processor, instead we try to queue the packet to an
> appropriate tasklet based on the processor ID. Will this cause any
> packet out-of-order problem? If packets from the same flow are queued
> to the same RX queue due to RSS, and processor affinity is set for RX
> queues, I assume packets from the same flow will end up in the same
> core when tasklet is scheduled. But I might have missed some uncommon
> cases here... Would appreciate if anyone can provide more insights.

Wait, don't you have proper smp affinity for the RX queues on your NIC ?

( Documentation/networking/scaling.txt RSS IRQ Configuration )

A driver ndo_start_xmit() MUST use skb_get_queue_mapping(skb), because
the driver queue is locked before ndo_start_xmit())  (for non
NETIF_F_LLTX drivers at least)

In case of ifb, __skb_queue_tail(&txp->rq, skb); could corrupt the skb
list.

In any case, you could have an action to do this before reaching IFB.
