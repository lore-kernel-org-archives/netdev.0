From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH v5 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Wed, 15 May 2013 09:56:47 +0800
Message-ID: <CAHrpEqT=yD085tPPpvxG9heL1nHjZM0e7aHdA_2RdQrNWShRdw@mail.gmail.com>
References: <1367971724-1974-1-git-send-email-Frank.Li@freescale.com>
	<20130513045710.GA4440@S2101-09.ap.freescale.net>
	<CAOMZO5AUk0GHKj857a0=Q-dxhpO2s7uatXurNVZV_UmEmtGsqQ@mail.gmail.com>
	<1368559834.4519.23.camel@edumazet-glaptop>
	<CAOMZO5DK6giehS9HpmXMzRKiDvvtEPLxvyenMQaBdrWS8WWVxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Frank Li <Frank.Li@freescale.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:51300 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949Ab3EOB4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 21:56:49 -0400
Received: by mail-wg0-f47.google.com with SMTP id e11so1138520wgh.14
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 18:56:47 -0700 (PDT)
In-Reply-To: <CAOMZO5DK6giehS9HpmXMzRKiDvvtEPLxvyenMQaBdrWS8WWVxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/5/15 Fabio Estevam <festevam@gmail.com>:
> Hi Eric,
>
> On Tue, May 14, 2013 at 4:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> Thats because netif_tx_lock_bh() should be used.
>
> Thanks for your advise.
>
>> And btw, the order of the unlocks should probably be reversed :
>>
>>               netif_tx_unlock_bh(ndev);
>>               netif_wake_queue(ndev);
>>               napi_enable(&fep->napi);
>>               netif_device_attach(ndev);
>
> I tried the change below and do not see the original warning on mx28:
>
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -451,7 +451,7 @@ fec_restart(struct net_device *ndev, int duplex)
>                 netif_device_detach(ndev);
>                 napi_disable(&fep->napi);
>                 netif_stop_queue(ndev);
> -               netif_tx_lock(ndev);
> +               netif_tx_lock_bh(ndev);
>         }
>
>         /* Whack a reset.  We should wait for this. */
> @@ -616,10 +616,10 @@ fec_restart(struct net_device *ndev, int duplex)
>         writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
>
>         if (netif_running(ndev)) {
> -               netif_device_attach(ndev);
> -               napi_enable(&fep->napi);
> +               netif_tx_unlock_bh(ndev);
>                 netif_wake_queue(ndev);
> -               netif_tx_unlock(ndev);
> +               napi_enable(&fep->napi);
> +               netif_device_attach(ndev);
>         }
>  }
>
> Could someone try it on mx6, please?
>
> If it works I can submit the patch tomorrow.

I also find the same solution yesterdays. I tested on MX6. Shawn
tested on MX6 and MX28.
You can submit patch.

best regards
Frank Li
