From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH -next 1/2] wan/pc300_drv: convert to net_device_ops
Date: Fri, 17 Apr 2009 05:48:17 +0400
Message-ID: <20090417014817.GA30721@orion>
References: <1239931383-30525-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:64223 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307AbZDQBs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 21:48:26 -0400
Received: by bwz17 with SMTP id 17so680224bwz.37
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 18:48:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1239931383-30525-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 05:23:02AM +0400, Alexander Beregalov wrote:
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> ---
>  drivers/net/wan/pc300_drv.c |   22 ++++++++++++++--------
>  1 files changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
> index c23fde0..df10a4c 100644
> --- a/drivers/net/wan/pc300_drv.c
> +++ b/drivers/net/wan/pc300_drv.c
> @@ -225,6 +225,7 @@ static char rcsid[] =
>  #include <linux/skbuff.h>
>  #include <linux/if_arp.h>
>  #include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
>  #include <linux/spinlock.h>
>  #include <linux/if.h>
>  #include <net/arp.h>
> @@ -3246,6 +3247,18 @@ static inline void show_version(void)
>  		rcsvers, rcsdate, __DATE__, __TIME__);
>  }				/* show_version */
>  
> +static const struct net_device_ops cpc_netdev_ops = {
> +	.ndo_init		= NULL,
> +	.ndo_open		= cpc_open,
> +	.ndo_stop		= cpc_close,
> +	.ndo_tx_timeout		= cpc_tx_timeout,
> +	.ndo_set_multicast_list	= NULL,

In this case ndo_init and ndo_set_multicast_list
are not needed.


>From 1507a5a797a5f0005696a9bf10e390caca9c3800 Mon Sep 17 00:00:00 2001
From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Fri, 17 Apr 2009 05:45:48 +0400
Subject: [PATCH] wan/pc300_drv: convert to net_device_ops


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/wan/pc300_drv.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index c23fde0..79dabc5 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -225,6 +225,7 @@ static char rcsid[] =
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/spinlock.h>
 #include <linux/if.h>
 #include <net/arp.h>
@@ -3246,6 +3247,16 @@ static inline void show_version(void)
 		rcsvers, rcsdate, __DATE__, __TIME__);
 }				/* show_version */
 
+static const struct net_device_ops cpc_netdev_ops = {
+	.ndo_open		= cpc_open,
+	.ndo_stop		= cpc_close,
+	.ndo_tx_timeout		= cpc_tx_timeout,
+	.ndo_set_mac_address	= NULL,
+	.ndo_change_mtu		= cpc_change_mtu,
+	.ndo_do_ioctl		= cpc_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static void cpc_init_card(pc300_t * card)
 {
 	int i, devcount = 0;
@@ -3357,18 +3368,11 @@ static void cpc_init_card(pc300_t * card)
 		dev->mem_start = card->hw.ramphys;
 		dev->mem_end = card->hw.ramphys + card->hw.ramsize - 1;
 		dev->irq = card->hw.irq;
-		dev->init = NULL;
 		dev->tx_queue_len = PC300_TX_QUEUE_LEN;
 		dev->mtu = PC300_DEF_MTU;
 
-		dev->open = cpc_open;
-		dev->stop = cpc_close;
-		dev->tx_timeout = cpc_tx_timeout;
+		dev->netdev_ops = &cpc_netdev_ops;
 		dev->watchdog_timeo = PC300_TX_TIMEOUT;
-		dev->set_multicast_list = NULL;
-		dev->set_mac_address = NULL;
-		dev->change_mtu = cpc_change_mtu;
-		dev->do_ioctl = cpc_ioctl;
 
 		if (register_hdlc_device(dev) == 0) {
 			printk("%s: Cyclades-PC300/", dev->name);
-- 
1.6.2.3

