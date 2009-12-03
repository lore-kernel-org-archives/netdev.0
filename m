From: Abraham Arce <abraham.arce.moreno@gmail.com>
Subject: Re: KS8851 SPI Driver Integration
Date: Thu, 3 Dec 2009 12:26:26 -0600
Message-ID: <cb8016980912031026h33551c2bo10d525f0df621e3f@mail.gmail.com>
References: <cb8016980911211610g53a958e8m100238cdcb89cff0@mail.gmail.com>
	 <cb8016980911211616r291b00ddi38a0867e05d947b0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: ben@simtec.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:42776 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754249AbZLCS0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:26:22 -0500
Received: by bwz27 with SMTP id 27so1373093bwz.21
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 10:26:28 -0800 (PST)
In-Reply-To: <cb8016980911211616r291b00ddi38a0867e05d947b0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> I am currently working with ks8851snl driver and facing some issues,
> the system integrated with is OMAP4, a ARM Cortex A9 Dual Core. I am
> using the following commit as latest

I have integrated latest patches from networking tree... driver is
functional with some minor changes at spi and ks8851 level described
below

> * Driver won't be able to get ip address via dhcp if SMP/Preemption/L2
> Cache are enabled, I have not enabled/disabled one by one to narrow
> down the problem...
>

The problem was in in mcspi l2 cache flush operation...

http://dev.omapzoom.org/?p=integration/kernel-omap4.git;a=commit;h=e351961969285d9069fcca9e22f748bb0f20f71d

> * Kernel NULL pointer when trying to mount a nfs directory using
> bootargs or after some time of pinging to any other ip

The following patch needed

http://dev.omapzoom.org/?p=integration/kernel-omap4.git;a=commitdiff;h=dd28c3d44322e98b25e2eb28f51e2e74dffec692

--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -722,12 +722,14 @@ static void ks8851_tx_work(struct work_struct *work)
               txb = skb_dequeue(&ks->txq);
               last = skb_queue_empty(&ks->txq);

-               ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_SDA);
-               ks8851_wrpkt(ks, txb, last);
-               ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr);
-               ks8851_wrreg16(ks, KS_TXQCR, TXQCR_METFE);
+               if (txb != NULL) {
+                       ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_SDA);
+                       ks8851_wrpkt(ks, txb, last);
+                       ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr);
+                       ks8851_wrreg16(ks, KS_TXQCR, TXQCR_METFE);

-               ks8851_done_tx(ks, txb);
+                       ks8851_done_tx(ks, txb);
+               }
       }

       mutex_unlock(&ks->lock);

Best Regards
Abraham
