From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Tue, 14 May 2013 12:30:34 -0700
Message-ID: <1368559834.4519.23.camel@edumazet-glaptop>
References: <1367971724-1974-1-git-send-email-Frank.Li@freescale.com>
	 <20130513045710.GA4440@S2101-09.ap.freescale.net>
	 <CAOMZO5AUk0GHKj857a0=Q-dxhpO2s7uatXurNVZV_UmEmtGsqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Guo <shawn.guo@linaro.org>,
	Frank Li <Frank.Li@freescale.com>, romieu@fr.zoreil.com,
	r.schwebel@pengutronix.de, davem@davemloft.net,
	l.stach@pengutronix.de, netdev@vger.kernel.org, lznuaa@gmail.com
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:42490 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755358Ab3ENTah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 15:30:37 -0400
Received: by mail-ie0-f175.google.com with SMTP id s9so1897063iec.20
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 12:30:36 -0700 (PDT)
In-Reply-To: <CAOMZO5AUk0GHKj857a0=Q-dxhpO2s7uatXurNVZV_UmEmtGsqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-14 at 16:27 -0300, Fabio Estevam wrote:
> On Mon, May 13, 2013 at 1:57 AM, Shawn Guo <shawn.guo@linaro.org> wrote:
> 
> > The patch has landed on 3.10-rc1.  Seems that it introduces a lock
> > warning as below.  Turn on CONFIG_PROVE_LOCKING and you will be able
> > to see it.
> 
> This makes the warning goes away on mx28:
> 
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -451,7 +451,6 @@ fec_restart(struct net_device *ndev, int duplex)
>                 netif_device_detach(ndev);
>                 napi_disable(&fep->napi);
>                 netif_stop_queue(ndev);
> -               netif_tx_lock(ndev);
>         }
> 
>         /* Whack a reset.  We should wait for this. */
> @@ -619,7 +618,6 @@ fec_restart(struct net_device *ndev, int duplex)
>                 netif_device_attach(ndev);
>                 napi_enable(&fep->napi);
>                 netif_wake_queue(ndev);
> -               netif_tx_unlock(ndev);
>         }
>  }
> 
> ,but not sure if it looks OK.
> --

Thats because netif_tx_lock_bh() should be used.

And btw, the order of the unlocks should probably be reversed :

              netif_tx_unlock_bh(ndev);
              netif_wake_queue(ndev);
              napi_enable(&fep->napi);
              netif_device_attach(ndev);
