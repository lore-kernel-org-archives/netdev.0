From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Sun, 22 May 2016 00:58:55 +0200
Message-ID: <5740E82F.8040903@gmx.de>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com> <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com> <573E2D0C.604@gmx.de>
 <20160520003145.GA22420@electric-eye.fr.zoreil.com>
 <20160521160910.GA14945@debian-dorm>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, wxt@rock-chips.com,
	heiko@sntech.de, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org, al.kochet@gmail.com
To: Shuyu Wei <wsy2220@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:52959 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751745AbcEUW7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 May 2016 18:59:43 -0400
In-Reply-To: <20160521160910.GA14945@debian-dorm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 21.05.2016 18:09, Shuyu Wei wrote:
> Looks like I got it wrong in the first place.
> 
> priv->tx_buff is not for the device, so there's no need to move it.
> The race has been fixed by commit c278c253f3d9, I forgot to check
> it out. That's my fault.
> 
> I do find another problem. We need to use a barrier to make sure
> skb_tx_timestamp() is called before setting the FOR_EMAC flag.
> 

Shuyu,

Could you please test the patch below? I implemented a new approach
in which tx_clean uses txbd_curr to determine if there are more 
descriptors to check or if the loop can be left. 
Memory barriers on both sides (xmit and clean) should ensure that 
SKB and info are only accessed if they are valid.
I also hope that skb_tx_timestamp is not an issue any more.


BTW: concerning get_maintainer Alexander Kochetkov should be CCed for
modifications in this area, so thats what I do hereby.

--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -162,7 +162,13 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 		struct sk_buff *skb = tx_buff->skb;
 		unsigned int info = le32_to_cpu(txbd->info);
 
-		if ((info & FOR_EMAC) || !txbd->data || !skb)
+		if (info & FOR_EMAC)
+			break;
+
+		/* Make sure curr pointer is consistent with info */
+		rmb();
+
+		if (*txbd_dirty == priv->txbd_curr)
 			break;
 
 		if (unlikely(info & (DROP | DEFR | LTCL | UFLO))) {
@@ -195,8 +201,8 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 		*txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
 	}
 
-	/* Ensure that txbd_dirty is visible to tx() before checking
-	 * for queue stopped.
+	/* Ensure that txbd_dirty is visible to tx() and we see the most recent
+	 * value for txbd_curr.
 	 */
 	smp_mb();
 
@@ -680,35 +686,29 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	dma_unmap_len_set(&priv->tx_buff[*txbd_curr], len, len);
 
 	priv->txbd[*txbd_curr].data = cpu_to_le32(addr);
-
-	/* Make sure pointer to data buffer is set */
-	wmb();
+	priv->tx_buff[*txbd_curr].skb = skb;
 
 	skb_tx_timestamp(skb);
 
 	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
 
-	/* Make sure info word is set */
+	/* 1. Make sure that with respect to tx_clean everything is set up
+	 * properly before we advance txbd_curr.
+	 * 2. Make sure writes to DMA descriptors are completed before we inform
+	 * the hardware.
+	 */
 	wmb();
 
-	priv->tx_buff[*txbd_curr].skb = skb;
-
 	/* Increment index to point to the next BD */
 	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
 
-	/* Ensure that tx_clean() sees the new txbd_curr before
-	 * checking the queue status. This prevents an unneeded wake
-	 * of the queue in tx_clean().
+	/* Ensure we see the most recent value of txbd_dirty and tx_clean() sees
+	 * the updated value of txbd_curr.
 	 */
 	smp_mb();
 
-	if (!arc_emac_tx_avail(priv)) {
+	if (!arc_emac_tx_avail(priv))
 		netif_stop_queue(ndev);
-		/* Refresh tx_dirty */
-		smp_mb();
-		if (arc_emac_tx_avail(priv))
-			netif_start_queue(ndev);
-	}
 
 	arc_reg_set(priv, R_STATUS, TXPL_MASK);
 
-- 
1.9.1
