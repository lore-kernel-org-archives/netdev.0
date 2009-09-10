From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH v3 3/3] ucc_geth: Fix hangs after switching from full to
 half duplex
Date: Fri, 11 Sep 2009 01:48:12 +0400
Message-ID: <20090910214812.GA30564@oksana.dev.rtsoft.ru>
References: <20090910020145.GC31083@oksana.dev.rtsoft.ru>
 <20090910175852.GA18948@oksana.dev.rtsoft.ru>
 <4AA93FB0.5060802@freescale.com>
 <20090910194053.GA24363@oksana.dev.rtsoft.ru>
 <20090910210935.GA26037@oksana.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>,
	Timur Tabi <timur@freescale.com>, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:2343 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753549AbZIJVsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 17:48:10 -0400
Content-Disposition: inline
In-Reply-To: <20090910210935.GA26037@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPC8360 QE UCC ethernet controllers hang when changing link duplex
under a load (a bit of NFS activity is enough).

  PHY: mdio@e0102120:00 - Link is Up - 1000/Full
  sh-3.00# ethtool -s eth0 speed 100 duplex half autoneg off
  PHY: mdio@e0102120:00 - Link is Down
  PHY: mdio@e0102120:00 - Link is Up - 100/Half
  NETDEV WATCHDOG: eth0 (ucc_geth): transmit queue 0 timed out
  ------------[ cut here ]------------
  Badness at c01fcbd0 [verbose debug info unavailable]
  NIP: c01fcbd0 LR: c01fcbd0 CTR: c0194e44
  ...

The cure is to disable the controller before changing speed/duplex
and enable it afterwards.

Though, disabling the controller might take quite a while, so we
better not grab any spinlocks in adjust_link(). Instead, we quiesce
the driver's activity, and only then disable the controller.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

On Fri, Sep 11, 2009 at 01:09:36AM +0400, Anton Vorontsov wrote:
> On Thu, Sep 10, 2009 at 11:40:53PM +0400, Anton Vorontsov wrote:
> > On Thu, Sep 10, 2009 at 01:04:32PM -0500, Scott Wood wrote:
> > > Anton Vorontsov wrote:
> > > >MPC8360 QE UCC ethernet controllers hang when changing link duplex
> > > >under a load (a bit of NFS activity is enough).
> > > >
> > > >  PHY: mdio@e0102120:00 - Link is Up - 1000/Full
> > > >  sh-3.00# ethtool -s eth0 speed 100 duplex half autoneg off
> > > >  PHY: mdio@e0102120:00 - Link is Down
> > > >  PHY: mdio@e0102120:00 - Link is Up - 100/Half
> > > >  NETDEV WATCHDOG: eth0 (ucc_geth): transmit queue 0 timed out
> > > >  ------------[ cut here ]------------
> > > >  Badness at c01fcbd0 [verbose debug info unavailable]
> > > >  NIP: c01fcbd0 LR: c01fcbd0 CTR: c0194e44
> > > >  ...
> > > >
> > > >The cure is to disable the controller before changing speed/duplex
> > > >and enable it afterwards.
> > > >
> > > >Since ugeth_graceful_stop_{tx,rx} now may be called from an atomic
> > > >context, switch the two functions from msleep() to mdelay().
> > > 
> > > Ouch.
> > 
> > Yeah, right... delaying for 10ms with irqs off isn't good.
> > 
> > > Can we put this in a workqueue or something?
> > 
> > adjust_link() itself isn't called from an atomic context.
> 
> Oops. I though that phylib calls us from a workqueue, not a timer. Hm...
> 
> Will be a little bit more work..

Ignore me. I'm working on two kernel versions in parallel (2.6.21 and
mainline), and it's 2.6.21 where phylib uses a timer. Mainline is OK.

How about this patch?

 drivers/net/ucc_geth.c |   36 +++++++++++++++++++++++++++++++-----
 1 files changed, 31 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 2a2c973..232fef9 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1560,6 +1560,25 @@ static int ugeth_disable(struct ucc_geth_private *ugeth, enum comm_dir mode)
 	return 0;
 }
 
+static void ugeth_quiesce(struct ucc_geth_private *ugeth)
+{
+	/* Wait for and prevent any further xmits. */
+	netif_tx_disable(ugeth->ndev);
+
+	/* Disable the interrupt to avoid NAPI rescheduling. */
+	disable_irq(ugeth->ug_info->uf_info.irq);
+
+	/* Stop NAPI, and possibly wait for its completion. */
+	napi_disable(&ugeth->napi);
+}
+
+static void ugeth_activate(struct ucc_geth_private *ugeth)
+{
+	napi_enable(&ugeth->napi);
+	enable_irq(ugeth->ug_info->uf_info.irq);
+	netif_tx_wake_all_queues(ugeth->ndev);
+}
+
 /* Called every time the controller might need to be made
  * aware of new link state.  The PHY code conveys this
  * information through variables in the ugeth structure, and this
@@ -1573,14 +1592,11 @@ static void adjust_link(struct net_device *dev)
 	struct ucc_geth __iomem *ug_regs;
 	struct ucc_fast __iomem *uf_regs;
 	struct phy_device *phydev = ugeth->phydev;
-	unsigned long flags;
 	int new_state = 0;
 
 	ug_regs = ugeth->ug_regs;
 	uf_regs = ugeth->uccf->uf_regs;
 
-	spin_lock_irqsave(&ugeth->lock, flags);
-
 	if (phydev->link) {
 		u32 tempval = in_be32(&ug_regs->maccfg2);
 		u32 upsmr = in_be32(&uf_regs->upsmr);
@@ -1631,9 +1647,21 @@ static void adjust_link(struct net_device *dev)
 			ugeth->oldspeed = phydev->speed;
 		}
 
+		/*
+		 * To change the MAC configuration we need to disable the
+		 * controller. To do so, we have to either grab ugeth->lock,
+		 * which is a bad idea since 'graceful stop' commands might
+		 * take quite a while, or we can quiesce driver's activity.
+		 */
+		ugeth_quiesce(ugeth);
+		ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
+
 		out_be32(&ug_regs->maccfg2, tempval);
 		out_be32(&uf_regs->upsmr, upsmr);
 
+		ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
+		ugeth_activate(ugeth);
+
 		if (!ugeth->oldlink) {
 			new_state = 1;
 			ugeth->oldlink = 1;
@@ -1647,8 +1675,6 @@ static void adjust_link(struct net_device *dev)
 
 	if (new_state && netif_msg_link(ugeth))
 		phy_print_status(phydev);
-
-	spin_unlock_irqrestore(&ugeth->lock, flags);
 }
 
 /* Initialize TBI PHY interface for communicating with the
-- 
1.6.3.3

