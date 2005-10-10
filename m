From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [PATCH] sis900: come alive after temporary memory shortage
Date: Mon, 10 Oct 2005 10:37:15 +0200
Message-ID: <20051010083715.GA7202@renditai.milesteg.arr>
References: <4337E76B.1090003@sw.ru> <8204E0D1-F30D-494F-8E97-CDCC26A82807@libero.it> <4337FF9D.70200@sw.ru> <20051006104004.GA2124@renditai.milesteg.arr> <4347C50A.9010501@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
        NetDev <netdev@oss.sgi.com>, Stanislav Protassov <st@sw.com.sg>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vasily Averin <vvs@sw.ru>
Content-Disposition: inline
In-Reply-To: <4347C50A.9010501@sw.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 08, 2005 at 05:09:30PM +0400, Vasily Averin wrote:
> Daniele, could you please check our new patch carefully?
This time I tested it as thoroughly as possible. It kept working during
all the time the memory was filling up, until the OOM killer woke up
from his dark pit. After OOM frenzy, the driver was still alive and
kicking.

> Andrew, could you please drop our old patch and replace it by the new one?
Yes, this one is better, thanks.

> Patch solves following problems:
> 1) Forgotten counter incrementation in sis900_rx() in case
>      it doesn't get memory for skb, that leads to whole interface failure.
>      Problem is accompanied with messages:
>     eth0: Memory squeeze,deferring packet.
>     eth0: NULL pointer encountered in Rx ring, skipping
> 2) If counter cur_rx overflows and there'll be temporary memory problems
>      buffer can't be recreated later, when memory IS available.
> 3) Limit the work in handler to prevent the endless packets processing if
>      new packets are generated faster then handled.
> 
> Signed-off-by: Konstantin Khorenko <khorenko@sw.ru>
> Signed-off-by: Vasily Averin <vvs@sw.ru>
Signed-off-by: Daniele Venzano <venza@brownhat.org>

--- a/drivers/net/sis900.c	2005-10-08 12:22:53.000000000 +0400
+++ b/drivers/net/sis900.c	2005-10-08 15:12:29.000000000 +0400
@@ -1696,15 +1696,20 @@ static int sis900_rx(struct net_device *
 	long ioaddr = net_dev->base_addr;
 	unsigned int entry = sis_priv->cur_rx % NUM_RX_DESC;
 	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
+	int rx_work_limit;
 
 	if (netif_msg_rx_status(sis_priv))
 		printk(KERN_DEBUG "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
 		       "status:0x%8.8x\n",
 		       sis_priv->cur_rx, sis_priv->dirty_rx, rx_status);
+	rx_work_limit = sis_priv->dirty_rx + NUM_RX_DESC - sis_priv->cur_rx;
 
 	while (rx_status & OWN) {
 		unsigned int rx_size;
 
+		if (--rx_work_limit < 0)
+			break;
+
 		rx_size = (rx_status & DSIZE) - CRC_SIZE;
 
 		if (rx_status & (ABORT|OVERRUN|TOOLONG|RUNT|RXISERR|CRCERR|FAERR)) {
@@ -1732,9 +1737,11 @@ static int sis900_rx(struct net_device *
 			   we are working on NULL sk_buff :-( */
 			if (sis_priv->rx_skbuff[entry] == NULL) {
 				if (netif_msg_rx_err(sis_priv))
-					printk(KERN_INFO "%s: NULL pointer " 
-						"encountered in Rx ring, skipping\n",
-						net_dev->name);
+					printk(KERN_WARNING "%s: NULL pointer " 
+					      "encountered in Rx ring\n"
+					      "cur_rx:%4.4d, dirty_rx:%4.4d\n",
+					      net_dev->name, sis_priv->cur_rx,
+					      sis_priv->dirty_rx);
 				break;
 			}
 
@@ -1770,6 +1777,7 @@ static int sis900_rx(struct net_device *
 				sis_priv->rx_ring[entry].cmdsts = 0;
 				sis_priv->rx_ring[entry].bufptr = 0;
 				sis_priv->stats.rx_dropped++;
+				sis_priv->cur_rx++;
 				break;
 			}
 			skb->dev = net_dev;
@@ -1787,7 +1795,7 @@ static int sis900_rx(struct net_device *
 
 	/* refill the Rx buffer, what if the rate of refilling is slower
 	 * than consuming ?? */
-	for (;sis_priv->cur_rx - sis_priv->dirty_rx > 0; sis_priv->dirty_rx++) {
+	for (; sis_priv->cur_rx != sis_priv->dirty_rx; sis_priv->dirty_rx++) {
 		struct sk_buff *skb;
 
 		entry = sis_priv->dirty_rx % NUM_RX_DESC;
