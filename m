From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add missing skb->dev assignment in Frame Relay RX code
Date: Sun, 29 Jun 2008 13:04:20 -0700
Message-ID: <20080629130420.62d00d59@extreme>
References: <m3wsk8aupw.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932500AbYF2UEo@vger.kernel.org>
In-Reply-To: <m3wsk8aupw.fsf@maximus.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 29 Jun 2008 21:48:11 +0200
Krzysztof Halasa <khc@pm.waw.pl> wrote:

> Hi,
> 
> Commit 4c13eb6657fe9ef7b4dc8f1a405c902e9e5234e0 ([ETH]: Make
> eth_type_trans set skb->dev like the other *_type_trans) removed
> skb->dev assignment from hdlc_fr.c:fr_rx(). Unfortunately it was also
> needed for cases other than eth_type_trans().
> 
> Adding it back.
> 
> It's quite serious and may be a security risk as it causes a wrong
> input interface indication (the physical hdlcX instead of logical
> pvcX). Probably -stable class fix.
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>
> 
> diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
> index c4ab032..3a86e64 100644
> --- a/drivers/net/wan/hdlc_fr.c
> +++ b/drivers/net/wan/hdlc_fr.c
> @@ -1008,6 +1008,7 @@ static int fr_rx(struct sk_buff *skb)
>  		stats->rx_bytes += skb->len;
>  		if (pvc->state.becn)
>  			stats->rx_compressed++;
> +		skb->dev = dev;
>  		netif_rx(skb);
>  		return NET_RX_SUCCESS;
>  	} else {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Better to use netdev_alloc_skb for receive buffers instead.
--- a/drivers/net/wan/hdlc_fr.c	2008-06-29 13:02:42.000000000 -0700
+++ b/drivers/net/wan/hdlc_fr.c	2008-06-29 13:04:01.000000000 -0700
@@ -515,7 +515,7 @@ static void fr_lmi_send(struct net_devic
 		}
 	}
 
-	skb = dev_alloc_skb(len);
+	skb = netdev_alloc_skb(dev, len);
 	if (!skb) {
 		printk(KERN_WARNING "%s: Memory squeeze on fr_lmi_send()\n",
 		       dev->name);
