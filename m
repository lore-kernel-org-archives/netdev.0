From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] sky2: version 1.24
Date: Fri, 14 Aug 2009 15:41:54 -0700 (PDT)
Message-ID: <20090814.154154.53636130.davem@davemloft.net>
References: <20090814151511.992669598@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47739
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755492AbZHNWln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 18:41:43 -0400
In-Reply-To: <20090814151511.992669598@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 14 Aug 2009 08:15:11 -0700

> This is rework of some of Mike's patches, and additional
> improvement in the restart logic.

Patches themselves look good.

> Patch against current net-next-2.6.

Ummm... no, it isn't.

I merged net-2.6 into net-next-2.6 yesterday, which brought in various
sky2 fixes.  This caused conflicts which I had to hand merge starting
in patch #6.

For example, in patch #6:

@@ -1498,10 +1498,9 @@ static int sky2_up(struct net_device *de
 	sky2_write32(hw, B0_IMSK, imask);
 	sky2_read32(hw, B0_IMSK);
 
-	sky2_set_multicast(dev);
-
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
+
 	return 0;
 
 err_out:

There is a netif_wake_queue() call right before the if (netif_msg_ifup)

Then, in patch #7:

@@ -2367,11 +2363,8 @@ static inline void sky2_tx_done(struct n
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (netif_running(dev)) {
-		netif_tx_lock(dev);
+	if (netif_running(dev))
 		sky2_tx_complete(sky2, last);
-		netif_tx_unlock(dev);
-	}
 }
 
 static inline void sky2_skb_rx(const struct sky2_port *sky2,


That if () test has an extra condition "&& !sky2->restarting",
I retained in when applying that patch.

Then, in patch #8:

@@ -2042,15 +2041,18 @@ struct sky2_port {
 		u8	fifo_lev;
 	} check;
 
-
 	dma_addr_t	     rx_le_map;
 	dma_addr_t	     tx_le_map;
+
 	u16		     advertising;	/* ADVERTISED_ bits */
-	u16		     speed;	/* SPEED_1000, SPEED_100, ... */
-	u8		     autoneg;	/* AUTONEG_ENABLE, AUTONEG_DISABLE */
-	u8		     duplex;	/* DUPLEX_HALF, DUPLEX_FULL */
-	u8		     rx_csum;
-	u8		     wol;
+	u16		     speed;		/* SPEED_1000, SPEED_100, ... */
+	u8		     wol;		/* WAKE_ bits */
+	u8		     duplex;		/* DUPLEX_HALF, DUPLEX_FULL */
+	u16		     flags;
+#define SKY2_FLAG_RX_CHECKSUM		0x0001
+#define SKY2_FLAG_AUTO_SPEED		0x0002
+#define SKY2_FLAG_AUTO_PAUSE		0x0004
+
  	enum flow_control    flow_mode;
  	enum flow_control    flow_status;

This is missing the "->restarting" member, I retained it while
applying this patch.

Even if whatever net-next-2.6 tree you patches against didn't have
those fixes, you should have anticipated them and known that I'd
have to end up sorting out the merge mess afterwards.

Anyways I pushed it all out, send me fixup patches if necessary.
