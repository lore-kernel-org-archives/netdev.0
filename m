From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v5 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Tue, 14 May 2013 16:40:32 -0300
Message-ID: <CAOMZO5DK6giehS9HpmXMzRKiDvvtEPLxvyenMQaBdrWS8WWVxw@mail.gmail.com>
References: <1367971724-1974-1-git-send-email-Frank.Li@freescale.com>
	<20130513045710.GA4440@S2101-09.ap.freescale.net>
	<CAOMZO5AUk0GHKj857a0=Q-dxhpO2s7uatXurNVZV_UmEmtGsqQ@mail.gmail.com>
	<1368559834.4519.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shawn Guo <shawn.guo@linaro.org>,
	Frank Li <Frank.Li@freescale.com>, romieu@fr.zoreil.com,
	r.schwebel@pengutronix.de, davem@davemloft.net,
	l.stach@pengutronix.de, netdev@vger.kernel.org, lznuaa@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f169.google.com ([209.85.220.169]:40956 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656Ab3ENTkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 15:40:32 -0400
Received: by mail-vc0-f169.google.com with SMTP id kw10so1029430vcb.14
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 12:40:32 -0700 (PDT)
In-Reply-To: <1368559834.4519.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Tue, May 14, 2013 at 4:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Thats because netif_tx_lock_bh() should be used.

Thanks for your advise.

> And btw, the order of the unlocks should probably be reversed :
>
>               netif_tx_unlock_bh(ndev);
>               netif_wake_queue(ndev);
>               napi_enable(&fep->napi);
>               netif_device_attach(ndev);

I tried the change below and do not see the original warning on mx28:

--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -451,7 +451,7 @@ fec_restart(struct net_device *ndev, int duplex)
                netif_device_detach(ndev);
                napi_disable(&fep->napi);
                netif_stop_queue(ndev);
-               netif_tx_lock(ndev);
+               netif_tx_lock_bh(ndev);
        }

        /* Whack a reset.  We should wait for this. */
@@ -616,10 +616,10 @@ fec_restart(struct net_device *ndev, int duplex)
        writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);

        if (netif_running(ndev)) {
-               netif_device_attach(ndev);
-               napi_enable(&fep->napi);
+               netif_tx_unlock_bh(ndev);
                netif_wake_queue(ndev);
-               netif_tx_unlock(ndev);
+               napi_enable(&fep->napi);
+               netif_device_attach(ndev);
        }
 }

Could someone try it on mx6, please?

If it works I can submit the patch tomorrow.
