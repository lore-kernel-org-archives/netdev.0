From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: sis900: eth0: NULL pointer encountered in Rx ring, skipping
Date: Wed, 19 Jan 2005 22:49:27 +0100
Message-ID: <20050119214927.GA2330@electric-eye.fr.zoreil.com>
References: <20050118101358.GA9335@xi.wantstofly.org> <20050118102139.GA9507@xi.wantstofly.org> <5cac192f0501191252406a13f2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <eric.lemoine@gmail.com>
Content-Disposition: inline
In-Reply-To: <5cac192f0501191252406a13f2@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Lemoine <eric.lemoine@gmail.com> :
[...]
> There are dev_alloc_skb()'s failing due to memory shortage. I think
> anyhow that the sis9000 driver doesnt handle "memory squeeze"
> situations right. Why not throwing current rx packet away and reuse
> ring entry instead of leaving holes (null skb's) in the ring. I would
> suggest a patch to the sis900 driver around that attached.

Imho it should not be necessary as long as the hardware is not completely
b0rken. I'd rather see how the driver behaves when it is really short of
memory (i.e. no entry is available for DMA in the ring). Patch below.


Make the driver own a Rx descriptor entry as long as it is not refilled.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/sis900.c~sis900-000 drivers/net/sis900.c
--- linux-2.6.11-rc1-bk6/drivers/net/sis900.c~sis900-000	2005-01-19 22:28:38.633282552 +0100
+++ linux-2.6.11-rc1-bk6-fr/drivers/net/sis900.c	2005-01-19 22:34:16.362996145 +0100
@@ -1643,13 +1643,15 @@ static int sis900_rx(struct net_device *
 	long ioaddr = net_dev->base_addr;
 	unsigned int entry = sis_priv->cur_rx % NUM_RX_DESC;
 	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
+	int rx_left;
 
 	if (sis900_debug > 3)
 		printk(KERN_INFO "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
 		       "status:0x%8.8x\n",
 		       sis_priv->cur_rx, sis_priv->dirty_rx, rx_status);
 
-	while (rx_status & OWN) {
+	rx_left = NUM_RX_DESC + sis_priv->dirty_rx - sis_priv->cur_rx;
+	while ((rx_left > 0) && (rx_status & OWN)) {
 		unsigned int rx_size;
 
 		rx_size = (rx_status & DSIZE) - CRC_SIZE;
@@ -1712,7 +1714,7 @@ static int sis900_rx(struct net_device *
 				       net_dev->name);
 				sis_priv->rx_skbuff[entry] = NULL;
 				/* reset buffer descriptor state */
-				sis_priv->rx_ring[entry].cmdsts = 0;
+				sis_priv->rx_ring[entry].cmdsts = OWN;
 				sis_priv->rx_ring[entry].bufptr = 0;
 				sis_priv->stats.rx_dropped++;
 				break;
@@ -1728,6 +1730,8 @@ static int sis900_rx(struct net_device *
 		sis_priv->cur_rx++;
 		entry = sis_priv->cur_rx % NUM_RX_DESC;
+		rmb();
 		rx_status = sis_priv->rx_ring[entry].cmdsts;
+		rx_left--;
 	} // while
 
 	/* refill the Rx buffer, what if the rate of refilling is slower

_
