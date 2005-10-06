From: Daniele Venzano <venza@brownhat.org>
Subject: [PATCH] sis900: come alive after temporary memory shortage
Date: Thu, 6 Oct 2005 12:40:05 +0200
Message-ID: <20051006104004.GA2124@renditai.milesteg.arr>
References: <4337E76B.1090003@sw.ru> <8204E0D1-F30D-494F-8E97-CDCC26A82807@libero.it> <4337FF9D.70200@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>,
        Stanislav Protassov <st@sw.com.sg>, Vasily Averin <vvs@sw.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4337FF9D.70200@sw.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch is good and fixes some corner cases. Please consider for
inclusion.

On Mon, Sep 26, 2005 at 06:03:09PM +0400, Konstantin Khorenko wrote:
> Patch solves following problems:
> 1) Forgotten counter incrementation in sis900_rx() in case
>     it doesn't get memory for skb, that leads to whole interface failure.
>     Problem is accompanied with messages:
>    eth0: Memory squeeze,deferring packet.
>    eth0: NULL pointer encountered in Rx ring, skipping
> 2) If counter cur_rx overflows and there'll be temporary memory problems
>     buffer can't be recreated later, when memory IS avaliable.
> 3) Limit the work in handler to prevent the endless packets processing if
>     new packets are generated faster then handled.
> 
> Signed-off-by: Konstantin Khorenko <khorenko@sw.ru>
> Signed-off-by: Vasily Averin <vvs@sw.ru>
Signed-off-by: Daniele Venzano <venza@brownhat.org>

--- main-2.6.13.1/drivers/net/sis900.c.sis900	2005-08-29 03:41:01.000000000 +0400
+++ main-2.6.13.1/drivers/net/sis900.c	2005-09-19 14:34:42.000000000 +0400
@@ -1696,6 +1696,8 @@ static int sis900_rx(struct net_device *
 	long ioaddr = net_dev->base_addr;
 	unsigned int entry = sis_priv->cur_rx % NUM_RX_DESC;
 	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
+	int rx_work_limit =
+		(sis_priv->dirty_rx - sis_priv->cur_rx) % NUM_RX_DESC;
 
 	if (netif_msg_rx_status(sis_priv))
 		printk(KERN_DEBUG "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
@@ -1705,6 +1713,8 @@ static int sis900_rx(struct net_device *
 	while (rx_status & OWN) {
 		unsigned int rx_size;
 
+		if (--rx_work_limit < 0)
+			break;
 		rx_size = (rx_status & DSIZE) - CRC_SIZE;
 
 		if (rx_status & (ABORT|OVERRUN|TOOLONG|RUNT|RXISERR|CRCERR|FAERR)) {
@@ -1770,6 +1780,7 @@ static int sis900_rx(struct net_device *
 				sis_priv->rx_ring[entry].cmdsts = 0;
 				sis_priv->rx_ring[entry].bufptr = 0;
 				sis_priv->stats.rx_dropped++;
+				sis_priv->cur_rx++;
 				break;
 			}
 			skb->dev = net_dev;
@@ -1787,7 +1798,7 @@ static int sis900_rx(struct net_device *
 
 	/* refill the Rx buffer, what if the rate of refilling is slower
 	 * than consuming ?? */
-	for (;sis_priv->cur_rx - sis_priv->dirty_rx > 0; sis_priv->dirty_rx++) {
+	for (; sis_priv->cur_rx != sis_priv->dirty_rx; sis_priv->dirty_rx++) {
 		struct sk_buff *skb;
 
 		entry = sis_priv->dirty_rx % NUM_RX_DESC;


-- 
------------------------------
Daniele Venzano
Web: http://teg.homeunix.org
