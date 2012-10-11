From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 14:40:48 +0200
Message-ID: <1349959248.21172.8970.camel@edumazet-glaptop>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	 <20121011103257.GO4625@n2100.arm.linux.org.uk>
	 <1349952574.21172.8604.camel@edumazet-glaptop>
	 <201210111228.25995.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jon Masters <jonathan@jonmasters.org>, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	David Laight <David.Laight@aculab.com>,
	Rob Herring <robherring2@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34455 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756254Ab2JKMkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 08:40:53 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so947524bkc.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 05:40:52 -0700 (PDT)
In-Reply-To: <201210111228.25995.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-11 at 12:28 +0000, Arnd Bergmann wrote:

> 
> Rob Herring as the original reporter has dropped off the Cc list, adding
> him back.
> 
> I assume that the calxeda xgmac driver is the culprit then. It uses
> netdev_alloc_skb() rather than netdev_alloc_skb_ip_align() in
> xgmac_rx_refill but it is not clear whether it does so intentionally
> or by accident.

Thanks Arnd

It seems an accident, since driver doesnt check skb->data alignment at
all (this can change with SLAB debug on/off)

It also incorrectly adds 64 bytes to bfsize, there is no need for this.

(or if its needed, a comment would be nice, because on prior kernels,
this makes skb->head allocations uses kmalloc-4096 instead of
kmalloc-2048 slab cache... With 3.7 its less an issue now we use order-3
pages to deliver fragments for rx skbs

So the following patch should fix the alignment, and makes driver uses
half memory than before for stable kernels

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 16814b3..a895e18 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -671,7 +671,8 @@ static void xgmac_rx_refill(struct xgmac_priv *priv)
 		p = priv->dma_rx + entry;
 
 		if (priv->rx_skbuff[entry] == NULL) {
-			skb = netdev_alloc_skb(priv->dev, priv->dma_buf_sz);
+			skb = netdev_alloc_skb_ip_align(priv->dev,
+							priv->dma_buf_sz);
 			if (unlikely(skb == NULL))
 				break;
 
@@ -703,7 +704,7 @@ static int xgmac_dma_desc_rings_init(struct net_device *dev)
 	/* Set the Buffer size according to the MTU;
 	 * indeed, in case of jumbo we need to bump-up the buffer sizes.
 	 */
-	bfsize = ALIGN(dev->mtu + ETH_HLEN + ETH_FCS_LEN + NET_IP_ALIGN + 64,
+	bfsize = ALIGN(dev->mtu + ETH_HLEN + ETH_FCS_LEN,
 		       64);
 
 	netdev_dbg(priv->dev, "mtu [%d] bfsize [%d]\n", dev->mtu, bfsize);
