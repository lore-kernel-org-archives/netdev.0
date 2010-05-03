From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: Avoid race in sky2_change_mtu
Date: Mon, 3 May 2010 16:26:34 -0700
Message-ID: <20100503162634.1f004023@nehalam>
References: <4BDEDB50.7000707@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35341 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759865Ab0ECX0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 19:26:49 -0400
In-Reply-To: <4BDEDB50.7000707@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 May 2010 23:18:56 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> netif_stop_queue does not ensure all in-progress transmits are complete,
>  so use netif_tx_disable() instead.
> 
> Make sure NAPI polls are disabled, otherwise NAPI might trigger a TX
>  restart between when we stop the queue and NAPI is disabled.

How could NAPI trigger a TX restart? Restart is a timer, not controlled
by NAPI. There is a different race that your patch isn't covering.

If a large MTU send is in progress while mtu is changing, the changes
to the GMAC store and forward (sky2_set_tx_stfwd) are not synchronized
with hardware queued transmits.

So I think a there needs to be another spinloop.

--- a/drivers/net/sky2.c	2010-05-03 16:19:58.828106182 -0700
+++ b/drivers/net/sky2.c	2010-05-03 16:24:37.850232475 -0700
@@ -2274,8 +2274,12 @@ static int sky2_change_mtu(struct net_de
 	imask = sky2_read32(hw, B0_IMSK);
 	sky2_write32(hw, B0_IMSK, 0);
 
-	dev->trans_start = jiffies;	/* prevent tx timeout */
 	netif_stop_queue(dev);
+
+	/* Wait for ongoing Tx to complete */
+	while (sky2->tx_cons != sky2->tx_prod)
+		udelay(10);
+
 	napi_disable(&hw->napi);
 
 	synchronize_irq(hw->pdev->irq);
