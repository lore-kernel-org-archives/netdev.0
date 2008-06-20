From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] net-driver: Drivers don't set IFF_* flag [Was: [PATCH 3/3]
 netdevice: order of synchronization of IFF_PROMISC and IFF_ALLMULTI]
Date: Fri, 20 Jun 2008 23:07:38 +0800
Message-ID: <485BC7BA.60406@cn.fujitsu.com>
References: <48562F9A.5030509@cn.fujitsu.com> <485631FF.7040509@trash.net> <485634D1.2010603@cn.fujitsu.com> <48563A7F.50309@trash.net> <485716A1.8030401@cn.fujitsu.com> <4857B6DC.5020805@trash.net> <48587295.40705@cn.fujitsu.com> <48587854.8050400@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59789 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbYFTPLk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 11:11:40 -0400
In-Reply-To: <48587854.8050400@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik said the following on 2008-6-18 10:52:
>>>> In some driver's code of *_set_multicast_list(), IFF_PROMISC
>>>> will be set if IFF_ALLMULTI is set.
>>>> And there is comment about the necessity for setting IFF_PROMISC.
>>>> /*
>>>>  *    We must make the kernel realise we had to move
>>>>  *    into promisc mode or we start all out war on
>>>>  *    the cable. If it was a promisc request the
>>>>  *    flag is already set. If not we assert it.
>>>>  */
>>>> So, I doubt about fixing the drivers.
>>>
>>> I have no idea what this comment is trying to say. Drivers
>>> shouldn't change dev->flags.
>>>
>>
>> Yes.
>> Maybe we should ask the authors about why they let driver to
>> change the dev->flags.
>> Fox example, about 3c527.
>> Alan,
>> Can you explain why do_mc32_set_multicast_list() change flag
>> to IFF_PROMISC when IFF_ALLMULTI is set?
>>
>> Jeff,
>> Any suggestion about this?
>> netdevice uses promiscuity as refcnt, and if driver set IFF_PROMISC
>> but don't change promiscuity will break the refcnt.
> 
> Drivers should not be setting IFF_* flags in set_multicast_list().
> 
> The normal logic is that a driver interprets the request implied in
> set_multicast_list ("promisc, all-multi, or select multi?"), and then
> programs the hardware based on that.
> 
> On some hardware, IFF_ALLMULTI requires that the hardware receive all
> packets (promisc).  Even for that case, the driver should -not- be
> setting the IFF_PROMISC flag.  It should be aware of its own hardware
> programming state through some other method.
> 

Subject: [PATCH] net-driver: Drivers don't set IFF_* flag

Some hardware set promisc when they are requested to set IFF_ALLMULTI flag.
It's ok, but if drivers set IFF_PROMISC flag when they set promisc,
it will broken upper layer handle for promisc and allmulti.
In addition, drivers can use their own hardware programming to make it.
So do not allow drivers to set IFF_* flags.

This is a general driver fix, so I didn't split it to pieces and send
to specific driver maintainers.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/3c523.c               |    4 +---
 drivers/net/3c527.c               |    9 +++------
 drivers/net/atp.c                 |    9 ++-------
 drivers/net/de620.c               |    7 -------
 drivers/net/eepro.c               |    8 --------
 drivers/net/eth16i.c              |    1 -
 drivers/net/lp486e.c              |    2 --
 drivers/net/ni5010.c              |    1 -
 drivers/net/ni52.c                |    2 +-
 drivers/net/sun3_82586.c          |    7 ++-----
 drivers/net/tulip/de4x5.c         |    2 ++
 drivers/net/wireless/orinoco.c    |    7 -------
 drivers/net/wireless/wavelan.c    |    3 ---
 drivers/net/wireless/wavelan_cs.c |    6 ------
 14 files changed, 11 insertions(+), 57 deletions(-)

diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 239fc42..9e48660 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -641,10 +641,8 @@ static int init586(struct net_device *dev)
 	cfg_cmd->time_low = 0x00;
 	cfg_cmd->time_high = 0xf2;
 	cfg_cmd->promisc = 0;
-	if (dev->flags & (IFF_ALLMULTI | IFF_PROMISC)) {
+	if (dev->flags & (IFF_ALLMULTI | IFF_PROMISC))
 		cfg_cmd->promisc = 1;
-		dev->flags |= IFF_PROMISC;
-	}
 	cfg_cmd->carr_coll = 0x00;
 
 	p->scb->cbl_offset = make16(cfg_cmd);
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index fae295b..a0bea51 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -1524,14 +1524,11 @@ static void do_mc32_set_multicast_list(struct net_device *dev, int retry)
 	struct mc32_local *lp = netdev_priv(dev);
 	u16 filt = (1<<2); /* Save Bad Packets, for stats purposes */
 
-	if (dev->flags&IFF_PROMISC)
+	if ((dev->flags&IFF_PROMISC) ||
+	    (dev->flags&IFF_ALLMULTI) ||
+	    dev->mc_count > 10)
 		/* Enable promiscuous mode */
 		filt |= 1;
-	else if((dev->flags&IFF_ALLMULTI) || dev->mc_count > 10)
-	{
-		dev->flags|=IFF_PROMISC;
-		filt |= 1;
-	}
 	else if(dev->mc_count)
 	{
 		unsigned char block[62];
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 3d44333..c10cd80 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -854,14 +854,9 @@ static void set_rx_mode_8002(struct net_device *dev)
 	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
-	if ( dev->mc_count > 0 || (dev->flags & (IFF_ALLMULTI|IFF_PROMISC))) {
-		/* We must make the kernel realise we had to move
-		 *	into promisc mode or we start all out war on
-		 *	the cable. - AC
-		 */
-		dev->flags|=IFF_PROMISC;
+	if (dev->mc_count > 0 || (dev->flags & (IFF_ALLMULTI|IFF_PROMISC)))
 		lp->addr_mode = CMR2h_PROMISC;
-	} else
+	else
 		lp->addr_mode = CMR2h_Normal;
 	write_reg_high(ioaddr, CMR2, lp->addr_mode);
 }
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index 3f5190c..d454e14 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -488,13 +488,6 @@ static void de620_set_multicast_list(struct net_device *dev)
 {
 	if (dev->mc_count || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
 	{ /* Enable promiscuous mode */
-		/*
-		 *	We must make the kernel realise we had to move
-		 *	into promisc mode or we start all out war on
-		 *	the cable. - AC
-		 */
-		dev->flags|=IFF_PROMISC;
-
 		de620_set_register(dev, W_TCR, (TCR_DEF & ~RXPBM) | RXALL);
 	}
 	else
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 56f5049..1f11350 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1283,14 +1283,6 @@ set_multicast_list(struct net_device *dev)
 
 	if (dev->flags&(IFF_ALLMULTI|IFF_PROMISC) || dev->mc_count > 63)
 	{
-		/*
-		 *	We must make the kernel realise we had to move
-		 *	into promisc mode or we start all out war on
-		 *	the cable. If it was a promisc request the
-		 *	flag is already set. If not we assert it.
-		 */
-		dev->flags|=IFF_PROMISC;
-
 		eepro_sw2bank2(ioaddr); /* be CAREFUL, BANK 2 now */
 		mode = inb(ioaddr + REG2);
 		outb(mode | PRMSC_Mode, ioaddr + REG2);
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index e3dd8b1..bee8b3f 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -1356,7 +1356,6 @@ static void eth16i_multicast(struct net_device *dev)
 
 	if(dev->mc_count || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
 	{
-		dev->flags|=IFF_PROMISC;	/* Must do this */
 		outb(3, ioaddr + RECEIVE_MODE_REG);
 	} else {
 		outb(2, ioaddr + RECEIVE_MODE_REG);
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index 591a7e4..83fa9d8 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -1272,8 +1272,6 @@ static void set_multicast_list(struct net_device *dev) {
 			return;
 		}
 		if (dev->mc_count == 0 && !(dev->flags & (IFF_PROMISC | IFF_ALLMULTI))) {
-			if (dev->flags & IFF_ALLMULTI)
-				dev->flags |= IFF_PROMISC;
 			lp->i596_config[8] &= ~0x01;
 		} else {
 			lp->i596_config[8] |= 0x01;
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index a20005c..8e0ca9f 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -648,7 +648,6 @@ static void ni5010_set_multicast_list(struct net_device *dev)
 	PRINTK2((KERN_DEBUG "%s: entering set_multicast_list\n", dev->name));
 
 	if (dev->flags&IFF_PROMISC || dev->flags&IFF_ALLMULTI || dev->mc_list) {
-		dev->flags |= IFF_PROMISC;
 		outb(RMD_PROMISC, EDLC_RMODE); /* Enable promiscuous mode */
 		PRINTK((KERN_DEBUG "%s: Entering promiscuous mode\n", dev->name));
 	} else {
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index a316dcc..b9a882d 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -621,7 +621,7 @@ static int init586(struct net_device *dev)
 		if (num_addrs > len) {
 			printk(KERN_ERR "%s: switching to promisc. mode\n",
 				dev->name);
-			dev->flags |= IFF_PROMISC;
+			writeb(0x01, &cfg_cmd->promisc);
 		}
 	}
 	if (dev->flags & IFF_PROMISC)
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index 9b2a7f7..e531302 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -425,14 +425,11 @@ static int init586(struct net_device *dev)
 		int len = ((char *) p->iscp - (char *) ptr - 8) / 6;
 		if(num_addrs > len)	{
 			printk("%s: switching to promisc. mode\n",dev->name);
-			dev->flags|=IFF_PROMISC;
+			cfg_cmd->promisc = 1;
 		}
 	}
 	if(dev->flags&IFF_PROMISC)
-	{
-			 cfg_cmd->promisc=1;
-			 dev->flags|=IFF_PROMISC;
-	}
+		cfg_cmd->promisc = 1;
 	cfg_cmd->carr_coll	= 0x00;
 
 	p->scb->cbl_offset	= make16(cfg_cmd);
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index bc30c6e..df22589 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -5520,6 +5520,7 @@ de4x5_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	omr |= OMR_PR;
 	outl(omr, DE4X5_OMR);
 	dev->flags |= IFF_PROMISC;
+	dev->promiscuity++;
 	break;
 
     case DE4X5_CLR_PROM:             /* Clear Promiscuous Mode */
@@ -5528,6 +5529,7 @@ de4x5_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	omr &= ~OMR_PR;
 	outl(omr, DE4X5_OMR);
 	dev->flags &= ~IFF_PROMISC;
+	dev->promiscuity = 0;
 	break;
 
     case DE4X5_SAY_BOO:              /* Say "Boo!" to the kernel log file */
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index 6d13a0d..00a0d79 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -1998,13 +1998,6 @@ __orinoco_set_multicast_list(struct net_device *dev)
 		else
 			priv->mc_count = mc_count;
 	}
-
-	/* Since we can set the promiscuous flag when it wasn't asked
-	   for, make sure the net_device knows about it. */
-	if (priv->promiscuous)
-		dev->flags |= IFF_PROMISC;
-	else
-		dev->flags &= ~IFF_PROMISC;
 }
 
 /* This must be called from user context, without locks held - use
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 49ae970..136220b 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -1409,9 +1409,6 @@ static void wavelan_set_multicast_list(struct net_device * dev)
 			lp->mc_count = 0;
 
 			wv_82586_reconfig(dev);
-
-			/* Tell the kernel that we are doing a really bad job. */
-			dev->flags |= IFF_PROMISC;
 		}
 	} else
 		/* Are there multicast addresses to send? */
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index b584c0e..00a3559 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -1412,9 +1412,6 @@ wavelan_set_multicast_list(struct net_device *	dev)
 	  lp->mc_count = 0;
 
 	  wv_82593_reconfig(dev);
-
-	  /* Tell the kernel that we are doing a really bad job... */
-	  dev->flags |= IFF_PROMISC;
 	}
     }
   else
@@ -1433,9 +1430,6 @@ wavelan_set_multicast_list(struct net_device *	dev)
 	    lp->mc_count = 0;
 
 	    wv_82593_reconfig(dev);
-
-	    /* Tell the kernel that we are doing a really bad job... */
-	    dev->flags |= IFF_ALLMULTI;
 	  }
       }
     else
-- 
1.5.3.4




