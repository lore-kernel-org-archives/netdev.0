From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: [PATCH] skge: resolve tx multiqueue bug
Date: Thu, 24 Jul 2008 08:18:53 +0200
Message-ID: <20080724061853.GA3224@gentoox2.trippelsdorf.de>
References: <20080723101827.GA2236@gentoox2.trippelsdorf.de> <20080723140347.GA2245@gentoox2.trippelsdorf.de> <48874C6A.1020604@cn.fujitsu.com> <20080723.153000.172383135.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Cc: wangchen@cn.fujitsu.com, ag@alessandroguido.name,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-41.synserver.de ([217.119.50.41]:1042 "HELO
	smtp-out-41.synserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752473AbYGXGTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 02:19:08 -0400
Content-Disposition: inline
In-Reply-To: <20080723.153000.172383135.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 23, 2008 at 03:30:00PM -0700, David Miller wrote:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Wed, 23 Jul 2008 23:21:14 +0800
> 
> > Markus Trippelsdorf said the following on 2008-7-23 22:03:
> > > On Wed, Jul 23, 2008 at 12:18:27PM +0200, Markus Trippelsdorf wrote:
> > >> On Wed, Jul 23, 2008 at 04:50:13PM +0800, Wang Chen wrote:
> > >>> Markus Trippelsdorf said the following on 2008-7-23 13:40:
> > >>>> On Tue, Jul 22, 2008 at 11:54:26AM +0200, Alessandro Guido wrote:
> > >>>>> Got a WARNING this morning (2.6.26-05752-g93ded9b) and I think it's related.
> > >>>> Same thing here (latest git):
> > >>>>
> > >>>> skge eth1: enabling interface
> > >>>> skge eth1: disabling interface
> > >>>> ------------[ cut here ]------------
> > >>>> WARNING: at net/core/dev.c:1344 __netif_schedule+0x24/0x6d()
> > >>>> Pid: 1904, comm: ip Not tainted 2.6.26-06077-gc010b2f #33
> > >>>>  [<ffffffff8020b3eb>] system_call_after_swapgs+0x7b/0x80
> > >> ...
> > >>>> ---[ end trace 92936ef183e09876 ]---
> > >>>> skge eth1: enabling interface
> > >>>> skge eth1: Link is up at 100 Mbps, full duplex, flow control both
> > >>>>
> > >>> Markus, please try this.
> > >>>
> > >>> - Add netif_start_queue() in ->open()
> > >>> - netif_carrier_*() is enough, remove netif_*_queue()
> > >> Unfortunately, your patch does not fix this. I still get the same warning.
> > >>
> > > 
> > > This patch works for me:
> > 
> > Your patch works for me too. So I think it's better than mine. :)
> > 
> > Tested-by: Wang Chen <wangchen@cn.fujitsu.com>
> > 
> > Dave, since Markus and me tested this patch, would you please apply it?
> 
> I can't, it's whitespace damaged.  All the tabs are turned into spaces,
> also there is no signoff from Markus.

Sorry, here is a correct version:

- Add netif_start_queue() in ->open()
- netif_carrier_*() is enough, remove netif_*_queue()

Signed-off-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Tested-by: Wang Chen <wangchen@cn.fujitsu.com> 

-- 
Markus

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch_skge.patch"

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 2e26dce..d761296 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -1069,7 +1069,6 @@ static void skge_link_up(struct skge_port *skge)
 		    LED_BLK_OFF|LED_SYNC_OFF|LED_ON);
 
 	netif_carrier_on(skge->netdev);
-	netif_wake_queue(skge->netdev);
 
 	if (netif_msg_link(skge)) {
 		printk(KERN_INFO PFX
@@ -1084,7 +1083,6 @@ static void skge_link_down(struct skge_port *skge)
 {
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
 	netif_carrier_off(skge->netdev);
-	netif_stop_queue(skge->netdev);
 
 	if (netif_msg_link(skge))
 		printk(KERN_INFO PFX "%s: Link is down.\n", skge->netdev->name);
@@ -2450,7 +2448,6 @@ static void skge_phy_reset(struct skge_port *skge)
 	int port = skge->port;
 	struct net_device *dev = hw->dev[port];
 
-	netif_stop_queue(skge->netdev);
 	netif_carrier_off(skge->netdev);
 
 	spin_lock_bh(&hw->phy_lock);
@@ -2640,6 +2637,7 @@ static int skge_up(struct net_device *dev)
 	spin_unlock_irq(&hw->hw_lock);
 
 	napi_enable(&skge->napi);
+	netif_start_queue(dev);
 	return 0;
 
  free_rx_ring:
@@ -2673,8 +2671,6 @@ static int skge_down(struct net_device *dev)
 	if (netif_msg_ifdown(skge))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
-	netif_stop_queue(dev);
-
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
 		del_timer_sync(&skge->link_timer);
 
@@ -3863,7 +3859,6 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 
 	/* device is off until link detection */
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 
 	return dev;
 }

--LZvS9be/3tNcYl/X--
