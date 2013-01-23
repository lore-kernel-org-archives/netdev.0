From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll:
 Implement basic statistics
Date: Tue, 22 Jan 2013 20:27:35 -0800
Message-ID: <1358915255.2107.33.camel@joe-AO722>
References: <FD9AD8C5375B924CABC56D982DB3A802079D32D1@EXMB1.micrel.com>
	 <20130122.205132.2281610193783011537.davem@davemloft.net>
	 <1358913454.2107.16.camel@joe-AO722>
	 <20130122.231754.2210645494690728329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David.Choi@Micrel.Com, netdev@vger.kernel.org,
	Ping.Doong@Micrel.Com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:57511 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753454Ab3AWE1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 23:27:38 -0500
In-Reply-To: <20130122.231754.2210645494690728329.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 23:17 -0500, David Miller wrote:
> Be also careful to not match the ones that are done to
> do something like the initial RX ring filling during
> device open.
> 
> If such an allocation failure causes device open to fail,
> that's a legitimate situation in which to log.

True.

These are only the alloc_skb()s with rx_dropped++
instances that aren't init cases.

Here's the patch if anyone wants to do
something with it.

unsigned, uncompiled for !x86, untested...

 drivers/net/appletalk/cops.c                          | 2 --
 drivers/net/can/grcan.c                               | 2 --
 drivers/net/can/mcp251x.c                             | 1 -
 drivers/net/can/mscan/mscan.c                         | 2 --
 drivers/net/ethernet/adi/bfin_mac.c                   | 1 -
 drivers/net/ethernet/aeroflex/greth.c                 | 7 -------
 drivers/net/ethernet/amd/7990.c                       | 2 --
 drivers/net/ethernet/amd/a2065.c                      | 1 -
 drivers/net/ethernet/amd/am79c961a.c                  | 1 -
 drivers/net/ethernet/amd/au1000_eth.c                 | 1 -
 drivers/net/ethernet/amd/declance.c                   | 2 --
 drivers/net/ethernet/amd/ni65.c                       | 1 -
 drivers/net/ethernet/amd/sunlance.c                   | 4 ----
 drivers/net/ethernet/cadence/at91_ether.c             | 1 -
 drivers/net/ethernet/cirrus/cs89x0.c                  | 3 ---
 drivers/net/ethernet/cirrus/mac89x0.c                 | 1 -
 drivers/net/ethernet/ethoc.c                          | 4 ----
 drivers/net/ethernet/freescale/fec.c                  | 2 --
 drivers/net/ethernet/freescale/fec_mpc52xx.c          | 1 -
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 4 ----
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c             | 2 --
 drivers/net/ethernet/i825xx/82596.c                   | 1 -
 drivers/net/ethernet/i825xx/lib82596.c                | 3 ---
 drivers/net/ethernet/microchip/enc28j60.c             | 3 ---
 drivers/net/ethernet/natsemi/sonic.c                  | 1 -
 drivers/net/ethernet/netx-eth.c                       | 2 --
 drivers/net/ethernet/nuvoton/w90p910_ether.c          | 1 -
 drivers/net/ethernet/realtek/8139too.c                | 2 --
 drivers/net/ethernet/realtek/atp.c                    | 2 --
 drivers/net/ethernet/seeq/sgiseeq.c                   | 2 --
 drivers/net/ethernet/sis/sis900.c                     | 4 ----
 drivers/net/ethernet/smsc/smc9194.c                   | 1 -
 drivers/net/ethernet/smsc/smc91c92_cs.c               | 1 -
 drivers/net/ethernet/smsc/smc91x.c                    | 2 --
 drivers/net/ethernet/xilinx/xilinx_emaclite.c         | 1 -
 drivers/net/ethernet/xircom/xirc2ps_cs.c              | 1 -
 drivers/net/hamradio/baycom_epp.c                     | 1 -
 drivers/net/hamradio/hdlcdrv.c                        | 1 -
 drivers/net/hamradio/mkiss.c                          | 2 --
 drivers/net/hippi/rrunner.c                           | 3 ---
 drivers/net/irda/pxaficp_ir.c                         | 1 -
 drivers/net/sb1000.c                                  | 3 ---
 drivers/net/slip/slip.c                               | 1 -
 drivers/net/usb/ipheth.c                              | 2 --
 drivers/net/wan/cosa.c                                | 1 -
 drivers/net/wan/sdla.c                                | 1 -
 drivers/net/wan/x25_asy.c                             | 1 -
 drivers/net/wan/z85230.c                              | 1 -
 drivers/net/wimax/i2400m/netdev.c                     | 1 -
 drivers/net/wireless/ray_cs.c                         | 1 -
 drivers/net/wireless/wl3501_cs.c                      | 2 --
 51 files changed, 94 deletions(-)

diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index cff6f02..bd01b72 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -790,8 +790,6 @@ static void cops_rx(struct net_device *dev)
         skb = dev_alloc_skb(pkt_len);
         if(skb == NULL)
         {
-                printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n",
-			dev->name);
                 dev->stats.rx_dropped++;
                 while(pkt_len--)        /* Discard packet */
                         inb(ioaddr);
diff --git a/drivers/net/can/grcan.c b/drivers/net/can/grcan.c
index 17fbc7a..e7277e4 100644
--- a/drivers/net/can/grcan.c
+++ b/drivers/net/can/grcan.c
@@ -1191,8 +1191,6 @@ static int grcan_receive(struct net_device *dev, int budget)
 		/* Take care of packet */
 		skb = alloc_can_skb(dev, &cf);
 		if (skb == NULL) {
-			netdev_err(dev,
-				   "dropping frame: skb allocation failed\n");
 			stats->rx_dropped++;
 			continue;
 		}
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 5eaf47b..ec1b04f 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -460,7 +460,6 @@ static void mcp251x_hw_rx(struct spi_device *spi, int buf_idx)
 
 	skb = alloc_can_skb(priv->net, &frame);
 	if (!skb) {
-		dev_err(&spi->dev, "cannot allocate RX skb\n");
 		priv->net->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index e6b4095..0789c81 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -426,8 +426,6 @@ static int mscan_rx_poll(struct napi_struct *napi, int quota)
 
 		skb = alloc_can_skb(dev, &frame);
 		if (!skb) {
-			if (printk_ratelimit())
-				netdev_notice(dev, "packet dropped\n");
 			stats->rx_dropped++;
 			out_8(&regs->canrflg, canrflg);
 			continue;
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index a175d0b..266f832 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1236,7 +1236,6 @@ static void bfin_mac_rx(struct net_device *dev)
 
 	new_skb = netdev_alloc_skb(dev, PKT_BUF_SZ + NET_IP_ALIGN);
 	if (!new_skb) {
-		netdev_notice(dev, "rx: low on mem - packet dropped\n");
 		dev->stats.rx_dropped++;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 0be2195..2d75b2f 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -777,12 +777,7 @@ static int greth_rx(struct net_device *dev, int limit)
 			skb = netdev_alloc_skb(dev, pkt_len + NET_IP_ALIGN);
 
 			if (unlikely(skb == NULL)) {
-
-				if (net_ratelimit())
-					dev_warn(&dev->dev, "low on memory - " "packet dropped\n");
-
 				dev->stats.rx_dropped++;
-
 			} else {
 				skb_reserve(skb, NET_IP_ALIGN);
 
@@ -934,8 +929,6 @@ static int greth_rx_gbit(struct net_device *dev, int limit)
 			 * table handling should be divided into cleaning and
 			 * filling as the TX part of the driver
 			 */
-			if (net_ratelimit())
-				dev_warn(greth->dev, "Could not allocate SKB, dropping packet\n");
 			/* reusing current skb, so it is a drop */
 			dev->stats.rx_dropped++;
 		}
diff --git a/drivers/net/ethernet/amd/7990.c b/drivers/net/ethernet/amd/7990.c
index 6e722dc..65926a9 100644
--- a/drivers/net/ethernet/amd/7990.c
+++ b/drivers/net/ethernet/amd/7990.c
@@ -318,8 +318,6 @@ static int lance_rx (struct net_device *dev)
 			struct sk_buff *skb = netdev_alloc_skb(dev, len + 2);
 
                         if (!skb) {
-                                printk ("%s: Memory squeeze, deferring packet.\n",
-                                        dev->name);
                                 dev->stats.rx_dropped++;
                                 rd->mblength = 0;
                                 rd->rmd1_bits = LE_R1_OWN;
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index 3789aff..0866e76 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -293,7 +293,6 @@ static int lance_rx(struct net_device *dev)
 			struct sk_buff *skb = netdev_alloc_skb(dev, len + 2);
 
 			if (!skb) {
-				netdev_warn(dev, "Memory squeeze, deferring packet\n");
 				dev->stats.rx_dropped++;
 				rd->mblength = 0;
 				rd->rmd1_bits = LE_R1_OWN;
diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index 60e2b70..9793767 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -528,7 +528,6 @@ am79c961_rx(struct net_device *dev, struct dev_priv *priv)
 			dev->stats.rx_packets++;
 		} else {
 			am_writeword (dev, hdraddr + 2, RMD_OWN);
-			printk (KERN_WARNING "%s: memory squeeze, dropping packet.\n", dev->name);
 			dev->stats.rx_dropped++;
 			break;
 		}
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index de774d4..688aede 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -727,7 +727,6 @@ static int au1000_rx(struct net_device *dev)
 			frmlen -= 4; /* Remove FCS */
 			skb = netdev_alloc_skb(dev, frmlen + 2);
 			if (skb == NULL) {
-				netdev_err(dev, "Memory squeeze, dropping packet.\n");
 				dev->stats.rx_dropped++;
 				continue;
 			}
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index baca0bd..3d86ffe 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -607,8 +607,6 @@ static int lance_rx(struct net_device *dev)
 			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == 0) {
-				printk("%s: Memory squeeze, deferring packet.\n",
-				       dev->name);
 				dev->stats.rx_dropped++;
 				*rds_ptr(rd, mblength, lp->type) = 0;
 				*rds_ptr(rd, rmd1, lp->type) =
diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
index 013b651..9443eff 100644
--- a/drivers/net/ethernet/amd/ni65.c
+++ b/drivers/net/ethernet/amd/ni65.c
@@ -1118,7 +1118,6 @@ static void ni65_recv_intr(struct net_device *dev,int csr0)
 			}
 			else
 			{
-				printk(KERN_ERR "%s: can't alloc new sk_buff\n",dev->name);
 				dev->stats.rx_dropped++;
 			}
 		}
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 6a40290..70d5430 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -536,8 +536,6 @@ static void lance_rx_dvma(struct net_device *dev)
 			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == NULL) {
-				printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
-				       dev->name);
 				dev->stats.rx_dropped++;
 				rd->mblength = 0;
 				rd->rmd1_bits = LE_R1_OWN;
@@ -708,8 +706,6 @@ static void lance_rx_pio(struct net_device *dev)
 			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == NULL) {
-				printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
-				       dev->name);
 				dev->stats.rx_dropped++;
 				sbus_writew(0, &rd->mblength);
 				sbus_writeb(LE_R1_OWN, &rd->rmd1_bits);
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 3becdb2..81764bf 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -209,7 +209,6 @@ static void at91ether_rx(struct net_device *dev)
 			netif_rx(skb);
 		} else {
 			lp->stats.rx_dropped++;
-			netdev_notice(dev, "Memory squeeze, dropping packet.\n");
 		}
 
 		if (lp->rx_ring[lp->rx_tail].ctrl & MACB_BIT(RX_MHASH_MATCH))
diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 1384469..8fbbee3 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -731,9 +731,6 @@ net_rx(struct net_device *dev)
 	/* Malloc up new buffer. */
 	skb = netdev_alloc_skb(dev, length + 2);
 	if (skb == NULL) {
-#if 0		/* Again, this seems a cruel thing to do */
-		pr_warn("%s: Memory squeeze, dropping packet\n", dev->name);
-#endif
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/ethernet/cirrus/mac89x0.c b/drivers/net/ethernet/cirrus/mac89x0.c
index e285f38..719b1cb 100644
--- a/drivers/net/ethernet/cirrus/mac89x0.c
+++ b/drivers/net/ethernet/cirrus/mac89x0.c
@@ -509,7 +509,6 @@ net_rx(struct net_device *dev)
 	/* Malloc up new buffer. */
 	skb = alloc_skb(length, GFP_ATOMIC);
 	if (skb == NULL) {
-		printk("%s: Memory squeeze, dropping packet.\n", dev->name);
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index aa47ef9..3cb0e53 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -446,10 +446,6 @@ static int ethoc_rx(struct net_device *dev, int limit)
 				dev->stats.rx_bytes += size;
 				netif_receive_skb(skb);
 			} else {
-				if (net_ratelimit())
-					dev_warn(&dev->dev, "low on memory - "
-							"packet dropped\n");
-
 				dev->stats.rx_dropped++;
 				break;
 			}
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index f52ba33..22cef5d 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -736,8 +736,6 @@ fec_enet_rx(struct net_device *ndev)
 		skb = netdev_alloc_skb(ndev, pkt_len - 4 + NET_IP_ALIGN);
 
 		if (unlikely(!skb)) {
-			printk("%s: Memory squeeze, dropping packet.\n",
-					ndev->name);
 			ndev->stats.rx_dropped++;
 		} else {
 			skb_reserve(skb, NET_IP_ALIGN);
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 817d081..bdfbf59 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -419,7 +419,6 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 		skb = netdev_alloc_skb(dev, FEC_RX_BUFFER_SIZE);
 		if (!skb) {
 			/* Can't get a new one : reuse the same & drop pkt */
-			dev_notice(&dev->dev, "Low memory - dropped packet.\n");
 			mpc52xx_fec_rx_submit(dev, rskb);
 			dev->stats.rx_dropped++;
 			continue;
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 46df288..02edb0f 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -177,8 +177,6 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 				received++;
 				netif_receive_skb(skb);
 			} else {
-				dev_warn(fep->dev,
-					 "Memory squeeze, dropping packet.\n");
 				fep->stats.rx_dropped++;
 				skbn = skb;
 			}
@@ -309,8 +307,6 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 				received++;
 				netif_rx(skb);
 			} else {
-				dev_warn(fep->dev,
-					 "Memory squeeze, dropping packet.\n");
 				fep->stats.rx_dropped++;
 				skbn = skb;
 			}
diff --git a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
index 2418faf..8412570 100644
--- a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
+++ b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
@@ -1003,8 +1003,6 @@ static void fjn_rx(struct net_device *dev)
 	    }
 	    skb = netdev_alloc_skb(dev, pkt_len + 2);
 	    if (skb == NULL) {
-		netdev_notice(dev, "Memory squeeze, dropping packet (len %d)\n",
-			      pkt_len);
 		outb(F_SKP_PKT, ioaddr + RX_SKIP);
 		dev->stats.rx_dropped++;
 		break;
diff --git a/drivers/net/ethernet/i825xx/82596.c b/drivers/net/ethernet/i825xx/82596.c
index 1c54e22..1760080 100644
--- a/drivers/net/ethernet/i825xx/82596.c
+++ b/drivers/net/ethernet/i825xx/82596.c
@@ -804,7 +804,6 @@ static inline int i596_rx(struct net_device *dev)
 memory_squeeze:
 			if (skb == NULL) {
 				/* XXX tulip.c can defer packets here!! */
-				printk(KERN_WARNING "%s: i596_rx Memory squeeze, dropping packet.\n", dev->name);
 				dev->stats.rx_dropped++;
 			}
 			else {
diff --git a/drivers/net/ethernet/i825xx/lib82596.c b/drivers/net/ethernet/i825xx/lib82596.c
index f045ea4..fc8da33 100644
--- a/drivers/net/ethernet/i825xx/lib82596.c
+++ b/drivers/net/ethernet/i825xx/lib82596.c
@@ -720,9 +720,6 @@ static inline int i596_rx(struct net_device *dev)
 memory_squeeze:
 			if (skb == NULL) {
 				/* XXX tulip.c can defer packets here!! */
-				printk(KERN_ERR
-				       "%s: i596_rx Memory squeeze, dropping packet.\n",
-				       dev->name);
 				dev->stats.rx_dropped++;
 			} else {
 				if (!rx_in_place) {
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 5d98a9f..e8ed5da 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -956,9 +956,6 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 	} else {
 		skb = netdev_alloc_skb(ndev, len + NET_IP_ALIGN);
 		if (!skb) {
-			if (netif_msg_rx_err(priv))
-				dev_err(&ndev->dev,
-					"out of memory for Rx'd frame\n");
 			ndev->stats.rx_dropped++;
 		} else {
 			skb_reserve(skb, NET_IP_ALIGN);
diff --git a/drivers/net/ethernet/natsemi/sonic.c b/drivers/net/ethernet/natsemi/sonic.c
index 46795e4..1bd419d 100644
--- a/drivers/net/ethernet/natsemi/sonic.c
+++ b/drivers/net/ethernet/natsemi/sonic.c
@@ -424,7 +424,6 @@ static void sonic_rx(struct net_device *dev)
 			/* Malloc up new buffer. */
 			new_skb = netdev_alloc_skb(dev, SONIC_RBSIZE + 2);
 			if (new_skb == NULL) {
-				printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n", dev->name);
 				lp->stats.rx_dropped++;
 				break;
 			}
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 63e7af4..cb9e638 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -152,8 +152,6 @@ static void netx_eth_receive(struct net_device *ndev)
 
 	skb = netdev_alloc_skb(ndev, len);
 	if (unlikely(skb == NULL)) {
-		printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
-			ndev->name);
 		ndev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 162da89..539d202 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -737,7 +737,6 @@ static void netdev_rx(struct net_device *dev)
 			data = ether->rdesc->recv_buf[ether->cur_rx];
 			skb = netdev_alloc_skb(dev, length + 2);
 			if (!skb) {
-				dev_err(&pdev->dev, "get skb buffer error\n");
 				ether->stats.rx_dropped++;
 				return;
 			}
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 1276ac7..3ccedeb 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -2041,8 +2041,6 @@ keep_pkt:
 
 			netif_receive_skb (skb);
 		} else {
-			if (net_ratelimit())
-				netdev_warn(dev, "Memory squeeze, dropping packet\n");
 			dev->stats.rx_dropped++;
 		}
 		received++;
diff --git a/drivers/net/ethernet/realtek/atp.c b/drivers/net/ethernet/realtek/atp.c
index 9f2d416..d77d60e 100644
--- a/drivers/net/ethernet/realtek/atp.c
+++ b/drivers/net/ethernet/realtek/atp.c
@@ -782,8 +782,6 @@ static void net_rx(struct net_device *dev)
 
 		skb = netdev_alloc_skb(dev, pkt_len + 2);
 		if (skb == NULL) {
-			printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n",
-				   dev->name);
 			dev->stats.rx_dropped++;
 			goto done;
 		}
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index 0fde9ca..0ad5694 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -381,8 +381,6 @@ memory_squeeze:
 					dev->stats.rx_packets++;
 					dev->stats.rx_bytes += len;
 				} else {
-					printk(KERN_NOTICE "%s: Memory squeeze, deferring packet.\n",
-						dev->name);
 					dev->stats.rx_dropped++;
 				}
 			} else {
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index efca14e..32714db 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1846,10 +1846,6 @@ refill_rx_ring:
 				 * "hole" on the buffer ring, it is not clear
 				 * how the hardware will react to this kind
 				 * of degenerated buffer */
-				if (netif_msg_rx_err(sis_priv))
-					printk(KERN_INFO "%s: Memory squeeze, "
-						"deferring packet.\n",
-						net_dev->name);
 				net_dev->stats.rx_dropped++;
 				break;
 			}
diff --git a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
index 50823da..4ff72a6 100644
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -1225,7 +1225,6 @@ static void smc_rcv(struct net_device *dev)
 		skb = netdev_alloc_skb(dev, packet_length + 5);
 
 		if ( skb == NULL ) {
-			printk(KERN_NOTICE CARDNAME ": Low memory, packet dropped.\n");
 			dev->stats.rx_dropped++;
 			goto done;
 		}
diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index 04393b5..9dfdf46 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -1502,7 +1502,6 @@ static void smc_rx(struct net_device *dev)
 	skb = netdev_alloc_skb(dev, packet_length+2);
 	
 	if (skb == NULL) {
-	    pr_debug("%s: Low memory, packet dropped.\n", dev->name);
 	    dev->stats.rx_dropped++;
 	    outw(MC_RELEASE, ioaddr + MMU_CMD);
 	    return;
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 591650a..dfbf978 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -465,8 +465,6 @@ static inline void  smc_rcv(struct net_device *dev)
 		 */
 		skb = netdev_alloc_skb(dev, packet_len);
 		if (unlikely(skb == NULL)) {
-			printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
-				dev->name);
 			SMC_WAIT_MMU_BUSY(lp);
 			SMC_SET_MMU_CMD(lp, MC_RELEASE);
 			dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 919b983..97bf214 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -617,7 +617,6 @@ static void xemaclite_rx_handler(struct net_device *dev)
 	if (!skb) {
 		/* Couldn't get memory. */
 		dev->stats.rx_dropped++;
-		dev_err(&lp->ndev->dev, "Could not allocate receive buffer\n");
 		return;
 	}
 
diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index 98e09d0..76210ab 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -1041,7 +1041,6 @@ xirc2ps_interrupt(int irq, void *dev_id)
 	    /* 1 extra so we can use insw */
 	    skb = netdev_alloc_skb(dev, pktlen + 3);
 	    if (!skb) {
-		pr_notice("low memory, packet dropped (size=%u)\n", pktlen);
 		dev->stats.rx_dropped++;
 	    } else { /* okay get the packet */
 		skb_reserve(skb, 2);
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 49b8b58..dc1a80b 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -546,7 +546,6 @@ static void do_rxpacket(struct net_device *dev)
 		return;
 	pktlen = bc->hdlcrx.bufcnt-2+1; /* KISS kludge */
 	if (!(skb = dev_alloc_skb(pktlen))) {
-		printk("%s: memory squeeze, dropping packet\n", dev->name);
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index a4a3516..7fbc1ad 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -153,7 +153,6 @@ static void hdlc_rx_flag(struct net_device *dev, struct hdlcdrv_state *s)
 		return;
 	pkt_len = s->hdlcrx.len - 2 + 1; /* KISS kludge */
 	if (!(skb = dev_alloc_skb(pkt_len))) {
-		printk("%s: memory squeeze, dropping packet\n", dev->name);
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 8e01c45..f9f7cdb 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -292,8 +292,6 @@ static void ax_bump(struct mkiss *ax)
 	count = ax->rcount;
 
 	if ((skb = dev_alloc_skb(count)) == NULL) {
-		printk(KERN_ERR "mkiss: %s: memory squeeze, dropping packet.\n",
-		       ax->dev->name);
 		ax->dev->stats.rx_dropped++;
 		spin_unlock_bh(&ax->buflock);
 		return;
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index e5b19b0..5e52b25 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -954,7 +954,6 @@ static void rx_int(struct net_device *dev, u32 rxlimit, u32 index)
 			if (pkt_len < PKT_COPY_THRESHOLD) {
 				skb = alloc_skb(pkt_len, GFP_ATOMIC);
 				if (skb == NULL){
-					printk(KERN_WARNING "%s: Unable to allocate skb (%i bytes), deferring packet\n", dev->name, pkt_len);
 					dev->stats.rx_dropped++;
 					goto defer;
 				} else {
@@ -991,8 +990,6 @@ static void rx_int(struct net_device *dev, u32 rxlimit, u32 index)
 						PCI_DMA_FROMDEVICE);
 					set_rraddr(&desc->addr, addr);
 				} else {
-					printk("%s: Out of memory, deferring "
-					       "packet\n", dev->name);
 					dev->stats.rx_dropped++;
 					goto defer;
 				}
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 858de05..5b021cf 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -443,7 +443,6 @@ static void pxa_irda_fir_irq_eif(struct pxa_irda *si, struct net_device *dev, in
 
 		skb = alloc_skb(len+1,GFP_ATOMIC);
 		if (!skb)  {
-			printk(KERN_ERR "pxa_ir: fir out of memory for receive skb\n");
 			dev->stats.rx_dropped++;
 			return;
 		}
diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
index 66c2f1a..573a99f 100644
--- a/drivers/net/sb1000.c
+++ b/drivers/net/sb1000.c
@@ -835,9 +835,6 @@ printk("cm0: IP identification: %02x%02x  fragment offset: %02x%02x\n", buffer[3
 		/* compute size to allocate for datagram */
 		skbsize = dlen + FrameSize;
 		if ((skb = alloc_skb(skbsize, GFP_ATOMIC)) == NULL) {
-			if (sb1000_debug > 1)
-				printk(KERN_WARNING "%s: can't allocate %d bytes long "
-					"skbuff\n", dev->name, skbsize);
 			stats->rx_dropped++;
 			insw(ioaddr, buffer, NewDatagramDataSize / 2);
 			goto dropped_frame;
diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index a34d6bf..eb1da6c 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -358,7 +358,6 @@ static void sl_bump(struct slip *sl)
 
 	skb = dev_alloc_skb(count);
 	if (skb == NULL) {
-		printk(KERN_WARNING "%s: memory squeeze, dropping packet.\n", dev->name);
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index 534d8be..74138bc 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -233,8 +233,6 @@ static void ipheth_rcvbulk_callback(struct urb *urb)
 
 	skb = dev_alloc_skb(len);
 	if (!skb) {
-		dev_err(&dev->intf->dev, "%s: dev_alloc_skb: -ENOMEM\n",
-			__func__);
 		dev->net->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 6aed238..827c984 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -733,7 +733,6 @@ static char *cosa_net_setup_rx(struct channel_data *chan, int size)
 	kfree_skb(chan->rx_skb);
 	chan->rx_skb = dev_alloc_skb(size);
 	if (chan->rx_skb == NULL) {
-		pr_notice("%s: Memory squeeze, dropping packet\n", chan->name);
 		chan->netdev->stats.rx_dropped++;
 		return NULL;
 	}
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index de3bbf4..400bdbb 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -827,7 +827,6 @@ static void sdla_receive(struct net_device *dev)
 		skb = dev_alloc_skb(len + sizeof(struct frhdr));
 		if (skb == NULL) 
 		{
-			netdev_notice(dev, "Memory squeeze, dropping packet\n");
 			dev->stats.rx_dropped++;
 			success = 0;
 		}
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 44db8b7..6a6cb97 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -197,7 +197,6 @@ static void x25_asy_bump(struct x25_asy *sl)
 
 	skb = dev_alloc_skb(count+1);
 	if (skb == NULL) {
-		netdev_warn(sl->dev, "memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index feacc3b..ccc57e9 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -1639,7 +1639,6 @@ static void z8530_rx_done(struct z8530_channel *c)
 		skb = dev_alloc_skb(ct);
 		if (skb == NULL) {
 			c->netdevice->stats.rx_dropped++;
-			netdev_warn(c->netdevice, "Memory squeeze\n");
 		} else {
 			skb_put(skb, ct);
 			skb_copy_to_linear_data(skb, rxb, ct);
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index cedd4d3..7318c4f 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -501,7 +501,6 @@ void i2400m_net_rx(struct i2400m *i2400m, struct sk_buff *skb_rx,
 		 * comments at the top of the file */
 		skb = __netdev_alloc_skb(net_dev, buf_len, GFP_KERNEL);
 		if (skb == NULL) {
-			dev_err(dev, "NETRX: no memory to realloc skb\n");
 			net_dev->stats.rx_dropped++;
 			goto error_skb_realloc;
 		}
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 598ca1c..68b8353 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -2172,7 +2172,6 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 
 	skb = dev_alloc_skb(total_len + 5);
 	if (skb == NULL) {
-		pr_debug("ray_cs rx_data could not allocate skb\n");
 		local->stats.rx_dropped++;
 		if (readb(&prcs->var.rx_packet.next_frag_rcs_index) != 0xFF)
 			release_frag_chain(local, prcs);
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 730186d..f36aacb 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -964,8 +964,6 @@ static inline void wl3501_md_ind_interrupt(struct net_device *dev,
 	skb = dev_alloc_skb(pkt_len + 5);
 
 	if (!skb) {
-		printk(KERN_WARNING "%s: Can't alloc a sk_buff of size %d.\n",
-		       dev->name, pkt_len);
 		dev->stats.rx_dropped++;
 	} else {
 		skb->dev = dev;
