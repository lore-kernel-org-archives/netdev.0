From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: moxa: fix TX overrun memory leak
Date: Mon, 27 Mar 2017 20:50:26 -0700 (PDT)
Message-ID: <20170327.205026.1935467634311224337.davem@davemloft.net>
References: <1490617879-14014-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: jonas.jensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54666 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbdC1Dub (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 23:50:31 -0400
In-Reply-To: <1490617879-14014-1-git-send-email-jonas.jensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Jensen <jonas.jensen@gmail.com>
Date: Mon, 27 Mar 2017 14:31:19 +0200

> @@ -25,6 +25,7 @@
>  #include <linux/of_irq.h>
>  #include <linux/crc32.h>
>  #include <linux/crc32c.h>
> +#include <linux/circ_buf.h>
>  
>  #include "moxart_ether.h"
>  
> @@ -297,6 +298,7 @@ static void moxart_tx_finished(struct net_device *ndev)
>  		tx_tail = TX_NEXT(tx_tail);
>  	}
>  	priv->tx_tail = tx_tail;
> +	netif_wake_queue(ndev);
>  }
>  
>  static irqreturn_t moxart_mac_interrupt(int irq, void *dev_id)

Doing the wakeup unconditionally is very wasteful, you just need to do it
when enough space has been made available.

Therefore the wakeup should be more like:

	if (netif_queue_stopped(ndev) &&
	    moxart_tx_queue_space(ndev) >= MOXART_TX_WAKEUP_THRESHOLD)
		netif_wake_queue();

Otherwise you're just going to flap back and forth under high load and
get almost not packet batching at all, hurting performance.
