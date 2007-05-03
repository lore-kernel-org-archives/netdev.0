From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH v2] gianfar: Add I/O barriers when touching buffer
 descriptor ownership.
Date: Wed, 2 May 2007 21:10:17 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0705022109350.1690@localhost.localdomain>
References: <20070502195712.GA16541@ld0162-tx32.am.freescale.net>
 <F1B250DD-A472-470F-B3D0-EBB2F042E454@kernel.crashing.org>
 <4638F0C4.2000406@freescale.com> <FA9554A4-5A7D-4E03-BE28-C4B6B80D9DB9@kernel.crashing.org>
 <4638F734.2040809@freescale.com> <41B347BE-06AA-4346-BEFB-19DFB52AC533@kernel.crashing.org>
 <463902EB.8070401@freescale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:25116 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1767328AbXECCOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 22:14:44 -0400
In-Reply-To: <463902EB.8070401@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2 May 2007, Scott Wood wrote:

> Kumar Gala wrote:
> > Why doesn't marking the bdp pointer volatile resolve the issue in
> > gfar_clean_rx_ring() to ensure load ordering?
>
> Because that only addresses compiler reordering (and does so in a rather
> clumsy way -- not all accesses need to be strongly ordered), not hardware
> reordering.
>
> -Scott
>

So what about some thing like this where we do the read only once?

- k

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index a06d8d1..9cd7d1e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1438,31 +1438,35 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 {
 	struct rxbd8 *bdp;
 	struct sk_buff *skb;
-	u16 pkt_len;
+	u16 pkt_len, status;
+	u32 bd_info;
 	int howmany = 0;
 	struct gfar_private *priv = netdev_priv(dev);

 	/* Get the first full descriptor */
 	bdp = priv->cur_rx;

-	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
+	bd_info = *bdp;
+
+	status = bd_info >> 16;
+	/* Remove the FCS from the packet length */
+	pkt_len = (bd_info & 0xffff) - 4;
+
+	while (!((status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
 		skb = priv->rx_skbuff[priv->skb_currx];

-		if (!(bdp->status &
+		if (!(status &
 		      (RXBD_LARGE | RXBD_SHORT | RXBD_NONOCTET
 		       | RXBD_CRCERR | RXBD_OVERRUN | RXBD_TRUNCATED))) {
 			/* Increment the number of packets */
 			priv->stats.rx_packets++;
 			howmany++;

-			/* Remove the FCS from the packet length */
-			pkt_len = bdp->length - 4;
-
 			gfar_process_frame(dev, skb, pkt_len);

 			priv->stats.rx_bytes += pkt_len;
 		} else {
-			count_errors(bdp->status, priv);
+			count_errors(status, priv);

 			if (skb)
 				dev_kfree_skb_any(skb);
@@ -1480,7 +1484,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 		priv->rx_skbuff[priv->skb_currx] = skb;

 		/* Update to the next pointer */
-		if (bdp->status & RXBD_WRAP)
+		if (status & RXBD_WRAP)
 			bdp = priv->rx_bd_base;
 		else
 			bdp++;
@@ -1490,6 +1494,11 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 		    (priv->skb_currx +
 		     1) & RX_RING_MOD_MASK(priv->rx_ring_size);

+		bd_info = *bdp;
+
+		status = bd_info >> 16;
+		/* Remove the FCS from the packet length */
+		pkt_len = (bd_info & 0xffff) - 4;
 	}

 	/* Update the current rxbd pointer to be the next one */
